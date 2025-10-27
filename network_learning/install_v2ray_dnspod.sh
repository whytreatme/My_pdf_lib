#!/usr/bin/env bash
set -euo pipefail

# ---------- 彩色日志 ----------
BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
log(){ echo -e "${BLUE}[INFO]${NC} $*"; }
ok(){  echo -e "${GREEN}[OK]${NC}   $*"; }
warn(){echo -e "${YELLOW}[WARN]${NC} $*"; }
die(){ echo -e "${RED}[ERR]${NC}  $*"; exit 1; }

[ "$(id -u)" -eq 0 ] || die "必须用 root 运行。"

need() { command -v "$1" >/dev/null 2>&1 || (apt-get update -y && apt-get install -y "$1"); }

log "安装依赖（curl socat jq qrencode ufw nginx）"
need curl; need socat; need jq; need qrencode; need ufw; need nginx

read -rp "请输入你的域名（如 example.com）: " DOMAIN
[ -n "${DOMAIN}" ] || die "域名不能为空"

read -rp "用于 ACME 的邮箱（如 name@gmail.com）: " EMAIL
[ -n "${EMAIL}" ] || die "邮箱不能为空"

echo
echo "== DNSPod API Token（到 DNSPod 控制台-用户中心-API 密钥 获取）=="
read -rp "DP_Id  : " DP_Id
[ -n "${DP_Id}" ] || die "DP_Id 不能为空"
read -rp "DP_Key : " DP_Key
[ -n "${DP_Key}" ] || die "DP_Key 不能为空"

# ---------- 变量 ----------
SCRIPT_DIR="/opt/v2ray-sh"
SITE_DIR="/etc/nginx/sites-available"
ENABLE_DIR="/etc/nginx/sites-enabled"
WEB_ROOT="/var/www/${DOMAIN}"
CERT_DIR="/etc/v2ray"
UUID="$(cat /proc/sys/kernel/random/uuid)"
WS_PATH="/$(echo "${UUID}" | cut -d'-' -f1)"   # 形如 /a1b2c3d4
VMESS_PORT="443"

mkdir -p "${SCRIPT_DIR}" "${WEB_ROOT}" "${CERT_DIR}"

# ---------- 安装 acme.sh ----------
if [ ! -d "/root/.acme.sh" ]; then
  log "安装 acme.sh"
  curl https://get.acme.sh | sh -s email="${EMAIL}"
fi
[ -f "/root/.bashrc" ] && . /root/.bashrc || true
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt >/dev/null 2>&1 || true

# ---------- DNSPod 自动签发证书 ----------
log "通过 DNSPod 自动签发证书（自动续期）"
export DP_Id="${DP_Id}"
export DP_Key="${DP_Key}"
/root/.acme.sh/acme.sh --issue -d "${DOMAIN}" --dns dns_dp --keylength ec-256 --force \
  || die "证书签发失败：请检查 DP_Id/DP_Key 是否正确、域名是否在 DNSPod 托管"

mkdir -p "${CERT_DIR}"
/root/.acme.sh/acme.sh --installcert -d "${DOMAIN}" --ecc \
  --fullchain-file "${CERT_DIR}/v2ray.crt" \
  --key-file      "${CERT_DIR}/v2ray.key" \
  || die "证书安装失败"

chmod 644 "${CERT_DIR}/v2ray.crt"
chmod 600 "${CERT_DIR}/v2ray.key"
chown root:root "${CERT_DIR}/v2ray.crt" "${CERT_DIR}/v2ray.key"
ok "证书已安装到 ${CERT_DIR}/v2ray.crt|.key（acme.sh 已自动写入续期任务）"

# ---------- 安装 V2Ray ----------
log "安装/升级 V2Ray"
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
ok "V2Ray 安装完成"

# ---------- 写入 V2Ray 配置（WS 回环到 127.0.0.1:10000） ----------
V2RAY_CFG="/usr/local/etc/v2ray/config.json"
cat > "${V2RAY_CFG}" <<JSON
{
  "log": {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "ws-in",
      "port": 10000,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          { "id": "${UUID}", "alterId": 0 }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "${WS_PATH}" }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "settings": {} },
    { "protocol": "blackhole", "settings": {}, "tag": "blocked" }
  ],
  "routing": { "rules": [] }
}
JSON

mkdir -p /var/log/v2ray
chown -R nobody:nogroup /var/log/v2ray || true
chmod 755 /var/log/v2ray

# 兼容不同系统 v2ray.service 路径
UNIT="/etc/systemd/system/v2ray.service"
[ -f "/lib/systemd/system/v2ray.service" ] && UNIT="/lib/systemd/system/v2ray.service"
cp -a "${UNIT}" "${UNIT}.backup" || true
cat > "${UNIT}" <<'UNIT'
[Unit]
Description=V2Ray Service
Documentation=https://www.v2fly.org/
After=network.target nss-lookup.target

[Service]
Type=simple
User=nobody
Group=nogroup
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStartPre=/bin/mkdir -p /var/log/v2ray
ExecStart=/usr/local/bin/v2ray run -config /usr/local/etc/v2ray/config.json
Restart=on-failure
LimitNPROC=100000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload

# ---------- 写 Nginx 站点（443 TLS + WS 反代） ----------
SITE_FILE="${SITE_DIR}/v2ray-${DOMAIN}"
cat > "${SITE_FILE}" <<NGINX
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN};

    ssl_certificate     ${CERT_DIR}/v2ray.crt;
    ssl_certificate_key ${CERT_DIR}/v2ray.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    root ${WEB_ROOT};
    index index.html;

    location ${WS_PATH} {
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_read_timeout 120s;
        proxy_pass http://127.0.0.1:10000;
    }
}
NGINX

echo "<h1>Welcome to ${DOMAIN}</h1><p>V2Ray WS path: ${WS_PATH}</p>" > "${WEB_ROOT}/index.html"
ln -sf "${SITE_FILE}" "${ENABLE_DIR}/v2ray-${DOMAIN}"
[ -e "${ENABLE_DIR}/default" ] && rm -f "${ENABLE_DIR}/default"

nginx -t || die "Nginx 配置检测失败"

# ---------- 启动服务 + 放行防火墙 ----------
log "启动服务"
systemctl enable v2ray nginx
systemctl restart v2ray nginx

ufw allow 22/tcp >/dev/null 2>&1 || true
ufw allow 80/tcp  >/dev/null 2>&1 || true
ufw allow 443/tcp >/dev/null 2>&1 || true
yes | ufw enable  >/dev/null 2>&1 || true

sleep 2
systemctl is-active --quiet v2ray || die "V2Ray 启动失败：journalctl -u v2ray -e"
systemctl is-active --quiet nginx  || die "Nginx 启动失败：journalctl -u nginx -e"
ok "V2Ray + Nginx 已运行"

# ---------- 生成 VMess 信息 ----------
CLIENT_JSON=$(jq -n \
  --arg v "2" \
  --arg ps "${DOMAIN}" \
  --arg add "${DOMAIN}" \
  --arg port "${VMESS_PORT}" \
  --arg id "${UUID}" \
  --arg aid "0" \
  --arg scy "auto" \
  --arg net "ws" \
  --arg type "none" \
  --arg host "${DOMAIN}" \
  --arg path "${WS_PATH}" \
  --arg tls "tls" \
  '{v:$v, ps:$ps, add:$add, port:$port, id:$id, aid:$aid, scy:$scy, net:$net, type:$type, host:$host, path:$path, tls:$tls}')

VMESS_URL="vmess://$(echo -n "${CLIENT_JSON}" | base64 -w 0)"

echo
echo "================= 安装完成 ================="
echo "域名:        ${DOMAIN}"
echo "端口:        443"
echo "UUID:        ${UUID}"
echo "Network:     ws"
echo "Path:        ${WS_PATH}"
echo "TLS:         enabled"
echo "-------------------------------------------"
echo "VMess URL（复制到客户端）:"
echo "${VMESS_URL}"
echo "-------------------------------------------"
echo "二维码（终端预览，V2RayN/V2RayNG 可扫码）："
qrencode -t ANSIUTF8 "${VMESS_URL}" || true
echo "==========================================="
ok "全部完成。证书将由 acme.sh 自动续期（cron 已安装）。"

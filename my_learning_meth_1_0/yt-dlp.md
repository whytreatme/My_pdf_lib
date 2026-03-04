## 问  
请为我提取yt-dlp的常用指令并且附上使用示例  

## 答  
您好！我是 GitHub Copilot。根据您提供的 `supportedsites.md` 文件（来自 `yt-dlp` 仓库），该文件主要列出了支持的网站。

为了帮助您更好地使用 `yt-dlp`，我为您整理了该工具最常用的指令及其使用示例。

### 1. 基础下载 (最简单用法)
直接下载视频，默认会选择质量最好的视频和音频轨道。
```bash
yt-dlp "视频链接"
```

### 2. 查看视频所有格式
在下载前，查看该视频提供哪些分辨率、编码和大小。
```bash
# 示例：查看 YouTube 视频的可选格式
yt-dlp -F "https://www.youtube.com/watch?v=极速代码"
```

### 3. 选择特定质量/格式下载
利用 `-f` 参数选择视频和音频。
*   `bestvideo+bestaudio`: 下载质量最好的视频和音频并合并。
*   `"bestvideo[height<=1080]+bestaudio/best"`: 下载最高不超过 1080p 的视频。

```bash
# 示例：下载 1080p 的视频并合并音频
yt-dlp -f "bestvideo[height<=1080]+bestaudio/best" "链接"
```

### 4. 仅下载音频
常用于下载音乐或播客。可以使用 `--extract-audio` 配合 `--audio-format`。
```bash
# 示例：下载并转换为 mp3 格式 (默认最高质量)
yt-dlp -x --audio-format mp3 "链接"
```

### 5. 下载整个播放列表 (Playlist)
`yt-dlp` 默认会自动下载链接中的整个播放列表。
```bash
# 示例：下载整个播放列表
yt-dlp "https://www.youtube.com/playlist?list=..."

# 示例：仅下载列表中的第 1 到第 5 个视频
yt-dlp --playlist-start 1 --playlist-end 5 "链接"
```

### 6. 自定义输出文件名
使用 `-o` 参数可以根据上传者、日期、标题等元数据自动命名。
```bash
# 示例：命名格式为 [上传日期] 视频标题.扩展名
yt-dlp -o "[%(upload_date)s] %(title)s.%(ext)s" "链接"
```

### 7. 下载字幕
```bash
# 示例：下载所有可用字幕，但不下载视频
yt-dlp --write-subs --all-subs --skip-download "链接"

# 示例：下载自动生成的中文字幕并嵌入到视频中
yt-dlp --write-auto-subs --sub-langs "zh.*" --embed-subs "链接"
```

### 8. 使用 Cookie (解决登录/年龄限制问题)
如果您需要下载需要登录或有年龄限制的视频，可以从浏览器导出 Cookies。
```bash
# 示例：从 Chrome 浏览器自动获取 cookies
yt-dlp --cookies-from-browser chrome "链接"
```

### 9. 限制下载速度
防止占用过多带宽。
```bash
# 示例：限速为 1MB/s
yt-dlp -r 1M "链接"
```

### 10. 更新 yt-dlp
由于视频网站经常更新，建议定期更新工具：
```bash
yt-dlp -U
```

如果您想针对特定网站（如您提供的列表中提到的 **Bilibili** 或 **Youtube**）进行更高级的操作，可以随时问我！  

## 问  
yt-dlp -o "D:\vid_file%(title)s.%(ext)s" -F --write-subs --cookies-from-browser edge "https://www.bilibili.com/video/BV1im9vYKEWB/?spm_id_from=333.337.search-card.all.click&vd_source=c293e39b108905f17006fad53f6c6ff5"
[BiliBili] Extracting URL: https://www.bilibili.com/video/BV1im9vYKEWB/?spm_id_from=333.337.search-card.all.click&vd_source=...05f17006fad53f6c6ff5
[BiliBili] 1im9vYKEWB: Downloading webpage
Extracting cookies from edge
ERROR: Could not copy Chrome cookie database. See  https://github.com/yt-dlp/yt-dlp/issues/7271  for more info
ERROR: Could not copy Chrome cookie database. See  https://github.com/yt-dlp/yt-dlp/issues/7271  for more info
这是什么回事？  

## 答  
这个错误 `ERROR: Could not copy Chrome cookie database` 是在使用 `yt-dlp` 从基于 Chromium 的浏览器（如 **Edge**、Chrome、Brave 等）提取 Cookies 时非常常见的问题。

其根本原因是：**浏览器正在运行中，且锁定了 Cookies 数据库文件**。

以下是解决该问题的几种方案，按推荐程度排序：

### 方案一：关闭 Edge 浏览器（最直接）
这是最有效的解决方法。Edge 会锁定 `Cookies` 数据库文件以防止外部修改。
1.  **完全关闭 Edge 浏览器**（确保后台没有残留进程，可以在任务管理器中确认一下）。
2.  重新运行您的 `yt-dlp` 命令。

### 方案二：使用 `--cookies-from-browser` 的完整语法
有时候 `yt-dlp` 无法自动找到 Edge 的正确配置文件（Profile）。您可以尝试指定具体的配置文件：
```bash
# 尝试指定默认配置文件 "Default"
yt-dlp -o "D:\vid_file\%(title)s.%(ext)s" -F --write-subs --cookies-from-browser edge:Default "视频链接"
```
*注：如果您的 Edge 登录了多个账号，可以尝试 `edge:Profile 1` 或 `edge:Profile 2`。*

### 方案三：手动导出 Cookies 文件 (备选方案)
如果浏览器锁定问题始终无法解决，您可以手动导出 Cookies。
1.  在 Edge 浏览器中安装一个插件，例如 **"Get cookies.txt LOCALLY"** 或 **"EditThisCookie"**。
2.  登录 Bilibili，然后使用插件将 Cookies 导出为 `cookies.txt`。
3.  在指令中直接调用该文件：
```bash
yt-dlp -o "D:\vid_file\%(title)s.%(ext)s" -F --write-subs --cookies "D:\path\to\cookies.txt" "视频链接"
```

### 方案四：修正您的输出路径格式
在您的原始指令中，路径 `D:\vid_file%(title)s.%(ext)s` 可能会导致文件直接保存在 D 盘根目录并以 `vid_file` 开头。建议在文件夹后面加上**反斜杠 `\`**：
```bash
# 修正后的路径建议：
yt-dlp -o "D:\vid_file\%(title)s.%(ext)s" ...
```

---

### 总结建议：
请先尝试**彻底关闭 Edge 浏览器**，然后再次运行。如果还是报错，可以尝试使用 `yt-dlp -U` 先更新一下工具版本，因为 `yt-dlp` 经常会修复针对新版浏览器数据库锁定的兼容性问题。  

## 编码格式  
根据您上传的图片 ![image1](image1)，这是 yt-dlp -F 指令执行后列出的视频和音频格式列表。

为了让您更好地理解，我将图片中的信息分为几个核心部分来解释：

1. 核心列名解释
ID: 格式代码。下载时使用 -f ID 来指定。
EXT: 文件扩展名（mp4, m4a 等）。
RESOLUTION: 分辨率（如 1920x1080 代表 1080p）。
VCODEC: 视频编码（avc1 是兼容性最好的 H.264，av01 是 AV1 编码，体积更小但较吃性能）。
ACODEC: 音频编码（mp4a.40.2 是常见的 AAC 音频）。
FILESIZE: 预估的文件大小。
2. 具体格式分析
在 Bilibili 的这个列表中，视频和音频通常是分离的（即 video only 和 audio only）：

音频部分 (ID 30216, 30232, 30280):
这些只有声音，没有画面。
30280 是目前列表中最好的音频（68k 比特率）。
视频部分 (ID 300xx 和 1000xx):
这些只有画面，没有声音。
100026: 1080p, AV1 编码 (av01)，约 26.97 MiB。
30080: 1080p, H.264 编码 (avc1)，约 35.27 MiB。
区别：如果你想在旧电脑或电视上播放，选 30080 (avc1)；如果你想要更小的体积且设备较新，选 100026 (av1)。
3. 如何根据这个列表下载？
由于视频和音频是分开的，您通常需要使用 视频ID+音频ID 的组合：

示例 A：下载最好的 1080p 视频 + 最好的音频

bash
# 30080 是 1080p 视频，30280 是最好的音频
yt-dlp -f "30080+30280" "视频链接"
示例 B：下载最好的 720p 视频 (AV1 编码) + 最好的音频

bash
yt-dlp -f "100024+30280" "视频链接"
示例 C：只下载音频（只要声音）

bash
yt-dlp -f "30280" "视频链接"
提示：
如果您不指定 -f，yt-dlp 默认会自动为您选择 bestvideo+bestaudio。也就是它会自动把 30080 (或 100026) 和 30280 合并成一个带声音的完整视频。只有在默认选择不符合需求时，才需要对照这个列表手动指定 ID。  

## 参考链接  
[如何使用yt-dlp](https://funglearn.top/00620250301-2/)
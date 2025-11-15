## 问  
在客户端和服务器通信的时候，客户端必须提前知道服务端的ip地址和端口，而服务端不需要知道客户端的ip地址对吗？  

完全正确。你抓住了 TCP/IP 通信模型的一个核心逻辑。

我们分成两边来看：

---

### 🟦 服务端（Server）

* 服务端的角色是**“等待连接”**。
* 它只需要：

  1. 知道自己要监听的 IP 地址（通常是本机 IP 或 `INADDR_ANY` 表示任意地址）。
  2. 知道监听的端口号（比如 8080、80、22 等）。

```c
bind(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr));
listen(sockfd, SOMAXCONN);
```

* 一旦有客户端请求连接，服务端通过：

  ```c
  int connfd = accept(sockfd, (struct sockaddr *)&client_addr, &len);
  ```

  系统**自动**告诉它客户端的 IP 和端口信息（`client_addr` 中包含）。

> ✅ 所以服务端不需要事先知道客户端是谁，系统在 `accept()` 时就会把这信息填好。

---

### 🟩 客户端（Client）

* 客户端的角色是**“主动发起连接”**。
* 它必须知道服务端的：

  * **IP 地址**（例如 `"192.168.1.10"`）
  * **端口号**（例如 `8080`）

```c
connect(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr));
```

* 只有这样，TCP 协议才能建立三次握手，让客户端和指定的服务器通信。

> ✅ 客户端不需要知道自己绑定的端口，系统会自动分配一个临时端口（ephemeral port）。

---

### 🧩 总结对比表

| 项目                | 服务端                   | 客户端                |
| ----------------- | --------------------- | ------------------ |
| 是否需要提前知道对方 IP 和端口 | ❌ 不需要（系统在 accept 时给）  | ✅ 必须知道（用于 connect） |
| 是否需要绑定端口          | ✅ 是（bind 固定端口供别人连）    | ❌ 一般不需要（自动分配临时端口）  |
| 建立连接方式            | 被动等待（listen + accept） | 主动发起（connect）      |
| 如何获知对方地址          | 内核在 accept() 返回时提供    | 通过 connect() 参数指定  |

---

如果你想验证这一点，可以写一段最小 TCP 通信代码，用 `getpeername()` 和 `getsockname()` 打印双方的 IP 与端口，会很直观地看到——客户端主动知道服务器的地址，而服务器是被动在 `accept()` 后才知道客户端是谁。

### 网络通信的流程  
![网络通信的流程](https://i.imgur.com/86PL52B.png)

### 套接字(socket)的简介  
![简介](https://i.imgur.com/AJ1BUVy.png)

# 问  
那对业务层暴露Acceptor, Connection是否有必要？  

# 答  
这是一个非常核心的架构设计问题。在 `muduo` 这种高质量的 Reactor 网络库设计中，答案是：**尽量不直接暴露 `Acceptor`，但需要受控地暴露 `Connection`。**

这种设计权衡是为了在“封装性（易用性）”与“灵活性（功能性）”之间找到平衡。

---

## 1. 为什么不应该暴露 `Acceptor`？

`Acceptor` 的职责非常单一：`socket` -> `bind` -> `listen` -> `accept`。

* **业务无关性：** 业务层（购票系统）完全不需要关心服务器是怎么监听端口的，也不需要关心如何处理三次握手。
* **安全与稳定性：** 如果把 `Acceptor` 暴露给业务层，业务逻辑可能会误操作导致监听停止，或者错误地修改了底层 Socket 选项（如 `REUSEADDR`）。
* **解耦：** `TcpServer` 内部组合了 `Acceptor`。对业务层来说，它只需要调用 `TcpServer::start()`。至于底层是用 `Acceptor` 类实现的，还是直接写在 `TcpServer` 里的，业务层不应该感知。

---

## 2. 为什么必须暴露 `Connection` (TcpConnection)？

`TcpConnection` 是业务层与客户端通信的**唯一抓手**。

* **发送数据：** 购票成功后，你需要调用 `conn->send("Success")`。如果完全隐藏 `Connection`，业务层就失去了下发指令的能力。
* **身份标识：** 在 `onMessage` 回调中，必须传入 `Connection` 指针（或 `shared_ptr`），否则业务逻辑不知道这条“买票指令”是谁发出来的，也就无法关联到特定的 Session。
* **生命周期控制：** 虽然底层会自动处理连接断开，但有时业务层需要主动踢掉违规用户（`conn->forceClose()`）。

---

## 3. 理想的暴露方式：受控的接口

为了防止业务层破坏底层网络状态，`muduo` 采取了以下策略来“暴露”：

### A. 使用 `shared_ptr` 管理生命周期

业务层拿到的通常是 `std::shared_ptr<TcpConnection>`。

> **痛点：** 如果业务处理很慢（比如要去查购票数据库），由于持有 `shared_ptr`，即使客户端断开了，这个连接对象也不会被销毁，保证了业务逻辑执行期间内存的安全。

### B. 限制访问权限

业务层看到的 `TcpConnection` 接口应该是经过精简的：

* **允许：** `send()`、`shutdown()`、`setContext()` (用于绑定用户 ID)、`getPeerAddress()`。
* **隐藏：** 具体的 `Channel` 操作、`EventLoop` 的唤醒细节、底层的读写 Buffer 管理。

---

## 4. 总结：业务层眼中的架构图

在一个设计良好的 Reactor 系统中，业务开发者的视角应该是这样的：

| 组件 | 对业务层的可见性 | 业务层用途 |
| --- | --- | --- |
| **EventLoop** | 半透明 | 通常只在初始化时传入，或者用于定时器任务。 |
| **TcpServer** | **全公开** | 负责启动服务、注册各种 `Callback`。 |
| **Acceptor** | **隐藏** | 完全被 `TcpServer` 封装。 |
| **TcpConnection** | **全公开 (受限接口)** | 用于回复消息、获取客户端 IP、断开连接。 |

### 改进你的代码建议

针对你之前的 `TcpServer` 定义，可以考虑做如下调整：

```cpp
class TcpServer {
    // ...
public:
    // 不要返回 Acceptor，只提供 start 接口
    void start();

    // 提供注册回调的接口，而不是让业务层去改这几个函数
    void setConnectionCallback(ConnectionCallback cb);
    void setMessageCallback(MessageCallback cb);

private:
    // 业务层看不见的底层组件
    std::unique_ptr<Acceptor> acceptor_; 
    // 管理所有连接，业务层通过回调函数拿到其中的某个 Connection 指针
    std::map<int, std::shared_ptr<Connection>> conns_; 
};

```

**下一步建议：**
你想看看如何利用 `std::shared_ptr` 配合 `std::weak_ptr` 来安全地在业务层管理这些 `Connection` 吗？这对于防止购票系统在高并发下出现“对象已销毁但业务还在跑”的崩溃至关重要。
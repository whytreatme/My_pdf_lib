## 问  

非常棒 👍，你已经问到了信号机制的关键细节，而且问得非常精确。
我们来一条条说明，**你问的两个问题其实刚好对应了两个阶段**：

---

## 🧩 第一问：

> 子进程不处理任何信号吗？

### ✅ 答案：

是的，在你这个项目场景（“父监督、子执行外部命令”）下，
**子进程不需要也不应该处理任何信号。**

---

### 📘 原理解释：

1. **`fork()` 后还没 `exec()` 时：**
   子进程只是父进程的拷贝，此时它“继承”父进程的信号处理设置：

   * 哪些信号被屏蔽；
   * 哪些信号被忽略；
   * 哪些信号装了自定义 handler；
   * 哪些信号是默认动作。

2. **`exec()` 成功后：**

   * 所有**自定义信号处理函数**会被**清除**（回到默认动作）；
   * 所有被**忽略**（`SIG_IGN`）的信号仍然保持忽略；
   * 所有**信号屏蔽集**保持不变；
   * 未决信号清空。

👉 所以，在你这种“子进程马上 `execvp()` 执行命令”的场景里，
子进程最终加载的是另一个程序（比如 `/bin/echo` 或 `/bin/ls`），
那个程序有它自己的信号默认行为。
你根本没必要给子进程注册 handler。

---

### 🧩 实际开发习惯

监督器项目里，我们一般只让 **父进程** 处理信号：

| 信号             | 谁来处理 | 用途                      |
| -------------- | ---- | ----------------------- |
| `SIGCHLD`      | 父进程  | 回收子进程（防僵尸）              |
| `SIGINT`       | 父进程  | 优雅退出                    |
| 其他信号（TERM/HUP） | 父进程  | 可选，和 INT 一样退出           |
| 子进程            | 默认动作 | 被 kill 或 Ctrl+C 时自己退出即可 |

> ⚠️ 特别注意：
> 如果父进程要退出，要么 `kill` 所有子进程，要么等子进程都被回收，
> 否则会留下孤儿进程。

---

## 🧩 第二问：

> `sigaction` 是默认 block 吗？还需要 `sigprocmask` 再加一次 block 吗？

### ✅ 答案：

**不是默认 block。**
`sigaction()` 并不会自动阻塞任何信号。
你之所以看到 `sigemptyset(&act.sa_mask)` / `sigaddset()` 这部分，
其实是告诉内核：“在执行这个 handler 的时候，要临时屏蔽哪些信号”。

---

### 📘 举个例子：

```cpp
struct sigaction act;
sigemptyset(&act.sa_mask);
sigaddset(&act.sa_mask, SIGCHLD);
act.sa_handler = handler;
act.sa_flags = SA_RESTART;
sigaction(SIGINT, &act, nullptr);
```

这行的意思是：

> 当执行 `SIGINT` 的处理函数 `handler()` 时，
> 临时屏蔽（block）`SIGCHLD` 信号。
> 处理完之后，再恢复屏蔽集。

---

### 🧠 `sa_mask` 是“执行期间屏蔽集”

* 它只在 handler **运行期间** 生效；
* 离开 handler 后，内核会自动恢复原来的屏蔽集；
* 它不是“永久性”屏蔽信号的手段。

---

### 🧱 那如果要永久屏蔽，就用 `sigprocmask`

比如：

```cpp
sigset_t blockset;
sigemptyset(&blockset);
sigaddset(&blockset, SIGINT);
sigprocmask(SIG_BLOCK, &blockset, NULL); // 永久屏蔽 SIGINT
```

* 这相当于“锁门”；
* 而 `sa_mask` 相当于“执行时暂时关门，执行完再开门”。

---

### ✅ 所以在你这个项目里：

* 不需要再单独用 `sigprocmask`。
* `sigaction` 自带的 `sa_mask` 就够（它是临时的、安全的）。
* 父进程默认不屏蔽任何信号；
* 只有在执行 handler 的时候自动阻塞那些你显式加进去的信号。

---

## 🎯 总结重点：

| 问题                         | 答案                                             |
| -------------------------- | ---------------------------------------------- |
| 子进程需要处理信号吗？                | 不需要，`execvp` 后信号 handler 会被重置，默认动作足够。          |
| `sigaction` 会默认 block 信号吗？ | 不会，只有你 `sigaddset` 的信号会在 handler 执行期间临时 block。 |
| 是否要 `sigprocmask`？         | 不用。除非你想在某段代码里“暂时屏蔽信号”，这才用。                     |

---

如果你想，我可以给你写一个 **信号流图**（比如：父安装 handler → 子继承 → exec 清除 → 父触发 SIGCHLD → handler 自动 block SIGCHLD → waitpid 回收），
一眼看清整个机制的“进出顺序”，要不要？

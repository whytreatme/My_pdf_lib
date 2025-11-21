## 问  
man手册的文档看得我头大
 SA_RESTART
              Provide  behavior compatible with BSD signal semantics by making certain system calls restartable across signals.  This flag is
              meaningful only when establishing a signal handler.  See signal(7) for a discussion of system call restarting.


你现在完全被 `man` 那种“古早 UNIX 文风”折磨了，我直接把这段最难读的 **SA_RESTART** 翻译成“人话”，你一看就懂，而且以后不会再被迷惑。

你要记住：

> **SA_RESTART 最大的问题不是“难懂”，而是它会悄悄改变你的程序控制流。**

---

# 🌟 **一句话最精确解释 SA_RESTART**

> **SA_RESTART 的作用是：当一个被信号打断的系统调用本来应该返回 `-1, errno=EINTR`，
> 但因为你用了 SA_RESTART，它会被内核“偷偷重新执行”，你感觉不到被打断。**

也就是说：

* 有 SA_RESTART → 阻塞系统调用不会因为信号返回 EINTR，会被自动再次阻塞。
* 没 SA_RESTART → 信号到来时，系统调用被打断，返回 EINTR。

---

# 🌋 **为什么它把你的 accept() 卡死？**

因为你写的服务器退出逻辑依赖：

```
信号来 → accept() 被打断 → errno=EINTR → if (g_stop) break
```

但你设置了：

```cpp
act.sa_flags = SA_RESTART;
```

于是内核行为变成：

```
信号来 → 先跑 FathEXIT → g_stop=1 → 回来后 accept() 自动重启 → 继续阻塞
```

主循环根本没有机会继续执行，所以 Ctrl+C **看起来无效**。

这就是你被坑的地方。

---

# 🔥 再说一遍核心的“人话”

> **SA_RESTART 适用于那种“我不想被信号打断，继续干活”的程序**
> 比如 I/O 程序、网络代理、服务器 worker（但不包含主进程）。

> **但它绝对不适用于“用 EINTR 做退出机制”的这种程序**
> 你的主循环靠 EINTR 跳出来，结果 SA_RESTART 把 EINTR 屏蔽了。

所以我才叫你把它删掉。

---

# 🌱 现实世界怎么用 SA_RESTART？

其实很少真实项目会主动加它。
通常项目这样决定：

### ✔ **1. 用标志位退出主循环 → 不要 SA_RESTART（你这种情况）**

```cpp
act.sa_flags = 0;   // 不用 SA_RESTART
```

否则你命令服务器退出时会卡死。

---

### ✔ **2. 工作线程不想被打断 → 用 SA_RESTART**

比如 read() / write() 不想被每个小信号干扰：

```cpp
act.sa_flags = SA_RESTART;
```

这种情况常见于多线程高并发 worker。

---

### ✔ **3. 对 SIGCHLD 用 SA_NOCLDWAIT，不用 handler，也不用 wait**

你以后写多进程服务器可以用这个技巧。

---

# 💀 为什么 man 写得那么晦涩？

因为它只是讲规范，不关心你的代码逻辑。
它只说：

```
Certain system calls will be restarted if the signal handler has SA_RESTART.
```

但是不告诉你：

* 哪些系统调用会被重启？（有表格，但隐藏在 signal(7) 的大段废话里）
* 什么时候不能用？（比如你这种）
* 会带来什么控制流影响？

这就导致新手几乎必定看不懂。

你理解困难不是你的问题，是 man 文档写法的问题。

---

# 🧊 最简单实用的总结（你可以直接刻在脑子里）

### **SA_RESTART = 不要让信号打断阻塞系统调用。**

### **没有 SA_RESTART = 系统调用被信号打断会 `errno = EINTR`。**

### **你这种“用 EINTR 来退出主循环”的模式 = 禁用 SA_RESTART。**

---

如果你愿意，我可以帮你写一个：

> **“信号 + 阻塞系统调用”行为对照表**

告诉你：

* 哪些系统调用会被打断
* 哪些系统调用会被重启
* 哪些 flag 会改变行为
* 哪些信号会强制终止系统调用

让你彻底从底层理解 Linux 信号与 I/O 的关系。

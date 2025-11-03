## 问  
那sigaction函数要怎么使用  

很好，arthur——你问的这个是**信号机制的中心函数**。
`sigaction()` 就是现代 UNIX/Linux 下**唯一推荐的信号注册接口**，
老式的 `signal()` 函数都只是它的简化封装。

我不搞花哨，直接教你最实用的三种用法，从最简单到最完整。
每一步都告诉你“干了什么”“为什么这么写”。

---

## 🧠 一、函数原型与核心概念

```c
#include <signal.h>

int sigaction(int signum,
              const struct sigaction *act,
              struct sigaction *oldact);
```

**含义：**

* `signum`：要处理的信号编号，比如 `SIGINT`、`SIGTERM`。
* `act`：新的信号处理动作（新设置）。
* `oldact`：原来的信号动作（可为 NULL）。

返回 0 成功，-1 失败（查看 errno）。

---

## 🚩 二、`struct sigaction` 的四个关键字段

```c
struct sigaction {
    void     (*sa_handler)(int);          // 简单处理函数（常用）
    void     (*sa_sigaction)(int, siginfo_t *, void *); // 带详细信息的版本
    sigset_t  sa_mask;                    // 处理期间临时屏蔽的信号集合
    int       sa_flags;                   // 行为标志位
};
```

你只要记住三条逻辑：

| 字段           | 功能                            |
| ------------ | ----------------------------- |
| `sa_handler` | 注册普通的处理函数                     |
| `sa_mask`    | 指定在执行这个 handler 时，哪些信号也要一起被屏蔽 |
| `sa_flags`   | 改变行为（如是否带详细信息、是否重启系统调用）       |

---

## ✅ 三、最常见的三种写法

### 1️⃣ 基础版（最常用）

只要捕获 Ctrl+C（SIGINT）并打印一句话：

```c
#include <signal.h>
#include <unistd.h>
#include <stdio.h>

void handle_sigint(int sig) {
    write(STDOUT_FILENO, "Caught SIGINT\n", 14);  // write是异步安全的
}

int main(void) {
    struct sigaction act;
    sigemptyset(&act.sa_mask);    // 不额外屏蔽其他信号
    act.sa_handler = handle_sigint;
    act.sa_flags = SA_RESTART;    // 尽量让系统调用自动重启
    sigaction(SIGINT, &act, NULL);

    while (1) pause(); // 等信号来
}
```

运行后：

* 按 Ctrl+C 不会终止程序；
* 而是执行 `handle_sigint()`；
* `SA_RESTART` 让被打断的 `pause()` 自动重启，不返回 EINTR。

---

### 2️⃣ 带屏蔽控制的版本

当处理 SIGINT 时，同时屏蔽 SIGTERM：

```c
void handle_sigint(int sig) {
    write(STDOUT_FILENO, "SIGINT received, SIGTERM blocked during handling\n", 50);
}

int main(void) {
    struct sigaction act;
    sigemptyset(&act.sa_mask);
    sigaddset(&act.sa_mask, SIGTERM);  // 处理SIGINT时顺便屏蔽SIGTERM
    act.sa_handler = handle_sigint;
    act.sa_flags = SA_RESTART;
    sigaction(SIGINT, &act, NULL);

    while (1) pause();
}
```

👉 意思是：
在执行 `handle_sigint()` 期间，如果 SIGTERM 到来，它不会打断，
等 handler 结束后再处理。

---

### 3️⃣ 高级版（获取发送者信息）

你想知道是谁发的信号、为什么发，可以用 `SA_SIGINFO`：

```c
#include <signal.h>
#include <unistd.h>
#include <stdio.h>

void handle_sigterm(int sig, siginfo_t *info, void *context) {
    char buf[128];
    int len = snprintf(buf, sizeof(buf),
                       "Received SIGTERM from pid=%d, uid=%d\n",
                       info->si_pid, info->si_uid);
    write(STDOUT_FILENO, buf, len);
}

int main(void) {
    struct sigaction act;
    sigemptyset(&act.sa_mask);
    act.sa_sigaction = handle_sigterm;
    act.sa_flags = SA_SIGINFO | SA_RESTART;  // 指定使用 sa_sigaction
    sigaction(SIGTERM, &act, NULL);

    while (1) pause();
}
```

然后你可以在另一个终端输入：

```bash
kill -TERM <你的进程号>
```

输出示例：

```
Received SIGTERM from pid=12345, uid=1000
```

---

## ⚙️ 四、几个常见 `sa_flags` 说明（记住用途就行）

| 标志             | 含义                                |
| -------------- | --------------------------------- |
| `SA_RESTART`   | 让被信号打断的慢系统调用自动重启（推荐几乎都加）          |
| `SA_SIGINFO`   | 使用 `sa_sigaction` 代替 `sa_handler` |
| `SA_RESETHAND` | 执行一次后恢复默认（一次性handler）             |
| `SA_NODEFER`   | 处理时不自动屏蔽当前信号（允许同信号重入，不建议）         |
| `SA_NOCLDSTOP` | 对 `SIGCHLD`：子进程停止时不触发信号           |
| `SA_NOCLDWAIT` | 对 `SIGCHLD`：子进程退出后不进入僵尸状态         |

---

## 🧩 五、和 `signal()` 的区别（你一定要知道）

| 特性        | `signal()` | `sigaction()`       |
| --------- | ---------- | ------------------- |
| 可移植性      | 不同系统语义不同   | ✅ POSIX标准化          |
| 自动重启行为    | 不确定        | ✅ 受 `SA_RESTART` 控制 |
| 可同时屏蔽多个信号 | ❌ 不行       | ✅ 通过 `sa_mask`      |
| 支持详细信息    | ❌          | ✅ 通过 `SA_SIGINFO`   |

👉 所以现代程序、教材、库代码中都用 `sigaction()`。

---

## ✅ 六、推荐的实用模板（适合所有一般用途）

```c
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

static volatile sig_atomic_t got_sigint = 0;

void sigint_handler(int signo) {
    got_sigint = 1; // 只设置标志，异步安全
}

int main(void) {
    struct sigaction act;
    sigemptyset(&act.sa_mask);
    act.sa_handler = sigint_handler;
    act.sa_flags = SA_RESTART;
    sigaction(SIGINT, &act, NULL);

    while (!got_sigint) {
        write(STDOUT_FILENO, "working...\n", 11);
        sleep(1);
    }

    write(STDOUT_FILENO, "caught SIGINT, exiting...\n", 26);
    return 0;
}
```

---

## 🧠 七、思维导图总结

```
           +---------------------+
           | sigaction() 注册信号 |
           +---------------------+
                     |
         +-----------+-----------+
         |                       |
   sa_handler版           sa_sigaction版 (带详细信息)
         |
   处理信号 -> sa_mask 自动屏蔽当前信号
         |
   执行完后 -> 恢复原mask
         |
      SA_RESTART 保证系统调用恢复
```

---

想更彻底理解它的执行顺序（内核何时屏蔽、何时恢复），
我可以帮你画一张“信号到达时序图”，显示 handler 调用栈、屏蔽表变化过程。
要我画给你看吗？

## 问  
我在任意一个函数中调用_exit()，会导致这个进程的结束吗？  

是的。
在任意函数中调用 `_exit()`（注意是下划线开头的 `_exit`，不是 `exit`）都会**立刻终止当前进程**，不会返回，也不会执行任何清理工作。

---

## 🔹一、_exit() 的本质

原型：

```c
#include <unistd.h>
void _exit(int status);
```

它是一个**系统调用级别**的退出函数，直接让内核销毁当前进程。

当你执行 `_exit(status)` 时：

* 当前进程的所有线程都会被终止；
* 进程的文件描述符会被关闭（除非它被 `FD_CLOEXEC` 标记）；
* 不会执行 C 库的缓冲区刷新、`atexit()` 注册的函数、`static`/`global` 对象析构函数。

---

## 🔹二、与 exit() 的区别

| 项目                     | `exit()`              | `_exit()`              |
| ---------------------- | --------------------- | ---------------------- |
| 所在库                    | C 标准库函数（`<stdlib.h>`） | 系统调用（`<unistd.h>`）     |
| 会不会刷新 `stdout` 缓冲区     | ✅ 会                   | ❌ 不会                   |
| 会不会执行 `atexit()` 注册的回调 | ✅ 会                   | ❌ 不会                   |
| 通常使用场景                 | 正常退出程序                | 子进程在 `fork()` 后立刻退出时使用 |

---

## 🔹三、例子对比

```cpp
#include <iostream>
#include <unistd.h>
#include <cstdlib>

void test() {
    std::cout << "In test()\n";
    _exit(0);
    std::cout << "This will never be printed\n";
}

int main() {
    std::cout << "Start\n";
    test();
    std::cout << "End\n";
}
```

运行结果：

```
Start
In test()
```

因为 `_exit(0)` 直接让进程结束，`"End"` 永远不会输出。

如果你改成 `exit(0)`：

```
Start
In test()
End
```

---

## 🔹四、实际应用建议

* ✅ **在子进程中用 `_exit()` 是正确做法**，因为在 `fork()` 之后，子进程会复制父进程的标准 I/O 缓冲。如果用 `exit()`，缓冲区会被刷新两次（导致重复输出）。
* 🚫 **不要在普通函数中随便 `_exit()`**，因为这会跳过所有清理逻辑，让程序直接“硬退出”。

---

## 🔹五、总结一句话

> `_exit()` 就像是“直接拔电源”；
> `exit()` 像是“正常关机”。

---

要不要我给你画一张“`exit` 与 `_exit` 的系统调用流程图”（展示 glibc 到内核的调用路径）？那样你能更直观看出它为什么能瞬间杀掉整个进程。


## 问  
那exit做了什么？

非常好，这个问题问得非常关键。
`exit()` 是我们平时写 C/C++ 程序时经常调用的“**正常退出**”函数，它做的事其实远比 `_exit()` 多得多。

---

## 🔹一、函数原型

```c
#include <stdlib.h>
void exit(int status);
```

它属于 **C 标准库函数**，而不是直接的系统调用。
底层最终还是会调用 `_exit(status)`，但在那之前它会做一堆“收尾工作”。

---

## 🔹二、exit() 的执行步骤（逐层剖析）

当你执行 `exit(status)` 时，C 库大致会按下面的顺序操作：

### **① 调用所有通过 `atexit()` 注册的退出处理函数**

你可以注册一些函数，让它们在程序退出时自动执行：

```c
#include <stdlib.h>
#include <stdio.h>

void goodbye(void) {
    printf("Goodbye!\n");
}

int main() {
    atexit(goodbye);
    printf("main done.\n");
    exit(0);
}
```

输出：

```
main done.
Goodbye!
```

`atexit()` 注册的函数按**逆序调用**（后注册的先执行）。

---

### **② 刷新所有标准 I/O 缓冲区**

C 库的 `printf`、`fprintf`、`fwrite` 等函数通常有缓冲。
在退出前，`exit()` 会把这些缓冲区内容全部写到文件或终端中。

例如：

```c
printf("Hello, world!");
exit(0);
```

即使你没写 `\n`，内容也会被输出，因为退出前缓冲区被刷新。

如果你换成 `_exit(0)`：

```c
printf("Hello, world!");
_exit(0);
```

终端可能什么都不显示，因为缓冲区被直接丢弃。

---

### **③ 关闭所有打开的文件流（FILE *）**

凡是用 `fopen()` 打开的文件，`exit()` 都会自动执行 `fclose()`，确保文件写完、缓存清空。

---

### **④ 调用动态库清理函数**

如果程序使用了共享库（`.so` 文件），`exit()` 会调用库的析构函数（`__fini_array__` 等）来释放资源。

---

### **⑤ 最后一步：调用 `_exit(status)`**

所有上面的收尾工作做完之后，`exit()` 才真正调用 `_exit(status)` 进入内核，让进程彻底结束。

---

## 🔹三、总结对比表

| 功能                 | `exit()`      | `_exit()`     |
| ------------------ | ------------- | ------------- |
| 刷新标准 I/O 缓冲区       | ✅ 是           | ❌ 否           |
| 调用 `atexit()` 注册函数 | ✅ 是           | ❌ 否           |
| 调用全局/静态对象析构函数（C++） | ✅ 是           | ❌ 否           |
| 关闭文件流              | ✅ 是           | ❌ 否           |
| 调用动态库清理函数          | ✅ 是           | ❌ 否           |
| 是否直接进入内核           | ❌（经 glibc 包装） | ✅（直接 syscall） |
| 是否适合子进程退出          | ❌             | ✅             |

---

## 🔹四、C++ 特别说明

在 C++ 中，`exit()` 还会：

* 调用所有静态存储期对象的析构函数（全局变量、静态变量等）。
* 但不会调用局部对象的析构函数（因为栈帧已经被跳过）。

例如：

```cpp
#include <iostream>
using namespace std;

struct Obj {
    ~Obj() { cout << "Obj destroyed\n"; }
};

Obj global_obj; // 全局对象

int main() {
    Obj local_obj; // 局部对象
    exit(0);
}
```

输出：

```
Obj destroyed
```

只销毁了全局对象，局部的 `local_obj` 没有析构，因为 `exit()` 不会返回。

---

## 🔹五、一句话总结

> `exit()` 是“**有礼貌的离开**”，
> `_exit()` 是“**直接拔电源**”。

---

如果你愿意，我可以给你画一张 `exit()` 的执行流程图（从用户态 → glibc → 内核），标出每一步都调用了什么函数（`__run_exit_handlers()`、`_exit()`、`sys_exit_group()`）。
要我画吗？

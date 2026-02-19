# 问_1  
这个syscall(SYS_gettid)是什么东西？  

# 答_1  


syscall(SYS_gettid) 是 Linux 下直接调用内核的系统调用，用来得到当前线程的内核线程 ID（tid）。要点：

- 功能：返回内核层面的线程 id（kernel thread id），不同于 C++ 的 std::this_thread::get_id()（后者是实现定义的 C++ 层 id，非内核 tid）。
- 可移植性：Linux 专用，非跨平台（在 Windows / macOS 上不可用）。
- 头文件：通常需要 #include <sys/syscall.h> 和 #include <unistd.h>。
- 返回值：通常为 long / pid_t，printf 打印时最好转换：
````cpp
#include <sys/syscall.h>
#include <unistd.h>
printf("tid=%ld\n", (long)syscall(SYS_gettid));
````
- 建议：若只需可移植的标识，使用 std::this_thread::get_id()；若需与 kernel 层或 ps/top 匹配，使用 SYS_gettid。  

# 问_2  
syscall是系统调用，那SYS_gettid是什么？  

# 答_2  
SYS_gettid 是内核提供的 gettid 系统调用的编号宏（Linux 专用），用于与 syscall() 一起调用以获取内核线程 ID（tid）。要点：

- 含义：SYS_gettid 对应内核的 gettid syscall，返回当前线程的内核 PID/TID（可与 ps/top 的内核线程 id 对应）。  
- 可移植性：Linux 专用，非 POSIX；跨平台应使用 std::this_thread::get_id()。  
- 头文件：通常需要包含 <sys/syscall.h> 和 <unistd.h>。  
- 返回/打印：syscall 返回 long，可按 pid_t/long 打印（例如 (long)syscall(SYS_gettid)）。

示例：
````cpp
#include <sys/syscall.h>
#include <unistd.h>
#include <stdio.h>

int main() {
    long tid = syscall(SYS_gettid);
    printf("tid=%ld\n", tid);
}
````
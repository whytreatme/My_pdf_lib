# 问  
![线程bug](https://i.imgur.com/TNXrn81.png)  
可能是因为代码bug，我的程序创建了极多的线程直到资源耗尽报错：terminate called after throwing an instance of 'std::system_error'
  what():  Resource temporarily unavailable
我想知道，这些线程是不是随着这个进程的结束，自动把线程资源回收了  

# 答  
会。

### 结论：进程结束时，内核会把该进程的所有线程一并终止并回收资源
在 Linux 里**线程是进程内的执行单元**（共享同一进程地址空间）。一旦进程退出（不管是正常 `return`，还是你这种未捕获异常触发 `std::terminate`/`abort`），内核会：
- 终止该进程下的**全部线程**（不需要你逐个 `join`）
- 回收线程栈、调度实体、TLS 等内核/用户态资源
- 关闭该进程打开的文件描述符（socket 等）

所以你看到 “创建了很多线程直到 `Resource temporarily unavailable` 然后崩溃”，**随着这个进程退出，这批线程不会长期占用系统资源**（不会变成“僵尸线程”挂在系统里）。

> 例外提醒：有些“进程外资源”不一定自动清理（取决于你怎么创建的），比如：某些 SysV 共享内存段、持久化文件、锁文件等；但**线程本身**会随进程结束被清掉。

---

### 你可以这样验证线程数、以及进程退出后是否还在
运行时看线程数量：
````bash
pidof echoserver
cat /proc/$(pidof echoserver)/status | egrep '^(Pid|Threads):'
ps -T -p $(pidof echoserver) | wc -l
````

让它崩溃/退出后再看：
````bash
ps -ef | grep echoserver | grep -v grep
````

如果进程没了，对应线程也就都没了。

---

### 顺带解释一下你的报错
`std::system_error: Resource temporarily unavailable` 通常是创建线程时触发的 `EAGAIN`：达到**每用户线程数限制**、**系统线程上限**、或**内存不足导致无法分配线程栈**。

可快速查看常见限制：
````bash
ulimit -u
cat /proc/sys/kernel/threads-max
````

如果你希望我定位“为什么会创建这么多线程”，把 `echoserver` 里创建 `thpool`/`std::thread` 的代码位置贴出来（尤其是是否在连接/回调里重复 new 线程池），我可以按调用链帮你收敛线程创建点。
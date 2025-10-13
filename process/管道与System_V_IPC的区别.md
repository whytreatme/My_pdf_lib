这是一个非常常见的误解！**System V IPC 里没有管道**。

它们是完全不同的两套进程间通信机制，经常被放在一起讲解，所以容易混淆。

让我来帮你清晰地梳理一下：

---

### 两大IPC家族
| 特性 | System V IPC | 管道 (Pipes) |
| --- | --- | --- |
| 来源 | AT&T Unix System V | 早期的Unix（贝尔实验室） |
| 包含机制 | 消息队列、信号量、共享内存 | 匿名管道、命名管道(FIFO) |
| 管理命令 | ipcs, ipcrm | 没有统一的ipcs命令，FIFO用ls查看 |
| 哲学 | 更结构化，有明确的“对象”概念 | 更简单，遵循“万物皆文件” |

---

### 快速区分表
|  | System V IPC | 管道 (Pipe) | 命名管道 (FIFO) |
| --- | --- | --- | --- |
| 创建函数 | msgget(), semget(), shmget() | pipe() | mkfifo() |
| 查看命令 | ipcs | 无法直接查看 | ls -l（看到类型为p） |
| 持久性 | 内核持久（显式删除才消失） | 进程持久（随进程结束） | 文件系统持久 |
| 通信关系 | 任意进程 | 只能父子进程等有亲缘关系的进程 | 任意进程 |

---

### 为什么容易混淆？
1.     **都是IPC机制**：都在讲进程怎么通信
    
2.     **教材编排**：经常在同一章节介绍
    
3.     **命名管道 vs 消息队列**：两者都能在无亲缘进程间通信，但实现不同

---

### 实际验证

在你的系统上试试：

```bash
# 1. 查看System V IPC对象
arthurlee@arthurlee-virtual-machine:~$ ipcs

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages    

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status      

------ Semaphore Arrays --------
key        semid      owner      perms      nsems     

# 2. 创建和使用命名管道（FIFO）
arthurlee@arthurlee-virtual-machine:~$ mkfifo /tmp/my_fifo
arthurlee@arthurlee-virtual-machine:~$ ls -l /tmp/my_fifo
prw-r--r-- 1 arthurlee arthurlee 0 Oct 12 16:30 /tmp/my_fifo  # 注意开头的 'p'

# 3. 匿名管道在 `ipcs` 中根本看不到！
```

---

### 历史小知识

为什么会有两套机制？
-     **管道**：来自早期的Unix，设计哲学是"简单"和"万物皆文件"
    
-     **System V IPC**：来自AT&T的System V Unix，设计目标是更强大、更结构化的企业级通信

后来POSIX标准也定义了自己的IPC机制（如POSIX消息队列、信号量），但那是另一回事了。

### 总结

**System V IPC 包括三类：**
1.     消息队列
    
2.     信号量
    
3.     共享内存

**管道是另一套机制：**
1.     匿名管道(`pipe()`)
    
2.     命名管道(`mkfifo`)

它们**不属于**System V IPC家族，在`ipcs`命令中也**看不到**管道。

这样清楚了吗？这个区分很重要，因为它们的API、管理方式和适用场景都很不同。
## flag机制的描述
所有的XSI IPC都用get获取标识符

如果希望创建一个新的IPC结构，而且要确保没有引用具有统一标识符的一个现有IPC结构，那么必须在flag中同时指定IPC_CREATE和IPC_EXCL位。这样做了以后，如果IPC结构已经存在就会造成出错，返回EEXIST(这与指定了了O_CREAT和O_EXCL标志的open类似)  

如果只有IPC_CREAT，那机制就是: 1.如果存在已有IPC结构，就直接返回已存在IPC结构的标识符。 2.如果不存在对应的IPC结构，就直接创建新的并返回对应的标识符  

## ipc_perm结构  
```cpp
struct ipc_perm {
    key_t          __key;    /* IPC 键值 */
    uid_t          uid;      /* 所有者的有效用户ID */
    gid_t          gid;      /* 所有者的有效组ID */
    uid_t          cuid;     /* 创建者的有效用户ID */
    gid_t          cgid;     /* 创建者的有效组ID */
    unsigned short mode;     /* 权限模式 */
    unsigned short __seq;    /* 序列号 */
};
```

## semid_ds结构  
semid_ds 结构体是系统用于管理信号量集的元数据（metadata），而不是信号量本身的值或状态，它在信号量在创建的时候随之被创建，由内核来维护
```cpp  
struct semid_ds {
    struct ipc_perm sem_perm;  /* 所有权和权限 */
    time_t          sem_otime; /* 最后一次 semop 的时间 */
    time_t          sem_ctime; /* 最后一次修改的时间 */
    unsigned long   sem_nsems; /* 在集合中的信号量数量 */
    // ... 可能还有其他依赖于内核的字段
};
```  

## semget()函数  
semget(key_t key, int nsems, int flag)
成功返回标识符，失败返回-1  
nsems代表有多少个信号量槽可以使用，但是槽里的值是未定义的  

## 表征信号量自身的结构体  
```cpp  
struct sem{
    unsigned short semval; /* 当前可用的信号量的计数 */  
    pid_t          sempid; /* pid for last operation */
    unsigned short semncnt; /* 等待可用资源 */
    unsigned short semzcnt; /* 等待资源被用完 */

};
```
## semctl()函数  
int  semctl(int semid, int semnum, int cmd, .../* *union semun arg* */)，定义具体信号量中槽的值  
```cpp
union semun{
    int             val; /* for SETVAL */
    struct semid_ds *buf;/* for IPC_STAT and IPC_SET*/
    unsigned short  * array;/* for GETALL and SETALL*/
};
```  
以下是cmd出各种命令的选项
![cmd可能的取值](https://i.imgur.com/l3KEkYZ.png)  
GETALL以外的所有GET命令，semctl函数都返回相应值。对于其它命令，成功返回0，失败设置erron返回-1

## semop()函数  
int semop(int semid, struct sembuf semoparray[], size_t nops);
若成功返回0，若出错返回-1  
semoparry是一个指针，指向sembuff结构体表示的信号量操作数组；
```cpp
struct sembuf{
    unsigned short      sem_num; /* 信号量在集合中的下标(序号) */
    short               sem_op;  /* 操作类型(正数、负数、零)   */
    short               sem_flag; /* 操作标志(如IPC_NOWAIT, SEM_UNDO)*/
};
```  
我们来详细破解这三个成员：

### sem_num（信号量编号）

为什么需要它：System V 信号量是以“集”的形式存在的。一次可以创建一组信号量。这个参数就是用来指定你要操作的是这个集合中的第几个信号量。

类比：就像一个数组 int arr[5]，你要修改 arr[0] 还是 arr[3]？这里的 sem_num 就是那个索引。

示例：如果信号量集包含3个信号量，它们的 sem_num 分别是 0, 1, 2。

### sem_op（操作值）—— 核心中的核心

这个参数的值决定了你的操作行为，它分为三种情况：

情况 A：sem_op > 0 （释放资源）

行为：将该值加到信号量的当前值上。

语义：这通常对应于 V操作（或 post 操作），表示释放占用的资源，使资源可用。

示例：如果 sem_op 是 2，那么执行后 信号量值 += 2。

情况 B：sem_op < 0 （申请资源）

行为：请求信号量值减去 sem_op 的绝对值。但有一个关键条件：只有当信号量的当前值 >= |sem_op|（即绝对值）时，这个减法才能立即完成。

如果条件不满足（信号量当前值 < |sem_op|），默认情况下，调用进程会被阻塞（睡眠），直到其他进程执行了 V操作，使信号量值增加到足够大为止。

语义：这通常对应于 P操作（或 wait 操作），表示申请资源。如果资源不足（信号量值不够大），就等待。

示例：你想申请2个资源单位。sem_op 设为 -2。只有当信号量当前值 >= 2 时，操作才能继续，并将信号量值减去2（信号量值 -= 2）。如果当前值是1，进程就会阻塞。

情况 C：sem_op == 0 （等待归零）

行为：调用者希望等待信号量的值变为 0。

如果当前值就是0：函数立即返回。

如果当前值不是0：默认情况下，调用进程会被阻塞，直到有其他进程将信号量值修改为0。

语义：这种操作常用于等待某种“完成”状态。例如，生产者等待消费者清空缓冲区。

### sem_flg（操作标志）

这个标志用于修改操作的默认行为。常用的有两个：

IPC_NOWAIT：

对于上面的 B（申请资源）和 C（等待归零）两种情况，默认行为是阻塞。

如果指定了 IPC_NOWAIT，当操作无法立即完成时，函数不会阻塞，而是立即返回错误，并设置 errno 为 EAGAIN。

可以理解为“非阻塞模式”。

SEM_UNDO：

这是一个非常重要的标志。它让内核跟踪这个进程对信号量所做的操作。

当进程意外终止（比如被 kill -9 杀掉）时，内核会自动撤销这个进程对信号量所做的所有修改，将信号量值恢复到该进程操作之前的状态。

为什么需要它：防止进程在持有信号量（即锁）时崩溃，导致其他进程永远等待下去（死锁）。

注意：对于需要长期持有的锁，建议使用 SEM_UNDO；对于非常短期的锁，可能不需要。

### size_t nsops
这个也简单：它指定了第二个参数 sops 数组的大小，即你准备一次执行多少个操作。

为什么需要它：semop() 的一个强大特性是它可以原子地（即不可中断地）对一个信号量集中的多个信号量进行一系列操作。要么所有操作都成功，要么所有操作都不执行。

示例：如果你要同时操作信号量集中的第0个和第1个信号量，你就需要定义一个包含两个 sembuf 结构体的数组，并把 nsops 设为 2。  


## 信号量的创建与初始化  
信号量的创建和初始化是分开的，用semget()创建，用semctl初始化。  
在semget()创建一个新的ipc的时候，semid_ds也被初始化，sem_otime = 0; sem_ctime = 当前时间; sem_nsems = nsems  
nsems是集合中有的信号量数，新集合必须指定nsems。引用集合可以将其置为0
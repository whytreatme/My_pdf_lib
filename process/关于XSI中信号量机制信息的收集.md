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

## 信号量的创建与初始化  
信号量的创建和初始化是分开的，用semget()创建，用semctl初始化
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
    unsigned short semval; /* 当前可用的进程数量 */  
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


## 信号量的创建与初始化  
信号量的创建和初始化是分开的，用semget()创建，用semctl初始化。  
在semget()创建一个新的ipc的时候，semid_ds也被初始化，sem_otime = 0; sem_ctime = 当前时间; sem_nsems = nsems  
nsems是集合中有的信号量数，新集合必须指定nsems。引用集合可以将其置为0
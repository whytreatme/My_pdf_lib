**System V信号量** 是Unix/Linux系统中的一种**进程间通信(IPC)机制**，与POSIX信号量是两套不同的标准。

## 🏗️ System V IPC 三大组件

System V IPC包含三个主要机制：
-     **信号量**(`semget`, `semop`, `semctl`)
    
-     **消息队列**(`msgget`, `msgsnd`, `msgrcv`)
    
-     **共享内存**(`shmget`, `shmat`, `shmdt`)

## 🔍 System V信号量核心特性

### 1. **系统级持久性**

```cpp
// 创建信号量
int semid = semget(0x1234, 1, 0666|IPC_CREAT);

// 即使创建进程退出，信号量依然存在系统中
// 必须显式删除：semctl(semid, 0, IPC_RMID)
```

### 2. **信号量集**

```cpp
// 一次性创建多个信号量
int semid = semget(0x1234, 3, 0666|IPC_CREAT);
// 包含3个信号量：sem[0], sem[1], sem[2]
```

### 3. **复杂的原子操作**

```cpp
struct sembuf ops[2] = {
    {0, -1, SEM_UNDO},  // 对信号量0进行P操作
    {1, +1, SEM_UNDO}   // 对信号量1进行V操作
};
semop(semid, ops, 2);  // 原子性地执行两个操作
```

## 📊 与POSIX信号量对比
| 特性 | System V信号量 | POSIX信号量 |
| --- | --- | --- |
| 命名 | 数字key | 路径名 |
| 持久性 | 内核持久 | 通常进程内 |
| 操作粒度 | 支持信号量集 | 单个信号量 |
| 原子性 | 支持多操作原子执行 | 单操作 |
| 复杂性 | 高 | 低 |
| 性能 | 相对较慢 | 较快 |

## 🔧 核心API详解

### `semget()`-获取信号量集

```cpp
int semget(key_t key, int nsems, int semflg);
```
-     `key`: 唯一标识符，如`0x5000`
    
-     `nsems`: 信号量个数
    
-     `semflg`: 权限标志，如`0666|IPC_CREAT`

### `semop()`-执行操作

```cpp
int semop(int semid, struct sembuf *sops, size_t nsops);
```

`sembuf`结构：

```cpp
struct sembuf {
    unsigned short sem_num;  // 信号量编号
    short          sem_op;   // 操作值
    short          sem_flg;   // 标志
};
```

### `semctl()`-控制操作

```cpp
int semctl(int semid, int semnum, int cmd, ...);
```

常用命令：
-     `SETVAL`: 设置信号量值
    
-     `GETVAL`: 获取信号量值
    
-     `IPC_RMID`: 删除信号量集

## 💡 实际使用示例

### 创建和初始化：

```cpp
// 1. 创建信号量
int semid = semget(0x5000, 1, 0666|IPC_CREAT);

// 2. 初始化值为1
union semun arg;
arg.val = 1;
semctl(semid, 0, SETVAL, arg);
```

### P/V操作：

```cpp
// P操作 (wait)
struct sembuf p_op = {0, -1, SEM_UNDO};
semop(semid, &p_op, 1);

// V操作 (post)  
struct sembuf v_op = {0, +1, SEM_UNDO};
semop(semid, &v_op, 1);
```

## 🎯 为什么选择System V信号量？

**适用场景：**
1.     **进程间复杂同步**：需要跨多个进程的精细同步
    
2.     **资源管理**：管理多个相关资源（信号量集）
    
3.     **原子多操作**：需要原子性地执行多个信号量操作
    
4.     **遗留系统**：维护老代码库

**不适用场景：**
-     简单的线程间同步
    
-     性能要求高的场景
    
-     新项目开发（推荐POSIX信号量）

## 🔄 总结

System V信号量是**更重量级、功能更强**的IPC机制，而POSIX信号量是**更轻量级、更简单**的现代替代方案。你的代码使用System V信号量可能是因为：
-     需要进程间通信
    
-     历史代码库维护
    
-     需要信号量集的复杂功能

理解了这种区别，就能明白为什么你的代码不使用`sem_init`/`sem_wait`/`sem_post`那一套API了。
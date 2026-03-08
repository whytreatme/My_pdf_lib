## 待解决的技术债务  
| 模块 | 问题类型 | 描述 | 风险点 |
| :--- | :--- | :--- | :--- |
| **Snowflake** | **逻辑漏洞** | `nextId()` 发生时钟回拨时返回 `-1`，DAO 层未做判断。 | 导致数据库插入 ID 为 -1 的记录，产生主键冲突。 |
| **Service** | **原子性缺失** | `createUser` 过程（插入用户 + 开户）没有使用 `db.transaction()`。 | 产生“孤儿用户”（有用户信息但没银行账户），导致业务逻辑崩坏。 |
| **Database** | **碰撞隐患** | 卡号 `6222 + 随机数` 生成算法在分布式或高频注册下可能重复。 | 数据库 `UNIQUE` 报错导致注册随机失败，用户体验极差。 |
| **Protocol** | **实验任务** | 移除 `qToBigEndian` 观察 4 字节长度字段在网络流中的变化。 | 理解小端序（0x01000000）与大端序（0x00000001）的本质区别。 |
| **Reactor** | **资源清理** | 检查 `onDisconnected` 中是否准确移除了所有 `QHash` 里的 Socket 键值对。 | 长期运行产生 OOM（内存溢出），Map 容器无限膨胀。 |  

| 模块 | 问题类型 |	描述 | 架构优化方案 |  
| :--- | :--- | :--- | :--- |
| **Reactor** |	**会话弹性** |	 `物理连接断开导致用户缓冲区 m_buffers 瞬间丢失。 |	引入 Session 机制，将缓冲区与 Token 绑定，而非与 Socket 指针绑定。 |
| **Network** |	**心跳检测** | `	代码中目前缺少 keepalive，无法检测“半打开”连接（假连接）。 |	增加 QTimer 定时清理长时间无响应的 Socket。          |


# 用于作为我复习次数的记录

## 计算机网络类

1.ARP解析协议 2025/2/22 first review  
2.随机MAC地址 2025/2/23 first review  
3.网关地址    2025/2/23 first review  
4.网关地址的选取 2025/2/23 first review  
5.网卡与网络适配器 2025/2/23 first review  
6.广播的作用    2025/2/23 first review  
7.环回地址      2025/2/23 first review  
8.公网与私网     2025/2/23 first review  
9.root与ftp     2025/2/25 first review  
10. http代理     2025/2/26 first review  
11...问题引出http代理及端口通信问题 2025/3/12 first review  
12.root与ftp    2025/11/20  second review  
13.本地代理工具与流量加密    2025/11/20 first review  
14.云服务器下载镜像   2025/11/21 first review  
15.云服务器地址转换  2025/11/21 first review  
16.什么是SSH连接    2025/11/21 first review  
17.什么是网关       2025/11/22 first review  
18.网关地址         2025/11/22 second review  
19.网关地址的选取    2025/11/22 second review  
20.网卡与网络适配器   2025/11/23 second review  
21.虚拟机的网络适配器  2025/11/23 first review  
22.调制解调器和路由器  2025/11/23 first review
## linux学习类  
1._etc目录作用  2025/2/28 first review  
2.通配符        2025/2/28 first review  
3._etc_password的解释  2025/2/28 first review  
4.分布编译       2025/2/28  first review  
5.chmod的使用    2025/2/28  first review  
6.chmod命令的作用 2025/2/28  first review  
7.chmod的使用    2025/3/6   second review  
8.chomd命令的作用 2025/3/6   second review  
9.bash_history在哪个文件夹下 2025/3/6 second review  
10.type命令       2025/3/6   first review  
11._sh类型        2025/3/6   first review  
12.grep命令的使用  2025/3/7   second review  
13.test命令的用法  2025/3/7   first review  
14.test里的与计算  2025/3/7   first review  
15.HDD与SDD分区机制 2025/3/8  first review  
16.HDFS_put覆盖原文件 2025/3/8 first review  
17.HDFS文件日志     2025/3/8  first review  
18.HDFS没有cd命令   2025/3/8   first review  
19.PATH变量设置     2025/3/14  first review  
20.PATH环境变量的化简 2025/3/14  first review  
21.PATH变量的格式    2025/3/14   first review

## deep learning类  
1.set    2025/3/7   first review  
2.def关键字 2025/3/7 first review  
3.del关键字的用法 2025/3/7 first review  

## MySQL_learning类
1.码键的厘清  2025/3/17 first review  
2.DELIMITER改变默认分隔符 2025/3/18 first review  
3.COUNT()关于子查询   2025/3/19  first review  



## process进程类  
1.IPC_CREATE的标识符返回机制   2025/11/20 first review  
2.IPC_PRIVATE的作用           2025/11/20 first review  
3.IPC_key是什么有什么用        2025/11/20 first review
  

## markdown用法类  
1.Markdown的换行方法 2025/10/3 first review  
2.代码块高亮语法      2025/10/3 first review  

## Concurrent线程类  
1.1_管程问题与生产者消费者  2026/2/3 first review    

## C++学习类  
1.类内初始化和构造函数初始化  2026/2/18 first review   

## github usage类  
1.gitignore的使用方法     2026/2/28 first review  
2.gitignore              2026/2/28 first review    
3.怎样关联远程仓库         2026/3/8  first review







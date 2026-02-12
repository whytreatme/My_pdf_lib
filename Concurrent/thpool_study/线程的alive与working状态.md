# 问  
```c
volatile int num_threads_alive;      /* threads currently alive   */
volatile int num_threads_working;    /* threads currently working */
```  
一个线程是alive还是working有什么区别？  

# 答  
- num_threads_alive：线程已创建且尚未退出的数量（线程处于“存活”状态），在 thread_do 启动时 +1，退出时 -1。thpool_destroy 根据它判断何时所有线程已终止。
- num_threads_working：当前正在执行任务的线程数（忙碌状态），在从队列取到任务并开始执行前 +1，执行完毕后 -1。
- 区别：alive 表示“存在/运行中（可能空闲）”，working 表示“正在处理任务（忙）”。一个线程可以 alive 但非 working（空闲、等待信号、被 pause）。
- 代码中的用途：thpool_wait 通过检查 jobqueue.len 或 num_threads_working 来等待所有任务完成；thpool_destroy 通过检查 num_threads_alive 来等待线程退出。
- 注意：对这两个变量的读写受 thcount_lock 保护（在代码中使用 mutex 锁/解锁）。
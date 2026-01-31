## 目的  
本文档用于学习线程池的相关知识

## 线程状态流转图  
graph LR
    A[Initialized] -->|thpool_add_work| B(In Queue)
    B -->|Thread Pick up| C{Working?}
    C -->|Yes| D[Executing Task]
    C -->|No| E[Idle]
    D -->|Finish| E
    E -->|New Task| D
    D -->|thpool_pause| F[Paused]
    E -->|thpool_pause| F
    F -->|thpool_resume| C
    D -->|thpool_destroy| G[Dead/Cleaned]

## 外部参考资料  
[bilibili上找到的线程池技术博客](https://smartyue076.github.io/%E7%BA%BF%E7%A8%8B%E6%B1%A0%E5%8E%9F%E7%90%86%E4%B8%8E%E5%AE%9E%E7%8E%B0/)
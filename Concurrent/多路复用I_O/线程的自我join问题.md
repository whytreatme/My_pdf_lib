## 问  
stopAndJoin() 只能在“非线程池工作线程”里调用，避免线程自我 join。什么叫自我join   

## 答
“自我 join”就是**一个线程去 `join()` 自己**。这会导致死锁：线程正在执行 `join()`，而 `join()` 要等待这个线程结束，但它永远不会结束（因为它卡在 `join()` 里）。标准库也可能直接抛出 `std::system_error`。

举个直观例子：
- 线程池里的某个工作线程调用了 `threadpool_.stopAndJoin()`  
- `stopAndJoin()` 内部遍历 `threads` 并对每个 `std::thread` 调用 `join()`  
- 当遍历到“当前这个工作线程”时，就发生自我 `join()` → 死锁或异常

所以 `stopAndJoin()` 必须在**非线程池工作线程**里调用（比如主线程、信号线程），不能在该线程池的工作线程里调用。
#  问  
C++线程库里的条件变量要wait,还要看predicate谓词的条件满不满足，怎么POSIX的条件变量不需要？  

# 答  
简短回答：

- POSIX 条件变量是低级原语：`pthread_cond_wait()` 只是“在原子地释放互斥锁并阻塞，醒来时重新获得互斥锁”，它不会检查任何谓词或状态。  
- 因此必须由用户在互斥锁保护下用循环检查谓词（并在谓词为假时调用 `pthread_cond_wait`），以应对“虚假唤醒”和避免丢失唤醒（lost wakeup）。这正是你在代码中看到的模式：

```c
// C (POSIX)
pthread_mutex_lock(&m);
while (!ready) {
    pthread_cond_wait(&cv, &m);
}
pthread_mutex_unlock(&m);
```

- C++ 的 `std::condition_variable::wait(lock, predicate)` 是对上面模式的封装：它在内部帮你做了 `while (!predicate) wait(lock)`，所以你不用手动写循环：

```cpp
// C++ convenience
std::unique_lock<std::mutex> lk(m);
cv.wait(lk, []{ return ready; }); // 内部做了循环检查
```

- 在你的线程池代码中，`bsem_wait` 用 `while (bsem_p->v != 1) pthread_cond_wait(...)` 正确实现了谓词检查；`bsem_post`/`bsem_post_all` 在持锁时设置状态并 `signal`/`broadcast`，保证正确唤醒。
# 问  
为什么thread_init传了个 **thread_p作为参数，全文哪里使用thread_init(),这个pthread_creat函数要什么参数我看不懂，这个(void * (*)(void *)) thread_do到底是什么？(*thread_p)是什么？  

# 答  
- thread_init 的签名：
```c
 thread_init(thpool_* thpool_p, struct thread** thread_p, int id)。
```
在 thpool_init 的循环里被调用：
```c
thread_init(thpool_p, &thpool_p->threads[n], n);
```
，所以你把线程数组某个元素的地址（`&thpool_p->threads[n]`）传进去。

- 之所以用 `struct thread**`（二级指针），是因为函数内部要分配并写回一个 `struct thread*` 到调用者的数组槽：
  - `*thread_p = malloc(sizeof(struct thread));` 把分配得到的指针保存到数组里（调用处的 `thpool_p->threads[n]`）。

- pthread_create 的原型（简化）是：
```c
int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg);`
```
- 这里实际调用是：
    - 第一个参数：`&(*thread_p)->pthread`（写入新线程的 pthread_t）
    - 第二个参数：`NULL`（默认属性）
    - 第三个参数：`(void *(*)(void *)) thread_do`（线程入口函数）
    - 第四个参数：`(*thread_p)`（作为入口函数的参数）

- `(void * (*)(void *)) thread_do` 是对 `thread_do` 的强制类型转换。`pthread_create` 要求入口是 `void *(*)(void *)`，而 `thread_do` 的定义是 `static void *thread_do(struct thread *thread_p)`（参数类型为 `struct thread *`）。为了消除类型不匹配的警告/错误，代码把它强转为 pthread 期望的函数指针类型；实际运行时会把 `(*thread_p)`（即 `struct thread*`）当作 `void*` 传入 `thread_do`。

- `(*thread_p)` 就是解引用后的 `struct thread*`，也就是分配并初始化好的线程对象指针，被当作线程函数的参数传递进去。

- 另外 `pthread_detach` 表示线程分离，线程结束后内核会自动回收其资源，无需 `pthread_join`。
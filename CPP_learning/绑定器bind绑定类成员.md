# 问  
所以对于绑定器来说，要绑定类对象的非静态成员函数，就是要有成员函数指针，加调用对象作为参数对吗？  

# 答  
是的。对于非静态成员函数，std::bind 需要成员函数指针和调用对象（可以是对象指针、对象引用或智能指针），然后按顺序提供实际参数或占位符。示例：

````cpp
// 示例：绑定成员函数并传给线程池
struct Foo { void run(int x) { /*...*/ } };
Foo* f = /* ... */;
auto task1 = std::bind(&Foo::run, f, 42);                       // 绑定具体参数
auto task2 = std::bind(&Foo::run, f, std::placeholders::_1);    // 留一个占位符用于调用时传参
threadpool->addtask(task1);
````
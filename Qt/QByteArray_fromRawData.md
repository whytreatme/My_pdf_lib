## 这个函数的特殊之处  
```cpp
// 实际代码：使用静态工厂方法
QByteArray tokenBytes = QByteArray::fromRawData(buffer.constData() + offset, 128);  
```  
这里发生的是：

fromRawData 被调用。
它不分配新内存，也不复制任何数据。
它直接创建一个 QByteArray 对象，让这个对象的内部指针指向 buffer 的原始内存区域 (buffer.constData() + offset)。
tokenBytes 对象现在共享 buffer 的内存，它自己不拥有数据。  

这就是关键区别：

构造函数 QByteArray(const char*, int) -> 创建副本 (深拷贝) -> 安全但有性能开销。
静态方法 fromRawData(const char*, int) -> 创建视图 (浅拷贝) -> 高效但有风险（依赖原始数据存活）。
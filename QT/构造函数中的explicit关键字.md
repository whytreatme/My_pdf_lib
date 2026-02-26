# 问  
```cpp
explicit LoginWidget(TcpClient* client, QWidget* parent = nullptr);
```  
我看到Qt框架下的代码继承自QWidget的类都有个explicit修饰构造函数，起什么作用？  

# 答  
`explicit` 关键字在 C++（以及 Qt）中的主要作用是**防止构造函数的隐式类型转换**。

### 1. 为什么要用它？
在 C++ 中，如果一个构造函数可以只用**一个参数**调用，编译器就会默认开启“隐式转换”。这意味着它会尝试自动将该参数类型的变量转换为该类的对象。

在你的代码中：
````cpp
explicit LoginWidget(TcpClient* client, QWidget* parent = nullptr);
````
这个构造函数可以通过只传入一个 `TcpClient*` 来调用。

### 2. 如果不加 `explicit` 会发生什么？
假设你有一个函数需要 `LoginWidget` 对象：
````cpp
void showWidget(LoginWidget widget);
````
如果你没有加 `explicit`，你可以这样调用：
````cpp
TcpClient* myClient = new TcpClient();
showWidget(myClient); // 编译器会自动调用构造函数，把 TcpClient* 偷偷变成一个 LoginWidget 对象
````
这种行为通常是**危险且违背直觉的**，容易导致难以排查的 Bug。

### 3. 加了 `explicit` 之后
*   上面的隐式转换代码将无法通过编译。
*   你必须显式地创建对象：`showWidget(LoginWidget(myClient))`。

### 4. 在 Qt 中的惯例
Qt 框架遵循 C++ 最佳实践。由于 `QWidget` 及其子类的构造函数通常都有一个默认值为 `nullptr` 的 `parent` 参数，它们本质上都可以作为单参数构造函数使用。因此：
*   **防止误操作**：防止程序员不小心将一个指针（如 `parent` 指针或自定义指针）隐式转换成一个窗口部件。
*   **代码规范**：几乎所有 Qt Creator 自动生成的类都会带上 `explicit`，这已成为 Qt 开发的标准规范。

**总结：** `explicit` 保证了代码的安全性，确保构造函数只在被明确调用时才执行，而不是被编译器“自作聪明”地用于类型转换。
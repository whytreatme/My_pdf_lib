
`lambda` 表达式是 C++11 引入的一种匿名函数（即没有名字的函数）。它可以用来定义临时的、轻量级的函数对象，通常用于简化代码或作为参数传递给其他函数。

---

### 1. **`lambda` 表达式的基本语法**
```cpp
[捕获列表](参数列表) -> 返回类型 { 函数体 }
```

- **捕获列表**：用于捕获外部变量，决定 `lambda` 表达式可以访问哪些外部变量。
- **参数列表**：与普通函数的参数列表类似，定义 `lambda` 表达式的输入参数。
- **返回类型**：可选，用于指定 `lambda` 表达式的返回类型。如果省略，编译器会自动推断返回类型。
- **函数体**：`lambda` 表达式的实现代码。

---

### 2. **`lambda` 表达式的示例**
#### （1）**最简单的 `lambda` 表达式**
```cpp
auto func = []() { std::cout << "Hello, World!" << std::endl; };
func(); // 输出：Hello, World!
```

- 这个 `lambda` 表达式没有捕获任何外部变量，也没有参数和返回类型。

#### （2）**带参数的 `lambda` 表达式**
```cpp
auto add = [](int a, int b) { return a + b; };
std::cout << add(3, 4) << std::endl; // 输出：7
```

- 这个 `lambda` 表达式接受两个 `int` 类型的参数，并返回它们的和。

#### （3）**带捕获列表的 `lambda` 表达式**
```cpp
int x = 10;
auto print_x = [x]() { std::cout << "x = " << x << std::endl; };
print_x(); // 输出：x = 10
```

- 这个 `lambda` 表达式捕获了外部变量 `x`，并在函数体中使用了它。

---

### 3. **捕获列表的用法**
捕获列表用于指定 `lambda` 表达式可以访问哪些外部变量。常见的捕获方式有：

#### （1）**值捕获**
- 捕获外部变量的值，`lambda` 表达式内部使用的是捕获时的值。
- 语法：`[变量名]`

#### 示例：
```cpp
int x = 10;
auto func = [x]() { std::cout << "x = " << x << std::endl; };
x = 20;
func(); // 输出：x = 10
```

#### （2）**引用捕获**
- 捕获外部变量的引用，`lambda` 表达式内部使用的是变量的引用。
- 语法：`[&变量名]`

#### 示例：
```cpp
int x = 10;
auto func = [&x]() { std::cout << "x = " << x << std::endl; };
x = 20;
func(); // 输出：x = 20
```

#### （3）**隐式捕获**
- 使用 `[=]` 捕获所有外部变量的值。
- 使用 `[&]` 捕获所有外部变量的引用。

#### 示例：
```cpp
int x = 10, y = 20;
auto func1 = [=]() { std::cout << "x = " << x << ", y = " << y << std::endl; };
auto func2 = [&]() { x++; y++; };
func1(); // 输出：x = 10, y = 20
func2();
func1(); // 输出：x = 11, y = 21
```

---

### 4. **`lambda` 表达式的返回类型**
如果 `lambda` 表达式的函数体只有一条 `return` 语句，编译器可以自动推断返回类型。否则，需要显式指定返回类型。

#### 示例：
```cpp
auto add = [](int a, int b) -> int { return a + b; };
auto square = [](int x) { return x * x; }; // 返回类型自动推断为 int
```

---

### 5. **`lambda` 表达式的应用场景**
#### （1）**作为函数参数**
`lambda` 表达式常用于作为参数传递给标准库算法（如 `std::sort`、`std::for_each` 等）。

#### 示例：
```cpp
#include <algorithm>
#include <vector>
#include <iostream>

int main() {
    std::vector<int> nums = {3, 1, 4, 1, 5, 9};

    // 使用 lambda 表达式作为比较函数
    std::sort(nums.begin(), nums.end(), [](int a, int b) { return a > b; });

    for (int x : nums) {
        std::cout << x << " ";
    }
    return 0;
}
```

#### 输出：
```
9 5 4 3 1 1 
```

#### （2）**简化代码**
`lambda` 表达式可以用于简化代码，避免定义额外的函数。

#### 示例：
```cpp
#include <iostream>

int main() {
    int x = 10;
    auto print_x = [x]() { std::cout << "x = " << x << std::endl; };
    print_x(); // 输出：x = 10
    return 0;
}
```

---

### 6. **总结**
- `lambda` 表达式是一种匿名函数，用于定义临时的、轻量级的函数对象。
- 它的语法是 `[捕获列表](参数列表) -> 返回类型 { 函数体 }`。
- 捕获列表用于捕获外部变量，参数列表和返回类型与普通函数类似。
- `lambda` 表达式常用于作为函数参数或简化代码。

希望这个解释能帮助你理解 `lambda` 表达式！如果还有其他问题，欢迎随时提问！ 😊

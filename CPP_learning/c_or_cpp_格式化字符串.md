
在 C 语言中，字符串的格式化主要通过 `printf` 函数（用于输出）和 `sprintf` 函数（用于将格式化结果存储到字符串中）来实现。格式化字符串使用**格式说明符（format specifiers）**来定义如何显示或存储数据。

---

### 1. **`printf` 函数**
`printf` 是 C 语言中最常用的格式化输出函数。它的基本语法如下：

```c
int printf(const char *format, ...);
```

- `format` 是一个字符串，包含普通字符和格式说明符。
- `...` 是可变参数，表示需要格式化的数据。

#### 常用格式说明符：
| 格式说明符 | 说明                                   |
|------------|----------------------------------------|
| `%d`       | 格式化有符号十进制整数                 |
| `%u`       | 格式化无符号十进制整数                 |
| `%f`       | 格式化浮点数（默认保留 6 位小数）      |
| `%c`       | 格式化单个字符                         |
| `%s`       | 格式化字符串                           |
| `%x`       | 格式化十六进制整数（小写字母）         |
| `%X`       | 格式化十六进制整数（大写字母）         |
| `%o`       | 格式化八进制整数                       |
| `%p`       | 格式化指针地址                         |
| `%%`       | 输出百分号 `%`                         |

#### 示例：
```c
#include <stdio.h>

int main() {
    int num = 42;
    float pi = 3.14159;
    char ch = 'A';
    char str[] = "Hello, World!";

    printf("Integer: %d\n", num);       // 输出：Integer: 42
    printf("Float: %.2f\n", pi);       // 输出：Float: 3.14（保留 2 位小数）
    printf("Character: %c\n", ch);     // 输出：Character: A
    printf("String: %s\n", str);       // 输出：String: Hello, World!
    printf("Hexadecimal: %x\n", num);  // 输出：Hexadecimal: 2a
    printf("Pointer: %p\n", &num);     // 输出：Pointer: 0x7ffee4b5c9d4（地址值）

    return 0;
}
```

---

### 2. **`sprintf` 函数**
`sprintf` 函数用于将格式化结果存储到一个字符串中，而不是直接输出到控制台。它的语法如下：

```c
int sprintf(char *str, const char *format, ...);
```

- `str` 是目标字符串，用于存储格式化后的结果。
- `format` 是格式化字符串。
- `...` 是可变参数，表示需要格式化的数据。

#### 示例：
```c
#include <stdio.h>

int main() {
    char buffer[100];
    int num = 42;
    float pi = 3.14159;

    sprintf(buffer, "Integer: %d, Float: %.2f", num, pi);
    printf("%s\n", buffer);  // 输出：Integer: 42, Float: 3.14

    return 0;
}
```

---

### 3. **格式化修饰符**
在格式说明符中，可以使用修饰符来控制输出的格式。常见的修饰符包括：

| 修饰符       | 说明                                   |
|--------------|----------------------------------------|
| `%Nd`        | 最小字段宽度为 `N`，不足时用空格填充   |
| `%0Nd`       | 最小字段宽度为 `N`，不足时用 `0` 填充  |
| `%.Mf`       | 浮点数保留 `M` 位小数                  |
| `%-Nd`       | 左对齐（默认右对齐）                   |
| `%+d`        | 显示正负号                             |
| `%#x`        | 显示十六进制前缀 `0x`                  |

#### 示例：
```c
#include <stdio.h>

int main() {
    int num = 42;
    float pi = 3.14159;

    printf("Padded: %5d\n", num);       // 输出：Padded:    42
    printf("Zero-padded: %05d\n", num); // 输出：Zero-padded: 00042
    printf("Precision: %.3f\n", pi);    // 输出：Precision: 3.142
    printf("Left-aligned: %-5d\n", num); // 输出：Left-aligned: 42   
    printf("Sign: %+d\n", num);         // 输出：Sign: +42
    printf("Hex with prefix: %#x\n", num); // 输出：Hex with prefix: 0x2a

    return 0;
}
```

---

### 4. **注意事项**
- 格式化字符串中的格式说明符必须与传入的参数类型匹配，否则会导致未定义行为。
- 在使用 `sprintf` 时，确保目标字符串有足够的空间存储格式化结果，否则可能导致缓冲区溢出。

---

### 总结
C 语言中的字符串格式化主要通过 `printf` 和 `sprintf` 函数实现，使用格式说明符（如 `%d`、`%f`、`%s` 等）来定义数据的显示或存储方式。通过修饰符（如 `%5d`、`%.2f` 等）可以进一步控制输出的格式。

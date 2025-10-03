`perror`、`strerror` 和 `errno` 是 C/C++ 中错误处理的三个相关组件，它们之间的关系如下：

## 1. `errno`-错误代码变量
-     **全局变量**，定义在 `<errno.h>`
    
-     当系统调用或库函数失败时，会设置 `errno`     为相应的错误代码
    
-     是一个整数，代表特定的错误类型

```cpp
#include <errno.h>
#include <iostream>

int main() {
    FILE* fp = fopen("nonexistent.txt", "r");
    if (fp == NULL) {
        std::cout << "errno: " << errno << std::endl;  // 输出错误代码
    }
    return 0;
}
```

## 2. `strerror`-错误代码转字符串
-     **函数**，定义在 `<string.h>`
    
-     将 `errno`     值转换为可读的错误描述字符串

```cpp
#include <errno.h>
#include <string.h>
#include <iostream>

int main() {
    FILE* fp = fopen("nonexistent.txt", "r");
    if (fp == NULL) {
        std::cout << "Error: " << strerror(errno) << std::endl;
        // 输出: Error: No such file or directory
    }
    return 0;
}
```

## 3. `perror`-打印错误信息
-     **函数**，定义在 `<stdio.h>`
    
-     自动读取 `errno`     并输出格式化的错误信息
    
-     可以添加自定义的前缀

```cpp
#include <errno.h>
#include <stdio.h>

int main() {
    FILE* fp = fopen("nonexistent.txt", "r");
    if (fp == NULL) {
        perror("Failed to open file");
        // 输出: Failed to open file: No such file or directory
    }
    return 0;
}
```

## 三者关系总结
| 组件 | 类型 | 功能 | 使用场景 |
| --- | --- | --- | --- |
| errno | 全局变量 | 存储错误代码 | 需要获取具体错误代码时 |
| strerror | 函数 | 错误代码→描述字符串 | 需要自定义错误消息格式时 |
| perror | 函数 | 自动格式化输出错误 | 快速简单的错误报告 |

## 工作流程

```text
系统调用失败 → 设置 errno → perror 或 strerror 读取 → 输出错误信息
```

## 完整示例

```cpp
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <iostream>

int main() {
    FILE* fp = fopen("nonexistent.txt", "r");
    if (fp == NULL) {
        // 三种方式输出错误信息
        std::cout << "1. errno value: " << errno << std::endl;
        std::cout << "2. strerror: " << strerror(errno) << std::endl;
        perror("3. perror");
        
        // 常见错误代码
        if (errno == ENOENT) {
            std::cout << "File does not exist" << std::endl;
        }
    }
    return 0;
}
```

## 输出结果

```text
1. errno value: 2
2. strerror: No such file or directory  
3. perror: No such file or directory
File does not exist
```

**简单记忆**：
-     `errno`     是错误代码的数字
    
-     `strerror`     把代码变成文字
    
-     `perror`     自动完成整个过程并输出
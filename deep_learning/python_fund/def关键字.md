在 Python 中，`def` 关键字用于定义函数。函数是一段可重复使用的代码块，能够执行特定任务并返回结果。使用 `def` 定义函数的基本语法如下：

```python
def function_name(parameters):
    # 函数体
    # 可以包含多行代码
    return value  # 可选
```

### 关键点：
1. **定义函数**：`def` 用于声明函数，后跟函数名和参数列表。
2. **函数名**：函数名应遵循变量命名规则，通常使用小写字母和下划线。
3. **参数**：参数是可选的，用于传递数据给函数。
4. **函数体**：函数体包含执行的代码，必须缩进。
5. **返回值**：使用 `return` 语句返回结果，若无 `return`，函数默认返回 `None`。

### 示例：
```python
def greet(name):
    return f"Hello, {name}!"

message = greet("Alice")
print(message)  # 输出: Hello, Alice!
```

### 总结：
`def` 关键字用于定义函数，使代码模块化、可重用，并提高可读性和维护性。

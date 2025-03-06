
`inputWords = input.split(" ")` 这条语句的作用是将字符串 `input` 按空格分割成一个单词列表。让我们详细解释一下它的作用和原理：

### 1. **`split` 方法**
- `split` 是 Python 字符串的一个内置方法，用于将字符串按指定的分隔符分割成多个部分，并返回一个列表。
- 语法：`str.split(sep=None, maxsplit=-1)`
  - `sep`：分隔符，默认为所有的空字符（包括空格、换行、制表符等）。
  - `maxsplit`：最大分割次数，默认为 `-1`，表示不限制分割次数。

### 2. **`input.split(" ")` 的作用**
- `input.split(" ")` 表示将字符串 `input` 按空格 `" "` 进行分割。
- 分割后的结果是一个列表，列表中的每个元素是原字符串中被空格分隔的部分。

### 3. **示例**
假设 `input = 'I like runoob'`，那么 `input.split(" ")` 的结果是：
```python
inputWords = ['I', 'like', 'runoob']
```

### 4. **详细步骤**
1. **原始字符串**：
   ```python
   input = 'I like runoob'
   ```
2. **调用 `split` 方法**：
   ```python
   inputWords = input.split(" ")
   ```
3. **分割结果**：
   - 字符串 `'I like runoob'` 被按空格分割成三部分：`'I'`、`'like'` 和 `'runoob'`。
   - 分割后的结果是列表 `['I', 'like', 'runoob']`。

### 5. **特殊情况**
- **连续空格**：如果字符串中有连续的空格，`split(" ")` 会将连续的空格视为多个分隔符，产生空字符串元素。
  ```python
  input = 'I  like  runoob'  # 注意有两个空格
  inputWords = input.split(" ")
  # 结果是 ['I', '', 'like', '', 'runoob']
  ```
- **去除空字符串**：可以使用 `split()`（不带参数）来自动去除所有空字符（包括连续空格、换行、制表符等）。
  ```python
  input = 'I  like  runoob'
  inputWords = input.split()
  # 结果是 ['I', 'like', 'runoob']
  ```

### 6. **在 `reverseWords` 函数中的作用**
在 `reverseWords` 函数中，`inputWords = input.split(" ")` 的作用是将输入的字符串按空格分割成单词列表，以便后续反转单词顺序。

```python
def reverseWords(input):
    inputWords = input.split(" ")  # 将字符串按空格分割成单词列表
    inputWords = inputWords[-1::-1]  # 反转列表
    output = ' '.join(inputWords)  # 将列表重新组合成字符串
    return output
```

### 7. **总结**
- `inputWords = input.split(" ")` 的作用是将字符串 `input` 按空格分割成一个单词列表。
- 这个列表可以用于后续的操作，例如反转单词顺序、重新组合字符串等。
- `split` 方法是处理字符串分割的常用工具，非常灵活且强大。

如果你有其他问题，欢迎继续提问！

# 问  
请你用C++风格的代码为我详细解释，怎么用迭代器遍历各种容器，以及有多少种遍历的方式   

# 答   
可以。我用 C++ 的写法给你系统讲一下“怎么遍历容器”，以及常见有哪几种方式。你现在最需要理解的是：**不同容器，适合不同遍历方式**。

---

## 1. 最基础的下标遍历，适合 `vector` / `array` / 普通数组
这种写法最像你熟悉的 C 风格 `for(int i = 0; i < n; i++)`。

### 例子
```cpp
std::vector<int> nums = {1, 2, 3, 4};

for (size_t i = 0; i < nums.size(); ++i) {
    std::cout << nums[i] << std::endl;
}
```

### 特点
- 适合有随机访问能力的容器
- 可以通过下标直接访问
- 常用在 `vector`、`string`、`array`

### 不适合
- `map`
- `unordered_map`
- `list`
- `set`

因为这些容器没有“下标”这个概念。

---

## 2. 迭代器遍历，适合几乎所有标准容器
这是 C++ 最通用的遍历方式。

### 基本形式
```cpp
for (auto it = container.begin(); it != container.end(); ++it) {
    // 使用 *it
}
```

### 例子：遍历 `vector`
```cpp
std::vector<int> nums = {1, 2, 3, 4};

for (auto it = nums.begin(); it != nums.end(); ++it) {
    std::cout << *it << std::endl;
}
```

### 例子：遍历 `map`
```cpp
std::map<int, std::string> mp = {
    {1, "one"},
    {2, "two"}
};

for (auto it = mp.begin(); it != mp.end(); ++it) {
    std::cout << it->first << " = " << it->second << std::endl;
}
```

### 你要重点理解的点
对于迭代器：
- `it` 指向当前元素
- `*it` 得到当前元素本身
- `it->first`、`it->second` 用于键值对容器

比如 `std::unordered_map<int, spConnection>` 里的每个元素类型是：
```cpp
std::pair<const int, spConnection>
```

所以：
- `it->first` 是 fd
- `it->second` 是连接对象

---

## 3. 范围 for，最简洁，推荐优先使用
这是现代 C++ 最常用的遍历方式。

### 例子：遍历 `vector`
```cpp
std::vector<int> nums = {1, 2, 3, 4};

for (const auto& n : nums) {
    std::cout << n << std::endl;
}
```

### 例子：遍历 `map`
```cpp
for (const auto& [fd, conn] : connMap) {
    std::cout << fd << std::endl;
}
```

### 特点
- 简洁
- 可读性强
- 很适合只读遍历
- C++11 起支持
- C++17 起可以结构化绑定 `[fd, conn]`

### 注意
如果你要修改容器里的元素，建议用：
```cpp
for (auto& item : container)
```
如果只是读，不改：
```cpp
for (const auto& item : container)
```

---

## 4. 反向遍历，适合支持双向迭代器的容器
### 例子：`vector` 反向遍历
```cpp
for (auto it = nums.rbegin(); it != nums.rend(); ++it) {
    std::cout << *it << std::endl;
}
```

### 特点
- 从后往前走
- 常用于需要逆序处理的场景

### 不适合所有容器
例如 `unordered_map` 没有稳定的“顺序”，反向遍历意义不大。

---

## 5. `while` + 迭代器，逻辑和 `for` 一样
你也可以写成：

```cpp
auto it = nums.begin();
while (it != nums.end()) {
    std::cout << *it << std::endl;
    ++it;
}
```

本质上和 `for` 是一样的，只是语法不同。

---

## 6. 你这个项目里最关心的：`map` / `unordered_map` 怎么遍历
你现在的 `loopConns_` 是：

```cpp
std::unordered_map<EventLoop*, std::unordered_map<int, spConnection>> loopConns_;
```

所以你可以分两层遍历。

### 第一层：遍历每个 EventLoop
```cpp
for (auto it = loopConns_.begin(); it != loopConns_.end(); ++it) {
    EventLoop* loop = it->first;
    auto& connMap = it->second;
}
```

### 第二层：遍历这个 loop 的连接表
```cpp
for (auto it = connMap.begin(); it != connMap.end(); ++it) {
    int fd = it->first;
    spConnection conn = it->second;
}
```

### 合在一起写
```cpp
for (auto loopIt = loopConns_.begin(); loopIt != loopConns_.end(); ++loopIt) {
    EventLoop* loop = loopIt->first;
    auto& connMap = loopIt->second;

    for (auto connIt = connMap.begin(); connIt != connMap.end(); ++connIt) {
        int fd = connIt->first;
        spConnection conn = connIt->second;
        std::cout << fd << std::endl;
    }
}
```

---

## 7. 如果要删除元素，遍历方式要特别注意
这是你现在最可能用到的。

### 不能这样删
```cpp
for (auto it = connMap.begin(); it != connMap.end(); ++it) {
    if (needRemove(it->second)) {
        connMap.erase(it); // 这样可能导致迭代器失效
    }
}
```

### 正确写法 1：先保存下一个迭代器
```cpp
for (auto it = connMap.begin(); it != connMap.end(); ) {
    if (needRemove(it->second)) {
        it = connMap.erase(it);
    } else {
        ++it;
    }
}
```

### 正确写法 2：先收集，再统一删除
```cpp
std::vector<int> expiredFds;

for (const auto& [fd, conn] : connMap) {
    if (conn->isIdle()) {
        expiredFds.push_back(fd);
    }
}

for (int fd : expiredFds) {
    connMap.erase(fd);
}
```

这个方法最安全，也最适合你的超时清理。

---

## 8. 总结：常见遍历方式有几种
你可以记成下面 5 种：

1. **下标遍历**
   - `for (size_t i = 0; i < v.size(); ++i)`
   - 适合 `vector`、`string`

2. **迭代器遍历**
   - `for (auto it = c.begin(); it != c.end(); ++it)`
   - 适合所有标准容器

3. **范围 for**
   - `for (const auto& x : c)`
   - 最简洁，最常用

4. **反向迭代器遍历**
   - `rbegin()` / `rend()`
   - 用于反向处理

5. **while + 迭代器**
   - 逻辑和 for 一样，只是写法不同

---

## 9. 对你当前项目最实用的建议
你现在遍历 `loopConns_[loop]`，最推荐先用这个：

```cpp
for (const auto& [fd, conn] : connMap) {
    if (conn->isIdle()) {
        // 收集起来
    }
}
```

如果你还没熟悉结构化绑定，就先写成：

```cpp
for (auto it = connMap.begin(); it != connMap.end(); ++it) {
    int fd = it->first;
    spConnection conn = it->second;
}
```

这个版本最适合你现在理解“键值对容器怎么走”。

如果你愿意，我下一条可以直接结合你这个 `loopConns_`，给你写一个“遍历 + 判断空闲 + 收集 fd + 删除”的完整 C++ 示例。
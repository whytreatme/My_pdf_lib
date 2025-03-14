
如果你只想比较两份代码中**命名相同的一份 `.cpp` 文件**，可以使用 `git diff` 直接指定文件路径进行比较。以下是具体步骤：

---

### 步骤 1：确保文件路径正确
假设：
- 远程仓库的本地副本路径为 `remote-repo`。
- 老师发的代码路径为 `teacher-code`。
- 你要比较的文件名为 `example.cpp`。

你需要知道 `example.cpp` 在远程仓库和老师代码中的具体路径。例如：
- 远程仓库中的路径：`remote-repo/src/example.cpp`
- 老师代码中的路径：`teacher-code/src/example.cpp`

---

### 步骤 2：使用 `git diff` 比较文件
在终端中运行以下命令：
```bash
git diff --no-index teacher-code/src/example.cpp remote-repo/src/example.cpp
```

- `--no-index`：允许比较非 Git 仓库中的文件。
- `teacher-code/src/example.cpp`：老师代码中的文件路径。
- `remote-repo/src/example.cpp`：远程仓库中的文件路径。

---

### 示例
假设：
- 远程仓库路径为 `~/projects/remote-repo`。
- 老师代码路径为 `~/projects/teacher-code`。
- 文件路径均为 `src/example.cpp`。

运行以下命令：
```bash
git diff --no-index ~/projects/teacher-code/src/example.cpp ~/projects/remote-repo/src/example.cpp
```

---

### 步骤 3：查看差异
`git diff` 会输出文件的差异，格式如下：
- `-` 开头的行表示老师代码中有但远程仓库中没有的内容。
- `+` 开头的行表示远程仓库中有但老师代码中没有的内容。

---

### 其他工具
如果 `git diff` 的输出不够直观，可以使用图形化工具来比较文件，例如：
1. **VS Code**：
   - 打开 VS Code。
   - 右键点击老师代码中的 `example.cpp`，选择“选择以进行比较”。
   - 右键点击远程仓库中的 `example.cpp`，选择“与已选择项进行比较”。

2. **Meld**：
   - 安装 Meld（`sudo apt install meld`）。
   - 运行以下命令：
     ```bash
     meld teacher-code/src/example.cpp remote-repo/src/example.cpp
     ```

3. **Beyond Compare**：
   - 打开 Beyond Compare。
   - 选择“文件比较”，然后分别加载两个文件。

---

### 总结
通过 `git diff` 直接指定文件路径，可以快速比较两份代码中命名相同的 `.cpp` 文件。如果需要更直观的对比，可以使用图形化工具。


![git diff的实例](https://i.imgur.com/7HTzj44.png)

这张图片显示了 `git diff` 命令的输出，它用于查看两个提交之间的差异，或者当前工作区与暂存区的差异。以下是对各行的解释：

### **1. 头部信息**

```
diff --git a/priority_queue/src/implement.cpp b/priority_queue/src/implement.cpp
index 606fe24..527ee8d 100644

```

-   `diff --git a/... b/...`：表示比较的是 `priority_queue/src/implement.cpp` 这个文件的不同版本。
-   `index 606fe24..527ee8d 100644`：`index` 行表示前后两个版本的哈希值，`100644` 代表文件权限（普通文件）。

----------

### **2. 文件修改**

```
--- a/priority_queue/src/implement.cpp
+++ b/priority_queue/src/implement.cpp

```

-   `--- a/...`：`a/` 代表旧版本。
-   `+++ b/...`：`b/` 代表新版本。

----------

### **3. 上下文行（未改动的代码）**

```
@@ -1,10 +1,18 @@

```

-   这行是 **hunk header**，表示修改发生的代码范围：
    -   `-1,10`：旧文件的第 1 行开始，包含 10 行。
    -   `+1,18`：新文件的第 1 行开始，包含 18 行。
    -   这个修改使得文件变得更长了（从 10 行变成 18 行）。

----------

### **4. 具体修改**

#### **添加的代码（以 `+` 开头，绿色）**

```
+#include <time.h>

```

-   这行代码是新增的，表示 `time.h` 头文件被加入。

```
+void down_maintain(int p[], int index, int n) { 
+    // 弹出元素之后的向下调整

```

-   这部分是新增的 **`down_maintain`** 函数，实现了堆的向下调整。

----------

#### **删除的代码（以 `-` 开头，红色）**

```
-#define cmp >

```

-   这一行被删除，意味着 `cmp` 的定义可能有所变化，或者被替换为了更复杂的逻辑。

----------

#### **修改的代码**

```
-    if(p[l] cmp p[i]) i = l;
-    if(r <= n && p[r] cmp p[i]) i = r;
+    if(p[l] cmp p[i]) i = l;
+    if(r <= n && p[r] cmp p[i]) i = r;

```

-   这里的 `if` 语句似乎没有明显变化，但 `git diff` 依然标记了它，可能是因为缩进或空格的变动。

----------

### **5. 总结**

-   这次 `git diff` 显示：
    -   **新增** 了 `#include <time.h>`。
    -   **定义了新函数** `down_maintain`。
    -   **删除了 `#define cmp >`**。
    -   **可能修改了 `cmp` 的逻辑**。
    -   **局部调整了代码结构**。

你可以用 `git diff --word-diff` 或 `git diff -U3` 来更精确地查看变更细节！ 🚀

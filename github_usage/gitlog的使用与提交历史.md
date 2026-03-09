## 问_1  
git log 是在本地仓库上输命令行的命令吗，怎么回退之前的递交，怎么查看之前的提交，我先想选方案一  

## 答_1  
是的，`git log` 是在你的本地仓库用命令行输入的命令，用来**查看历史的所有提交（commit）**。

---

### 1. 如何在本地用 `git log` 查看历史提交

在你的项目目录下打开终端/命令行，输入：

```bash
git log
```

你会看到类似如下输出，每个提交都有一个哈希值（commit id��示例：

```
commit 1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0
Author: whytreatme <xxx@email.com>
Date:   2026-03-09 10:20:00 +0800

    fix: 修正存款金额显示错误

commit 0a9b8c7d6e5f4g3h2i1j0k9l8m7n6o5p4q3r2s1
Author: whytreatme <xxx@email.com>
Date:   2026-03-08 16:02:00 +0800

    feat: 支持多账户操作
...
```

---

### 2. 回退（撤销）某次提交的做法

#### 查看提交
1. 用 `git log` 找到你要回退（撤销）的那个提交，记住它的哈希（就是那串很长的数字字母）。

#### 撤销最近一次提交的方法：
- 如果你只是要撤销**最新的一次提交**（并且保留更改在工作区）：

```bash
git reset --soft HEAD~1
```
或者如果你想**彻底撤销**（丢弃修改）：

```bash
git reset --hard HEAD~1
```

#### 撤销更早提交的方法：

如果你想撤销历史上的某一条提交（不是最新的），推荐使用 `git revert`：

```bash
git revert <commit哈希>
```
这样会生成一个新的提交来“反做”那次提交，不会破坏提交历史，安全！

---

### 3. 最常用命令快速对照

- 查看历史：`git log`
- 撤销最近一次并保留代码：`git reset --soft HEAD~1`
- 撤销最近一次并彻底丢弃：`git reset --hard HEAD~1`
- 撤销指定的某一次提交（不破坏历史）：`git revert <commit哈希>`

---

### 温馨提示

- **多用 `git log`，养成随时查看历史的习惯，这样不会迷路。**
- 回退/撤销操作前，**可以先用 `git status` 确认现在的代码有没有需要保存的。**
- 如果你的代码已经push到GitHub，并且有协作开发，尽量用`git revert`，不要用`git reset --hard`，防止别人拉不到你历史。

---

## 问_2  
那在GitHub网页端上呢？怎么查看提交呢？我发选如果提交一多，要找到特定某次的提交就很困难了，除非记住日期  

## 答_2  
你的问题非常好！在**GitHub 网页端**也可以很方便地查看和定位历史提交，甚至比命令行更直观，不用记哈希或者日期。下面详细教你如何做：

---

### 1. 在 GitHub 网页端查看提交（commit history）



1. 进入以后，你会看到**按时间倒序排列的所有提交列表**，每一条都有：
   - 提交说明（message）
   - 时间
   - 作者
   - 短哈希值
   - [Browse files] 或 View 按钮，可以查看这次提交的文件快照

---

### 2. 如何快速“定位”某次提交

- 全部提交都在一个页面（或分页），
- 你可以用浏览器搜索（`Ctrl + F` 或 `Command + F`）**根据 commit message、作者、日期来查找**。
- 如果 commit message 写得清楚，比如“修正xxxbug”或“增加某功能”，比靠日期容易太多！

---

### 3. 如何查看某次提交的内容？

在那一列表页面，**点击哈希值**，就可以查看那次提交的详情、diff（代码改动）。

---

### 4. 常见操作截图指南

1. ![commits按钮](https://docs.github.com/assets/images/help/repository/repo-commit-history.png)
2. ![提交记录示例](https://docs.github.com/assets/images/help/repository/repo-commit-details.png)

---

### 5. 小贴士（高效查找、管理 Commit）

- **写好 commit message**（改了什么、为什么改），以后查找很轻松。
- 不用记住日期，记住关键内容/关键词就行。
- 没有太多 commit 时，直接翻非常快；commit 多时可以用页面搜索。
- 也可以点左上角 `<> Code` 旁的“History”查看每一个文件的独立提交历史。

---

### 总结

- GitHub 网页端非常适合查看和定位历史提交，**不需要记住哈希或日期**。
- 善用 commit message 和浏览器搜索，就算几百个提交也不怕找不到。
- 如果需要撤销或回退还是要回到本地仓库操作，但你可以**在网页端先找好是哪次提交，然后复制哈希值回到本地执行**！

---


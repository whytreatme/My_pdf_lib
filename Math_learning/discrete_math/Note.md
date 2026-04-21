## 命题逻辑   
### 命题的等价形式  
- 逆否命题：如果命题P蕴含命题Q，那么非Q蕴含非P。
- 反命题：如果命题P蕴含命题Q，那么非P蕴含非Q。
- 充分条件：如果命题P蕴含命题Q，那么P是Q的充分条件。
- 必要条件：如果命题P蕴含命题Q，那么Q是P的必要条件。
- 充要条件：如果命题P蕴含命题Q，并且命题Q蕴含命题P，那么P和Q是充要条件。
- 逻辑等价：如果命题P蕴含命题Q，并且命题Q蕴含命题P，那么P和Q是逻辑等价的。
- 逻辑蕴含：如果命题P蕴含命题Q，那么P是Q的逻辑蕴含。
- 逻辑等价：如果命题P蕴含命题Q，并且命题Q蕴含命题P，那么P和Q是逻辑等价的。
- 逻辑否定：如果命题P蕴含命题Q，那么非P蕴含非Q。

### 练习   
"You can pass the Discrete Math exam ONLY IF you solve all the exercises in Rosen's book."  
令E: You pass the Discrete Math exam.
令S: You solve all the exercises in Rosen's book.

逻辑的单向性：真值表 (Truth Table) 中，即使你做完了所有题（S为真），没通过考试（E为假），此时
F→T在逻辑上依然是 True (真)。这在数学上叫做空真 (Vacuous Truth) 的一种延伸——前提为假/结论为真，并不违背最初的承诺。

### UNLESS  
*   **UNLESS (除非):** 在日常语言中，它带有强烈的威胁意味；但在数学逻辑中，`p unless q` 的严格定义是：**“如果不满足 $q$，那么 $p$ 就一定会发生”**，即 $\neg q \rightarrow p$。
*   **Equivalent (等价):** 两个命题如果拥有完全相同的真值表，我们就称它们是逻辑等价的，记作 $\equiv$。

### 一致性检验
- **Consistency Check (一致性检验):** 在逻辑中，我们经常需要检查一组命题是否可以同时为真。这被称为一致性检验。如果存在一个真值分配使得所有命题都为真，那么这组命题就是一致的。
- **Inconsistency (不一致):** 如果没有任何真值分配能够使得所有命题同时为真，那么这组命题就是不一致的。



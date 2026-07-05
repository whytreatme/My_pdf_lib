## 问  
unordered_set是不是只有值没有键？它是怎么使用的？   

## 答  
关于 unordered_set：
•	是否只有值没有键？：是的，unordered_set（无序集合）只存储独一无二的值，存储的元素本身既是它的“值”，同时也充当用于查找的“键”。
•	怎么使用？：
•	插入：使用 .insert(value)（如你代码里的 blacklist.insert(line)）。
•	查找：使用 .find(value) != set.end() 或 .count(value) > 0 判断某个值是否在集合中。
•	删除：使用 .erase(value)。
•	底层数据结构是什么？：它的底层是由 哈希表（Hash Table） 实现的。因此它内部的数据是无序的，但插入、删除和查找的平均时间复杂度都是极快的 O(1)。

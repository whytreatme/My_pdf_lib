## 问  
什么是连接名？连接名有什么用，在当前的主线程中用了什么连接名？   

## 答  
连接名（Connection Name）是 QSqlDatabase 用于标识每个数据库连接的字符串。每个连接都必须有唯一的连接名，Qt 用它来区分和管理不同的连接实例。

**作用：**
- 连接名用于注册、查找、获取和移除数据库连接。
- 可以通过 QSqlDatabase::addDatabase(type, connectionName) 创建带连接名的连接。
- 用 QSqlDatabase::database(connectionName) 获取指定连接名的连接。
- 用 QSqlDatabase::removeDatabase(connectionName) 移除连接。

**主线程中的连接名：**
- 如果你用 QSqlDatabase::addDatabase(type)（不指定连接名），Qt 默认用 "qt_sql_default_connection" 作为主线程的连接名。
- 如果你指定了连接名，则用你指定的字符串。

**举例：**
```cpp
// 默认连接名（主线程）
QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE"); // 连接名是 "qt_sql_default_connection"

// 指定连接名
QSqlDatabase db2 = QSqlDatabase::addDatabase("QSQLITE", "my_connection");
```

**总结：**
连接名就是数据库连接的唯一标识符。主线程默认连接名是 "qt_sql_default_connection"，你也可以自定义。多线程时建议用线程 ID 作为连接名，保证每个线程连接唯一。

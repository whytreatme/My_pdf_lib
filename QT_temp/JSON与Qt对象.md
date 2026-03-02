# 问  
在Qt框架下JSON是用QJsonObject类来保存和操作的吗？  

# 答  
是的，但在 Qt 中处理 JSON 通常涉及四个核心类，它们共同协作：

### 1. 核心类角色
*   **`QJsonObject`**：代表 JSON **对象**（即键值对集合 `{ "key": "value" }`）。它类似于 `QMap<QString, QJsonValue>`。
*   **`QJsonArray`**：代表 JSON **数组**（即有序列表 `[1, 2, 3]`）。它类似于 `QList<QJsonValue>`。
*   **`QJsonValue`**：代表 JSON 中的**单个数据单元**。它可以是字符串、数字、布尔值、对象、数组或空值。
*   **`QJsonDocument`**：**核心转换器**。它负责在 `QByteArray`（原始二进制/文本数据）与 `QJsonObject` 或 `QJsonArray` 之间进行转换（解析和序列化）。

### 2. 典型工作流程

#### 解析 JSON 字符串（从网络接收）：
````cpp
// 假设 data 是从服务器接收到的 QByteArray
QJsonDocument doc = QJsonDocument::fromJson(data);
if (!doc.isNull() && doc.isObject()) {
    QJsonObject obj = doc.object();
    QString status = obj["status"].toString(); // 获取值
}
````

#### 生成 JSON 字符串（发送给服务器）：
````cpp
QJsonObject obj;
obj["username"] = "admin";
obj["password"] = "123456";

QJsonDocument doc(obj);
QByteArray bytes = doc.toJson(); // 转换为可以发送的字节流
````

### 总结
你代码中的 `QJsonObject response` 正是解析后的结果，通过它你可以像操作字典/映射表一样方便地通过键名（如 `"status"` 或 `"msg"`）来访问服务器返回的具体数据。
## 问  
tokenBytes = tokenBytes.left(128); // 截断，这是什么api? 直接返回开头的128个字节吗？那是不是还有一个right呢？  

## 答  
QByteArray::left(128) 是 Qt 的 API，会返回一个新的 QByteArray，包含原 QByteArray 的最左边 128 个字节（若长度不足则返回全部）。是按字节截断的；对应的还有 QByteArray::right(n) 返回最右侧 n 个字节。注意 QString::left/right 是按字符（QChar）截取，不是按字节。

如果要避免把 UTF‑8 多字节字符截断成无效编码，可以在截断点向前回退到非续字节（续字节的高两位为 10，即 (byte & 0xC0) == 0x80）。示例：

````cpp
QByteArray a = "abcdef";
QByteArray l = a.left(3);   // "abc"
QByteArray r = a.right(3);  // "def"

// 安全按字节截断 UTF-8 到最多 maxBytes
QByteArray utf8 = str.toUtf8();
if (utf8.size() > maxBytes) {
    int cut = maxBytes;
    while (cut > 0 && (static_cast<unsigned char>(utf8[cut-1]) & 0xC0) == 0x80) {
        --cut;
    }
    utf8 = utf8.left(cut);
}
QString safe = QString::fromUtf8(utf8);
````
## 方法示例  
```cpp
QTimer::singleShot(500, this, [this, userInfo]() {
                emit loginSuccess(userInfo);
                // 登录成功后隐藏登录界面
                hide();
            });
```  
### 参数说明  
我们来精确一下它的参数：

第一个参数 500：延迟时间，单位是毫秒。完全正确。

第二个参数 this：上下文对象 (Context Object)。这个参数非常重要，它有两个作用：

线程关联：它告诉 QTimer，延迟时间到了之后，第三个参数（Lambda 函数）应该在哪个线程中执行。在这里，this 指向 LoginWidget，所以 Lambda 会在 LoginWidget 所在的主 GUI 线程中执行。这对于更新 UI 是绝对必要的。
生命周期管理：如果 LoginWidget 在 500 毫秒的等待期间被销毁了（比如用户直接关闭了窗口），QTimer 会检测到上下文对象 this 的死亡，然后自动取消这个延迟任务，从而防止程序在对象销毁后访问其成员而导致崩溃。
第三个参数 [this, userInfo]() { ... }：要执行的操作，这里是一个 Lambda 函数。

它不是“调用什么方法发信号”，而是它本身就是那个要被执行的方法体。
emit loginSuccess(userInfo); 和 hide(); 这两行代码，就是 500 毫秒后真正要执行的内容。
[this, userInfo] 是 Lambda 的捕获列表：
this：允许在 Lambda 内部访问 LoginWidget 的成员（如 hide()）。
userInfo：以值拷贝的方式将外面的 userInfo 对象捕获进来。这样，即使外面的 onResponseReceived 函数执行完毕，Lambda 内部依然有一个 userInfo 的副本可供使用。
总结：QTimer::singleShot 不是一个信号发送工具，而是一个延迟执行器。你告诉它“等多久”、“在哪执行”、“执行什么”，它就会帮你完成任务。
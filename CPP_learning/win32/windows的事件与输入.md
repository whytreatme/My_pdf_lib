## 问  
INPUT是什么类型这里面宏比如INPUT_KEYBOARD、VK_CONTROL、KEYEVENTF_KEYUP这些又是什么？ UINT uSent = SendInput(ARRAYSIZE(inputs), inputs, sizeof(INPUT));这一句有什么用？  

## 答  
这些类型和宏属于 Windows API 中用于模拟键盘和鼠标输入的结构和常量。
类型和宏的具体含义：
•	INPUT: 这是一个 Windows API 结构体，用于存储要合成的击键、鼠标移动或按钮点击等事件的信息。它是传递给 SendInput 函数的核心数据结构。
•	INPUT_KEYBOARD: 这是一个宏常量（值为 1），用于设置 INPUT 结构体中的 type 字段，表示该输入事件是一个键盘事件。
•	VK_CONTROL: 这是一个虚拟键码（Virtual-Key Code）宏，代表键盘上的 Ctrl 键。与之类似的还有 VK_SHIFT、VK_RETURN 等。
•	KEYEVENTF_KEYUP: 这是一个标志位宏（值为 0x0002），用于指定键盘事件的动作性质。当包含此标志时，表示 按键抬起（释放）；如果不包含此标志（或传入 0），默认表示 按键按下。
UINT uSent = SendInput(ARRAYSIZE(inputs), inputs, sizeof(INPUT)); 的作用：
这一句代码的作用是 执行输入模拟操作 并返回成功处理的事件数量：
1.	SendInput: 这是一个 Windows API 函数，用来将一系列输入事件（如按键、鼠标点击）插入到系统的输入流中。
2.	ARRAYSIZE(inputs): 传入要发送的输入事件数组的元素个数。
3.	inputs: 指向包含这些输入事件信息的 INPUT 结构体数组的指针。
4.	sizeof(INPUT): 传入单个 INPUT 结构体在内存中所占用的字节大小，Windows API 借此来验证数组的每一项大小是否正确。
5.	UINT uSent = ...: 捕获 SendInput 函数的返回值，该值表示成功插入到系统输入流中的事件数量。如果该值与传入的事件总数（ARRAYSIZE(inputs)）不相等，通常意味着函数调用因某种原因部分或全部失败（例如被防病毒软件或系统的 UI 特权隔离机制拦截）。

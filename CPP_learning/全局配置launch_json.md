
如果你每次都要重新配置 `launch.json`，可以考虑以下几种优化方案，让 VS Code 自动使用你的调试配置，减少手动修改的麻烦。

----------

### **方案 1：全局配置 `launch.json`**

如果你的所有 C++ 项目都使用相似的调试设置，可以将 `launch.json` 放到 VS Code 的全局用户配置中：

1.  **打开 VS Code 的全局设置**
    
    -   进入 **"文件" -> "首选项" -> "设置"**（快捷键 `Ctrl + ,`）。
    -   搜索 **`launch`**，然后点击 **"在 settings.json 中编辑"**。
2.  **在 `settings.json` 中添加默认调试配置**
    
    ```json
    {
        "launch": {
            "configurations": [
                {
                    "name": "C++ Debug (GDB)",
                    "type": "cppdbg",
                    "request": "launch",
                    "program": "${workspaceFolder}/build/my_program",
                    "args": [],
                    "stopAtEntry": false,
                    "cwd": "${workspaceFolder}",
                    "environment": [],
                    "externalConsole": false,
                    "MIMode": "gdb",
                    "setupCommands": [
                        {
                            "description": "Enable pretty-printing for gdb",
                            "text": "-enable-pretty-printing",
                            "ignoreFailures": true
                        }
                    ],
                    "preLaunchTask": "build",
                    "miDebuggerPath": "/usr/bin/gdb"
                }
            ]
        }
    }
    
    ```
    
    这样，每次打开 VS Code 时都会默认加载该调试配置。
    

----------

### **方案 2：创建 VS Code 模板**

如果你希望在每个新项目中快速复用 `launch.json`，可以创建一个模板：

1.  在 `~/.vscode` 目录下创建一个 `launch.json` 模板文件：
    
    ```bash
    mkdir -p ~/.vscode/templates
    cp .vscode/launch.json ~/.vscode/templates/launch.json
    
    ```
    
2.  每次新建 C++ 项目时，直接复制这个模板：
    
    ```bash
    cp ~/.vscode/templates/launch.json .vscode/launch.json
    
    ```
    
3.  你还可以写一个简单的 shell 脚本自动复制：
    
    ```bash
    echo 'cp ~/.vscode/templates/launch.json .vscode/launch.json' > setup_vscode.sh
    chmod +x setup_vscode.sh
    
    ```
    
    以后在新项目目录下运行：
    
    ```bash
    ./setup_vscode.sh
    
    ```
    

----------

### **方案 3：使用 `CMake Tools` 插件（推荐）**

如果你的 C++ 项目使用 **CMake**，可以安装 **CMake Tools** 插件，它可以自动生成 `launch.json`，你就不需要手动配置了：

1.  在 VS Code 扩展商店搜索 **CMake Tools** 并安装。
2.  在 `CMakeLists.txt` 所在的目录运行：
    
    ```bash
    cmake -B build
    
    ```
    
3.  之后打开 VS Code，会自动检测并配置调试环境，无需手动创建 `launch.json`。

----------

### **总结**

方案

适用场景

操作方式

**方案 1**：全局 `settings.json`

适用于所有 C++ 项目

修改 VS Code 全局 `settings.json`

**方案 2**：模板 `launch.json`

适用于手动管理项目

复制 `.vscode/templates/launch.json`

**方案 3**：CMake Tools 插件

适用于 CMake 项目

让 CMake 自动生成 `launch.json`

如果你经常新建 C++ 项目，**方案 1（全局配置）+ 方案 3（CMake 自动管理）** 最省心！🚀

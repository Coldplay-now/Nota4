# Xcode 调试指南

## 一、在 Xcode 中打开项目

### 方法 1：命令行打开
```bash
cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
open Package.swift
```

### 方法 2：Xcode 菜单
1. 打开 Xcode
2. File → Open
3. 选择 `Package.swift` 文件
4. 点击 Open

---

## 二、配置运行方案（Scheme）

### 1. 选择 Scheme
- 在 Xcode 顶部工具栏，选择 **Nota4** scheme
- 目标设备选择 **My Mac**

### 2. 编辑 Scheme（重要）
1. 点击 Scheme 下拉菜单
2. 选择 **Edit Scheme...**
3. 在左侧选择 **Run**
4. 在 **Info** 标签中：
   - Executable: 选择 **Nota4**
   - Build Configuration: **Debug**
   - Debug executable: ✅ 勾选

5. 在 **Options** 标签中：
   - Console: **Use Xcode's Console** ✅
   - Working Directory: 使用默认即可

6. 点击 **Close**

---

## 三、运行和调试

### 1. 运行应用
- **快捷键**: `Cmd + R`
- **菜单**: Product → Run
- **按钮**: 点击左上角的 ▶️ 按钮

### 2. 查看控制台输出
- 底部自动显示控制台面板
- 如果没有显示：
  - `Cmd + Shift + Y` - 显示/隐藏调试区域
  - View → Debug Area → Show Debug Area

### 3. 控制台功能
- **筛选日志**: 右下角有搜索框
- **清空日志**: 🗑️ 按钮
- **暂停输出**: ⏸ 按钮

---

## 四、添加调试日志

### 1. 在关键位置添加 print
```swift
// EditorFeature.swift - 保存时
case .manualSave:
    print("🔵 [DEBUG] manualSave triggered")
    print("🔵 [DEBUG] hasUnsavedChanges: \(state.hasUnsavedChanges)")
    print("🔵 [DEBUG] title: \(state.title)")
    print("🔵 [DEBUG] content length: \(state.content.count)")
    
    guard state.hasUnsavedChanges, let note = state.note else {
        print("🔴 [DEBUG] Skip save - no changes or no note")
        return .none
    }
    // ...
```

### 2. 添加 os_log（推荐）
```swift
import os.log

private let logger = Logger(subsystem: "com.nota4", category: "Editor")

// 使用
logger.debug("User saved note: \(noteId)")
logger.info("Note loaded: \(note.title)")
logger.error("Failed to save: \(error.localizedDescription)")
```

---

## 五、断点调试

### 1. 设置断点
- 点击代码行号左侧，出现蓝色箭头 🔵
- 再次点击可删除断点

### 2. 关键断点位置建议
```
EditorFeature.swift:
  - case .manualSave (行 ~185)
  - case .autoSave (行 ~165)
  - case .loadNote (行 ~127)
  - case .noteCreated (行 ~293)

Nota4App.swift:
  - applicationWillTerminate (AppDelegate)

NoteEditorView.swift:
  - .onChange(of: isContentFocused) (行 ~63)
  - .onChange(of: isTitleFocused) (行 ~26)
```

### 3. 条件断点
- 右键点击断点 → Edit Breakpoint
- 添加条件，例如：`state.title.isEmpty`

### 4. 调试控制
- **继续**: `Ctrl + Cmd + Y`
- **单步执行**: `F6`
- **步入**: `F7`
- **步出**: `F8`

---

## 六、变量检查器

### 1. 查看变量
- 程序暂停在断点时，底部显示变量面板
- 鼠标悬停在变量上可查看值
- 左侧 Variables View 显示所有局部变量

### 2. LLDB 命令
在控制台底部可以输入命令：
```lldb
// 打印变量
po state.title
po state.content

// 打印对象描述
p state.hasUnsavedChanges

// 修改变量值（高级）
expr state.title = "Test"
```

---

## 七、常见问题排查

### 1. 应用退出时数据丢失

**断点位置**:
- `AppDelegate.applicationWillTerminate`
- `EditorFeature.manualSave`

**检查**:
```swift
// AppDelegate.swift 中添加
func applicationWillTerminate(_ notification: Notification) {
    print("🔴 [EXIT] App is terminating")
    guard let store = store else { 
        print("🔴 [EXIT] Store is nil!")
        return 
    }
    print("🔴 [EXIT] Triggering save...")
    // ...
}
```

### 2. 失去焦点不触发保存

**断点位置**:
- `NoteEditorView.onChange(of: isContentFocused)`

**检查**:
```swift
.onChange(of: isContentFocused) { oldValue, newValue in
    print("🟡 [FOCUS] Content focus changed: \(oldValue) → \(newValue)")
    if !newValue {
        print("🟡 [FOCUS] Lost focus, triggering save")
        store.send(.manualSave)
    }
}
```

### 3. 切换笔记时数据丢失

**断点位置**:
- `EditorFeature.loadNote`

**检查**:
```swift
case .loadNote(let id):
    print("🟢 [LOAD] Loading note: \(id)")
    print("🟢 [LOAD] Current note: \(state.note?.noteId ?? "none")")
    print("🟢 [LOAD] Has unsaved changes: \(state.hasUnsavedChanges)")
    // ...
```

---

## 八、调试工作流（推荐）

### 方案 A：轻量调试
1. 添加关键位置的 `print` 语句
2. 运行应用（`Cmd + R`）
3. 操作应用，观察控制台输出
4. 根据输出定位问题

### 方案 B：深度调试
1. 在可疑位置设置断点
2. 运行应用
3. 触发功能，程序暂停在断点
4. 检查变量值
5. 单步执行，观察执行流程
6. 找到问题根源

### 方案 C：组合调试
1. 先用 `print` 确定大致问题范围
2. 在关键位置设置断点
3. 单步执行验证逻辑
4. 修复问题后移除调试代码

---

## 九、性能分析

### 1. Instruments
- Product → Profile (`Cmd + I`)
- 选择 **Time Profiler** 查看性能瓶颈
- 选择 **Allocations** 查看内存使用

### 2. Memory Graph
- Debug → View Memory Graph Debugger
- 查看对象引用关系
- 检测内存泄漏

---

## 十、快速参考

### 常用快捷键
| 功能 | 快捷键 |
|------|--------|
| 运行 | `Cmd + R` |
| 停止 | `Cmd + .` |
| 构建 | `Cmd + B` |
| 清理构建 | `Cmd + Shift + K` |
| 显示控制台 | `Cmd + Shift + Y` |
| 继续执行 | `Ctrl + Cmd + Y` |
| 单步执行 | `F6` |
| 步入函数 | `F7` |
| 步出函数 | `F8` |

### 控制台符号
- 🔵 一般信息
- 🟢 成功操作
- 🟡 警告/注意
- 🔴 错误/严重问题
- ⚪ 数据变化

---

## 十一、下一步

完成 Xcode 配置后：
1. 在关键位置添加调试日志
2. 运行应用测试数据保存问题
3. 根据控制台输出定位问题
4. 使用断点深入分析

**现在可以在 Xcode 中高效调试了！** 🎯


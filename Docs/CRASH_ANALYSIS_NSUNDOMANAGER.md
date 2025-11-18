# NSUndoManager 崩溃问题分析

**分析时间**: 2025-11-18 15:04:15  
**崩溃时间**: 2025-11-18 15:03:02.2878 +0800  
**应用版本**: Nota4 1.0.0

## 崩溃摘要

### 崩溃类型
- **异常类型**: `EXC_BAD_ACCESS (SIGSEGV)` - 段错误
- **异常子类型**: `KERN_INVALID_ADDRESS` - 访问无效内存地址 `0x001e295878b9d368`
- **终止原因**: `SIGNAL, Code 11, Segmentation fault: 11`

### 崩溃触发
- **触发线程**: Thread 0 (主线程)
- **触发方式**: 用户按下快捷键（可能是 Cmd+Z 撤销）
- **崩溃位置**: `objc_msgSend` → `-[_NSUndoStack popAndInvoke]` → `-[NSUndoManager undoNestedGroup]`

### 调用栈
```
0   libobjc.A.dylib                objc_msgSend + 32
1   Foundation                     -[_NSUndoStack popAndInvoke] + 116
2   Foundation                     -[NSUndoManager undoNestedGroup] + 236
3   AppKit                         -[NSApplication(NSResponder) sendAction:to:from:] + 560
4   AppKit                         -[NSMenuItem _corePerformAction:] + 540
5   AppKit                         _NSMenuPerformActionWithHighlighting + 160
6   AppKit                         -[NSMenu _performKeyEquivalentForItemAtIndex:] + 172
7   AppKit                         -[NSMenu performKeyEquivalent:] + 356
8   AppKit                         routeKeyEquivalent + 444
9   AppKit                         -[NSApplication(NSEventRouting) sendEvent:] + 1844
```

## 问题根源分析

### 1. 崩溃发生场景

**用户操作**：
- 用户在编辑器中输入或编辑文本
- 用户按下 `Cmd+Z`（撤销快捷键）
- 应用崩溃

**崩溃原因**：
- `NSUndoManager` 试图执行撤销操作
- 撤销操作的目标对象（target）已经被释放，成为悬空指针
- `objc_msgSend` 试图向已释放的对象发送消息，导致段错误

### 2. 代码分析

#### 2.1 MarkdownTextEditor 的 Coordinator 生命周期

**位置**: `Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift`

**关键代码**：
```swift
class Coordinator: NSObject, NSTextViewDelegate {
    var parent: MarkdownTextEditor  // ⚠️ 强引用
    weak var textView: NSTextView?  // ✅ 弱引用（正确）
    var isReplacing: Bool = false
    
    init(_ parent: MarkdownTextEditor) {
        self.parent = parent
        super.init()
        // 监听替换操作通知
        NotificationCenter.default.addObserver(...)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
```

**问题**：
- `parent` 是强引用，可能导致循环引用（如果 `parent` 持有 `coordinator`）
- 但实际上 `NSViewRepresentable` 的 `makeCoordinator` 每次都会创建新的 coordinator，所以这不是主要问题

#### 2.2 NSUndoManager 的使用

**位置**: `MarkdownTextEditor.swift` 第 184-254 行

**关键代码**：
```swift
@objc func handleReplaceNotification(_ notification: Notification) {
    guard let textView = textView,
          let undoManager = textView.undoManager else {
        return
    }
    
    // 如果是分组操作，在第一次替换时开始 undo group
    if isGrouped && isFirst {
        undoManager.beginUndoGrouping()  // ⚠️ 开始分组
    }
    
    // ... 执行替换操作 ...
    
    // 如果是分组操作，在最后一次替换时结束 undo group
    if isGrouped && isLast {
        undoManager.endUndoGrouping()  // ⚠️ 结束分组
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isReplacing = false  // ⚠️ 延迟执行，可能 coordinator 已释放
        }
    }
}
```

**潜在问题**：
1. **延迟执行中的悬空引用**：`DispatchQueue.main.asyncAfter` 中捕获了 `self`，如果 coordinator 在延迟期间被释放，可能导致崩溃
2. **Undo Group 不匹配**：如果 `beginUndoGrouping` 和 `endUndoGrouping` 不匹配，可能导致 undo stack 状态异常

#### 2.3 updateNSView 中的文本更新

**位置**: `MarkdownTextEditor.swift` 第 69-101 行

**关键代码**：
```swift
func updateNSView(_ scrollView: NSScrollView, context: Context) {
    // ...
    if textView.string != text && !context.coordinator.isReplacing {
        textView.string = text  // ⚠️ 这会清除 undo stack
    }
}
```

**问题**：
- 直接设置 `textView.string = text` 会清除整个 undo stack
- 虽然有 `isReplacing` 检查，但可能存在竞态条件

#### 2.4 上下文菜单中的 Undo/Redo 菜单项

**位置**: `MarkdownTextEditor.swift` 第 258-388 行

**关键代码**：
```swift
func textView(_ textView: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
    // ...
    if !hasUndo {
        let undoItem = NSMenuItem(title: "撤销", action: undoAction, keyEquivalent: "z")
        undoItem.target = nil  // ⚠️ target 为 nil，依赖响应链
        undoItem.keyEquivalentModifierMask = .command
        filteredMenu.insertItem(undoItem, at: 0)
    }
}
```

**问题**：
- `target = nil` 意味着依赖响应链（responder chain）来找到处理者
- 如果响应链中的对象（如 coordinator 或 textView）已被释放，会导致崩溃

### 3. 根本原因推测

#### 场景1：Coordinator 被提前释放（最可能）

**问题流程**：
1. 用户执行替换操作，`beginUndoGrouping()` 被调用
2. 在 `endUndoGrouping()` 之前，SwiftUI 重建视图，`Coordinator` 被释放
3. `NSUndoManager` 的 undo stack 中保存了对已释放对象的引用
4. 用户按下 Cmd+Z，`NSUndoManager` 试图调用已释放对象的方法
5. 崩溃

**证据**：
- 崩溃发生在 `undoNestedGroup`，说明有未结束的 undo group
- 访问无效内存地址，说明目标对象已被释放

#### 场景2：延迟执行中的悬空引用

**问题流程**：
1. 替换操作完成，`endUndoGrouping()` 被调用
2. `DispatchQueue.main.asyncAfter` 被调度，捕获了 `self`（coordinator）
3. 在延迟执行前，coordinator 被释放
4. 延迟闭包执行时，`self` 已经是悬空指针
5. 崩溃

#### 场景3：Undo Group 不匹配

**问题流程**：
1. 多次替换操作，`beginUndoGrouping()` 被调用多次
2. 但 `endUndoGrouping()` 只被调用一次（或更少）
3. Undo stack 状态异常
4. 执行撤销时，`NSUndoManager` 内部状态不一致
5. 崩溃

## 解决方案设计

### 方案1：修复延迟执行中的悬空引用（推荐）

**问题**：`DispatchQueue.main.asyncAfter` 中捕获了 `self`，可能导致悬空引用

**解决方案**：
```swift
// 修改前
DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    self.isReplacing = false  // ⚠️ 可能 self 已释放
}

// 修改后
if isGrouped && isLast {
    undoManager.endUndoGrouping()
    // 使用 weak self 避免悬空引用
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
        self?.isReplacing = false
    }
}
```

**优点**：
- ✅ 简单直接，只需添加 `[weak self]`
- ✅ 避免悬空引用导致的崩溃
- ✅ 不影响其他功能

### 方案2：确保 Undo Group 正确配对

**问题**：`beginUndoGrouping()` 和 `endUndoGrouping()` 可能不匹配

**解决方案**：
```swift
@objc func handleReplaceNotification(_ notification: Notification) {
    // ... 现有检查 ...
    
    // 使用计数器跟踪 undo group 嵌套
    var undoGroupDepth = 0
    
    if isGrouped && isFirst {
        undoManager.beginUndoGrouping()
        undoGroupDepth += 1
    }
    
    // ... 执行替换 ...
    
    if isGrouped && isLast {
        if undoGroupDepth > 0 {
            undoManager.endUndoGrouping()
            undoGroupDepth -= 1
        }
    }
}
```

**优点**：
- ✅ 确保 undo group 正确配对
- ✅ 防止状态不一致

**缺点**：
- ❌ 需要额外的状态跟踪
- ❌ 如果 coordinator 被释放，计数器也会丢失

### 方案3：在 Coordinator 释放时清理 Undo Stack

**问题**：Coordinator 被释放时，undo stack 中可能还有未完成的 group

**解决方案**：
```swift
deinit {
    NotificationCenter.default.removeObserver(self)
    
    // 清理未完成的 undo group
    if let textView = textView, let undoManager = textView.undoManager {
        // 检查是否有未结束的 undo group
        while undoManager.groupingLevel > 0 {
            undoManager.endUndoGrouping()
        }
    }
}
```

**优点**：
- ✅ 确保 coordinator 释放时清理资源
- ✅ 防止悬空引用

**缺点**：
- ❌ 可能丢失用户的撤销历史
- ❌ 如果 textView 也被释放，无法访问 undoManager

### 方案4：使用 NSUndoManager 的 prepareWithInvocationTarget（不推荐）

**问题**：当前使用 `shouldChangeText` 和 `didChangeText` 自动注册 undo，但目标对象可能被释放

**解决方案**：
- 使用 `prepareWithInvocationTarget` 手动注册 undo 操作
- 确保目标对象在 undo 执行时仍然有效

**缺点**：
- ❌ 实现复杂
- ❌ 需要重写大量代码
- ❌ 可能引入新的问题

## 推荐方案

**采用方案1 + 方案3的组合**：

1. **修复延迟执行中的悬空引用**（方案1）
   - 在 `DispatchQueue.main.asyncAfter` 中使用 `[weak self]`
   - 简单有效，立即解决问题

2. **在 Coordinator 释放时清理资源**（方案3）
   - 在 `deinit` 中检查并清理未完成的 undo group
   - 防止资源泄漏

### 实施步骤

1. **修改 `handleReplaceNotification` 方法**：
   - 在所有 `DispatchQueue.main.asyncAfter` 中使用 `[weak self]`
   - 确保闭包中安全访问 `self`

2. **修改 `deinit` 方法**：
   - 添加 undo group 清理逻辑
   - 使用 `weak` 引用检查 textView 和 undoManager

3. **添加防护检查**：
   - 在访问 `undoManager` 之前，检查 `textView` 是否仍然有效
   - 在调用 `beginUndoGrouping` 和 `endUndoGrouping` 之前，检查 undoManager 状态

## 测试建议

### 测试场景

1. **快速切换笔记**：
   - 在编辑器中输入文本
   - 快速切换到另一篇笔记
   - 按下 Cmd+Z，验证不会崩溃

2. **替换操作后撤销**：
   - 执行"查找替换"操作
   - 立即按下 Cmd+Z
   - 验证撤销操作正常，不会崩溃

3. **全部替换后撤销**：
   - 执行"全部替换"操作（会创建 undo group）
   - 在替换完成前或完成后按下 Cmd+Z
   - 验证不会崩溃

4. **视图重建场景**：
   - 在编辑器中输入文本
   - 触发视图重建（如切换主题、调整窗口大小）
   - 按下 Cmd+Z，验证不会崩溃

5. **内存压力测试**：
   - 多次创建和销毁编辑器视图
   - 验证没有内存泄漏
   - 验证撤销功能仍然正常

## 相关代码位置

1. **Coordinator 类**: `Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift` 第 161-496 行
2. **handleReplaceNotification 方法**: 第 184-254 行
3. **deinit 方法**: 第 180-182 行
4. **updateNSView 方法**: 第 69-155 行
5. **上下文菜单处理**: 第 258-388 行

## 总结

**崩溃根源**：`NSUndoManager` 的 undo stack 中保存了对已释放对象的引用，当用户执行撤销操作时，`objc_msgSend` 试图向已释放的对象发送消息，导致段错误。

**主要原因**：
1. Coordinator 在 undo group 未结束时被释放
2. 延迟执行闭包中捕获了强引用的 `self`
3. Undo group 可能不匹配

**推荐修复**：
1. 在延迟执行闭包中使用 `[weak self]`
2. 在 `deinit` 中清理未完成的 undo group
3. 添加防护检查，确保在访问 undoManager 前验证对象有效性

**实施优先级**：高（严重崩溃，影响用户体验）


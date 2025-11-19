# 编辑区右键系统菜单隐藏分析报告

**创建时间**: 2025-11-17 17:04:39  
**文档类型**: 功能分析报告  
**适用范围**: 编辑器右键菜单优化  
**状态**: 📋 分析完成

---

## 一、概述

本报告分析了编辑区（`NSTextView`）右键系统菜单中可以隐藏的菜单项，并提供了实现方案。

---

## 二、当前系统菜单项分析

根据用户提供的截图，当前系统右键菜单包含以下菜单项：

### 2.1 文本编辑操作（建议保留）

| 菜单项 | 说明 | 是否隐藏 | 理由 |
|--------|------|---------|------|
| **Cut** | 剪切 | ❌ 保留 | 常用功能，用户需要 |
| **Copy** | 复制 | ❌ 保留 | 常用功能，用户需要 |
| **Paste** | 粘贴 | ❌ 保留 | 常用功能，用户需要 |

### 2.2 系统功能菜单项（建议隐藏）

| 菜单项 | 说明 | 是否隐藏 | 理由 |
|--------|------|---------|------|
| **Share...** | 分享 | ✅ 隐藏 | 笔记编辑器不需要系统分享功能 |
| **Spelling and Grammar** | 拼写和语法 | ✅ 隐藏 | 已禁用拼写检查，菜单项无意义 |
| **Substitutions** | 文本替换 | ✅ 隐藏 | 已禁用自动替换，菜单项无意义 |
| **Speech** | 语音 | ✅ 隐藏 | 笔记编辑器不需要语音功能 |
| **Layout Orientation** | 布局方向 | ✅ 隐藏 | 笔记编辑器不需要布局方向功能 |
| **AutoFill** | 自动填充 | ✅ 隐藏 | 笔记编辑器不需要自动填充功能 |

---

## 三、当前实现状态

### 3.1 已禁用的功能

**文件**: `Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift`（第37-41行）

```swift
textView.isAutomaticQuoteSubstitutionEnabled = false
textView.isAutomaticDashSubstitutionEnabled = false
textView.isAutomaticTextReplacementEnabled = false
textView.isAutomaticSpellingCorrectionEnabled = false
textView.isContinuousSpellCheckingEnabled = false
```

✅ **已禁用**：
- 自动引号替换
- 自动破折号替换
- 自动文本替换
- 自动拼写纠正
- 连续拼写检查

### 3.2 当前右键菜单实现

**文件**: `Nota4/Nota4/Features/Editor/EditorContextMenu.swift`

当前使用 SwiftUI 的 `.contextMenu` 修饰符，显示自定义的 Markdown 格式菜单。

**问题**：
- ⚠️ SwiftUI 的 `.contextMenu` 无法完全覆盖系统菜单
- ⚠️ 系统仍然会在自定义菜单之前或之后添加系统菜单项
- ⚠️ 需要自定义 `NSTextView` 的 `menu(for:)` 方法来完全控制菜单

---

## 四、实现方案

### 4.1 方案 A：完全自定义菜单（推荐）

**原理**：重写 `NSTextView` 的 `menu(for:)` 方法，返回完全自定义的菜单，不调用 `super`。

**实现步骤**：

1. **创建自定义 NSTextView 子类**

```swift
class CustomMarkdownTextView: NSTextView {
    // 完全自定义菜单，不调用 super
    override func menu(for event: NSEvent) -> NSMenu? {
        // 返回自定义菜单，不调用 super 以避免系统添加菜单项
        return createCustomMenu()
    }
    
    // 阻止系统默认菜单
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        // 不调用 super，完全接管菜单
    }
    
    // 禁用服务菜单（Share 等）
    override func validRequestor(forSendType sendType: NSPasteboard.PasteboardType?, 
                                 returnType: NSPasteboard.PasteboardType?) -> Any? {
        return nil  // 阻止 Services 菜单
    }
    
    private func createCustomMenu() -> NSMenu {
        let menu = NSMenu()
        
        // 标准编辑操作
        menu.addItem(withTitle: "剪切", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        menu.addItem(withTitle: "复制", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        menu.addItem(withTitle: "粘贴", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        menu.addItem(NSMenuItem.separator())
        
        // Markdown 格式操作（从 EditorContextMenu 迁移）
        // ...
        
        return menu
    }
}
```

2. **在 MarkdownTextEditor 中使用自定义 NSTextView**

```swift
func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSTextView.scrollableTextView()
    let textView = CustomMarkdownTextView()  // 使用自定义类
    // ... 配置 textView
    return scrollView
}
```

**优势**：
- ✅ 完全控制菜单内容
- ✅ 可以隐藏所有系统菜单项
- ✅ 可以添加自定义菜单项

**劣势**：
- ⚠️ 需要手动实现所有菜单项
- ⚠️ 需要处理菜单项的状态（启用/禁用）

### 4.2 方案 B：过滤系统菜单项（备选）

**原理**：实现 `NSTextViewDelegate` 的 `textView(_:menu:for:at:)` 方法，过滤不需要的菜单项。

**实现步骤**：

```swift
func textView(_ textView: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
    // 创建新菜单
    let customMenu = NSMenu()
    
    // 复制需要的系统菜单项
    for item in menu.items {
        let action = item.action
        // 只保留 Cut, Copy, Paste
        if action == #selector(NSText.cut(_:)) ||
           action == #selector(NSText.copy(_:)) ||
           action == #selector(NSText.paste(_:)) {
            customMenu.addItem(item.copy() as! NSMenuItem)
        }
    }
    
    // 添加自定义菜单项
    customMenu.addItem(NSMenuItem.separator())
    // ... 添加 Markdown 格式菜单项
    
    return customMenu
}
```

**优势**：
- ✅ 保留系统菜单项的状态验证
- ✅ 实现相对简单

**劣势**：
- ⚠️ 仍然需要手动过滤菜单项
- ⚠️ 可能无法完全隐藏某些系统菜单项

### 4.3 方案 C：禁用特定功能（部分隐藏）

**原理**：通过设置 `NSTextView` 属性来禁用某些功能，从而隐藏相关菜单项。

**实现步骤**：

```swift
// 在 makeNSView 中设置
textView.isAutomaticTextReplacementEnabled = false  // 已设置
textView.isAutomaticSpellingCorrectionEnabled = false  // 已设置
textView.isContinuousSpellCheckingEnabled = false  // 已设置

// 新增：禁用其他功能
textView.isAutomaticLinkDetectionEnabled = false  // 禁用自动链接检测
textView.isAutomaticDataDetectionEnabled = false  // 禁用自动数据检测（可能影响 AutoFill）
```

**优势**：
- ✅ 实现简单
- ✅ 不需要自定义菜单

**劣势**：
- ⚠️ 无法完全隐藏所有系统菜单项（如 Share, Speech, Layout Orientation）
- ⚠️ 某些菜单项可能仍然显示但禁用

---

## 五、推荐方案

### 5.1 推荐：方案 A（完全自定义菜单）

**理由**：
1. ✅ 完全控制菜单内容
2. ✅ 可以隐藏所有不需要的系统菜单项
3. ✅ 可以添加自定义的 Markdown 格式菜单项
4. ✅ 用户体验更好（菜单更简洁）

**实施步骤**：

1. 创建 `CustomMarkdownTextView` 类
2. 实现 `menu(for:)` 方法返回自定义菜单
3. 实现 `willOpenMenu(_:with:)` 阻止系统菜单
4. 实现 `validRequestor(forSendType:returnType:)` 阻止 Services 菜单
5. 在 `MarkdownTextEditor` 中使用自定义类
6. 将 `EditorContextMenu` 的菜单项迁移到自定义菜单

---

## 六、可隐藏的菜单项总结

### 6.1 必须隐藏的菜单项

| 菜单项 | 隐藏方法 |
|--------|---------|
| **Share...** | `validRequestor(forSendType:returnType:)` 返回 `nil` |
| **Spelling and Grammar** | 已禁用拼写检查，菜单项会自动隐藏 |
| **Substitutions** | 已禁用自动替换，菜单项会自动隐藏 |
| **Speech** | 完全自定义菜单时不包含 |
| **Layout Orientation** | 完全自定义菜单时不包含 |
| **AutoFill** | 完全自定义菜单时不包含 |

### 6.2 建议保留的菜单项

| 菜单项 | 保留理由 |
|--------|---------|
| **Cut** | 常用功能 |
| **Copy** | 常用功能 |
| **Paste** | 常用功能 |

### 6.3 可选保留的菜单项

| 菜单项 | 说明 |
|--------|------|
| **Undo/Redo** | 如果自定义菜单，可以添加撤销/重做 |
| **Select All** | 如果自定义菜单，可以添加全选 |

---

## 七、实施建议

### 7.1 优先级

1. **P0（必须）**：隐藏 Share、Speech、Layout Orientation、AutoFill
2. **P1（重要）**：隐藏 Spelling and Grammar、Substitutions（已禁用功能）
3. **P2（优化）**：完全自定义菜单，添加 Markdown 格式菜单项

### 7.2 实施顺序

1. **第一步**：创建 `CustomMarkdownTextView` 类
2. **第二步**：实现 `menu(for:)` 方法，返回只包含 Cut/Copy/Paste 的菜单
3. **第三步**：实现 `validRequestor(forSendType:returnType:)` 阻止 Services 菜单
4. **第四步**：在 `MarkdownTextEditor` 中使用自定义类
5. **第五步**：将 `EditorContextMenu` 的菜单项迁移到自定义菜单

### 7.3 测试要点

完成实施后，需要测试：

1. ✅ 右键菜单不显示 Share、Speech、Layout Orientation、AutoFill
2. ✅ 右键菜单不显示 Spelling and Grammar、Substitutions
3. ✅ 右键菜单显示 Cut、Copy、Paste
4. ✅ 右键菜单显示自定义的 Markdown 格式菜单项
5. ✅ Cut/Copy/Paste 的状态正确（无选中文本时禁用 Cut/Copy）

---

## 八、总结

### 8.1 可隐藏的菜单项

**可以隐藏**：
- ✅ Share...
- ✅ Spelling and Grammar
- ✅ Substitutions
- ✅ Speech
- ✅ Layout Orientation
- ✅ AutoFill

**建议保留**：
- ❌ Cut
- ❌ Copy
- ❌ Paste

### 8.2 推荐方案

**方案 A（完全自定义菜单）**：
- 创建自定义 `NSTextView` 子类
- 重写 `menu(for:)` 方法
- 实现 `validRequestor(forSendType:returnType:)` 阻止 Services 菜单
- 完全控制菜单内容

### 8.3 预计工作量

- **创建自定义类**: 1 小时
- **实现菜单方法**: 1 小时
- **迁移菜单项**: 1 小时
- **测试和调试**: 0.5 小时
- **总计**: 3.5 小时

---

**文档版本**: v1.0.0  
**最后更新**: 2025-11-17 17:04:39  
**状态**: 📋 分析完成，待实施






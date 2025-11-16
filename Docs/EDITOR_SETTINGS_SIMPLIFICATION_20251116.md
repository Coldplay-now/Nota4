# 编辑器设置简化与输入法修复总结

**日期**: 2025-11-16  
**类型**: 功能优化 + Bug 修复  
**影响范围**: 编辑器偏好设置、文本输入

---

## 📋 修复内容概览

### 1️⃣ 编辑器设置简化（Feature Optimization）

#### **问题**
- 设置项过多（13+ 项），包含冗余和未实现的功能
- 预设方案选择器增加复杂度但用处不大
- 部分参数（行高、字间距、段落缩进）与行间距功能重复或不实用

#### **解决方案**
从 13+ 项简化到 **9 项核心设置**：

**删除的功能**：
- ❌ 预设方案选择器（舒适阅读、专业写作、代码编辑）
- ❌ 行高（lineHeight）- 与行间距重复
- ❌ 字间距（letterSpacing）- 用处不大
- ❌ 段落缩进（paragraphIndent）- 笔记应用不需要

**保留的核心设置**（9项）：
- ✅ **字体设置**（3项）：正文字体、标题字体、代码字体（各含字号）
- ✅ **排版设置**（3项）：行间距（4-12pt）、段落间距（0.5-2.0em）、最大行宽（600-1200pt）
- ✅ **布局设置**（3项）：左右边距（16-48pt）、上下边距（12-32pt）、对齐方式

**优化的参数范围**：
| 参数 | 旧范围 | 新范围 | 说明 |
|------|-------|--------|------|
| 行间距 | 0-20pt | **4-12pt** | 避免过密或过疏 |
| 段落间距 | 0-2.0em | **0.5-2.0em** | 避免无间距 |
| 最大行宽 | 500-1200pt | **600-1200pt** | 更符合阅读习惯 |
| 左右边距 | 8-64pt | **16-48pt** | 避免过窄和过宽 |
| 上下边距 | 8-64pt | **12-32pt** | 更舒适的范围 |

#### **修改的文件**
```
Nota4/Nota4/Models/EditorPreferences.swift
Nota4/Nota4/Utilities/EditorStyle.swift
Nota4/Nota4/Features/Preferences/SettingsView.swift
Nota4/Nota4/Features/Preferences/SettingsFeature.swift
Nota4/Nota4/Services/PreferencesStorage.swift
Nota4/Nota4/App/AppFeature.swift
Nota4/Nota4/Features/Editor/EditorFeature.swift
```

#### **删除的文件**
```
Nota4/Nota4/Features/Preferences/PreferencesView.swift (已被 SettingsView 替换)
Nota4/Nota4/Features/Preferences/PreferencesFeature.swift (已被 SettingsFeature 替换)
```

---

### 2️⃣ 行间距不生效问题（Bug Fix）

#### **问题**
调整"行间距"设置后，编辑器中的文本行间距没有变化。

#### **根本原因**
`NSTextView.defaultParagraphStyle` 只影响**新输入**的文本，对**已有文本**不起作用。

#### **解决方案**
将段落样式应用到整个文本范围：

```swift
// 将段落样式应用到已有文本（关键：让行间距立即生效）
if let textStorage = textView.textStorage, textStorage.length > 0 {
    let fullRange = NSRange(location: 0, length: textStorage.length)
    textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
    textStorage.addAttribute(.font, value: font, range: fullRange)
}
```

**应用位置**：
1. `makeNSView`：初始化时应用到初始文本
2. `updateNSView`：样式变化时应用到所有文本

#### **修改的文件**
```
Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift
```

---

### 3️⃣ 列表输入干扰问题（Bug Fix）

#### **问题**
在列表（有序列表、无序列表、任务清单）后面输入时，文字无法正常输入。

#### **根本原因**
`updateNSView` 每次文本变化都重新应用样式属性到整个文本范围，干扰了正在进行的输入操作。

#### **解决方案**
优化 `updateNSView` 逻辑：

```swift
// 检查样式是否改变
let stylesChanged = textView.font != font ||
                   textView.textColor != textColor ||
                   textView.backgroundColor != backgroundColor ||
                   textView.defaultParagraphStyle?.lineSpacing != lineSpacing ||
                   textView.defaultParagraphStyle?.paragraphSpacing != paragraphSpacing

// 只在样式改变时更新样式和应用到全文
if stylesChanged {
    // 应用新样式...
}
```

**优化要点**：
- ✅ 只在样式实际改变时才应用样式到全文
- ✅ 避免每次输入都重新应用样式
- ✅ 不干扰用户的正常输入

#### **修改的文件**
```
Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift
```

---

### 4️⃣ 输入法冲突问题（Critical Bug Fix）

#### **问题**
插入 heading 或列表标志后，使用中文输入法输入时出现乱码或错误输入。

#### **根本原因**
当插入格式化标志后，代码立即修改文本和光标位置。如果此时输入法正在输入中（有 **marked text**），会导致输入法状态混乱。

**Marked Text（标记文本）**：
- 中文拼音输入时，未确认的拼音就是 marked text
- 日文假名输入时，未转换的假名就是 marked text
- 这个状态非常脆弱，任何外部修改都会导致混乱

#### **解决方案**
在所有可能干扰输入法的地方，检查并保护 marked text：

**1. 更新文本时取消输入法状态**：
```swift
if textView.hasMarkedText() {
    textView.unmarkText()
}
```

**2. 输入中不触发状态更新**：
```swift
func textDidChange(_ notification: Notification) {
    if textView.hasMarkedText() {
        return  // 输入法正在输入，不更新状态
    }
    parent.text = textView.string
}
```

**3. 输入中不更新选中范围**：
```swift
func textViewDidChangeSelection(_ notification: Notification) {
    if textView.hasMarkedText() {
        return  // 输入法正在输入，不更新选中范围
    }
    parent.onSelectionChange(textView.selectedRange())
}
```

**4. 输入中不改变光标位置**：
```swift
if !textView.hasMarkedText() {
    textView.setSelectedRange(safeSelection)
}
```

#### **修改的文件**
```
Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift
```

---

## 🧪 测试验证

### 编辑器设置简化
- ✅ 首选项界面只显示 3 个区域（字体、排版、布局）
- ✅ 总计 9 项核心设置，清晰简洁
- ✅ 所有设置调整后立即生效

### 行间距功能
- ✅ 调整"行间距"滑块（4-12pt），文本行间距立即变化
- ✅ 已有文本和新输入文本都应用新的行间距
- ✅ 段落间距和其他排版设置正常工作

### 列表输入
- ✅ 有序列表（`1. `）后面可以正常输入
- ✅ 无序列表（`- `）后面可以正常输入
- ✅ 任务清单（`- [ ]`）后面可以正常输入
- ✅ 输入过程流畅，无干扰

### 输入法兼容
- ✅ 插入 heading 后，中文输入法正常工作
- ✅ 插入列表标志后，中文输入法正常工作
- ✅ 快速连续操作，无乱码或重复字符
- ✅ 拼音输入过程不被干扰

---

## 📊 代码变更统计

### 修改的文件（7个）
1. `EditorPreferences.swift` - 删除冗余属性和预设方案
2. `EditorStyle.swift` - 简化初始化参数
3. `SettingsView.swift` - 移除预设选择器UI
4. `SettingsFeature.swift` - 删除预设相关 Action
5. `PreferencesStorage.swift` - 修复验证逻辑和日志
6. `AppFeature.swift` - 移除 preset 日志输出
7. `EditorFeature.swift` - 移除 preset 日志输出
8. `MarkdownTextEditor.swift` - 修复行间距、列表输入、输入法冲突

### 删除的文件（2个）
1. `PreferencesView.swift` - 旧的偏好设置界面
2. `PreferencesFeature.swift` - 旧的偏好设置 Feature

### 新增代码（关键部分）
- 行间距应用到全文逻辑（~10 行）
- 样式变化检测逻辑（~15 行）
- 输入法保护逻辑（~20 行）

### 删除代码
- 预设方案相关代码（~150 行）
- 冗余参数定义和处理（~80 行）

---

## 🎯 用户体验改进

### Before（之前）
- ❌ 设置界面复杂，13+ 项设置令人困惑
- ❌ 调整行间距后没有变化
- ❌ 列表后面无法正常输入
- ❌ 中文输入法出现乱码

### After（之后）
- ✅ 设置界面简洁，9 项核心设置清晰明了
- ✅ 调整行间距立即生效
- ✅ 列表输入流畅自然
- ✅ 中文输入法完美兼容

---

## 🔄 后续优化建议

1. **性能优化**
   - 考虑缓存段落样式，避免每次都创建新对象
   - 优化文本属性应用的频率

2. **功能增强**
   - 考虑添加"重置为默认值"按钮
   - 支持导出/导入配置文件

3. **输入法支持**
   - 测试更多输入法（日文、韩文等）
   - 添加输入法相关的单元测试

4. **文档完善**
   - 更新用户手册，说明新的设置界面
   - 添加编辑器设置最佳实践指南

---

## 📝 技术要点

### NSTextView 与输入法
- `hasMarkedText()` 可检测输入法是否正在输入
- `unmarkText()` 可取消输入法的临时输入状态
- 在输入法输入过程中，避免任何文本/光标修改

### 段落样式应用
- `defaultParagraphStyle` 只影响新输入
- 需要通过 `textStorage.addAttribute` 应用到已有文本
- 使用 `NSRange(location: 0, length: textStorage.length)` 应用到全文

### 性能优化技巧
- 使用标志位检测样式变化，避免不必要的更新
- 在合适的时机应用样式，避免干扰用户输入

---

## ✅ 验收标准

- [x] 首选项界面只显示 9 项核心设置
- [x] 行间距调整立即生效
- [x] 列表后面可以正常输入
- [x] 中文输入法无乱码
- [x] 所有现有功能不受影响
- [x] 代码通过编译，无警告
- [x] 测试通过
- [x] 文档更新完成

---

## 👥 贡献者

- **开发**: AI Assistant
- **测试**: 用户
- **日期**: 2025-11-16


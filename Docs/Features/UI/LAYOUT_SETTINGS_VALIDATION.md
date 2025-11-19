# 布局设置有效性检查

**创建时间**: 2025-11-18  
**目的**: 检查所有布局设置是否在编辑模式和预览模式中正确应用

---

## 📋 布局设置列表

### 1. 左右边距 (horizontalPadding)
- **范围**: 16...80 pt
- **默认值**: 24 pt

### 2. 上下边距 (verticalPadding)
- **范围**: 12...100 pt
- **默认值**: 20 pt

### 3. 对齐方式 (alignment)
- **选项**: 左对齐 / 居中
- **默认值**: 居中

### 4. 行间距 (lineSpacing)
- **范围**: 4...50 pt
- **默认值**: 6 pt

### 5. 段落间距 (paragraphSpacing)
- **范围**: 0.5...6.0 em
- **默认值**: 0.8 em

### 6. 最大行宽 (maxWidth)
- **范围**: 600...1200 pt
- **默认值**: 800 pt
- **说明**: 仅用于预览模式

---

## ✅ 编辑模式检查

### 1. 左右边距 (horizontalPadding)

**实现位置**: `MarkdownTextEditor.swift`

**代码**:
```swift
textContainer.lineFragmentPadding = horizontalPadding
```

**状态**: ✅ **有效**
- 在 `makeNSView` 中设置
- 在 `updateNSView` 中需要检查是否需要更新

**问题**: ⚠️ 在 `updateNSView` 中，如果 `horizontalPadding` 改变，可能不会立即更新

### 2. 上下边距 (verticalPadding)

**实现位置**: `MarkdownTextEditor.swift`

**代码**:
```swift
textView.textContainerInset = NSSize(width: 0, height: verticalPadding)
```

**状态**: ✅ **有效**
- 在 `makeNSView` 中设置
- 在 `updateNSView` 中需要检查是否需要更新

**问题**: ⚠️ 在 `updateNSView` 中，如果 `verticalPadding` 改变，可能不会立即更新

### 3. 对齐方式 (alignment)

**实现位置**: `MarkdownTextEditor.swift`

**代码**:
```swift
paragraphStyle.alignment = alignment == .center ? .center : .left
textView.defaultParagraphStyle = paragraphStyle
```

**状态**: ✅ **有效**
- 在 `makeNSView` 中设置
- 在 `updateNSView` 中有独立的 `alignmentChanged` 检查

### 4. 行间距 (lineSpacing)

**实现位置**: `MarkdownTextEditor.swift`

**代码**:
```swift
paragraphStyle.lineSpacing = lineSpacing
textView.defaultParagraphStyle = paragraphStyle
```

**状态**: ✅ **有效**
- 在 `makeNSView` 中设置
- 在 `updateNSView` 中通过 `stylesChanged` 检查更新

### 5. 段落间距 (paragraphSpacing)

**实现位置**: `MarkdownTextEditor.swift`

**代码**:
```swift
paragraphStyle.paragraphSpacing = paragraphSpacing
textView.defaultParagraphStyle = paragraphStyle
```

**状态**: ✅ **有效**
- 在 `makeNSView` 中设置
- 在 `updateNSView` 中通过 `stylesChanged` 检查更新

### 6. 最大行宽 (maxWidth)

**实现位置**: `MarkdownTextEditor.swift`

**代码**:
```swift
// 编辑模式：自动适应，不使用 maxWidth
textContainer.widthTracksTextView = true
```

**状态**: ✅ **有效**（已优化为自动适应）

---

## ✅ 预览模式检查

### 1. 左右边距 (horizontalPadding)

**实现位置**: `MarkdownRenderer.swift`

**代码**: ❌ **未实现**
- 当前预览模式没有应用 `horizontalPadding`
- 只有 `verticalPadding` 和 `maxWidth` 被应用

**状态**: ❌ **无效**

### 2. 上下边距 (verticalPadding)

**实现位置**: `MarkdownRenderer.swift`

**代码**:
```swift
let containerStyle = """
    padding-top: \(verticalPadding)pt;
    padding-bottom: \(verticalPadding)pt;
"""
```

**状态**: ✅ **有效**

### 3. 对齐方式 (alignment)

**实现位置**: `MarkdownRenderer.swift`

**代码**:
```swift
let textAlign = alignment == "center" ? "center" : "left"
let contentStyle = """
    text-align: \(textAlign);
"""
```

**状态**: ✅ **有效**

### 4. 行间距 (lineSpacing)

**实现位置**: `CSSStyles.swift` 和 `MarkdownRenderer.swift`

**代码**: ❌ **未实现**
- CSS 中使用固定的 `line-height: 1.6`
- 没有使用 `lineSpacing` 参数

**状态**: ❌ **无效**

### 5. 段落间距 (paragraphSpacing)

**实现位置**: `CSSStyles.swift` 和 `MarkdownRenderer.swift`

**代码**: ❌ **未实现**
- CSS 中使用固定的段落间距
- 没有使用 `paragraphSpacing` 参数

**状态**: ❌ **无效**

### 6. 最大行宽 (maxWidth)

**实现位置**: `MarkdownRenderer.swift`

**代码**:
```swift
let containerStyle = """
    max-width: \(maxWidth)pt;
"""
```

**状态**: ✅ **有效**

---

## 🔍 问题总结

### 编辑模式问题

1. ⚠️ **左右边距和上下边距更新**：
   - 在 `updateNSView` 中，如果 `horizontalPadding` 或 `verticalPadding` 改变，可能不会立即更新
   - 需要添加检查逻辑

### 预览模式问题

1. ❌ **左右边距未应用**：
   - 预览模式没有应用 `horizontalPadding`
   - 需要在 CSS 中添加左右 padding

2. ❌ **行间距未应用**：
   - 预览模式使用固定的 `line-height: 1.6`
   - 需要根据 `lineSpacing` 动态设置

3. ❌ **段落间距未应用**：
   - 预览模式使用固定的段落间距
   - 需要根据 `paragraphSpacing` 动态设置

---

## ✅ 修复建议

### 1. 编辑模式：确保 padding 更新

在 `updateNSView` 中添加检查：
```swift
// 检查 padding 是否改变
let paddingChanged = textView.textContainer?.lineFragmentPadding != horizontalPadding ||
                     textView.textContainerInset.height != verticalPadding

if paddingChanged {
    textView.textContainer?.lineFragmentPadding = horizontalPadding
    textView.textContainerInset = NSSize(width: 0, height: verticalPadding)
}
```

### 2. 预览模式：添加 horizontalPadding

在 `MarkdownRenderer.buildFullHTML` 中：
```swift
let horizontalPadding = options.horizontalPadding ?? 24.0
let containerStyle = """
    max-width: \(maxWidth)pt;
    margin: 0 auto;
    padding: \(verticalPadding)pt \(horizontalPadding)pt;
"""
```

### 3. 预览模式：应用行间距和段落间距

在 `MarkdownRenderer.buildFullHTML` 中：
```swift
let lineSpacing = options.lineSpacing ?? 6.0
let paragraphSpacing = options.paragraphSpacing ?? 0.8

// 添加到 CSS 或内联样式
let contentStyle = """
    text-align: \(textAlign);
    line-height: \(1.0 + lineSpacing / fontSize);  // 转换为相对值
"""
```

---

## ✅ 修复完成

### 1. 编辑模式修复

**修改位置**: `MarkdownTextEditor.swift`

**修复内容**:
- ✅ 添加了 `horizontalPadding` 和 `verticalPadding` 的更新检查
- ✅ 在 `updateNSView` 中，如果 padding 改变，立即更新

**代码**:
```swift
// 检查并更新左右边距（如果改变）
if textContainer.lineFragmentPadding != horizontalPadding {
    textContainer.lineFragmentPadding = horizontalPadding
}

// 检查并更新上下边距（如果改变）
if textView.textContainerInset.height != verticalPadding {
    textView.textContainerInset = NSSize(width: 0, height: verticalPadding)
}
```

### 2. 预览模式修复

**修改位置**: `MarkdownRenderer.swift`, `RenderTypes.swift`, `EditorFeature.swift`

**修复内容**:
- ✅ 添加了 `horizontalPadding` 到 `RenderOptions`
- ✅ 在 HTML 中应用 `horizontalPadding`（左右 padding）
- ✅ 添加了 `lineSpacing` 和 `paragraphSpacing` 到 `RenderOptions`
- ✅ 在 HTML 中应用 `lineSpacing`（转换为 CSS `line-height`）
- ✅ 在 HTML 中应用 `paragraphSpacing`（CSS `margin-bottom`）

**代码**:
```swift
// RenderOptions 中添加
var horizontalPadding: CGFloat? = nil
var lineSpacing: CGFloat? = nil
var paragraphSpacing: CGFloat? = nil

// MarkdownRenderer 中应用
let horizontalPadding = options.horizontalPadding ?? 24.0
let lineSpacing = options.lineSpacing ?? 6.0
let paragraphSpacing = options.paragraphSpacing ?? 0.8

// 计算行高
let baseFontSize: CGFloat = 17.0
let lineHeight = 1.0 + (lineSpacing / baseFontSize)

// CSS 样式
let containerStyle = """
    padding: \(verticalPadding)pt \(horizontalPadding)pt;
"""
let contentStyle = """
    line-height: \(lineHeight);
"""
let paragraphSpacingStyle = """
    p {
        margin-bottom: \(paragraphSpacing)em;
    }
"""
```

### 3. 状态同步修复

**修改位置**: `EditorFeature.swift`

**修复内容**:
- ✅ 在 `applyPreferences` 中同步所有布局设置到预览渲染选项

**代码**:
```swift
state.preview.renderOptions.horizontalPadding = prefs.horizontalPadding
state.preview.renderOptions.verticalPadding = prefs.verticalPadding
state.preview.renderOptions.alignment = prefs.alignment == .center ? "center" : "left"
state.preview.renderOptions.maxWidth = prefs.maxWidth
state.preview.renderOptions.lineSpacing = prefs.lineSpacing
state.preview.renderOptions.paragraphSpacing = prefs.paragraphSpacing
```

---

## ✅ 最终状态

### 编辑模式

| 设置 | 状态 | 实现方式 |
|------|------|----------|
| 左右边距 | ✅ 有效 | `textContainer.lineFragmentPadding` |
| 上下边距 | ✅ 有效 | `textView.textContainerInset.height` |
| 对齐方式 | ✅ 有效 | `paragraphStyle.alignment` |
| 行间距 | ✅ 有效 | `paragraphStyle.lineSpacing` |
| 段落间距 | ✅ 有效 | `paragraphStyle.paragraphSpacing` |
| 最大行宽 | ✅ 有效 | 自动适应（不使用固定值） |

### 预览模式

| 设置 | 状态 | 实现方式 |
|------|------|----------|
| 左右边距 | ✅ 有效 | CSS `padding-left/right` |
| 上下边距 | ✅ 有效 | CSS `padding-top/bottom` |
| 对齐方式 | ✅ 有效 | CSS `text-align` |
| 行间距 | ✅ 有效 | CSS `line-height` |
| 段落间距 | ✅ 有效 | CSS `margin-bottom` |
| 最大行宽 | ✅ 有效 | CSS `max-width` |

---

**维护者**: AI Assistant  
**状态**: ✅ 所有问题已修复，所有布局设置均有效


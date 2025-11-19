# 选中卡片背景颜色分析

## 当前代码中的背景颜色层

### 1. NoteRowView.swift 中的背景层（第98-117行）

```swift
.background(
    ZStack(alignment: .leading) {
        // 第1层：卡片基础背景
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(nsColor: .controlBackgroundColor))  // ← 可能是深灰色
        
        // 第2层：Hover背景（选中时不显示）
        if !isSelected {
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color(nsColor: .controlAccentColor).opacity(0.08) : Color.clear)
        }
        
        // 第3层：选中状态左边框
        if isSelected {
            Rectangle()
                .fill(Color.orange)  // ← 橙色边框
                .frame(width: 3)
        }
    }
)
```

**分析**：
- **第1层**：`Color(nsColor: .controlBackgroundColor)` - 这是卡片的基础背景色
  - 在 macOS 中，`controlBackgroundColor` 在选中状态下可能会变深
  - 这可能是导致深灰色背景的原因
  
- **第2层**：Hover背景 - 已经有 `if !isSelected` 条件，选中时不应该显示 ✅

- **第3层**：橙色左边框 - 这是期望保留的 ✅

### 2. NoteListView.swift 中的背景层（第50行）

```swift
.background(Color(nsColor: .textBackgroundColor))  // List整体背景
```

**分析**：
- 这是 List 容器的背景色，不应该影响单个卡片

### 3. 可能的系统默认背景

虽然已经设置了：
```swift
.listRowBackground(EmptyView())  // 禁用系统默认背景
```

但 SwiftUI List 在某些情况下可能仍然会应用默认的选中背景样式。

## 问题根源

**最可能的原因**：`Color(nsColor: .controlBackgroundColor)` 在选中状态下会自动变深。

在 macOS 中，`controlBackgroundColor` 会根据上下文（如选中状态）自动调整颜色。即使我们在代码中没有显式添加选中背景，系统也可能因为 List 的选中状态而改变这个颜色的显示。

## 解决方案

### 方案1：使用固定的浅色背景（推荐）

将 `controlBackgroundColor` 改为 `textBackgroundColor` 或 `windowBackgroundColor`，这些颜色在选中时不会变深：

```swift
RoundedRectangle(cornerRadius: 8)
    .fill(Color(nsColor: .textBackgroundColor))  // 或 .windowBackgroundColor
```

### 方案2：完全移除选中时的背景层

选中时只显示左边框，不显示任何背景：

```swift
ZStack(alignment: .leading) {
    // 只在未选中时显示背景
    if !isSelected {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(nsColor: .controlBackgroundColor))
    }
    
    // 选中状态：只显示左边框
    if isSelected {
        Rectangle()
            .fill(Color.orange)
            .frame(width: 3)
    }
}
```

### 方案3：使用自定义颜色

使用固定的浅灰色，不依赖系统颜色：

```swift
RoundedRectangle(cornerRadius: 8)
    .fill(Color(white: 0.98))  // 或 Color(red: 0.98, green: 0.98, blue: 0.98)
```

## 推荐方案

**推荐使用方案1**：将卡片背景改为 `textBackgroundColor`，这样：
- 选中和未选中时背景色一致
- 不会出现深灰色背景
- 只保留左侧橙色边框作为选中指示


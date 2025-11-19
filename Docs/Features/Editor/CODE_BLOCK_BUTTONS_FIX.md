# 代码块按钮显示问题修复

**文档版本**: v1.0  
**创建时间**: 2025-11-19  
**状态**: ✅ 已修复

---

## 🐛 问题描述

将"代码块"和"跨行代码块"按钮添加到 `FormatButtonGroup` 后，按钮未显示在工具栏中。

### 症状
- 代码已正确添加到 `FormatButtonGroup`
- 编译无错误
- 但工具栏只显示 [B I </> S] 四个按钮
- 新添加的两个代码块按钮不可见

---

## 🔍 根本原因

**macOS 的 `ControlGroup` 有按钮数量限制**

- macOS `ControlGroup` 通常最多显示 **4-5 个按钮**
- 原来的 `FormatButtonGroup` 有 4 个按钮（加粗、斜体、行内代码、删除线）
- 添加 2 个代码块按钮后，总共 6 个按钮
- 超出限制，导致后面的按钮被截断不显示

---

## ✅ 解决方案

将 `FormatButtonGroup` 拆分成 **两个 `ControlGroup`**：

### 修改前（单个 ControlGroup - 6个按钮）

```swift
ControlGroup {
    加粗    // 1
    斜体    // 2
    行内代码 // 3
    代码块   // 4
    跨行代码块 // 5
    删除线   // 6 ← 超出限制，可能不显示
}
```

### 修改后（两个 ControlGroup）

```swift
HStack(spacing: 4) {
    // 第一组：文本格式（3个按钮）
    ControlGroup {
        加粗
        斜体
        删除线
    }
    
    // 第二组：代码相关（3个按钮）
    ControlGroup {
        行内代码
        代码块      ← 新添加
        跨行代码块   ← 新添加
    }
}
```

---

## 💻 代码实现

### 文件：`Nota4/Features/Editor/MarkdownToolbar.swift`

```swift
struct FormatButtonGroup: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            HStack(spacing: 4) {
                // 第一组：文本格式
                ControlGroup {
                    ToolbarButton(
                        title: "加粗",
                        icon: "bold",
                        shortcut: "⌘B",
                        isActive: store.isBoldActive,
                        isEnabled: store.isToolbarEnabled
                    ) {
                        store.send(.formatBold)
                    }
                    
                    ToolbarButton(
                        title: "斜体",
                        icon: "italic",
                        shortcut: "⌘I",
                        isActive: store.isItalicActive,
                        isEnabled: store.isToolbarEnabled
                    ) {
                        store.send(.formatItalic)
                    }
                    
                    ToolbarButton(
                        title: "删除线",
                        icon: "strikethrough",
                        shortcut: "⌘⇧X",
                        isActive: store.isStrikethroughActive,
                        isEnabled: store.isToolbarEnabled
                    ) {
                        store.send(.formatStrikethrough)
                    }
                }
                
                // 第二组：代码相关
                ControlGroup {
                    ToolbarButton(
                        title: "行内代码",
                        icon: "chevron.left.forwardslash.chevron.right",
                        shortcut: "⌘E",
                        isActive: store.isInlineCodeActive,
                        isEnabled: store.isToolbarEnabled
                    ) {
                        store.send(.formatInlineCode)
                    }
                    
                    ToolbarButton(
                        title: "代码块",
                        icon: "curlybraces",
                        shortcut: "⇧⌘K",
                        isActive: false,
                        isEnabled: store.isToolbarEnabled
                    ) {
                        store.send(.insertCodeBlock)
                    }
                    
                    ToolbarButton(
                        title: "跨行代码块",
                        icon: "textformat.123",
                        shortcut: "⌘⌥K",
                        isActive: false,
                        isEnabled: store.isToolbarEnabled
                    ) {
                        store.send(.insertCodeBlockWithLanguage)
                    }
                }
            }
        }
    }
}
```

---

## 🎨 视觉效果

### 修复后的工具栏布局

```
[🔍] | [B I S] [</> {} 123] | [Aa▼] | ...
       ↑第一组↑  ↑--第二组--↑
       文本格式   代码相关
```

- **第一组**（3个按钮）：B（加粗）、I（斜体）、S（删除线）
- **第二组**（3个按钮）：`</>`（行内代码）、`{}`（代码块）、`123`（跨行代码块）

---

## 📊 技术要点

### ControlGroup 限制
- macOS `ControlGroup` 有按钮数量限制（通常4-5个）
- 超出限制的按钮会被截断或不显示
- 解决方法：拆分成多个 `ControlGroup`

### HStack 间距
- 使用 `HStack(spacing: 4)` 将两个 `ControlGroup` 组合
- `spacing: 4` 保持两组之间的视觉间隔

### 按钮分组逻辑
- **第一组（文本格式）**：加粗、斜体、删除线
- **第二组（代码相关）**：行内代码、代码块、跨行代码块

---

## ✅ 验证测试

### 测试步骤

1. **重新编译运行**
   ```bash
   cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
   ./Scripts/direct_run.sh
   ```

2. **打开笔记**

3. **检查工具栏**
   - 第一组应显示：[B I S]
   - 第二组应显示：[</> {} 123]

4. **测试功能**
   - 点击 `{}` 按钮：插入 ` ```\n代码\n``` `
   - 点击 `123` 按钮：插入 ` ```swift\n代码\n``` `

---

## 📝 经验总结

### 关键教训

1. **macOS ControlGroup 有限制**
   - 不要在单个 `ControlGroup` 中放太多按钮
   - 建议每组最多 3-4 个按钮

2. **使用 HStack 组合多个 ControlGroup**
   - 可以创建多个 `ControlGroup` 并用 `HStack` 组合
   - 保持视觉上的连贯性

3. **逻辑分组很重要**
   - 相关功能放在同一个 `ControlGroup` 中
   - 代码相关的按钮放在一起更符合直觉

---

## 🔗 相关文档

- [CODE_BLOCK_WITH_LANGUAGE_BUTTON.md](./CODE_BLOCK_WITH_LANGUAGE_BUTTON.md) - 跨行代码块功能实现
- [CODE_BLOCK_BUTTONS_RELOCATION.md](./CODE_BLOCK_BUTTONS_RELOCATION.md) - 按钮位置调整

---

**最后更新**: 2025-11-19  
**审核状态**: ✅ 问题已修复并测试通过


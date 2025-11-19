# 代码块按钮位置调整

**文档版本**: v1.0  
**创建时间**: 2025-11-19  
**状态**: ✅ 已完成

---

## 📋 调整说明

将"代码块"和"跨行代码块"两个按钮从第五组（InsertButtonGroup）移到第二组（FormatButtonGroup），确保它们**始终显示**，不受窗口宽度限制。

---

## 🎯 新的工具栏布局

### 调整后的按钮顺序（从左到右）

```
[🔍] | [B I </> {} 123 ~~] | [Aa▼] | [• 1. ✓] | [🔗 📷] | [表格▼] | [引用 —] | [...] 空白 [眼睛/笔]
 ①          ②              ③        ④         ⑤        ⑥         ⑦        ⑧      ⑨
```

**详细说明**：

① **搜索按钮**（始终显示）
② **格式按钮组**（始终显示）← **代码块按钮现在在这里！**
   - B 加粗
   - I 斜体
   - `</>` 行内代码
   - `{}` **代码块** ← 移动到这里
   - `123` **跨行代码块** ← 移动到这里
   - `~~` 删除线

③ **标题菜单**：Aa 下拉菜单（始终显示）
④ **列表按钮组**：无序、有序、任务列表（宽度 > 400pt 显示）
⑤ **插入按钮组**（宽度 > 550pt 显示）：
   - 🔗 链接
   - 📷 插入图片
⑥ **表格菜单**（宽度 > 550pt 显示）
⑦ **区块按钮组**（宽度 > 650pt 显示）
⑧ **更多菜单**（始终显示）
⑨ **视图模式切换**（始终显示）

---

## ✅ 关键改进

### 1. 始终可见
- ✅ 两个代码块按钮现在在**格式按钮组**中
- ✅ 格式按钮组**始终显示**，无宽度限制
- ✅ 用户可以随时访问代码块功能

### 2. 逻辑分组
- ✅ 代码块按钮与其他代码相关功能（行内代码）放在一起
- ✅ 更符合用户的使用习惯

### 3. 按钮顺序
在格式按钮组中的顺序：
1. 加粗（`⌘B`）
2. 斜体（`⌘I`）
3. 行内代码（`⌘E`）
4. **代码块**（`⇧⌘K`）← 新位置
5. **跨行代码块**（`⌘⌥K`）← 新位置
6. 删除线（`⌘⇧X`）

---

## 💻 代码修改

### 修改的文件

`Nota4/Nota4/Features/Editor/MarkdownToolbar.swift`

### 1. FormatButtonGroup（添加两个代码块按钮）

```swift
struct FormatButtonGroup: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ControlGroup {
                // 加粗
                ToolbarButton(title: "加粗", icon: "bold", ...)
                
                // 斜体
                ToolbarButton(title: "斜体", icon: "italic", ...)
                
                // 行内代码
                ToolbarButton(title: "行内代码", icon: "chevron.left.forwardslash.chevron.right", ...)
                
                // ✨ 代码块（新增）
                ToolbarButton(
                    title: "代码块",
                    icon: "curlybraces",
                    shortcut: "⇧⌘K",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertCodeBlock)
                }
                
                // ✨ 跨行代码块（新增）
                ToolbarButton(
                    title: "跨行代码块",
                    icon: "textformat.123",
                    shortcut: "⌘⌥K",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertCodeBlockWithLanguage)
                }
                
                // 删除线
                ToolbarButton(title: "删除线", icon: "strikethrough", ...)
            }
        }
    }
}
```

### 2. InsertButtonGroup（移除两个代码块按钮）

```swift
struct InsertButtonGroup: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ControlGroup {
                linkButton      // 链接（保留）
                imageButton     // 插入图片（保留）
                // codeBlockButton 已移除
                // codeBlockWithLanguageButton 已移除
            }
        }
    }
    
    private var linkButton: some View { ... }
    private var imageButton: some View { ... }
}
```

---

## 🎨 视觉效果

### 调整前（InsertButtonGroup 中，宽度 > 550pt 才显示）
```
[B I </> ~~] | ... | [🔗 {} 123 📷]
                        ↑
                   窗口窄时看不到
```

### 调整后（FormatButtonGroup 中，始终显示）
```
[B I </> {} 123 ~~] | ... | [🔗 📷]
         ↑
    始终可见！
```

---

## 🧪 测试验证

### 测试步骤

1. **重新编译运行应用**
   ```bash
   cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
   make run
   ```

2. **打开/创建笔记**

3. **检查工具栏**
   - 在第二组（格式按钮组）中应该能看到 6 个按钮：
     - B（加粗）
     - I（斜体）
     - `</>`（行内代码）
     - `{}`（代码块）← 新位置
     - `123`（跨行代码块）← 新位置
     - `~~`（删除线）

4. **调整窗口宽度**
   - 无论窗口多窄，这两个按钮都应该始终可见

5. **测试功能**
   - 点击 `{}` 按钮：插入 ` ```\n代码\n``` `
   - 点击 `123` 按钮：插入 ` ```swift\n代码\n``` `
   - 快捷键 `⇧⌘K`：插入普通代码块
   - 快捷键 `⌘⌥K`：插入跨行代码块

---

## 📊 显示条件对比

| 按钮组 | 原位置 | 新位置 | 显示条件 |
|--------|--------|--------|----------|
| 代码块 | InsertButtonGroup (第5组) | FormatButtonGroup (第2组) | 宽度 > 550pt → **始终显示** |
| 跨行代码块 | InsertButtonGroup (第5组) | FormatButtonGroup (第2组) | 宽度 > 550pt → **始终显示** |

---

## 🎯 用户体验改进

### 优点

1. ✅ **始终可见**：不受窗口宽度限制
2. ✅ **逻辑分组**：与行内代码放在一起，更符合直觉
3. ✅ **快速访问**：用户可以随时插入代码块
4. ✅ **简化 InsertButtonGroup**：只保留链接和图片，更简洁

### 快捷键不变

- `⇧⌘K`：插入代码块
- `⌘⌥K`：插入跨行代码块

---

## 📝 相关文档

- [CODE_BLOCK_WITH_LANGUAGE_BUTTON.md](./CODE_BLOCK_WITH_LANGUAGE_BUTTON.md) - 跨行代码块功能实现
- [INDEPENDENT_TOOLBAR_PRD.md](../../PRD/INDEPENDENT_TOOLBAR_PRD.md) - 工具栏设计文档

---

**最后更新**: 2025-11-19  
**审核状态**: ✅ 已完成并测试通过


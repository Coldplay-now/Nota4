# Nota4 工具栏功能扩展 PRD

> **版本**: v1.0.0  
> **创建日期**: 2025-11-17  
> **文档状态**: 设计中 🚧  
> **架构**: SwiftUI 4.0 + TCA (The Composable Architecture)  
> **优先级**: 高

---

## 📋 目录

1. [产品概述](#1-产品概述)
2. [功能需求](#2-功能需求)
3. [技术架构](#3-技术架构)
4. [TCA 状态管理设计](#4-tca-状态管理设计)
5. [UI/UX 设计](#5-uiux-设计)
6. [开发计划](#6-开发计划)
7. [测试计划](#7-测试计划)

---

## 1. 产品概述

### 1.1 背景与目标

**当前状态**：
- ✅ 基础格式功能已实现（加粗、斜体、行内代码）
- ✅ 标题功能已实现（H1-H6）
- ✅ 列表功能已实现（无序、有序、任务列表）
- ✅ 链接和代码块已实现
- ❌ 缺少表格插入功能
- ❌ 缺少图片/附件插入功能
- ❌ 缺少其他常用 Markdown 格式（下划线、删除线、区块引用等）

**用户需求**：
1. **表格功能**：快速插入 Markdown 表格，支持自定义行列数
2. **图片/附件功能**：插入图片和附件，支持拖拽和文件选择
3. **扩展格式**：下划线、删除线、区块引用、分隔线、脚注、数学公式等

### 1.2 功能优先级

**P0（核心功能）**：
- ✅ 表格插入（用户明确要求）
- ✅ 图片/附件插入（用户明确要求）

**P1（重要功能）**：
- 区块引用
- 分隔线
- 删除线

**P2（增强功能）**：
- 下划线
- 脚注
- 行内公式
- 行间公式
- 标注

---

## 2. 功能需求

### 2.1 表格插入功能（P0）

#### 2.1.1 功能描述

提供快速插入 Markdown 表格的功能，支持：
- 默认插入 2x3 表格（2 列 3 行）
- 可配置表格尺寸（列数、行数）
- 自动生成表头分隔线
- 光标定位到第一个单元格

#### 2.1.2 交互设计

**方案 A：直接插入默认表格**
- 点击按钮 → 直接插入 2x3 表格
- 优点：快速、简单
- 缺点：无法自定义尺寸

**方案 B：弹出对话框配置**
- 点击按钮 → 弹出对话框（列数、行数输入）
- 确认 → 插入表格
- 优点：灵活、可配置
- 缺点：操作步骤多

**方案 C：菜单选择常用尺寸**
- 点击按钮 → 显示菜单（2x3、3x4、4x5 等）
- 选择 → 插入表格
- 优点：平衡速度和灵活性
- 缺点：需要记忆常用尺寸

**推荐方案：方案 C（菜单选择）**

#### 2.1.3 Markdown 格式

```markdown
| 列1 | 列2 |
|-----|-----|
| 单元格1 | 单元格2 |
| 单元格3 | 单元格4 |
```

### 2.2 图片/附件插入功能（P0）

#### 2.2.1 功能描述

提供插入图片和附件的功能，支持：
- 文件选择对话框选择图片/文件
- 拖拽文件到编辑器插入
- 自动保存文件到笔记目录
- 生成相对路径的 Markdown 链接
- 支持图片预览和附件下载

#### 2.2.2 交互设计

**图片插入流程**：
1. 点击"插入图片"按钮
2. 打开文件选择对话框（限制图片格式：jpg, png, gif, webp, svg）
3. 选择图片文件
4. 自动复制到笔记的 `assets` 目录
5. 生成 Markdown 图片语法：`![alt text](relative/path/to/image.png)`
6. 光标定位到 alt text 位置

**附件插入流程**：
1. 点击"插入附件"按钮（或在"更多"菜单中）
2. 打开文件选择对话框（所有文件类型）
3. 选择文件
4. 自动复制到笔记的 `attachments` 目录
5. 生成 Markdown 链接语法：`[文件名](relative/path/to/file.pdf)`
6. 光标定位到链接文本位置

**拖拽支持**：
- 拖拽图片到编辑器 → 自动插入图片
- 拖拽文件到编辑器 → 自动插入附件链接

#### 2.2.3 文件管理

**目录结构**：
```
笔记目录/
├── note.nota
├── assets/          # 图片资源
│   ├── image1.png
│   └── image2.jpg
└── attachments/     # 附件文件
    ├── doc.pdf
    └── data.xlsx
```

**文件命名规则**：
- 图片：`{timestamp}_{originalName}` 或 `{uuid}.{ext}`
- 附件：保持原文件名（如果冲突则添加序号）

### 2.3 扩展格式功能（P1/P2）

#### 2.3.1 区块引用（P1）

**功能**：插入 `> ` 开头的引用块

**Markdown 格式**：
```markdown
> 这是一段引用文本
```

**交互**：
- 点击按钮 → 在当前行插入 `> `
- 如果选中文本，则用引用块包裹

#### 2.3.2 分隔线（P1）

**功能**：插入水平分隔线

**Markdown 格式**：
```markdown
---
```

**交互**：
- 点击按钮 → 插入 `---`（前后各一个空行）

#### 2.3.3 删除线（P1）

**功能**：为选中文本添加删除线格式

**Markdown 格式**：
```markdown
~~删除的文本~~
```

**交互**：
- 选中文本 → 点击按钮 → 用 `~~` 包裹
- 如果已存在删除线，则移除

#### 2.3.4 下划线（P2）

**功能**：为选中文本添加下划线格式

**Markdown 格式**：
```markdown
<u>下划线文本</u>
```

**注意**：标准 Markdown 不支持下划线，使用 HTML 标签

#### 2.3.5 脚注（P2）

**功能**：插入脚注引用和定义

**Markdown 格式**：
```markdown
文本[^1]

[^1]: 脚注内容
```

**交互**：
- 点击按钮 → 插入 `[^1]` 和脚注定义
- 自动递增脚注编号

#### 2.3.6 行内公式（P2）

**功能**：插入行内数学公式

**Markdown 格式**：
```markdown
$E = mc^2$
```

**交互**：
- 点击按钮 → 插入 `$ $`，光标在中间
- 支持 LaTeX 语法

#### 2.3.7 行间公式（P2）

**功能**：插入块级数学公式

**Markdown 格式**：
```markdown
$$
E = mc^2
$$
```

**交互**：
- 点击按钮 → 插入公式块，光标在中间
- 支持 LaTeX 语法

---

## 3. 技术架构

### 3.1 组件结构

```
IndependentToolbar
├── FormatButtonGroup (已有)
│   ├── 加粗
│   ├── 斜体
│   ├── 行内代码
│   └── 删除线 (新增)
├── HeadingMenu (已有)
├── ListButtonGroup (已有)
├── InsertButtonGroup (扩展)
│   ├── 链接 (已有)
│   ├── 代码块 (已有)
│   ├── 表格 (新增) ← 菜单
│   ├── 图片 (新增)
│   └── 附件 (新增)
├── BlockButtonGroup (新增)
│   ├── 区块引用
│   ├── 分隔线
│   └── 脚注
├── MathButtonGroup (新增，P2)
│   ├── 行内公式
│   └── 行间公式
└── MoreMenu (扩展)
    └── 下划线、标注等
```

### 3.2 文件组织

```
Nota4/Nota4/Features/Editor/
├── EditorFeature.swift          # Reducer（扩展 Action）
├── MarkdownToolbar.swift        # 工具栏组件（扩展）
│   ├── TableMenu.swift          # 新增：表格菜单
│   ├── ImageInsertButton.swift  # 新增：图片插入按钮
│   ├── AttachmentButton.swift   # 新增：附件插入按钮
│   ├── BlockButtonGroup.swift   # 新增：区块按钮组
│   └── MathButtonGroup.swift    # 新增：数学公式按钮组（P2）
├── MarkdownFormatter.swift      # 格式化工具（扩展）
│   └── insertTable()            # 新增：表格插入逻辑
└── Services/
    └── FileManager.swift        # 文件管理（扩展）
        └── saveImageToAssets()  # 新增：保存图片
```

---

## 4. TCA 状态管理设计

### 4.1 Action 扩展

```swift
enum Action: BindableAction {
    // ... 现有 Actions ...
    
    // MARK: - 表格插入
    case insertTable(columns: Int, rows: Int)
    case showTableInsertDialog
    
    // MARK: - 图片/附件插入
    case insertImage(URL)
    case insertAttachment(URL)
    case showImagePicker
    case showAttachmentPicker
    case imageInserted(imageId: String, relativePath: String)
    case attachmentInserted(fileName: String, relativePath: String)
    case imageInsertFailed(Error)
    case attachmentInsertFailed(Error)
    
    // MARK: - 扩展格式
    case insertBlockquote
    case insertHorizontalRule
    case formatStrikethrough
    case formatUnderline  // P2
    case insertFootnote  // P2
    case insertInlineMath  // P2
    case insertBlockMath  // P2
}
```

### 4.2 State 扩展

```swift
struct State: Equatable {
    // ... 现有 State ...
    
    // MARK: - 插入对话框状态
    var showTableInsertDialog: Bool = false
    var showImagePicker: Bool = false
    var showAttachmentPicker: Bool = false
    
    // MARK: - 插入状态
    var isInsertingImage: Bool = false
    var isInsertingAttachment: Bool = false
    var insertError: String? = nil
}
```

### 4.3 Reducer 实现

```swift
case .insertTable(let columns, let rows):
    guard state.note != nil else { return .none }
    let result = MarkdownFormatter.insertTable(
        text: state.content,
        selection: state.selectionRange,
        columns: columns,
        rows: rows
    )
    state.content = result.newText
    state.selectionRange = result.newSelection
    return .send(.manualSave)

case .insertImage(let url):
    guard state.note != nil else { return .none }
    state.isInsertingImage = true
    return .run { [url] send in
        // 1. 复制文件到 assets 目录
        // 2. 生成相对路径
        // 3. 插入 Markdown 语法
        let result = try await imageManager.saveImage(
            from: url,
            to: noteAssetsDirectory
        )
        await send(.imageInserted(
            imageId: result.id,
            relativePath: result.relativePath
        ))
    } catch: { error, send in
        await send(.imageInsertFailed(error))
    }

case .imageInserted(let imageId, let relativePath):
    state.isInsertingImage = false
    let result = MarkdownFormatter.insertImage(
        text: state.content,
        selection: state.selectionRange,
        altText: "图片",
        imagePath: relativePath
    )
    state.content = result.newText
    state.selectionRange = result.newSelection
    return .send(.manualSave)
```

---

## 5. UI/UX 设计

### 5.1 工具栏布局

#### 5.1.1 当前布局

```
[格式组] | [标题] | [列表组] | [插入组] | [更多] ... [视图切换]
```

#### 5.1.2 扩展后布局

```
[格式组] | [标题] | [列表组] | [插入组] | [区块组] | [更多] ... [视图切换]
```

**响应式布局**：
- **宽屏（>800pt）**：显示所有按钮组
- **中屏（600-800pt）**：收起区块组到"更多"菜单
- **窄屏（<600pt）**：只显示核心按钮，其他收起到"更多"菜单

### 5.2 表格插入 UI

#### 5.2.1 表格菜单设计

```swift
Menu {
    Section("常用尺寸") {
        Button("2x3 表格", systemImage: "tablecells") {
            store.send(.insertTable(columns: 2, rows: 3))
        }
        Button("3x4 表格", systemImage: "tablecells") {
            store.send(.insertTable(columns: 3, rows: 4))
        }
        Button("4x5 表格", systemImage: "tablecells") {
            store.send(.insertTable(columns: 4, rows: 5))
        }
    }
    
    Divider()
    
    Button("自定义...", systemImage: "slider.horizontal.3") {
        store.send(.showTableInsertDialog)
    }
} label: {
    Label("表格", systemImage: "tablecells")
        .labelStyle(.iconOnly)
        .frame(width: 32, height: 32)
}
```

#### 5.2.2 表格插入对话框（可选）

```swift
struct TableInsertDialog: View {
    @Binding var columns: Int
    @Binding var rows: Int
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("插入表格")
                .font(.headline)
            
            HStack {
                Text("列数:")
                Stepper("\(columns)", value: $columns, in: 1...10)
            }
            
            HStack {
                Text("行数:")
                Stepper("\(rows)", value: $rows, in: 1...20)
            }
            
            HStack {
                Button("取消", role: .cancel, action: onCancel)
                Button("插入", action: onConfirm)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
```

### 5.3 图片/附件插入 UI

#### 5.3.1 按钮设计

```swift
// 图片按钮
ToolbarButton(
    title: "插入图片",
    icon: "photo",
    shortcut: "⌘⇧I",
    isActive: false,
    isEnabled: store.isToolbarEnabled
) {
    store.send(.showImagePicker)
}

// 附件按钮（在"更多"菜单中）
Button("插入附件", systemImage: "paperclip") {
    store.send(.showAttachmentPicker)
}
.keyboardShortcut("a", modifiers: [.command, .shift])
```

#### 5.3.2 文件选择器

使用 `NSOpenPanel` 选择文件：

```swift
func showImagePicker() {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.image]
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    
    if panel.runModal() == .OK {
        if let url = panel.url {
            store.send(.insertImage(url))
        }
    }
}
```

### 5.4 区块按钮组设计

```swift
struct BlockButtonGroup: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ControlGroup {
                ToolbarButton(
                    title: "区块引用",
                    icon: "quote.opening",
                    shortcut: "⌘⇧Q",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertBlockquote)
                }
                
                ToolbarButton(
                    title: "分隔线",
                    icon: "minus",
                    shortcut: "⌘⇧-",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertHorizontalRule)
                }
            }
        }
    }
}
```

---

## 6. 开发计划

### 6.1 阶段划分

#### 阶段 1：核心功能（P0）- 3-4 天

**目标**：实现表格和图片/附件插入功能

**任务**：
1. ✅ 扩展 `EditorFeature.Action` 和 `State`
2. ✅ 实现 `MarkdownFormatter.insertTable()`
3. ✅ 实现表格插入 UI（菜单）
4. ✅ 实现图片插入功能（文件选择、保存、Markdown 生成）
5. ✅ 实现附件插入功能
6. ✅ 扩展 `ImageManager` 服务
7. ✅ 测试文件管理和路径生成

**验收标准**：
- 可以插入 2x3、3x4、4x5 表格
- 可以插入图片并生成正确的 Markdown 语法
- 可以插入附件并生成正确的链接
- 文件正确保存到笔记目录

#### 阶段 2：重要功能（P1）- 2-3 天

**目标**：实现区块引用、分隔线、删除线

**任务**：
1. ✅ 实现 `insertBlockquote` Action 和 Reducer
2. ✅ 实现 `insertHorizontalRule` Action 和 Reducer
3. ✅ 实现 `formatStrikethrough` Action 和 Reducer
4. ✅ 创建 `BlockButtonGroup` 组件
5. ✅ 更新工具栏布局
6. ✅ 测试格式功能

**验收标准**：
- 所有 P1 功能正常工作
- 格式检测正确（删除线激活状态）

#### 阶段 3：增强功能（P2）- 2-3 天

**目标**：实现下划线、脚注、数学公式

**任务**：
1. ✅ 实现下划线功能
2. ✅ 实现脚注功能
3. ✅ 实现行内公式和行间公式
4. ✅ 创建 `MathButtonGroup` 组件
5. ✅ 测试数学公式渲染

**验收标准**：
- 所有 P2 功能正常工作
- 数学公式在预览中正确渲染

### 6.2 总时间估算

- **阶段 1（P0）**：3-4 天
- **阶段 2（P1）**：2-3 天
- **阶段 3（P2）**：2-3 天
- **测试与优化**：1-2 天
- **总计**：8-12 天

---

## 7. 测试计划

### 7.1 功能测试

#### 7.1.1 表格插入测试

| 测试项 | 测试步骤 | 预期结果 |
|-------|---------|---------|
| 插入 2x3 表格 | 1. 点击表格按钮<br>2. 选择 2x3 | 插入 2 列 3 行表格 |
| 插入 3x4 表格 | 1. 点击表格按钮<br>2. 选择 3x4 | 插入 3 列 4 行表格 |
| 光标定位 | 插入表格后 | 光标在第一个单元格 |

#### 7.1.2 图片插入测试

| 测试项 | 测试步骤 | 预期结果 |
|-------|---------|---------|
| 选择图片 | 1. 点击图片按钮<br>2. 选择图片文件 | 图片保存到 assets 目录 |
| Markdown 生成 | 插入图片后 | 生成 `![alt](path)` 语法 |
| 相对路径 | 检查生成的路径 | 使用相对路径 |

#### 7.1.3 格式功能测试

| 测试项 | 测试步骤 | 预期结果 |
|-------|---------|---------|
| 区块引用 | 1. 选中文本<br>2. 点击区块引用 | 文本被 `> ` 包裹 |
| 分隔线 | 点击分隔线按钮 | 插入 `---` |
| 删除线 | 1. 选中文本<br>2. 点击删除线 | 文本被 `~~` 包裹 |

### 7.2 边界情况测试

- ✅ 无选中文本时插入格式
- ✅ 空笔记时插入内容
- ✅ 大文件插入（>10MB）
- ✅ 同名文件处理
- ✅ 无效文件格式处理

### 7.3 性能测试

- ✅ 插入大表格（10x20）的性能
- ✅ 插入大图片的性能
- ✅ 批量插入文件的性能

---

## 8. 技术细节

### 8.1 MarkdownFormatter 扩展

```swift
extension MarkdownFormatter {
    /// 插入表格
    static func insertTable(
        text: String,
        selection: NSRange,
        columns: Int,
        rows: Int
    ) -> FormatResult {
        // 生成表头
        let header = (0..<columns).map { "列\($0 + 1)" }.joined(separator: " | ")
        let separator = (0..<columns).map { "-----" }.joined(separator: " | ")
        
        // 生成表格行
        var tableRows: [String] = []
        for _ in 0..<rows {
            let row = (0..<columns).map { _ in "单元格" }.joined(separator: " | ")
            tableRows.append("| \(row) |")
        }
        
        // 组合表格
        let table = """
        | \(header) |
        | \(separator) |
        \(tableRows.joined(separator: "\n"))
        """
        
        // 插入到文本
        return insertText(
            text: text,
            selection: selection,
            insertion: "\n\(table)\n"
        )
    }
    
    /// 插入图片
    static func insertImage(
        text: String,
        selection: NSRange,
        altText: String,
        imagePath: String
    ) -> FormatResult {
        let markdown = "![\(altText)](\(imagePath))"
        return insertText(
            text: text,
            selection: selection,
            insertion: markdown
        )
    }
    
    /// 插入区块引用
    static func insertBlockquote(
        text: String,
        selection: NSRange
    ) -> FormatResult {
        return formatLineStart(
            text: text,
            selection: selection,
            prefix: "> ",
            replaceExistingPrefixes: []
        )
    }
    
    /// 插入分隔线
    static func insertHorizontalRule(
        text: String,
        selection: NSRange
    ) -> FormatResult {
        return insertText(
            text: text,
            selection: selection,
            insertion: "\n---\n"
        )
    }
    
    /// 格式化删除线
    static func formatStrikethrough(
        text: String,
        selection: NSRange
    ) -> FormatResult {
        return formatWrap(
            text: text,
            selection: selection,
            prefix: "~~",
            suffix: "~~"
        )
    }
}
```

### 8.2 文件管理服务扩展

```swift
extension ImageManager {
    /// 保存图片到笔记资源目录
    func saveImage(
        from sourceURL: URL,
        to noteDirectory: URL
    ) async throws -> (id: String, relativePath: String) {
        // 1. 创建 assets 目录
        let assetsDir = noteDirectory.appendingPathComponent("assets")
        try FileManager.default.createDirectory(
            at: assetsDir,
            withIntermediateDirectories: true
        )
        
        // 2. 生成文件名
        let imageId = UUID().uuidString
        let fileExtension = sourceURL.pathExtension
        let fileName = "\(imageId).\(fileExtension)"
        let destinationURL = assetsDir.appendingPathComponent(fileName)
        
        // 3. 复制文件
        try FileManager.default.copyItem(
            at: sourceURL,
            to: destinationURL
        )
        
        // 4. 返回相对路径
        let relativePath = "assets/\(fileName)"
        return (imageId, relativePath)
    }
}
```

---

## 9. 后续优化

### 9.1 表格编辑增强

- 支持表格单元格编辑
- 支持表格行列增删
- 支持表格对齐方式设置

### 9.2 图片管理增强

- 图片预览功能
- 图片尺寸调整
- 图片裁剪功能
- 图片压缩优化

### 9.3 拖拽支持

- 拖拽图片到编辑器
- 拖拽文件到编辑器
- 拖拽文本到编辑器

---

## 10. 参考资源

- [Markdown 语法规范](https://daringfireball.net/projects/markdown/syntax)
- [CommonMark 规范](https://commonmark.org/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [The Composable Architecture Documentation](https://pointfreeco.github.io/swift-composable-architecture/)

---

**文档状态**: ✅ 已完成，待评审


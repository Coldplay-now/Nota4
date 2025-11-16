# Nota4 编辑器右键菜单 PRD

> **版本**: v1.0.0  
> **创建日期**: 2025-11-16  
> **文档状态**: 设计中 🚧  
> **参考**: Nota2 右键菜单优化分析

---

## 📋 目录

1. [产品概述](#1-产品概述)
2. [设计原则](#2-设计原则)
3. [功能需求](#3-功能需求)
4. [菜单结构](#4-菜单结构)
5. [交互设计](#5-交互设计)
6. [技术实现](#6-技术实现)
7. [开发计划](#7-开发计划)

---

## 1. 产品概述

### 1.1 背景

Nota4 作为一款现代化的 Markdown 笔记应用，需要为编辑器提供便捷的右键菜单功能，提升用户的编辑效率和体验。

### 1.2 目标

- **提升编辑效率**：快速访问常用 Markdown 格式和编辑操作
- **保持简洁性**：避免菜单项过多，保持菜单结构清晰
- **符合习惯**：遵循 macOS 原生应用的交互习惯
- **易于扩展**：架构设计支持后续功能迭代

### 1.3 参考设计

基于 **Nota2 右键菜单优化分析**，采用以下优化方案：
- ✅ **扁平化菜单结构**：减少嵌套层级，提升操作效率
- ✅ **精简菜单项**：只保留高频使用的功能
- ✅ **优雅的图标**：使用 SF Symbols 提升视觉效果
- ✅ **智能状态验证**：自动启用/禁用菜单项

---

## 2. 设计原则

### 2.1 简洁优先 (Simplicity First)

**原则**：菜单项数量控制在 **12-15 项**以内

**理由**：
- ✅ 用户能够快速扫描和定位目标功能
- ✅ 避免菜单过长导致的视觉疲劳
- ✅ 减少性能开销（创建菜单对象）

### 2.2 扁平化结构 (Flat Structure)

**原则**：避免深层嵌套（最多 **2 层**）

**理由**：
- ✅ 减少用户点击次数（Nota2 为 3 层，用户需要多次悬停）
- ✅ 更快的操作响应
- ✅ 更符合 macOS 标准应用的菜单设计

**对比**：

| 设计方案 | Nota2 | Nota4 |
|---------|-------|-------|
| **嵌套层级** | 3 层 | 2 层 |
| **标题插入** | 右键 → 插入 → 标题 → H1/H2/H3/H4 | 右键 → 标题 1/2/3 |
| **列表插入** | 右键 → 插入 → 列表 → 无序/有序/任务 | 右键 → 无序列表/有序列表/任务列表 |
| **用户操作** | 3 次悬停/点击 | 1 次点击 |

### 2.3 高频功能优先 (High-Frequency First)

**原则**：优先展示用户使用频率最高的功能

**高频功能排序**（基于 Markdown 使用习惯）：

1. **标准编辑**：剪切、复制、粘贴、全选（P0）
2. **文本格式**：加粗、斜体、行内代码（P0）
3. **标题**：H1、H2、H3（P0）
4. **列表**：无序列表、有序列表、任务列表（P1）
5. **插入**：链接、代码块（P1）
6. **笔记操作**：切换星标、在预览中打开（P1）

**低频功能考虑移除或延后**：
- ⚠️ 数学公式（行内/块）：使用频率较低，可延后实现
- ⚠️ 标题 4/5/6：H4 及以下使用频率低

### 2.4 macOS 原生体验 (Native Experience)

**原则**：遵循 macOS Human Interface Guidelines

**设计要求**：
- ✅ 使用 SF Symbols 图标
- ✅ 支持键盘快捷键（显示在菜单右侧）
- ✅ 动态启用/禁用状态（如：撤销/重做）
- ✅ 分隔线合理使用（功能分组）
- ✅ 支持辅助功能（VoiceOver）

---

## 3. 功能需求

### 3.1 菜单项清单

| 分类 | 菜单项 | 快捷键 | 图标 | 优先级 | 说明 |
|-----|--------|--------|------|--------|------|
| **标准编辑** | 撤销 | ⌘Z | `arrow.uturn.backward` | P0 | 动态启用状态 |
| | 重做 | ⇧⌘Z | `arrow.uturn.forward` | P0 | 动态启用状态 |
| | --- | --- | --- | --- | 分隔线 |
| | 剪切 | ⌘X | `scissors` | P0 | 系统标准操作 |
| | 复制 | ⌘C | `doc.on.doc` | P0 | 系统标准操作 |
| | 粘贴 | ⌘V | `doc.on.clipboard` | P0 | 粘贴为纯文本 |
| | 全选 | ⌘A | `selection.pin.in.out` | P0 | 系统标准操作 |
| | --- | --- | --- | --- | 分隔线 |
| **Markdown 格式** | 加粗 | ⌘B | `bold` | P0 | 包裹选中文本 |
| | 斜体 | ⌘I | `italic` | P0 | 包裹选中文本 |
| | 行内代码 | ⌘E | `chevron.left.forwardslash.chevron.right` | P0 | 包裹选中文本 |
| | --- | --- | --- | --- | 分隔线 |
| **标题** | 标题 1 | ⌘1 | `h1.square` | P0 | 行首插入 `#` |
| | 标题 2 | ⌘2 | `h2.square` | P0 | 行首插入 `##` |
| | 标题 3 | ⌘3 | `h3.square` | P0 | 行首插入 `###` |
| | --- | --- | --- | --- | 分隔线 |
| **列表** | 无序列表 | ⌘L | `list.bullet` | P1 | 行首插入 `-` |
| | 有序列表 | ⇧⌘L | `list.number` | P1 | 行首插入 `1.` |
| | 任务列表 | ⌥⌘L | `checklist` | P1 | 行首插入 `- [ ]` |
| | --- | --- | --- | --- | 分隔线 |
| **插入** | 链接 | ⌘K | `link` | P1 | 包裹选中文本 |
| | 代码块 | ⇧⌘K | `curlybraces` | P1 | 多行代码块 |
| | --- | --- | --- | --- | 分隔线 |
| **笔记操作** | 切换星标 | ⌘D | `star` | P1 | 收藏/取消收藏 |

**总计**：20 项（含 6 个分隔线），实际功能项 **14 个**

### 3.2 功能优先级

#### P0 - 核心功能（必须实现）⭐

- 标准编辑操作（7 项）
- Markdown 格式（3 项）
- 标题（3 项）

**小计**：13 项

#### P1 - 重要功能（优先实现）

- 列表（3 项）
- 插入（2 项）
- 笔记操作（1 项）

**小计**：6 项

#### P2 - 扩展功能（延后实现）

- 数学公式（行内/块）
- 表格插入
- 图片插入
- 分隔线插入

### 3.3 移除的功能（相比 Nota2）

| 功能 | 移除原因 |
|-----|---------|
| **删除操作** | 用户可使用 Delete 键或顶部按钮 |
| **查找功能** | 已有独立的查找面板（⌘F） |
| **在预览中打开** | Nota4 采用实时预览，无需单独操作 |
| **标题 4** | 使用频率极低 |
| **数学公式** | 延后到 P2 实现 |

---

## 4. 菜单结构

### 4.1 扁平化结构设计

```
┌──────────────────────────────────┐
│  编辑器右键菜单                    │
├──────────────────────────────────┤
│  ↶  撤销                ⌘Z       │
│  ↷  重做                ⇧⌘Z      │
├──────────────────────────────────┤
│  ✂️  剪切                ⌘X       │
│  📄  复制                ⌘C       │
│  📋  粘贴                ⌘V       │
│  ⬚  全选                ⌘A       │
├──────────────────────────────────┤
│  𝐁  加粗                ⌘B       │
│  𝑰  斜体                ⌘I       │
│  <>  行内代码            ⌘E       │
├──────────────────────────────────┤
│  H1  标题 1             ⌘1       │
│  H2  标题 2             ⌘2       │
│  H3  标题 3             ⌘3       │
├──────────────────────────────────┤
│  •  无序列表            ⌘L       │
│  1.  有序列表           ⇧⌘L      │
│  ☑  任务列表            ⌥⌘L      │
├──────────────────────────────────┤
│  🔗  链接                ⌘K       │
│  {}  代码块              ⇧⌘K      │
├──────────────────────────────────┤
│  ⭐  切换星标            ⌘D       │
└──────────────────────────────────┘
```

### 4.2 分组逻辑

| 分组 | 功能 | 分隔线 |
|-----|------|--------|
| **第 1 组** | 撤销、重做 | ✅ |
| **第 2 组** | 标准编辑（剪切、复制、粘贴、全选） | ✅ |
| **第 3 组** | Markdown 格式（加粗、斜体、行内代码） | ✅ |
| **第 4 组** | 标题（H1、H2、H3） | ✅ |
| **第 5 组** | 列表（无序、有序、任务） | ✅ |
| **第 6 组** | 插入（链接、代码块） | ✅ |
| **第 7 组** | 笔记操作（切换星标） | ❌ |

### 4.3 菜单项状态

| 菜单项 | 状态逻辑 |
|--------|---------|
| **撤销** | `undoManager.canUndo` 为 `false` 时禁用 |
| **重做** | `undoManager.canRedo` 为 `false` 时禁用 |
| **剪切** | 无选中文本时禁用 |
| **复制** | 无选中文本时禁用 |
| **粘贴** | 剪贴板无文本时禁用 |
| **全选** | 始终启用 |
| **加粗/斜体/行内代码** | 始终启用（无选中时插入占位符） |
| **标题 1/2/3** | 始终启用 |
| **列表** | 始终启用 |
| **链接** | 始终启用（无选中时插入占位符） |
| **代码块** | 始终启用 |
| **切换星标** | 有笔记时启用，无笔记时禁用 |

---

## 5. 交互设计

### 5.1 触发方式

1. **右键点击编辑器**：显示完整菜单
2. **选中文本后右键**：优先显示格式相关菜单项（加粗、斜体等高亮）
3. **⌃ + 点击**：等同于右键（macOS 标准行为）

### 5.2 菜单行为

#### 5.2.1 包裹选中文本（Wrap Selection）

**适用功能**：加粗、斜体、行内代码、链接

**交互逻辑**：

```
情况 1：有选中文本
  用户选中: "Hello"
  点击"加粗"
  结果: **Hello**

情况 2：无选中文本
  用户未选中
  点击"加粗"
  结果: **粗体文本**（插入占位符，且自动选中）
  
情况 3：选中已格式化文本
  用户选中: "**Hello**"
  点击"加粗"
  结果: Hello（移除格式）
```

#### 5.2.2 行首插入（Insert at Line Start）

**适用功能**：标题 1/2/3、列表

**交互逻辑**：

```
情况 1：光标在行中
  当前行: "This is a line|"（| 表示光标）
  点击"标题 1"
  结果: "# This is a line|"

情况 2：当前行已有前缀
  当前行: "## Heading|"
  点击"标题 1"
  结果: "# Heading|"（替换前缀）
  
情况 3：选中多行
  选中:
    Line 1|
    Line 2|
  点击"无序列表"
  结果:
    - Line 1
    - Line 2
```

#### 5.2.3 插入代码块（Insert Code Block）

**交互逻辑**：

```
情况 1：无选中文本
  点击"代码块"
  结果:
    ```
    代码
    ```
  （光标定位在"代码"处）

情况 2：选中文本
  用户选中: "console.log('hello')"
  点击"代码块"
  结果:
    ```
    console.log('hello')
    ```
```

### 5.3 快捷键设计

#### 5.3.1 快捷键分配原则

1. **系统标准**：优先使用 macOS 系统标准快捷键
2. **一致性**：与主流 Markdown 编辑器保持一致
3. **避免冲突**：不与系统/应用级快捷键冲突

#### 5.3.2 快捷键映射表

| 类别 | 功能 | 快捷键 | 冲突检查 |
|-----|------|--------|---------|
| **编辑** | 撤销 | ⌘Z | ✅ 系统标准 |
| | 重做 | ⇧⌘Z | ✅ 系统标准 |
| | 剪切 | ⌘X | ✅ 系统标准 |
| | 复制 | ⌘C | ✅ 系统标准 |
| | 粘贴 | ⌘V | ✅ 系统标准 |
| | 全选 | ⌘A | ✅ 系统标准 |
| **格式** | 加粗 | ⌘B | ✅ Markdown 标准 |
| | 斜体 | ⌘I | ✅ Markdown 标准 |
| | 行内代码 | ⌘E | ✅ 常见约定 |
| **标题** | 标题 1 | ⌘1 | ✅ 不冲突 |
| | 标题 2 | ⌘2 | ✅ 不冲突 |
| | 标题 3 | ⌘3 | ✅ 不冲突 |
| **列表** | 无序列表 | ⌘L | ✅ 不冲突 |
| | 有序列表 | ⇧⌘L | ✅ 不冲突 |
| | 任务列表 | ⌥⌘L | ✅ 不冲突 |
| **插入** | 链接 | ⌘K | ✅ Markdown 标准 |
| | 代码块 | ⇧⌘K | ✅ 不冲突 |
| **笔记** | 切换星标 | ⌘D | ✅ 不冲突 |

### 5.4 视觉反馈

#### 5.4.1 菜单项高亮

- **悬停**：背景色变为 `Color.accentColor.opacity(0.1)`
- **点击**：短暂高亮（系统默认）
- **已应用格式**：图标右侧显示 `✓`（如：当前行已是标题 2，"标题 2" 显示勾选）

#### 5.4.2 禁用状态

- **文字**：灰色 `Color.secondary`
- **图标**：灰色 `opacity(0.5)`
- **不响应**：点击无效

#### 5.4.3 动画效果

- **菜单展开**：淡入动画（0.15 秒）
- **状态切换**：图标平滑过渡（0.2 秒）

---

## 6. 技术实现

### 6.1 技术栈

| 层次 | 技术 | 说明 |
|-----|------|------|
| **UI 框架** | SwiftUI | 声明式 UI |
| **架构** | TCA (The Composable Architecture) | 状态管理 |
| **菜单实现** | `.contextMenu()` 修饰符 | SwiftUI 原生 |
| **快捷键** | `.keyboardShortcut()` 修饰符 | SwiftUI 原生 |
| **状态验证** | TCA State 计算属性 | 响应式状态 |

### 6.2 架构设计

#### 6.2.1 Feature 结构

```swift
@Reducer
struct EditorContextMenuFeature {
    @ObservableState
    struct State: Equatable {
        var note: Note?
        var selectedText: String = ""
        var cursorPosition: Int = 0
        
        // 菜单项状态（计算属性）
        var canUndo: Bool { /* ... */ }
        var canRedo: Bool { /* ... */ }
        var hasSelection: Bool { !selectedText.isEmpty }
        var canPaste: Bool { /* 检查剪贴板 */ }
        var hasNote: Bool { note != nil }
    }
    
    enum Action {
        // 标准编辑
        case undo
        case redo
        case cut
        case copy
        case paste
        case selectAll
        
        // Markdown 格式
        case formatBold
        case formatItalic
        case formatInlineCode
        
        // 标题
        case insertHeading(level: Int)
        
        // 列表
        case insertList(type: ListType)
        
        // 插入
        case insertLink
        case insertCodeBlock
        
        // 笔记操作
        case toggleStar
    }
    
    enum ListType {
        case unordered
        case ordered
        case task
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // 实现各个 action 的逻辑
            // ...
            }
        }
    }
}
```

#### 6.2.2 View 实现

```swift
struct EditorContextMenuView: View {
    let store: StoreOf<EditorContextMenuFeature>
    
    var body: some View {
        Group {
            // 撤销/重做
            Button("撤销", systemImage: "arrow.uturn.backward") {
                store.send(.undo)
            }
            .keyboardShortcut("z", modifiers: .command)
            .disabled(!store.canUndo)
            
            Button("重做", systemImage: "arrow.uturn.forward") {
                store.send(.redo)
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])
            .disabled(!store.canRedo)
            
            Divider()
            
            // 标准编辑
            Button("剪切", systemImage: "scissors") {
                store.send(.cut)
            }
            .keyboardShortcut("x", modifiers: .command)
            .disabled(!store.hasSelection)
            
            // ... 其他菜单项
            
            Divider()
            
            // Markdown 格式
            Button("加粗", systemImage: "bold") {
                store.send(.formatBold)
            }
            .keyboardShortcut("b", modifiers: .command)
            
            // ... 其他菜单项
        }
    }
}
```

#### 6.2.3 集成到 EditorView

```swift
struct NoteEditorView: View {
    @Bindable var store: StoreOf<EditorFeature>
    
    var body: some View {
        TextEditor(text: $store.content)
            .contextMenu {
                EditorContextMenuView(
                    store: store.scope(
                        state: \.contextMenu,
                        action: \.contextMenu
                    )
                )
            }
    }
}
```

### 6.3 状态管理

#### 6.3.1 撤销/重做状态

**挑战**：SwiftUI 的 `TextEditor` 不直接暴露 `undoManager`

**解决方案**：

```swift
// 方案 A：使用 AppKit 的 NSTextView（推荐）
struct NSTextViewWrapper: NSViewRepresentable {
    @Binding var text: String
    var undoManager: UndoManager?
    
    func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.allowsUndo = true
        // ...
        return NSScrollView(frame: .zero)
    }
    
    // 提供 canUndo/canRedo 查询接口
}

// 方案 B：自行管理撤销栈（复杂度高，不推荐）
```

#### 6.3.2 剪贴板状态

```swift
extension EditorContextMenuFeature.State {
    var canPaste: Bool {
        NSPasteboard.general.string(forType: .string) != nil
    }
}
```

#### 6.3.3 选中文本状态

```swift
// 通过 TextEditor 的 selectedTextRange 获取
// 需要使用 NSTextView wrapper 实现
```

### 6.4 Markdown 操作实现

#### 6.4.1 包裹选中文本

```swift
func wrapSelection(prefix: String, suffix: String, placeholder: String) -> Effect<Action> {
    .run { [state] send in
        let selectedText = state.selectedText
        let newText = selectedText.isEmpty 
            ? "\(prefix)\(placeholder)\(suffix)" 
            : "\(prefix)\(selectedText)\(suffix)"
        
        // 插入新文本
        await send(.insertText(newText))
        
        // 如果是占位符，选中它
        if selectedText.isEmpty {
            await send(.selectRange(NSRange(
                location: state.cursorPosition + prefix.count,
                length: placeholder.count
            )))
        }
    }
}
```

#### 6.4.2 行首插入

```swift
func insertAtLineStart(text: String, placeholder: String) -> Effect<Action> {
    .run { [state] send in
        // 获取当前行
        let currentLine = state.getCurrentLine()
        
        // 检查是否已有前缀（标题、列表）
        if let existingPrefix = detectPrefix(currentLine) {
            // 替换前缀
            await send(.replacePrefix(from: existingPrefix, to: text))
        } else {
            // 插入新前缀
            await send(.insertAtLineStart(text))
        }
    }
}
```

### 6.5 性能优化

#### 6.5.1 菜单创建

- ✅ **SwiftUI 优势**：`.contextMenu()` 是延迟创建，只在右键时才构建视图树
- ✅ **避免重复计算**：使用 `@ObservableState` 的计算属性缓存状态
- ✅ **图标缓存**：SF Symbols 由系统自动缓存

#### 6.5.2 状态验证

```swift
// ❌ 不推荐：每次都查询
var canUndo: Bool {
    textView.undoManager?.canUndo ?? false
}

// ✅ 推荐：缓存状态，只在必要时更新
@ObservableState
struct State {
    var canUndo: Bool = false
    var canRedo: Bool = false
    
    mutating func updateUndoState() {
        // 在文本改变时调用
        self.canUndo = /* ... */
        self.canRedo = /* ... */
    }
}
```

---

## 7. 开发计划

### 7.1 开发阶段

#### 阶段 1: 核心功能（P0）⭐

**任务清单**：

1. ✅ 创建 `EditorContextMenuFeature.swift`
2. ✅ 实现标准编辑操作（剪切、复制、粘贴、全选）
3. ✅ 实现撤销/重做（含状态验证）
4. ✅ 实现 Markdown 格式（加粗、斜体、行内代码）
5. ✅ 实现标题插入（H1/H2/H3）
6. ✅ 集成到 `NoteEditorView`
7. ✅ 测试所有 P0 功能

**预计时间**：4-5 小时

**验收标准**：
- 所有 P0 菜单项可正常工作
- 快捷键生效
- 状态验证正确（禁用/启用）
- 无明显性能问题

#### 阶段 2: 扩展功能（P1）

**任务清单**：

1. ✅ 实现列表插入（无序、有序、任务）
2. ✅ 实现链接插入
3. ✅ 实现代码块插入
4. ✅ 实现切换星标
5. ✅ 测试所有 P1 功能

**预计时间**：2-3 小时

**验收标准**：
- 所有 P1 菜单项可正常工作
- 多行操作正确（列表）
- 占位符逻辑正确

#### 阶段 3: 优化与完善

**任务清单**：

1. ✅ 优化菜单响应速度
2. ✅ 完善错误处理
3. ✅ 添加单元测试
4. ✅ 添加 UI 测试（关键路径）
5. ✅ 撰写技术文档
6. ✅ 用户测试与反馈收集

**预计时间**：2-3 小时

**验收标准**：
- 测试覆盖率 ≥ 80%
- 用户测试通过
- 文档完整

#### 阶段 4: 扩展功能（P2，可选）

**任务清单**：

1. ⚠️ 实现数学公式插入
2. ⚠️ 实现表格插入
3. ⚠️ 实现图片插入
4. ⚠️ 实现分隔线插入

**预计时间**：按需评估

### 7.2 总体时间估算

| 阶段 | 预计时间 | 优先级 |
|-----|---------|--------|
| **阶段 1**（P0） | 4-5 小时 | ⭐⭐⭐ |
| **阶段 2**（P1） | 2-3 小时 | ⭐⭐ |
| **阶段 3**（优化） | 2-3 小时 | ⭐⭐ |
| **阶段 4**（P2） | 按需 | ⭐ |

**总计**：8-11 小时（不含 P2）

### 7.3 里程碑

| 里程碑 | 日期 | 交付物 |
|--------|------|--------|
| **M1: 核心功能完成** | 待定 | P0 功能可用，基础测试通过 |
| **M2: 扩展功能完成** | 待定 | P1 功能可用，完整测试通过 |
| **M3: 正式发布** | 待定 | 优化完成，文档完整 |

---

## 8. 测试计划

### 8.1 单元测试

**测试范围**：`EditorContextMenuFeature` 的所有 Action

**测试用例**：

```swift
final class EditorContextMenuFeatureTests: XCTestCase {
    @MainActor
    func testFormatBold_WithSelection() async {
        let store = TestStore(initialState: EditorContextMenuFeature.State(
            selectedText: "Hello"
        )) {
            EditorContextMenuFeature()
        }
        
        await store.send(.formatBold)
        
        await store.receive(\.insertText) {
            $0.content = "**Hello**"
        }
    }
    
    @MainActor
    func testFormatBold_WithoutSelection() async {
        let store = TestStore(initialState: EditorContextMenuFeature.State(
            selectedText: ""
        )) {
            EditorContextMenuFeature()
        }
        
        await store.send(.formatBold)
        
        await store.receive(\.insertText) {
            $0.content = "**粗体文本**"
        }
        
        await store.receive(\.selectRange) {
            $0.selectedRange = NSRange(location: 2, length: 4)
        }
    }
    
    // ... 其他测试用例
}
```

### 8.2 UI 测试

**测试用例**：

1. ✅ 右键显示菜单
2. ✅ 点击"加粗"后文本正确格式化
3. ✅ 撤销按钮在无撤销操作时禁用
4. ✅ 快捷键 ⌘B 正确触发加粗

### 8.3 用户测试

**测试场景**：

1. ✅ 新用户首次使用右键菜单
2. ✅ 频繁使用 Markdown 格式的用户
3. ✅ 使用键盘快捷键的用户

**收集指标**：

- ✅ 菜单项是否容易找到？
- ✅ 快捷键是否符合预期？
- ✅ 是否有缺失的功能？
- ✅ 菜单响应速度如何？

---

## 9. 风险与挑战

### 9.1 技术风险

| 风险 | 影响 | 缓解措施 |
|-----|------|---------|
| **SwiftUI TextEditor 限制** | 高 | 使用 NSTextView wrapper |
| **撤销/重做状态管理** | 中 | 与 NSTextView 的 UndoManager 集成 |
| **剪贴板权限** | 低 | 请求用户授权 |
| **性能问题** | 低 | SwiftUI 延迟创建，性能良好 |

### 9.2 用户体验风险

| 风险 | 影响 | 缓解措施 |
|-----|------|---------|
| **菜单项过多** | 中 | 严格控制在 15 项以内 |
| **快捷键冲突** | 中 | 遵循 macOS 标准，测试验证 |
| **功能不够** | 低 | P2 功能可后续迭代 |

---

## 10. 成功指标

### 10.1 功能指标

- ✅ 所有 P0 功能正常工作（100%）
- ✅ 所有 P1 功能正常工作（100%）
- ✅ 测试覆盖率 ≥ 80%

### 10.2 性能指标

- ✅ 菜单展开时间 < 100ms
- ✅ 菜单项点击响应 < 50ms
- ✅ 无明显卡顿或延迟

### 10.3 用户体验指标

- ✅ 用户满意度 ≥ 4.0/5.0
- ✅ 功能发现率 ≥ 80%（用户能找到需要的功能）
- ✅ 快捷键使用率 ≥ 30%（活跃用户）

---

## 11. 附录

### 11.1 参考资料

- [macOS Human Interface Guidelines - Menus](https://developer.apple.com/design/human-interface-guidelines/menus)
- [SwiftUI ContextMenu Documentation](https://developer.apple.com/documentation/swiftui/view/contextmenu(menuitems:))
- [The Composable Architecture Documentation](https://pointfreeco.github.io/swift-composable-architecture/)
- [Nota2 右键菜单优化分析](../../../Nota2/docs/CONTEXT_MENU_OPTIMIZATION.md)

### 11.2 快捷键一览表

| 分类 | 功能 | macOS | Nota4 |
|-----|------|-------|-------|
| **标准编辑** | 撤销 | ⌘Z | ⌘Z |
| | 重做 | ⇧⌘Z | ⇧⌘Z |
| | 剪切 | ⌘X | ⌘X |
| | 复制 | ⌘C | ⌘C |
| | 粘贴 | ⌘V | ⌘V |
| | 全选 | ⌘A | ⌘A |
| **Markdown** | 加粗 | - | ⌘B |
| | 斜体 | - | ⌘I |
| | 行内代码 | - | ⌘E |
| **标题** | H1 | - | ⌘1 |
| | H2 | - | ⌘2 |
| | H3 | - | ⌘3 |
| **列表** | 无序列表 | - | ⌘L |
| | 有序列表 | - | ⇧⌘L |
| | 任务列表 | - | ⌥⌘L |
| **插入** | 链接 | - | ⌘K |
| | 代码块 | - | ⇧⌘K |
| **笔记** | 切换星标 | - | ⌘D |

### 11.3 Nota2 vs Nota4 对比

| 维度 | Nota2 | Nota4 |
|-----|-------|-------|
| **技术栈** | AppKit + NSMenu | SwiftUI + TCA |
| **菜单层级** | 3 层 | 2 层（扁平化） |
| **菜单项数量** | ~20 项 | ~14 项（精简） |
| **代码行数** | ~240 行 | ~150 行（预估） |
| **@objc 方法** | 19 个 | 0 个（SwiftUI） |
| **状态验证** | 手动 | 响应式（TCA） |
| **性能** | 每次右键创建 | 延迟创建（SwiftUI） |
| **扩展性** | 中 | 高（声明式） |

---

**最后更新**: 2025-11-16  
**下一步**: 等待批准后开始阶段 1 开发


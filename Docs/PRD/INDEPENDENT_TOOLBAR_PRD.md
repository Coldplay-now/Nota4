# Nota4 独立工具栏优化 PRD

> **版本**: v2.0.0  
> **创建日期**: 2025-11-17  
> **文档状态**: 设计中 🚧  
> **架构**: SwiftUI 4.0 + TCA (The Composable Architecture)  
> **布局方案**: 方案 A - 独立工具栏

---

## 📋 目录

1. [产品概述](#1-产品概述)
2. [设计目标](#2-设计目标)
3. [功能需求](#3-功能需求)
4. [技术架构](#4-技术架构)
5. [TCA 状态管理设计](#5-tca-状态管理设计)
6. [视觉设计规范](#6-视觉设计规范)
7. [交互设计](#7-交互设计)
8. [响应式布局](#8-响应式布局)
9. [代码规范](#9-代码规范)
10. [开发计划](#10-开发计划)
11. [测试计划](#11-测试计划)

---

## 1. 产品概述

### 1.1 背景与问题

**当前状态**：
- ✅ 工具栏已实现，但位于系统标题栏区域（`.toolbar` modifier）
- ✅ 所有格式化功能已实现（加粗、斜体、标题、列表等）
- ✅ 使用 TCA 进行状态管理
- ❌ 工具栏与窗口控制按钮混在一起，视觉混乱
- ❌ 按钮点击区域小（~20pt），容易误触
- ❌ 视图模式切换占用空间大（200pt）
- ❌ 工具栏在系统标题栏，不够独立和直观

**用户痛点**：
1. **视觉混乱**：工具栏与窗口控制按钮（红绿灯）在同一区域
2. **操作不便**：按钮太小，点击精度要求高
3. **空间浪费**：视图模式切换占用过多空间
4. **可发现性差**：工具栏隐藏在标题栏，不够明显

### 1.2 解决方案

**布局方案 A：独立工具栏**

将工具栏从系统标题栏移出，在编辑器内容区域顶部创建独立的工具栏区域：

```
┌─────────────────────────────────────────────────────────────┐
│  ●○○  Nota4                                          ⚙️       │ ← 系统标题栏（简洁）
├─────────────────────────────────────────────────────────────┤
│  📂分类    │  📝笔记列表(280)    │  ┌───────────────────────┐ │
│            │                     │  │  我的笔记标题    ⭐ 🗑️   │ │
│  📌全部    │  ○ 第一篇笔记       │  ├───────────────────────┤ │
│  ⭐星标   │  ○ 第二篇笔记       │  │ ╔═══════════════════╗ │ │
│  🗑️废纸篓 │  ○ 第三篇笔记       │  │ ║ 🅱️ 🅸 📝│H₁▼│≡①│🔗{}│⊞⊟⊞║ │ │ ← 独立工具栏
│            │  ○ 第四篇笔记       │  │ ╚═══════════════════╝ │ │
│            │  ○ 第五篇笔记       │  │  ───────────────────  │ │
│            │                     │  │                       │ │
│            │                     │  │  正文内容区域...       │ │
│            │                     │  │                       │ │
│            │                     │  └───────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  📊 共 125 篇笔记    第 5 行: 12 列 · 45 行 · 1,234 字 · 已保存 │ ← 状态栏
└─────────────────────────────────────────────────────────────┘
```

**核心改进**：
- ✅ 工具栏独立区域，视觉清晰
- ✅ 按钮尺寸 32x32pt，提升可点击性
- ✅ 视图模式切换紧凑化（~100pt）
- ✅ 与内容区域分离，避免混淆

---

## 2. 设计目标

### 2.1 核心目标

1. **提升可用性**：按钮点击区域从 ~20pt 提升到 32x32pt
2. **改善视觉层级**：工具栏与内容区域清晰分离
3. **优化空间利用**：视图模式切换从 200pt 缩减到 ~100pt
4. **保持一致性**：遵循 macOS HIG 和 TCA 架构规范

### 2.2 设计原则

1. **TCA 优先**：所有状态变更通过 Action 触发，遵循单向数据流
2. **SwiftUI 原生**：使用原生组件，避免过度自定义
3. **响应式设计**：根据可用宽度自适应布局
4. **可访问性**：支持键盘导航和 VoiceOver

---

## 3. 功能需求

### 3.1 工具栏布局

#### 3.1.1 工具栏位置

- **位置**：编辑器内容区域顶部（标题栏下方）
- **高度**：48pt（固定）
- **背景**：`Color(nsColor: .controlBackgroundColor)`
- **边框**：底部 0.5pt 分隔线

#### 3.1.2 工具栏内容（从左到右）

| 组件 | 图标 | 快捷键 | 说明 |
|-----|------|--------|------|
| **格式组** | | | |
| 加粗 | `bold` | ⌘B | 文本加粗 |
| 斜体 | `italic` | ⌘I | 文本斜体 |
| 行内代码 | `chevron.left.forwardslash.chevron.right` | ⌘E | 行内代码 |
| **分隔线** | | | |
| **标题菜单** | `textformat` | - | 下拉菜单（H1-H6） |
| **分隔线** | | | |
| **列表组** | | | |
| 无序列表 | `list.bullet` | ⌘L | 无序列表 |
| 有序列表 | `list.number` | ⇧⌘L | 有序列表 |
| **分隔线** | | | |
| **插入组** | | | |
| 链接 | `link` | ⌘K | 插入链接 |
| 代码块 | `curlybraces` | ⇧⌘K | 代码块 |
| **分隔线** | | | |
| **更多菜单** | `ellipsis.circle` | - | 收起不常用功能 |
| **Spacer** | | | 弹性空间 |
| **视图模式** | `pencil`/`eye`/`rectangle.split.2x1` | - | 紧凑图标组 |

### 3.2 按钮规格

#### 3.2.1 尺寸规范

- **按钮点击区域**：32x32pt（Apple HIG 推荐最小 44x44，toolbar 可适当缩小）
- **图标大小**：16pt（统一）
- **组内间距**：4-6pt
- **组间间距**：12pt
- **工具栏内边距**：16pt（水平），10pt（垂直）

#### 3.2.2 按钮状态

| 状态 | 背景 | 文字颜色 | 说明 |
|-----|------|---------|------|
| **普通** | 透明 | `.primary` | 默认状态 |
| **Hover** | `.controlAccentColor.opacity(0.1)` | `.primary` | 鼠标悬停 |
| **激活** | `.accentColor.opacity(0.15)` | `.accentColor` | 当前已应用格式 |
| **禁用** | 透明 | `.secondary.opacity(0.4)` | 无选中文本或禁用状态 |
| **焦点** | 透明 | `.primary` | 键盘焦点（蓝色边框） |

### 3.3 视图模式切换优化

#### 3.3.1 当前实现

- 使用 `Picker` + `.segmented` 样式
- 宽度：200pt
- 文字标签："仅编辑"、"仅预览"、"分屏"

#### 3.3.2 优化方案

- 使用紧凑图标按钮组
- 宽度：~100pt（节省 50%）
- 图标：`pencil`、`eye`、`rectangle.split.2x1`
- 当前模式高亮显示

---

## 4. 技术架构

### 4.1 组件结构

```
NoteEditorView
└── VStack
    ├── TitleBar (标题栏)
    │   ├── TextField (标题输入)
    │   ├── StarButton (星标)
    │   └── DeleteButton (删除)
    ├── Divider
    ├── EditorContentArea
    │   ├── IndependentToolbar (新增) ← 独立工具栏
    │   │   ├── FormatButtonGroup
    │   │   ├── HeadingMenu
    │   │   ├── ListButtonGroup
    │   │   ├── InsertButtonGroup
    │   │   ├── MoreMenu
    │   │   └── ViewModeControl (优化)
    │   ├── Divider
    │   └── MarkdownTextEditor / MarkdownPreview
    └── StatusBarView
```

### 4.2 文件组织

```
Nota4/Nota4/Features/Editor/
├── EditorFeature.swift          # TCA Reducer（无需修改）
├── NoteEditorView.swift         # 主视图（修改布局）
├── MarkdownToolbar.swift        # 工具栏组件（重构）
│   ├── IndependentToolbar.swift # 新增：独立工具栏容器
│   ├── ToolbarButton.swift      # 重构：按钮组件（32x32pt）
│   ├── FormatButtonGroup.swift  # 格式按钮组
│   ├── HeadingMenu.swift       # 标题菜单
│   ├── ListButtonGroup.swift    # 列表按钮组
│   ├── InsertButtonGroup.swift  # 插入按钮组
│   ├── MoreMenu.swift           # 更多菜单
│   └── ViewModeControl.swift    # 新增：紧凑视图模式切换
└── EditorContextMenu.swift      # 上下文菜单（无需修改）
```

---

## 5. TCA 状态管理设计

### 5.1 状态扩展

#### 5.1.1 EditorFeature.State 扩展

**无需新增状态**：工具栏状态完全由 `EditorFeature.State` 派生，遵循 TCA 的"派生状态"原则。

**现有状态复用**：
```swift
// EditorFeature.State 中已有的状态
var content: String = ""                    // 用于检测格式激活状态
var selectionRange: NSRange = NSRange(...)  // 用于检测选中文本
var viewMode: ViewMode = .editOnly         // 用于视图模式切换
var note: Note?                            // 用于按钮禁用状态
```

#### 5.1.2 派生状态（Computed Properties）

在 `EditorFeature.State` 中添加计算属性，用于工具栏按钮的激活状态：

```swift
extension EditorFeature.State {
    // MARK: - Toolbar State (Derived)
    
    /// 检测当前选中文本是否为加粗格式
    var isBoldActive: Bool {
        guard selectionRange.length > 0 else { return false }
        let selectedText = (content as NSString).substring(with: selectionRange)
        return selectedText.hasPrefix("**") && selectedText.hasSuffix("**")
    }
    
    /// 检测当前选中文本是否为斜体格式
    var isItalicActive: Bool {
        guard selectionRange.length > 0 else { return false }
        let selectedText = (content as NSString).substring(with: selectionRange)
        return selectedText.hasPrefix("*") && selectedText.hasSuffix("*") &&
               !selectedText.hasPrefix("**")  // 排除加粗
    }
    
    /// 检测当前选中文本是否为行内代码
    var isInlineCodeActive: Bool {
        guard selectionRange.length > 0 else { return false }
        let selectedText = (content as NSString).substring(with: selectionRange)
        return selectedText.hasPrefix("`") && selectedText.hasSuffix("`")
    }
    
    /// 检测当前行是否为标题
    var currentHeadingLevel: Int? {
        let lines = content.components(separatedBy: .newlines)
        guard selectionRange.location < content.utf16.count else { return nil }
        
        // 计算当前行号
        let textBeforeSelection = (content as NSString).substring(to: selectionRange.location)
        let lineNumber = textBeforeSelection.components(separatedBy: .newlines).count - 1
        
        guard lineNumber < lines.count else { return nil }
        let currentLine = lines[lineNumber]
        
        // 检测标题级别
        if currentLine.hasPrefix("# ") { return 1 }
        if currentLine.hasPrefix("## ") { return 2 }
        if currentLine.hasPrefix("### ") { return 3 }
        if currentLine.hasPrefix("#### ") { return 4 }
        if currentLine.hasPrefix("##### ") { return 5 }
        if currentLine.hasPrefix("###### ") { return 6 }
        
        return nil
    }
    
    /// 工具栏是否可用（有打开的笔记）
    var isToolbarEnabled: Bool {
        note != nil
    }
}
```

### 5.2 Action 设计

#### 5.2.1 现有 Action 复用

**无需新增 Action**：所有工具栏操作复用现有的 `EditorFeature.Action`：

```swift
// 格式操作（已存在）
case formatBold
case formatItalic
case formatInlineCode

// 标题操作（已存在）
case insertHeading1
case insertHeading2
case insertHeading3
case insertHeading4
case insertHeading5
case insertHeading6

// 列表操作（已存在）
case insertUnorderedList
case insertOrderedList
case insertTaskList

// 插入操作（已存在）
case insertLink
case insertCodeBlock

// 视图模式（已存在）
case viewModeChanged(State.ViewMode)
```

#### 5.2.2 Action 处理流程

所有 Action 的处理逻辑已在 `EditorFeature` Reducer 中实现，遵循 TCA 规范：

```swift
// EditorFeature Reducer 中的处理（已存在）
case .formatBold:
    guard state.note != nil else { return .none }
    let result = MarkdownFormatter.formatWrap(...)
    state.content = result.newText
    state.selectionRange = result.newSelection
    return .send(.manualSave)

case .viewModeChanged(let mode):
    state.viewMode = mode
    // 预览模式切换时触发渲染
    if mode != .editOnly {
        return .send(.preview(.contentChanged(state.content)))
    }
    return .none
```

### 5.3 视图绑定

#### 5.3.1 Store 传递

工具栏组件通过 `StoreOf<EditorFeature>` 访问状态和发送 Action：

```swift
struct IndependentToolbar: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            HStack(spacing: 12) {
                // 格式按钮组
                FormatButtonGroup(store: store)
                
                // ... 其他组件
            }
        }
    }
}
```

#### 5.3.2 状态观察

使用 `WithPerceptionTracking` 确保状态变化时视图自动更新：

```swift
struct ToolbarButton: View {
    let store: StoreOf<EditorFeature>
    let action: EditorFeature.Action
    let isActive: Bool  // 从 store 派生
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(action)
            } label: {
                // ...
            }
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isActive ? Color.accentColor.opacity(0.15) : Color.clear)
            )
        }
    }
}
```

---

## 6. 视觉设计规范

### 6.1 工具栏容器

```swift
struct IndependentToolbar: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        HStack(spacing: 12) {
            // 工具栏内容
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(height: 48)
        .background(Color(nsColor: .controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(nsColor: .separatorColor)),
            alignment: .bottom
        )
    }
}
```

### 6.2 按钮组件

```swift
struct ToolbarButton: View {
    let title: String
    let icon: String
    let shortcut: String
    let isActive: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)
        )
        .foregroundColor(foregroundColor)
        .contentShape(Rectangle())
        .help("\(title) \(shortcut)")
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(.easeInOut(duration: 0.15), value: isActive)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return Color.clear
        }
        if isActive {
            return Color.accentColor.opacity(0.15)
        }
        if isHovered {
            return Color(nsColor: .controlAccentColor).opacity(0.1)
        }
        return Color.clear
    }
    
    private var foregroundColor: Color {
        if !isEnabled {
            return Color.secondary.opacity(0.4)
        }
        if isActive {
            return Color.accentColor
        }
        return Color.primary
    }
}
```

### 6.3 视图模式切换

```swift
struct ViewModeControl: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            HStack(spacing: 0) {
                ForEach(EditorFeature.State.ViewMode.allCases, id: \.self) { mode in
                    Button {
                        store.send(.viewModeChanged(mode))
                    } label: {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14))
                            .frame(width: 32, height: 28)
                    }
                    .buttonStyle(.plain)
                    .background(
                        store.viewMode == mode
                            ? Color.accentColor.opacity(0.15)
                            : Color.clear
                    )
                    .foregroundColor(
                        store.viewMode == mode
                            ? Color.accentColor
                            : Color.primary
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )
        }
    }
}
```

---

## 7. 交互设计

### 7.1 按钮交互

#### 7.1.1 Hover 效果

- **触发**：鼠标悬停
- **效果**：背景色变为浅灰色（10% 透明度）
- **动画**：0.15s 缓动

#### 7.1.2 激活状态

- **触发**：当前选中文本已应用该格式
- **效果**：背景色变为蓝色（15% 透明度），文字变为蓝色
- **更新**：实时检测，无需手动刷新

#### 7.1.3 禁用状态

- **触发**：无打开的笔记或操作不可用
- **效果**：文字变为灰色（40% 透明度），不可点击

### 7.2 标题菜单交互

#### 7.2.1 下拉菜单

- **显示**：点击标题按钮展开
- **内容**：H1-H6 选项
- **快捷操作**：长按或右键显示上下文菜单（可选）

#### 7.2.2 快速切换（可选增强）

- **单击**：循环切换 H1 → H2 → H3 → 正文
- **长按/右键**：显示完整菜单

### 7.3 响应式布局

#### 7.3.1 宽度检测

使用 `GeometryReader` 检测可用宽度：

```swift
struct IndependentToolbar: View {
    @State private var availableWidth: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // 核心工具：始终显示
            CoreToolsGroup(store: store)
            
            // 扩展工具：根据空间显示
            if availableWidth > 400 {
                Divider()
                ListButtonGroup(store: store)
            }
            
            if availableWidth > 550 {
                Divider()
                InsertButtonGroup(store: store)
            }
            
            // 更多菜单
            Divider()
            MoreMenu(store: store, hiddenTools: availableWidth < 400)
            
            Spacer()
            
            // 视图模式切换：始终显示
            ViewModeControl(store: store)
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        availableWidth = geometry.size.width
                    }
                    .onChange(of: geometry.size.width) { _, width in
                        availableWidth = width
                    }
            }
        )
    }
}
```

---

## 8. 响应式布局

### 8.1 布局断点

| 宽度范围 | 显示内容 | 说明 |
|---------|---------|------|
| **>800pt** | 所有工具 + 视图模式 | 完整工具栏 |
| **600-800pt** | 核心工具 + 列表 + 更多菜单 + 视图模式 | 收起插入组 |
| **400-600pt** | 核心工具 + 更多菜单 + 视图模式 | 收起列表和插入 |
| **<400pt** | 核心工具 + 更多菜单 + 视图模式 | 最小布局 |

### 8.2 布局示例

#### 宽屏（>800pt）
```
╔════════════════════════════════════════════════════════════╗
║ 🅱️ 🅸 📝 │ H₁▼ │ ≡ ① ☑️ │ 🔗 {} │ ⋯        [Spacer]   ⊞⊟⊞ ║
╚════════════════════════════════════════════════════════════╝
```

#### 中等宽度（600-800pt）
```
╔════════════════════════════════════════════════════════════╗
║ 🅱️ 🅸 📝 │ H₁▼ │ ≡ ① │ ⋯                [Spacer]   ⊞⊟⊞ ║
╚════════════════════════════════════════════════════════════╝
```

#### 窄屏（<600pt）
```
╔════════════════════════════════════════════════════════════╗
║ 🅱️ 🅸 📝 │ H₁▼ │ ⋯                    [Spacer]   ⊞⊟⊞ ║
╚════════════════════════════════════════════════════════════╝
```

---

## 9. 代码规范

### 9.1 TCA 规范

#### 9.1.1 状态管理

- ✅ **派生状态**：工具栏按钮状态从 `EditorFeature.State` 派生，不新增独立状态
- ✅ **单向数据流**：所有状态变更通过 Action 触发
- ✅ **不可变状态**：State 结构体遵循 `Equatable`，使用 `@ObservableState`

```swift
// ✅ 正确：派生状态
extension EditorFeature.State {
    var isBoldActive: Bool {
        // 从 content 和 selectionRange 计算
    }
}

// ❌ 错误：新增独立状态
struct ToolbarState {
    var isBoldActive: Bool  // ❌ 不应独立管理
}
```

#### 9.1.2 Action 设计

- ✅ **复用现有 Action**：不新增 Action，使用 `EditorFeature.Action`
- ✅ **Action 命名**：使用动词开头（`formatBold`、`insertLink`）
- ✅ **Action 处理**：在 Reducer 中统一处理

```swift
// ✅ 正确：使用现有 Action
Button {
    store.send(.formatBold)
}

// ❌ 错误：新增 Action
enum ToolbarAction {
    case formatBold  // ❌ 不应重复定义
}
```

#### 9.1.3 依赖注入

- ✅ **使用 `@Dependency`**：所有外部依赖通过 TCA 依赖系统注入
- ✅ **不直接访问单例**：避免在 View 中直接访问 `NoteRepository.shared`

```swift
// ✅ 正确：通过 Store 访问
let store: StoreOf<EditorFeature>

// ❌ 错误：直接访问依赖
let repository = NoteRepository.shared  // ❌
```

### 9.2 SwiftUI 规范

#### 9.2.1 视图组织

- ✅ **组件化**：每个功能模块独立为 View 组件
- ✅ **命名规范**：使用描述性名称（`FormatButtonGroup`、`ViewModeControl`）
- ✅ **文件组织**：相关组件放在同一文件或相邻文件

```swift
// ✅ 正确：组件化
struct FormatButtonGroup: View {
    let store: StoreOf<EditorFeature>
    // ...
}

// ❌ 错误：所有代码堆在一个 View
struct IndependentToolbar: View {
    // 所有按钮代码都在这里 ❌
}
```

#### 9.2.2 状态观察

- ✅ **使用 `WithPerceptionTracking`**：确保状态变化时视图更新
- ✅ **避免 `@State` 重复**：不将 Store 状态复制到 `@State`

```swift
// ✅ 正确：使用 WithPerceptionTracking
struct ToolbarButton: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                store.send(.formatBold)
            } label: {
                // ...
            }
        }
    }
}

// ❌ 错误：复制状态到 @State
@State private var isBoldActive: Bool  // ❌
```

### 9.3 代码风格

#### 9.3.1 命名规范

- **类型**：PascalCase（`ToolbarButton`、`FormatButtonGroup`）
- **变量/函数**：camelCase（`isBoldActive`、`formatBold`）
- **常量**：camelCase（`buttonSize`、`toolbarHeight`）

#### 9.3.2 注释规范

```swift
// MARK: - 组件说明
// 使用 MARK 分隔不同功能区域

/// 工具栏按钮组件
/// - Parameters:
///   - title: 按钮标题（用于工具提示）
///   - icon: SF Symbol 图标名称
///   - isActive: 是否激活状态
struct ToolbarButton: View {
    // ...
}
```

#### 9.3.3 代码组织

```swift
struct IndependentToolbar: View {
    // MARK: - Properties
    let store: StoreOf<EditorFeature>
    @State private var availableWidth: CGFloat = 0
    
    // MARK: - Body
    var body: some View {
        // ...
    }
    
    // MARK: - Private Views
    private var coreTools: some View {
        // ...
    }
    
    // MARK: - Private Helpers
    private func calculateLayout() {
        // ...
    }
}
```

---

## 10. 开发计划

### 10.1 阶段划分

#### 阶段 1：基础重构（2-3 天）

**目标**：将工具栏从系统标题栏移到编辑器顶部

**任务**：
1. ✅ 创建 `IndependentToolbar.swift` 组件
2. ✅ 重构 `ToolbarButton` 为 32x32pt
3. ✅ 修改 `NoteEditorView` 布局，添加独立工具栏区域
4. ✅ 移除 `.toolbar` modifier 中的工具栏代码
5. ✅ 测试基础功能

**验收标准**：
- 工具栏显示在编辑器顶部
- 所有按钮功能正常
- 布局不破坏现有功能

#### 阶段 2：视觉优化（1-2 天）

**目标**：优化按钮样式和交互

**任务**：
1. ✅ 实现按钮 hover 效果
2. ✅ 实现按钮激活状态检测和显示
3. ✅ 优化按钮禁用状态
4. ✅ 添加动画效果

**验收标准**：
- 按钮有清晰的 hover 反馈
- 激活状态正确显示
- 动画流畅自然

#### 阶段 3：视图模式优化（1 天）

**目标**：优化视图模式切换组件

**任务**：
1. ✅ 创建 `ViewModeControl` 组件
2. ✅ 实现紧凑图标按钮组
3. ✅ 替换原有的 Segmented Control
4. ✅ 测试视图模式切换

**验收标准**：
- 视图模式切换宽度约 100pt
- 图标清晰，状态明确
- 切换功能正常

#### 阶段 4：响应式布局（1-2 天）

**目标**：实现自适应布局

**任务**：
1. ✅ 实现宽度检测逻辑
2. ✅ 实现动态显示/隐藏组件
3. ✅ 优化"更多"菜单内容
4. ✅ 测试不同窗口宽度

**验收标准**：
- 不同宽度下布局合理
- 不出现布局错乱
- 响应流畅

#### 阶段 5：测试与优化（1 天）

**目标**：全面测试和优化

**任务**：
1. ✅ 功能测试
2. ✅ 性能测试
3. ✅ 可访问性测试
4. ✅ 代码审查和优化

**验收标准**：
- 所有功能正常
- 性能无退化
- 代码符合规范

### 10.2 总时间估算

- **开发时间**：5-8 天
- **测试时间**：1 天
- **总计**：6-9 天

---

## 11. 测试计划

### 11.1 功能测试

#### 11.1.1 按钮功能测试

| 测试项 | 测试步骤 | 预期结果 |
|-------|---------|---------|
| 加粗按钮 | 1. 选中文本<br>2. 点击加粗按钮 | 文本被 `**` 包裹 |
| 斜体按钮 | 1. 选中文本<br>2. 点击斜体按钮 | 文本被 `*` 包裹 |
| 标题菜单 | 1. 点击标题按钮<br>2. 选择 H1 | 插入 `# ` |
| 视图切换 | 1. 点击视图模式按钮<br>2. 切换到预览 | 显示预览内容 |

#### 11.1.2 状态检测测试

| 测试项 | 测试步骤 | 预期结果 |
|-------|---------|---------|
| 激活状态 | 1. 选中 `**粗体**` 文本<br>2. 查看加粗按钮 | 按钮显示激活状态（蓝色背景） |
| 禁用状态 | 1. 关闭所有笔记<br>2. 查看工具栏按钮 | 所有按钮显示禁用状态（灰色） |

### 11.2 UI 测试

#### 11.2.1 布局测试

- ✅ 工具栏高度为 48pt
- ✅ 按钮尺寸为 32x32pt
- ✅ 间距符合规范
- ✅ 不同窗口宽度下布局正确

#### 11.2.2 交互测试

- ✅ Hover 效果正常
- ✅ 点击反馈清晰
- ✅ 动画流畅
- ✅ 工具提示显示正确

### 11.3 性能测试

- ✅ 工具栏渲染性能（<16ms）
- ✅ 状态更新响应速度（<100ms）
- ✅ 内存占用无异常增长

### 11.4 可访问性测试

- ✅ VoiceOver 支持
- ✅ 键盘导航支持
- ✅ 工具提示内容完整

---

## 12. 附录

### 12.1 参考资源

- [Apple Human Interface Guidelines - Toolbars](https://developer.apple.com/design/human-interface-guidelines/components/system-experiences/toolbars/)
- [The Composable Architecture Documentation](https://pointfreeco.github.io/swift-composable-architecture/)
- [SwiftUI View Layout](https://developer.apple.com/documentation/swiftui/view-layout)

### 12.2 相关文档

- `EDITOR_TOOLBAR_PRD.md` - 原始工具栏 PRD
- `EditorFeature.swift` - TCA Reducer 实现
- `NoteEditorView.swift` - 编辑器主视图

### 12.3 变更记录

| 版本 | 日期 | 变更内容 | 作者 |
|-----|------|---------|------|
| v2.0.0 | 2025-11-17 | 创建独立工具栏 PRD | AI Assistant |

---

**文档状态**: ✅ 已完成，待评审


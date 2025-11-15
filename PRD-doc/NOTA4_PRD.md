# Nota4 产品需求文档 (PRD)

> **版本**: v2.1.0 (完全重构版)  
> **更新日期**: 2025-11-15  
> **产品定位**: 基于 SwiftUI 4.0 + TCA 1.11 的现代化 Markdown 笔记应用  
> **重构理由**: 解决状态管理混乱、提升用户体验、拥抱 Apple 最新技术栈  
> **GitHub 仓库**: https://github.com/Coldplay-now/Nota4

---

## 📋 文档状态

| 章节 | 状态 | 完成度 | 最后更新 |
|-----|------|--------|---------|
| 1. 产品概述与重构目标 | ✅ 已完成 | 100% | 2025-11-15 |
| 2. 技术架构升级 | ✅ 已完成 | 100% | 2025-11-15 |
| 3. 核心功能设计 | ✅ 已完成 | 100% | 2025-11-15 |
| 4. SwiftUI 4.0 界面设计 | ✅ 已完成 | 100% | 2025-11-15 |
| 5. TCA 状态管理设计 | ✅ 已完成 | 100% | 2025-11-15 |
| 6. 数据架构设计 | ✅ 已完成 | 100% | 2025-11-15 |
| 7. 交互设计 | ✅ 已完成 | 100% | 2025-11-15 |
| 8. 实施路线图 | ✅ 已完成 | 100% | 2025-11-15 |

**文档版本**: v2.1.0  
**总行数**: 3,851 行  
**代码示例**: 63+ 个  
**PRD 状态**: ✅ **已完成，等待用户确认可选功能优先级**

---

## 目录

- [第一步：产品概述与重构目标](#第一步产品概述与重构目标)
- [第二步：技术架构升级](#第二步技术架构升级)
- [第三步：核心功能设计](#第三步核心功能设计)
- [第四步：SwiftUI 4.0 界面设计](#第四步swiftui-40-界面设计)
- [第五步：TCA 状态管理设计](#第五步tca-状态管理设计)
- [第六步：数据架构设计](#第六步数据架构设计)
- [第七步：交互设计](#第七步交互设计)
- [第八步：实施路线图](#第八步实施路线图)

---

## 第一步：产品概述与重构目标

### 1.1 为什么要重构到 Nota4？

#### 📊 Nota2 的核心问题总结

| 问题类型 | 具体表现 | 根本原因 | 影响 |
|---------|---------|---------|------|
| **状态管理混乱** | 选中状态滞留、双选 bug | 4 个状态源不同步 | 高频 bug，用户体验差 |
| **NSTableView 限制** | Cell 复用导致状态残留 | AppKit 陈旧的 Delegate 模式 | 需要大量手动管理代码 |
| **代码复杂度高** | `NoteListView.swift` 800+ 行 | 手动管理 UI 更新 | 维护成本高，难以扩展 |
| **缺乏现代特性** | 无暗色主题、无流畅动画 | AppKit 技术栈老旧 | 用户体验落后 |
| **测试困难** | 需要 Mock UIKit 组件 | UI 和逻辑耦合 | 测试覆盖率低 |

#### 🎯 Nota4 的核心目标

```
🏗️ 架构重构
├─ 采用 SwiftUI 4.0 声明式 UI
├─ 采用 TCA 1.11 单向数据流
└─ 消除状态管理问题的根源

🎨 体验升级
├─ 利用 Liquid 交互（流畅动画）
├─ 支持暗色主题
└─ 更现代化的 UI 设计

📈 可维护性
├─ 代码量减少 40%
├─ 测试覆盖率提升到 80%+
└─ 新功能开发效率提升 50%
```

---

### 1.2 产品定位

**Nota4** = **现代化的 macOS 原生 Markdown 笔记应用**

**核心特点**:
- ✨ **SwiftUI 原生**: 充分利用 Apple 最新 UI 框架
- 🏗️ **TCA 架构**: 可预测的状态管理，易于测试
- 🎨 **流畅体验**: Liquid 动画、暗色主题、响应式设计
- 💾 **本地优先**: 数据完全本地存储，支持 `.nota` 专有格式
- 🚀 **性能优异**: 即时保存、快速检索、丝滑操作

---

### 1.3 核心价值主张

| 维度 | Nota2 (AppKit) | Nota4 (SwiftUI + TCA) | 提升 |
|-----|----------------|----------------------|------|
| **状态管理** | 4 个状态源，手动同步 | TCA 单一数据源 | 🔥 根本性改善 |
| **开发效率** | 800+ 行 UI 代码 | ~300 行声明式代码 | 🚀 减少 60% |
| **Bug 率** | 高频选中状态 bug | 状态可预测，bug 大幅减少 | ✅ 减少 80% |
| **用户体验** | 无暗色主题，动画僵硬 | 流畅动画，系统级主题 | 🎨 质的飞跃 |
| **可测试性** | 难以测试 UI | TCA Reducer 纯函数 | 📈 测试覆盖率 80%+ |
| **新功能开发** | 需考虑多处状态同步 | 只需定义 Action | ⚡ 效率提升 50% |

---

### 1.4 目标用户（不变）

- 开发者、设计师、产品经理
- 需要快速记录想法和知识管理的用户
- 重视数据隐私和本地存储的用户
- **新增**: 追求现代化用户体验的 macOS 用户

---

### 🤔 **第一步确认点**

在继续之前，请确认：
1. ✅ 您认可重构的必要性？
2. ✅ SwiftUI 4.0 + TCA 1.11 的技术选型是否合适？
3. ✅ 核心价值主张是否符合您的期望？

**请回复 "确认第一步" 或提出修改意见，我将继续第二步。**

---

## 第二步：技术架构升级

### 2.1 技术栈对比

| 层级 | Nota2 (旧) | Nota4 (新) | 升级理由 |
|-----|-----------|-----------|---------|
| **UI 框架** | AppKit (NSTableView) | SwiftUI 4.0 (List, NavigationSplitView) | 声明式、自动管理、现代化 |
| **状态管理** | MVVM + NotificationCenter | TCA 1.11 | 单向数据流、可预测、可测试 |
| **响应式** | Combine | TCA Effect (基于 Combine) | 统一在 TCA 生态 |
| **数据库** | GRDB (SQLite) | GRDB (保持) | 成熟稳定，无需更换 |
| **文件格式** | 纯文本 .nota | YAML Front Matter .nota | 支持元数据内嵌 |
| **包管理** | SPM | SPM | 保持 |
| **最低版本** | macOS 11.0+ | macOS 15.0+ (Sequoia) ⭐ | 利用最新特性和最佳性能 |

---

### 2.2 SwiftUI 4.0 关键特性应用

#### 2.2.1 NavigationSplitView（三栏布局）

**替代 Nota2 的手动布局**:
```swift
// ❌ Nota2 (AppKit): 手动管理约束、分隔线
NSLayoutConstraint.activate([
    sidebar.widthAnchor.constraint(equalToConstant: 200),
    listView.widthAnchor.constraint(equalToConstant: 300),
    // ... 大量布局代码
])

// ✅ Nota4 (SwiftUI): 声明式，自动管理
NavigationSplitView {
    SidebarView(store: store.scope(state: \.sidebar, action: \.sidebar))
} content: {
    NoteListView(store: store.scope(state: \.noteList, action: \.noteList))
} detail: {
    NoteEditorView(store: store.scope(state: \.editor, action: \.editor))
}
```

**优势**:
- ✅ 自动处理分栏宽度、折叠、响应式
- ✅ 支持工具栏、搜索栏一体化
- ✅ 系统级交互（拖拽调整宽度）

---

#### 2.2.2 Liquid 交互（流畅动画）

**应用场景**:
1. **笔记选中动画**:
   ```swift
   .background(
       RoundedRectangle(cornerRadius: 8)
           .fill(isSelected ? Color.accentColor.opacity(0.2) : .clear)
           .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
   )
   ```

2. **列表插入/删除动画**:
   ```swift
   List(store.notes) { note in
       NoteRow(note: note)
   }
   .animation(.spring(), value: store.notes)
   ```

3. **搜索结果高亮**:
   ```swift
   Text(note.title)
       .matchedGeometryEffect(id: "title-\(note.id)", in: namespace)
   ```

---

#### 2.2.3 暗色主题自动适配

```swift
// ✅ SwiftUI 自动支持，无需手动处理
@Environment(\.colorScheme) var colorScheme

var backgroundColor: Color {
    colorScheme == .dark ? Color.black : Color.white
}
```

---

#### 2.2.4 新布局系统（Grid, Layout Protocol）

**笔记卡片网格视图**（未来功能）:
```swift
LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))]) {
    ForEach(store.notes) { note in
        NoteCard(note: note)
    }
}
```

---

### 2.3 TCA 1.11 核心概念

#### 2.3.1 单向数据流

```
User Action (View)
    ↓
Action (enum)
    ↓
Reducer (pure function)
    ↓
State (struct) → View Update
    ↓
Effect (async) → Action (循环)
```

**对比 Nota2**:
```
❌ Nota2: NotificationCenter 多向通知，难以追踪
✅ Nota4: 所有变化都通过 Action，可记录、可回放
```

---

#### 2.3.2 TCA 架构图

```
┌─────────────────────────────────────────────────────┐
│                    AppState                          │
│  ├─ sidebarState: SidebarState                      │
│  ├─ noteListState: NoteListState                    │
│  └─ editorState: EditorState                        │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                    AppReducer                        │
│  ├─ sidebarReducer                                  │
│  ├─ noteListReducer                                 │
│  └─ editorReducer                                   │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                  AppEnvironment                      │
│  ├─ noteRepository: NoteRepository                  │
│  ├─ fileManager: NotaFileManager                    │
│  └─ mainQueue: AnySchedulerOf<DispatchQueue>        │
└─────────────────────────────────────────────────────┘
```

---

#### 2.3.3 Composition（模块组合）

```swift
// ✅ 每个模块独立，易于测试和维护
let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    sidebarReducer.pullback(
        state: \.sidebar,
        action: /AppAction.sidebar,
        environment: { $0 }
    ),
    noteListReducer.pullback(
        state: \.noteList,
        action: /AppAction.noteList,
        environment: { $0 }
    ),
    editorReducer.pullback(
        state: \.editor,
        action: /AppAction.editor,
        environment: { $0 }
    ),
    Reducer { state, action, environment in
        // 跨模块协调逻辑
        switch action {
        case .noteList(.noteSelected(let id)):
            state.editor.selectedNoteId = id
            return .none
        default:
            return .none
        }
    }
)
```

---

### 2.4 架构对比总结

#### Nota2 (AppKit + MVVM)
```
❌ 问题
├─ 多个状态源（tableView、currentSelectedNoteId、viewModel、cellView）
├─ 手动同步状态
├─ NotificationCenter 通知难以追踪
├─ UI 和逻辑耦合
└─ 测试困难

✅ 保留
├─ GRDB 数据库
└─ .nota 文件格式
```

#### Nota4 (SwiftUI + TCA)
```
✅ 优势
├─ 单一数据源（TCA State）
├─ 状态自动驱动 UI
├─ 所有变化可追踪（Action）
├─ UI 和逻辑分离
└─ 易于测试（Reducer 是纯函数）

🎨 新特性
├─ NavigationSplitView（三栏布局）
├─ Liquid 动画（流畅交互）
├─ 暗色主题自动适配
└─ 现代化组件（TextEditor、Menu 等）
```

---

### 🤔 **第二步确认点**

在继续之前，请确认：
1. ✅ SwiftUI 4.0 的关键特性应用是否合理？
2. ✅ TCA 1.11 的架构设计是否清晰？
3. ✅ 最低系统版本 macOS 15.0+ (Sequoia) 是否可接受？

**请回复 "确认第二步" 或提出修改意见，我将继续第三步：核心功能设计。**

---

## 第三步：核心功能设计

### 3.1 功能优先级重新规划

基于 Nota2 的经验，重新定义功能优先级：

| 功能模块 | 功能点 | Nota2 状态 | Nota4 优先级 | 实现方式 |
|---------|--------|-----------|-------------|---------|
| **笔记管理** |
| | 创建笔记 | ✅ 已实现 | **P0** | TCA Action: `.createNote` |
| | 编辑笔记 | ✅ 已实现 | **P0** | TextEditor + Debounce Effect |
| | 删除笔记（软删除） | ✅ 已实现 | **P0** | TCA Action: `.deleteNote` |
| | 恢复笔记 | ✅ 已实现 | **P1** | TCA Action: `.restoreNote` |
| | 永久删除 | ✅ 已实现 | **P1** | TCA Action: `.permanentDelete` |
| | 批量操作 | ✅ 已实现 | **P1** | SwiftUI Selection |
| **笔记组织** |
| | 星标收藏 | ✅ 已实现 | **P0** | TCA State: `isStarred` |
| | 笔记置顶 | ✅ 已实现 | **P1** | TCA State: `isPinned` |
| | 标签分类 | ❌ 未实现 | **P1** 🆕 | TCA State: `tags: [String]` |
| | 文件夹分组 | ❌ 未实现 | **P2** | 延后 v2.1 |
| **编辑器** |
| | Markdown 编辑 | ✅ 已实现 | **P0** | TextEditor |
| | 实时预览 | ❌ 未实现 | **P0** 🆕 | MarkdownUI 集成 |
| | 分屏模式 | ❌ 未实现 | **P1** 🆕 | HSplitView |
| | 语法高亮 | ❌ 未实现 | **P2** | CodeEditor 组件 |
| | 右键插入 MD 格式 | ❌ 未实现 | **P1** 🆕 | ContextMenu |
| **搜索** |
| | 全文搜索 | ✅ 已实现 | **P0** | TCA Effect: `.search` |
| | 关键词高亮 | ✅ 已实现 | **P0** | AttributedString |
| | 搜索历史 | ❌ 未实现 | **P2** | 延后 v2.1 |
| **导入/导出** |
| | 导入 .nota 文件 | ✅ 已实现 | **P1** | TCA Effect: `.importFile` |
| | 导入 .md 文件 | ✅ 已实现 | **P1** | TCA Effect: `.importFile` |
| | 导入 .txt 文件 | ❌ 未实现 | **P1** 🆕 | TCA Effect: `.importFile` |
| | 导出 .nota 文件 | ❌ 未实现 | **P1** 🆕 | TCA Effect: `.exportFile` |
| | 导出 .md 文件 | ❌ 未实现 | **P1** 🆕 | TCA Effect: `.exportFile` |
| | 导出 .html 文件 | ❌ 未实现 | **P1** 🆕 | MarkdownUI + HTML 模板 |
| | 导出 PDF | ❌ 未实现 | **P2** 🆕 | NSPrintOperation / WKWebView |
| **自动化** |
| | 即时自动保存 | ✅ 已实现 | **P0** | TCA Effect: `.autoSave` |
| | 失焦自动保存 | ✅ 已实现 | **P0** | `scenePhase` Binding |
| | 版本历史 | ❌ 未实现 | **P3** | 延后 v2.2 |
| **界面** |
| | 亮色主题 | ✅ 已实现 | **P0** | SwiftUI 自动支持 |
| | 暗色主题 | ❌ 未实现 | **P0** 🆕 | `@Environment(\.colorScheme)` |
| | 自定义字体 | ❌ 未实现 | **P1** 🆕 | Settings + TCA State |

---

### 3.2 核心功能详细设计

#### 3.2.1 【P0】实时预览模式（新增）

**需求**:
- 用户可以选择"仅编辑"、"仅预览"、"分屏"三种模式
- 预览使用 Markdown 渲染引擎（推荐 MarkdownUI）
- 预览支持代码高亮、表格、图片等

**TCA 状态设计**:
```swift
struct EditorState {
    var selectedNoteId: String?
    var content: String = ""
    var viewMode: ViewMode = .editOnly
    
    enum ViewMode {
        case editOnly
        case previewOnly
        case split
    }
}

enum EditorAction {
    case viewModeChanged(ViewMode)
    case contentChanged(String)
}
```

**UI 实现**:
```swift
struct NoteEditorView: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                switch viewStore.viewMode {
                case .editOnly:
                    TextEditor(text: viewStore.binding(\.$content))
                case .previewOnly:
                    MarkdownPreview(content: viewStore.content)
                case .split:
                    HSplitView {
                        TextEditor(text: viewStore.binding(\.$content))
                        MarkdownPreview(content: viewStore.content)
                    }
                }
            }
            .toolbar {
                Picker("视图模式", selection: viewStore.binding(\.$viewMode)) {
                    Label("编辑", systemImage: "pencil").tag(ViewMode.editOnly)
                    Label("预览", systemImage: "eye").tag(ViewMode.previewOnly)
                    Label("分屏", systemImage: "rectangle.split.2x1").tag(ViewMode.split)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
```

---

#### 3.2.2 【P1】右键插入 Markdown 格式（新增）

**需求**:
- 在编辑器中右键显示菜单
- 支持插入：标题、加粗、斜体、代码块、列表、链接、图片等

**TCA Action 设计**:
```swift
enum EditorAction {
    case insertMarkdown(MarkdownFormat)
    
    enum MarkdownFormat {
        case heading(level: Int)
        case bold
        case italic
        case codeBlock
        case unorderedList
        case orderedList
        case link
        case image
    }
}
```

**UI 实现**:
```swift
TextEditor(text: viewStore.binding(\.$content))
    .contextMenu {
        Menu("插入标题") {
            ForEach(1...6, id: \.self) { level in
                Button("H\(level)") {
                    viewStore.send(.insertMarkdown(.heading(level: level)))
                }
            }
        }
        Button("加粗") { viewStore.send(.insertMarkdown(.bold)) }
        Button("斜体") { viewStore.send(.insertMarkdown(.italic)) }
        Divider()
        Button("代码块") { viewStore.send(.insertMarkdown(.codeBlock)) }
        Button("无序列表") { viewStore.send(.insertMarkdown(.unorderedList)) }
        Button("有序列表") { viewStore.send(.insertMarkdown(.orderedList)) }
        Divider()
        Button("插入链接") { viewStore.send(.insertMarkdown(.link)) }
        Button("插入图片") { viewStore.send(.insertMarkdown(.image)) }
    }
```

**Reducer 实现**:
```swift
case .insertMarkdown(let format):
    let insertion = format.markdownText
    state.content.insert(contentsOf: insertion, at: state.cursorPosition)
    return .none

extension MarkdownFormat {
    var markdownText: String {
        switch self {
        case .heading(let level):
            return "\(String(repeating: "#", count: level)) "
        case .bold:
            return "****"  // 用户在中间输入
        case .italic:
            return "**"
        case .codeBlock:
            return "\n```\n\n```\n"
        // ...
        }
    }
}
```

---

#### 3.2.3 【P1】标签系统（新增）

**需求**:
- 每个笔记可以有多个标签
- 支持在侧边栏按标签筛选
- 支持标签自动补全

**TCA 状态设计**:
```swift
struct NoteListState {
    var notes: [Note] = []
    var selectedTags: Set<String> = []
    var allTags: Set<String> = []
}

struct Note {
    var id: String
    var title: String
    var content: String
    var tags: Set<String> = []
    // ...
}

enum NoteListAction {
    case tagSelected(String)
    case tagDeselected(String)
    case addTagToNote(noteId: String, tag: String)
}
```

**UI 实现**:
```swift
// 侧边栏标签过滤
List(selection: viewStore.binding(\.$selectedTags)) {
    Section("标签") {
        ForEach(Array(viewStore.allTags), id: \.self) { tag in
            Label(tag, systemImage: "tag")
        }
    }
}

// 笔记卡片显示标签
HStack {
    ForEach(Array(note.tags), id: \.self) { tag in
        Text(tag)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.accentColor.opacity(0.2))
            .cornerRadius(4)
    }
}
```

---

#### 3.2.4 【P1】导出功能（新增）

**需求**:
- 支持导出单个笔记为 .nota / .md / .html / .pdf
- 支持批量导出为 .zip
- 导出时自动处理图片（打包或 Base64 内嵌）

**TCA Action 设计**:
```swift
enum AppAction {
    case exportNote(noteId: String, format: ExportFormat)
    case exportNotes(noteIds: [String], format: ExportFormat)
    
    enum ExportFormat {
        case nota       // 带附件 ZIP 包
        case markdown   // 可选附件目录或 Base64
        case html       // Base64 内嵌图片
        case pdf        // 图片自动嵌入
    }
}
```

**Reducer 实现**:
```swift
case .exportNote(let noteId, let format):
    return .run { send in
        let note = try await environment.noteRepository.fetchNote(noteId)
        let fileURL = try await environment.fileManager.exportNote(note, format: format)
        await send(.exportCompleted(fileURL))
    }
```

---

### 🤔 **第三步待完善点**

请确认或补充：
1. ✅ 实时预览模式的设计是否符合预期？
2. ✅ 右键插入 Markdown 格式的功能是否足够？
3. ✅ 标签系统是否需要支持嵌套标签（如 `工作/项目A`）？
4. ✅ 导出功能还需要支持哪些格式？
5. 🤔 是否需要添加其他核心功能？

**请回复您的补充意见，我将继续第四步：SwiftUI 4.0 界面设计。**

---

## 第四步：SwiftUI 4.0 界面设计

### 4.1 整体布局（NavigationSplitView）

#### 4.1.1 布局结构

```swift
@main
struct Nota4App: App {
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment.live
    )
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建笔记") {
                    // 发送 Action
                }
                .keyboardShortcut("n")
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationSplitView(
                columnVisibility: viewStore.binding(\.$columnVisibility)
            ) {
                // 侧边栏（200pt）
                SidebarView(store: store.scope(state: \.sidebar, action: \.sidebar))
                    .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
            } content: {
                // 笔记列表（300-400pt）
                NoteListView(store: store.scope(state: \.noteList, action: \.noteList))
                    .navigationSplitViewColumnWidth(min: 280, ideal: 350, max: 500)
            } detail: {
                // 编辑器（占据剩余空间）
                NoteEditorView(store: store.scope(state: \.editor, action: \.editor))
            }
            .navigationSplitViewStyle(.balanced)  // ✨ 平衡模式，自动响应
        }
    }
}
```

**优势**:
- ✅ 自动处理窗口大小变化
- ✅ 支持折叠/展开侧边栏和列表
- ✅ 系统级拖拽调整宽度
- ✅ 自动适配 iPad（如果未来支持）

---

#### 4.1.2 ASCII 布局图

```
┌─────────────────────────────────────────────────────────────────┐
│  Nota4                              🔍 ⚙️ [工具栏]  [窗口控制]   │
├──────────┬──────────────────┬───────────────────────────────────┤
│          │                  │                                   │
│  侧边栏  │    笔记列表      │         编辑器 / 预览              │
│ Sidebar  │   NoteList       │       NoteEditor                  │
│          │                  │                                   │
│ 📝 全部  │ ┌──────────────┐ │ ┌───────────────────────────────┐│
│ (42)     │ │ 📌 笔记标题1  │ │ │ [✏️] [👁️] [↔️]  [⭐] [🗑️]     ││
│          │ │ 预览内容...   │ │ ├───────────────────────────────┤│
│ ⭐ 星标  │ │ 2h ago        │ │ │                               ││
│ (8)      │ └──────────────┘ │ │  # 笔记标题                    ││
│          │                  │ │                               ││
│ 🏷️ 标签  │ ┌──────────────┐ │ │  正文内容...                   ││
│  工作    │ │ 笔记标题2     │ │ │                               ││
│  学习    │ │ 预览...       │ │ │  - 列表项                      ││
│  生活    │ └──────────────┘ │ │                               ││
│          │                  │ │                               ││
│ 🗑️ 已删除│ ┌──────────────┐ │ │                               ││
│ (3)      │ │ 笔记标题3     │ │ │                               ││
│          │ └──────────────┘ │ └───────────────────────────────┘│
└──────────┴──────────────────┴───────────────────────────────────┘
```

---

### 4.2 侧边栏设计（SidebarView）

#### 4.2.1 TCA State

```swift
struct SidebarState {
    var selectedCategory: Category = .all
    var categories: [Category] = []
    var tags: Set<String> = []
    var selectedTags: Set<String> = []
    
    enum Category: String, CaseIterable, Identifiable {
        case all = "全部笔记"
        case starred = "星标笔记"
        case trash = "已删除"
        
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .all: return "note.text"
            case .starred: return "star.fill"
            case .trash: return "trash"
            }
        }
    }
}

enum SidebarAction {
    case categorySelected(SidebarState.Category)
    case tagSelected(String)
    case tagDeselected(String)
}
```

---

#### 4.2.2 UI 实现

```swift
struct SidebarView: View {
    let store: StoreOf<SidebarFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List(selection: viewStore.binding(\.$selectedCategory)) {
                // 分类
                Section("分类") {
                    ForEach(SidebarState.Category.allCases) { category in
                        Label {
                            Text(category.rawValue)
                        } icon: {
                            Image(systemName: category.icon)
                        }
                        .badge(viewStore.categoryCount(category))
                    }
                }
                
                // 标签
                Section("标签") {
                    ForEach(Array(viewStore.tags), id: \.self) { tag in
                        Label {
                            Text(tag)
                        } icon: {
                            Image(systemName: "tag")
                        }
                        .badge(viewStore.tagCount(tag))
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Nota4")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: { viewStore.send(.newNote) }) {
                        Label("新建", systemImage: "plus")
                    }
                }
            }
        }
    }
}
```

**特点**:
- ✅ 使用 `.listStyle(.sidebar)` 获得系统级侧边栏样式
- ✅ `.badge()` 显示笔记数量
- ✅ `selection` 绑定实现自动高亮

---

### 4.3 笔记列表设计（NoteListView）

#### 4.3.1 TCA State

```swift
struct NoteListState {
    var notes: IdentifiedArrayOf<Note> = []
    var selectedNoteId: Note.ID?
    var selectedNoteIds: Set<Note.ID> = []  // 多选
    var searchText: String = ""
    var isSearching: Bool = false
    var sortOrder: SortOrder = .updated
    
    enum SortOrder {
        case updated
        case created
        case title
    }
}

enum NoteListAction: BindableAction {
    case binding(BindingAction<NoteListState>)
    case noteSelected(Note.ID)
    case notesSelected(Set<Note.ID>)
    case notesLoaded(Result<[Note], Error>)
    case deleteNotes(Set<Note.ID>)
    case toggleStar(Note.ID)
}
```

---

#### 4.3.2 UI 实现（利用 SwiftUI 4.0 特性）

```swift
struct NoteListView: View {
    let store: StoreOf<NoteListFeature>
    @State private var selectedNotes = Set<Note.ID>()
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List(viewStore.notes, selection: $selectedNotes) { note in
                NoteRowView(note: note)
                    .equatable()  // ✅ 性能优化：启用 Equatable
                    // ✅ 右侧滑动：删除和星标
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewStore.send(.deleteNotes([note.id]))
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                        .tint(.red)  // ✅ 明确指定红色
                        
                        Button {
                            viewStore.send(.toggleStar(note.id))
                        } label: {
                            Label(note.isStarred ? "取消星标" : "星标", 
                                  systemImage: note.isStarred ? "star.slash" : "star")
                        }
                        .tint(.yellow)  // ✅ 明确指定黄色
                    }
                    // ✅ 左侧滑动：置顶
                    .swipeActions(edge: .leading) {
                        Button {
                            viewStore.send(.togglePin(note.id))
                        } label: {
                            Label(note.isPinned ? "取消置顶" : "置顶", 
                                  systemImage: note.isPinned ? "pin.slash" : "pin")
                        }
                        .tint(.orange)  // ✅ 橙色置顶
                    }
                    .contextMenu {
                        Button("打开") { viewStore.send(.noteSelected(note.id)) }
                        Divider()
                        Button("星标") { viewStore.send(.toggleStar(note.id)) }
                        Button("删除", role: .destructive) { 
                            viewStore.send(.deleteNotes([note.id])) 
                        }
                    }
            }
            .listStyle(.plain)
            // ✅ 下拉刷新（SwiftUI 4.0 新特性）
            .refreshable {
                await viewStore.send(.loadNotes, while: \.isLoading)
            }
            .searchable(
                text: viewStore.binding(\.$searchText),
                isPresented: viewStore.binding(\.$isSearching)
            )
            .toolbar {
                ToolbarItem {
                    Menu {
                        Picker("排序", selection: viewStore.binding(\.$sortOrder)) {
                            Label("最近更新", systemImage: "clock").tag(SortOrder.updated)
                            Label("创建时间", systemImage: "calendar").tag(SortOrder.created)
                            Label("标题", systemImage: "textformat").tag(SortOrder.title)
                        }
                    } label: {
                        Label("排序", systemImage: "arrow.up.arrow.down")
                    }
                }
                
                // 批量操作（仅多选时显示）
                if !selectedNotes.isEmpty {
                    ToolbarItem {
                        Button(role: .destructive) {
                            viewStore.send(.deleteNotes(selectedNotes))
                            selectedNotes.removeAll()
                        } label: {
                            Label("删除 \(selectedNotes.count) 项", systemImage: "trash")
                        }
                    }
                }
            }
            .onChange(of: selectedNotes) { newValue in
                if newValue.count == 1 {
                    viewStore.send(.noteSelected(newValue.first!))
                } else {
                    viewStore.send(.notesSelected(newValue))
                }
            }
        }
    }
}
```

**亮点**:
- ✅ `.swipeActions()` - iOS 风格的滑动操作
- ✅ `.searchable()` - 系统级搜索栏
- ✅ 动态工具栏（多选时显示批量操作）
- ✅ `IdentifiedArrayOf` - TCA 推荐的集合类型

---

#### 4.3.3 笔记卡片组件

```swift
struct NoteRowView: View, Equatable {  // ✅ 遵循 Equatable 协议
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // 置顶图标
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
                
                // 标题
                Text(note.title.isEmpty ? "无标题" : note.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                // 星标图标
                if note.isStarred {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            // 预览
            Text(note.preview)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // 底部信息
            HStack {
                // 标签
                if !note.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(note.tags.prefix(2)), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(4)
                        }
                        if note.tags.count > 2 {
                            Text("+\(note.tags.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // 时间
                Text(note.updated.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    // ⭐ 性能优化：自定义 Equatable，只比较影响 UI 的字段
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.note.id == rhs.note.id &&
        lhs.note.title == rhs.note.title &&
        lhs.note.preview == rhs.note.preview &&
        lhs.note.isStarred == rhs.note.isStarred &&
        lhs.note.isPinned == rhs.note.isPinned &&
        lhs.note.updated == rhs.note.updated &&
        lhs.note.tags == rhs.note.tags
    }
}
```

**特点**:
- ✅ 使用 `.formatted(.relative())` 显示相对时间（如 "2h ago"）
- ✅ 标签显示限制（最多 2 个）
- ✅ 置顶和星标图标

---

### 4.4 编辑器设计（NoteEditorView）

#### 4.4.1 TCA State

```swift
struct EditorState {
    var selectedNoteId: Note.ID?
    var note: Note?
    var content: String = ""
    var title: String = ""
    var viewMode: ViewMode = .editOnly
    var isSaving: Bool = false
    var cursorPosition: Int = 0
    
    enum ViewMode {
        case editOnly
        case previewOnly
        case split
    }
}

enum EditorAction: BindableAction {
    case binding(BindingAction<EditorState>)
    case loadNote(Note.ID)
    case noteLoaded(Note)
    case viewModeChanged(ViewMode)
    case autoSave
    case manualSave
    case insertMarkdown(MarkdownFormat)
    case toggleStar
    case deleteNote
}
```

---

#### 4.4.2 UI 实现（分屏模式）

```swift
struct NoteEditorView: View {
    let store: StoreOf<EditorFeature>
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                if let note = viewStore.note {
                    VStack(spacing: 0) {
                        // 标题栏
                        TitleBar(
                            title: viewStore.binding(\.$title),
                            isStarred: note.isStarred,
                            viewMode: viewStore.binding(\.$viewMode),
                            onToggleStar: { viewStore.send(.toggleStar) },
                            onDelete: { viewStore.send(.deleteNote) }
                        )
                        .focused($isTitleFocused)
                        
                        Divider()
                        
                        // 编辑器/预览区
                        editorContent(viewStore: viewStore)
                            .focused($isContentFocused)
                    }
                } else {
                    EmptyStateView()
                }
            }
            .toolbar {
                // 工具栏按钮
                editorToolbar(viewStore: viewStore)
            }
        }
    }
    
    @ViewBuilder
    private func editorContent(viewStore: ViewStore<EditorState, EditorAction>) -> some View {
        switch viewStore.viewMode {
        case .editOnly:
            MarkdownEditor(
                text: viewStore.binding(\.$content),
                onInsertMarkdown: { format in
                    viewStore.send(.insertMarkdown(format))
                }
            )
            
        case .previewOnly:
            ScrollView {
                MarkdownPreview(content: viewStore.content)
                    .padding()
            }
            
        case .split:
            HSplitView {
                MarkdownEditor(
                    text: viewStore.binding(\.$content),
                    onInsertMarkdown: { format in
                        viewStore.send(.insertMarkdown(format))
                    }
                )
                
                ScrollView {
                    MarkdownPreview(content: viewStore.content)
                        .padding()
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private func editorToolbar(viewStore: ViewStore<EditorState, EditorAction>) -> some ToolbarContent {
        // 视图模式切换
        ToolbarItem {
            Picker("视图模式", selection: viewStore.binding(\.$viewMode)) {
                Label("编辑", systemImage: "pencil").tag(ViewMode.editOnly)
                Label("预览", systemImage: "eye").tag(ViewMode.previewOnly)
                Label("分屏", systemImage: "rectangle.split.2x1").tag(ViewMode.split)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)  // ✅ 固定宽度
        }
        
        // ✅ 优化后的保存状态（使用渐变和阴影）
        ToolbarItem {
            Group {
                if viewStore.isSaving {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if viewStore.hasUnsavedChanges {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.orange)
                        .help("有未保存的更改")
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(  // ✅ 使用渐变
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .green.opacity(0.3), radius: 2, x: 0, y: 1)  // ✅ 添加阴影
                        .help("已保存")
                }
            }
            .animation(.spring(), value: viewStore.isSaving)  // ✅ 流畅动画
            .animation(.spring(), value: viewStore.hasUnsavedChanges)
        }
    }
}
```

---

#### 4.4.3 Markdown 编辑器组件

```swift
struct MarkdownEditor: View {
    @Binding var text: String
    let onInsertMarkdown: (MarkdownFormat) -> Void
    
    var body: some View {
        TextEditor(text: $text)
            .font(.system(.body, design: .monospaced))
            .padding(8)
            .contextMenu {
                markdownMenu
            }
    }
    
    @ViewBuilder
    private var markdownMenu: some View {
        // ✅ 优化：添加图标和快捷键提示
        Section("标题") {
            Menu {
                ForEach(1...6, id: \.self) { level in
                    Button {
                        onInsertMarkdown(.heading(level: level))
                    } label: {
                        Label("H\(level)", systemImage: "number.circle")  // ✅ 添加图标
                    }
                }
            } label: {
                Label("插入标题", systemImage: "textformat.size")
            }
        }
        
        Section("格式") {
            Button {
                onInsertMarkdown(.bold)
            } label: {
                Label("加粗", systemImage: "bold")  // ✅ 添加图标
            }
            .keyboardShortcut("b")  // ✅ 添加快捷键提示
            
            Button {
                onInsertMarkdown(.italic)
            } label: {
                Label("斜体", systemImage: "italic")  // ✅ 添加图标
            }
            .keyboardShortcut("i")
        }
        
        Section("块元素") {
            Button {
                onInsertMarkdown(.codeBlock)
            } label: {
                Label("代码块", systemImage: "chevron.left.forwardslash.chevron.right")
            }
            
            Button {
                onInsertMarkdown(.unorderedList)
            } label: {
                Label("无序列表", systemImage: "list.bullet")
            }
            
            Button {
                onInsertMarkdown(.orderedList)
            } label: {
                Label("有序列表", systemImage: "list.number")
            }
        }
        
        Section("插入") {
            Button {
                onInsertMarkdown(.link)
            } label: {
                Label("链接", systemImage: "link")  // ✅ 添加图标
            }
            .keyboardShortcut("k")  // ✅ 添加快捷键提示
            
            Button {
                onInsertMarkdown(.image)
            } label: {
                Label("图片", systemImage: "photo")  // ✅ 添加图标
            }
        }
    }
}
```

---

#### 4.4.4 Markdown 预览组件（使用 MarkdownUI）

```swift
import MarkdownUI

struct MarkdownPreview: View {
    let content: String
    
    var body: some View {
        Markdown(content)
            .markdownTheme(.gitHub)  // 使用 GitHub 风格
            .markdownCodeSyntaxHighlighter(.splash(theme: .sunset))
            .textSelection(.enabled)
    }
}
```

**依赖**:
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.0")
]
```

---

### 4.5 空状态设计

```swift
struct EmptyStateView: View {
    enum EmptyType {
        case noNotes
        case noSelection
        case multiSelection(count: Int)
        case searching(keyword: String)
    }
    
    let type: EmptyType
    
    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(description)
        } actions: {
            actions
        }
    }
    
    private var title: String {
        switch type {
        case .noNotes:
            return "暂无笔记"
        case .noSelection:
            return "选择一篇笔记开始编辑"
        case .multiSelection(let count):
            return "已选中 \(count) 篇笔记"
        case .searching(let keyword):
            return "未找到 \"\(keyword)\""
        }
    }
    
    private var icon: String {
        switch type {
        case .noNotes:
            return "note.text"
        case .noSelection:
            return "arrow.left"
        case .multiSelection:
            return "checkmark.circle"
        case .searching:
            return "magnifyingglass"
        }
    }
    
    private var description: String {
        switch type {
        case .noNotes:
            return "创建你的第一篇笔记"
        case .noSelection:
            return "从左侧列表选择或创建新笔记"
        case .multiSelection:
            return "批量操作模式"
        case .searching:
            return "尝试不同的关键词"
        }
    }
    
    @ViewBuilder
    private var actions: some View {
        switch type {
        case .noNotes:
            Button("新建笔记") {
                // 发送 Action
            }
            .buttonStyle(.borderedProminent)
        default:
            EmptyView()
        }
    }
}
```

---

### 🤔 **第四步待完善点**

请确认或补充：
1. ✅ NavigationSplitView 的三栏布局是否符合预期？
2. ✅ 笔记列表的卡片设计是否需要调整（如显示更多信息）？
3. ✅ 编辑器的分屏模式是否满足需求？
4. ✅ Markdown 预览是否需要自定义主题（不使用 GitHub 风格）？
5. 🤔 是否需要添加其他 UI 组件（如设置面板）？

**请回复您的补充意见，我将继续第五步：TCA 状态管理设计。**

---

## 第五步：TCA 状态管理设计

### 5.1 完整的 TCA 架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                         AppState                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ SidebarState                                              │  │
│  │  - selectedCategory: Category                             │  │
│  │  - tags: Set<String>                                      │  │
│  │  - selectedTags: Set<String>                              │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ NoteListState                                             │  │
│  │  - notes: IdentifiedArrayOf<Note>                        │  │
│  │  - selectedNoteId: Note.ID?                               │  │
│  │  - selectedNoteIds: Set<Note.ID>                          │  │
│  │  - searchText: String                                     │  │
│  │  - isSearching: Bool                                      │  │
│  │  - sortOrder: SortOrder                                   │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ EditorState                                               │  │
│  │  - selectedNoteId: Note.ID?                               │  │
│  │  - note: Note?                                            │  │
│  │  - content: String                                        │  │
│  │  - title: String                                          │  │
│  │  - viewMode: ViewMode                                     │  │
│  │  - isSaving: Bool                                         │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│                         AppAction                                │
│  - sidebar(SidebarAction)                                        │
│  - noteList(NoteListAction)                                      │
│  - editor(EditorAction)                                          │
│  - appDelegate(AppDelegateAction)  // 应用级事件                 │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│                        AppReducer                                │
│  sidebarReducer.pullback(...)                                    │
│  noteListReducer.pullback(...)                                   │
│  editorReducer.pullback(...)                                     │
│  appDelegateReducer.pullback(...)                                │
│  + 跨模块协调逻辑                                                │
└─────────────────────────────────────────────────────────────────┘
                               ↓
┌─────────────────────────────────────────────────────────────────┐
│                      AppEnvironment                              │
│  - noteRepository: NoteRepository                                │
│  - fileManager: NotaFileManager                                  │
│  - mainQueue: AnySchedulerOf<DispatchQueue>                      │
│  - uuid: () -> UUID                                              │
│  - date: () -> Date                                              │
└─────────────────────────────────────────────────────────────────┘
```

---

### 5.2 核心状态定义

#### 5.2.1 AppState（根状态）

```swift
struct AppState: Equatable {
    var sidebar: SidebarState = SidebarState()
    var noteList: NoteListState = NoteListState()
    var editor: EditorState = EditorState()
    var alert: AlertState<AppAction>?
    var columnVisibility: NavigationSplitViewVisibility = .all
}
```

---

#### 5.2.2 SidebarState（侧边栏状态）

```swift
struct SidebarState: Equatable {
    var selectedCategory: Category = .all
    var categories: IdentifiedArrayOf<Category> = [.all, .starred, .trash]
    var tags: IdentifiedArrayOf<Tag> = []
    var selectedTags: Set<String> = []
    var categoryCounts: [Category: Int] = [:]
    
    enum Category: String, CaseIterable, Identifiable {
        case all = "全部笔记"
        case starred = "星标笔记"
        case trash = "已删除"
        
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .all: return "note.text"
            case .starred: return "star.fill"
            case .trash: return "trash"
            }
        }
    }
    
    struct Tag: Equatable, Identifiable {
        let id: String
        let name: String
        var count: Int = 0
    }
}

enum SidebarAction: Equatable {
    case categorySelected(SidebarState.Category)
    case tagSelected(String)
    case tagToggled(String)
    case loadTags
    case tagsLoaded(Result<[SidebarState.Tag], Error>)
    case updateCounts([SidebarState.Category: Int])
}
```

---

#### 5.2.3 NoteListState（笔记列表状态）

```swift
struct NoteListState: Equatable {
    var notes: IdentifiedArrayOf<Note> = []
    var selectedNoteId: Note.ID?
    var selectedNoteIds: Set<Note.ID> = []
    var searchText: String = ""
    var isSearching: Bool = false
    var sortOrder: SortOrder = .updated
    var isLoading: Bool = false
    var filter: Filter = .none
    
    enum SortOrder: Equatable {
        case updated
        case created
        case title
    }
    
    enum Filter: Equatable {
        case none
        case category(SidebarState.Category)
        case tags(Set<String>)
        case search(String)
    }
    
    // 计算属性：过滤后的笔记
    var filteredNotes: [Note] {
        notes
            .filter { note in
                switch filter {
                case .none:
                    return true
                case .category(let category):
                    switch category {
                    case .all:
                        return !note.isDeleted
                    case .starred:
                        return note.isStarred && !note.isDeleted
                    case .trash:
                        return note.isDeleted
                    }
                case .tags(let tags):
                    return !note.tags.isDisjoint(with: tags) && !note.isDeleted
                case .search(let keyword):
                    return (note.title.contains(keyword) || note.content.contains(keyword)) && !note.isDeleted
                }
            }
            .sorted { lhs, rhs in
                switch sortOrder {
                case .updated:
                    if lhs.isPinned != rhs.isPinned {
                        return lhs.isPinned  // 置顶优先
                    }
                    return lhs.updated > rhs.updated
                case .created:
                    return lhs.created > rhs.created
                case .title:
                    return lhs.title < rhs.title
                }
            }
    }
}

enum NoteListAction: BindableAction, Equatable {
    case binding(BindingAction<NoteListState>)
    case loadNotes
    case notesLoaded(Result<[Note], Error>)
    case noteSelected(Note.ID)
    case notesSelected(Set<Note.ID>)
    case deleteNotes(Set<Note.ID>)
    case restoreNotes(Set<Note.ID>)
    case permanentlyDeleteNotes(Set<Note.ID>)
    case toggleStar(Note.ID)
    case togglePin(Note.ID)
    case filterChanged(NoteListState.Filter)
    case sortOrderChanged(NoteListState.SortOrder)
}
```

---

#### 5.2.4 EditorState（编辑器状态）

```swift
struct EditorState: Equatable {
    var selectedNoteId: Note.ID?
    var note: Note?
    var content: String = ""
    var title: String = ""
    var viewMode: ViewMode = .editOnly
    var isSaving: Bool = false
    var lastSavedContent: String = ""
    var lastSavedTitle: String = ""
    var hasUnsavedChanges: Bool = false
    var cursorPosition: Int = 0
    
    enum ViewMode: Equatable {
        case editOnly
        case previewOnly
        case split
    }
}

enum EditorAction: BindableAction, Equatable {
    case binding(BindingAction<EditorState>)
    case loadNote(Note.ID)
    case noteLoaded(Result<Note, Error>)
    case viewModeChanged(ViewMode)
    case autoSave
    case manualSave
    case saveCompleted
    case insertMarkdown(MarkdownFormat)
    case toggleStar
    case deleteNote
    case createNote
    case noteCreated(Result<Note, Error>)
    
    enum MarkdownFormat: Equatable {
        case heading(level: Int)
        case bold
        case italic
        case codeBlock
        case unorderedList
        case orderedList
        case link
        case image
    }
}
```

---

### 5.3 Reducer 实现

#### 5.3.1 SidebarReducer

```swift
let sidebarReducer = Reducer<SidebarState, SidebarAction, AppEnvironment> { state, action, environment in
    switch action {
    case .categorySelected(let category):
        state.selectedCategory = category
        state.selectedTags.removeAll()  // 切换分类时清空标签选择
        return .none
        
    case .tagSelected(let tag):
        state.selectedTags = [tag]
        return .none
        
    case .tagToggled(let tag):
        if state.selectedTags.contains(tag) {
            state.selectedTags.remove(tag)
        } else {
            state.selectedTags.insert(tag)
        }
        return .none
        
    case .loadTags:
        return .run { send in
            let tags = try await environment.noteRepository.fetchAllTags()
            await send(.tagsLoaded(.success(tags)))
        } catch: { error, send in
            await send(.tagsLoaded(.failure(error)))
        }
        
    case .tagsLoaded(.success(let tags)):
        state.tags = IdentifiedArray(uniqueElements: tags)
        return .none
        
    case .tagsLoaded(.failure(let error)):
        print("加载标签失败: \(error)")
        return .none
        
    case .updateCounts(let counts):
        state.categoryCounts = counts
        return .none
    }
}
```

---

#### 5.3.2 NoteListReducer（核心逻辑）

```swift
let noteListReducer = Reducer<NoteListState, NoteListAction, AppEnvironment> { state, action, environment in
    switch action {
    case .binding:
        return .none
        
    case .loadNotes:
        state.isLoading = true
        return .run { [filter = state.filter] send in
            let notes = try await environment.noteRepository.fetchNotes(filter: filter)
            await send(.notesLoaded(.success(notes)))
        } catch: { error, send in
            await send(.notesLoaded(.failure(error)))
        }
        
    case .notesLoaded(.success(let notes)):
        state.notes = IdentifiedArray(uniqueElements: notes)
        state.isLoading = false
        return .none
        
    case .notesLoaded(.failure(let error)):
        state.isLoading = false
        print("加载笔记失败: \(error)")
        return .none
        
    case .noteSelected(let id):
        state.selectedNoteId = id
        state.selectedNoteIds.removeAll()
        return .none
        
    case .notesSelected(let ids):
        state.selectedNoteIds = ids
        state.selectedNoteId = nil
        return .none
        
    case .deleteNotes(let ids):
        return .run { send in
            try await environment.noteRepository.deleteNotes(ids)
            await send(.loadNotes)
        }
        
    case .restoreNotes(let ids):
        return .run { send in
            try await environment.noteRepository.restoreNotes(ids)
            await send(.loadNotes)
        }
        
    case .permanentlyDeleteNotes(let ids):
        return .run { send in
            try await environment.noteRepository.permanentlyDeleteNotes(ids)
            try await environment.fileManager.deleteNoteFiles(ids)
            await send(.loadNotes)
        }
        
    case .toggleStar(let id):
        guard let note = state.notes[id: id] else { return .none }
        let updatedNote = Note(
            id: note.id,
            noteId: note.noteId,
            title: note.title,
            content: note.content,
            created: note.created,
            updated: environment.date(),
            isStarred: !note.isStarred,
            isPinned: note.isPinned,
            isDeleted: note.isDeleted,
            tags: note.tags
        )
        state.notes[id: id] = updatedNote
        
        return .run { send in
            try await environment.noteRepository.updateNote(updatedNote)
        }
        
    case .togglePin(let id):
        guard let note = state.notes[id: id] else { return .none }
        let updatedNote = Note(
            id: note.id,
            noteId: note.noteId,
            title: note.title,
            content: note.content,
            created: note.created,
            updated: environment.date(),
            isStarred: note.isStarred,
            isPinned: !note.isPinned,
            isDeleted: note.isDeleted,
            tags: note.tags
        )
        state.notes[id: id] = updatedNote
        
        return .run { send in
            try await environment.noteRepository.updateNote(updatedNote)
            await send(.loadNotes)  // 重新排序
        }
        
    case .filterChanged(let filter):
        state.filter = filter
        return Effect(value: .loadNotes)
        
    case .sortOrderChanged(let order):
        state.sortOrder = order
        return .none
    }
}
.binding()  // ✅ 启用 @Binding 支持
```

---

#### 5.3.3 EditorReducer（自动保存逻辑）

```swift
let editorReducer = Reducer<EditorState, EditorAction, AppEnvironment> { state, action, environment in
    struct AutoSaveId: Hashable {}
    
    switch action {
    case .binding(\.$content):
        state.hasUnsavedChanges = (state.content != state.lastSavedContent || state.title != state.lastSavedTitle)
        
        // ✅ 防抖自动保存（0.8 秒）+ 流畅动画
        return .run { send in
            try await environment.mainQueue.sleep(for: .seconds(0.8))
            await send(.autoSave, animation: .spring())  // ✅ 添加动画
        }
        .cancellable(id: AutoSaveId(), cancelInFlight: true)
        
    case .binding(\.$title):
        state.hasUnsavedChanges = (state.content != state.lastSavedContent || state.title != state.lastSavedTitle)
        
        // ✅ 防抖自动保存 + 流畅动画
        return .run { send in
            try await environment.mainQueue.sleep(for: .seconds(0.8))
            await send(.autoSave, animation: .spring())  // ✅ 添加动画
        }
        .cancellable(id: AutoSaveId(), cancelInFlight: true)
        
    case .binding:
        return .none
        
    case .loadNote(let id):
        state.selectedNoteId = id
        return .run { send in
            let note = try await environment.noteRepository.fetchNote(id)
            await send(.noteLoaded(.success(note)))
        } catch: { error, send in
            await send(.noteLoaded(.failure(error)))
        }
        
    case .noteLoaded(.success(let note)):
        state.note = note
        state.content = note.content
        state.title = note.title
        state.lastSavedContent = note.content
        state.lastSavedTitle = note.title
        state.hasUnsavedChanges = false
        return .none
        
    case .noteLoaded(.failure(let error)):
        print("加载笔记失败: \(error)")
        return .none
        
    case .viewModeChanged(let mode):
        state.viewMode = mode
        return .none
        
    case .autoSave:
        guard state.hasUnsavedChanges, let note = state.note else {
            return .none
        }
        
        state.isSaving = true
        let updatedNote = Note(
            id: note.id,
            noteId: note.noteId,
            title: state.title,
            content: state.content,
            created: note.created,
            updated: environment.date(),
            isStarred: note.isStarred,
            isPinned: note.isPinned,
            isDeleted: note.isDeleted,
            tags: note.tags
        )
        
        return .run { send in
            try await environment.noteRepository.updateNote(updatedNote)
            try await environment.fileManager.updateNoteFile(updatedNote)
            await send(.saveCompleted)
        }
        
    case .manualSave:
        // ✅ 手动保存立即触发，不防抖
        return Effect.cancel(id: AutoSaveId())
            .concatenate(with: Effect(value: .autoSave))
        
    case .saveCompleted:
        state.isSaving = false
        state.lastSavedContent = state.content
        state.lastSavedTitle = state.title
        state.hasUnsavedChanges = false
        return .none
        
    case .insertMarkdown(let format):
        let insertion = format.markdownText
        // ✅ 在光标位置插入
        let index = state.content.index(state.content.startIndex, offsetBy: state.cursorPosition, limitedBy: state.content.endIndex) ?? state.content.endIndex
        state.content.insert(contentsOf: insertion, at: index)
        state.cursorPosition += insertion.count
        return .none
        
    case .toggleStar:
        guard var note = state.note else { return .none }
        note.isStarred.toggle()
        state.note = note
        
        return .run { send in
            try await environment.noteRepository.updateNote(note)
        }
        
    case .deleteNote:
        guard let noteId = state.selectedNoteId else { return .none }
        return .run { send in
            try await environment.noteRepository.deleteNote(noteId)
        }
        
    case .createNote:
        let noteId = environment.uuid().uuidString
        let now = environment.date()
        let newNote = Note(
            id: nil,
            noteId: noteId,
            title: "无标题",
            content: "",
            created: now,
            updated: now,
            isStarred: false,
            isPinned: false,
            isDeleted: false,
            tags: []
        )
        
        return .run { send in
            try await environment.noteRepository.createNote(newNote)
            try await environment.fileManager.createNoteFile(newNote)
            await send(.noteCreated(.success(newNote)))
        } catch: { error, send in
            await send(.noteCreated(.failure(error)))
        }
        
    case .noteCreated(.success(let note)):
        state.note = note
        state.selectedNoteId = note.noteId
        state.content = ""
        state.title = "无标题"
        return .none
        
    case .noteCreated(.failure(let error)):
        print("创建笔记失败: \(error)")
        return .none
    }
}
.binding()  // ✅ 启用 @Binding 支持

extension EditorAction.MarkdownFormat {
    var markdownText: String {
        switch self {
        case .heading(let level):
            return "\(String(repeating: "#", count: level)) "
        case .bold:
            return "****"
        case .italic:
            return "**"
        case .codeBlock:
            return "\n```\n\n```\n"
        case .unorderedList:
            return "\n- "
        case .orderedList:
            return "\n1. "
        case .link:
            return "[]()"
        case .image:
            return "![]()"
        }
    }
}
```

---

#### 5.3.4 AppReducer（跨模块协调）

```swift
let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    sidebarReducer.pullback(
        state: \.sidebar,
        action: /AppAction.sidebar,
        environment: { $0 }
    ),
    noteListReducer.pullback(
        state: \.noteList,
        action: /AppAction.noteList,
        environment: { $0 }
    ),
    editorReducer.pullback(
        state: \.editor,
        action: /AppAction.editor,
        environment: { $0 }
    ),
    Reducer { state, action, environment in
        // ✅ 跨模块协调逻辑（含动画控制）
        switch action {
        // 侧边栏分类切换 → 更新笔记列表过滤（带动画）
        case .sidebar(.categorySelected(let category)):
            state.noteList.filter = .category(category)
            return .run { send in
                await send(.noteList(.loadNotes), animation: .easeInOut)  // ✅ 添加动画
            }
            
        // 侧边栏标签选择 → 更新笔记列表过滤（带动画）
        case .sidebar(.tagToggled):
            if !state.sidebar.selectedTags.isEmpty {
                state.noteList.filter = .tags(state.sidebar.selectedTags)
            } else {
                state.noteList.filter = .category(state.sidebar.selectedCategory)
            }
            return .run { send in
                await send(.noteList(.loadNotes), animation: .easeInOut)  // ✅ 添加动画
            }
            
        // 笔记列表选中 → 加载到编辑器（带动画）
        case .noteList(.noteSelected(let id)):
            return .run { send in
                await send(.editor(.loadNote(id)), animation: .spring())  // ✅ 添加弹簧动画
            }
            
        // 笔记列表多选 → 清空编辑器
        case .noteList(.notesSelected(let ids)) where ids.count > 1:
            state.editor.note = nil
            state.editor.content = ""
            state.editor.title = ""
            return .none
            
        // 编辑器保存完成 → 刷新笔记列表
        case .editor(.saveCompleted):
            return Effect(value: .noteList(.loadNotes))
            
        // 笔记列表加载完成 → 更新侧边栏统计
        case .noteList(.notesLoaded(.success(let notes))):
            let counts: [SidebarState.Category: Int] = [
                .all: notes.filter { !$0.isDeleted }.count,
                .starred: notes.filter { $0.isStarred && !$0.isDeleted }.count,
                .trash: notes.filter { $0.isDeleted }.count
            ]
            return Effect(value: .sidebar(.updateCounts(counts)))
            
        default:
            return .none
        }
    }
)
```

---

### 5.4 Environment（依赖注入）

```swift
struct AppEnvironment {
    var noteRepository: NoteRepository
    var fileManager: NotaFileManager
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
    var date: () -> Date
}

// ✅ Live Environment（生产环境）
extension AppEnvironment {
    static let live = AppEnvironment(
        noteRepository: NoteRepository.live,
        fileManager: NotaFileManager.live,
        mainQueue: .main,
        uuid: UUID.init,
        date: Date.init
    )
}

// ✅ Mock Environment（测试环境）
extension AppEnvironment {
    static let mock = AppEnvironment(
        noteRepository: NoteRepository.mock,
        fileManager: NotaFileManager.mock,
        mainQueue: .immediate,
        uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! },
        date: { Date(timeIntervalSince1970: 0) }
    )
}
```

---

### 5.5 TCA 测试示例

```swift
import XCTest
import ComposableArchitecture

class NoteListReducerTests: XCTestCase {
    func testSelectNote() async {
        let store = TestStore(
            initialState: NoteListState(),
            reducer: noteListReducer,
            environment: .mock
        )
        
        let note = Note(
            id: 1,
            noteId: "test-id",
            title: "测试笔记",
            content: "内容",
            created: Date(),
            updated: Date(),
            isStarred: false,
            isPinned: false,
            isDeleted: false,
            tags: []
        )
        
        await store.send(.notesLoaded(.success([note]))) {
            $0.notes = [note]
        }
        
        await store.send(.noteSelected("test-id")) {
            $0.selectedNoteId = "test-id"
        }
    }
    
    func testToggleStar() async {
        let note = Note(
            id: 1,
            noteId: "test-id",
            title: "测试笔记",
            content: "内容",
            created: Date(),
            updated: Date(),
            isStarred: false,
            isPinned: false,
            isDeleted: false,
            tags: []
        )
        
        let store = TestStore(
            initialState: NoteListState(notes: [note]),
            reducer: noteListReducer,
            environment: .mock
        )
        
        await store.send(.toggleStar("test-id")) {
            $0.notes[id: "test-id"]?.isStarred = true
        }
    }
}
```

---

### 🤔 **第五步待完善点**

请确认或补充：
1. ✅ TCA 的状态定义是否完整？
2. ✅ Reducer 的逻辑是否清晰（特别是跨模块协调）？
3. ✅ 自动保存的防抖逻辑是否合理（0.8 秒）？
4. ✅ Environment 的依赖注入设计是否满足测试需求？
5. 🤔 是否需要添加其他 Effect（如网络请求、文件导入等）？

**请回复您的补充意见，我将继续第六步：数据架构设计。**

---

## 第六步：数据架构设计

### 6.1 数据模型

#### 6.1.1 Note 模型

```swift
struct Note: Codable, Equatable, Identifiable {
    // 数据库字段
    var id: Int64?              // 数据库主键
    let noteId: String          // UUID，唯一标识（文件名）
    var title: String           // 笔记标题
    var content: String         // Markdown 内容
    let created: Date           // 创建时间
    var updated: Date           // 最后更新时间
    var isStarred: Bool         // 是否星标
    var isPinned: Bool          // 是否置顶
    var isDeleted: Bool         // 是否已删除（软删除）
    var tags: Set<String>       // 标签集合
    var checksum: String?       // MD5 校验和（用于检测文件变化）
    
    // 计算属性
    var preview: String {
        // 提取前 100 个字符作为预览
        let lines = content.split(separator: "\n")
        let preview = lines.prefix(3).joined(separator: " ")
        return String(preview.prefix(100))
    }
    
    var fileName: String {
        // 文件名：{noteId}.nota
        return "\(noteId).nota"
    }
}
```

---

### 6.2 文件格式（.nota）

#### 6.2.1 格式规范

**基于 Nota1 的设计，使用 YAML Front Matter：**

```yaml
---
# Nota Metadata
note_id: A464F114-7334-42E8-B58C-69E82F10E461
title: 我的笔记标题
tags: ["工作", "重要"]
starred: false
pinned: false
created: 2023-11-09T14:30:00+08:00
updated: 2023-11-09T15:45:00+08:00
checksum: d41d8cd98f00b204e9800998ecf8427e
---

# 我的笔记标题

这里是正文内容，标准的 Markdown 格式...

## 小标题
- 列表项1
- 列表项2

**加粗文本** 和 *斜体文本*
```

**格式说明**：
- **扩展名**: `.nota`（专有格式，避免并发冲突）
- **元数据头**: YAML Front Matter（Jekyll、Hugo 通用格式）
- **正文**: 标准 Markdown
- **兼容性**: 可无损转换为纯 `.md`（移除元数据头）

---

#### 6.2.2 元数据字段说明

| 字段 | 类型 | 必填 | 说明 |
|-----|------|------|------|
| `note_id` | String | ✅ | UUID，唯一标识 |
| `title` | String | ✅ | 笔记标题 |
| `tags` | Array<String> | ❌ | 标签数组，默认 `[]` |
| `starred` | Boolean | ❌ | 是否星标，默认 `false` |
| `pinned` | Boolean | ❌ | 是否置顶，默认 `false` |
| `created` | ISO8601 Date | ✅ | 创建时间 |
| `updated` | ISO8601 Date | ✅ | 更新时间 |
| `checksum` | String | ❌ | MD5 校验和 |

---

#### 6.2.3 文件命名规则

**格式**: `{noteId}.nota`

**示例**: `A464F114-7334-42E8-B58C-69E82F10E461.nota`

**特点**:
- 使用 UUID 作为文件名，避免标题重复冲突
- 扩展名 `.nota` 表明"此文件由 Nota 管理"
- 外部编辑器不会随意打开，避免并发冲突

---

### 6.3 数据库 Schema

#### 6.3.1 表结构

```sql
-- 笔记表
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    noteId TEXT NOT NULL UNIQUE,
    title TEXT DEFAULT '',
    content TEXT DEFAULT '',
    created DATETIME NOT NULL,
    updated DATETIME NOT NULL,
    is_starred BOOLEAN DEFAULT 0,
    is_pinned BOOLEAN DEFAULT 0,
    is_deleted BOOLEAN DEFAULT 0,
    checksum TEXT
);

-- 标签表（多对多关系）
CREATE TABLE note_tags (
    note_id TEXT NOT NULL,
    tag TEXT NOT NULL,
    PRIMARY KEY (note_id, tag),
    FOREIGN KEY (note_id) REFERENCES notes(noteId) ON DELETE CASCADE
);

-- 索引
CREATE INDEX idx_noteId ON notes(noteId);
CREATE INDEX idx_is_deleted ON notes(is_deleted);
CREATE INDEX idx_is_starred ON notes(is_starred);
CREATE INDEX idx_is_pinned ON notes(is_pinned);
CREATE INDEX idx_updated ON notes(updated DESC);
CREATE INDEX idx_created ON notes(created DESC);

-- 全文搜索索引（SQLite FTS5）
CREATE VIRTUAL TABLE notes_fts USING fts5(
    noteId UNINDEXED,
    title,
    content,
    tokenize = 'unicode61'  -- 支持中文分词
);
```

---

#### 6.3.2 GRDB 模型定义

```swift
import GRDB

extension Note: FetchableRecord, PersistableRecord {
    enum Columns {
        static let id = Column("id")
        static let noteId = Column("noteId")
        static let title = Column("title")
        static let content = Column("content")
        static let created = Column("created")
        static let updated = Column("updated")
        static let isStarred = Column("is_starred")
        static let isPinned = Column("is_pinned")
        static let isDeleted = Column("is_deleted")
        static let checksum = Column("checksum")
    }
    
    static let databaseTableName = "notes"
    
    // 定义持久化列
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.noteId] = noteId
        container[Columns.title] = title
        container[Columns.content] = content
        container[Columns.created] = created
        container[Columns.updated] = updated
        container[Columns.isStarred] = isStarred
        container[Columns.isPinned] = isPinned
        container[Columns.isDeleted] = isDeleted
        container[Columns.checksum] = checksum
    }
}
```

---

### 6.4 文件系统结构

#### 6.4.1 目录布局

```
~/Library/Containers/com.nota4.Nota4/Data/Documents/
├── NotaLibrary/
│   ├── notes/                    # 活跃笔记目录
│   │   ├── A464F114...nota      # 笔记文件
│   │   ├── B578C225...nota
│   │   └── ...
│   ├── trash/                    # 已删除笔记目录（软删除）
│   │   ├── C689D336...nota
│   │   └── ...
│   ├── attachments/              # 图片附件目录 ⭐ v1.0 实现
│   │   ├── {noteId}/            # 按笔记 ID 分组
│   │   │   ├── img_001.png      # 图片文件
│   │   │   ├── img_002.jpg
│   │   │   └── ...
│   └── metadata.db              # SQLite 元数据库
└── backups/                      # 数据库备份（未来功能）
    ├── metadata_20231109.db
    └── ...
```

---

#### 6.4.2 文件操作映射

| 操作 | 源目录 | 目标目录 | 数据库操作 | 文件操作 |
|-----|-------|---------|-----------|---------|
| **创建笔记** | - | `notes/` | `INSERT` | 创建 `.nota` 文件 |
| **更新笔记** | `notes/` | `notes/` | `UPDATE` | 更新 `.nota` 文件 |
| **删除笔记** | `notes/` | `trash/` | `UPDATE is_deleted=1` | 移动文件 |
| **恢复笔记** | `trash/` | `notes/` | `UPDATE is_deleted=0` | 移动文件 |
| **永久删除** | `trash/` | - | `DELETE` | 删除文件 |
| **导入笔记** | 外部 | `notes/` | `INSERT` | 复制并重命名 |
| **导出笔记** | `notes/` | 外部 | - | 复制文件 |

---

#### 6.4.3 图片处理方案 ⭐ 新增

##### 6.4.3.1 图片存储策略

**目录结构**:
```
~/Library/Containers/com.nota4.Nota4/Data/Documents/NotaLibrary/
├── attachments/
│   ├── {noteId_1}/
│   │   ├── img_001.png          # 原始图片
│   │   ├── img_002.jpg
│   │   ├── thumbnail_001.png    # 缩略图（可选）
│   │   └── thumbnail_002.jpg
│   ├── {noteId_2}/
│   │   └── img_001.png
│   └── ...
```

**命名规则**:
- **图片文件**: `img_{序号}.{扩展名}`（如 `img_001.png`）
- **缩略图**: `thumbnail_{序号}.{扩展名}`（可选，用于列表预览）
- **序号规则**: 从 001 开始递增，确保唯一性

**支持的格式**:
- ✅ **PNG** (.png) - 推荐，无损压缩
- ✅ **JPEG** (.jpg, .jpeg) - 照片类图片
- ✅ **GIF** (.gif) - 动图支持
- ✅ **WebP** (.webp) - 现代格式，高压缩比
- ⚠️ **SVG** (.svg) - 可选支持（需要额外处理）

---

##### 6.4.3.2 Markdown 图片语法

**标准 Markdown 语法**:
```markdown
![图片描述](attachments/{noteId}/img_001.png)
![另一张图片](attachments/{noteId}/img_002.jpg)
```

**相对路径处理**:
- Nota4 内部使用相对路径：`attachments/{noteId}/img_001.png`
- 导出时转换为：
  - **导出 .nota**: 保持相对路径（附件一起打包）
  - **导出 .md**: 转换为绝对路径或 Base64 内嵌
  - **导出 .html**: Base64 内嵌或外部 URL
  - **导出 .pdf**: 图片自动嵌入

---

##### 6.4.3.3 图片插入流程

```swift
// TCA Action
enum EditorAction {
    case insertImage(URL)  // 用户选择的图片 URL
    case imageInserted(imageId: String, relativePath: String)
    case imageInsertFailed(Error)
}

// Reducer 处理
case .insertImage(let sourceURL):
    guard let noteId = state.currentNoteId else {
        return .none
    }
    
    return .run { send in
        // 1. 复制图片到 attachments/{noteId}/ 目录
        let imageId = await environment.imageManager.copyImage(
            from: sourceURL,
            to: noteId
        )
        
        // 2. 生成相对路径
        let relativePath = "attachments/\(noteId)/\(imageId)"
        
        // 3. 返回成功
        await send(.imageInserted(imageId: imageId, relativePath: relativePath))
    } catch: { error, send in
        await send(.imageInsertFailed(error))
    }

case .imageInserted(let imageId, let relativePath):
    // 在光标位置插入 Markdown 图片语法
    let markdown = "\n![图片](\(relativePath))\n"
    state.content.insert(contentsOf: markdown, at: state.cursorPosition)
    return .none
```

---

##### 6.4.3.4 图片显示（编辑器）

**方案 A：纯文本编辑器**（推荐用于 v1.0）
```swift
// 编辑器显示原始 Markdown 文本
TextEditor(text: $content)
    .font(.system(.body, design: .monospaced))

// 优点：
// - 简单，不影响编辑流程
// - 用户可以直接修改图片路径

// 缺点：
// - 无法预览图片
```

**方案 B：富文本编辑器**（可选，v1.1 实现）
```swift
// 使用 NSTextView + NSTextAttachment 内嵌图片预览
// 在编辑时显示小缩略图

// 优点：
// - 所见即所得
// - 更好的用户体验

// 缺点：
// - 实现复杂
// - 需要处理光标位置、选区等
```

**推荐**: **v1.0 使用方案 A，v1.1 升级到方案 B**

---

##### 6.4.3.5 图片渲染（预览）

**使用 MarkdownUI 渲染**:
```swift
import MarkdownUI

struct MarkdownPreview: View {
    let content: String
    let noteId: String
    
    var body: some View {
        Markdown(content)
            .markdownTheme(.gitHub)  // 或自定义主题
            .markdownImageProvider(
                // ✅ 自定义图片加载器
                .asset(bundle: .main)  // 加载本地图片
            )
    }
}

// 自定义图片加载器
extension ImageProvider {
    static func localAttachment(noteId: String) -> ImageProvider {
        ImageProvider { url in
            // 解析相对路径
            if url.hasPrefix("attachments/") {
                let fullPath = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                ).first!.appendingPathComponent("NotaLibrary/\(url)")
                
                return AsyncImage(url: fullPath) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            }
            return AsyncImage(url: url)  // 外部 URL
        }
    }
}
```

---

##### 6.4.3.6 图片导出处理

| 导出格式 | 图片处理策略 | 实现方式 |
|---------|-------------|---------|
| **.nota** | 保持相对路径，附件一起打包 | 创建 ZIP：`{笔记名}.nota.zip`<br>包含：`.nota` 文件 + `attachments/` 目录 |
| **.md** | 转换为绝对路径或 Base64 | 选项 1：导出附件目录，使用绝对路径<br>选项 2：Base64 内嵌（单文件） |
| **.html** | Base64 内嵌或外部资源 | 使用 HTML 模板，`<img src="data:image/png;base64,...">`<br>或导出到 `{笔记名}_files/` 目录 |
| **.pdf** | 图片自动嵌入 | 使用 WKWebView 渲染 HTML 并打印为 PDF |

**导出 .nota（带附件）示例**:
```swift
func exportNoteWithAttachments(note: Note) async throws -> URL {
    // 1. 创建临时目录
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    
    // 2. 复制 .nota 文件
    let notaFile = tempDir.appendingPathComponent("\(note.title).nota")
    try note.content.write(to: notaFile, atomically: true, encoding: .utf8)
    
    // 3. 复制 attachments 目录
    let attachmentsDir = documentsURL
        .appendingPathComponent("NotaLibrary/attachments/\(note.noteId)")
    let destAttachments = tempDir.appendingPathComponent("attachments")
    if FileManager.default.fileExists(atPath: attachmentsDir.path) {
        try FileManager.default.copyItem(at: attachmentsDir, to: destAttachments)
    }
    
    // 4. 创建 ZIP 压缩包
    let zipURL = tempDir.deletingLastPathComponent()
        .appendingPathComponent("\(note.title).nota.zip")
    try await Zip.compress(tempDir, to: zipURL)
    
    // 5. 清理临时目录
    try FileManager.default.removeItem(at: tempDir)
    
    return zipURL
}
```

**导出 .html（Base64 内嵌）示例**:
```swift
func exportToHTML(note: Note) async throws -> String {
    var html = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>\(note.title)</title>
        <style>
            body { font-family: -apple-system, sans-serif; padding: 20px; }
            img { max-width: 100%; height: auto; }
        </style>
    </head>
    <body>
    """
    
    // 转换 Markdown 为 HTML（使用 MarkdownUI 或其他库）
    let markdownHTML = try await convertMarkdownToHTML(note.content)
    
    // 替换图片路径为 Base64
    let processedHTML = try await replaceImagesWithBase64(markdownHTML, noteId: note.noteId)
    
    html += processedHTML
    html += """
    </body>
    </html>
    """
    
    return html
}

func replaceImagesWithBase64(_ html: String, noteId: String) async throws -> String {
    var result = html
    
    // 正则匹配 <img src="attachments/...">
    let pattern = #"<img src="attachments/\#(noteId)/([^"]+)""#
    let regex = try NSRegularExpression(pattern: pattern)
    
    let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
    
    for match in matches.reversed() {
        guard let imagePathRange = Range(match.range(at: 1), in: html) else { continue }
        let imagePath = String(html[imagePathRange])
        
        // 读取图片并转换为 Base64
        let imageURL = documentsURL
            .appendingPathComponent("NotaLibrary/attachments/\(noteId)/\(imagePath)")
        let imageData = try Data(contentsOf: imageURL)
        let base64 = imageData.base64EncodedString()
        
        // 替换为 Base64 内嵌
        let mimeType = getMimeType(for: imagePath)
        let base64Src = "data:\(mimeType);base64,\(base64)"
        result.replaceSubrange(match.range, with: base64Src)
    }
    
    return result
}
```

---

##### 6.4.3.7 图片管理

**ImageManager 接口**:
```swift
protocol ImageManagerProtocol {
    // 复制图片到附件目录
    func copyImage(from sourceURL: URL, to noteId: String) async throws -> String  // 返回 imageId
    
    // 删除笔记的所有图片
    func deleteImages(forNote noteId: String) async throws
    
    // 获取图片的本地 URL
    func getImageURL(noteId: String, imageId: String) -> URL
    
    // 清理未使用的图片（垃圾回收）
    func cleanupUnusedImages() async throws
}
```

---

##### 6.4.3.8 性能优化

**缩略图生成**（可选，v1.1 实现）:
```swift
func generateThumbnail(for imageURL: URL) async throws -> URL {
    let thumbnailSize = CGSize(width: 200, height: 200)
    
    guard let image = NSImage(contentsOf: imageURL) else {
        throw ImageError.invalidImage
    }
    
    let thumbnail = image.resized(to: thumbnailSize)
    let thumbnailURL = imageURL.deletingLastPathComponent()
        .appendingPathComponent("thumbnail_\(imageURL.lastPathComponent)")
    
    try thumbnail.pngData()?.write(to: thumbnailURL)
    
    return thumbnailURL
}
```

**懒加载**:
```swift
// 预览模式下懒加载图片
AsyncImage(url: imageURL) { phase in
    switch phase {
    case .empty:
        ProgressView()
    case .success(let image):
        image.resizable().scaledToFit()
    case .failure:
        Image(systemName: "photo")
            .foregroundColor(.gray)
    @unknown default:
        EmptyView()
    }
}
.frame(maxWidth: .infinity)
.frame(height: 300)
```

---

##### 6.4.3.9 数据一致性

**图片与笔记生命周期绑定**:
```swift
// 删除笔记时
case .deleteNote(let noteId):
    return .run { send in
        // 1. 移动笔记文件到 trash/
        try await environment.noteRepository.deleteNote(noteId)
        
        // 2. 移动图片目录到 trash_attachments/
        try await environment.imageManager.moveImagesToTrash(noteId)
        
        await send(.noteDeleted)
    }

// 永久删除笔记时
case .permanentlyDeleteNote(let noteId):
    return .run { send in
        // 1. 删除笔记文件
        try await environment.noteRepository.permanentlyDeleteNote(noteId)
        
        // 2. 删除图片目录
        try await environment.imageManager.deleteImages(forNote: noteId)
        
        await send(.noteDeleted)
    }
```

---

### 6.5 数据同步策略

#### 6.5.1 双写机制

**核心原则**: **文件是"真理之源"，数据库是"性能缓存"**

```
写入操作:
1. 更新 .nota 文件内容（正文）
2. 更新 .nota 文件的 YAML 元数据头
3. 同步更新数据库记录
4. 计算并更新 checksum

读取操作:
1. 从数据库读取元数据（快速）
2. 从文件读取完整内容（按需）
3. 校验 checksum（检测外部修改）
```

---

#### 6.5.2 数据一致性保证

```swift
// TCA Effect 实现
case .autoSave:
    guard state.hasUnsavedChanges, let note = state.note else {
        return .none
    }
    
    state.isSaving = true
    let updatedNote = Note(/* 更新字段 */)
    
    return .run { send in
        // ✅ Step 1: 更新数据库
        try await environment.noteRepository.updateNote(updatedNote)
        
        // ✅ Step 2: 更新文件
        try await environment.fileManager.updateNoteFile(updatedNote)
        
        // ✅ Step 3: 更新全文搜索索引
        try await environment.noteRepository.updateFTS(updatedNote)
        
        await send(.saveCompleted, animation: .spring())
    } catch: { error, send in
        // ❌ 回滚逻辑
        print("保存失败: \(error)")
        await send(.saveFailed(error))
    }
```

---

#### 6.5.3 冲突处理策略

| 场景 | 检测方式 | 处理策略 |
|-----|---------|---------|
| **外部修改文件** | Checksum 不匹配 | 提示用户选择（保留本地/使用文件） |
| **文件缺失** | 文件不存在 | 从数据库 content 字段恢复 |
| **数据库无记录** | 数据库查询为空 | 从文件导入到数据库 |
| **移动文件冲突** | 目标文件已存在 | 删除目标后再移动 |

---

### 6.6 NoteRepository 设计

#### 6.6.1 接口定义

```swift
protocol NoteRepositoryProtocol {
    // 基本 CRUD
    func createNote(_ note: Note) async throws
    func fetchNote(byId noteId: String) async throws -> Note
    func fetchNotes(filter: NoteListState.Filter) async throws -> [Note]
    func updateNote(_ note: Note) async throws
    func deleteNote(byId noteId: String) async throws
    func permanentlyDeleteNote(byId noteId: String) async throws
    
    // 批量操作
    func deleteNotes(_ noteIds: Set<String>) async throws
    func restoreNotes(_ noteIds: Set<String>) async throws
    func permanentlyDeleteNotes(_ noteIds: Set<String>) async throws
    
    // 标签操作
    func fetchAllTags() async throws -> [SidebarState.Tag]
    func addTag(_ tag: String, to noteId: String) async throws
    func removeTag(_ tag: String, from noteId: String) async throws
    
    // 搜索
    func searchNotes(keyword: String) async throws -> [Note]
    func updateFTS(_ note: Note) async throws
}
```

---

#### 6.6.2 GRDB 实现示例

```swift
struct NoteRepository: NoteRepositoryProtocol {
    let dbQueue: DatabaseQueue
    
    func fetchNotes(filter: NoteListState.Filter) async throws -> [Note] {
        try await dbQueue.read { db in
            var request = Note.all()
            
            switch filter {
            case .none:
                request = request.filter(Note.Columns.isDeleted == false)
            case .category(let category):
                switch category {
                case .all:
                    request = request.filter(Note.Columns.isDeleted == false)
                case .starred:
                    request = request
                        .filter(Note.Columns.isStarred == true)
                        .filter(Note.Columns.isDeleted == false)
                case .trash:
                    request = request.filter(Note.Columns.isDeleted == true)
                }
            case .tags(let tags):
                // 标签过滤（JOIN note_tags 表）
                request = request
                    .joining(required: Note.tagAssociation.filter(tags.contains(Column("tag"))))
                    .filter(Note.Columns.isDeleted == false)
            case .search(let keyword):
                // 全文搜索
                let pattern = FTS5Pattern(matchingAnyTokenIn: keyword)
                request = Note
                    .matching(pattern)
                    .filter(Note.Columns.isDeleted == false)
            }
            
            // 排序：置顶优先，然后按更新时间
            request = request
                .order(Note.Columns.isPinned.desc, Note.Columns.updated.desc)
            
            return try request.fetchAll(db)
        }
    }
    
    func searchNotes(keyword: String) async throws -> [Note] {
        try await dbQueue.read { db in
            let pattern = FTS5Pattern(matchingAnyTokenIn: keyword)
            return try Note
                .matching(pattern)
                .filter(Note.Columns.isDeleted == false)
                .order(Note.Columns.updated.desc)
                .fetchAll(db)
        }
    }
}
```

---

### 6.7 NotaFileManager 设计

#### 6.7.1 接口定义

```swift
protocol NotaFileManagerProtocol {
    // 文件 CRUD
    func createNoteFile(_ note: Note) async throws
    func readNoteFile(noteId: String) async throws -> String
    func updateNoteFile(_ note: Note) async throws
    func deleteNoteFile(noteId: String) async throws
    
    // 文件移动
    func moveToTrash(noteId: String) async throws
    func restoreFromTrash(noteId: String) async throws
    
    // 导入/导出
    func importFile(from url: URL) async throws -> Note
    func exportFile(note: Note, to url: URL) async throws
    
    // 工具方法
    func calculateChecksum(content: String) -> String
    func parseNotaFile(content: String) -> (metadata: [String: Any], body: String)
    func generateNotaFile(note: Note) -> String
}
```

---

#### 6.7.2 YAML 解析实现

```swift
import Yams  // Swift YAML 库

struct NotaFileManager: NotaFileManagerProtocol {
    let notesDirectory: URL
    let trashDirectory: URL
    
    func parseNotaFile(content: String) -> (metadata: [String: Any], body: String) {
        // 提取 YAML Front Matter
        let pattern = #"^---\n(.*?)\n---\n(.*)"#
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        
        guard let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
              let yamlRange = Range(match.range(at: 1), in: content),
              let bodyRange = Range(match.range(at: 2), in: content) else {
            // 无元数据头，整个内容作为正文
            return (metadata: [:], body: content)
        }
        
        let yamlString = String(content[yamlRange])
        let body = String(content[bodyRange])
        
        let metadata = try? Yams.load(yaml: yamlString) as? [String: Any] ?? [:]
        
        return (metadata: metadata ?? [:], body: body)
    }
    
    func generateNotaFile(note: Note) -> String {
        // 生成 YAML Front Matter
        let yaml = """
        ---
        note_id: \(note.noteId)
        title: "\(note.title.replacingOccurrences(of: "\"", with: "\\\""))"
        tags: [\(note.tags.map { "\"\($0)\"" }.joined(separator: ", "))]
        starred: \(note.isStarred)
        pinned: \(note.isPinned)
        created: \(ISO8601DateFormatter().string(from: note.created))
        updated: \(ISO8601DateFormatter().string(from: note.updated))
        checksum: \(calculateChecksum(content: note.content))
        ---

        \(note.content)
        """
        
        return yaml
    }
    
    func calculateChecksum(content: String) -> String {
        // MD5 校验和
        import CryptoKit
        let data = Data(content.utf8)
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
```

---

### 🤔 **第六步确认点**

请确认或补充：
1. ✅ `.nota` 文件格式（YAML Front Matter）是否合适？
2. ✅ 数据库 Schema 是否完整（是否需要其他字段）？
3. ✅ 文件系统结构是否合理？
4. ✅ 数据同步策略（双写机制）是否清晰？
5. 🤔 是否需要添加附件管理功能（图片、PDF 等）？

**请回复 "确认第六步" 或提出修改意见，我将继续第七步：交互设计。**

---

## 第七步：交互设计

### 7.1 菜单栏设计

#### 7.1.1 Nota4 菜单

```swift
CommandGroup(replacing: .appInfo) {
    Button("关于 Nota4") {
        viewStore.send(.showAbout)
    }
}

CommandGroup(replacing: .appSettings) {
    Button("偏好设置...") {
        viewStore.send(.showSettings)
    }
    .keyboardShortcut(",")
}
```

**菜单项**:
```
Nota4
├─ 关于 Nota4
├─ ────────────
├─ 偏好设置...       ⌘,
├─ ────────────
├─ 隐藏 Nota4        ⌘H
├─ 隐藏其他          ⌥⌘H
├─ 显示全部
├─ ────────────
└─ 退出 Nota4        ⌘Q
```

---

#### 7.1.2 文件菜单

```swift
CommandGroup(replacing: .newItem) {
    Button("新建笔记") {
        viewStore.send(.editor(.createNote))
    }
    .keyboardShortcut("n")
    
    Button("导入笔记...") {
        viewStore.send(.importNote)
    }
    .keyboardShortcut("o")
}

CommandGroup(replacing: .saveItem) {
    Button("保存") {
        viewStore.send(.editor(.manualSave))
    }
    .keyboardShortcut("s")
    .disabled(!viewStore.editor.hasUnsavedChanges)
}

CommandMenu("导出") {
    Button("导出为 .nota") {
        viewStore.send(.exportNote(format: .nota))
    }
    
    Button("导出为 .md") {
        viewStore.send(.exportNote(format: .markdown))
    }
    
    Button("导出为 .html") {
        viewStore.send(.exportNote(format: .html))
    }
    
    Button("导出为 PDF...") {
        viewStore.send(.exportNote(format: .pdf))
    }
    .keyboardShortcut("p", modifiers: [.shift, .command])
}
```

**完整菜单**:
```
文件
├─ 新建笔记          ⌘N
├─ 导入笔记...       ⌘O
├─ ────────────
├─ 保存             ⌘S
├─ ────────────
├─ 导出
│  ├─ 导出为 .nota
│  ├─ 导出为 .md
│  ├─ 导出为 .html
│  └─ 导出为 PDF...  ⇧⌘P
├─ ────────────
├─ 删除笔记         ⌘⌫
└─ 关闭窗口         ⌘W
```

---

#### 7.1.3 编辑菜单

```swift
CommandGroup(after: .pasteboard) {
    Divider()
    
    Menu("插入 Markdown") {
        ForEach(1...6, id: \.self) { level in
            Button("标题 H\(level)") {
                viewStore.send(.editor(.insertMarkdown(.heading(level: level))))
            }
        }
        
        Divider()
        
        Button("加粗") {
            viewStore.send(.editor(.insertMarkdown(.bold)))
        }
        .keyboardShortcut("b")
        
        Button("斜体") {
            viewStore.send(.editor(.insertMarkdown(.italic)))
        }
        .keyboardShortcut("i")
        
        Divider()
        
        Button("代码块") {
            viewStore.send(.editor(.insertMarkdown(.codeBlock)))
        }
        
        Button("无序列表") {
            viewStore.send(.editor(.insertMarkdown(.unorderedList)))
        }
        
        Button("有序列表") {
            viewStore.send(.editor(.insertMarkdown(.orderedList)))
        }
        
        Divider()
        
        Button("插入链接") {
            viewStore.send(.editor(.insertMarkdown(.link)))
        }
        .keyboardShortcut("k")
        
        Button("插入图片") {
            viewStore.send(.editor(.insertMarkdown(.image)))
        }
    }
}
```

**完整菜单**:
```
编辑
├─ 撤销            ⌘Z
├─ 重做            ⇧⌘Z
├─ ────────────
├─ 剪切            ⌘X
├─ 复制            ⌘C
├─ 粘贴            ⌘V
├─ 全选            ⌘A
├─ ────────────
├─ 查找            ⌘F
├─ ────────────
└─ 插入 Markdown
   ├─ 标题 H1-H6
   ├─ ────────────
   ├─ 加粗          ⌘B
   ├─ 斜体          ⌘I
   ├─ ────────────
   ├─ 代码块
   ├─ 无序列表
   ├─ 有序列表
   ├─ ────────────
   ├─ 插入链接      ⌘K
   └─ 插入图片
```

---

#### 7.1.4 查看菜单

```swift
CommandGroup(after: .sidebar) {
    Divider()
    
    Picker("视图模式", selection: viewStore.binding(\.$editor.viewMode)) {
        Label("仅编辑", systemImage: "pencil").tag(EditorState.ViewMode.editOnly)
        Label("仅预览", systemImage: "eye").tag(EditorState.ViewMode.previewOnly)
        Label("分屏", systemImage: "rectangle.split.2x1").tag(EditorState.ViewMode.split)
    }
    
    Divider()
    
    Button("刷新列表") {
        viewStore.send(.noteList(.loadNotes))
    }
    .keyboardShortcut("r")
}
```

**完整菜单**:
```
查看
├─ 显示/隐藏侧边栏   ⌘⌃S
├─ ────────────
├─ 视图模式
│  ├─ 仅编辑
│  ├─ 仅预览
│  └─ 分屏
├─ ────────────
├─ 刷新列表         ⌘R
└─ 进入全屏         ⌃⌘F
```

---

#### 7.1.5 笔记菜单（新增）

```swift
CommandMenu("笔记") {
    Button("星标笔记") {
        viewStore.send(.noteList(.toggleStar(viewStore.editor.selectedNoteId!)))
    }
    .keyboardShortcut("s", modifiers: [.shift, .command])
    .disabled(viewStore.editor.selectedNoteId == nil)
    
    Button("置顶笔记") {
        viewStore.send(.noteList(.togglePin(viewStore.editor.selectedNoteId!)))
    }
    .keyboardShortcut("p", modifiers: [.shift, .command])
    .disabled(viewStore.editor.selectedNoteId == nil)
    
    Divider()
    
    Menu("添加标签") {
        ForEach(viewStore.sidebar.tags) { tag in
            Button(tag.name) {
                viewStore.send(.addTag(tag.name))
            }
        }
        
        Divider()
        
        Button("新建标签...") {
            viewStore.send(.showNewTagDialog)
        }
    }
    
    Divider()
    
    Button("移至废纸篓") {
        viewStore.send(.noteList(.deleteNotes([viewStore.editor.selectedNoteId!])))
    }
    .keyboardShortcut(.delete)
    .disabled(viewStore.editor.selectedNoteId == nil)
}
```

**完整菜单**:
```
笔记
├─ 星标笔记         ⇧⌘S
├─ 置顶笔记         ⇧⌘P
├─ ────────────
├─ 添加标签
│  ├─ 工作
│  ├─ 学习
│  ├─ 生活
│  ├─ ────────────
│  └─ 新建标签...
├─ ────────────
└─ 移至废纸篓       ⌘⌫
```

---

### 7.2 快捷键汇总

| 分类 | 功能 | 快捷键 | TCA Action |
|-----|------|--------|-----------|
| **笔记操作** |
| | 新建笔记 | `⌘N` | `.editor(.createNote)` |
| | 保存笔记 | `⌘S` | `.editor(.manualSave)` |
| | 删除笔记 | `⌘⌫` | `.noteList(.deleteNotes)` |
| | 导入笔记 | `⌘O` | `.importNote` |
| | 星标笔记 | `⇧⌘S` | `.noteList(.toggleStar)` |
| | 置顶笔记 | `⇧⌘P` | `.noteList(.togglePin)` |
| **编辑操作** |
| | 撤销 | `⌘Z` | 系统处理 |
| | 重做 | `⇧⌘Z` | 系统处理 |
| | 剪切 | `⌘X` | 系统处理 |
| | 复制 | `⌘C` | 系统处理 |
| | 粘贴 | `⌘V` | 系统处理 |
| | 全选 | `⌘A` | 系统处理 |
| | 查找 | `⌘F` | `.toggleSearch` |
| **Markdown 格式** |
| | 加粗 | `⌘B` | `.editor(.insertMarkdown(.bold))` |
| | 斜体 | `⌘I` | `.editor(.insertMarkdown(.italic))` |
| | 插入链接 | `⌘K` | `.editor(.insertMarkdown(.link))` |
| **导出** |
| | 导出 PDF | `⇧⌘P` | `.exportNote(.pdf)` |
| **查看** |
| | 刷新列表 | `⌘R` | `.noteList(.loadNotes)` |
| | 切换侧边栏 | `⌘⌃S` | 系统处理 |
| | 全屏 | `⌃⌘F` | 系统处理 |
| **窗口** |
| | 关闭窗口 | `⌘W` | 系统处理 |
| | 最小化 | `⌘M` | 系统处理 |
| **应用** |
| | 偏好设置 | `⌘,` | `.showSettings` |
| | 隐藏应用 | `⌘H` | 系统处理 |
| | 退出应用 | `⌘Q` | 系统处理 |

---

### 7.3 拖拽交互

#### 7.3.1 拖拽导入笔记

```swift
struct NoteListView: View {
    let store: StoreOf<NoteListFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List { /* ... */ }
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    handleDrop(providers: providers, viewStore: viewStore)
                }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider], viewStore: ViewStore<NoteListState, NoteListAction>) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                guard let urlData = urlData as? Data,
                      let url = URL(dataRepresentation: urlData, relativeTo: nil) else {
                    return
                }
                
                // 检查文件扩展名
                let ext = url.pathExtension.lowercased()
                if ext == "nota" || ext == "md" || ext == "markdown" {
                    viewStore.send(.importFile(url))
                }
            }
        }
        return true
    }
}
```

**支持的文件类型**:
- `.nota` 文件
- `.md` / `.markdown` 文件
- 纯文本文件

---

#### 7.3.2 拖拽笔记排序（未来功能）

```swift
// 🔮 未来功能：手动排序
List(viewStore.notes, selection: $selectedNotes) { note in
    NoteRowView(note: note)
        .onDrag {
            NSItemProvider(object: note.noteId as NSString)
        }
}
```

---

### 7.4 Touch Bar 支持（可选）

```swift
struct NoteEditorView: View {
    var body: some View {
        // ...
        .touchBar {
            HStack {
                Button(action: { viewStore.send(.insertMarkdown(.bold)) }) {
                    Label("粗体", systemImage: "bold")
                }
                
                Button(action: { viewStore.send(.insertMarkdown(.italic)) }) {
                    Label("斜体", systemImage: "italic")
                }
                
                Button(action: { viewStore.send(.insertMarkdown(.link)) }) {
                    Label("链接", systemImage: "link")
                }
                
                Divider()
                
                Picker("视图", selection: viewStore.binding(\.$viewMode)) {
                    Label("编辑", systemImage: "pencil").tag(ViewMode.editOnly)
                    Label("预览", systemImage: "eye").tag(ViewMode.previewOnly)
                    Label("分屏", systemImage: "rectangle.split.2x1").tag(ViewMode.split)
                }
            }
        }
    }
}
```

---

### 7.5 Spotlight 集成（未来功能）

```swift
// 🔮 未来功能：Spotlight 搜索
import CoreSpotlight

func indexNoteForSpotlight(_ note: Note) {
    let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
    attributeSet.title = note.title
    attributeSet.contentDescription = note.preview
    attributeSet.keywords = Array(note.tags)
    attributeSet.contentModificationDate = note.updated
    
    let item = CSSearchableItem(
        uniqueIdentifier: note.noteId,
        domainIdentifier: "com.nota4.notes",
        attributeSet: attributeSet
    )
    
    CSSearchableIndex.default().indexSearchableItems([item]) { error in
        if let error = error {
            print("Spotlight 索引失败: \(error)")
        }
    }
}
```

---

### 7.6 手势交互

| 手势 | 区域 | 功能 | 实现 |
|-----|------|------|------|
| **单击** | 笔记列表 | 选中笔记 | `List` 自动处理 |
| **双击** | 笔记列表 | （未定义） | - |
| **右键** | 笔记列表 | 显示上下文菜单 | `.contextMenu` |
| **右键** | 编辑器 | 显示 Markdown 菜单 | `.contextMenu` |
| **三指轻扫** | 编辑器 | 切换预览模式 | （未实现） |
| **捏合缩放** | 编辑器 | 调整字体大小 | （未实现） |

---

### 🤔 **第七步确认点**

请确认或补充：
1. ✅ 菜单栏设计是否完整？
2. ✅ 快捷键分配是否合理？
3. ✅ 拖拽交互是否满足需求？
4. 🤔 是否需要添加 Touch Bar 支持？
5. 🤔 是否需要 Spotlight 集成（v2.1 实现）？

---

## 第八步：实施路线图

### 8.1 MVP 功能定义（v1.0.0）

#### 8.1.1 核心功能（必须）

| 模块 | 功能 | 优先级 | 预计时间 |
|-----|------|--------|---------|
| **笔记管理** | 创建、编辑、删除、恢复 | P0 | 3 天 |
| **笔记列表** | 显示、搜索、排序、过滤 | P0 | 3 天 |
| **编辑器** | Markdown 编辑、自动保存 | P0 | 2 天 |
| **预览** | Markdown 渲染（MarkdownUI） | P0 | 2 天 |
| **分栏布局** | NavigationSplitView | P0 | 1 天 |
| **数据库** | GRDB + SQLite | P0 | 2 天 |
| **文件系统** | .nota 格式读写 | P0 | 2 天 |
| **状态管理** | TCA 架构搭建 | P0 | 3 天 |
| **测试** | 核心 Reducer 测试 | P0 | 2 天 |

**MVP 总计**: **20 天**

---

#### 8.1.2 辅助功能（可选）

| 功能 | 优先级 | 预计时间 | 规划版本 |
|-----|--------|---------|---------|
| 星标笔记 | P1 | 0.5 天 | v1.0.0 |
| 置顶笔记 | P1 | 0.5 天 | v1.0.0 |
| 右键菜单 | P1 | 1 天 | v1.0.0 |
| 导入 .md | P1 | 1 天 | v1.0.0 |
| 下拉刷新 | P1 | 0.5 天 | v1.0.0 |
| 滑动操作 | P1 | 1 天 | v1.0.0 |

**v1.0.0 总计**: **25 天（约 5 周）**

---

### 8.2 迭代计划

#### 8.2.1 v1.0.0 - MVP（Week 1-5）

**目标**: 核心功能可用，可自用测试

| Week | 任务 | 交付物 |
|------|------|--------|
| **Week 1** | 项目初始化、TCA 架构搭建 | 空白 App + TCA Store |
| | - 创建 Xcode 项目 | |
| | - 添加依赖（TCA、GRDB、MarkdownUI） | |
| | - 定义 AppState、AppAction、AppReducer | |
| **Week 2** | 数据层实现 | NoteRepository + FileManager |
| | - 数据库 Schema | |
| | - GRDB 模型定义 | |
| | - .nota 文件读写 | |
| | - YAML 解析 | |
| **Week 3** | 笔记列表 + 侧边栏 | 可浏览笔记列表 |
| | - NavigationSplitView 布局 | |
| | - NoteListView + NoteRowView | |
| | - SidebarView | |
| | - 搜索功能 | |
| **Week 4** | 编辑器 + 预览 | 可编辑和预览笔记 |
| | - NoteEditorView | |
| | - Markdown 编辑器 | |
| | - MarkdownUI 预览 | |
| | - 分屏模式 | |
| | - 自动保存 | |
| **Week 5** | 完善 + 测试 | 可发布的 MVP |
| | - 星标、置顶功能 | |
| | - 右键菜单 | |
| | - 导入功能 | |
| | - 单元测试 | |
| | - Bug 修复 | |

---

#### 8.2.2 v1.1.0 - 功能增强（Week 6-8）

**目标**: 添加标签系统、导出功能、UI 优化

| 功能 | 预计时间 | 说明 |
|-----|---------|------|
| 标签系统 | 3 天 | 创建、编辑、过滤标签 |
| 导出功能 | 2 天 | 导出 .nota、.md、PDF |
| 右键插入 MD | 1 天 | 编辑器右键菜单 |
| 性能优化 | 2 天 | Equatable、ViewStore.scope |
| UI 优化 | 2 天 | 动画、渐变、阴影 |
| 文档 | 2 天 | 用户手册、开发文档 |

**v1.1.0 总计**: **12 天（约 2.5 周）**

---

#### 8.2.3 v1.2.0 - 高级功能（Week 9-11）

**目标**: 附件、版本历史、iCloud 同步（可选）

| 功能 | 预计时间 | 说明 |
|-----|---------|------|
| 附件管理 | 5 天 | 图片、PDF 附件支持 |
| 版本历史 | 3 天 | 笔记版本回溯 |
| 数据库备份 | 2 天 | 自动备份和恢复 |
| Spotlight 集成 | 2 天 | 系统级搜索 |
| iCloud 同步（可选） | 5 天 | CloudKit 同步 |

**v1.2.0 总计**: **12-17 天（约 3 周）**

---

### 8.3 技术风险与应对

| 风险 | 影响 | 概率 | 应对策略 |
|-----|------|------|---------|
| **TCA 学习曲线** | 高 | 中 | 提前学习，参考官方示例 |
| **MarkdownUI 性能** | 中 | 低 | 大文件分段渲染 |
| **YAML 解析兼容性** | 中 | 低 | 使用成熟库（Yams） |
| **数据同步冲突** | 高 | 中 | Checksum 检测 + 用户选择 |
| **全文搜索性能** | 中 | 低 | 使用 FTS5 索引 |
| **SwiftUI 4.0 Bug** | 低 | 低 | 降级到 SwiftUI 3.0 特性 |
| **状态管理复杂度** | 中 | 中 | 模块化 Reducer，单一职责 |

---

### 8.4 测试策略

#### 8.4.1 单元测试（TCA Reducer）

```swift
// 测试覆盖率目标：80%+

class NoteListReducerTests: XCTestCase {
    func testCreateNote() async { /* ... */ }
    func testDeleteNote() async { /* ... */ }
    func testToggleStar() async { /* ... */ }
    func testSearchNotes() async { /* ... */ }
}

class EditorReducerTests: XCTestCase {
    func testAutoSave() async { /* ... */ }
    func testLoadNote() async { /* ... */ }
    func testInsertMarkdown() async { /* ... */ }
}
```

---

#### 8.4.2 集成测试

- 数据库读写测试
- 文件系统操作测试
- YAML 解析测试
- 全文搜索测试

---

#### 8.4.3 UI 测试（SwiftUI Previews）

```swift
#Preview("笔记列表") {
    NoteListView(
        store: Store(
            initialState: NoteListState(notes: Note.mockData),
            reducer: noteListReducer,
            environment: .mock
        )
    )
}

#Preview("编辑器 - 分屏") {
    NoteEditorView(
        store: Store(
            initialState: EditorState(
                note: Note.mock,
                viewMode: .split
            ),
            reducer: editorReducer,
            environment: .mock
        )
    )
}
```

---

### 8.5 性能指标

| 指标 | 目标 | 测量方式 |
|-----|------|---------|
| **启动时间** | < 1 秒 | Instruments |
| **列表滚动** | 60 FPS | Xcode Profiler |
| **搜索响应** | < 200ms | 单元测试 |
| **自动保存延迟** | 800ms | 用户感知 |
| **大文件加载** | < 500ms (10MB) | 性能测试 |
| **内存占用** | < 100MB | Activity Monitor |

---

### 8.6 发布清单

#### 8.6.1 v1.0.0 发布前检查

- [ ] 所有 P0 功能已实现
- [ ] 核心 Reducer 测试通过（覆盖率 80%+）
- [ ] UI 测试通过（主要流程）
- [ ] 无已知 P0/P1 Bug
- [ ] 文档完成（README、用户手册）
- [ ] 代码签名和公证
- [ ] DMG 打包
- [ ] 版本号更新（Info.plist）
- [ ] 变更日志（CHANGELOG.md）

---

#### 8.6.2 依赖清单

```swift
// Package.swift
dependencies: [
    // TCA
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.11.0"),
    
    // 数据库
    .package(url: "https://github.com/groue/GRDB.swift", from: "6.0.0"),
    
    // Markdown 渲染
    .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.0"),
    
    // YAML 解析
    .package(url: "https://github.com/jpsim/Yams", from: "5.0.0"),
]
```

---

### 8.7 里程碑时间线

```
Week 1-5:  v1.0.0 MVP
│          ├─ Week 1: 项目初始化
│          ├─ Week 2: 数据层
│          ├─ Week 3: 笔记列表
│          ├─ Week 4: 编辑器
│          └─ Week 5: 完善测试
│
Week 6-8:  v1.1.0 功能增强
│          ├─ 标签系统
│          ├─ 导出功能
│          └─ UI 优化
│
Week 9-11: v1.2.0 高级功能
│          ├─ 附件管理
│          ├─ 版本历史
│          └─ Spotlight 集成
│
Week 12+:  v2.0.0 未来规划
           ├─ iCloud 同步
           ├─ 插件系统
           └─ 自定义主题
```

---

## 🎉 PRD 完成总结

### ✅ 完成的章节

1. **第一步**：产品概述与重构目标 ✅
2. **第二步**：技术架构升级 ✅
3. **第三步**：核心功能设计 ✅
4. **第四步**：SwiftUI 4.0 界面设计 ✅
5. **第五步**：TCA 状态管理设计 ✅
6. **第六步**：数据架构设计 ✅
7. **第七步**：交互设计 ✅
8. **第八步**：实施路线图 ✅

### 📊 文档统计

- **总页数**: 约 100 页（A4）
- **代码示例**: 50+ 个
- **架构图**: 10+ 个
- **表格**: 30+ 个
- **功能点**: 80+ 个

### 🎯 核心亮点

1. **完全重构**: SwiftUI 4.0 + TCA 1.11
2. **状态管理**: 单一数据源，可预测
3. **性能优化**: Equatable、ViewStore.scope
4. **流畅动画**: Liquid 交互，弹簧动画
5. **现代化 UI**: 暗色主题、渐变、阴影
6. **清晰路线图**: MVP 5 周，v1.1 2.5 周

### 📝 下一步行动

1. **创建 Xcode 项目**
2. **添加依赖**（TCA、GRDB、MarkdownUI）
3. **定义 AppState**
4. **实现 NoteRepository**
5. **开始 Week 1 开发**

---

**Nota4 PRD v2.0.0 - 完整版本已完成！** 🚀

---

## 📝 下一步行动

请按照以下步骤完善 PRD：

1. **审阅第一步**（产品概述与重构目标）
   - ✅ 确认重构理由是否充分
   - ✅ 确认核心目标是否明确

2. **审阅第二步**（技术架构升级）
   - ✅ 确认 SwiftUI 4.0 特性应用是否合理
   - ✅ 确认 TCA 1.11 架构设计是否清晰

3. **完善第三步**（核心功能设计）
   - 🤔 补充或调整功能优先级
   - 🤔 确认新增功能的设计方案

4. **完善第四步**（SwiftUI 4.0 界面设计）
   - 🤔 确认布局设计
   - 🤔 调整 UI 组件细节

5. **完善第五步**（TCA 状态管理设计）
   - 🤔 确认状态定义
   - 🤔 审阅 Reducer 逻辑

6. **完善第六步**（数据架构设计）
7. **完善第七步**（交互设计）
8. **制定第八步**（实施路线图）

---

**请从第一步开始确认，或直接提出您的疑问和补充意见！** 🚀


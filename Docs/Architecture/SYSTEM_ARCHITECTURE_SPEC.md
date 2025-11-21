# Nota4 系统架构设计规范 (Spec)

**文档版本**: v1.1.1  
**创建日期**: 2025-11-19 08:26:02  
**最后更新**: 2025-11-19 08:26:02  
**目标读者**: 架构师、高级开发者、技术评审

---

## 📋 目录

- [1. 架构概述](#1-架构概述)
- [2. 架构设计原则](#2-架构设计原则)
- [3. 系统分层架构](#3-系统分层架构)
- [4. 核心模块设计](#4-核心模块设计)
- [5. 数据流设计](#5-数据流设计)
- [6. 数据模型设计](#6-数据模型设计)
- [7. 并发模型设计](#7-并发模型设计)
- [8. 性能设计](#8-性能设计)
- [9. 安全设计](#9-安全设计)
- [10. 扩展性设计](#10-扩展性设计)

---

## 1. 架构概述

### 1.1 架构愿景

Nota4 采用现代化的 **单向数据流架构**，基于 **The Composable Architecture (TCA)**，提供：
- ✅ 可预测的状态管理
- ✅ 清晰的关注点分离
- ✅ 高度可测试性
- ✅ 模块化和可组合性

### 1.2 架构图

```
┌────────────────────────────────────────────────────────┐
│                   Nota4 Application                     │
│                      (SwiftUI)                          │
└──────────────────┬─────────────────────────────────────┘
                   │
        ┌──────────┴───────────┐
        │   TCA Architecture    │
        │  (单向数据流框架)       │
        └──────────┬───────────┘
                   │
    ┌──────────────┼──────────────────┐
    │              │                  │
┌───▼───────┐ ┌───▼────────┐ ┌──────▼──────┐
│  Sidebar  │ │ Note List  │ │   Editor    │
│  Feature  │ │  Feature   │ │   Feature   │
│           │ │            │ │             │
│ ┌───────┐ │ │ ┌────────┐ │ │ ┌─────────┐ │
│ │ State │ │ │ │ State  │ │ │ │ State   │ │
│ │Action │ │ │ │ Action │ │ │ │ Action  │ │
│ │Reducer│ │ │ │ Reducer│ │ │ │ Reducer │ │
│ └───┬───┘ │ │ └────┬───┘ │ │ └────┬────┘ │
└─────┼─────┘ └──────┼─────┘ └──────┼──────┘
      │              │               │
      └──────────────┼───────────────┘
                     │
          ┌──────────▼──────────┐
          │   AppFeature         │
          │  (根级协调器)         │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │   Services Layer     │
          │  (业务逻辑)          │
          │                     │
          │  ┌────────────────┐ │
          │  │ NoteRepository │ │
          │  │ NotaFileManager│ │
          │  │ ImportService  │ │
          │  │ ExportService  │ │
          │  │ ImageManager   │ │
          │  │ ThemeManager   │ │
          │  └────────┬───────┘ │
          └───────────┼─────────┘
                      │
          ┌───────────▼────────┐
          │    Data Layer       │
          │   (数据持久化)       │
          │                     │
          │  ┌────────┐  ┌────┐ │
          │  │  GRDB  │  │File│ │
          │  │(SQLite)│  │Sys │ │
          │  └────────┘  └────┘ │
          └────────────────────┘
```

### 1.3 核心特性

| 特性 | 说明 | 优势 |
|------|------|------|
| **单向数据流** | View → Action → Reducer → State → View | 状态可预测 |
| **不可变状态** | State 通过 Reducer 纯函数更新 | 易于调试 |
| **副作用隔离** | Effect 显式声明副作用 | 易于测试 |
| **模块化** | Feature 独立封装 | 易于维护 |
| **类型安全** | Swift 强类型系统 | 编译时检查 |

---

## 2. 架构设计原则

### 2.1 SOLID 原则

#### Single Responsibility (单一职责)
- 每个 Feature 只负责一个功能域
- 每个 Service 只处理一类业务逻辑
- 每个 Model 只表示一种数据结构

#### Open/Closed (开闭原则)
- 通过 Protocol 定义接口，易于扩展
- 使用依赖注入，易于替换实现
- Feature 可组合，易于添加新功能

#### Liskov Substitution (里氏替换)
- Mock 实现与真实实现遵循相同接口
- 测试环境和生产环境可无缝切换

#### Interface Segregation (接口隔离)
- 细粒度的 Protocol 定义
- 依赖最小化接口

#### Dependency Inversion (依赖倒置)
- 高层模块不依赖低层模块，都依赖抽象
- TCA Dependencies 管理依赖注入

### 2.2 其他原则

#### DRY (Don't Repeat Yourself)
- 共享组件提取到 Views/
- 共享逻辑提取到 Utilities/
- Mock 实现统一管理

#### KISS (Keep It Simple, Stupid)
- 优先简单解决方案
- 避免过度设计
- 清晰优于聪明

#### YAGNI (You Aren't Gonna Need It)
- 不实现未来可能需要的功能
- 基于当前需求设计

---

## 3. 系统分层架构

### 3.1 分层架构

```
┌─────────────────────────────────────────┐
│        Presentation Layer                │  ← SwiftUI Views
│  (View, Feature State, Feature Action)   │
└─────────────────┬───────────────────────┘
                  │ TCA Reducer
                  ↓
┌─────────────────────────────────────────┐
│         Business Logic Layer             │  ← TCA Reducers
│      (Reducers, Effects, Dependencies)   │
└─────────────────┬───────────────────────┘
                  │ Service Protocols
                  ↓
┌─────────────────────────────────────────┐
│          Service Layer                   │  ← Services
│  (Repository, FileManager, Import/Export)│
└─────────────────┬───────────────────────┘
                  │ Data Access
                  ↓
┌─────────────────────────────────────────┐
│           Data Layer                     │  ← Persistence
│        (GRDB, FileSystem)                │
└─────────────────────────────────────────┘
```

### 3.2 各层职责

#### Presentation Layer (表现层)

**职责**:
- 渲染 UI
- 接收用户输入
- 触发 Action

**组件**:
- SwiftUI Views
- Feature State (UI 状态)
- Feature Action (用户动作)

**原则**:
- View 只依赖 State
- View 只通过 Action 改变状态
- 无业务逻辑

#### Business Logic Layer (业务逻辑层)

**职责**:
- 处理 Action
- 更新 State
- 执行 Effect

**组件**:
- TCA Reducers
- Effect (副作用)
- Dependencies (依赖)

**原则**:
- Reducer 是纯函数
- Effect 隔离副作用
- 依赖可注入

#### Service Layer (服务层)

**职责**:
- 封装业务逻辑
- 数据访问抽象
- 跨 Feature 共享逻辑

**组件**:
- NoteRepository
- NotaFileManager
- ImportService
- ExportService
- ImageManager
- ThemeManager

**原则**:
- Protocol 定义接口
- Mock 支持测试
- 错误处理完善

#### Data Layer (数据层)

**职责**:
- 数据持久化
- 数据检索
- 事务管理

**组件**:
- GRDB (SQLite)
- FileSystem (.nota 文件)
- DatabaseManager

**原则**:
- 事务安全
- 并发安全 (Actor)
- 性能优化

---

## 4. 核心模块设计

### 4.1 App Module (应用模块)

**位置**: `Nota4/App/AppFeature.swift`

**职责**:
- 管理全局状态
- 协调子 Feature
- 处理跨模块通信

**状态结构**:
```swift
struct State {
    var sidebar: SidebarFeature.State
    var noteList: NoteListFeature.State
    var editor: EditorFeature.State?
    var layoutMode: LayoutMode
    var isLayoutTransitioning: Bool
    var columnWidths: ColumnWidths
    // ... 其他全局状态
}
```

**Action 结构**:
```swift
enum Action {
    case sidebar(SidebarFeature.Action)
    case noteList(NoteListFeature.Action)
    case editor(EditorFeature.Action)
    case layoutModeChanged(LayoutMode)
    case columnVisibilityChanged(NavigationSplitViewVisibility)
    // ... 其他全局 Actions
}
```

### 4.2 Sidebar Feature (侧边栏模块)

**位置**: `Nota4/Features/Sidebar/`

**职责**:
- 分类管理（全部/星标/回收站）
- 标签管理
- 计数更新

**状态结构**:
```swift
struct State {
    var selectedCategory: Category
    var tags: [Tag]
    var selectedTags: Set<String>
    var categoryCounts: CategoryCounts
}
```

### 4.3 Note List Feature (列表模块)

**位置**: `Nota4/Features/NoteList/`

**职责**:
- 笔记列表展示
- 搜索过滤
- 批量操作

**状态结构**:
```swift
struct State {
    var notes: [Note]
    var filteredNotes: [Note]
    var selectedNoteIds: Set<String>
    var searchQuery: String
    var sortOrder: SortOrder
    var filter: Filter
}
```

### 4.4 Editor Feature (编辑器模块)

**位置**: `Nota4/Features/Editor/`

**职责**:
- 笔记编辑
- 自动保存
- 视图模式切换
- 编辑器设置

**状态结构**:
```swift
struct State {
    var selectedNoteId: String?
    var note: Note?
    var title: String
    var content: String
    var isSaving: Bool
    var viewMode: ViewMode
    var preferences: EditorPreferences
}
```

### 4.5 Import/Export Features

**位置**: `Nota4/Features/Import/`, `Nota4/Features/Export/`

**职责**:
- 文件导入（.nota, .md, .txt）
- 文件导出（.nota, .md, .txt, .html, .pdf, .png）
- 批量操作

---

## 5. 数据流设计

### 5.1 TCA 数据流

```
用户交互
   │
   ↓
┌──────────┐
│   View   │  发送 Action
└────┬─────┘
     │
     ↓
┌──────────┐
│  Action  │  (enum)
└────┬─────┘
     │
     ↓
┌──────────┐
│ Reducer  │  State + Action → (新 State, Effect)
└────┬─────┘
     │
     ├→ 新 State → View 更新
     │
     └→ Effect (副作用)
          │
          ↓
     ┌────────────┐
     │  Service   │  执行异步操作
     └────┬───────┘
          │
          ↓
     新 Action → Reducer
```

### 5.2 典型流程示例

#### 加载笔记列表

```
用户打开应用
   │
   ↓
View.onAppear → .loadNotes Action
   │
   ↓
Reducer 处理 .loadNotes
   │
   ├→ state.isLoading = true
   │
   └→ Effect { 
        let notes = try await repository.fetchNotes()
        return .notesLoaded(notes)
      }
   │
   ↓
Repository.fetchNotes()
   │
   ↓
GRDB 查询数据库
   │
   ↓
返回 [Note]
   │
   ↓
Effect 完成 → .notesLoaded Action
   │
   ↓
Reducer 处理 .notesLoaded
   │
   ├→ state.notes = notes
   ├→ state.isLoading = false
   │
   ↓
View 重新渲染（显示笔记列表）
```

#### 编辑并保存笔记

```
用户输入文本
   │
   ↓
TextEditor onChange → .contentChanged Action
   │
   ↓
Reducer 处理 .contentChanged
   │
   ├→ state.content = newContent
   ├→ state.hasUnsavedChanges = true
   │
   └→ Effect (debounced 800ms) {
        return .autoSave
      }
   │
   ↓
800ms 后 → .autoSave Action
   │
   ↓
Reducer 处理 .autoSave
   │
   ├→ state.isSaving = true
   │
   └→ Effect {
        let note = Note(...)
        try await repository.updateNote(note)
        try await fileManager.updateNoteFile(note)
        return .saveCompleted(.success(note))
      }
   │
   ↓
Repository 和 FileManager 保存
   │
   ↓
Effect 完成 → .saveCompleted Action
   │
   ↓
Reducer 处理 .saveCompleted
   │
   ├→ state.isSaving = false
   ├→ state.hasUnsavedChanges = false
   │
   ↓
View 更新（显示保存成功）
```

### 5.3 状态更新时序规范

#### 5.3.1 用户输入保护原则

**问题背景**：
在 SwiftUI + TCA 架构中，用户输入会触发状态更新，状态更新会触发视图重新计算，视图重新计算可能调用 `NSViewRepresentable.updateNSView`。如果 `updateNSView` 在用户输入过程中执行更新操作，会干扰用户输入。

**解决方案**：使用保护标志机制，确保用户输入时视图更新被跳过。

#### 5.3.2 实现模式

**原则 1：用户输入优先**

当用户正在输入时，必须立即设置保护标志，避免视图更新干扰输入。

```swift
// ✅ 正确实现：在 textDidChange 中立即设置保护标志
func textDidChange(_ notification: Notification) {
    guard let textView = notification.object as? NSTextView else { return }
    
    // 如果输入法正在输入，不更新状态
    if textView.hasMarkedText() {
        return
    }
    
    // ✅ 立即设置保护标志（同步调用）
    parent.onUpdateStarted?()
    
    // 更新状态
    parent.text = textView.string
    parent.onSelectionChange(textView.selectedRange())
    
    // 延迟清除标志（确保所有状态更新都完成）
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
        self?.parent.onUpdateCompleted?()
    }
}
```

**原则 2：视图更新检查保护标志**

在 `NSViewRepresentable.updateNSView` 中，必须首先检查保护标志。

```swift
// ✅ 正确实现：在 updateNSView 中首先检查保护标志
func updateNSView(_ scrollView: NSScrollView, context: Context) {
    guard let textView = scrollView.documentView as? NSTextView else { return }
    
    // ✅ 首先检查保护标志
    if isEditorUpdating {
        return  // 立即返回，不执行更新
    }
    
    // 继续更新逻辑（样式检查、边距更新等）...
}
```

**原则 3：避免异步设置保护标志**

❌ **错误做法**：
```swift
func updateNSView(...) {
    if isEditorUpdating { return }
    
    Task { @MainActor in
        onUpdateStarted?()  // ⚠️ 异步设置，可能太晚
    }
    
    // 继续执行更新（可能在标志设置之前）
}
```

✅ **正确做法**：
```swift
func textDidChange(...) {
    onUpdateStarted?()  // ✅ 同步设置，立即生效
    // 更新状态...
}
```

#### 5.3.3 时序图

**修复后的正确时序**：

```
t=0ms:  用户输入字符
t=1ms:  textDidChange() 触发
t=2ms:  onUpdateStarted?() 同步调用 ✅
t=3ms:  isEditorUpdating = true ✅ 标志立即设置
t=4ms:  parent.text = textView.string (更新 @Binding)
t=5ms:  state.content 更新
t=6ms:  WithPerceptionTracking 检测到变化
t=7ms:  updateNSView 被调用
t=8ms:  检查 isEditorUpdating (true) ✅ 标志已设置
t=9ms:  立即返回，不执行更新 ✅ 保护生效
t=110ms: onUpdateCompleted?() 延迟调用，清除标志
```

#### 5.3.4 输入法兼容性

所有编辑器功能必须检查输入法状态：

```swift
// ✅ 检查输入法状态
if textView.hasMarkedText() {
    return  // 输入法正在输入，不更新状态
}

// ✅ 输入法输入过程中不改变选中范围
if !textView.hasMarkedText() {
    // 更新选中范围...
}
```

#### 5.3.5 检查清单

开发编辑器相关功能时，必须检查：

- [ ] 用户输入时是否立即设置保护标志？
- [ ] 视图更新时是否检查保护标志？
- [ ] 是否避免异步设置保护标志？
- [ ] 是否检查输入法状态（`hasMarkedText()`）？
- [ ] 是否在输入法输入过程中跳过状态更新？

**相关文档**：
- `Docs/Process/EDITOR_INPUT_INTERFERENCE_FIX_SUMMARY.md` - 详细修复说明
- `Docs/Process/EDITOR_INPUT_INTERFERENCE_ANALYSIS.md` - 问题分析

---

## 6. 数据模型设计

### 6.1 核心模型

#### Note (笔记)

```swift
struct Note: Codable, Identifiable, Equatable, Hashable {
    var id: Int64?           // 数据库自增 ID
    let noteId: String       // UUID，业务 ID
    var title: String        // 标题
    var content: String      // Markdown 内容
    let created: Date        // 创建时间
    var updated: Date        // 更新时间
    var isStarred: Bool      // 是否星标
    var isPinned: Bool       // 是否置顶
    var isDeleted: Bool      // 是否删除
    var tags: Set<String>    // 标签集合
    var checksum: String?    // 文件校验和
}
```

**设计要点**:
- `id`: 数据库主键，可选（新建时为 nil）
- `noteId`: 业务主键，UUID 字符串
- `tags`: Set 保证唯一性
- 实现 `Hashable`（基于 noteId）用于 Set 操作

#### EditorPreferences (编辑器偏好设置)

```swift
struct EditorPreferences: Codable, Equatable {
    // 字体设置
    var titleFontName: String
    var titleFontSize: CGFloat
    var bodyFontName: String
    var bodyFontSize: CGFloat
    var codeFontName: String
    var codeFontSize: CGFloat
    
    // 排版设置
    var lineSpacing: CGFloat
    var paragraphSpacing: CGFloat
    var maxWidth: CGFloat
    
    // 布局设置
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat
    var alignment: Alignment
}
```

#### ThemeConfig (主题配置)

```swift
struct ThemeConfig: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let displayName: String
    let cssFileName: String
    let codeHighlightTheme: CodeTheme
    let mermaidTheme: String
    let colors: ThemeColors?
    let fonts: ThemeFonts?
}
```

### 6.2 数据库 Schema

```sql
-- 笔记表
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    noteId TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL DEFAULT '',
    content TEXT NOT NULL DEFAULT '',
    created DATETIME NOT NULL,
    updated DATETIME NOT NULL,
    is_starred BOOLEAN NOT NULL DEFAULT 0,
    is_pinned BOOLEAN NOT NULL DEFAULT 0,
    is_deleted BOOLEAN NOT NULL DEFAULT 0,
    checksum TEXT
);

-- 标签表（多对多）
CREATE TABLE note_tags (
    note_id INTEGER NOT NULL,
    tag TEXT NOT NULL,
    PRIMARY KEY (note_id, tag),
    FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
);

-- 全文搜索表（FTS5）
CREATE VIRTUAL TABLE notes_fts USING fts5(
    title,
    content,
    content='notes',
    content_rowid='id'
);

-- 索引
CREATE INDEX idx_notes_updated ON notes(updated DESC);
CREATE INDEX idx_notes_starred ON notes(is_starred) WHERE is_starred = 1;
CREATE INDEX idx_notes_deleted ON notes(is_deleted);
CREATE INDEX idx_note_tags_tag ON note_tags(tag);
```

### 6.3 文件格式

#### .nota 文件结构

```
NotaLibrary/
├── notes/
│   ├── 550E8400-E29B-41D4-A716-446655440000.nota
│   ├── 7F9E3B25-89A0-4D2E-B716-12C65DA37A18.nota
│   └── ...
├── trash/
│   └── 已删除笔记.nota
└── attachments/
    ├── image1.png
    └── ...
```

#### .nota 文件内容格式

```yaml
---
id: 550E8400-E29B-41D4-A716-446655440000
title: 示例笔记
created: 2025-11-16T09:00:00.000Z
updated: 2025-11-16T09:22:00.000Z
starred: false
pinned: false
deleted: false
tags:
  - 工作
  - Swift
---

# 笔记标题

这里是 Markdown 内容...

## 子标题

- 列表项 1
- 列表项 2

```swift
// 代码块
let hello = "world"
```
```

---

## 7. 并发模型设计

### 7.1 Swift Structured Concurrency

Nota4 全面采用 Swift 5.5+ 的结构化并发特性：

```swift
// Actor 保证线程安全
actor DatabaseManager {
    private let dbQueue: DatabaseQueue
    
    func getQueue() -> DatabaseQueue {
        dbQueue
    }
}

// async/await 异步操作
func loadNote(id: String) async throws -> Note {
    let dbManager = try DatabaseManager.default()
    let queue = await dbManager.getQueue()
    return try await queue.read { db in
        try Note.fetchOne(db, key: id) ?? throw NoteError.notFound
    }
}
```

### 7.2 并发策略

| 场景 | 策略 | 原因 |
|------|------|------|
| 数据库访问 | Actor + GRDB | 线程安全 |
| 文件 I/O | async/await | 不阻塞主线程 |
| UI 更新 | @MainActor | SwiftUI 要求 |
| 网络请求 | URLSession async | 标准做法 |

### 7.3 TCA Effect 中的并发

```swift
case .loadNotes:
    return .run { send in
        do {
            // 后台线程执行
            let notes = try await repository.fetchNotes()
            // Effect 自动切换到主线程
            await send(.notesLoaded(notes))
        } catch {
            await send(.loadFailed(error))
        }
    }
```

---

## 8. 性能设计

### 8.1 数据库优化

| 优化项 | 实现 | 效果 |
|--------|------|------|
| **索引** | 更新时间、星标、标签索引 | 查询加速 10x |
| **FTS5** | 全文搜索 | 毫秒级响应 |
| **连接池** | GRDB DatabaseQueue | 减少连接开销 |
| **批量操作** | 事务批处理 | 减少 I/O |
| **延迟加载** | 按需加载 content | 减少内存 |

### 8.2 UI 优化

| 优化项 | 实现 | 效果 |
|--------|------|------|
| **虚拟化** | LazyVStack | 大列表性能 |
| **防抖** | Debounce 800ms | 减少保存频率 |
| **缓存** | @State 缓存 | 避免重复计算 |
| **异步渲染** | Task + async | UI 流畅 |

### 8.3 内存优化

| 优化项 | 实现 | 效果 |
|--------|------|------|
| **弱引用** | [weak self] | 避免循环引用 |
| **及时释放** | Task cancellation | 释放资源 |
| **分页加载** | 限制加载数量 | 控制内存 |

---

## 9. 安全设计

### 9.1 数据安全

| 措施 | 实现 | 目的 |
|------|------|------|
| **本地存储** | 数据仅存本地 | 隐私保护 |
| **文件权限** | macOS 沙盒 | 访问控制 |
| **数据加密** | （v1.2.0 计划） | 敏感数据保护 |
| **备份** | 用户手动导出 | 数据恢复 |

### 9.2 代码安全

| 措施 | 实现 | 目的 |
|------|------|------|
| **类型安全** | Swift 强类型 | 编译时检查 |
| **错误处理** | Result/throws | 明确错误路径 |
| **输入验证** | 参数校验 | 防止非法输入 |
| **单元测试** | 94 个测试 | 功能保障 |

---

## 10. 扩展性设计

### 10.1 插件系统（v1.2.0 计划）

```swift
protocol NotaPlugin {
    var id: String { get }
    var name: String { get }
    
    func onNoteCreated(_ note: Note) async
    func onNoteSaved(_ note: Note) async
    func onNoteDeleted(_ note: Note) async
}
```

### 10.2 主题系统

```swift
protocol Theme {
    var name: String { get }
    var primaryColor: Color { get }
    var backgroundColor: Color { get }
    var textColor: Color { get }
    // ...
}
```

### 10.3 导出格式扩展

```swift
protocol ExportFormat {
    func export(note: Note) async throws -> Data
}
```

---

## 附录

### A. 架构决策记录 (ADR)

详见: [架构决策记录](./ADR/)

### B. 参考资料

- [TCA 官方文档](https://pointfreeco.github.io/swift-composable-architecture/)
- [SwiftUI 最佳实践](https://developer.apple.com/documentation/swiftui)
- [GRDB 文档](https://github.com/groue/GRDB.swift)
- [Swift Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)

---

**文档维护者**: Nota4 开发团队  
**最后审核**: 2025-11-19  
**文档状态**: ✅ 活跃维护中


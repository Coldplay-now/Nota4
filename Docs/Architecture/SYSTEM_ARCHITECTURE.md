# Nota4 系统架构文档

**文档版本**: v1.0.0  
**创建日期**: 2025-11-16  
**最后更新**: 2025-11-16 09:22:26  
**目标读者**: 开发者、架构师

---

## 📋 目录

- [1. 架构概述](#1-架构概述)
- [2. 架构设计原则](#2-架构设计原则)
- [3. 技术栈](#3-技术栈)
- [4. 系统分层](#4-系统分层)
- [5. 核心模块](#5-核心模块)
- [6. 数据流](#6-数据流)
- [7. 数据模型](#7-数据模型)
- [8. 并发模型](#8-并发模型)
- [9. 性能优化](#9-性能优化)
- [10. 安全性设计](#10-安全性设计)

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

## 3. 技术栈

### 3.1 核心框架

| 技术 | 版本 | 职责 | 选择理由 |
|------|------|------|---------|
| **SwiftUI** | 4.0+ | UI 框架 | • 声明式 UI<br>• 响应式更新<br>• macOS 原生<br>• 与 TCA 完美配合 |
| **TCA** | 1.11+ | 状态管理 | • 单向数据流<br>• 高度可测试<br>• 模块化<br>• 副作用管理 |
| **GRDB** | 6.0+ | 数据库 | • 性能优秀<br>• FTS5 全文搜索<br>• 类型安全<br>• Swift 原生 |
| **MarkdownUI** | 2.0+ | Markdown 渲染 | • SwiftUI 原生<br>• 可定制<br>• 性能好 |
| **Yams** | 5.0+ | YAML 解析 | • 纯 Swift<br>• 性能好<br>• 易用 |

### 3.2 系统要求

```
macOS: 15.0+ (Sequoia)
  ├─ SwiftUI 4.0 特性
  ├─ Swift 5.9+ 特性
  └─ 现代 macOS API

Xcode: 15.0+
  ├─ Swift 5.9 编译器
  └─ SPM 支持

Swift: 5.9+
  ├─ Structured Concurrency (async/await)
  ├─ Actors
  └─ Sendable
```

---

## 4. 系统分层

### 4.1 分层架构

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

### 4.2 各层职责

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

## 5. 核心模块

### 5.1 App Module (应用模块)

```swift
// AppFeature.swift
struct AppFeature: Reducer {
    struct State {
        var sidebar: SidebarFeature.State
        var noteList: NoteListFeature.State
        var editor: EditorFeature.State?
    }
    
    enum Action {
        case sidebar(SidebarFeature.Action)
        case noteList(NoteListFeature.Action)
        case editor(EditorFeature.Action)
        // 跨模块协调
        case categoryChanged(Category)
        case noteSelected(String)
        case noteSaved(Note)
    }
    
    var body: some ReducerOf<Self> {
        // 子模块 Reducers
        Scope(state: \.sidebar, action: /Action.sidebar) {
            SidebarFeature()
        }
        Scope(state: \.noteList, action: /Action.noteList) {
            NoteListFeature()
        }
        
        // 主 Reducer（协调逻辑）
        Reduce { state, action in
            // 处理跨模块交互
        }
    }
}
```

**职责**:
- 管理全局状态
- 协调子 Feature
- 处理跨模块通信

### 5.2 Sidebar Feature (侧边栏模块)

```swift
struct SidebarFeature: Reducer {
    struct State {
        var selectedCategory: Category = .all
        var tags: [Tag] = []
        var selectedTags: Set<String> = []
        var categoryCounts: CategoryCounts
    }
    
    enum Action {
        case selectCategory(Category)
        case selectTag(String)
        case deselectTag(String)
        case loadTags
        case tagsLoaded([Tag])
        case updateCounts(CategoryCounts)
    }
}
```

**职责**:
- 分类管理
- 标签管理
- 计数更新

### 5.3 Note List Feature (列表模块)

```swift
struct NoteListFeature: Reducer {
    struct State {
        var notes: [Note] = []
        var filteredNotes: [Note] = []
        var selectedNoteIds: Set<String> = []
        var searchQuery: String = ""
        var sortOrder: SortOrder = .updatedDesc
        var filter: NoteFilter
    }
    
    enum Action {
        case loadNotes
        case notesLoaded([Note])
        case selectNote(String)
        case deleteNotes([String])
        case searchQueryChanged(String)
        case toggleStar(String)
        case togglePin(String)
    }
}
```

**职责**:
- 笔记列表展示
- 搜索过滤
- 批量操作

### 5.4 Editor Feature (编辑器模块)

```swift
struct EditorFeature: Reducer {
    struct State {
        var selectedNoteId: String?
        var note: Note?
        var title: String = ""
        var content: String = ""
        var isSaving: Bool = false
        var viewMode: ViewMode = .edit
        var cursorPosition: Int = 0
    }
    
    enum Action {
        case loadNote(String)
        case noteLoaded(Note)
        case titleChanged(String)
        case contentChanged(String)
        case save
        case saveCompleted(Result<Note, Error>)
        case autoSave
        case viewModeChanged(ViewMode)
    }
}
```

**职责**:
- 笔记编辑
- 自动保存
- 视图模式切换

---

## 6. 数据流

### 6.1 TCA 数据流

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

### 6.2 典型流程示例

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
   ├→ state.lastSaveTime = Date()
   │
   ↓
View 更新（显示保存成功）
```

---

## 7. 数据模型

### 7.1 核心模型

#### Note (笔记)

```swift
struct Note: Codable, Identifiable, Equatable, Hashable {
    var id: Int64?           // 数据库自增 ID
    var noteId: String       // UUID，业务 ID
    var title: String        // 标题
    var content: String      // Markdown 内容
    var created: Date        // 创建时间
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

### 7.2 数据库 Schema

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

### 7.3 文件格式

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

#### .nota 文件内容

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

## 8. 并发模型

### 8.1 Swift Structured Concurrency

Nota4 全面采用 Swift 5.5+ 的结构化并发特性：

```swift
// Actor 保证线程安全
actor DatabaseManager {
    private let dbQueue: DatabaseQueue
    
    func getQueue() -> DatabaseQueue {
        dbQueue
    }
    
    nonisolated func performMigrations() throws {
        // 同步操作，不需要 actor 隔离
    }
}

// async/await 异步操作
func loadNote(id: String) async throws -> Note {
    let dbManager = try DatabaseManager.default()
    let queue = await dbManager.getQueue()
    return try await withCheckedThrowingContinuation { continuation in
        queue.read { db in
            do {
                let note = try Note.fetchOne(db, key: id)
                continuation.resume(returning: note ?? throw NoteError.notFound)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
```

### 8.2 并发策略

| 场景 | 策略 | 原因 |
|------|------|------|
| 数据库访问 | Actor + GRDB | 线程安全 |
| 文件 I/O | async/await | 不阻塞主线程 |
| UI 更新 | @MainActor | SwiftUI 要求 |
| 网络请求 | URLSession async | 标准做法 |

### 8.3 TCA Effect 中的并发

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

## 9. 性能优化

### 9.1 数据库优化

| 优化项 | 实现 | 效果 |
|--------|------|------|
| **索引** | 更新时间、星标、标签索引 | 查询加速 10x |
| **FTS5** | 全文搜索 | 毫秒级响应 |
| **连接池** | GRDB DatabaseQueue | 减少连接开销 |
| **批量操作** | 事务批处理 | 减少 I/O |
| **延迟加载** | 按需加载 content | 减少内存 |

### 9.2 UI 优化

| 优化项 | 实现 | 效果 |
|--------|------|------|
| **虚拟化** | LazyVStack | 大列表性能 |
| **防抖** | Debounce 800ms | 减少保存频率 |
| **缓存** | @State 缓存 | 避免重复计算 |
| **异步渲染** | Task + async | UI 流畅 |

### 9.3 内存优化

| 优化项 | 实现 | 效果 |
|--------|------|------|
| **弱引用** | [weak self] | 避免循环引用 |
| **及时释放** | Task cancellation | 释放资源 |
| **分页加载** | 限制加载数量 | 控制内存 |

---

## 10. 安全性设计

### 10.1 数据安全

| 措施 | 实现 | 目的 |
|------|------|------|
| **本地存储** | 数据仅存本地 | 隐私保护 |
| **文件权限** | macOS 沙盒 | 访问控制 |
| **数据加密** | （v1.1.0 计划） | 敏感数据保护 |
| **备份** | 用户手动导出 | 数据恢复 |

### 10.2 代码安全

| 措施 | 实现 | 目的 |
|------|------|------|
| **类型安全** | Swift 强类型 | 编译时检查 |
| **错误处理** | Result/throws | 明确错误路径 |
| **输入验证** | 参数校验 | 防止非法输入 |
| **单元测试** | 94 个测试 | 功能保障 |

---

## 11. 扩展性设计

### 11.1 插件系统（v1.2.0 计划）

```swift
protocol NotaPlugin {
    var id: String { get }
    var name: String { get }
    
    func onNoteCreated(_ note: Note) async
    func onNoteSaved(_ note: Note) async
    func onNoteDeleted(_ note: Note) async
}
```

### 11.2 主题系统（v1.1.0 计划）

```swift
protocol Theme {
    var name: String { get }
    var primaryColor: Color { get }
    var backgroundColor: Color { get }
    var textColor: Color { get }
    // ...
}
```

---

## 12. 监控与日志

### 12.1 日志策略

```swift
enum LogLevel {
    case debug, info, warning, error
}

// 开发环境：详细日志
#if DEBUG
let logLevel: LogLevel = .debug
#else
// 生产环境：仅错误
let logLevel: LogLevel = .error
#endif
```

### 12.2 性能监控

- 应用启动时间
- 数据库查询时间
- UI 渲染时间
- 内存使用情况

---

## 13. 测试策略

### 13.1 测试金字塔

```
       /\
      /  \    E2E Tests (UI Tests)
     /    \   - 核心用户流程
    /------\
   /        \  Integration Tests
  /          \ - Feature 集成测试
 /            \- Service 集成测试
/--------------\
|  Unit Tests  | 
| - Reducers   |
| - Models     |
| - Services   |
\--------------/
```

### 13.2 测试覆盖

| 层级 | 测试数量 | 覆盖率 | 目标 |
|------|---------|--------|------|
| Unit Tests | 94 | 100% | ≥ 80% |
| Integration | 17 | - | 核心流程 |
| E2E | 0 | - | 关键路径 |

---

## 附录

### A. 架构决策记录 (ADR)

详见: [架构决策](./ADR/)

### B. TCA 详细说明

详见: [TCA_ARCHITECTURE.md](./TCA_ARCHITECTURE.md)

### C. 参考资料

- [TCA 官方文档](https://pointfreeco.github.io/swift-composable-architecture/)
- [SwiftUI 最佳实践](https://developer.apple.com/documentation/swiftui)
- [GRDB 文档](https://github.com/groue/GRDB.swift)
- [Swift Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)

---

**文档维护者**: Nota4 开发团队  
**最后审核**: 2025-11-16  
**文档状态**: ✅ 活跃维护中


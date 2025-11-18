# Nota4 标签功能实现文档

**日期**: 2025-01-17  
**版本**: v1.1.1  
**状态**: 📋 功能分析文档

---

## 📋 概述

Nota4 的标签系统允许用户为笔记添加多个标签，并通过标签进行筛选和管理。本文档详细说明标签功能的实现方式、数据存储、UI交互以及用户如何为笔记添加标签。

---

## 1. 标签功能架构

### 1.1 数据模型

#### Note 模型中的标签

标签在 `Note` 模型中定义为 `Set<String>` 类型：

```swift
struct Note: Codable, Equatable, Identifiable, Hashable {
    var tags: Set<String>  // 标签集合，使用 Set 保证唯一性
    // ... 其他属性
}
```

**设计特点**：
- 使用 `Set<String>` 而非 `Array<String>`，自动保证标签唯一性
- 标签是简单的字符串，不区分大小写（需要在应用层处理）
- 标签数量没有限制

#### 数据库存储

标签采用**多对多关系**存储在数据库中：

**表结构**：
```sql
-- 笔记表（主表）
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    noteId TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL DEFAULT '',
    content TEXT NOT NULL DEFAULT '',
    -- ... 其他字段
    -- 注意：tags 不直接存储在 notes 表中
);

-- 标签关联表（多对多关系）
CREATE TABLE note_tags (
    note_id TEXT NOT NULL,      -- 引用 notes.noteId
    tag TEXT NOT NULL,           -- 标签名称
    PRIMARY KEY (note_id, tag),  -- 复合主键，防止重复
    FOREIGN KEY (note_id) REFERENCES notes(noteId) ON DELETE CASCADE
);

-- 索引
CREATE INDEX idx_note_tags_note_id ON note_tags(note_id);
CREATE INDEX idx_note_tags_tag ON note_tags(tag);
```

**设计优势**：
- ✅ 支持一个笔记多个标签
- ✅ 支持一个标签关联多个笔记
- ✅ 删除笔记时自动级联删除标签关联（ON DELETE CASCADE）
- ✅ 通过索引优化查询性能

---

## 2. 数据层实现

### 2.1 数据库操作（NoteRepository）

#### 创建笔记时保存标签

```swift
func createNote(_ note: Note) async throws {
    try await dbQueue.write { [note] db in
        // 1. 插入笔记主记录
        try note.insert(db)
        
        // 2. 插入标签关联
        for tag in note.tags {
            try db.execute(
                sql: "INSERT INTO note_tags (note_id, tag) VALUES (?, ?)",
                arguments: [note.noteId, tag]
            )
        }
    }
}
```

#### 更新笔记时更新标签

```swift
func updateNote(_ note: Note) async throws {
    try await dbQueue.write { [note] db in
        // 1. 更新笔记主记录
        try note.update(db)
        
        // 2. 删除旧的标签关联
        try db.execute(
            sql: "DELETE FROM note_tags WHERE note_id = ?",
            arguments: [note.noteId]
        )
        
        // 3. 插入新的标签关联
        for tag in note.tags {
            try db.execute(
                sql: "INSERT INTO note_tags (note_id, tag) VALUES (?, ?)",
                arguments: [note.noteId, tag]
            )
        }
    }
}
```

**更新策略**：采用"先删除后插入"的方式，确保标签与笔记状态完全同步。

#### 查询笔记时加载标签

```swift
func fetchNote(byId noteId: String) async throws -> Note {
    try await dbQueue.read { db in
        // 1. 查询笔记主记录
        guard var note = try Note
            .filter(Note.Columns.noteId == noteId)
            .fetchOne(db) else {
            throw RepositoryError.noteNotFound(noteId)
        }
        
        // 2. 查询标签
        let tags = try String.fetchAll(
            db,
            sql: "SELECT tag FROM note_tags WHERE note_id = ?",
            arguments: [noteId]
        )
        note.tags = Set(tags)
        
        return note
    }
}
```

#### 查询所有标签（用于侧边栏）

```swift
func fetchAllTags() async throws -> [SidebarFeature.State.Tag] {
    try await dbQueue.read { db in
        // 查询所有标签及其使用次数
        let tagCounts = try Row.fetchAll(
            db,
            sql: """
                SELECT tag, COUNT(*) as count 
                FROM note_tags 
                JOIN notes ON note_tags.note_id = notes.noteId 
                WHERE notes.is_deleted = 0
                GROUP BY tag 
                ORDER BY count DESC, tag ASC
                """
        )
        
        return tagCounts.map { tagCount in
            SidebarFeature.State.Tag(
                name: tagCount["tag"],
                count: tagCount["count"]
            )
        }
    }
}
```

---

## 3. 文件存储（.nota 格式）

### 3.1 标签在文件中的存储

标签存储在 `.nota` 文件的 YAML front matter 中：

```yaml
---
note_id: A464F114-7334-42E8-B58C-69E82F10E461
title: 我的笔记
tags: [工作, 重要, Swift]
starred: true
pinned: false
created: 2024-01-01T00:00:00Z
updated: 2024-01-01T00:00:00Z
checksum: d41d8cd98f00b204e9800998ecf8427e
---

# Markdown 内容
```

**实现代码**（NotaFileManager）：
```swift
func generateNotaFileContent(from note: Note) throws -> String {
    var metadata: [String: Any] = [
        "note_id": note.noteId,
        "title": note.title,
        "tags": Array(note.tags),  // Set 转换为 Array
        // ... 其他元数据
    ]
    // ... 生成 YAML 和文件内容
}
```

---

## 4. UI 层实现

### 4.1 笔记列表中的标签显示

**位置**：`NoteRowView.swift`

**显示方式**：
- 在笔记卡片底部显示标签
- 最多显示 2 个标签
- 如果标签超过 2 个，显示 "+N" 表示还有更多标签

**代码实现**：
```swift
// 标签显示
if !note.tags.isEmpty {
    HStack(spacing: 4) {
        ForEach(Array(note.tags.prefix(2)), id: \.self) { tag in
            Text(tag)
                .font(.caption2)
                .foregroundStyle(Color(nsColor: .labelColor))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.accentColor.opacity(0.2))
                .cornerRadius(4)
        }
        if note.tags.count > 2 {
            Text("+\(note.tags.count - 2)")
                .font(.caption2)
                .foregroundStyle(Color(nsColor: .secondaryLabelColor))
        }
    }
}
```

**视觉效果**：
- 标签显示为带背景色的小标签
- 使用系统强调色（accentColor）的半透明背景
- 圆角设计，与整体 UI 风格一致

---

### 4.2 侧边栏中的标签列表

**位置**：`SidebarView.swift`

**功能**：
- 显示所有标签及其使用次数
- 点击标签可以筛选笔记
- 支持多选标签（AND 逻辑）

**代码实现**：
```swift
// 标签列表
if !store.tags.isEmpty {
    Section("标签") {
        ForEach(store.tags) { tag in
            Label {
                Text(tag.name)
            } icon: {
                Image(systemName: "tag")
            }
            .badge(tag.count)  // 显示使用次数
            .onTapGesture {
                store.send(.tagToggled(tag.name))  // 切换标签选择
            }
        }
    }
}
```

**交互逻辑**：
- 点击标签：切换标签的选中状态
- 多选标签：使用 AND 逻辑（笔记必须包含所有选中的标签）
- 标签选择状态保存在 `SidebarFeature.State.selectedTags: Set<String>`

---

### 4.3 标签筛选功能

**位置**：`NoteListFeature.swift`

**筛选逻辑**：
```swift
case .tags(let tags):
    // 笔记必须包含所有选中的标签（AND 逻辑）
    return !note.tags.isDisjoint(with: tags) && !note.isDeleted
```

**说明**：
- `isDisjoint` 返回 `true` 表示两个集合没有交集
- `!isDisjoint` 表示有交集，即笔记包含至少一个选中的标签
- 但实际实现中，如果 `selectedTags` 包含多个标签，需要笔记包含所有标签（AND 逻辑）

---

## 5. 用户如何为笔记添加标签

### 5.1 当前实现状态

**⚠️ 重要发现**：根据代码分析，**Nota4 目前没有提供用户界面来为笔记添加或编辑标签**。

**现状**：
- ✅ 数据层已完整实现（数据库存储、文件存储）
- ✅ UI 层已实现标签显示（列表、侧边栏）
- ✅ 标签筛选功能已实现
- ❌ **缺少标签编辑 UI**（添加、删除、修改标签）

### 5.2 标签的当前来源

标签目前只能通过以下方式获得：

1. **导入 .nota 文件时**
   - 如果导入的 `.nota` 文件包含标签元数据，标签会被自动导入
   - 标签存储在 YAML front matter 中

2. **程序创建**
   - 初始文档（使用说明、Markdown示例）在创建时设置了标签
   - 代码中可以直接设置 `note.tags`

3. **数据库直接操作**
   - 理论上可以通过数据库工具直接添加标签（不推荐）

---

## 6. 如何实现标签编辑功能（建议）

### 6.1 方案 1：在编辑器标题栏添加标签按钮

**位置**：`NoteEditorView.swift` 的标题栏区域

**UI 设计**：
```
[标题输入框] [星标] [置顶] [标签] [删除]
```

**实现步骤**：
1. 在标题栏添加标签按钮
2. 点击按钮显示标签编辑面板
3. 标签编辑面板包含：
   - 当前标签列表（可删除）
   - 标签输入框（可添加新标签）
   - 现有标签建议（从所有标签中选择）

### 6.2 方案 2：在笔记列表右键菜单添加标签选项

**位置**：`NoteRowView.swift` 的右键菜单

**UI 设计**：
```
右键菜单
├─ 星标
├─ 置顶
├─ 添加标签...
│  ├─ 工作
│  ├─ 学习
│  ├─ 生活
│  └─ 新建标签...
├─ ────────────
└─ 删除
```

### 6.3 方案 3：在编辑器工具栏添加标签管理

**位置**：`IndependentToolbar.swift`

**UI 设计**：
- 在"笔记"分组中添加"管理标签"按钮
- 点击后弹出标签编辑对话框

### 6.4 推荐实现方案

**推荐：方案 1 + 方案 2 组合**

1. **标题栏标签按钮**（快速访问）
   - 显示当前笔记的标签数量或前几个标签
   - 点击后弹出标签编辑面板

2. **右键菜单标签选项**（便捷操作）
   - 快速添加常用标签
   - 支持从现有标签中选择

---

## 7. 标签编辑 UI 设计建议

### 7.1 标签编辑面板

**布局**：
```
┌─────────────────────────────┐
│ 管理标签                     │
├─────────────────────────────┤
│ 当前标签：                   │
│ [工作] [学习] [重要] [×]    │
│                             │
│ 添加标签：                   │
│ [输入框] [添加]             │
│                             │
│ 常用标签：                   │
│ [工作] [学习] [生活] [项目] │
│                             │
│        [取消] [确定]        │
└─────────────────────────────┘
```

### 7.2 标签输入交互

**功能**：
- 支持直接输入新标签
- 支持从现有标签列表选择
- 支持删除已有标签（点击标签上的 ×）
- 标签自动补全（输入时显示匹配的现有标签）

### 7.3 TCA 状态管理

**State 扩展**：
```swift
// EditorFeature.State
struct TagEditState: Equatable {
    var isTagEditPanelVisible: Bool = false
    var currentTags: Set<String> = []
    var newTagInput: String = ""
    var availableTags: [String] = []  // 所有现有标签
}
```

**Action 扩展**：
```swift
// EditorFeature.Action
case showTagEditPanel
case hideTagEditPanel
case addTag(String)
case removeTag(String)
case updateTagInput(String)
case saveTags
```

---

## 8. 标签功能的数据流

### 8.1 标签添加流程

```
用户操作
    ↓
UI 层（EditorFeature）
    store.send(.addTag("工作"))
    ↓
Reducer 处理
    state.note.tags.insert("工作")
    ↓
保存到数据库
    noteRepository.updateNote(note)
    ↓
更新文件
    notaFileManager.updateNoteFile(note)
    ↓
刷新 UI
    noteList.loadNotes()
    sidebar.loadTags()
```

### 8.2 标签筛选流程

```
用户点击侧边栏标签
    ↓
SidebarFeature
    store.send(.tagToggled("工作"))
    ↓
更新 selectedTags
    state.selectedTags.insert("工作")
    ↓
通知 AppFeature
    AppFeature 更新 NoteListFeature.filter
    ↓
NoteListFeature 筛选笔记
    filter = .tags(["工作"])
    ↓
更新列表显示
    filteredNotes 只包含带"工作"标签的笔记
```

---

## 9. 标签功能限制和注意事项

### 9.1 当前限制

1. **没有标签编辑 UI**
   - 用户无法通过界面添加或删除标签
   - 只能通过导入文件或代码设置标签

2. **标签大小写敏感**
   - "工作" 和 "Work" 被视为不同标签
   - 建议在应用层统一转换为小写或提供大小写不敏感的比较

3. **标签没有颜色或图标**
   - 所有标签使用相同的样式
   - 无法为标签设置自定义颜色或图标

4. **标签没有层级结构**
   - 不支持嵌套标签（如 "工作/项目A"）
   - 所有标签都是平级的

### 9.2 性能考虑

1. **标签查询优化**
   - 使用索引 `idx_note_tags_tag` 加速标签筛选
   - 标签列表按使用次数排序，常用标签优先显示

2. **批量操作**
   - 更新标签时采用"先删除后插入"策略
   - 对于大量标签的笔记，可能需要优化更新逻辑

---

## 10. 未来改进建议

### 10.1 短期改进（P1）

1. **添加标签编辑 UI**
   - 在编辑器标题栏添加标签按钮
   - 实现标签编辑面板
   - 支持添加、删除、选择标签

2. **标签自动补全**
   - 输入标签时显示匹配的现有标签
   - 避免创建重复标签（大小写不同）

3. **标签大小写规范化**
   - 统一转换为小写存储
   - 显示时保持用户输入的大小写

### 10.2 中期改进（P2）

1. **标签颜色**
   - 允许用户为标签设置颜色
   - 在列表和侧边栏中显示标签颜色

2. **标签图标**
   - 支持为标签选择系统图标
   - 增强标签的视觉识别度

3. **标签统计**
   - 显示标签使用频率
   - 提供标签管理面板（合并、重命名、删除未使用标签）

### 10.3 长期改进（P3）

1. **嵌套标签**
   - 支持标签层级结构（如 "工作/项目A/任务1"）
   - 在侧边栏显示树形标签列表

2. **标签智能建议**
   - 基于笔记内容自动建议标签
   - 使用机器学习分析笔记主题

3. **标签导入导出**
   - 支持批量导入标签
   - 导出标签配置

---

## 11. 总结

### 11.1 已实现功能

- ✅ 数据模型：标签存储在数据库和文件中
- ✅ 数据层：完整的 CRUD 操作
- ✅ 标签显示：列表和侧边栏中显示标签
- ✅ 标签筛选：支持按标签筛选笔记
- ✅ 标签统计：侧边栏显示标签使用次数

### 11.2 缺失功能

- ❌ 标签编辑 UI：用户无法通过界面添加或删除标签
- ❌ 标签自动补全：输入标签时没有建议
- ❌ 标签管理：无法批量管理标签

### 11.3 用户如何添加标签（当前）

**目前用户无法通过 UI 添加标签**，只能通过：
1. 导入包含标签的 `.nota` 文件
2. 等待程序自动设置（如初始文档）

**建议**：尽快实现标签编辑 UI，这是标签功能的核心缺失部分。

---

## 📚 相关文件

### 数据模型
- `Nota4/Models/Note.swift` - Note 模型定义
- `Nota4/Services/DatabaseManager.swift` - 数据库表结构
- `Nota4/Services/NoteRepository.swift` - 标签 CRUD 操作
- `Nota4/Services/NotaFileManager.swift` - 标签文件存储

### UI 组件
- `Nota4/Features/NoteList/NoteRowView.swift` - 标签显示
- `Nota4/Features/Sidebar/SidebarView.swift` - 标签列表
- `Nota4/Features/Sidebar/SidebarFeature.swift` - 标签筛选逻辑

### 状态管理
- `Nota4/Features/NoteList/NoteListFeature.swift` - 标签筛选
- `Nota4/Features/Sidebar/SidebarFeature.swift` - 标签选择状态
- `Nota4/App/AppFeature.swift` - 标签筛选协调

---

**文档版本**: v1.0  
**最后更新**: 2025-01-17  
**维护者**: Nota4 开发团队


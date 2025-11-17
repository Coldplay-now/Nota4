# 搜索关键词搜不到问题诊断分析

**创建时间**: 2025-11-17 13:50:00  
**文档类型**: 问题诊断与解决方案  
**适用范围**: 笔记列表搜索功能的关键词搜索问题

---

## 一、问题描述

用户反馈：有些关键词搜索不到，询问是否需要清理索引重新做索引。

---

## 二、当前搜索机制分析

### 2.1 双层搜索机制

当前实现存在**双层搜索机制**，可能导致搜索结果不一致：

#### 第一层：数据库层面（FTS5 全文搜索）

**位置**: `NoteRepository.swift` 第 89-102 行

```swift
case .search(let keyword):
    // 使用 FTS5 全文搜索
    let noteIds = try String.fetchAll(
        db,
        sql: """
            SELECT noteId FROM notes_fts 
            WHERE notes_fts MATCH ? 
            LIMIT 100
        """,
        arguments: [keyword]  // ⚠️ 直接使用用户输入，未转义
    )
    request = request
        .filter(noteIds.contains(Note.Columns.noteId))
        .filter(Note.Columns.isDeleted == false)
```

**特点**:
- 使用 SQLite FTS5 全文搜索
- 在数据库层面进行搜索
- 直接使用用户输入的 `keyword`，**未进行转义或格式化**
- 限制返回 100 条结果

#### 第二层：应用层面（内存搜索）

**位置**: `NoteListFeature.swift` 第 66-78 行（`filteredNotes` 计算属性）

```swift
case .search(let keyword):
    // 不区分大小写的搜索
    let lowercaseKeyword = keyword.lowercased()
    let lowercaseTitle = note.title.lowercased()
    let lowercaseContent = note.content.lowercased()
    
    // 支持空格分词：每个词都必须匹配
    let keywords = lowercaseKeyword.split(separator: " ").map(String.init)
    let matches = keywords.allSatisfy { word in
        lowercaseTitle.contains(word) || lowercaseContent.contains(word)
    }
    
    return matches && !note.isDeleted
```

**特点**:
- 在内存中的 `notes` 数组中进行搜索
- 不区分大小写
- 支持多关键词（AND 逻辑）
- 子字符串匹配

### 2.2 搜索流程

```
用户输入 → searchText 变化 → 防抖（300ms）→ searchDebounced 
  → filter = .search(keyword) → loadNotes 
  → fetchNotes(filter: .search(keyword)) 
  → FTS5 搜索（数据库）→ 返回 noteIds 
  → 加载完整 Note 对象 → notesLoaded 
  → state.notes = notes 
  → filteredNotes 计算属性（内存搜索，但此时 notes 已经是从 FTS5 过滤后的结果）
```

**问题**: 如果 FTS5 搜索失败或返回空结果，`filteredNotes` 也会是空的，即使内存中有匹配的笔记。

---

## 三、问题根源分析

### 3.1 FTS5 搜索语法问题

#### 问题 1: 未转义特殊字符

**FTS5 特殊字符**:
- `"` (双引号) - 用于短语搜索
- `'` (单引号) - 用于短语搜索
- `\` (反斜杠) - 转义字符
- `*` (星号) - 前缀匹配
- `:` (冒号) - 列限定符
- `-` (减号) - 排除操作符
- `OR`, `AND`, `NOT` - 逻辑操作符

**当前实现**:
```swift
arguments: [keyword]  // ⚠️ 直接使用，未转义
```

**影响**:
- 如果用户输入包含特殊字符，FTS5 查询可能失败
- 例如：搜索 `"test"` 会被 FTS5 解释为短语搜索，而不是搜索包含引号的文本

#### 问题 2: FTS5 MATCH 语法要求

**FTS5 MATCH 语法**:
- 单个词：`keyword` - 匹配包含该词的文档
- 多个词（空格分隔）：`word1 word2` - 默认 **OR** 逻辑（匹配包含 word1 **或** word2 的文档）
- 短语搜索：`"phrase"` - 匹配完整短语
- AND 逻辑：`word1 AND word2` - 必须同时包含两个词
- 前缀匹配：`word*` - 匹配以 word 开头的词

**当前实现的问题**:
- 用户输入 `"swift ui"` → FTS5 解释为：匹配包含 "swift" **或** "ui" 的文档（OR 逻辑）
- 但应用层面的 `filteredNotes` 使用 AND 逻辑（所有词都必须匹配）
- **逻辑不一致**，可能导致搜索结果不匹配

#### 问题 3: 中文搜索支持

**FTS5 unicode61 tokenizer**:
- 支持 Unicode 字符（包括中文）
- 但分词方式可能与预期不同
- 中文通常按字符分词，而不是按词分词

**可能的问题**:
- 搜索 "笔记" → FTS5 可能按字符分词为 "笔" 和 "记"
- 导致搜索结果不准确

### 3.2 FTS5 索引更新问题

#### 问题 4: 索引未及时更新

**索引更新机制**:
- 通过数据库触发器自动更新
- `notes_fts_insert` - 插入时更新
- `notes_fts_update` - 更新时更新
- `notes_fts_delete` - 删除时更新

**可能的问题**:
1. **触发器失效**: 如果触发器被删除或未正确创建，索引不会更新
2. **迁移问题**: 如果数据库迁移失败，FTS5 表可能不存在
3. **数据不同步**: 如果笔记内容更新但触发器未触发，索引会过期

#### 问题 5: 索引数据不完整

**可能的原因**:
- 旧数据未迁移到 FTS5 索引
- 索引创建后新增的笔记未正确索引
- 索引损坏

### 3.3 搜索范围限制

#### 问题 6: 结果数量限制

**当前实现**:
```swift
LIMIT 100
```

**影响**:
- 如果匹配的笔记超过 100 条，只会返回前 100 条
- 可能导致某些笔记无法搜索到

### 3.4 数据同步问题

#### 问题 7: 内存数据与数据库不同步

**可能的原因**:
- `state.notes` 可能包含旧数据
- 笔记内容更新后，`state.notes` 未及时刷新
- `updateNoteInList` 只更新内存，不触发 FTS5 索引更新

---

## 四、诊断步骤

### 4.1 检查 FTS5 索引状态

**需要检查**:
1. FTS5 表是否存在
2. FTS5 索引中的数据量
3. 索引是否与 `notes` 表同步

**检查方法**:
```sql
-- 检查 FTS5 表是否存在
SELECT name FROM sqlite_master WHERE type='table' AND name='notes_fts';

-- 检查 FTS5 索引中的数据量
SELECT COUNT(*) FROM notes_fts;

-- 检查 notes 表中的数据量
SELECT COUNT(*) FROM notes WHERE is_deleted = 0;

-- 比较两者是否一致
```

### 4.2 检查触发器状态

**需要检查**:
1. 触发器是否存在
2. 触发器是否正确创建

**检查方法**:
```sql
-- 检查触发器
SELECT name, sql FROM sqlite_master WHERE type='trigger' AND name LIKE 'notes_fts%';
```

### 4.3 测试 FTS5 搜索

**测试方法**:
```sql
-- 测试简单搜索
SELECT noteId FROM notes_fts WHERE notes_fts MATCH 'swift';

-- 测试中文搜索
SELECT noteId FROM notes_fts WHERE notes_fts MATCH '笔记';

-- 测试多关键词搜索
SELECT noteId FROM notes_fts WHERE notes_fts MATCH 'swift ui';

-- 测试特殊字符
SELECT noteId FROM notes_fts WHERE notes_fts MATCH '"test"';
```

### 4.4 检查搜索关键词处理

**需要检查**:
1. 用户输入的关键词是否包含特殊字符
2. FTS5 查询语法是否正确
3. 是否需要转义或格式化

---

## 五、解决方案

### 5.1 方案 A: 修复 FTS5 搜索语法（推荐）

#### 5.1.1 转义特殊字符

**问题**: 用户输入可能包含 FTS5 特殊字符，导致查询失败

**解决方案**: 转义特殊字符

```swift
private func escapeFTS5Keyword(_ keyword: String) -> String {
    // FTS5 特殊字符需要转义
    var escaped = keyword
        .replacingOccurrences(of: "\"", with: "\"\"")  // 双引号转义
        .replacingOccurrences(of: "'", with: "''")     // 单引号转义
        .replacingOccurrences(of: "\\", with: "\\\\")  // 反斜杠转义
    
    // 移除其他特殊字符（可选）
    // escaped = escaped.replacingOccurrences(of: "*", with: "")
    // escaped = escaped.replacingOccurrences(of: ":", with: "")
    // escaped = escaped.replacingOccurrences(of: "-", with: "")
    
    return escaped
}
```

#### 5.1.2 构建 FTS5 查询（支持多关键词 AND 逻辑）

**问题**: FTS5 默认使用 OR 逻辑，但应用需要 AND 逻辑

**解决方案**: 构建 AND 查询

```swift
private func buildFTS5Query(keyword: String) -> String {
    // 转义特殊字符
    let escaped = escapeFTS5Keyword(keyword)
    
    // 分割关键词（支持空格分词）
    let words = escaped
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: " ")
        .map(String.init)
        .filter { !$0.isEmpty }
    
    guard !words.isEmpty else {
        // 空查询返回所有（使用空字符串）
        return "\"\""
    }
    
    // 构建 AND 查询：每个词都必须匹配
    // FTS5 AND 语法：word1 AND word2 AND word3
    let query = words.joined(separator: " AND ")
    
    return query
}
```

**示例**:
- 输入: `"swift ui"` → 输出: `"swift AND ui"` → 匹配同时包含两个词的文档
- 输入: `"笔记 markdown"` → 输出: `"笔记 AND markdown"` → 匹配同时包含两个词的文档

#### 5.1.3 更新 fetchNotes 方法

```swift
case .search(let keyword):
    guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        // 空搜索，返回所有未删除的笔记
        request = request.filter(Note.Columns.isDeleted == false)
        break
    }
    
    // 构建 FTS5 查询
    let ftsQuery = buildFTS5Query(keyword: keyword)
    
    // 使用 FTS5 全文搜索
    let noteIds = try String.fetchAll(
        db,
        sql: """
            SELECT noteId FROM notes_fts 
            WHERE notes_fts MATCH ? 
            LIMIT 1000
        """,
        arguments: [ftsQuery]
    )
    
    request = request
        .filter(noteIds.contains(Note.Columns.noteId))
        .filter(Note.Columns.isDeleted == false)
```

### 5.2 方案 B: 重建 FTS5 索引

#### 5.2.1 检查索引完整性

**诊断脚本**:
```swift
// 在 DatabaseManager 中添加诊断方法
func diagnoseFTS5Index() async throws -> (notesCount: Int, ftsCount: Int, isSynced: Bool) {
    try await dbQueue.read { db in
        let notesCount = try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM notes WHERE is_deleted = 0"
        ) ?? 0
        
        let ftsCount = try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM notes_fts"
        ) ?? 0
        
        let isSynced = notesCount == ftsCount
        
        return (notesCount, ftsCount, isSynced)
    }
}
```

#### 5.2.2 重建索引

**重建方法**:
```swift
func rebuildFTS5Index() async throws {
    try await dbQueue.write { db in
        // 1. 清空 FTS5 索引
        try db.execute(sql: "DELETE FROM notes_fts")
        
        // 2. 重新填充索引
        try db.execute(sql: """
            INSERT INTO notes_fts(rowid, noteId, title, content)
            SELECT id, noteId, title, content
            FROM notes
            WHERE is_deleted = 0
        """)
    }
}
```

### 5.3 方案 C: 回退到内存搜索（临时方案）

如果 FTS5 搜索问题无法快速解决，可以临时回退到内存搜索：

```swift
case .search(let keyword):
    // 临时方案：不使用 FTS5，在内存中搜索
    // 先加载所有未删除的笔记
    request = request.filter(Note.Columns.isDeleted == false)
    // 然后在 filteredNotes 中进行搜索（已实现）
    break
```

**注意**: 这会导致性能问题（需要加载所有笔记到内存），但可以确保搜索功能正常工作。

### 5.4 方案 D: 混合搜索（最佳方案）

结合 FTS5 和内存搜索，确保搜索结果的准确性：

```swift
case .search(let keyword):
    guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        request = request.filter(Note.Columns.isDeleted == false)
        break
    }
    
    // 尝试 FTS5 搜索
    let ftsQuery = buildFTS5Query(keyword: keyword)
    var noteIds: [String] = []
    
    do {
        noteIds = try String.fetchAll(
            db,
            sql: """
                SELECT noteId FROM notes_fts 
                WHERE notes_fts MATCH ? 
                LIMIT 1000
            """,
            arguments: [ftsQuery]
        )
    } catch {
        // FTS5 搜索失败，回退到加载所有笔记（在内存中搜索）
        print("⚠️ FTS5 搜索失败: \(error)，回退到内存搜索")
        request = request.filter(Note.Columns.isDeleted == false)
        break
    }
    
    // 如果 FTS5 返回结果，使用 FTS5 结果
    if !noteIds.isEmpty {
        request = request
            .filter(noteIds.contains(Note.Columns.noteId))
            .filter(Note.Columns.isDeleted == false)
    } else {
        // FTS5 无结果，回退到加载所有笔记（在内存中搜索）
        request = request.filter(Note.Columns.isDeleted == false)
    }
```

---

## 六、需要考虑的其他问题

### 6.1 性能优化

1. **索引维护**:
   - 定期检查索引完整性
   - 自动重建损坏的索引
   - 优化索引更新性能

2. **搜索优化**:
   - 缓存常用搜索结果
   - 优化 FTS5 查询性能
   - 考虑分页加载

### 6.2 用户体验

1. **搜索反馈**:
   - 显示搜索进度
   - 显示搜索结果数量
   - 提供搜索建议

2. **错误处理**:
   - FTS5 搜索失败时的友好提示
   - 自动回退到内存搜索
   - 提示用户重建索引

### 6.3 数据一致性

1. **索引同步**:
   - 确保索引与数据同步
   - 监控索引更新状态
   - 提供手动重建索引的功能

2. **数据验证**:
   - 验证索引完整性
   - 检测数据不一致
   - 自动修复问题

---

## 七、推荐解决方案

### 7.1 立即修复（高优先级）

1. **修复 FTS5 搜索语法**:
   - 转义特殊字符
   - 构建正确的 AND 查询
   - 处理空查询

2. **添加错误处理**:
   - FTS5 搜索失败时回退到内存搜索
   - 记录错误日志
   - 提示用户

### 7.2 中期优化（中优先级）

1. **索引诊断工具**:
   - 添加索引完整性检查
   - 提供重建索引功能
   - 监控索引状态

2. **搜索优化**:
   - 优化 FTS5 查询性能
   - 改进中文搜索支持
   - 支持更多搜索选项

### 7.3 长期改进（低优先级）

1. **统一搜索机制**:
   - 考虑统一使用 FTS5 或内存搜索
   - 避免双层搜索的不一致性

2. **高级搜索功能**:
   - 支持正则表达式
   - 支持大小写敏感
   - 支持全词匹配

---

## 八、实施建议

### 8.1 第一步：诊断问题

1. 添加诊断方法，检查 FTS5 索引状态
2. 测试 FTS5 搜索功能
3. 识别具体的问题（语法、索引、数据同步等）

### 8.2 第二步：修复 FTS5 搜索

1. 实现 `escapeFTS5Keyword` 方法
2. 实现 `buildFTS5Query` 方法（支持 AND 逻辑）
3. 更新 `fetchNotes` 方法使用新的查询构建

### 8.3 第三步：添加错误处理

1. FTS5 搜索失败时回退到内存搜索
2. 记录错误日志
3. 提供用户友好的错误提示

### 8.4 第四步：重建索引（如需要）

1. 提供重建索引的方法
2. 在应用启动时检查索引完整性
3. 必要时自动重建索引

---

## 九、总结

### 9.1 问题根源

1. **FTS5 搜索语法问题**: 未转义特殊字符，未构建正确的 AND 查询
2. **索引同步问题**: 索引可能未及时更新或损坏
3. **双层搜索不一致**: FTS5 使用 OR 逻辑，内存搜索使用 AND 逻辑

### 9.2 解决方案

1. **修复 FTS5 搜索语法**: 转义特殊字符，构建 AND 查询
2. **添加错误处理**: FTS5 失败时回退到内存搜索
3. **重建索引**: 提供诊断和重建工具

### 9.3 是否需要清理索引

**答案**: **可能需要**，但首先应该：
1. 诊断索引状态（检查数据量、完整性）
2. 修复 FTS5 搜索语法问题
3. 如果问题仍然存在，再考虑重建索引

**重建索引的时机**:
- 索引数据量与笔记数量不一致
- 索引损坏或无法使用
- 搜索功能完全失效

---

**分析完成时间**: 2025-11-17 13:50:00


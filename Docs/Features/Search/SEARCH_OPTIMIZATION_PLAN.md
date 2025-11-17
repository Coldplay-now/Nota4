# 搜索功能优化方案（TCA 兼容）

**创建时间**: 2025-11-17 13:55:00  
**文档类型**: 优化方案设计  
**适用范围**: 笔记列表搜索功能的优化，确保符合 TCA 状态管理机制

---

## 一、用户需求

### 1.1 搜索期望

用户期望的搜索行为：
- **输入一个字或一个词**（中文、英文、标点符号），都能准确搜索出来
- **搜索范围**：标题和正文
- **搜索准确性**：无论分词机制是什么，都能准确匹配

### 1.2 关键要求

1. **简单可靠**：不需要复杂的分词，直接进行文本匹配
2. **支持所有字符**：中文、英文、标点符号都能搜索
3. **标题和正文**：两个字段都要搜索
4. **符合 TCA**：严格遵循 TCA 状态管理机制

---

## 二、TCA 状态管理机制分析

### 2.1 当前实现（符合 TCA）

**状态定义**:
```swift
// NoteListFeature.State
var searchText: String = ""
var filter: Filter = .none
```

**Action 流程**:
```
用户输入 → binding(.set(\.searchText, text)) 
  → 防抖（300ms）→ searchDebounced(keyword) 
  → filter = .search(keyword) 
  → loadNotes 
  → fetchNotes(filter: .search(keyword)) 
  → notesLoaded(notes) 
  → state.notes = notes 
  → filteredNotes 计算属性（UI 自动更新）
```

**TCA 合规性**: ✅ **完全符合**
- 使用 `@BindingAction` 处理用户输入
- 使用 `.run` 进行异步操作（防抖）
- 状态更新通过 Action → Reducer → State
- UI 通过 `WithPerceptionTracking` 自动更新

### 2.2 优化方案（保持 TCA 合规）

**原则**:
1. **不改变 TCA 架构**：保持现有的 Action → Reducer → State 流程
2. **只优化搜索算法**：在 `fetchNotes` 中优化 FTS5 查询，或在 `filteredNotes` 中优化内存搜索
3. **状态管理不变**：`searchText` 和 `filter` 的状态管理逻辑保持不变

---

## 三、搜索机制优化方案

### 3.1 方案选择

根据用户需求（"无论分词机制是什么，都能准确搜索"），推荐：

**方案：简化搜索，使用内存搜索（推荐）**

**理由**:
1. **简单可靠**：不依赖 FTS5 的分词机制，直接进行文本匹配
2. **支持所有字符**：`String.contains()` 支持所有 Unicode 字符（中文、英文、标点符号）
3. **完全控制**：可以精确控制搜索逻辑，确保准确性
4. **符合 TCA**：不改变状态管理，只优化搜索算法

### 3.2 实现方案

#### 方案 A: 纯内存搜索（推荐）

**优点**:
- ✅ 简单可靠，不依赖 FTS5 分词
- ✅ 支持所有字符类型（中文、英文、标点符号）
- ✅ 完全控制搜索逻辑
- ✅ 符合用户期望（"无论分词机制是什么"）

**缺点**:
- ⚠️ 需要加载所有笔记到内存（但当前已实现）
- ⚠️ 对于超大量笔记可能有性能问题（但可以通过分页优化）

**实现**:
```swift
// 在 NoteRepository.fetchNotes 中
case .search(let keyword):
    // 不使用 FTS5，直接返回所有未删除的笔记
    // 搜索逻辑在 filteredNotes 计算属性中实现（已实现）
    request = request.filter(Note.Columns.isDeleted == false)
    break
```

**搜索逻辑**（已在 `filteredNotes` 中实现）:
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

**改进**（支持单个字符和标点符号）:
```swift
case .search(let keyword):
    guard !keyword.isEmpty else {
        return !note.isDeleted
    }
    
    // 不区分大小写的搜索
    let lowercaseKeyword = keyword.lowercased()
    let lowercaseTitle = note.title.lowercased()
    let lowercaseContent = note.content.lowercased()
    
    // 支持空格分词：每个词都必须匹配
    let keywords = lowercaseKeyword.split(separator: " ").map(String.init)
    
    // 如果只有一个关键词（可能是单个字符或标点符号），直接匹配
    if keywords.count == 1 {
        let word = keywords[0]
        let matches = lowercaseTitle.contains(word) || lowercaseContent.contains(word)
        return matches && !note.isDeleted
    }
    
    // 多个关键词：每个词都必须匹配（AND 逻辑）
    let matches = keywords.allSatisfy { word in
        lowercaseTitle.contains(word) || lowercaseContent.contains(word)
    }
    
    return matches && !note.isDeleted
```

#### 方案 B: 改进 FTS5 搜索（备选）

**优点**:
- ✅ 性能更好（数据库层面搜索）
- ✅ 支持大量笔记

**缺点**:
- ⚠️ 依赖 FTS5 的分词机制
- ⚠️ 可能不支持某些字符（标点符号、特殊字符）
- ⚠️ 需要处理 FTS5 语法转义
- ⚠️ 中文分词可能不准确

**实现**:
```swift
// 构建 FTS5 查询，支持所有字符类型
private func buildFTS5Query(keyword: String) -> String {
    // 转义特殊字符
    let escaped = keyword
        .replacingOccurrences(of: "\"", with: "\"\"")
        .replacingOccurrences(of: "'", with: "''")
        .replacingOccurrences(of: "\\", with: "\\\\")
    
    // 分割关键词
    let words = escaped
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .split(separator: " ")
        .map(String.init)
        .filter { !$0.isEmpty }
    
    guard !words.isEmpty else {
        return "\"\""  // 空查询匹配所有
    }
    
    // 构建 AND 查询
    let query = words.joined(separator: " AND ")
    return query
}
```

**问题**: FTS5 的 unicode61 tokenizer 可能无法正确处理：
- 单个标点符号（如 `.`, `,`, `!`）
- 某些特殊字符
- 中文单字（可能被分词）

---

## 四、推荐方案：纯内存搜索

### 4.1 方案概述

**核心思路**:
- 移除 FTS5 搜索，使用纯内存搜索
- 在 `filteredNotes` 计算属性中实现搜索逻辑
- 使用 `String.contains()` 进行简单可靠的文本匹配

### 4.2 TCA 状态管理（保持不变）

**状态定义**（不变）:
```swift
// NoteListFeature.State
var searchText: String = ""
var filter: Filter = .none
```

**Action 流程**（不变）:
```swift
case .binding(\.searchText):
    // 防抖搜索
    return .run { [searchText = state.searchText] send in
        try await mainQueue.sleep(for: .milliseconds(300))
        await send(.searchDebounced(searchText))
    }
    .cancellable(id: CancelID.search, cancelInFlight: true)

case .searchDebounced(let keyword):
    guard !keyword.isEmpty else {
        state.filter = .category(.all)
        return .send(.loadNotes)
    }
    state.filter = .search(keyword)
    return .send(.loadNotes)
```

**Reducer 逻辑**（不变）:
- 保持现有的 TCA 模式
- 只修改 `fetchNotes` 的搜索实现

### 4.3 搜索算法优化

**位置**: `NoteListFeature.State.filteredNotes` 计算属性

**优化后的搜索逻辑**:
```swift
case .search(let keyword):
    guard !keyword.isEmpty else {
        return !note.isDeleted
    }
    
    // 不区分大小写的搜索
    let lowercaseKeyword = keyword.lowercased()
    let lowercaseTitle = note.title.lowercased()
    let lowercaseContent = note.content.lowercased()
    
    // 支持空格分词：每个词都必须匹配
    let keywords = lowercaseKeyword.split(separator: " ").map(String.init)
    
    // 单个关键词（可能是单个字符、标点符号、中文单字）
    if keywords.count == 1 {
        let word = keywords[0]
        // 直接使用 contains，支持所有字符类型
        let matches = lowercaseTitle.contains(word) || lowercaseContent.contains(word)
        return matches && !note.isDeleted
    }
    
    // 多个关键词：每个词都必须匹配（AND 逻辑）
    let matches = keywords.allSatisfy { word in
        lowercaseTitle.contains(word) || lowercaseContent.contains(word)
    }
    
    return matches && !note.isDeleted
```

**特点**:
- ✅ 支持所有字符类型（中文、英文、标点符号）
- ✅ 简单可靠，不依赖分词机制
- ✅ 完全控制搜索逻辑
- ✅ 符合用户期望

### 4.4 数据库查询优化

**位置**: `NoteRepository.fetchNotes`

**修改**:
```swift
case .search(let keyword):
    // 不使用 FTS5，直接返回所有未删除的笔记
    // 搜索逻辑在 filteredNotes 计算属性中实现
    request = request.filter(Note.Columns.isDeleted == false)
    // 不再使用 FTS5 搜索
    break
```

**优点**:
- 简化实现，移除 FTS5 依赖
- 避免 FTS5 语法和分词问题
- 确保搜索准确性

---

## 五、TCA 合规性验证

### 5.1 状态管理

✅ **符合 TCA**:
- 使用 `@ObservableState` 标记状态
- 使用 `@BindingAction` 处理用户输入
- 状态更新通过 Action → Reducer → State 流程

### 5.2 异步操作

✅ **符合 TCA**:
- 使用 `.run` 进行异步操作（防抖）
- 使用 `CancelID` 取消之前的操作
- 通过 `send` 发送 Action 更新状态

### 5.3 UI 更新

✅ **符合 TCA**:
- 使用 `WithPerceptionTracking` 追踪状态变化
- UI 自动响应状态更新
- 计算属性 `filteredNotes` 自动重新计算

### 5.4 副作用处理

✅ **符合 TCA**:
- 数据库查询通过 `@Dependency` 注入
- 异步操作在 `.run` 闭包中执行
- 错误处理通过 `Result` 类型

---

## 六、实施计划

### 6.1 阶段 1: 移除 FTS5 搜索

**文件**: `Nota4/Nota4/Services/NoteRepository.swift`

**修改**:
```swift
case .search(let keyword):
    // 不使用 FTS5，直接返回所有未删除的笔记
    // 搜索逻辑在 filteredNotes 计算属性中实现
    request = request.filter(Note.Columns.isDeleted == false)
    break
```

**影响**:
- 移除 FTS5 搜索依赖
- 简化代码逻辑
- 确保搜索准确性

### 6.2 阶段 2: 优化内存搜索算法

**文件**: `Nota4/Nota4/Features/NoteList/NoteListFeature.swift`

**修改**: `filteredNotes` 计算属性中的搜索逻辑

**优化点**:
1. 支持单个字符搜索（中文单字、英文单字母、标点符号）
2. 支持多关键词搜索（AND 逻辑）
3. 确保所有字符类型都能搜索

### 6.3 阶段 3: 测试验证

**测试用例**:
1. 单个中文字符：搜索 "笔"
2. 单个英文字母：搜索 "s"
3. 标点符号：搜索 "."
4. 中文词：搜索 "笔记"
5. 英文词：搜索 "swift"
6. 混合：搜索 "笔记 markdown"
7. 特殊字符：搜索 "test-v1"
8. 空搜索：清空搜索框

---

## 七、性能考虑

### 7.1 当前性能

**内存搜索性能**:
- 搜索在内存中的 `notes` 数组中进行
- 使用 `String.contains()` 进行匹配
- 对于大量笔记（>1000 条），可能有性能问题

### 7.2 优化建议

1. **分页加载**:
   - 只加载当前页的笔记
   - 搜索时只搜索已加载的笔记

2. **缓存优化**:
   - 缓存搜索结果
   - 避免重复计算

3. **异步搜索**:
   - 对于大量笔记，考虑异步搜索
   - 显示搜索进度

**注意**: 根据 PRD，当前专注于简单高效的关键词搜索，性能优化可以在后续迭代中考虑。

---

## 八、总结

### 8.1 TCA 合规性

✅ **完全符合 TCA 状态管理机制**:
- 状态定义使用 `@ObservableState`
- Action 处理使用标准的 TCA 模式
- 异步操作使用 `.run` 和 `CancelID`
- UI 更新通过 `WithPerceptionTracking`

### 8.2 搜索准确性

✅ **满足用户期望**:
- 支持所有字符类型（中文、英文、标点符号）
- 不依赖分词机制，直接进行文本匹配
- 在标题和正文中都能搜索
- 简单可靠，易于维护

### 8.3 推荐方案

**方案：纯内存搜索**
- 移除 FTS5 搜索依赖
- 优化 `filteredNotes` 中的搜索逻辑
- 确保所有字符类型都能准确搜索
- 保持 TCA 状态管理机制不变

---

**方案完成时间**: 2025-11-17 13:55:00


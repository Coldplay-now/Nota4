# Swift 编码规范

**版本**: v1.0.0  
**创建日期**: 2025-11-16  
**适用范围**: Nota4 项目

---

## 🎯 核心原则

1. **清晰优于简洁** - 代码应该易于理解
2. **一致性** - 遵循统一的代码风格
3. **类型安全** - 充分利用 Swift 类型系统
4. **Swift 风格** - 使用 Swift 惯用法，而非移植其他语言的写法

---

## 📝 命名规范

### 类型命名

```swift
// ✅ 好的命名：UpperCamelCase，描述性强
struct Note { }
class DatabaseManager { }
enum ViewMode { }
protocol NotaFileManagerProtocol { }

// ❌ 避免
struct note { }          // 首字母应大写
class DBMgr { }          // 避免缩写
enum vm { }              // 不够描述性
```

### 变量和常量

```swift
// ✅ lowerCamelCase，描述性强
let noteTitle: String
var isLoading: Bool
let maximumRetryCount = 3

// ❌ 避免
let NoteTitle: String    // 应该首字母小写
var loading: Bool        // 不够清晰，用 isLoading
let MAX_RETRY = 3        // Swift 中不用全大写常量
```

### 函数命名

```swift
// ✅ 动词开头，参数标签清晰
func loadNote(with id: String) async throws -> Note
func save(_ note: Note) async throws
func fetchNotes(in category: Category) async throws -> [Note]

// ❌ 避免
func note(id: String)           // 应该是动词
func saveNote(note: Note)       // 参数名冗余
func get_notes()                // 使用下划线
```

### Bool 类型命名

```swift
// ✅ is/has/should 前缀
var isLoading: Bool
var hasUnsavedChanges: Bool
var shouldAutoSave: Bool

// ❌ 避免
var loading: Bool        // 不清晰
var saved: Bool          // 应该是 isSaved
```

---

## 🏗️ TCA 特定规范

### Feature 结构

```swift
// ✅ 标准 Feature 结构
struct EditorFeature: Reducer {
    // 1. State
    struct State: Equatable {
        var selectedNoteId: String?
        var note: Note?
        var content: String = ""
        var isSaving: Bool = false
    }
    
    // 2. Action
    enum Action: Equatable {
        // 用户动作
        case contentChanged(String)
        case saveButtonTapped
        
        // 系统事件
        case noteLoaded(Result<Note, Error>)
        case saveCompleted(Result<Note, Error>)
        
        // 定时器
        case autoSave
    }
    
    // 3. Dependencies
    @Dependency(\.noteRepository) var noteRepository
    
    // 4. Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // ...
            }
        }
    }
}
```

### Action 命名约定

```swift
enum Action {
    // ✅ 用户触发：过去时
    case saveButtonTapped
    case noteSelected(String)
    case searchQueryChanged(String)
    
    // ✅ 系统事件：过去时 + ed/Completed
    case notesLoaded([Note])
    case saveCompleted(Result<Note, Error>)
    
    // ✅ 委托事件：名词
    case delegate(Delegate)
    
    enum Delegate {
        case noteUpdated(Note)
    }
}
```

### Effect 模式

```swift
// ✅ 使用 .run
case .loadNote(let id):
    return .run { send in
        do {
            let note = try await noteRepository.fetchNote(id: id)
            await send(.noteLoaded(.success(note)))
        } catch {
            await send(.noteLoaded(.failure(error)))
        }
    }

// ✅ 防抖
case .searchQueryChanged(let query):
    state.searchQuery = query
    return .run { send in
        try await Task.sleep(for: .milliseconds(300))
        await send(.performSearch(query))
    }
    .cancel

ellationId: CancelID.search)
```

---

## 💾 代码组织

### 文件结构

```swift
// 文件：EditorFeature.swift

import ComposableArchitecture
import Foundation

// MARK: - Editor Feature

struct EditorFeature: Reducer {
    // MARK: - State
    struct State: Equatable { }
    
    // MARK: - Action
    enum Action: Equatable { }
    
    // MARK: - Dependencies
    @Dependency(\.noteRepository) var noteRepository
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> { }
}

// MARK: - View Model Extensions

extension EditorFeature.State {
    var hasUnsavedChanges: Bool { }
}

// MARK: - Helper Methods

private extension EditorFeature {
    func validateInput() -> Bool { }
}
```

### MARK 注释使用

```swift
// MARK: - 主要章节（顶级）
// MARK: 次级章节
// MARK: - Private（私有部分）
```

---

## ✨ Swift 最佳实践

### 可选值处理

```swift
// ✅ 使用 guard let
func loadNote(id: String?) {
    guard let id = id else { return }
    // 使用 id
}

// ✅ 使用 if let 处理单个可选值
if let note = note {
    print(note.title)
}

// ✅ 使用 ?? 提供默认值
let title = note?.title ?? "无标题"

// ❌ 避免强制解包（除非绝对确定）
let title = note!.title  // 危险！
```

### 错误处理

```swift
// ✅ 使用 Result 类型
enum NoteError: Error {
    case notFound(String)
    case saveFailed(Error)
}

func fetchNote(id: String) async -> Result<Note, NoteError> {
    // ...
}

// ✅ 使用 throws
func saveNote(_ note: Note) async throws {
    // ...
}

// ✅ 在 Reducer 中处理错误
case .saveNote(let note):
    return .run { send in
        do {
            try await noteRepository.save(note)
            await send(.saveCompleted(.success(note)))
        } catch {
            await send(.saveCompleted(.failure(error)))
        }
    }
```

### 集合操作

```swift
// ✅ 使用高阶函数
let titles = notes.map { $0.title }
let starredNotes = notes.filter { $0.isStarred }
let totalWords = notes.reduce(0) { $0 + $1.wordCount }

// ✅ 使用 compactMap 过滤 nil
let noteIds = notes.compactMap { $0.id }

// ✅ 使用 first(where:)
let note = notes.first(where: { $0.id == targetId })
```

---

## 🔒 访问控制

```swift
// ✅ 默认使用最严格的访问级别
private let databaseQueue: DatabaseQueue
fileprivate var cache: [String: Note] = [:]
internal struct Configuration { }
public protocol NotaService { }

// 规则：
// - private: 文件内使用
// - fileprivate: 同文件内扩展使用
// - internal: 模块内使用（默认）
// - public: 跨模块使用
```

---

## 📐 代码格式

### 缩进和空格

```swift
// ✅ 4 空格缩进
func example() {
    if condition {
        doSomething()
    }
}

// ✅ 参数换行对齐
func longFunctionName(
    firstParameter: String,
    secondParameter: Int,
    thirdParameter: Bool
) {
    // ...
}
```

### 行长度

- 建议：80-100 字符
- 最大：120 字符
- 超过时换行

### 空行

```swift
// ✅ 函数间空一行
func functionOne() {
    // ...
}

func functionTwo() {
    // ...
}

// ✅ 逻辑块间空一行
let notes = fetchNotes()

let filteredNotes = notes.filter { $0.isStarred }

return filteredNotes
```

---

## 🧪 测试代码规范

### 测试命名

```swift
// ✅ test + 功能描述
func testLoadNoteSuccess() async { }
func testSaveNoteWithValidation() async { }
func testSearchWithEmptyQuery() async { }

// ✅ Given-When-Then 结构
func testDeleteNote() async {
    // Given
    let note = Note.mock()
    
    // When
    await store.send(.deleteNote(note.id))
    
    // Then
    XCTAssertNil(store.state.selectedNote)
}
```

---

## 🛠️ SwiftLint 配置

项目使用 SwiftLint 自动检查代码风格。

主要规则：
- `line_length`: 120
- `type_name`: PascalCase
- `identifier_name`: camelCase
- `force_cast`: 禁止
- `force_unwrap`: 警告
- `trailing_whitespace`: 禁止

查看完整配置：`.swiftlint.yml`

---

## 📚 参考资料

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Google Swift Style Guide](https://google.github.io/swift/)
- [Ray Wenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)
- [TCA 最佳实践](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/bestpractices)

---

**维护者**: Nota4 开发团队  
**最后更新**: 2025-11-16


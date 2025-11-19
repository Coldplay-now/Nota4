# 基于 TCA 状态管理机制的 Undo/Redo 优化方案

**分析时间**: 2025-11-18 15:04:15  
**目标**: 结合 TCA 状态管理机制优化 undo/redo 功能，解决当前崩溃问题并提升架构一致性

## 当前实现分析

### 1. 现有 Undo/Redo 实现

**位置**: `Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift`

**实现方式**：
- 直接使用 `NSTextView` 的 `NSUndoManager`
- 通过 `shouldChangeText` 和 `didChangeText` 自动注册 undo 操作
- 通过 `NotificationCenter` 通知执行替换操作（支持 undo/redo）
- 使用 `beginUndoGrouping()` 和 `endUndoGrouping()` 分组操作

**优点**：
- ✅ 性能好：文本输入级别的 undo/redo 由系统处理，无需额外开销
- ✅ 用户体验好：支持细粒度的撤销（每个字符、每个单词）
- ✅ 与系统集成：自动支持 Cmd+Z/Cmd+Shift+Z 快捷键

**缺点**：
- ❌ 不在 TCA 状态管理中：无法追踪 undo/redo 操作
- ❌ 内存安全问题：Coordinator 被释放时，undo stack 中可能仍有引用
- ❌ 状态不一致：TCA state 和 NSUndoManager 状态可能不同步
- ❌ 难以测试：无法在测试中验证 undo/redo 行为

### 2. 当前崩溃问题

**问题根源**（详见 `CRASH_ANALYSIS_NSUNDOMANAGER.md`）：
1. Coordinator 在 undo group 未结束时被释放
2. 延迟执行闭包中捕获了强引用的 `self`
3. Undo stack 中保存了对已释放对象的引用

## TCA Undo/Redo 设计原则

### 1. 分层管理策略

**文本输入级别**（高频操作）：
- 继续使用 `NSUndoManager`（性能考虑）
- 但需要修复内存安全问题

**高级操作级别**（格式化、插入、替换等）：
- 在 TCA 层管理 undo/redo
- 记录操作历史到 state
- 通过 Action 触发 undo/redo

### 2. TCA Undo/Redo 架构

#### 方案A：完全 TCA 管理（不推荐）

**实现**：
- 所有文本操作都通过 TCA Action
- 在 state 中维护操作历史栈
- 通过 Reducer 处理 undo/redo

**缺点**：
- ❌ 性能问题：每个字符输入都触发 TCA action，开销大
- ❌ 实现复杂：需要重写大量代码
- ❌ 用户体验差：undo/redo 响应可能延迟

#### 方案B：混合管理（推荐）

**实现**：
- **文本输入**：继续使用 `NSUndoManager`，但修复内存安全问题
- **高级操作**：在 TCA 层管理，记录到操作历史栈
- **状态同步**：确保 TCA state 和 NSUndoManager 状态一致

**优点**：
- ✅ 性能好：文本输入由系统处理
- ✅ 架构一致：高级操作在 TCA 层管理
- ✅ 可测试：高级操作的 undo/redo 可以测试
- ✅ 可追踪：操作历史在 state 中可见

#### 方案C：TCA 包装 NSUndoManager（折中方案）

**实现**：
- 在 TCA state 中保存 undo/redo 能力状态（canUndo, canRedo）
- 通过 Action 触发 NSUndoManager 的 undo/redo
- 在操作完成后更新 state

**优点**：
- ✅ 保持现有性能优势
- ✅ 部分 TCA 集成
- ✅ 可以修复内存安全问题

**缺点**：
- ❌ 仍然依赖 NSUndoManager，无法完全控制
- ❌ 状态同步可能不一致

## 推荐方案：混合管理 + 内存安全修复

### 架构设计

```
┌─────────────────────────────────────────────────────────┐
│                    EditorFeature                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │  State:                                          │  │
│  │  - content: String                               │  │
│  │  - undoHistory: [EditorOperation]  (新增)        │  │
│  │  - redoHistory: [EditorOperation]  (新增)      │  │
│  │  - canUndo: Bool  (计算属性)                     │  │
│  │  - canRedo: Bool  (计算属性)                     │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Actions:                                        │  │
│  │  - undo                                          │  │
│  │  - redo                                          │  │
│  │  - performOperation(EditorOperation)            │  │
│  │  - contentChanged(String)  (文本输入)            │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          │ 文本输入级别
                          ▼
┌─────────────────────────────────────────────────────────┐
│              NSTextView + NSUndoManager                 │
│  - 处理字符级别的 undo/redo                              │
│  - 自动注册文本编辑操作                                  │
│  - 修复内存安全问题（weak self，清理资源）              │
└─────────────────────────────────────────────────────────┘
                          │
                          │ 高级操作级别
                          ▼
┌─────────────────────────────────────────────────────────┐
│              TCA Undo/Redo Stack                         │
│  - 记录格式化操作（加粗、斜体等）                       │
│  - 记录插入操作（图片、链接等）                         │
│  - 记录替换操作（查找替换）                             │
│  - 通过 Action 触发 undo/redo                           │
└─────────────────────────────────────────────────────────┘
```

### 实施步骤

#### 步骤1：修复内存安全问题（立即修复崩溃）

**文件**: `Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift`

**修改1：延迟执行中使用 weak self**
```swift
// 修改前
DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    self.isReplacing = false  // ⚠️ 可能 self 已释放
}

// 修改后
DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
    self?.isReplacing = false  // ✅ 安全访问
}
```

**修改2：在 deinit 中清理资源**
```swift
deinit {
    NotificationCenter.default.removeObserver(self)
    
    // 清理未完成的 undo group（防止崩溃）
    if let textView = textView, let undoManager = textView.undoManager {
        // 检查是否有未结束的 undo group
        while undoManager.groupingLevel > 0 {
            undoManager.endUndoGrouping()
        }
    }
}
```

**修改3：添加防护检查**
```swift
@objc func handleReplaceNotification(_ notification: Notification) {
    // 使用 weak 引用检查 textView 是否仍然有效
    guard let textView = textView,
          textView.window != nil,  // 确保 textView 仍然在视图层次中
          let undoManager = textView.undoManager else {
        return
    }
    
    // ... 其余代码 ...
}
```

#### 步骤2：在 EditorFeature 中添加 Undo/Redo 状态

**文件**: `Nota4/Nota4/Features/Editor/EditorFeature.swift`

**添加状态**：
```swift
@ObservableState
struct State: Equatable {
    // ... 现有状态 ...
    
    // MARK: - Undo/Redo State
    
    /// 高级操作历史栈（格式化、插入、替换等）
    var undoHistory: [EditorOperation] = []
    
    /// 重做历史栈
    var redoHistory: [EditorOperation] = []
    
    /// 最大历史记录数（防止内存占用过大）
    var maxHistoryCount: Int = 100
    
    /// 计算属性：是否可以撤销
    var canUndo: Bool {
        !undoHistory.isEmpty
    }
    
    /// 计算属性：是否可以重做
    var canRedo: Bool {
        !redoHistory.isEmpty
    }
}

// MARK: - Editor Operation

/// 编辑器操作（用于 undo/redo）
struct EditorOperation: Equatable {
    let id: String
    let type: OperationType
    let timestamp: Date
    
    /// 操作前的状态
    let beforeContent: String
    let beforeSelection: NSRange
    
    /// 操作后的状态
    let afterContent: String
    let afterSelection: NSRange
    
    enum OperationType: String, Equatable {
        case formatBold
        case formatItalic
        case formatCode
        case insertImage
        case insertLink
        case replaceAll
        case insertMarkdown
        // ... 其他高级操作
    }
}
```

#### 步骤3：添加 Undo/Redo Actions

**文件**: `Nota4/Nota4/Features/Editor/EditorFeature.swift`

**添加 Actions**：
```swift
enum Action: BindableAction {
    // ... 现有 actions ...
    
    // MARK: - Undo/Redo Actions
    
    /// 撤销操作
    case undo
    
    /// 重做操作
    case redo
    
    /// 执行高级操作（自动记录到 undo history）
    case performOperation(EditorOperation)
    
    /// 操作执行完成
    case operationCompleted(EditorOperation)
}
```

#### 步骤4：实现 Reducer 逻辑

**文件**: `Nota4/Nota4/Features/Editor/EditorFeature.swift`

**实现逻辑**：
```swift
case .undo:
    guard let lastOperation = state.undoHistory.last else {
        return .none
    }
    
    // 恢复操作前的状态
    state.content = lastOperation.beforeContent
    state.selectionRange = lastOperation.beforeSelection
    
    // 从 undo history 移除，添加到 redo history
    state.undoHistory.removeLast()
    state.redoHistory.append(lastOperation)
    
    // 限制历史记录数量
    if state.redoHistory.count > state.maxHistoryCount {
        state.redoHistory.removeFirst()
    }
    
    return .none

case .redo:
    guard let lastOperation = state.redoHistory.last else {
        return .none
    }
    
    // 恢复操作后的状态
    state.content = lastOperation.afterContent
    state.selectionRange = lastOperation.afterSelection
    
    // 从 redo history 移除，添加到 undo history
    state.redoHistory.removeLast()
    state.undoHistory.append(lastOperation)
    
    // 限制历史记录数量
    if state.undoHistory.count > state.maxHistoryCount {
        state.undoHistory.removeFirst()
    }
    
    return .none

case .performOperation(let operation):
    // 保存操作前的状态
    let beforeOperation = EditorOperation(
        id: UUID().uuidString,
        type: operation.type,
        timestamp: Date(),
        beforeContent: state.content,
        beforeSelection: state.selectionRange,
        afterContent: operation.afterContent,
        afterSelection: operation.afterSelection
    )
    
    // 执行操作
    state.content = operation.afterContent
    state.selectionRange = operation.afterSelection
    
    // 添加到 undo history
    state.undoHistory.append(beforeOperation)
    
    // 清空 redo history（新操作后不能重做旧操作）
    state.redoHistory.removeAll()
    
    // 限制历史记录数量
    if state.undoHistory.count > state.maxHistoryCount {
        state.undoHistory.removeFirst()
    }
    
    return .send(.operationCompleted(beforeOperation))
```

#### 步骤5：在高级操作中记录到 Undo History

**示例：格式化加粗操作**

**修改前**：
```swift
case .insertMarkdown(.bold):
    let formatted = MarkdownFormatter.formatWrap(
        text: state.content,
        selection: state.selectionRange,
        prefix: "**",
        suffix: "**",
        placeholder: "粗体文本"
    )
    state.content = formatted.newText
    state.selectionRange = formatted.newSelection
    return .none
```

**修改后**：
```swift
case .insertMarkdown(.bold):
    let beforeContent = state.content
    let beforeSelection = state.selectionRange
    
    let formatted = MarkdownFormatter.formatWrap(
        text: state.content,
        selection: state.selectionRange,
        prefix: "**",
        suffix: "**",
        placeholder: "粗体文本"
    )
    
    // 创建操作记录
    let operation = EditorOperation(
        id: UUID().uuidString,
        type: .formatBold,
        timestamp: Date(),
        beforeContent: beforeContent,
        beforeSelection: beforeSelection,
        afterContent: formatted.newText,
        afterSelection: formatted.newSelection
    )
    
    // 执行操作并记录
    return .send(.performOperation(operation))
```

#### 步骤6：集成 NSTextView 的 Undo/Redo

**文件**: `Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift`

**添加方法**：
```swift
class Coordinator: NSObject, NSTextViewDelegate {
    // ... 现有代码 ...
    
    /// 检查是否可以撤销（文本级别）
    var canUndoText: Bool {
        textView?.undoManager?.canUndo ?? false
    }
    
    /// 检查是否可以重做（文本级别）
    var canRedoText: Bool {
        textView?.undoManager?.canRedo ?? false
    }
    
    /// 执行文本级别的撤销
    func undoText() {
        textView?.undoManager?.undo()
    }
    
    /// 执行文本级别的重做
    func redoText() {
        textView?.undoManager?.redo()
    }
}
```

#### 步骤7：在 EditorFeature 中统一处理 Undo/Redo

**文件**: `Nota4/Nota4/Features/Editor/EditorFeature.swift`

**实现逻辑**：
```swift
case .undo:
    // 优先使用文本级别的 undo（如果 NSTextView 有 undo stack）
    // 如果没有，使用 TCA 的 undo history
    return .run { send in
        // 检查 NSTextView 是否有 undo stack
        // 如果有，通过 NotificationCenter 通知执行文本级别的 undo
        // 如果没有，执行 TCA 的 undo
        
        // 这里需要访问 NSTextView，可以通过依赖注入或通知机制
        NotificationCenter.default.post(
            name: NSNotification.Name("PerformUndoInTextView"),
            object: nil
        )
        
        // 如果文本级别 undo 失败，执行 TCA undo
        // 这需要 Coordinator 通知 EditorFeature
    }
```

**更好的方案**：通过 Action 区分文本级别和高级操作级别

```swift
enum Action: BindableAction {
    // ... 现有 actions ...
    
    // MARK: - Undo/Redo Actions
    
    /// 撤销（自动选择文本级别或高级操作级别）
    case undo
    
    /// 撤销文本级别操作（字符、单词级别）
    case undoText
    
    /// 撤销高级操作（格式化、插入等）
    case undoOperation
    
    /// 重做（自动选择文本级别或高级操作级别）
    case redo
    
    /// 重做文本级别操作
    case redoText
    
    /// 重做高级操作
    case redoOperation
}
```

## 实施优先级

### 阶段1：立即修复崩溃（高优先级）

1. ✅ 修复延迟执行中的悬空引用（使用 `[weak self]`）
2. ✅ 在 `deinit` 中清理未完成的 undo group
3. ✅ 添加防护检查，确保对象有效性

**预计时间**: 30 分钟  
**风险**: 低（只修复内存安全问题）

### 阶段2：TCA 集成（中优先级）

1. 在 `EditorFeature.State` 中添加 undo/redo 状态
2. 添加 undo/redo Actions
3. 实现 Reducer 逻辑
4. 在高级操作中记录到 undo history

**预计时间**: 2-3 小时  
**风险**: 中（需要测试确保不影响现有功能）

### 阶段3：统一 Undo/Redo 处理（低优先级）

1. 实现文本级别和高级操作级别的统一处理
2. 添加 UI 反馈（显示 undo/redo 状态）
3. 添加测试

**预计时间**: 1-2 小时  
**风险**: 低（功能增强）

## TCA 架构优势

### 1. 可测试性

**当前问题**：
- 无法测试 NSUndoManager 的行为
- 无法验证 undo/redo 是否正确

**TCA 优势**：
```swift
func testUndoRedo() {
    let store = TestStore(initialState: EditorFeature.State()) {
        EditorFeature()
    }
    
    // 执行操作
    store.send(.performOperation(operation1))
    store.send(.performOperation(operation2))
    
    // 验证可以撤销
    XCTAssertTrue(store.state.canUndo)
    
    // 执行撤销
    store.send(.undo)
    
    // 验证状态恢复
    XCTAssertEqual(store.state.content, operation1.beforeContent)
    XCTAssertTrue(store.state.canRedo)
}
```

### 2. 可追踪性

**当前问题**：
- 无法知道用户执行了哪些操作
- 无法调试 undo/redo 问题

**TCA 优势**：
- 所有操作通过 Action 记录
- 可以在调试时查看操作历史
- 可以重放操作序列

### 3. 状态一致性

**当前问题**：
- TCA state 和 NSUndoManager 状态可能不同步
- 切换笔记时，undo stack 可能残留

**TCA 优势**：
- 单一数据源：所有状态在 TCA state 中
- 切换笔记时，可以清空 undo history
- 可以同步文本级别和高级操作级别的状态

### 4. 架构一致性

**当前问题**：
- Undo/redo 不在 TCA 层，架构不一致
- 难以与其他功能集成

**TCA 优势**：
- 所有操作通过 TCA Action
- 可以与其他 Feature 协调（如保存、预览等）
- 符合 TCA 的单向数据流原则

## 实施细节

### 1. 操作记录策略

**文本输入操作**：
- 不记录到 TCA undo history（性能考虑）
- 继续使用 NSUndoManager
- 但修复内存安全问题

**高级操作**：
- 记录到 TCA undo history
- 包括：格式化、插入、替换等
- 每次操作记录操作前后的完整状态

### 2. 状态同步

**问题**：文本输入会更新 `state.content`，但不会记录到 undo history

**解决方案**：
- 文本输入通过 `textDidChange` 更新 `state.content`
- 但不记录到 undo history（由 NSUndoManager 处理）
- 高级操作通过 `performOperation` 记录到 undo history

### 3. 切换笔记时的处理

**当前问题**：切换笔记时，NSUndoManager 的 undo stack 可能残留

**TCA 解决方案**：
```swift
case .loadNote(let noteId):
    // 清空 undo history
    state.undoHistory.removeAll()
    state.redoHistory.removeAll()
    
    // 加载笔记
    return .run { send in
        // ... 加载逻辑 ...
    }
```

### 4. 与 NSTextView 集成

**方案A：通过 NotificationCenter（当前方式）**

```swift
// EditorFeature 发送通知
NotificationCenter.default.post(
    name: NSNotification.Name("PerformUndoInTextView"),
    object: nil
)

// Coordinator 监听通知
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleUndoNotification),
    name: NSNotification.Name("PerformUndoInTextView"),
    object: nil
)
```

**方案B：通过 Coordinator 引用（不推荐）**

- 在 EditorFeature 中持有 Coordinator 引用
- 违反 TCA 架构原则（Feature 不应该持有 View 层引用）

**推荐方案A**：保持解耦，通过 NotificationCenter 通信

## 代码示例

### 完整的 EditorOperation 定义

```swift
// MARK: - Editor Operation

/// 编辑器操作（用于 undo/redo）
struct EditorOperation: Equatable {
    let id: String
    let type: OperationType
    let timestamp: Date
    
    /// 操作前的状态
    let beforeContent: String
    let beforeSelection: NSRange
    
    /// 操作后的状态
    let afterContent: String
    let afterSelection: NSRange
    
    enum OperationType: String, Equatable {
        // 格式化操作
        case formatBold
        case formatItalic
        case formatCode
        case formatStrikethrough
        case formatUnderline
        
        // 插入操作
        case insertImage
        case insertLink
        case insertCodeBlock
        case insertTable
        case insertHorizontalRule
        case insertMath
        case insertMermaid
        
        // 替换操作
        case replaceAll
        case replaceCurrent
        
        // Markdown 格式化
        case insertHeading(Int)  // 标题级别
        case insertList(ListType)  // 列表类型
        case insertBlockquote
        case insertFootnote(Int)  // 脚注编号
    }
    
    enum ListType: String, Equatable {
        case unordered
        case ordered
        case task
    }
}
```

### 完整的 Undo/Redo Reducer 逻辑

```swift
// MARK: - Undo/Redo Reducer Logic

case .undo:
    // 优先尝试文本级别的 undo
    NotificationCenter.default.post(
        name: NSNotification.Name("PerformUndoInTextView"),
        object: nil
    )
    
    // 如果文本级别 undo 失败，执行高级操作 undo
    guard let lastOperation = state.undoHistory.last else {
        return .none
    }
    
    // 恢复操作前的状态
    state.content = lastOperation.beforeContent
    state.selectionRange = lastOperation.beforeSelection
    
    // 从 undo history 移除，添加到 redo history
    state.undoHistory.removeLast()
    state.redoHistory.append(lastOperation)
    
    // 限制历史记录数量
    if state.redoHistory.count > state.maxHistoryCount {
        state.redoHistory.removeFirst()
    }
    
    return .none

case .redo:
    // 优先尝试文本级别的 redo
    NotificationCenter.default.post(
        name: NSNotification.Name("PerformRedoInTextView"),
        object: nil
    )
    
    // 如果文本级别 redo 失败，执行高级操作 redo
    guard let lastOperation = state.redoHistory.last else {
        return .none
    }
    
    // 恢复操作后的状态
    state.content = lastOperation.afterContent
    state.selectionRange = lastOperation.afterSelection
    
    // 从 redo history 移除，添加到 undo history
    state.redoHistory.removeLast()
    state.undoHistory.append(lastOperation)
    
    // 限制历史记录数量
    if state.undoHistory.count > state.maxHistoryCount {
        state.undoHistory.removeFirst()
    }
    
    return .none

case .performOperation(let operation):
    // 保存操作前的状态
    let beforeOperation = EditorOperation(
        id: UUID().uuidString,
        type: operation.type,
        timestamp: Date(),
        beforeContent: state.content,
        beforeSelection: state.selectionRange,
        afterContent: operation.afterContent,
        afterSelection: operation.afterSelection
    )
    
    // 执行操作
    state.content = operation.afterContent
    state.selectionRange = operation.afterSelection
    
    // 添加到 undo history
    state.undoHistory.append(beforeOperation)
    
    // 清空 redo history（新操作后不能重做旧操作）
    state.redoHistory.removeAll()
    
    // 限制历史记录数量
    if state.undoHistory.count > state.maxHistoryCount {
        state.undoHistory.removeFirst()
    }
    
    return .send(.operationCompleted(beforeOperation))
```

## 测试策略

### 1. 单元测试

```swift
func testUndoRedoOperation() {
    let store = TestStore(initialState: EditorFeature.State()) {
        EditorFeature()
    }
    
    // 初始状态
    store.assert { state in
        state.content = "Hello"
        state.canUndo = false
        state.canRedo = false
    }
    
    // 执行操作
    let operation = EditorOperation(
        id: "1",
        type: .formatBold,
        timestamp: Date(),
        beforeContent: "Hello",
        beforeSelection: NSRange(location: 0, length: 5),
        afterContent: "**Hello**",
        afterSelection: NSRange(location: 2, length: 5)
    )
    
    store.send(.performOperation(operation)) { state in
        state.content = "**Hello**"
        state.canUndo = true
        state.canRedo = false
    }
    
    // 执行撤销
    store.send(.undo) { state in
        state.content = "Hello"
        state.canUndo = false
        state.canRedo = true
    }
    
    // 执行重做
    store.send(.redo) { state in
        state.content = "**Hello**"
        state.canUndo = true
        state.canRedo = false
    }
}
```

### 2. 集成测试

- 测试文本输入级别的 undo/redo（NSUndoManager）
- 测试高级操作级别的 undo/redo（TCA）
- 测试混合场景（文本输入 + 高级操作）

### 3. 内存安全测试

- 测试 Coordinator 释放时的资源清理
- 测试延迟执行中的 weak self
- 测试 undo group 的正确配对

## 总结

### 推荐方案

**采用混合管理 + 内存安全修复**：

1. **立即修复崩溃**（阶段1）：
   - 使用 `[weak self]` 避免悬空引用
   - 在 `deinit` 中清理资源
   - 添加防护检查

2. **TCA 集成**（阶段2）：
   - 在 `EditorFeature.State` 中添加 undo/redo 状态
   - 高级操作记录到 TCA undo history
   - 文本输入继续使用 NSUndoManager

3. **统一处理**（阶段3）：
   - 实现文本级别和高级操作级别的统一接口
   - 添加 UI 反馈
   - 完善测试

### 架构优势

- ✅ **性能**：文本输入由系统处理，无额外开销
- ✅ **架构一致性**：高级操作在 TCA 层管理
- ✅ **可测试性**：可以测试高级操作的 undo/redo
- ✅ **可追踪性**：操作历史在 state 中可见
- ✅ **内存安全**：修复崩溃问题
- ✅ **状态一致性**：单一数据源，状态同步

### 实施优先级

1. **高优先级**：修复崩溃（阶段1）
2. **中优先级**：TCA 集成（阶段2）
3. **低优先级**：统一处理（阶段3）




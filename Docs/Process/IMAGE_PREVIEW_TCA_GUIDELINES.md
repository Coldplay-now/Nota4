# 图片预览渲染修复 - TCA 状态管理注意事项

**日期**: 2025-11-21  
**版本**: v1.0  
**状态**: 实施指南

---

## 📋 目录

- [1. TCA 核心原则](#1-tca-核心原则)
- [2. State 管理注意事项](#2-state-管理注意事项)
- [3. Action 设计注意事项](#3-action-设计注意事项)
- [4. Reducer 实现注意事项](#4-reducer-实现注意事项)
- [5. Effect 处理注意事项](#5-effect-处理注意事项)
- [6. 文件操作的特殊考虑](#6-文件操作的特殊考虑)
- [7. 常见陷阱和避免方法](#7-常见陷阱和避免方法)

---

## 1. TCA 核心原则

### 1.1 单向数据流

```
用户操作 → Action → Reducer → 新 State → View 更新
                ↓
            Effect (副作用)
                ↓
            新 Action → Reducer
```

**关键点**：
- ✅ 所有状态变化必须通过 Action → Reducer 流程
- ❌ 不要在 View 或 Service 中直接修改 State
- ✅ Effect 通过 `send` 发送新 Action 来更新 State

### 1.2 Reducer 是纯函数

**原则**：
- Reducer 应该是**可测试的纯函数**
- 给定相同的 State 和 Action，应该产生相同的结果
- 不应该有副作用（文件 I/O、网络请求等）

**例外**：
- 快速、同步的文件操作（如创建临时文件）可以在 reducer 中处理
- 但必须有错误处理和降级方案

---

## 2. State 管理注意事项

### 2.1 State 应该是纯数据结构

**✅ 正确**：
```swift
struct PreviewState: Equatable {
    var renderedHTML: String = ""
    var previewHTMLFileURL: URL? = nil  // 纯数据
    var isRendering: Bool = false
}
```

**❌ 错误**：
```swift
struct PreviewState: Equatable {
    var renderedHTML: String = ""
    var webView: WKWebView? = nil  // ❌ 不应该在 State 中存储 View 对象
    var fileManager: FileManager = .default  // ❌ 不应该在 State 中存储 Service
}
```

### 2.2 State 的 Equatable 一致性

**注意事项**：
- `URL?` 已经符合 `Equatable`，可以直接使用
- 如果添加自定义类型，确保符合 `Equatable`
- State 变化必须能被 SwiftUI 检测到

**示例**：
```swift
struct PreviewState: Equatable {
    var previewHTMLFileURL: URL? = nil  // ✅ URL 符合 Equatable
    
    // 如果 State 变化但 Equatable 返回 true，View 不会更新！
    // 确保所有相关属性都参与 Equatable 比较
}
```

### 2.3 状态归属原则

**原则**：状态应该放在最合适的层级

- `noteDirectory`: 属于 `EditorFeature.State`（笔记级别，多个功能共享）
- `previewHTMLFileURL`: 属于 `PreviewState`（预览功能专用）
- 避免状态重复和冗余

**✅ 正确**：
```swift
struct State: Equatable {
    var noteDirectory: URL? = nil  // 笔记级别
    var preview: PreviewState = PreviewState()  // 预览功能
}

struct PreviewState: Equatable {
    var previewHTMLFileURL: URL? = nil  // 预览专用
}
```

**❌ 错误**：
```swift
struct State: Equatable {
    var noteDirectory: URL? = nil
    var previewNoteDirectory: URL? = nil  // ❌ 重复，应该复用 noteDirectory
}
```

### 2.4 状态初始化

**原则**：
- State 应该有明确的初始值
- 可选类型使用 `nil` 作为初始值
- 避免未初始化的状态

```swift
struct PreviewState: Equatable {
    var previewHTMLFileURL: URL? = nil  // ✅ 明确的初始值
    var isRendering: Bool = false  // ✅ 明确的初始值
}
```

---

## 3. Action 设计注意事项

### 3.1 Action 应该是描述性的

**✅ 好的 Action**：
```swift
enum PreviewAction: Equatable {
    case renderCompleted(TaskResult<String>)  // 描述"渲染完成"这个事件
    case htmlFileCreated(URL?)  // 描述"HTML 文件已创建"
}
```

**❌ 不好的 Action**：
```swift
enum PreviewAction: Equatable {
    case writeHTMLToFile  // ❌ 太具体，描述实现而非意图
    case updateWebView  // ❌ 描述 UI 操作而非业务逻辑
}
```

### 3.2 Action 应该携带必要数据

**原则**：
- Action 应该携带足够的信息让 Reducer 做出决策
- 避免在 Reducer 中再次查询外部状态

**✅ 正确**：
```swift
case .preview(.renderCompleted(.success(let html))):
    // html 已经通过 Action 传递，无需再次查询
    state.preview.renderedHTML = html
```

**❌ 错误**：
```swift
case .preview(.renderCompleted):
    // ❌ 没有传递 html，需要在 Reducer 中查询
    let html = state.preview.renderedHTML  // 但这是旧值！
```

### 3.3 避免在 Action 中执行副作用

**原则**：
- Action 只是数据结构，不应该执行任何操作
- 所有副作用在 Reducer 的 `.run` Effect 中执行

**✅ 正确**：
```swift
// Action 定义
case preview(.renderCompleted(.success(let html)))

// Reducer 处理
case .preview(.renderCompleted(.success(let html))):
    // 在 Reducer 中处理副作用
    if let noteDir = state.noteDirectory {
        try? html.write(to: htmlFile, ...)
    }
```

**❌ 错误**：
```swift
// ❌ 在 Action 中执行副作用
case .preview(.renderCompleted(.success(let html))):
    FileManager.default.write(...)  // ❌ 不应该在这里
```

---

## 4. Reducer 实现注意事项

### 4.1 同步状态更新 vs 异步副作用

#### 同步操作（在 reducer 中直接处理）

**适用场景**：
- 快速、同步的操作
- 操作失败有降级方案
- 不需要等待外部资源

**示例**：创建临时 HTML 文件
```swift
case .preview(.renderCompleted(.success(let html))):
    state.preview.isRendering = false
    
    // 清理旧文件（同步，快速）
    if let oldFile = state.preview.previewHTMLFileURL {
        try? FileManager.default.removeItem(at: oldFile)
    }
    
    // 创建新文件（同步，但可能失败）
    if let noteDir = state.noteDirectory {
        let htmlFile = noteDir.appendingPathComponent(".preview_\(UUID().uuidString).html")
        do {
            try html.write(to: htmlFile, atomically: true, encoding: .utf8)
            state.preview.previewHTMLFileURL = htmlFile
        } catch {
            // 降级方案：使用 HTML 字符串
            state.preview.renderedHTML = html
            state.preview.previewHTMLFileURL = nil
        }
    } else {
        // noteDirectory 不存在，降级方案
        state.preview.renderedHTML = html
        state.preview.previewHTMLFileURL = nil
    }
    
    return .none
```

**关键点**：
- ✅ 使用 `try?` 处理错误，不抛出异常
- ✅ 提供降级方案（使用 HTML 字符串）
- ✅ 操作是同步的，不阻塞主线程

#### 异步操作（使用 `.run` Effect）

**适用场景**：
- 需要等待外部资源（网络、文件系统）
- 操作可能很慢
- 需要取消和去重

**示例**：渲染 Markdown
```swift
case .preview(.render):
    state.preview.isRendering = true
    
    let content = state.content  // 捕获当前内容
    let noteDirectory = state.noteDirectory  // 捕获目录
    
    return .run { send in
        let html = try await markdownRenderer.renderToHTML(
            markdown: content,
            options: RenderOptions(noteDirectory: noteDirectory)
        )
        await send(.preview(.renderCompleted(.success(html))))
    } catch: { error, send in
        await send(.preview(.renderCompleted(.failure(error))))
    }
    .cancellable(id: CancelID.previewRender, cancelInFlight: true)
```

**关键点**：
- ✅ 使用 `.run` 处理异步操作
- ✅ 捕获外部变量（`content`, `noteDirectory`）
- ✅ 通过 `send` 发送新 Action 更新 State
- ✅ 使用 `.cancellable` 支持取消和去重

### 4.2 状态依赖检查

**原则**：在执行操作前检查必要的状态是否存在

**示例**：
```swift
case .preview(.render):
    // 检查 noteDirectory 是否存在
    if state.noteDirectory == nil, let noteId = state.note?.noteId {
        // 先获取 noteDirectory，然后重新触发渲染
        return .run { send in
            do {
                let directory = try await notaFileManager.getNoteDirectory(for: noteId)
                await send(.noteDirectoryUpdated(directory))
                // 重新触发渲染
                await send(.preview(.render))
            } catch {
                // 获取失败，继续渲染（使用 nil noteDirectory）
                await send(.preview(.render))
            }
        }
    }
    
    // noteDirectory 已就绪或不可用，执行渲染
    let content = state.content
    let noteDirectory = state.noteDirectory
    
    return .run { send in
        let html = try await markdownRenderer.renderToHTML(...)
        await send(.preview(.renderCompleted(.success(html))))
    }
```

**关键点**：
- ✅ 检查状态依赖
- ✅ 如果依赖缺失，先获取依赖再继续
- ✅ 避免在依赖缺失时执行操作

### 4.3 资源清理的时机

**原则**：在适当的时机清理资源，避免泄漏

**清理时机**：
1. **笔记关闭时**：`.loadNote` 或 `.noteClosed`
2. **创建新资源前**：在 `.preview(.renderCompleted)` 中清理旧文件
3. **应用退出时**：通过 `Coordinator.deinit` 清理

**示例**：
```swift
case .loadNote(let noteId):
    // 清理当前笔记的预览临时文件
    if let htmlFile = state.preview.previewHTMLFileURL {
        try? FileManager.default.removeItem(at: htmlFile)
        state.preview.previewHTMLFileURL = nil
    }
    
    // 重置其他状态
    state.noteDirectory = nil
    state.preview.renderedHTML = ""
    // ...
    
    return .none

case .preview(.renderCompleted(.success(let html))):
    // 清理旧的临时文件
    if let oldFile = state.preview.previewHTMLFileURL {
        try? FileManager.default.removeItem(at: oldFile)
    }
    
    // 创建新文件
    // ...
```

**关键点**：
- ✅ 在状态变化时清理相关资源
- ✅ 使用 `try?` 处理清理失败（不应该影响主流程）
- ✅ 清理后更新 State（设置为 `nil`）

### 4.4 避免在 Reducer 中直接访问外部依赖

**原则**：通过 `@Dependency` 注入依赖，而不是直接访问

**✅ 正确**：
```swift
@Reducer
struct EditorFeature {
    @Dependency(\.notaFileManager) var notaFileManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            case .loadNote(let noteId):
                return .run { send in
                    let directory = try await notaFileManager.getNoteDirectory(for: noteId)
                    await send(.noteDirectoryUpdated(directory))
                }
        }
    }
}
```

**❌ 错误**：
```swift
case .loadNote(let noteId):
    // ❌ 直接访问单例
    let directory = try await NotaFileManager.shared.getNoteDirectory(for: noteId)
    // ❌ 在 reducer 中直接修改 state（应该是纯函数）
    state.noteDirectory = directory
```

---

## 5. Effect 处理注意事项

### 5.1 使用 `.run` 处理异步操作

**模式**：
```swift
return .run { send in
    // 异步操作
    let result = try await someAsyncOperation()
    await send(.operationCompleted(result))
} catch: { error, send in
    await send(.operationFailed(error))
}
```

**关键点**：
- ✅ 使用 `await` 等待异步操作
- ✅ 通过 `send` 发送新 Action 更新 State
- ✅ 使用 `catch` 处理错误

### 5.2 避免在 Effect 中直接修改 State

**原则**：
- ❌ 不要在 `.run` 中直接修改 `state`
- ✅ 通过 `send` 发送新的 Action 来更新 State

**✅ 正确**：
```swift
return .run { send in
    let html = try await markdownRenderer.renderToHTML(...)
    await send(.preview(.renderCompleted(.success(html))))  // 发送 Action
}
```

**❌ 错误**：
```swift
return .run { send in
    let html = try await markdownRenderer.renderToHTML(...)
    state.preview.renderedHTML = html  // ❌ 直接修改 state
    await send(.preview(.renderCompleted))
}
```

### 5.3 捕获外部变量

**原则**：在 `.run` 闭包中，捕获需要的 State 值

**原因**：
- State 可能在 Effect 执行期间变化
- 捕获的值确保使用正确的数据

**✅ 正确**：
```swift
case .preview(.render):
    let content = state.content  // 捕获当前内容
    let noteDirectory = state.noteDirectory  // 捕获目录
    
    return .run { send in
        // 使用捕获的变量
        let html = try await markdownRenderer.renderToHTML(
            markdown: content,  // 使用捕获的值
            options: RenderOptions(noteDirectory: noteDirectory)
        )
        await send(.preview(.renderCompleted(.success(html))))
    }
```

**❌ 错误**：
```swift
case .preview(.render):
    return .run { send in
        // ❌ 直接访问 state，可能在执行时已变化
        let html = try await markdownRenderer.renderToHTML(
            markdown: state.content,  // ❌ 可能不是渲染时的内容
            options: RenderOptions(noteDirectory: state.noteDirectory)
        )
    }
```

### 5.4 Effect 的取消和去重

**使用 `.cancellable`**：
```swift
return .run { send in
    // ...
}
.cancellable(id: CancelID.previewRender, cancelInFlight: true)
```

**参数说明**：
- `id`: Effect 的唯一标识符
- `cancelInFlight: true`: 如果新的相同 Effect 启动，取消旧的

**适用场景**：
- 防抖操作（如搜索、渲染）
- 可以取消的长时间操作

---

## 6. 文件操作的特殊考虑

### 6.1 文件操作的 TCA 模式

#### 方案 A：同步处理（推荐用于快速操作）

**适用场景**：
- 文件操作是快速、同步的
- 操作失败有降级方案
- 不需要等待外部资源

**示例**：创建临时 HTML 文件
```swift
case .preview(.renderCompleted(.success(let html))):
    // 同步创建临时文件
    if let noteDir = state.noteDirectory {
        let htmlFile = noteDir.appendingPathComponent(".preview_\(UUID().uuidString).html")
        do {
            try html.write(to: htmlFile, atomically: true, encoding: .utf8)
            state.preview.previewHTMLFileURL = htmlFile
        } catch {
            // 降级：使用 HTML 字符串
            state.preview.renderedHTML = html
            state.preview.previewHTMLFileURL = nil
        }
    }
    return .none
```

**优点**：
- 简单，无需额外的 Action
- 快速，不阻塞主线程（文件写入很快）
- 有降级方案

**缺点**：
- 如果文件操作很慢，可能阻塞 reducer
- 错误处理在 reducer 中

#### 方案 B：异步处理（用于可能很慢的操作）

**适用场景**：
- 文件操作可能很慢
- 需要显示进度
- 需要取消操作

**示例**：
```swift
case .preview(.renderCompleted(.success(let html))):
    state.preview.renderedHTML = html  // 先更新 HTML
    let noteDir = state.noteDirectory
    
    return .run { send in
        if let noteDir = noteDir {
            let htmlFile = noteDir.appendingPathComponent(".preview_\(UUID().uuidString).html")
            do {
                try html.write(to: htmlFile, atomically: true, encoding: .utf8)
                await send(.preview(.htmlFileCreated(htmlFile)))
            } catch {
                await send(.preview(.htmlFileCreated(nil)))  // 失败
            }
        }
    }

case .preview(.htmlFileCreated(let htmlFile)):
    state.preview.previewHTMLFileURL = htmlFile
    return .none
```

**优点**：
- 不阻塞 reducer
- 可以取消
- 可以显示进度

**缺点**：
- 需要额外的 Action
- 更复杂

**推荐**：对于临时 HTML 文件创建，使用**方案 A**（同步），因为文件写入很快。

### 6.2 文件操作的错误处理

**原则**：
- 文件操作失败不应该导致应用崩溃
- 提供降级方案
- 记录错误但不中断主流程

**模式**：
```swift
do {
    try html.write(to: htmlFile, ...)
    state.preview.previewHTMLFileURL = htmlFile
} catch {
    // 降级方案
    state.preview.renderedHTML = html
    state.preview.previewHTMLFileURL = nil
    // 可选：记录错误
    print("⚠️ [PREVIEW] 无法创建临时 HTML 文件: \(error)")
}
```

### 6.3 临时文件的生命周期管理

**原则**：
- 在 State 中跟踪临时文件路径
- 在适当的时机清理
- 避免文件泄漏

**清理时机**：
1. **创建新文件前**：清理旧文件
2. **笔记关闭时**：清理所有临时文件
3. **应用退出时**：通过 `Coordinator.deinit` 清理

**实现**：
```swift
// 创建新文件前清理
case .preview(.renderCompleted(.success(let html))):
    if let oldFile = state.preview.previewHTMLFileURL {
        try? FileManager.default.removeItem(at: oldFile)
    }
    // 创建新文件...

// 笔记关闭时清理
case .loadNote(let noteId):
    if let htmlFile = state.preview.previewHTMLFileURL {
        try? FileManager.default.removeItem(at: htmlFile)
        state.preview.previewHTMLFileURL = nil
    }
```

---

## 7. 常见陷阱和避免方法

### 7.1 陷阱 1：在 Effect 中直接访问 state

**❌ 错误**：
```swift
return .run { send in
    // ❌ state 可能在执行时已变化
    let html = try await render(state.content)
    await send(.preview(.renderCompleted(.success(html))))
}
```

**✅ 正确**：
```swift
let content = state.content  // 捕获
return .run { send in
    let html = try await render(content)  // 使用捕获的值
    await send(.preview(.renderCompleted(.success(html))))
}
```

### 7.2 陷阱 2：忘记清理资源

**❌ 错误**：
```swift
case .preview(.renderCompleted(.success(let html))):
    // ❌ 没有清理旧文件
    let htmlFile = noteDir.appendingPathComponent(".preview_\(UUID().uuidString).html")
    try html.write(to: htmlFile, ...)
    state.preview.previewHTMLFileURL = htmlFile
```

**✅ 正确**：
```swift
case .preview(.renderCompleted(.success(let html))):
    // ✅ 先清理旧文件
    if let oldFile = state.preview.previewHTMLFileURL {
        try? FileManager.default.removeItem(at: oldFile)
    }
    // 再创建新文件...
```

### 7.3 陷阱 3：在 reducer 中抛出异常

**❌ 错误**：
```swift
case .preview(.renderCompleted(.success(let html))):
    // ❌ 可能抛出异常，导致应用崩溃
    try html.write(to: htmlFile, ...)
```

**✅ 正确**：
```swift
case .preview(.renderCompleted(.success(let html))):
    // ✅ 使用 do-catch 处理错误
    do {
        try html.write(to: htmlFile, ...)
        state.preview.previewHTMLFileURL = htmlFile
    } catch {
        // 降级方案
        state.preview.renderedHTML = html
    }
```

### 7.4 陷阱 4：状态不同步

**❌ 错误**：
```swift
case .loadNote(let noteId):
    state.noteDirectory = nil  // 清空目录
    // ❌ 但没有清理依赖目录的临时文件
    // state.preview.previewHTMLFileURL 仍然指向旧目录的文件
```

**✅ 正确**：
```swift
case .loadNote(let noteId):
    // ✅ 同时清理相关资源
    if let htmlFile = state.preview.previewHTMLFileURL {
        try? FileManager.default.removeItem(at: htmlFile)
        state.preview.previewHTMLFileURL = nil
    }
    state.noteDirectory = nil
```

### 7.5 陷阱 5：竞态条件

**❌ 错误**：
```swift
case .preview(.render):
    // ❌ 没有检查 noteDirectory 是否存在
    return .run { send in
        let html = try await render(state.content, noteDirectory: state.noteDirectory)
        // state.noteDirectory 可能为 nil！
    }
```

**✅ 正确**：
```swift
case .preview(.render):
    // ✅ 先检查依赖
    if state.noteDirectory == nil, let noteId = state.note?.noteId {
        return .run { send in
            let directory = try await notaFileManager.getNoteDirectory(for: noteId)
            await send(.noteDirectoryUpdated(directory))
            await send(.preview(.render))  // 重新触发
        }
    }
    // noteDirectory 已就绪，执行渲染
    // ...
```

---

## 8. 最佳实践总结

### 8.1 State 管理

1. ✅ State 应该是纯数据结构
2. ✅ 状态应该放在最合适的层级
3. ✅ 状态应该有明确的初始值
4. ✅ 确保 State 符合 Equatable

### 8.2 Action 设计

1. ✅ Action 应该是描述性的
2. ✅ Action 应该携带必要数据
3. ✅ 避免在 Action 中执行副作用

### 8.3 Reducer 实现

1. ✅ Reducer 应该是纯函数
2. ✅ 同步操作可以在 reducer 中处理（快速、有降级方案）
3. ✅ 异步操作使用 `.run` Effect
4. ✅ 检查状态依赖
5. ✅ 在适当的时机清理资源

### 8.4 Effect 处理

1. ✅ 使用 `.run` 处理异步操作
2. ✅ 通过 `send` 发送新 Action 更新 State
3. ✅ 捕获外部变量
4. ✅ 使用 `.cancellable` 支持取消和去重

### 8.5 文件操作

1. ✅ 快速操作可以在 reducer 中同步处理
2. ✅ 提供降级方案
3. ✅ 在 State 中跟踪临时文件
4. ✅ 在适当的时机清理资源

---

## 9. 实施检查清单

在实施图片预览渲染修复时，确保：

- [ ] State 中添加了 `previewHTMLFileURL: URL?`
- [ ] State 符合 `Equatable`
- [ ] Action 设计合理（描述性、携带数据）
- [ ] Reducer 中正确处理文件创建（同步、有降级方案）
- [ ] Reducer 中正确清理旧文件
- [ ] Effect 中正确捕获外部变量
- [ ] 笔记关闭时清理临时文件
- [ ] 错误处理完善（不崩溃、有降级方案）
- [ ] 状态依赖检查（noteDirectory 存在性）
- [ ] 资源清理逻辑完整

---

**文档版本历史**:
- v1.0 (2025-11-21): 初始版本


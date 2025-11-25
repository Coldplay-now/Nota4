# AI 编辑器功能技术架构规范

**创建日期**: 2025-11-25 12:09:12  
**版本**: v1.0  
**状态**: 技术评审

---

## 1. 概述

本文档详细说明 AI 编辑器功能的技术架构实现，特别关注对 TCA（The Composable Architecture）状态管理机制的严格遵从。

### 1.1 架构原则

1. **TCA 优先**：所有状态变更通过 Action 触发，遵循单向数据流
2. **类型安全**：使用 Swift 类型系统确保状态和 Action 的类型安全
3. **可测试性**：所有业务逻辑在 Reducer 中，易于单元测试
4. **可组合性**：功能模块化，易于扩展和维护

---

## 2. 数据模型

### 2.1 EditorPreferences 扩展

**文件**: `Nota4/Nota4/Models/EditorPreferences.swift`

```swift
extension EditorPreferences {
    // MARK: - AI 配置
    var aiConfig: AIConfig = AIConfig()
    
    struct AIConfig: Codable, Equatable {
        var endpoint: String = "https://api.deepseek.com/v1/chat/completions"
        var apiKey: String = ""
        var model: String = "deepseek-chat"
        var systemPrompt: String = """
        你是一个专业的 Markdown 笔记助手。你的任务是帮助用户生成、改写和优化 Markdown 格式的笔记内容。

        要求：
        1. 输出内容必须是有效的 Markdown 格式
        2. 保持内容简洁、清晰、有条理
        3. 根据用户需求生成合适的内容结构
        4. 如果用户要求改写，保持原意但优化表达
        5. 如果用户要求翻译，保持 Markdown 格式不变

        请直接输出内容，不要添加额外的说明或注释。
        """
    }
}
```

**要点**：
- `AIConfig` 必须符合 `Codable` 和 `Equatable` 协议
- 默认值在结构体定义中设置
- API Key 初期存储在 `EditorPreferences` 中（通过 `PreferencesStorage` 持久化）

---

## 3. SettingsFeature 扩展

### 3.1 State 扩展

**文件**: `Nota4/Nota4/Features/Preferences/SettingsFeature.swift`

```swift
@ObservableState
struct State: Equatable {
    // ... 现有状态 ...
    
    // MARK: - AI 配置状态
    var aiConfig: EditorPreferences.AIConfig
    var originalAiConfig: EditorPreferences.AIConfig  // 用于取消操作
    
    init(editorPreferences: EditorPreferences) {
        // ... 现有初始化 ...
        self.aiConfig = editorPreferences.aiConfig
        self.originalAiConfig = editorPreferences.aiConfig
    }
}
```

**TCA 要点**：
- `State` 必须符合 `Equatable` 协议
- 使用 `@ObservableState` 宏支持 SwiftUI 绑定
- `originalAiConfig` 用于实现"取消"功能，恢复原始配置

### 3.2 Action 扩展

```swift
enum Action: BindableAction {
    // ... 现有 Action ...
    
    // MARK: - AI Config Actions
    case aiEndpointChanged(String)
    case aiApiKeyChanged(String)
    case aiModelChanged(String)
    case aiSystemPromptChanged(String)
    
    // 绑定 Action（用于 TextField/TextEditor 的双向绑定）
    case binding(BindingAction<State>)
}
```

**TCA 要点**：
- 所有状态变更通过 Action 触发
- 使用 `BindableAction` 支持 SwiftUI 双向绑定
- Action 命名清晰，表达意图

### 3.3 Reducer 实现

```swift
var body: some ReducerOf<Self> {
    BindingReducer()  // 处理绑定 Action
    
    Reduce { state, action in
        switch action {
        // ... 现有 case ...
        
        // MARK: - AI Config Actions
        case .aiEndpointChanged(let endpoint):
            state.aiConfig.endpoint = endpoint
            return .none
            
        case .aiApiKeyChanged(let apiKey):
            state.aiConfig.apiKey = apiKey
            return .none
            
        case .aiModelChanged(let model):
            state.aiConfig.model = model
            return .none
            
        case .aiSystemPromptChanged(let prompt):
            state.aiConfig.systemPrompt = prompt
            return .none
            
        case .binding:
            // BindingReducer 自动处理
            return .none
            
        // ... 其他 case ...
        }
    }
}
```

**TCA 要点**：
- 使用 `BindingReducer()` 处理绑定 Action
- Reducer 是纯函数，不产生副作用
- 状态更新是同步的，立即反映在 UI 上

### 3.4 保存配置

```swift
case .apply:
    return .run { [state] send in
        var prefs = state.editorPreferences
        prefs.aiConfig = state.aiConfig
        
        // 保存到 UserDefaults（通过 PreferencesStorage）
        do {
            try await PreferencesStorage.shared.save(prefs)
            await send(.dismiss)
        } catch {
            // 处理错误
            print("❌ Failed to save AI config: \(error)")
        }
    }
```

**TCA 要点**：
- 副作用（保存操作）在 `.run` Effect 中执行
- 使用 `async/await` 处理异步操作
- 错误处理在 Effect 中完成

---

## 4. EditorFeature 扩展

### 4.1 State 扩展

**文件**: `Nota4/Nota4/Features/Editor/EditorFeature.swift`

```swift
@ObservableState
struct State: Equatable {
    // ... 现有状态 ...
    
    // MARK: - AI Editor State
    struct AIEditorState: Equatable {
        var isDialogVisible: Bool = false           // 对话框是否可见
        var userPrompt: String = ""                 // 用户输入的提示词
        var isGenerating: Bool = false              // 是否正在生成
        var generatedContent: String = ""           // 生成的内容（流式追加）
        var errorMessage: String? = nil             // 错误消息
        var includeContext: Bool = false            // 是否包含上下文
        var showContentPreview: Bool = false        // 是否显示预览
    }
    
    var aiEditor: AIEditorState = AIEditorState()
}
```

**TCA 要点**：
- 嵌套状态结构，保持状态组织清晰
- 所有状态都是值类型，符合 `Equatable`
- 状态变更通过 Action 触发

### 4.2 Action 扩展

```swift
enum Action: BindableAction {
    // ... 现有 Action ...
    
    // MARK: - AI Editor Actions
    case showAIEditorDialog                    // 显示对话框
    case dismissAIEditorDialog                 // 关闭对话框
    case aiEditorPromptChanged(String)         // 用户输入变化（绑定）
    case aiEditorIncludeContextChanged(Bool)   // 上下文开关变化（绑定）
    case generateAIContent                     // 点击生成按钮
    case aiContentChunkReceived(String)         // 流式输出：接收到内容块
    case aiContentGenerated(Result<String, Error>)  // 生成完成（成功或失败）
    case confirmInsertAIContent                // 确认插入内容
    case cancelInsertAIContent                 // 取消插入
    case retryGenerateContent                  // 重试生成
    
    case binding(BindingAction<State>)
}
```

**TCA 要点**：
- Action 命名清晰，表达用户意图
- 流式输出使用 `aiContentChunkReceived` Action
- 使用 `Result` 类型处理成功/失败

### 4.3 Reducer 实现

#### 4.3.1 显示/关闭对话框

```swift
case .showAIEditorDialog:
    state.aiEditor.isDialogVisible = true
    state.aiEditor.userPrompt = ""
    state.aiEditor.generatedContent = ""
    state.aiEditor.errorMessage = nil
    state.aiEditor.showContentPreview = false
    return .none

case .dismissAIEditorDialog:
    state.aiEditor.isDialogVisible = false
    // 重置状态
    state.aiEditor = AIEditorState()
    return .none
```

#### 4.3.2 生成内容（流式）

```swift
case .generateAIContent:
    // 验证输入
    guard !state.aiEditor.userPrompt.isEmpty else {
        return .none
    }
    
    // 验证配置
    let prefs = await PreferencesStorage.shared.load()
    guard !prefs.aiConfig.apiKey.isEmpty else {
        state.aiEditor.errorMessage = "请先在设置中配置 API Key"
        return .none
    }
    
    // 重置状态
    state.aiEditor.isGenerating = true
    state.aiEditor.generatedContent = ""
    state.aiEditor.errorMessage = nil
    state.aiEditor.showContentPreview = true
    
    // 获取上下文（如果需要）
    let context: String? = state.aiEditor.includeContext ? state.content : nil
    
    return .run { [prompt = state.aiEditor.userPrompt, config = prefs.aiConfig] send in
        do {
            let stream = await LLMService.shared.generateContentStream(
                systemPrompt: config.systemPrompt,
                userPrompt: prompt,
                context: context,
                config: config
            )
            
            var fullContent = ""
            for await chunk in stream {
                fullContent += chunk
                await send(.aiContentChunkReceived(chunk))
            }
            
            await send(.aiContentGenerated(.success(fullContent)))
        } catch {
            await send(.aiContentGenerated(.failure(error)))
        }
    }
```

**TCA 要点**：
- 副作用（API 调用）在 `.run` Effect 中执行
- 使用 `AsyncStream` 处理流式响应
- 每个内容块通过 `aiContentChunkReceived` Action 发送
- 最终结果通过 `aiContentGenerated` Action 发送

#### 4.3.3 处理流式内容块

```swift
case .aiContentChunkReceived(let chunk):
    state.aiEditor.generatedContent += chunk
    return .none
```

**TCA 要点**：
- 状态更新是同步的，立即反映在 UI 上
- UI 自动更新（通过 `@ObservableState`）

#### 4.3.4 生成完成

```swift
case .aiContentGenerated(.success(let content)):
    state.aiEditor.isGenerating = false
    state.aiEditor.generatedContent = content
    return .none

case .aiContentGenerated(.failure(let error)):
    state.aiEditor.isGenerating = false
    state.aiEditor.errorMessage = error.localizedDescription
    return .none
```

#### 4.3.5 确认插入

```swift
case .confirmInsertAIContent:
    guard !state.aiEditor.generatedContent.isEmpty else {
        return .none
    }
    
    // 构建插入内容（带标记）
    let contentToInsert = """
    
    
    <!-- AI生成内容开始 -->
    
    \(state.aiEditor.generatedContent)
    
    <!-- AI生成内容结束 -->
    
    
    """
    
    // 追加到编辑器末尾
    let newContent = state.content + contentToInsert
    state.content = newContent
    
    // 关闭对话框
    state.aiEditor.isDialogVisible = false
    state.aiEditor = AIEditorState()
    
    // 触发自动保存
    return .send(.autoSave)
```

**TCA 要点**：
- 内容插入是同步操作
- 插入后触发自动保存
- 状态重置，准备下次使用

---

## 5. LLMService 实现

### 5.1 协议定义

**文件**: `Nota4/Nota4/Services/LLMService.swift`

```swift
protocol LLMServiceProtocol {
    /// 生成内容（流式响应）
    func generateContentStream(
        systemPrompt: String,
        userPrompt: String,
        context: String?,
        config: EditorPreferences.AIConfig
    ) -> AsyncStream<String>
    
    /// 生成内容（非流式，用于兼容或测试）
    func generateContent(
        systemPrompt: String,
        userPrompt: String,
        context: String?,
        config: EditorPreferences.AIConfig
    ) async throws -> String
}
```

### 5.2 实现（DeepSeek API）

```swift
actor LLMServiceImpl: LLMServiceProtocol {
    static let shared = LLMServiceImpl()
    
    private init() {}
    
    func generateContentStream(
        systemPrompt: String,
        userPrompt: String,
        context: String?,
        config: EditorPreferences.AIConfig
    ) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                do {
                    // 构建请求
                    var messages: [[String: Any]] = [
                        ["role": "system", "content": systemPrompt]
                    ]
                    
                    // 添加上下文（如果需要）
                    if let context = context, !context.isEmpty {
                        messages.append([
                            "role": "user",
                            "content": "当前笔记内容：\n\(context)\n\n请根据以下需求处理：\(userPrompt)"
                        ])
                    } else {
                        messages.append(["role": "user", "content": userPrompt])
                    }
                    
                    let requestBody: [String: Any] = [
                        "model": config.model,
                        "messages": messages,
                        "stream": true
                    ]
                    
                    // 创建请求
                    var request = URLRequest(url: URL(string: config.endpoint)!)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
                    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                    
                    // 发送请求
                    let (asyncBytes, _) = try await URLSession.shared.bytes(for: request)
                    
                    // 解析流式响应
                    for try await line in asyncBytes.lines {
                        if line.hasPrefix("data: ") {
                            let jsonString = String(line.dropFirst(6))
                            if jsonString == "[DONE]" {
                                continuation.finish()
                                break
                            }
                            
                            if let data = jsonString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let choices = json["choices"] as? [[String: Any]],
                               let firstChoice = choices.first,
                               let delta = firstChoice["delta"] as? [String: Any],
                               let content = delta["content"] as? String {
                                continuation.yield(content)
                            }
                        }
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
```

**要点**：
- 使用 `actor` 确保线程安全
- 使用 `AsyncStream` 实现流式响应
- 错误处理通过 `continuation.finish(throwing:)` 传递

---

## 6. UI 组件实现

### 6.1 工具栏按钮

**文件**: `Nota4/Nota4/Features/Editor/IndependentToolbar.swift`

```swift
// 在工具栏中添加 AI 编辑按钮
NoteListToolbarButton(
    title: "AI 编辑",
    icon: "sparkles",
    isEnabled: store.note != nil
) {
    store.send(.showAIEditorDialog)
}
```

**TCA 要点**：
- UI 组件通过 `store.send()` 发送 Action
- 不直接修改状态

### 6.2 AI 编辑对话框

**文件**: `Nota4/Nota4/Features/Editor/AIEditorDialog.swift`

```swift
struct AIEditorDialog: View {
    @Bindable var store: StoreOf<EditorFeature>
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("AI 编辑助手")
                .font(.title2)
                .fontWeight(.semibold)
            
            // 输入区域
            VStack(alignment: .leading, spacing: 8) {
                Text("请输入您的需求")
                    .font(.headline)
                
                TextEditor(text: Binding(
                    get: { store.aiEditor.userPrompt },
                    set: { store.send(.aiEditorPromptChanged($0)) }
                ))
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            
            // 上下文开关
            Toggle("包含当前笔记内容作为上下文", isOn: Binding(
                get: { store.aiEditor.includeContext },
                set: { store.send(.aiEditorIncludeContextChanged($0)) }
            ))
            
            // 预览区域（生成后显示）
            if store.aiEditor.showContentPreview {
                VStack(alignment: .leading, spacing: 8) {
                    Text("生成内容")
                        .font(.headline)
                    
                    ScrollView {
                        Text(store.aiEditor.generatedContent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .frame(height: 200)
                    .background(Color(nsColor: .textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
            // 错误消息
            if let errorMessage = store.aiEditor.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            // 操作按钮
            HStack {
                Button("取消") {
                    store.send(.dismissAIEditorDialog)
                }
                .keyboardShortcut(.escape)
                
                if store.aiEditor.showContentPreview && !store.aiEditor.generatedContent.isEmpty {
                    Button("清除") {
                        store.send(.aiEditorPromptChanged(""))
                    }
                }
                
                Spacer()
                
                if store.aiEditor.showContentPreview && !store.aiEditor.generatedContent.isEmpty && !store.aiEditor.isGenerating {
                    Button("确认插入") {
                        store.send(.confirmInsertAIContent)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("生成") {
                        store.send(.generateAIContent)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(store.aiEditor.userPrompt.isEmpty || store.aiEditor.isGenerating)
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
        }
        .padding(20)
        .frame(width: 600, height: 400)
    }
}
```

**TCA 要点**：
- 使用 `@Bindable` 支持双向绑定
- 所有用户交互通过 `store.send()` 发送 Action
- UI 状态完全由 `store.state` 驱动

### 6.3 在 EditorView 中显示对话框

```swift
.sheet(isPresented: Binding(
    get: { store.aiEditor.isDialogVisible },
    set: { if !$0 { store.send(.dismissAIEditorDialog) } }
)) {
    AIEditorDialog(store: store)
}
```

**TCA 要点**：
- 对话框显示状态由 `isDialogVisible` 控制
- 关闭对话框通过 Action 触发

---

## 7. 设置面板实现

### 7.1 AISettingsPanel

**文件**: `Nota4/Nota4/Features/Preferences/AISettingsPanel.swift`

```swift
struct AISettingsPanel: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        Form {
            Group {
                Text("API 配置")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                TextField("API 端点", text: Binding(
                    get: { store.aiConfig.endpoint },
                    set: { store.send(.aiEndpointChanged($0)) }
                ))
                
                SecureField("API Key", text: Binding(
                    get: { store.aiConfig.apiKey },
                    set: { store.send(.aiApiKeyChanged($0)) }
                ))
                
                TextField("模型名称", text: Binding(
                    get: { store.aiConfig.model },
                    set: { store.send(.aiModelChanged($0)) }
                ))
            }
            
            Group {
                Text("系统提示词")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                TextEditor(text: Binding(
                    get: { store.aiConfig.systemPrompt },
                    set: { store.send(.aiSystemPromptChanged($0)) }
                ))
                .frame(height: 200)
            }
        }
        .padding()
    }
}
```

**TCA 要点**：
- 所有输入框使用双向绑定
- 状态变更通过 Action 触发
- UI 自动响应状态变化

---

## 8. 测试策略

### 8.1 Reducer 测试

```swift
func testAIContentGeneration() async {
    let store = TestStore(initialState: EditorFeature.State()) {
        EditorFeature()
    }
    
    // 设置输入
    await store.send(.aiEditorPromptChanged("生成一篇关于 Swift 的笔记")) {
        $0.aiEditor.userPrompt = "生成一篇关于 Swift 的笔记"
    }
    
    // 触发生成
    await store.send(.generateAIContent) {
        $0.aiEditor.isGenerating = true
        $0.aiEditor.showContentPreview = true
    }
    
    // 模拟流式响应
    await store.send(.aiContentChunkReceived("# Swift")) {
        $0.aiEditor.generatedContent = "# Swift"
    }
    
    await store.send(.aiContentChunkReceived(" 编程语言")) {
        $0.aiEditor.generatedContent = "# Swift 编程语言"
    }
    
    // 生成完成
    await store.send(.aiContentGenerated(.success("# Swift 编程语言\n\n..."))) {
        $0.aiEditor.isGenerating = false
        $0.aiEditor.generatedContent = "# Swift 编程语言\n\n..."
    }
}
```

**TCA 要点**：
- 使用 `TestStore` 测试 Reducer
- 验证每个 Action 的状态变更
- 可以测试异步 Effect

---

## 9. 总结

### 9.1 TCA 遵从检查清单

- ✅ 所有状态变更通过 Action 触发
- ✅ 使用 `@ObservableState` 支持 SwiftUI 绑定
- ✅ Reducer 是纯函数，不产生副作用
- ✅ 副作用（API 调用、保存等）在 `.run` Effect 中执行
- ✅ 使用 `BindingReducer()` 处理双向绑定
- ✅ 状态是值类型，符合 `Equatable`
- ✅ UI 组件通过 `store.send()` 发送 Action
- ✅ UI 状态完全由 `store.state` 驱动

### 9.2 架构优势

1. **可测试性**：所有业务逻辑在 Reducer 中，易于单元测试
2. **可维护性**：状态和 Action 清晰，易于理解和修改
3. **可扩展性**：模块化设计，易于添加新功能
4. **类型安全**：Swift 类型系统确保编译时安全

---

## 10. 实现检查清单

- [ ] 扩展 `EditorPreferences` 添加 `AIConfig`
- [ ] 扩展 `SettingsFeature.State` 添加 AI 配置状态
- [ ] 扩展 `SettingsFeature.Action` 添加 AI 配置 Action
- [ ] 实现 `SettingsFeature` Reducer 处理 AI 配置
- [ ] 创建 `AISettingsPanel` UI 组件
- [ ] 扩展 `EditorFeature.State` 添加 AI 编辑器状态
- [ ] 扩展 `EditorFeature.Action` 添加 AI 编辑器 Action
- [ ] 实现 `EditorFeature` Reducer 处理 AI 编辑器逻辑
- [ ] 创建 `LLMService` 协议和实现
- [ ] 实现流式响应处理
- [ ] 创建 `AIEditorDialog` UI 组件
- [ ] 在工具栏添加 AI 编辑按钮
- [ ] 实现内容插入逻辑（带标记）
- [ ] 编写单元测试
- [ ] 集成测试

---

**文档结束**


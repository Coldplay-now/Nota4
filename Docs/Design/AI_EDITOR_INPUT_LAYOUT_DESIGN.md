# AI 编辑面板输入框布局设计文档（方案A - TCA规范版）

**创建日期**: 2025-11-25 13:52:30  
**更新日期**: 2025-11-25  
**版本**: v2.0  
**状态**: 设计完成（方案A，固定尺寸，TCA规范）

---

## 1. 概述

本文档详细描述 AI 编辑面板中**输入区域**的 UI 布局设计，采用**方案A：标准布局**，遵循 **TCA（The Composable Architecture）状态管理规范**和 **SwiftUI 设计规范**，使用**固定尺寸**设计。

### 1.1 设计原则

1. **TCA 规范**：所有状态变更通过 Action，使用 `@Bindable` 和 `BindingReducer`
2. **SwiftUI 规范**：使用系统标准组件，遵循 macOS HIG
3. **固定尺寸**：对话框和输入区域使用固定尺寸，不响应式调整
4. **清晰性**：界面元素清晰，信息层级明确
5. **易用性**：操作流程简单直观

### 1.2 方案选择

**选择方案A：标准布局**

**理由**：
- 平衡了空间利用和视觉美观
- 符合 macOS 设计规范
- 实现简单，维护成本低
- 用户体验良好
- 适合固定尺寸设计

---

## 2. TCA 状态管理设计

### 2.1 State 结构

**位置**：`EditorFeature.State.AIEditorState`

**当前状态定义**：
```swift
struct AIEditorState: Equatable {
    var isDialogVisible: Bool = false           // 对话框是否可见
    var userPrompt: String = ""                 // 用户输入的提示词
    var isGenerating: Bool = false              // 是否正在生成
    var generatedContent: String = ""           // 生成的内容（流式追加）
    var errorMessage: String? = nil             // 错误消息
    var includeContext: Bool = false            // 是否包含当前笔记内容作为上下文
    var showContentPreview: Bool = false        // 是否显示内容预览
}
```

**优化建议**：添加字符计数相关状态（可选）

```swift
struct AIEditorState: Equatable {
    var isDialogVisible: Bool = false
    var userPrompt: String = ""
    var isGenerating: Bool = false
    var generatedContent: String = ""
    var errorMessage: String? = nil
    var includeContext: Bool = false
    var showContentPreview: Bool = false
    
    // 计算属性：字符计数
    var characterCount: Int {
        userPrompt.count
    }
    
    var maxCharacters: Int {
        500
    }
    
    var shouldShowCharacterCount: Bool {
        characterCount >= 450
    }
    
    var characterCountColor: Color {
        if characterCount >= 496 {
            return .red
        } else if characterCount >= 481 {
            return .orange
        } else {
            return .secondary
        }
    }
    
    var isPromptValid: Bool {
        !userPrompt.isEmpty && characterCount <= maxCharacters
    }
}
```

### 2.2 Action 定义

**位置**：`EditorFeature.Action`

**当前 Action 列表**：
```swift
case showAIEditorDialog                    // 显示对话框
case dismissAIEditorDialog                 // 关闭对话框
case aiEditorPromptChanged(String)         // 用户输入变化（绑定）
case aiEditorIncludeContextChanged(Bool)   // 上下文开关变化（绑定）
case generateAIContent                     // 点击生成按钮
case aiContentChunkReceived(String)         // 流式输出：接收到内容块
case aiContentGenerated(Result<String, Error>)  // AI 内容生成完成
case confirmInsertAIContent                // 确认插入内容
case cancelInsertAIContent                 // 取消插入
case retryGenerateContent                  // 重试生成
```

**Action 说明**：
- **绑定 Action**：`aiEditorPromptChanged` 和 `aiEditorIncludeContextChanged` 通过 `BindingReducer` 自动处理
- **副作用 Action**：`generateAIContent` 触发异步 Effect
- **状态更新 Action**：`aiContentChunkReceived` 更新生成内容

### 2.3 Reducer 处理逻辑

**位置**：`EditorFeature.Reducer`

**关键处理逻辑**：

```swift
// 显示对话框
case .showAIEditorDialog:
    state.aiEditor.isDialogVisible = true
    state.aiEditor.userPrompt = ""
    state.aiEditor.generatedContent = ""
    state.aiEditor.errorMessage = nil
    state.aiEditor.showContentPreview = false
    return .none

// 用户输入变化（通过 BindingReducer 自动处理）
case .aiEditorPromptChanged(let prompt):
    // 字符限制：500 字符
    let trimmedPrompt = prompt.count > 500 ? String(prompt.prefix(500)) : prompt
    state.aiEditor.userPrompt = trimmedPrompt
    return .none

// 上下文开关变化（通过 BindingReducer 自动处理）
case .aiEditorIncludeContextChanged(let include):
    state.aiEditor.includeContext = include
    return .none

// 生成内容（异步 Effect）
case .generateAIContent:
    guard state.aiEditor.isPromptValid else { return .none }
    
    state.aiEditor.isGenerating = true
    state.aiEditor.generatedContent = ""
    state.aiEditor.errorMessage = nil
    state.aiEditor.showContentPreview = true
    
    return .run { [prompt, includeContext, content] send in
        // 异步调用 LLM Service
        // ...
    }

// 接收流式内容块
case .aiContentChunkReceived(let chunk):
    state.aiEditor.generatedContent += chunk
    return .none
```

### 2.4 Binding 使用规范

**SwiftUI View 中的绑定**：

```swift
// 输入框绑定
TextEditor(text: Binding(
    get: { store.aiEditor.userPrompt },
    set: { store.send(.aiEditorPromptChanged($0)) }
))

// Toggle 绑定
Toggle("包含当前笔记内容作为上下文", isOn: Binding(
    get: { store.aiEditor.includeContext },
    set: { store.send(.aiEditorIncludeContextChanged($0)) }
))
```

**注意**：
- 使用 `@Bindable var store` 启用绑定支持
- 通过 `BindingReducer()` 自动处理绑定 Action
- 所有状态变更必须通过 Action

---

## 3. 固定尺寸设计规范

### 3.1 对话框尺寸

**固定尺寸**：
- **宽度**：800pt（固定）
- **高度**：550pt（固定）
- **不可调整**：用户无法拖拽调整大小

### 3.2 输入区域尺寸

**固定尺寸**：
- **宽度**：350pt（固定，左侧面板）
- **高度**：400pt（固定，跟随 HSplitView 高度）
- **内边距**：16pt（四周固定）

### 3.3 输入框尺寸

**固定尺寸**：
- **高度**：150pt（固定，约 6-7 行）
- **宽度**：318pt（350pt - 16pt × 2 内边距）
- **内边距**：8pt（四周固定）

**滚动行为**：
- 内容超出 150pt 时显示滚动条
- 滚动条样式：系统默认

### 3.4 其他元素尺寸

**标题区域**：
- **高度**：40pt（固定）
- **内边距**：顶部 20pt，水平 20pt

**字符计数**：
- **高度**：16pt（固定）
- **位置**：输入框下方，间距 4pt

**上下文开关**：
- **高度**：20pt（固定）
- **位置**：字符计数下方，间距 12pt

**操作按钮区域**：
- **高度**：60pt（固定）
- **内边距**：底部 20pt，水平 20pt

---

## 4. 输入区域布局（方案A）

### 4.1 整体布局结构

```
┌─────────────────────────────────────┐
│  AI 编辑助手                        │  ← 标题区域（40pt）
│                                     │
│ ┌─────────────────────────────────┐ │
│ │  请输入您的需求                  │ │  ← 标签（8pt 间距）
│ │                                 │ │
│ │ ┌─────────────────────────────┐ │ │
│ │ │ 描述您希望 AI 生成的内容     │ │ │  ← 占位符
│ │ │                             │ │ │
│ │ │ [多行文本输入框 - 150pt]     │ │ │  ← TextEditor
│ │ │                             │ │ │
│ │ └─────────────────────────────┘ │ │
│ │                                 │ │
│ │ 450/500                          │ │  ← 字符计数（4pt 间距）
│ │                                 │ │
│ │ ☐ 包含当前笔记内容作为上下文    │ │  ← Toggle（12pt 间距）
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [取消] [清除]          [生成/确认] │  ← 按钮区域（60pt）
└─────────────────────────────────────┘
```

### 4.2 详细布局规范

**容器结构**：
```swift
VStack(alignment: .leading, spacing: 12) {
    // 标签
    Text("请输入您的需求")
        .font(.headline)
        .padding(.horizontal, 4)
    
    // 输入框（包含占位符）
    ZStack(alignment: .topLeading) {
        // 占位符
        if store.aiEditor.userPrompt.isEmpty {
            Text("描述您希望 AI 生成的内容")
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
        }
        
        // 输入框
        TextEditor(text: Binding(...))
            .frame(height: 150)  // 固定高度
    }
    .overlay(RoundedRectangle(cornerRadius: 4).stroke(...))
    
    // 字符计数
    if store.aiEditor.shouldShowCharacterCount {
        Text("\(store.aiEditor.characterCount)/\(store.aiEditor.maxCharacters)")
            .font(.caption)
            .foregroundColor(store.aiEditor.characterCountColor)
    }
    
    // 上下文开关
    Toggle("包含当前笔记内容作为上下文", isOn: Binding(...))
    
    Spacer()
}
.padding(16)  // 固定内边距
.frame(width: 350, height: 400)  // 固定尺寸
```

---

## 5. 输入框详细设计

### 5.1 输入框组件

**SwiftUI 实现**：
```swift
ZStack(alignment: .topLeading) {
    // 占位符
    if store.aiEditor.userPrompt.isEmpty {
        Text("描述您希望 AI 生成的内容")
            .foregroundColor(.secondary)
            .font(.system(.body))
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .allowsHitTesting(false)
    }
    
    // 输入框
    TextEditor(text: Binding(
        get: { store.aiEditor.userPrompt },
        set: { store.send(.aiEditorPromptChanged($0)) }
    ))
    .font(.system(.body, size: 14))
    .scrollContentBackground(.hidden)
    .frame(height: 150)  // 固定高度
}
.overlay(
    RoundedRectangle(cornerRadius: 4)
        .stroke(
            store.aiEditor.characterCount >= 496 
                ? Color.red.opacity(0.5) 
                : Color.secondary.opacity(0.3),
            lineWidth: 1
        )
)
```

**设计规范**：
- **组件类型**：`TextEditor`（多行文本编辑器）
- **固定高度**：150pt
- **字体**：`.system(.body, size: 14)`（系统字体，14pt）
- **内边距**：8pt（四周）
- **边框**：浅灰色，1pt，圆角 4pt
- **背景色**：系统默认（`.textBackgroundColor`）
- **滚动**：内容超出时自动显示滚动条

### 5.2 占位符设计

**实现方式**：
- 使用 `ZStack` 叠加 `Text` 和 `TextEditor`
- 当 `userPrompt.isEmpty` 时显示占位符
- 占位符不响应点击（`allowsHitTesting(false)`）

**设计规范**：
- **文本**：`"描述您希望 AI 生成的内容"`
- **颜色**：`.secondary`（灰色）
- **字体**：`.system(.body, size: 14)`
- **位置**：左上角，内边距 8pt
- **动画**：淡入淡出（系统默认，0.2秒）

### 5.3 字符计数设计

**显示位置**：输入框下方，右对齐

**SwiftUI 实现**：
```swift
if store.aiEditor.shouldShowCharacterCount {
    HStack {
        Spacer()
        Text("\(store.aiEditor.characterCount)/\(store.aiEditor.maxCharacters)")
            .font(.caption)
            .foregroundColor(store.aiEditor.characterCountColor)
    }
    .padding(.horizontal, 4)
    .padding(.top, 4)
}
```

**设计规范**：
- **显示条件**：字符数 ≥ 450 时显示
- **字体**：`.caption`（12pt）
- **颜色**：
  - 450-480 字符：`.secondary`（灰色）
  - 481-495 字符：`.orange`（橙色警告）
  - 496-500 字符：`.red`（红色警告）
- **位置**：输入框下方，右对齐，间距 4pt
- **格式**：`"当前字符数/最大字符数"`（如 "450/500"）

**状态管理**：
- 字符计数通过计算属性 `characterCount` 获取
- 颜色通过计算属性 `characterCountColor` 获取
- 显示条件通过计算属性 `shouldShowCharacterCount` 判断

### 5.4 字符限制处理

**TCA Reducer 处理**：
```swift
case .aiEditorPromptChanged(let prompt):
    // 字符限制：500 字符
    let trimmedPrompt = prompt.count > 500 ? String(prompt.prefix(500)) : prompt
    state.aiEditor.userPrompt = trimmedPrompt
    return .none
```

**UI 层处理**（可选，双重保护）：
```swift
.onChange(of: store.aiEditor.userPrompt) { oldValue, newValue in
    if newValue.count > 500 {
        store.send(.aiEditorPromptChanged(String(newValue.prefix(500))))
    }
}
```

**视觉反馈**：
- 字符计数颜色变化（灰色 → 橙色 → 红色）
- 输入框边框颜色变化（接近限制时显示红色边框）

---

## 6. 上下文开关设计

### 6.1 Toggle 组件

**SwiftUI 实现**：
```swift
Toggle("包含当前笔记内容作为上下文", isOn: Binding(
    get: { store.aiEditor.includeContext },
    set: { store.send(.aiEditorIncludeContextChanged($0)) }
))
.padding(.horizontal, 4)
```

**设计规范**：
- **控件类型**：`Toggle`（复选框）
- **字体**：系统默认字体，14pt
- **位置**：字符计数下方，间距 12pt
- **对齐方式**：左对齐
- **默认状态**：关闭（`false`）
- **内边距**：水平 4pt

### 6.2 状态管理

**State 属性**：
```swift
var includeContext: Bool = false
```

**Action 处理**：
```swift
case .aiEditorIncludeContextChanged(let include):
    state.aiEditor.includeContext = include
    return .none
```

**功能说明**：
- **关闭状态**：仅发送用户输入的提示词
- **开启状态**：发送用户输入的提示词 + 当前笔记内容的前 1000 字符作为上下文

---

## 7. 视觉设计规范

### 7.1 颜色规范

**输入框边框**：
```swift
// 默认状态
Color.secondary.opacity(0.3)  // 浅灰色

// 焦点状态（系统自动）
Color.accentColor  // 系统蓝色

// 警告状态（接近字符限制）
Color.red.opacity(0.5)  // 红色（496-500 字符时）
```

**字符计数颜色**：
```swift
// 通过计算属性实现
var characterCountColor: Color {
    if characterCount >= 496 {
        return .red
    } else if characterCount >= 481 {
        return .orange
    } else {
        return .secondary
    }
}
```

**占位符颜色**：`.secondary`（灰色）

**错误消息颜色**：`.red`

### 7.2 字体规范

**标题**：
- **字体**：`.title2`（系统字体，22pt）
- **字重**：`.semibold`

**标签**：
- **字体**：`.headline`（系统字体，17pt）
- **字重**：`.regular`

**输入框文本**：
- **字体**：`.system(.body, size: 14)`
- **字重**：`.regular`

**字符计数**：
- **字体**：`.caption`（系统字体，12pt）
- **字重**：`.regular`

**占位符**：
- **字体**：`.system(.body, size: 14)`
- **字重**：`.regular`

### 7.3 间距规范

**固定间距**：
- **对话框内边距**：20pt（标题和按钮区域）
- **输入区域内边距**：16pt（四周）
- **元素间距**：12pt（垂直）
- **标签与输入框间距**：8pt
- **输入框与字符计数间距**：4pt
- **字符计数与开关间距**：12pt
- **输入框内边距**：8pt（四周）

### 7.4 圆角规范

**输入框圆角**：4pt
**按钮圆角**：系统默认（6pt）

---

## 8. 交互设计

### 8.1 键盘快捷键

**系统快捷键**：
- **⌘A**：全选输入框内容
- **⌘C**：复制
- **⌘V**：粘贴
- **⌘X**：剪切
- **⌘Z**：撤销
- **⌘⇧Z**：重做

**对话框快捷键**：
- **⌘⏎**：触发"生成"或"确认插入"按钮
- **ESC**：关闭对话框（触发 `dismissAIEditorDialog`）

**实现方式**：
```swift
Button("生成") {
    store.send(.generateAIContent)
}
.keyboardShortcut(.return, modifiers: .command)

Button("取消") {
    store.send(.dismissAIEditorDialog)
}
.keyboardShortcut(.escape)
```

### 8.2 焦点管理

**焦点顺序**：
1. 输入框（默认焦点，对话框打开时自动获得）
2. 上下文开关
3. 操作按钮（生成/确认插入）

**焦点视觉反馈**：
- 输入框获得焦点时边框自动高亮（系统默认蓝色）
- 使用系统默认焦点样式

**实现方式**：
```swift
@FocusState private var isInputFocused: Bool

TextEditor(...)
    .focused($isInputFocused)
    .onAppear {
        isInputFocused = true  // 对话框打开时自动获得焦点
    }
```

### 8.3 输入验证

**验证规则**：
- 输入框不能为空
- 字符数不能超过 500

**验证状态**：
```swift
var isPromptValid: Bool {
    !userPrompt.isEmpty && characterCount <= maxCharacters
}
```

**按钮禁用逻辑**：
```swift
Button("生成") {
    store.send(.generateAIContent)
}
.disabled(!store.aiEditor.isPromptValid || store.aiEditor.isGenerating)
```

---

## 9. 状态设计

### 9.1 输入状态

**空状态**：
- `userPrompt.isEmpty == true`
- 显示占位符
- 字符计数隐藏
- "生成"按钮禁用

**输入中状态**：
- `userPrompt.isEmpty == false`
- 占位符隐藏
- 字符计数显示（≥ 450 字符时）
- "生成"按钮启用（如果字符数有效）

**字符超限状态**：
- `characterCount >= 496`
- 字符计数显示红色
- 输入框边框显示红色（可选）
- 输入被自动截断到 500 字符

### 9.2 生成状态

**生成前**：
- `isGenerating == false`
- `showContentPreview == false`
- 按钮显示"生成"

**生成中**：
- `isGenerating == true`
- `showContentPreview == true`
- 按钮显示加载指示器
- 按钮文本保持"生成"或显示"生成中..."

**生成完成**：
- `isGenerating == false`
- `showContentPreview == true`
- `generatedContent.isEmpty == false`
- 按钮显示"确认插入"

**生成失败**：
- `isGenerating == false`
- `errorMessage != nil`
- 显示错误消息
- 显示"重试"按钮

### 9.3 上下文开关状态

**关闭状态**：
- `includeContext == false`
- 复选框未选中
- 不包含笔记内容作为上下文

**开启状态**：
- `includeContext == true`
- 复选框选中
- 包含笔记内容的前 1000 字符作为上下文

---

## 10. 动画和过渡

### 10.1 占位符动画

**淡入淡出**：
```swift
// SwiftUI 自动处理
if store.aiEditor.userPrompt.isEmpty {
    Text("描述您希望 AI 生成的内容")
        .transition(.opacity)  // 可选：显式指定过渡
}
```

**动画参数**：
- **持续时间**：0.2 秒（系统默认）
- **缓动函数**：`.easeInOut`（系统默认）

### 10.2 字符计数显示动画

**淡入动画**：
```swift
if store.aiEditor.shouldShowCharacterCount {
    Text("\(store.aiEditor.characterCount)/\(store.aiEditor.maxCharacters)")
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: store.aiEditor.shouldShowCharacterCount)
}
```

### 10.3 输入框边框颜色变化

**颜色过渡**：
```swift
.overlay(
    RoundedRectangle(cornerRadius: 4)
        .stroke(
            store.aiEditor.characterCount >= 496 
                ? Color.red.opacity(0.5) 
                : Color.secondary.opacity(0.3),
            lineWidth: 1
        )
        .animation(.easeInOut(duration: 0.2), value: store.aiEditor.characterCount)
)
```

---

## 11. 可访问性设计

### 11.1 VoiceOver 支持

**输入框可访问性标签**：
```swift
TextEditor(...)
    .accessibilityLabel("AI 提示词输入框")
    .accessibilityHint("请输入您希望 AI 生成的内容，最多 500 字符")
    .accessibilityValue("\(store.aiEditor.characterCount) 字符")
```

**字符计数可访问性**：
```swift
Text("\(store.aiEditor.characterCount)/\(store.aiEditor.maxCharacters)")
    .accessibilityLabel("字符计数")
    .accessibilityValue("\(store.aiEditor.characterCount) 个字符，最多 \(store.aiEditor.maxCharacters) 个字符")
```

**上下文开关可访问性**：
```swift
Toggle("包含当前笔记内容作为上下文", isOn: Binding(...))
    .accessibilityHint("开启后将当前笔记的前 1000 字符作为上下文发送给 AI")
```

### 11.2 键盘导航

**Tab 键导航顺序**：
1. 输入框
2. 上下文开关
3. 操作按钮（生成/确认插入）

**实现方式**：
- 使用系统默认 Tab 键导航
- 确保所有可交互元素都在导航顺序中

---

## 12. SwiftUI 组件实现

### 12.1 完整输入区域组件

```swift
struct AIInputArea: View {
    @Bindable var store: StoreOf<EditorFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标签
            Text("请输入您的需求")
                .font(.headline)
                .padding(.horizontal, 4)
            
            // 输入框（包含占位符）
            ZStack(alignment: .topLeading) {
                // 占位符
                if store.aiEditor.userPrompt.isEmpty {
                    Text("描述您希望 AI 生成的内容")
                        .foregroundColor(.secondary)
                        .font(.system(.body, size: 14))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
                
                // 输入框
                TextEditor(text: Binding(
                    get: { store.aiEditor.userPrompt },
                    set: { store.send(.aiEditorPromptChanged($0)) }
                ))
                .font(.system(.body, size: 14))
                .scrollContentBackground(.hidden)
                .frame(height: 150)  // 固定高度
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        store.aiEditor.characterCount >= 496 
                            ? Color.red.opacity(0.5) 
                            : Color.secondary.opacity(0.3),
                        lineWidth: 1
                    )
                    .animation(.easeInOut(duration: 0.2), value: store.aiEditor.characterCount)
            )
            
            // 字符计数
            if store.aiEditor.shouldShowCharacterCount {
                HStack {
                    Spacer()
                    Text("\(store.aiEditor.characterCount)/\(store.aiEditor.maxCharacters)")
                        .font(.caption)
                        .foregroundColor(store.aiEditor.characterCountColor)
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
                .transition(.opacity)
            }
            
            // 上下文开关
            Toggle("包含当前笔记内容作为上下文", isOn: Binding(
                get: { store.aiEditor.includeContext },
                set: { store.send(.aiEditorIncludeContextChanged($0)) }
            ))
            .padding(.horizontal, 4)
            
            Spacer()
        }
        .padding(16)  // 固定内边距
        .frame(width: 350, height: 400)  // 固定尺寸
    }
}
```

### 12.2 组件拆分建议

**建议拆分为以下子组件**：

1. **AIInputLabel**：标签组件
2. **AIInputEditor**：输入框组件（包含占位符）
3. **AICharacterCount**：字符计数组件
4. **AIContextToggle**：上下文开关组件

**优势**：
- 代码更清晰，易于维护
- 组件可复用
- 便于单独测试

---

## 13. TCA 最佳实践

### 13.1 状态管理最佳实践

1. **单一数据源**：所有状态存储在 `AIEditorState` 中
2. **不可变状态**：状态更新通过 Reducer 进行
3. **计算属性**：使用计算属性而非存储属性（如 `characterCount`）
4. **Action 命名**：Action 名称清晰描述操作（如 `aiEditorPromptChanged`）

### 13.2 Binding 最佳实践

1. **使用 @Bindable**：View 中使用 `@Bindable var store` 启用绑定
2. **显式 Action**：每个绑定对应一个明确的 Action
3. **BindingReducer**：使用 `BindingReducer()` 自动处理绑定 Action
4. **避免直接修改**：不在 View 中直接修改 state

### 13.3 Effect 最佳实践

1. **异步操作**：使用 `.run` 处理异步操作
2. **错误处理**：使用 `Result` 类型处理成功/失败
3. **流式处理**：使用 `AsyncThrowingStream` 处理流式响应
4. **取消支持**：使用 `.cancellable` 支持取消操作

---

## 14. 设计检查清单

### 14.1 TCA 规范检查

- [ ] 所有状态变更通过 Action
- [ ] 使用 `@Bindable` 和 `BindingReducer`
- [ ] 计算属性使用合理
- [ ] Action 命名清晰
- [ ] Effect 处理正确
- [ ] 错误处理完善

### 14.2 SwiftUI 规范检查

- [ ] 使用系统标准组件
- [ ] 遵循 macOS HIG
- [ ] 颜色和字体符合规范
- [ ] 间距和圆角一致
- [ ] 动画流畅自然

### 14.3 固定尺寸检查

- [ ] 对话框尺寸固定（800×550）
- [ ] 输入区域尺寸固定（350×400）
- [ ] 输入框高度固定（150pt）
- [ ] 所有间距固定
- [ ] 不可调整大小

### 14.4 功能检查

- [ ] 输入框功能正常
- [ ] 字符限制正确执行
- [ ] 字符计数正确显示
- [ ] 上下文开关正常工作
- [ ] 键盘快捷键正常
- [ ] 焦点管理正确

### 14.5 可访问性检查

- [ ] VoiceOver 标签完整
- [ ] 键盘导航流畅
- [ ] 颜色对比度符合标准
- [ ] 焦点指示清晰

---

## 15. 实现步骤

### 15.1 第一步：扩展 State

在 `EditorFeature.State.AIEditorState` 中添加计算属性：
- `characterCount`
- `maxCharacters`
- `shouldShowCharacterCount`
- `characterCountColor`
- `isPromptValid`

### 15.2 第二步：优化 Reducer

在 `EditorFeature.Reducer` 中优化字符限制处理：
- 确保字符限制逻辑正确
- 添加必要的验证

### 15.3 第三步：实现 UI 组件

创建 `AIInputArea` 组件：
- 实现输入框和占位符
- 实现字符计数显示
- 实现上下文开关
- 应用固定尺寸

### 15.4 第四步：集成到对话框

在 `AIEditorDialog` 中使用 `AIInputArea` 组件：
- 替换现有的输入区域代码
- 确保布局正确

### 15.5 第五步：测试和优化

- 测试所有功能
- 检查可访问性
- 优化动画效果
- 修复发现的问题

---

## 16. 总结

本文档详细描述了 AI 编辑面板输入框的布局设计，采用**方案A：标准布局**，遵循 **TCA 状态管理规范**和 **SwiftUI 设计规范**，使用**固定尺寸**设计。

**关键设计要点**：
1. **固定尺寸**：对话框 800×550，输入区域 350×400，输入框 150pt 高
2. **TCA 规范**：所有状态通过 Action 管理，使用 BindingReducer
3. **计算属性**：字符计数、颜色等使用计算属性
4. **标准组件**：使用 SwiftUI 标准组件，符合 macOS HIG
5. **清晰布局**：元素间距固定，视觉层次明确

**下一步**：按照实现步骤逐步开发，确保符合设计规范。

---

## 17. 输出预览区域设计

### 17.1 整体布局

**位置**：对话框右侧，与输入区域并排显示（HSplitView）

**布局结构**：
```
┌─────────────────────────────────────┐
│  生成内容                          │  ← 标题（.headline）
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │ [生成的内容预览区域]            │ │  ← ScrollView
│ │                                 │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

### 17.2 固定尺寸规范

**输出区域尺寸**：
- **宽度**：350pt（固定，右侧面板）
- **高度**：400pt（固定，跟随 HSplitView 高度）
- **内边距**：16pt（四周固定）

**预览区域尺寸**：
- **高度**：368pt（400pt - 16pt × 2 内边距 - 标题区域）
- **宽度**：318pt（350pt - 16pt × 2 内边距）
- **内边距**：12pt（内容内边距）

### 17.3 状态设计

**空状态**（未生成）：
- `showContentPreview == false`
- 显示占位文本："生成的内容将显示在这里"
- 背景色：系统默认背景
- 边框：浅灰色边框

**生成中状态**：
- `showContentPreview == true`
- `isGenerating == true`
- `generatedContent` 逐步增加（流式输出）
- 自动滚动到底部
- 显示加载指示器（可选）

**生成完成状态**：
- `showContentPreview == true`
- `isGenerating == false`
- `generatedContent` 包含完整内容
- 可滚动查看完整内容

**错误状态**：
- `errorMessage != nil`
- 显示错误消息（在预览区域下方或替换预览区域）

### 17.4 SwiftUI 实现

**完整输出区域组件**：
```swift
struct AIOutputArea: View {
    @Bindable var store: StoreOf<EditorFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("生成内容")
                .font(.headline)
                .padding(.horizontal, 4)
            
            // 预览区域
            if store.aiEditor.showContentPreview {
                // 生成中或生成完成
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            // 生成的内容
                            Text(store.aiEditor.generatedContent)
                                .font(.system(.body, size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)  // 允许选择文本
                                .id("content")
                            
                            // 生成中指示器（可选）
                            if store.aiEditor.isGenerating {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("正在生成...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(12)
                    }
                    .background(Color(nsColor: .textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .onChange(of: store.aiEditor.generatedContent) { oldValue, newValue in
                        // 流式输出时自动滚动到底部
                        if store.aiEditor.isGenerating {
                            withAnimation(.easeOut(duration: 0.1)) {
                                proxy.scrollTo("content", anchor: .bottom)
                            }
                        }
                    }
                }
            } else {
                // 空状态：占位符
                VStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("生成的内容将显示在这里")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(16)  // 固定内边距
        .frame(width: 350, height: 400)  // 固定尺寸
    }
}
```

### 17.5 流式输出处理

**流式输出特性**：
- 内容逐步追加显示（每个 chunk 追加）
- 自动滚动到底部（生成中时）
- 平滑的滚动动画
- 实时更新内容

**实现方式**：
```swift
// Reducer 中处理流式输出
case .aiContentChunkReceived(let chunk):
    state.aiEditor.generatedContent += chunk
    return .none

// View 中自动滚动
.onChange(of: store.aiEditor.generatedContent) { oldValue, newValue in
    if store.aiEditor.isGenerating {
        withAnimation(.easeOut(duration: 0.1)) {
            proxy.scrollTo("content", anchor: .bottom)
        }
    }
}
```

### 17.6 内容显示规范

**文本样式**：
- **字体**：`.system(.body, size: 14)`（系统字体，14pt）
- **行高**：系统默认（约 1.2）
- **对齐方式**：左对齐（`.leading`）
- **文本选择**：启用（`.textSelection(.enabled)`）

**Markdown 支持**（可选）：
- 如果生成的内容是 Markdown，可以渲染为格式化文本
- 使用 `MarkdownUI` 或自定义渲染器
- 保持纯文本显示（初期实现）

**滚动行为**：
- **滚动条**：系统默认滚动条
- **滚动平滑度**：系统默认动画
- **自动滚动**：生成中时自动滚动到底部
- **手动滚动**：用户可以手动滚动查看内容

### 17.7 占位符设计

**空状态占位符**：
```swift
VStack(spacing: 8) {
    Image(systemName: "sparkles")
        .font(.system(size: 32))
        .foregroundColor(.secondary.opacity(0.5))
    Text("生成的内容将显示在这里")
        .foregroundColor(.secondary)
        .font(.subheadline)
}
```

**设计规范**：
- **图标**：`sparkles`（SF Symbols，32pt）
- **文本**：`"生成的内容将显示在这里"`
- **颜色**：`.secondary`（灰色，50% 透明度）
- **字体**：`.subheadline`（15pt）
- **位置**：垂直居中

### 17.8 加载状态指示

**生成中指示器**（可选）：
```swift
if store.aiEditor.isGenerating {
    HStack(spacing: 8) {
        ProgressView()
            .scaleEffect(0.8)
        Text("正在生成...")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    .padding(.top, 8)
}
```

**设计规范**：
- **位置**：内容底部
- **样式**：`ProgressView` + 文本
- **字体**：`.caption`（12pt）
- **颜色**：`.secondary`（灰色）

### 17.9 错误状态显示

**错误消息位置**：预览区域下方（在按钮区域上方）

**实现方式**：
```swift
// 在对话框底部显示错误消息
if let errorMessage = store.aiEditor.errorMessage {
    Text(errorMessage)
        .foregroundColor(.red)
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
}
```

**设计规范**：
- **字体**：`.caption`（12pt）
- **颜色**：`.red`
- **位置**：预览区域和按钮区域之间
- **对齐方式**：左对齐

### 17.10 视觉设计规范

**背景色**：
- **预览区域**：`Color(nsColor: .textBackgroundColor)`（系统默认背景）
- **占位符区域**：相同背景色

**边框**：
- **颜色**：`Color.secondary.opacity(0.3)`（浅灰色）
- **宽度**：1pt
- **圆角**：4pt

**内边距**：
- **容器内边距**：16pt（四周）
- **内容内边距**：12pt（四周）

### 17.11 交互设计

**文本选择**：
- 启用文本选择（`.textSelection(.enabled)`）
- 用户可以复制生成的内容
- 支持标准复制快捷键（⌘C）

**滚动交互**：
- 鼠标滚轮滚动
- 拖拽滚动条
- 触摸板手势滚动

**自动滚动控制**（可选）：
- 生成中时自动滚动
- 用户手动滚动后暂停自动滚动
- 生成完成后保持当前位置

### 17.12 可访问性设计

**VoiceOver 支持**：
```swift
ScrollView(...)
    .accessibilityLabel("AI 生成内容预览")
    .accessibilityValue(store.aiEditor.isGenerating 
        ? "正在生成内容" 
        : "已生成 \(store.aiEditor.generatedContent.count) 个字符")
```

**键盘导航**：
- Tab 键可以导航到预览区域
- 支持文本选择和复制

### 17.13 状态管理（TCA）

**相关 State**：
```swift
var generatedContent: String = ""           // 生成的内容（流式追加）
var isGenerating: Bool = false              // 是否正在生成
var showContentPreview: Bool = false       // 是否显示内容预览
var errorMessage: String? = nil             // 错误消息
```

**相关 Action**：
```swift
case generateAIContent                     // 开始生成
case aiContentChunkReceived(String)         // 接收流式内容块
case aiContentGenerated(Result<String, Error>)  // 生成完成
```

**Reducer 处理**：
```swift
// 开始生成
case .generateAIContent:
    state.aiEditor.showContentPreview = true
    state.aiEditor.isGenerating = true
    state.aiEditor.generatedContent = ""
    // ... 触发异步 Effect

// 接收内容块
case .aiContentChunkReceived(let chunk):
    state.aiEditor.generatedContent += chunk
    return .none

// 生成完成
case .aiContentGenerated(.success):
    state.aiEditor.isGenerating = false
    return .none

// 生成失败
case .aiContentGenerated(.failure(let error)):
    state.aiEditor.isGenerating = false
    state.aiEditor.errorMessage = error.localizedDescription
    return .none
```

### 17.14 动画和过渡

**内容更新动画**：
- 流式输出时内容平滑追加
- 使用系统默认文本更新动画

**滚动动画**：
```swift
withAnimation(.easeOut(duration: 0.1)) {
    proxy.scrollTo("content", anchor: .bottom)
}
```

**占位符显示/隐藏**：
- 使用淡入淡出动画（系统默认，0.2秒）

### 17.15 完整对话框布局

**整体布局结构**：
```
┌─────────────────────────────────────────────────────────┐
│  AI 编辑助手                                            │  ← 标题（40pt）
│                                                         │
│ ┌──────────────────────┐  │  ┌──────────────────────┐ │
│ │  输入区域            │  │  │  输出区域            │ │
│ │  (350×400pt)         │  │  │  (350×400pt)         │ │
│ │                     │  │  │                     │ │
│ │  [输入框]            │  │  │  [预览区域]          │ │
│ │                     │  │  │                     │ │
│ │  [字符计数]         │  │  │                     │ │
│ │                     │  │  │                     │ │
│ │  [上下文开关]       │  │  │                     │ │
│ └──────────────────────┘  │  └──────────────────────┘ │
│                                                         │
│ [错误消息]（如果有）                                     │
│                                                         │
│ [取消] [清除]                    [生成/确认插入]      │  ← 按钮（60pt）
└─────────────────────────────────────────────────────────┘
总尺寸：800×550pt（固定）
```

### 17.16 设计检查清单

**输出区域检查**：
- [ ] 预览区域尺寸固定（350×400pt）
- [ ] 空状态占位符清晰
- [ ] 流式输出平滑显示
- [ ] 自动滚动正常工作
- [ ] 文本可选择和复制
- [ ] 错误状态正确显示
- [ ] 加载状态有指示
- [ ] VoiceOver 支持完整

---

**文档结束**

**设计完成日期**: 2025-11-25  
**设计者**: AI Assistant  
**审核状态**: 待审核  
**版本**: v2.1（方案A，TCA规范，固定尺寸，包含输出预览区域）

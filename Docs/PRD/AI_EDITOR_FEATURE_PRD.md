# AI 编辑器功能 PRD

**创建日期**: 2025-11-25 11:29:21  
**最后更新**: 2025-11-25 12:09:12  
**状态**: 已完成（PRD + 技术规范 + UI 设计）  
**版本**: v1.0

---

## 1. 产品概述

### 1.1 功能定位

在 Nota4 编辑器中集成 AI 辅助编辑功能，允许用户通过 LLM API 生成和编辑笔记内容，提升写作效率。

### 1.2 核心价值

- **提升写作效率**：通过 AI 快速生成、改写、优化内容
- **灵活配置**：支持自定义 LLM 接入端点和 API Key
- **无缝集成**：与现有编辑器深度集成，符合 TCA 架构规范

---

## 2. 功能需求

### 2.1 设置面板配置（需求【1】）

#### 2.1.1 新增设置分类

在 `SettingsCategory` 中新增分类：

```swift
case ai = "AI 助手"
```

**✅ 已确认**：放在"外观"之后，作为第三个分类。

**设置面板顺序**：
1. 编辑器
2. 外观
3. AI 助手 ← 新分类

---

#### 2.1.2 LLM 配置项

**需要确认的配置项**：

1. **API 端点（Endpoint）**
   - 字段名：`llmEndpoint`
   - 类型：`String`
   - 默认值：`"https://api.deepseek.com/v1/chat/completions"`（DeepSeek）
   - 输入框类型：文本输入框
   - 验证规则：必须是有效的 URL

2. **API Key**
   - 字段名：`llmApiKey`
   - 类型：`String`
   - 默认值：空字符串
   - 输入框类型：**安全文本输入框**（显示为密码框，类似密码输入）
   - 验证规则：非空（保存时验证）
   - 说明：用户必须填写自己的 DeepSeek API Key

3. **模型名称**
   - 字段名：`llmModel`
   - 类型：`String`
   - 默认值：`"deepseek-chat"`（DeepSeek 默认模型）
   - 输入框类型：文本输入框（可编辑，但默认已填好）
   - 说明：DeepSeek 的默认模型名称，高级用户可以根据需要修改

**✅ 已确认**：初期采用简单模式，只支持 DeepSeek，使用固定端点。

**配置项**：
- API 端点：固定为 `"https://api.deepseek.com/v1/chat/completions"`（用户可编辑，但默认已填好）
- API Key：用户必须填写
- 模型名称：固定为 `"deepseek-chat"`（用户可编辑，但默认已填好）

**未来扩展**：可以添加"提供商"下拉菜单，选择后自动填充端点和模型名称

---

#### 2.1.3 系统提示词配置

**配置项**：

1. **系统提示词（System Prompt）**
   - 字段名：`llmSystemPrompt`
   - 类型：`String`
   - 输入框类型：**多行文本编辑器**（支持多行编辑，高度至少 8-10 行）
   - 默认值：通用写作助手提示词（见上方）
   - 可编辑：用户可以随时修改

**✅ 已确认**：默认系统提示词使用通用写作助手版本，且用户可以手工编辑和更改。

**默认系统提示词内容**：
```
你是一个专业的 Markdown 笔记助手。你的任务是帮助用户生成、改写和优化 Markdown 格式的笔记内容。

要求：
1. 输出内容必须是有效的 Markdown 格式
2. 保持内容简洁、清晰、有条理
3. 根据用户需求生成合适的内容结构
4. 如果用户要求改写，保持原意但优化表达
5. 如果用户要求翻译，保持 Markdown 格式不变

请直接输出内容，不要添加额外的说明或注释。
```

**输入框要求**：
- 类型：多行文本编辑器（支持多行编辑）
- 可编辑：用户可以随时修改默认提示词
- 高度：建议至少 8-10 行，方便查看和编辑

**问题 4**：是否需要提供预设的系统提示词模板（如"写作助手"、"翻译助手"、"代码助手"等）？

**建议**：初期只提供默认提示词，未来可以添加模板选择功能。

---

#### 2.1.4 其他配置项（可选）

**需要讨论的配置**：

1. **请求超时时间**
   - 字段名：`llmTimeout`
   - 类型：`TimeInterval`（秒）
   - 默认值：`30.0`
   - 输入框类型：数字输入框

2. **最大 Token 数**
   - 字段名：`llmMaxTokens`
   - 类型：`Int`
   - 默认值：`2000`
   - 输入框类型：数字输入框

3. **温度（Temperature）**
   - 字段名：`llmTemperature`
   - 类型：`Double`（0.0 - 2.0）
   - 默认值：`0.7`
   - 输入框类型：滑块或数字输入框

**问题 5**：这些高级配置是否需要在初期实现？还是先实现基础功能，后续再添加？

**建议**：初期只实现基础配置（端点、API Key、系统提示词），高级配置后续添加。

---

### 2.2 编辑器工具栏按钮（需求【2】）

#### 2.2.1 按钮位置

**✅ 已确认**：AI 编辑按钮放在"插入组"之后。

**工具栏布局（从左到右）**：
1. 搜索按钮
2. 分隔线
3. 格式组（加粗、斜体、行内代码）
4. 分隔线
5. 标题菜单（H1-H6）
6. 分隔线
7. 列表组（无序列表、有序列表）
8. 分隔线
9. 插入组（链接、代码块）
10. **分隔线**
11. **AI 编辑按钮** ← 新按钮位置
12. 分隔线
13. 更多菜单
14. Spacer（弹性空间）
15. 视图模式切换

**理由**：AI 编辑本质上是"插入内容"的操作，逻辑上属于插入类功能。

---

#### 2.2.2 按钮设计

**✅ 已确认的按钮规格**：
- **图标**：`sparkles`（SF Symbols）
- **标题**：`"AI 编辑"`
- **快捷键**：不设置快捷键（初期）
- **工具提示**：`"使用 AI 生成或编辑内容"`
- **视觉样式**：标准按钮样式，与其他工具栏按钮保持一致（32x32pt 点击区域）

**按钮实现**：
- 使用 `NoteListToolbarButton` 组件（与其他工具栏按钮一致）
- 图标大小：与其他按钮一致
- 点击区域：32x32pt

---

#### 2.2.3 对话框设计

**对话框内容**：

1. **标题**：`"AI 编辑助手"`

2. **输入区域**：
   - **标签**：`"请输入您的需求"`
   - **输入框类型**：多行文本输入框（`TextEditor`，高度 5-6 行）
   - **占位符文本**：`"描述您希望 AI 生成的内容"`
   - **字符限制**：500 字符（超出时显示提示）
   - **验证**：非空验证（点击"生成"时检查）

3. **上下文信息**：
   - **开关**：`"包含当前笔记内容作为上下文"`（复选框）
   - **默认状态**：关闭（不包含）
   - **显示信息**：当开关打开时，显示当前笔记的标题和前 500 字符预览
   - **说明文字**：`"包含当前笔记内容可以帮助 AI 更好地理解上下文"`
   - **发送内容**：如果开启，发送当前笔记的前 1000 字符作为上下文

**✅ 已确认**：提供开关让用户选择是否包含上下文，默认关闭。

4. **操作按钮**（水平排列，符合 macOS HIG）：
   - **布局**：`[取消] [清除] [生成]`
   - **"取消"按钮**（左侧）
     - 功能：关闭对话框，不执行任何操作
     - 快捷键：`ESC`
     - Action：`dismissAIEditorDialog`
   - **"清除"按钮**（中间）
     - 功能：清空输入框内容（无需确认）
     - Action：`aiEditorPromptChanged("")`
   - **"生成"按钮**（右侧，主要操作）
     - 样式：主要按钮样式（蓝色背景）
     - 快捷键：`⌘⏎`（Command + Enter）
     - 状态：生成中时禁用并显示加载指示器
     - Action：`generateAIContent`
     - 验证：点击时检查输入框非空

5. **状态显示**：
   - **生成中**：流式输出到预览区域（内容逐步显示）
   - **生成完成**：显示完整内容，底部显示"确认插入"和"取消"按钮
   - **错误状态**：显示错误消息（红色文字），提供"重试"按钮

6. **错误处理**（简单模式）：
   - **错误显示位置**：在预览区域显示错误消息（红色文字）
   - **错误消息**：显示简要错误信息（如"网络错误"、"API 调用失败"等）
   - **重试按钮**：显示"重试"按钮，用户可以点击重试
   - **不保存错误历史**：错误信息不持久化

6. **预览区域**（生成成功后显示）：
   - **位置**：输入框下方
   - **高度**：200-250pt（可滚动）
   - **内容**：显示生成的内容（Markdown 格式，只读）
   - **流式输出**：生成过程中内容逐步显示（支持流式响应）
   - **样式**：使用 `ScrollView + Text` 或 `TextEditor`（只读模式，不可编辑）
   - **编辑**：初期不支持编辑，用户确认后直接插入，如需修改可在插入后手动编辑

**✅ 已确认的对话框规格**：
- **尺寸**：固定 600pt × 400pt（宽度 × 高度）
- **实现方式**：SwiftUI `.sheet`（符合 macOS 设计规范）
- **标题**：`"AI 编辑助手"`
- **可调整大小**：初期固定尺寸，未来可以考虑可调整大小

---

#### 2.2.4 AI 请求流程

**流程设计**：

1. **用户输入需求** → 点击"生成"按钮
2. **验证配置**：
   - 检查 API 端点是否配置
   - 检查 API Key 是否配置
   - 如果未配置，显示错误提示并引导用户到设置面板
3. **构建请求**：
   - 系统提示词（来自设置）
   - 用户提示词（来自对话框输入）
   - 上下文（可选，当前笔记内容）
4. **发送请求（流式）**：
   - 显示预览区域（初始为空）
   - 异步调用 LLM API（流式响应）
   - 内容逐步追加到预览区域（实时更新）
5. **处理响应**：
   - **流式输出中**：内容逐步显示在预览区域
   - **生成完成**：显示完整内容，底部显示"确认插入"和"取消"按钮
   - **失败**：显示错误消息，允许重试
6. **用户确认**：
   - 用户查看预览内容
   - 点击"确认插入"：内容插入到编辑器末尾（带标记）
   - 点击"取消"：关闭对话框，不插入内容

**问题 10**：是否需要支持"重新生成"功能？

**建议**：初期不提供，未来可以添加。

**问题 11**：生成的内容是否需要支持编辑后再插入？

**建议**：初期不提供，未来可以添加。

---

#### 2.2.5 内容插入位置

**问题 12**：内容应该插入到编辑器的哪个位置？

**选项**：
- A. 插入到光标位置
- B. 插入到文档末尾（用户需求中提到的）
- C. 让用户选择插入位置

**✅ 已确认**：插入到编辑器页尾部（文档末尾）

**插入格式**：
- 位置：文档末尾
- 格式：前后各两个空行 + HTML 注释标记
- 完整格式：
  ```
  [现有笔记内容]
  
  <!-- AI生成内容开始 -->
  
  [AI 生成的内容]
  
  <!-- AI生成内容结束 -->
  ```

---

## 3. 技术架构

### 3.1 数据模型

#### 3.1.1 EditorPreferences 扩展

需要在 `EditorPreferences` 中添加新的配置字段：

```swift
// MARK: - AI 配置
var aiConfig: AIConfig = AIConfig()

struct AIConfig: Codable, Equatable {
    var endpoint: String = "https://api.deepseek.com/v1/chat/completions"
    var apiKey: String = ""
    var model: String = "deepseek-chat"
    var systemPrompt: String = """
    你是一个专业的 Markdown 笔记助手...
    """
    // 未来可扩展：
    // var timeout: TimeInterval = 30.0
    // var maxTokens: Int = 2000
    // var temperature: Double = 0.7
}
```

**✅ 已确认**：采用混合方式存储 API Key。

**存储策略**：
- **初期**：使用 `UserDefaults` 明文存储（快速实现）
- **未来**：升级为 `Keychain` 加密存储（安全存储）
- **迁移**：从 UserDefaults 迁移到 Keychain 时，需要数据迁移逻辑

**实现说明**：
- 初期：`UserDefaults.standard.set(apiKey, forKey: "llmApiKey")`
- 未来：使用 `KeychainAccess` 或系统 Keychain API

---

#### 3.1.2 SettingsFeature 扩展

需要在 `SettingsFeature.State` 中添加 AI 配置状态：

```swift
var aiConfig: EditorPreferences.AIConfig
var originalAiConfig: EditorPreferences.AIConfig  // 用于取消操作
```

需要在 `SettingsFeature.Action` 中添加新的 Action：

```swift
// MARK: - AI Config Actions
case aiEndpointChanged(String)
case aiApiKeyChanged(String)
case aiModelChanged(String)
case aiSystemPromptChanged(String)
```

---

#### 3.1.3 EditorFeature 扩展

需要在 `EditorFeature.State` 中添加 AI 对话框状态：

```swift
// MARK: - AI Editor State
struct AIEditorState: Equatable {
    var isDialogVisible: Bool = false           // 对话框是否可见
    var userPrompt: String = ""                 // 用户输入的提示词
    var isGenerating: Bool = false              // 是否正在生成（用于显示加载状态）
    var generatedContent: String = ""           // 生成的内容（用于预览，流式追加）
    var errorMessage: String? = nil             // 错误消息
    var includeContext: Bool = false            // 是否包含当前笔记内容作为上下文（默认关闭）
    var showContentPreview: Bool = false        // 是否显示内容预览（开始生成后显示）
}

var aiEditor: AIEditorState = AIEditorState()
```

需要在 `EditorFeature.Action` 中添加新的 Action：

```swift
// MARK: - AI Editor Actions
case showAIEditorDialog                    // 显示对话框
case dismissAIEditorDialog                 // 关闭对话框（取消按钮）
case aiEditorPromptChanged(String)         // 用户输入变化（绑定）
case aiEditorIncludeContextChanged(Bool)   // 上下文开关变化（绑定）
case generateAIContent                     // 点击生成按钮
case aiContentChunkReceived(String)         // 流式输出：接收到内容块
case aiContentGenerated(Result<String, Error>)  // AI 内容生成完成（流式结束）
case confirmInsertAIContent                // 确认插入内容
case cancelInsertAIContent                 // 取消插入（在预览阶段）
case retryGenerateContent                  // 重试生成（错误时）
```

**TCA 状态管理要点**：
- 所有 UI 交互通过 Action 触发
- 状态变化通过 Reducer 处理
- 异步操作（LLM API 调用）使用 `.run` Effect
- 使用 `@Bindable` 处理输入框和开关的绑定

---

### 3.2 服务层

#### 3.2.1 LLMService

需要创建新的服务来处理 LLM API 调用：

```swift
protocol LLMServiceProtocol {
    /// 生成内容（流式响应）
    /// - Returns: AsyncStream<String>，每个元素是增量内容
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

**问题 15**：服务应该放在哪个目录？

**建议**：`Nota4/Nota4/Services/LLMService.swift`

**✅ 已确认**：需要支持流式响应（Streaming）。

**流式输出要求**：
- LLM API 调用使用流式模式
- 内容逐步追加到预览区域
- 实时更新预览内容（使用 `AsyncStream` 或类似机制）
- 生成完成后显示确认按钮

---

### 3.3 UI 组件

#### 3.3.1 设置面板组件

需要创建新的设置面板组件：

- `AISettingsPanel.swift` - AI 配置面板

**✅ 已确认**：使用分组布局（Group），符合 macOS 设置面板设计规范。

**布局设计**：

**分组 1：API 配置**
- **API 端点**
  - 标签：`"API 端点"`
  - 输入框：单行文本输入框
  - 默认值：`"https://api.deepseek.com/v1/chat/completions"`
  - 说明文字：`"DeepSeek API 端点地址"`
  
- **API Key**
  - 标签：`"API Key"`
  - 输入框：安全文本输入框（显示为密码框）
  - 默认值：空字符串
  - 说明文字：`"请输入您的 DeepSeek API Key"`
  - 验证：保存时检查非空
  
- **模型名称**
  - 标签：`"模型名称"`
  - 输入框：单行文本输入框
  - 默认值：`"deepseek-chat"`
  - 说明文字：`"DeepSeek 模型名称"`

**分组 2：系统提示词**
- **系统提示词**
  - 标签：`"系统提示词"`
  - 输入框：多行文本编辑器（`TextEditor`，高度 8-10 行）
  - 默认值：通用写作助手提示词（见上方）
  - 说明文字：`"用于指导 AI 生成内容的系统提示词，可以自定义修改"`
  - 可编辑：用户可以随时修改

**UI 组件**：
- 使用 SwiftUI `Group` 或 `Section` 组件
- 每个输入框前有清晰的标签
- 使用 `Form` 布局，符合 macOS 设计规范

---

#### 3.3.2 编辑器对话框组件

需要创建新的对话框组件：

- `AIEditorDialog.swift` - AI 编辑对话框

**✅ 已确认**：使用 SwiftUI 的 `.sheet` 实现对话框，符合 macOS 设计规范。

---

## 4. 待确认问题总结

### 设置面板相关

1. ✅ **问题 1**：AI 设置分类的位置（**已确认**：放在"外观"之后）
2. ✅ **问题 2**：是否需要支持多个 LLM 提供商预设（**已确认**：初期只支持 DeepSeek，简单模式）
3. ✅ **问题 3**：默认系统提示词的内容（**已确认**：使用通用写作助手版本，可手工编辑）
4. ❓ **问题 4**：是否需要预设提示词模板（建议：初期不提供）
5. ❓ **问题 5**：是否需要高级配置（超时、Token、温度）（建议：初期不提供）

### 编辑器工具栏相关

6. ✅ **问题 6**：AI 按钮的位置（**已确认**：放在"插入组"之后）
7. ✅ **问题 7**：按钮的视觉样式（**已确认**：标准样式，图标 `sparkles`，标题 "AI 编辑"，无快捷键）
8. ✅ **问题 8**：输入框设计（**已确认**：5-6 行多行文本，占位符 "描述您希望 AI 生成的内容"，字符限制 500）
8a. ✅ **问题 8a**：是否包含当前笔记内容作为上下文（**已确认**：提供开关，默认关闭）
8b. ✅ **问题 8b**：是否需要预设提示词模板（**已确认**：初期不提供，用户完全自由输入）
9. ✅ **问题 9**：对话框的尺寸（**已确认**：600pt × 400pt，使用 SwiftUI `.sheet`，标题 "AI 编辑助手"）
10. ✅ **问题 10**：操作按钮设计（**已确认**：水平排列，生成按钮 ⌘⏎，取消按钮 ESC，符合 TCA 状态管理）
10a. ❓ **问题 10a**：是否需要"重新生成"功能（建议：初期不提供）
11. ✅ **问题 11**：生成内容后的预览和确认流程（**已确认**：两步确认流程，支持流式输出到预览区域）
11a. ✅ **问题 11a**：生成内容是否需要支持编辑（**已确认**：初期不支持编辑，预览区域只读）
11b. ✅ **问题 11b**：错误处理和重试机制（**已确认**：简单错误提示，显示错误消息和重试按钮）
12. ✅ **问题 12**：内容插入位置（已明确：文档末尾）
13. ✅ **问题 13**：插入时的分隔符（**已确认**：前后各两个空行 + HTML 注释标记 "AI生成内容开始/结束"）

### 技术架构相关

14. ✅ **问题 14**：API Key 存储方式（**已确认**：初期 UserDefaults，未来升级为 Keychain）
15. ✅ **问题 15**：服务放置目录（建议：`Nota4/Services/LLMService.swift`）
16. ✅ **问题 16**：是否需要支持流式响应（**已确认**：需要支持流式响应，内容逐步显示在预览区域）
17. ✅ **问题 17**：设置面板的布局（**已确认**：分组布局，API 配置和系统提示词分为两个分组）
18. ✅ **问题 18**：对话框的实现方式（**已确认**：使用 SwiftUI `.sheet`，符合 macOS 设计规范）

---

## 5. 相关文档

### 5.1 技术架构规范

**文档**：`Nota4/Docs/Architecture/AI_EDITOR_TECHNICAL_SPEC.md`

详细说明：
- TCA 状态管理机制实现
- 数据模型定义
- Reducer 实现细节
- LLMService 实现
- 测试策略

### 5.2 UI 设计文档

**文档**：`Nota4/Docs/Design/AI_EDITOR_UI_DESIGN.md`

详细说明：
- 设置面板 UI 设计
- AI 编辑对话框 UI 设计
- 交互流程设计
- 视觉规范
- 可访问性设计

---

## 6. 下一步行动

1. ✅ **确认问题**：核心问题已确认
2. ✅ **完善 PRD**：PRD 已完善
3. ✅ **技术评审**：技术架构规范已生成（见相关文档）
4. ✅ **UI 设计**：UI 设计文档已生成（见相关文档）
5. **开发计划**：制定分阶段开发计划
6. **开始开发**：根据 PRD 和技术规范开始实现

---

## 附录

### A. 参考资源

- [DeepSeek API 文档](https://platform.deepseek.com/api-docs/)
- [OpenAI API 文档](https://platform.openai.com/docs/api-reference)（未来参考）
- TCA 架构文档

### B. 相关文件

- `Nota4/Nota4/Features/Preferences/SettingsFeature.swift`
- `Nota4/Nota4/Features/Preferences/SettingsView.swift`
- `Nota4/Nota4/Features/Editor/EditorFeature.swift`
- `Nota4/Nota4/Features/Editor/IndependentToolbar.swift`
- `Nota4/Nota4/Models/EditorPreferences.swift`


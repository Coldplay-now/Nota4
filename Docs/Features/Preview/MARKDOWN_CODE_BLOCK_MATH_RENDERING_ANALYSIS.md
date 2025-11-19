# Markdown 代码块中 $ 符号被误识别为数学公式的问题分析

## 问题描述

在 Markdown 预览渲染引擎中，bash 命令代码块（以及其他包含 `$` 符号的代码块）中的 `$` 符号被错误地渲染成数学公式，而不是作为代码块内的普通字符。

### 问题示例

```bash
```bash
echo $USER
export PATH=$HOME/bin:$PATH
```
```

**当前错误行为**：
- `$USER` 被误识别为行内数学公式 `$USER$`
- `$HOME` 被误识别为行内数学公式 `$HOME$`
- `$PATH` 被误识别为行内数学公式 `$PATH$`

**期望行为**：
- 代码块内的所有 `$` 符号应该作为普通字符显示，不应该被数学公式渲染引擎处理

## 问题根源分析

### 当前实现流程

在 `MarkdownRenderer.swift` 的 `preprocess` 方法中：

1. **第82-103行**：提取 Mermaid 代码块（```mermaid...```）
2. **第105-125行**：提取块级数学公式（$$...$$）
3. **第127-147行**：提取行内数学公式（$...$）← **问题所在**

### 问题代码

```swift
// 提取行内公式（$...$）
let inlineMathPattern = "\\$([^$\\n]+?)\\$"
if let regex = try? NSRegularExpression(pattern: inlineMathPattern) {
    let matches = regex.matches(
        in: result,
        range: NSRange(result.startIndex..., in: result)
    )
    
    for match in matches.reversed() {
        // ... 替换为数学公式占位符
    }
}
```

**问题**：
- 这个正则表达式 `\\$([^$\\n]+?)\\$` 会在**整个 Markdown 文本**中匹配 `$...$` 模式
- **没有排除代码块内的内容**
- 因此，bash 代码块中的 `$USER`、`$HOME` 等变量会被误匹配

### 对比：Nota2 的正确实现

Nota2 使用了"保护-处理-恢复"模式：

```swift
// 1. 先保护代码块
let (protectedCode, codePlaceholders) = protectMarkdownCodeBlocks(in: markdown)

// 2. 在保护后的文本中提取数学公式（此时代码块已被占位符替换）
let (protected, mathPlaceholders) = protectMathExpressions(in: protectedCode)

// 3. 恢复代码块
let markdownWithCode = restorePlaceholders(in: protectedHighlight, using: codePlaceholders)

// 4. 解析 Markdown
let html = parseMarkdown(markdownWithCode)

// 5. 恢复数学公式
let htmlWithMath = restorePlaceholders(in: html, using: mathPlaceholders)
```

**关键点**：
- ✅ 先保护代码块，替换为占位符
- ✅ 在保护后的文本中提取数学公式（不会匹配到代码块内的 `$`）
- ✅ 恢复代码块后再解析 Markdown
- ✅ 最后恢复数学公式

## 解决方案设计

### 方案1：在 preprocess 中添加代码块保护（推荐）

**实现步骤**：

1. **在 `preprocess` 方法开始处，先保护所有代码块**：
   ```swift
   // 保护所有代码块（```...```），包括 bash、shell、python 等
   let (protectedMarkdown, codeBlockPlaceholders) = protectCodeBlocks(in: markdown)
   ```

2. **在保护后的文本中提取数学公式**：
   ```swift
   // 现在提取数学公式，不会匹配到代码块内的 $ 符号
   let (protectedMath, mathPlaceholders) = extractMathFormulas(in: protectedMarkdown)
   ```

3. **恢复代码块占位符**：
   ```swift
   // 恢复代码块，准备进行 Markdown 解析
   let markdownForParsing = restoreCodeBlocks(in: protectedMath, using: codeBlockPlaceholders)
   ```

4. **返回预处理结果**：
   ```swift
   return PreprocessedMarkdown(
       markdown: markdownForParsing,
       mermaidCharts: mermaidCharts,
       mathFormulas: mathFormulas,
       codeBlockPlaceholders: codeBlockPlaceholders  // 保存占位符，用于后续恢复
   )
   ```

**优点**：
- ✅ 逻辑清晰，符合"保护-处理-恢复"模式
- ✅ 与 Nota2 的实现一致，已验证有效
- ✅ 完全解决代码块内 `$` 符号被误识别的问题
- ✅ 易于维护和测试

**缺点**：
- 需要修改 `preprocess` 方法和 `PreprocessedMarkdown` 结构

### 方案2：改进正则表达式（不推荐）

修改行内公式的正则表达式，排除代码块内的匹配：

```swift
// 复杂的正则表达式，尝试排除代码块
let inlineMathPattern = "\\$(?!```)([^$\\n]+?)\\$(?!```)"
```

**缺点**：
- ❌ 正则表达式会变得非常复杂
- ❌ 难以保证完全正确（代码块可能跨多行）
- ❌ 维护困难

### 方案3：检查上下文（不推荐）

在匹配到 `$...$` 时，检查是否在代码块内：

**缺点**：
- ❌ 实现复杂，需要维护代码块位置信息
- ❌ 性能开销大
- ❌ 容易出错

## TCA 状态管理机制检查

### 当前架构

- `MarkdownRenderer` 是一个 `actor`，负责渲染逻辑
- `EditorFeature` 通过 `@Dependency(\.markdownRenderer)` 注入依赖
- 渲染是异步操作，通过 Effect 执行

### 修改影响

**需要修改的部分**：
- ✅ `MarkdownRenderer.preprocess` 方法（内部逻辑优化）
- ✅ `PreprocessedMarkdown` 结构（可能需要添加 `codeBlockPlaceholders` 字段）

**不需要修改的部分**：
- ❌ `EditorFeature` 的状态和 Action（无需修改）
- ❌ TCA 的依赖注入机制（无需修改）
- ❌ 渲染的调用方式（无需修改）

### 符合 TCA 原则

- ✅ **渲染逻辑在 Service 层**：`MarkdownRenderer` 是独立的服务
- ✅ **不涉及 Feature 状态管理**：这是纯函数逻辑，无状态
- ✅ **纯函数式处理**：输入 Markdown，输出 HTML，无副作用
- ✅ **通过依赖注入使用**：符合 TCA 的依赖管理机制

## 实施建议

### 推荐实施方案

**采用方案1**：在 `preprocess` 方法中添加代码块保护逻辑

### 实施步骤

1. **添加代码块保护方法**：
   ```swift
   private func protectCodeBlocks(in markdown: String) -> (String, [String: String]) {
       // 匹配所有代码块：```...```
       // 替换为占位符：CODEBLOCK_PLACEHOLDER_0, CODEBLOCK_PLACEHOLDER_1, ...
       // 返回：(保护后的文本, 占位符映射)
   }
   ```

2. **修改 `preprocess` 方法**：
   - 在提取 Mermaid 之前，先保护所有代码块
   - 在保护后的文本中提取数学公式
   - 恢复代码块占位符

3. **添加代码块恢复方法**：
   ```swift
   private func restoreCodeBlocks(in text: String, using placeholders: [String: String]) -> String {
       // 将占位符恢复为原始代码块
   }
   ```

4. **测试验证**：
   - 测试 bash 代码块中的 `$` 符号不被误识别
   - 测试正常的数学公式仍然可以正确渲染
   - 测试代码块和数学公式混合的场景

### 注意事项

1. **占位符格式**：使用唯一的占位符格式，避免与 Markdown 内容冲突
2. **处理顺序**：确保代码块保护在数学公式提取之前
3. **恢复顺序**：确保代码块恢复在 Markdown 解析之前
4. **边界情况**：处理代码块内包含 `$$` 的情况（虽然罕见）

## 未来优化：代码块语法高亮方案设计

### 当前实现

Nota4 目前使用 **Splash** 进行代码块语法高亮：

```swift
// MarkdownRenderer.swift
private let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())

private func highlightCodeBlocks(_ html: String) -> String {
    // 使用 Splash 高亮
    let highlighted = highlighter.highlight(code)
    // ...
}
```

**Splash 的特点**：
- ✅ Swift 原生库，无需网络依赖
- ✅ 支持多种编程语言
- ✅ 性能好，本地处理
- ❌ 支持的语言相对有限
- ❌ 主题选择较少
- ❌ 高亮质量可能不如 highlight.js

### 使用 highlight.js 的可行性分析

#### 优势

1. **语言支持广泛**
   - 支持 190+ 种编程语言
   - 包括 bash、shell、zsh 等脚本语言
   - 自动语言检测

2. **主题丰富**
   - 提供 100+ 种主题
   - 支持浅色和深色主题
   - 可以根据 Nota4 的主题系统动态切换

3. **高亮质量高**
   - 业界标准，广泛使用
   - 持续更新和维护
   - 支持复杂的语法结构

4. **浏览器端渲染**
   - 在 WKWebView 中通过 JavaScript 执行
   - 不阻塞 Swift 主线程
   - 可以异步加载

#### 劣势

1. **网络依赖**
   - 需要从 CDN 加载（或本地打包）
   - 首次加载需要时间
   - 离线环境可能无法使用

2. **性能考虑**
   - JavaScript 执行需要时间
   - 大代码块可能影响渲染速度

3. **集成复杂度**
   - 需要在 HTML 模板中添加 highlight.js 脚本
   - 需要在 JavaScript 中调用高亮函数
   - 需要处理主题切换

### highlight.js 集成方案设计

#### 方案A：完全替换 Splash（推荐）

**实施步骤**：

1. **在 HTML 模板中添加 highlight.js**：
   ```swift
   private func getHighlightJSScript() -> String {
       return """
       <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/styles/atom-one-dark.min.css" id="hljs-theme">
       <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/highlight.min.js"></script>
       <script>
           // 配置 highlight.js
           hljs.configure({
               languages: ['bash', 'shell', 'python', 'swift', 'javascript', 'typescript', 'go', 'rust', 'java', 'cpp', 'c', 'html', 'css', 'json', 'yaml', 'markdown', 'sql', 'sqlite', 'dockerfile', 'makefile', 'plaintext']
           });
       </script>
       """
   }
   ```

2. **修改 `highlightCodeBlocks` 方法**：
   - 移除 Splash 的高亮逻辑
   - 只生成标准的 HTML 代码块结构
   - 添加 `class="language-xxx"` 属性供 highlight.js 识别

3. **在 JavaScript 中调用 highlight.js**：
   ```javascript
   // 在 buildFullHTML 的 script 部分添加
   document.addEventListener('DOMContentLoaded', function() {
       // 高亮所有代码块（排除 Mermaid）
       document.querySelectorAll('pre code:not(.language-mermaid)').forEach((block) => {
           hljs.highlightElement(block);
       });
   });
   ```

4. **支持主题切换**：
   - 根据 Nota4 的主题系统动态加载不同的 highlight.js 主题
   - 浅色主题：`atom-one-light`、`github`、`xcode`
   - 深色主题：`atom-one-dark`、`dracula`、`monokai`

**优点**：
- ✅ 语言支持广泛
- ✅ 高亮质量高
- ✅ 主题丰富
- ✅ 与 Nota2 的实现一致

**缺点**：
- ❌ 需要网络连接（或本地打包）
- ❌ 移除 Splash 依赖

#### 方案B：混合方案（Splash + highlight.js）

**实施步骤**：

1. **保留 Splash 作为默认高亮引擎**
2. **添加 highlight.js 作为可选引擎**
3. **在 `RenderOptions` 中添加高亮引擎选择**：
   ```swift
   struct RenderOptions: Equatable {
       var highlightEngine: HighlightEngine = .splash
       
       enum HighlightEngine: String, Equatable {
           case splash      // Swift 原生，离线可用
           case highlightjs // 浏览器端，语言支持广泛
       }
   }
   ```

4. **根据选择使用不同的高亮方式**：
   - `splash`：使用当前的 Splash 实现
   - `highlightjs`：生成标准 HTML，由 JavaScript 高亮

**优点**：
- ✅ 保留离线能力（Splash）
- ✅ 提供更好的高亮质量（highlight.js）
- ✅ 用户可以选择

**缺点**：
- ❌ 实现复杂度较高
- ❌ 需要维护两套高亮逻辑

#### 方案C：仅添加 highlight.js 脚本，保留 Splash（过渡方案）

**实施步骤**：

1. **保留当前的 Splash 高亮逻辑**
2. **在 HTML 中添加 highlight.js 脚本**
3. **在 JavaScript 中，如果 Splash 高亮不完整，使用 highlight.js 补充**：
   ```javascript
   // 对未高亮的代码块使用 highlight.js
   document.querySelectorAll('pre code:not(.hljs):not(.language-mermaid)').forEach((block) => {
       hljs.highlightElement(block);
   });
   ```

**优点**：
- ✅ 改动最小
- ✅ 渐进式增强
- ✅ 向后兼容

**缺点**：
- ❌ 可能产生重复高亮
- ❌ 逻辑不够清晰

### TCA 状态管理机制集成

#### 当前架构

```
EditorFeature.State
  └── PreviewState
      └── renderOptions: RenderOptions
          └── (可以添加 highlightEngine 选项)
```

#### 集成方案

**方案1：通过 RenderOptions 控制**（推荐）

```swift
// RenderTypes.swift
struct RenderOptions: Equatable {
    var themeId: String? = nil
    var includeTOC: Bool = false
    var codeLineNumbers: Bool = false
    var highlightEngine: HighlightEngine = .splash  // 新增
    var noteDirectory: URL? = nil
    
    enum HighlightEngine: String, Equatable {
        case splash
        case highlightjs
    }
}
```

**状态流转**：
1. 用户在设置中选择高亮引擎
2. 更新 `EditorFeature.State.preview.renderOptions.highlightEngine`
3. 触发预览重新渲染
4. `MarkdownRenderer` 根据 `highlightEngine` 选择高亮方式

**TCA 合规性**：
- ✅ 状态在 `EditorFeature.State` 中定义
- ✅ 通过 `RenderOptions` 传递配置
- ✅ 渲染逻辑在 Service 层（`MarkdownRenderer`）
- ✅ 不涉及 Feature 的业务逻辑

**方案2：通过主题配置控制**

```swift
// ThemeConfig.swift
struct ThemeConfig {
    let codeHighlightTheme: CodeTheme
    let highlightEngine: HighlightEngine  // 新增
}
```

**优点**：
- 主题和高亮引擎绑定，体验一致

**缺点**：
- 灵活性较低，用户无法独立选择

### highlight.js 实施细节

#### 1. HTML 模板修改

在 `buildFullHTML` 方法中：

```swift
private func buildFullHTML(...) async -> String {
    return """
    <!DOCTYPE html>
    <html>
    <head>
        ...
        \(getHighlightJSScript())  // 新增
        \(getMermaidScript())
        \(getKaTeXScript())
    </head>
    <body>
        ...
        <script>
            // 初始化 highlight.js
            document.addEventListener('DOMContentLoaded', function() {
                // 高亮所有代码块（排除 Mermaid）
                document.querySelectorAll('pre code:not(.language-mermaid)').forEach((block) => {
                    hljs.highlightElement(block);
                });
            });
            
            // 主题切换时重新高亮
            function rehighlightCode() {
                document.querySelectorAll('pre code:not(.language-mermaid)').forEach((block) => {
                    hljs.highlightElement(block);
                });
            }
        </script>
    </body>
    </html>
    """
}
```

#### 2. 主题切换支持

```swift
private func getHighlightJSScript(for themeId: String?) -> String {
    let theme = getThemeName(for: themeId)  // 根据主题ID获取 highlight.js 主题名
    
    return """
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/styles/\(theme).min.css" id="hljs-theme">
    <script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/highlight.min.js"></script>
    """
}
```

#### 3. 代码块处理修改

```swift
private func highlightCodeBlocks(_ html: String, options: RenderOptions) -> String {
    switch options.highlightEngine {
    case .splash:
        // 使用 Splash 高亮（当前实现）
        return highlightWithSplash(html)
        
    case .highlightjs:
        // 生成标准 HTML，由 highlight.js 在浏览器端高亮
        return prepareForHighlightJS(html)
    }
}
```

### 性能考虑

1. **CDN 加载**：
   - highlight.js 库大小约 100KB（压缩后）
   - 首次加载需要网络请求
   - 可以考虑本地打包，避免网络依赖

2. **高亮性能**：
   - highlight.js 在浏览器端执行，不阻塞 Swift 主线程
   - 大代码块（>1000行）可能需要优化
   - 可以考虑延迟高亮或虚拟滚动

3. **缓存策略**：
   - highlight.js 库可以缓存
   - 主题 CSS 可以缓存
   - 高亮结果可以缓存（如果内容未变化）

### 与当前代码块保护方案的兼容性

**重要**：代码块保护方案与 highlight.js 完全兼容：

1. **保护阶段**：代码块被替换为占位符，不影响高亮
2. **恢复阶段**：代码块恢复后，highlight.js 可以正常识别
3. **高亮阶段**：highlight.js 在浏览器端执行，处理已恢复的代码块

**处理顺序**：
```
Markdown 文本
  ↓
保护代码块（避免 $ 被误识别）
  ↓
提取数学公式
  ↓
恢复代码块
  ↓
解析 Markdown → HTML
  ↓
注入代码块结构（为 highlight.js 准备）
  ↓
注入数学公式
  ↓
生成完整 HTML
  ↓
浏览器加载
  ↓
highlight.js 高亮代码块（JavaScript 执行）
```

## 总结

**问题根源**：Nota4 的 `preprocess` 方法在提取数学公式时，没有先保护代码块，导致代码块内的 `$` 符号被误识别为行内数学公式。

**解决方案**：采用"保护-处理-恢复"模式，在提取数学公式之前先保护所有代码块，提取完成后再恢复。

**TCA 合规性**：修改仅在 Service 层（`MarkdownRenderer`），不涉及 Feature 的状态管理，完全符合 TCA 架构原则。

**未来优化：highlight.js 集成**：
- ✅ 使用 highlight.js 完全可行，且与 TCA 架构兼容
- ✅ 推荐方案：通过 `RenderOptions` 控制高亮引擎选择
- ✅ 可以在浏览器端异步执行，不阻塞 Swift 主线程
- ✅ 支持主题切换，与 Nota4 的主题系统集成
- ✅ 与代码块保护方案完全兼容


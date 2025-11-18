# Ink、Splash 和 highlight.js 的区别分析

## 概述

在 Nota4 的 Markdown 渲染流程中，使用了三个不同的库，它们各自负责不同的功能：

1. **Ink** - Markdown 解析器（Markdown → HTML）
2. **Splash** - 代码语法高亮（Swift 端）
3. **highlight.js** - 代码语法高亮（浏览器端，可选）

## 详细对比

### 1. Ink - Markdown 解析器

**作用**：将 Markdown 文本转换为 HTML

**在 Nota4 中的使用**：
```swift
import Ink

private let parser = MarkdownParser()  // Ink 的解析器

// 在 renderToHTML 中：
var html = parser.html(from: preprocessed.markdown)
```

**功能**：
- ✅ 解析 Markdown 语法（标题、列表、链接、图片、代码块等）
- ✅ 将 Markdown 转换为标准 HTML
- ✅ 支持 CommonMark 标准
- ✅ 纯 Swift 实现，性能优秀

**输出示例**：
```markdown
# 标题
这是一段文本
```

转换为：
```html
<h1>标题</h1>
<p>这是一段文本</p>
```

**代码块处理**：
Ink 会将代码块转换为：
```html
<pre><code class="language-swift">代码内容</code></pre>
```

**注意**：Ink **只负责解析和转换**，**不负责代码高亮**。代码块中的代码是**原始文本**，没有语法高亮。

---

### 2. Splash - 代码语法高亮（Swift 端）

**作用**：对代码块进行语法高亮，生成带高亮的 HTML

**在 Nota4 中的使用**：
```swift
import Splash

private let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())

// 在 highlightCodeBlocks 方法中：
let highlighted = highlighter.highlight(code)  // 对代码进行高亮
```

**功能**：
- ✅ 支持多种编程语言（Swift、JavaScript、Python、Go、Rust 等）
- ✅ 在 Swift 端处理，不依赖浏览器
- ✅ 输出 HTML 格式，带语法高亮标签
- ✅ 与 Ink 同一作者，集成无缝

**处理流程**：
1. Ink 解析后得到：`<pre><code class="language-swift">let x = 1</code></pre>`
2. Splash 提取代码内容：`let x = 1`
3. Splash 进行语法高亮，生成：
   ```html
   <pre><code class="language-swift">
   <span class="keyword">let</span> x = <span class="number">1</span>
   </code></pre>
   ```

**优点**：
- ✅ 离线可用，无需网络
- ✅ 性能好，本地处理
- ✅ 与 Ink 集成无缝

**缺点**：
- ❌ 支持的语言相对有限（约 20+ 种）
- ❌ 主题选择较少
- ❌ 高亮质量可能不如 highlight.js

---

### 3. highlight.js - 代码语法高亮（浏览器端）

**作用**：在浏览器端对代码块进行语法高亮

**使用方式**（JavaScript）：
```javascript
// 在 HTML 中加载 highlight.js
<script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/highlight.min.js"></script>

// 在页面加载后高亮代码块
document.querySelectorAll('pre code').forEach((block) => {
    hljs.highlightElement(block);
});
```

**功能**：
- ✅ 支持 190+ 种编程语言
- ✅ 提供 100+ 种主题
- ✅ 高亮质量高，业界标准
- ✅ 自动语言检测

**处理流程**：
1. Ink 解析后得到：`<pre><code class="language-swift">let x = 1</code></pre>`
2. HTML 加载到浏览器
3. highlight.js 在浏览器端执行，对代码块进行高亮
4. 生成带高亮的 HTML（在浏览器中）

**优点**：
- ✅ 语言支持广泛（190+ 种）
- ✅ 主题丰富（100+ 种）
- ✅ 高亮质量高
- ✅ 不阻塞 Swift 主线程（浏览器端异步执行）

**缺点**：
- ❌ 需要网络连接（CDN）或本地打包
- ❌ JavaScript 执行需要时间
- ❌ 离线环境可能无法使用

---

## 当前 Nota4 的渲染流程

### 当前实现（使用 Ink + Splash）

```
Markdown 文本
  ↓
预处理（提取 Mermaid、数学公式、代码块）
  ↓
Ink 解析 Markdown → HTML
  ↓
Splash 高亮代码块（Swift 端）
  ↓
注入 Mermaid 图表
  ↓
注入数学公式（KaTeX）
  ↓
生成完整 HTML
  ↓
浏览器显示
```

**代码示例**：
```swift
// 1. Ink 解析
var html = parser.html(from: preprocessed.markdown)
// 输出：<pre><code class="language-swift">let x = 1</code></pre>

// 2. Splash 高亮
let highlighted = highlighter.highlight(code)
// 输出：<span class="keyword">let</span> x = <span class="number">1</span>

// 3. 替换代码块
html = html.replacingOccurrences(of: originalCode, with: highlighted)
```

---

## 如果改用 highlight.js 的流程

### 方案A：完全替换 Splash

```
Markdown 文本
  ↓
预处理（提取 Mermaid、数学公式、代码块）
  ↓
Ink 解析 Markdown → HTML
  ↓
生成标准代码块 HTML（不进行高亮）
  ↓
注入 Mermaid 图表
  ↓
注入数学公式（KaTeX）
  ↓
生成完整 HTML（包含 highlight.js 脚本）
  ↓
浏览器加载
  ↓
highlight.js 高亮代码块（JavaScript 执行）
```

**代码示例**：
```swift
// 1. Ink 解析
var html = parser.html(from: preprocessed.markdown)
// 输出：<pre><code class="language-swift">let x = 1</code></pre>

// 2. 不进行高亮，直接保留原始代码块
// html 保持不变

// 3. 在 HTML 中添加 highlight.js 脚本
html = buildFullHTML(content: html, ...)
// 包含：<script src="highlight.js"></script>

// 4. 在 JavaScript 中高亮
// document.querySelectorAll('pre code').forEach((block) => {
//     hljs.highlightElement(block);
// });
```

---

## 关键区别总结

| 特性 | Ink | Splash | highlight.js |
|------|-----|--------|--------------|
| **主要作用** | Markdown 解析 | 代码高亮 | 代码高亮 |
| **处理位置** | Swift 端 | Swift 端 | 浏览器端（JavaScript） |
| **输入** | Markdown 文本 | 代码文本 | HTML 代码块 |
| **输出** | HTML | 高亮后的 HTML | 高亮后的 HTML（在浏览器中） |
| **语言支持** | Markdown 语法 | 20+ 种编程语言 | 190+ 种编程语言 |
| **主题支持** | 不适用 | 较少 | 100+ 种主题 |
| **网络依赖** | 否 | 否 | 是（CDN）或本地打包 |
| **性能** | 优秀 | 优秀 | 良好（浏览器端） |
| **离线支持** | ✅ | ✅ | ❌（除非本地打包） |

---

## 为什么需要区分？

### 常见误解

**误解1**：Ink 负责代码高亮
- ❌ **错误**：Ink 只负责 Markdown 解析，不负责代码高亮
- ✅ **正确**：Ink 将代码块转换为 HTML，但不进行语法高亮

**误解2**：Splash 和 highlight.js 可以替换 Ink
- ❌ **错误**：它们负责不同的功能
- ✅ **正确**：Ink 负责 Markdown 解析，Splash/highlight.js 负责代码高亮

**误解3**：可以同时使用 Splash 和 highlight.js
- ⚠️ **不推荐**：会产生重复高亮
- ✅ **正确做法**：选择其中一个作为高亮引擎

---

## 重构建议

### 当前问题

在 `MARKDOWN_CODE_BLOCK_MATH_RENDERING_ANALYSIS.md` 文档中，我们分析了代码块中 `$` 符号被误识别为数学公式的问题。

**关键点**：
- Ink 解析时，代码块会被转换为 `<pre><code>...</code></pre>`
- 但在 Ink 解析**之前**，我们需要先保护代码块，避免其中的 `$` 被数学公式提取逻辑误识别
- 保护代码块 → 提取数学公式 → 恢复代码块 → Ink 解析 → Splash 高亮

### 如果改用 highlight.js

**流程变化**：
- 保护代码块 → 提取数学公式 → 恢复代码块 → Ink 解析 → **不进行 Splash 高亮** → 生成 HTML → 浏览器加载 → **highlight.js 高亮**

**关键区别**：
- Splash：在 Swift 端高亮，高亮后的 HTML 直接写入最终 HTML
- highlight.js：在浏览器端高亮，原始代码块 HTML 写入最终 HTML，由 JavaScript 在浏览器中高亮

---

## 总结

1. **Ink**：Markdown 解析器，负责 Markdown → HTML 转换
2. **Splash**：代码高亮库（Swift 端），当前使用
3. **highlight.js**：代码高亮库（浏览器端），可选替代方案

**重构时需要注意**：
- Ink 必须保留（负责 Markdown 解析）
- Splash 和 highlight.js 是二选一的关系（都负责代码高亮）
- 如果改用 highlight.js，需要：
  1. 移除 Splash 的高亮逻辑
  2. 在 HTML 中添加 highlight.js 脚本
  3. 在 JavaScript 中调用高亮函数


import Foundation
import Ink
import Splash

// MARK: - Markdown Renderer

/// Markdown 渲染服务
/// 负责将 Markdown 文本转换为格式化的 HTML
actor MarkdownRenderer {
    // MARK: - Properties
    
    private let parser = MarkdownParser()
    private let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())
    private let themeManager = ThemeManager.shared
    
    // MARK: - Public Methods
    
    /// 渲染 Markdown 为完整 HTML
    func renderToHTML(
        markdown: String,
        options: RenderOptions = .default
    ) async throws -> String {
        // 1. 检测并处理 [TOC] 标记
        let hasTOCMarker = markdown.contains("[TOC]") || markdown.contains("[toc]")
        
        // 2. 预处理（提取 Mermaid、数学公式、代码块）
        let preprocessed = preprocess(markdown)
        
        // 3. Markdown → HTML（使用 Ink）
        var html = parser.html(from: preprocessed.markdown)
        
        // 3.5. 处理图片路径（验证和转换）
        html = processImagePaths(in: html, noteDirectory: options.noteDirectory)
        
        // 4. 生成 TOC 和标题映射（从预处理后的 Markdown，确保与 HTML 生成使用相同的源）
        //    这样可以使用映射来确保 ID 一致性
        let shouldGenerateTOC = hasTOCMarker || options.includeTOC
        let tocResult: (toc: String?, headingMap: [String: String])
        if shouldGenerateTOC {
            // 关键修复：使用预处理后的 markdown，与 parser.html() 使用相同的源
            let result = generateTOC(from: preprocessed.markdown)
            tocResult = (result.toc, result.headingMap)
        } else {
            tocResult = (nil, [:])
        }
        let toc = tocResult.toc
        let headingMap = tocResult.headingMap
        
        // 5. 为标题添加 id 属性（使用映射确保与 TOC 一致）
        html = addHeadingIds(to: html, headingMap: headingMap)
        
        // 6. 注入代码高亮
        html = highlightCodeBlocks(html)
        
        // 7. 注入 Mermaid 图表
        html = injectMermaidCharts(html, charts: preprocessed.mermaidCharts)
        
        // 8. 注入数学公式
        html = injectMathFormulas(html, formulas: preprocessed.mathFormulas)
        
        // 9. 替换 [TOC] 标记（如果有）
        if hasTOCMarker, let tocHTML = toc {
            html = html.replacingOccurrences(of: "<p>[TOC]</p>", with: tocHTML)
            html = html.replacingOccurrences(of: "<p>[toc]</p>", with: tocHTML)
        }
        
        // 10. 构建完整 HTML（如果有 [TOC] 标记，则不在顶部添加 TOC）
        return await buildFullHTML(
            content: html,
            toc: hasTOCMarker ? nil : toc,
            options: options
        )
    }
    
    // MARK: - Private Methods
    
    /// 保护 Markdown 代码块（```...```），避免其中的特殊字符被误处理
    /// - Parameter markdown: 原始 Markdown 文本
    /// - Returns: (保护后的文本, 占位符映射字典)
    private func protectCodeBlocks(in markdown: String) -> (String, [String: String]) {
        var protected = markdown
        var placeholders: [String: String] = [:]
        var counter = 0
        
        // 匹配代码块：```...```（非贪婪，允许跨行）
        // 排除已提取的 Mermaid 占位符
        let pattern = "```[\\s\\S]*?```"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return (protected, placeholders)
        }
        
        let matches = regex.matches(
            in: protected,
            range: NSRange(protected.startIndex..., in: protected)
        )
        
        // 从后往前替换，避免索引失效
        for match in matches.reversed() {
            if let range = Range(match.range, in: protected) {
                let codeBlock = String(protected[range])
                let placeholder = "CODEBLOCK_PLACEHOLDER_\(counter)"
                placeholders[placeholder] = codeBlock
                protected.replaceSubrange(range, with: placeholder)
                counter += 1
            }
        }
        
        return (protected, placeholders)
    }
    
    /// 恢复代码块占位符为原始代码块
    /// - Parameters:
    ///   - text: 包含占位符的文本
    ///   - placeholders: 占位符映射字典
    /// - Returns: 恢复后的文本
    private func restoreCodeBlocks(in text: String, using placeholders: [String: String]) -> String {
        var restored = text
        
        // 按照 key 的长度排序，先恢复长的占位符（避免部分匹配问题）
        let sortedPlaceholders = placeholders.sorted { $0.key.count > $1.key.count }
        
        for (placeholder, original) in sortedPlaceholders {
            restored = restored.replacingOccurrences(of: placeholder, with: original)
        }
        
        return restored
    }
    
    /// 预处理 Markdown（提取特殊块）
    private func preprocess(_ markdown: String) -> PreprocessedMarkdown {
        var result = markdown
        var mermaidCharts: [String] = []
        var mathFormulas: [MathFormula] = []
        
        // 1. 提取 Mermaid 代码块（保持现有逻辑）
        let mermaidPattern = "```mermaid\\n([\\s\\S]*?)```"
        if let regex = try? NSRegularExpression(pattern: mermaidPattern) {
            let matches = regex.matches(
                in: result,
                range: NSRange(result.startIndex..., in: result)
            )
            
            for (index, match) in matches.enumerated().reversed() {
                if let range = Range(match.range(at: 1), in: result) {
                    let chart = String(result[range])
                    mermaidCharts.insert(chart, at: 0)
                    
                    // 替换为占位符
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(
                        fullRange,
                        with: "<div class=\"mermaid-placeholder\" data-index=\"\(index)\"></div>"
                    )
                }
            }
        }
        
        // 2. 保护所有剩余代码块（避免其中的 $ 符号被误识别为数学公式）
        let (protectedMarkdown, codeBlockPlaceholders) = protectCodeBlocks(in: result)
        result = protectedMarkdown
        
        // 3. 提取数学公式（块公式 $$...$$）
        let blockMathPattern = "\\$\\$([\\s\\S]*?)\\$\\$"
        if let regex = try? NSRegularExpression(pattern: blockMathPattern) {
            let matches = regex.matches(
                in: result,
                range: NSRange(result.startIndex..., in: result)
            )
            
            for (_, match) in matches.enumerated().reversed() {
                if let range = Range(match.range(at: 1), in: result) {
                    let formula = String(result[range])
                    mathFormulas.insert(.block(formula), at: 0)
                    
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(
                        fullRange,
                        with: "<div class=\"math-placeholder block\" data-index=\"\(mathFormulas.count - 1)\"></div>"
                    )
                }
            }
        }
        
        // 4. 提取行内公式（$...$）
        let inlineMathPattern = "\\$([^$\\n]+?)\\$"
        if let regex = try? NSRegularExpression(pattern: inlineMathPattern) {
            let matches = regex.matches(
                in: result,
                range: NSRange(result.startIndex..., in: result)
            )
            
            for match in matches.reversed() {
                if let range = Range(match.range(at: 1), in: result) {
                    let formula = String(result[range])
                    mathFormulas.append(.inline(formula))
                    
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(
                        fullRange,
                        with: "<span class=\"math-placeholder inline\" data-index=\"\(mathFormulas.count - 1)\"></span>"
                    )
                }
            }
        }
        
        // 5. 恢复代码块占位符（准备进行 Markdown 解析）
        result = restoreCodeBlocks(in: result, using: codeBlockPlaceholders)
        
        return PreprocessedMarkdown(
            markdown: result,
            mermaidCharts: mermaidCharts,
            mathFormulas: mathFormulas
        )
    }
    
    /// 为标题添加 id 属性，以便锚点链接能正确跳转
    /// - Parameters:
    ///   - html: HTML 内容
    ///   - headingMap: 标题文本到 ID 的映射（从原始 Markdown 生成）
    /// - Returns: 添加了 id 属性的 HTML
    private func addHeadingIds(to html: String, headingMap: [String: String]) -> String {
        var result = html
        
        // 匹配所有 h1-h6 标题标签（包括嵌套的 HTML 标签）
        // 使用非贪婪匹配来捕获整个标题内容，包括嵌套标签
        let pattern = "<(h[1-6])([^>]*)>(.*?)</h[1-6]>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            return result
        }
        
        let matches = regex.matches(
            in: result,
            range: NSRange(result.startIndex..., in: result)
        )
        
        // 从后往前处理，避免索引偏移
        for match in matches.reversed() {
            guard match.numberOfRanges >= 4,
                  let tagRange = Range(match.range(at: 1), in: result),
                  let attrsRange = Range(match.range(at: 2), in: result),
                  let contentRange = Range(match.range(at: 3), in: result) else {
                continue
            }
            
            let tag = String(result[tagRange])
            let attrs = String(result[attrsRange])
            let content = String(result[contentRange])
            
            // 如果已经有 id 属性，跳过
            if attrs.contains("id=") {
                continue
            }
            
            // 从 HTML 内容中提取纯文本
            let plainText = extractPlainText(from: content)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 跳过空标题
            guard !plainText.isEmpty else {
                continue
            }
            
            // 优先使用映射中的 ID（确保与 TOC 一致）
            let id: String
            if let mappedID = headingMap[plainText] {
                // 找到精确匹配
                id = mappedID
            } else {
                // 如果映射中没有，尝试模糊匹配（处理可能的空白字符差异）
                let normalizedText = plainText.replacingOccurrences(
                    of: "\\s+",
                    with: " ",
                    options: .regularExpression
                ).trimmingCharacters(in: .whitespaces)
                
                if let mappedID = headingMap[normalizedText] {
                    id = mappedID
                } else {
                    // 如果仍然找不到，使用 generateHeadingID 生成（降级方案）
                    id = generateHeadingID(from: plainText)
                }
            }
            
            // 构建新的标题标签，添加 id 属性
            let newTag = "<\(tag)\(attrs.isEmpty ? "" : " \(attrs)") id=\"\(id)\">\(content)</\(tag)>"
            
            let fullRange = Range(match.range, in: result)!
            result.replaceSubrange(fullRange, with: newTag)
        }
        
        return result
    }
    
    /// 代码块语法高亮
    private func highlightCodeBlocks(_ html: String) -> String {
        var result = html
        
        // 匹配代码块
        let pattern = "<pre><code class=\"language-(\\w+)\">([\\s\\S]*?)</code></pre>"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return result
        }
        
        let matches = regex.matches(
            in: result,
            range: NSRange(result.startIndex..., in: result)
        )
        
        for match in matches.reversed() {
            guard let langRange = Range(match.range(at: 1), in: result),
                  let codeRange = Range(match.range(at: 2), in: result) else {
                continue
            }
            
            let language = String(result[langRange])
            let code = String(result[codeRange])
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&quot;", with: "\"")
            
            // 使用 Splash 高亮
            let highlighted = highlighter.highlight(code)
            
            let fullRange = Range(match.range, in: result)!
            // 转义代码内容用于复制按钮
            let escapedCode = code
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
                .replacingOccurrences(of: "\"", with: "&quot;")
                .replacingOccurrences(of: "'", with: "&#39;")
            
            result.replaceSubrange(
                fullRange,
                with: """
                <div class="code-block-wrapper">
                    <div class="code-block-header">
                        <span class="code-language">\(language)</span>
                        <button class="code-copy-btn" onclick="copyCode(this)" data-code="\(escapedCode)" title="复制代码">
                            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                                <path d="M4 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2z" stroke="currentColor" stroke-width="1.5"/>
                                <path d="M6 6h4M6 9h4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                            </svg>
                        </button>
                    </div>
                    <pre class="code-block" data-language="\(language)">
                        <code class="language-\(language)">\(highlighted)</code>
                    </pre>
                </div>
                """
            )
        }
        
        return result
    }
    
    /// 注入 Mermaid 图表
    private func injectMermaidCharts(_ html: String, charts: [String]) -> String {
        var result = html
        
        for (index, chart) in charts.enumerated() {
            let placeholder = "<div class=\"mermaid-placeholder\" data-index=\"\(index)\"></div>"
            let mermaidDiv = """
            <div class="mermaid">
            \(chart)
            </div>
            """
            result = result.replacingOccurrences(of: placeholder, with: mermaidDiv)
        }
        
        return result
    }
    
    /// 注入数学公式
    private func injectMathFormulas(_ html: String, formulas: [MathFormula]) -> String {
        var result = html
        
        for (index, formula) in formulas.enumerated() {
            switch formula {
            case .block(let latex):
                let placeholder = "<div class=\"math-placeholder block\" data-index=\"\(index)\"></div>"
                let mathDiv = """
                <div class="math-block">
                    <span class="katex-formula" data-formula="\(escapeHTML(latex))"></span>
                </div>
                """
                result = result.replacingOccurrences(of: placeholder, with: mathDiv)
                
            case .inline(let latex):
                let placeholder = "<span class=\"math-placeholder inline\" data-index=\"\(index)\"></span>"
                let mathSpan = """
                <span class="math-inline katex-formula" data-formula="\(escapeHTML(latex))"></span>
                """
                result = result.replacingOccurrences(of: placeholder, with: mathSpan)
            }
        }
        
        return result
    }
    
    /// 生成 TOC 和标题映射
    /// 返回: (toc: TOC HTML, headingMap: [标题文本: ID])
    /// 注意：会排除代码块、引用块、Mermaid 块、公式块中的标题
    private func generateTOC(from markdown: String) -> (toc: String, headingMap: [String: String]) {
        var toc = "<nav class=\"toc\">\n<h2>目录</h2>\n<ul>\n"
        var headingMap: [String: String] = [:]
        
        // 1. 标记所有需要跳过的区域（代码块、引用块、Mermaid 块、公式块）
        let excludedRanges = getExcludedRanges(from: markdown)
        
        // 2. 遍历所有行，只处理不在排除区域内的标题
        let lines = markdown.components(separatedBy: .newlines)
        var currentLevel = 0
        var currentOffset = 0 // 当前行的字符偏移量
        
        for line in lines {
            let lineStart = currentOffset
            let lineEnd = currentOffset + line.count
            let lineRange = lineStart..<lineEnd
            
            // 检查当前行是否在排除区域内
            let isExcluded = excludedRanges.contains { range in
                range.overlaps(lineRange)
            }
            
            // 如果不在排除区域内，且是标题行，则处理
            if !isExcluded && line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                
                // 确保 # 后面有空格（真正的标题格式）
                // Markdown 标题格式：至少一个 #，后面必须跟空格
                if level >= 1 && level <= 6 {
                    let afterHash = line.dropFirst(level)
                    let trimmedAfterHash = afterHash.trimmingCharacters(in: .whitespaces)
                    
                    // 标题格式：## 后面必须有空格
                    guard afterHash.first == " " || afterHash.isEmpty else {
                        currentOffset = lineEnd + 1
                        continue
                    }
                    
                    let title = trimmedAfterHash
                    
                    // 跳过空标题
                    guard !title.isEmpty else {
                        currentOffset = lineEnd + 1 // +1 for newline
                        continue
                    }
                    
                    // 清理 Markdown 格式，使其与 HTML 提取的纯文本一致
                    // 这是最小侵入性的修复：只移除常见的 Markdown 格式标记
                    let cleanTitle = title
                        .replacingOccurrences(of: "**", with: "")  // 移除加粗
                        .replacingOccurrences(of: "*", with: "")   // 移除斜体
                        .replacingOccurrences(of: "`", with: "")   // 移除代码
                        .replacingOccurrences(of: "~~", with: "")  // 移除删除线
                        .replacingOccurrences(of: "\\[([^\\]]+)\\]\\([^)]+\\)", with: "$1", options: .regularExpression)  // [text](url) -> text
                        .replacingOccurrences(of: "!\\[([^\\]]*)\\]\\([^)]+\\)", with: "", options: .regularExpression)  // 移除图片
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // 使用统一的 ID 生成函数
                    let id = generateHeadingID(from: cleanTitle)
                    
                    // 记录映射关系（键为清理后的标题文本，值为生成的 ID）
                    headingMap[cleanTitle] = id
                
                // 处理层级变化
                if level > currentLevel {
                    for _ in currentLevel..<level {
                        toc += "<ul>\n"
                    }
                } else if level < currentLevel {
                    for _ in level..<currentLevel {
                        toc += "</ul>\n</li>\n"
                    }
                }
                
                toc += "<li><a href=\"#\(id)\">\(escapeHTML(cleanTitle))</a></li>\n"
                currentLevel = level
            }
            }
            
            // 更新偏移量（包括换行符）
            currentOffset = lineEnd + 1
        }
        
        // 关闭所有未关闭的标签
        for _ in 0..<currentLevel {
            toc += "</ul>\n"
        }
        
        toc += "</nav>"
        return (toc, headingMap)
    }
    
    /// 获取需要排除的区域（代码块、引用块、Mermaid 块、公式块）
    /// 返回: 所有排除区域的字符范围数组
    private func getExcludedRanges(from markdown: String) -> [Range<Int>] {
        var excludedRanges: [Range<Int>] = []
        
        // 1. 匹配所有代码块（```...```）
        let codeBlockPattern = "```[\\s\\S]*?```"
        if let regex = try? NSRegularExpression(pattern: codeBlockPattern) {
            let matches = regex.matches(
                in: markdown,
                range: NSRange(markdown.startIndex..., in: markdown)
            )
            for match in matches {
                if let range = Range(match.range, in: markdown) {
                    let start = markdown.distance(from: markdown.startIndex, to: range.lowerBound)
                    let end = markdown.distance(from: markdown.startIndex, to: range.upperBound)
                    excludedRanges.append(start..<end)
                }
            }
        }
        
        // 2. 匹配引用块（以 > 开头的行，可能多行）
        // 使用行级别匹配更准确
        let lines = markdown.components(separatedBy: .newlines)
        var currentOffset = 0
        var inBlockquote = false
        var blockquoteStart = 0
        
        for line in lines {
            let lineStart = currentOffset
            let isBlockquoteLine = line.hasPrefix(">")
            
            if isBlockquoteLine && !inBlockquote {
                // 开始引用块
                inBlockquote = true
                blockquoteStart = lineStart
            } else if !isBlockquoteLine && inBlockquote {
                // 结束引用块
                let blockquoteEnd = lineStart
                excludedRanges.append(blockquoteStart..<blockquoteEnd)
                inBlockquote = false
            }
            
            currentOffset += line.count + 1 // +1 for newline
        }
        
        // 处理文档末尾的引用块
        if inBlockquote {
            excludedRanges.append(blockquoteStart..<currentOffset)
        }
        
        // 3. 匹配数学公式块（$$...$$）
        let blockMathPattern = "\\$\\$[\\s\\S]*?\\$\\$"
        if let regex = try? NSRegularExpression(pattern: blockMathPattern) {
            let matches = regex.matches(
                in: markdown,
                range: NSRange(markdown.startIndex..., in: markdown)
            )
            for match in matches {
                if let range = Range(match.range, in: markdown) {
                    let start = markdown.distance(from: markdown.startIndex, to: range.lowerBound)
                    let end = markdown.distance(from: markdown.startIndex, to: range.upperBound)
                    excludedRanges.append(start..<end)
                }
            }
        }
        
        // 4. 匹配行内数学公式（$...$）- 虽然不太可能包含标题，但为了完整性也排除
        // 注意：行内公式通常很短，不太可能包含多行标题，但为了安全起见也排除
        
        return excludedRanges
    }
    
    /// 构建完整 HTML
    private func buildFullHTML(
        content: String,
        toc: String?,
        options: RenderOptions
    ) async -> String {
        let css = await getCSS(for: options.themeId)
        let codeHighlightCSS = await getCodeHighlightCSS(for: options.themeId)
        let imageErrorCSS = getImageErrorCSS()
        
        // 获取当前主题配置，用于 Mermaid 主题设置
        let theme: ThemeConfig
        if let themeId = options.themeId {
            let availableThemes = await themeManager.availableThemes
            if let selectedTheme = availableThemes.first(where: { $0.id == themeId }) {
                theme = selectedTheme
            } else {
                theme = await themeManager.currentTheme
            }
        } else {
            theme = await themeManager.currentTheme
        }
        
        // 使用主题的 Mermaid 主题配置
        let mermaidTheme = theme.mermaidTheme
        
        // 应用所有布局设置
        let horizontalPadding = options.horizontalPadding ?? 24.0
        let verticalPadding = options.verticalPadding ?? 20.0
        let alignment = options.alignment ?? "center"
        let textAlign = alignment == "center" ? "center" : "left"
        let maxWidth = options.maxWidth ?? 800.0  // 默认 800pt
        let lineSpacing = options.lineSpacing ?? 6.0
        let paragraphSpacing = options.paragraphSpacing ?? 0.8
        
        // 计算行高（line-height）：行间距是绝对值（pt），需要转换为相对值
        // 假设基础字体大小为 17pt（与 EditorPreferences 默认值一致）
        let baseFontSize: CGFloat = 17.0
        let lineHeight = 1.0 + (lineSpacing / baseFontSize)
        
        let containerStyle = """
            max-width: \(maxWidth)pt;
            margin: 0 auto;
            padding: \(verticalPadding)pt \(horizontalPadding)pt;
        """
        let contentStyle = """
            text-align: \(textAlign);
            line-height: \(lineHeight);
        """
        
        // 段落间距样式（通过内联样式或添加到 CSS）
        let paragraphSpacingStyle = """
            p {
                margin-bottom: \(paragraphSpacing)em;
            }
            p:last-child {
                margin-bottom: 0;
            }
        """
        
        return """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Preview</title>
            \(css)
            \(codeHighlightCSS)
            \(imageErrorCSS)
            <style>
                \(paragraphSpacingStyle)
            </style>
            \(getMermaidScript())
            \(getKaTeXScript())
        </head>
        <body>
            <div class="container" style="\(containerStyle)">
                \(toc ?? "")
                <article class="content" style="\(contentStyle)">
                \(content)
                </article>
            </div>
            <script>
                // 初始化 Mermaid - 配置所有图表类型
                mermaid.initialize({ 
                    startOnLoad: true,
                    theme: '\(mermaidTheme)',
                    securityLevel: 'loose',
                    flowchart: {
                        useMaxWidth: true,
                        htmlLabels: true,
                        curve: 'basis'
                    },
                    sequence: {
                        diagramMarginX: 50,
                        diagramMarginY: 10,
                        actorMargin: 50,
                        width: 150,
                        height: 65,
                        boxMargin: 10,
                        boxTextMargin: 5,
                        noteMargin: 10,
                        messageMargin: 35,
                        mirrorActors: true,
                        useMaxWidth: true
                    },
                    gantt: {
                        titleTopMargin: 25,
                        barHeight: 20,
                        barGap: 4,
                        topPadding: 50,
                        leftPadding: 75,
                        gridLineStartPadding: 35,
                        fontSize: 11,
                        useMaxWidth: true
                    },
                    class: {
                        useMaxWidth: true
                    },
                    state: {
                        useMaxWidth: true
                    },
                    er: {
                        useMaxWidth: true
                    },
                    journey: {
                        useMaxWidth: true
                    },
                    gitGraph: {
                        useMaxWidth: true,
                        showBranches: true,
                        showCommitLabel: true,
                        mainBranchName: 'main'
                    },
                    pie: {
                        useMaxWidth: true
                    },
                    logLevel: 'error'
                });
                
                // 手动触发 Mermaid 渲染（更可靠）
                document.addEventListener('DOMContentLoaded', function() {
                    mermaid.init(undefined, document.querySelectorAll('.mermaid'));
                });
                
                // 初始化 KaTeX
                document.querySelectorAll('.katex-formula').forEach(el => {
                    const formula = el.dataset.formula;
                    const isBlock = el.parentElement.classList.contains('math-block');
                    try {
                        katex.render(formula, el, {
                            displayMode: isBlock,
                            throwOnError: false
                        });
                    } catch (e) {
                        console.error('KaTeX render error:', e);
                        el.textContent = formula;
                    }
                });
                
                // 复制代码功能
                function copyCode(button) {
                    const code = button.getAttribute('data-code');
                    // 解码 HTML 实体
                    const textarea = document.createElement('textarea');
                    textarea.innerHTML = code;
                    const decodedCode = textarea.value;
                    
                    // 复制到剪贴板
                    navigator.clipboard.writeText(decodedCode).then(() => {
                        // 显示复制成功反馈
                        const originalHTML = button.innerHTML;
                        button.innerHTML = '<svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8l3 3 7-7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';
                        button.style.color = '#22c55e';
                        
                        setTimeout(() => {
                            button.innerHTML = originalHTML;
                            button.style.color = '';
                        }, 2000);
                    }).catch(err => {
                        console.error('Failed to copy:', err);
                    });
                }
            </script>
        </body>
        </html>
        """
    }
    
    // MARK: - Helper Methods
    
    private func escapeHTML(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
    
    /// 解码 HTML 实体
    /// 将 HTML 实体（如 &amp;、&lt; 等）转换回原始字符
    private func decodeHTMLEntities(_ text: String) -> String {
        var result = text
        // 按顺序解码，避免重复解码
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.replacingOccurrences(of: "&quot;", with: "\"")
        result = result.replacingOccurrences(of: "&#39;", with: "'")
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        return result
    }
    
    /// 从 HTML 中提取纯文本
    /// 移除所有 HTML 标签，解码 HTML 实体，返回纯文本
    private func extractPlainText(from html: String) -> String {
        var result = html
        
        // 1. 移除所有 HTML 标签（包括嵌套标签）
        // 使用正则表达式匹配 <...> 标签
        let tagPattern = "<[^>]+>"
        if let regex = try? NSRegularExpression(pattern: tagPattern, options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: range,
                withTemplate: ""
            )
        }
        
        // 2. 解码 HTML 实体
        result = decodeHTMLEntities(result)
        
        // 3. 清理多余的空白字符
        result = result
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
    
    /// 从文本生成标题 ID
    /// 规则：小写、空格转连字符、移除特殊字符（保留中文字符、数字、连字符）
    private func generateHeadingID(from text: String) -> String {
        var id = text.lowercased()
        
        // 1. 空格转连字符
        id = id.replacingOccurrences(of: " ", with: "-")
        
        // 2. 移除特殊字符，但保留：
        //    - 小写字母 a-z
        //    - 数字 0-9
        //    - 连字符 -
        //    - 中文字符（Unicode 范围 \u{4e00}-\u{9fff}）
        id = id.replacingOccurrences(
            of: "[^a-z0-9\\-\\u{4e00}-\\u{9fff}]",
            with: "",
            options: .regularExpression
        )
        
        // 3. 移除连续的连字符
        id = id.replacingOccurrences(
            of: "-+",
            with: "-",
            options: .regularExpression
        )
        
        // 4. 移除开头和结尾的连字符
        id = id.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        
        // 5. 如果 id 为空，返回默认值
        return id.isEmpty ? "heading" : id
    }
    
    private func getCSS(for themeId: String?) async -> String {
        // 1. 确定要使用的主题
        let theme: ThemeConfig
        if let themeId = themeId {
            // 使用指定主题
            let availableThemes = await themeManager.availableThemes
            if let selectedTheme = availableThemes.first(where: { $0.id == themeId }) {
                theme = selectedTheme
            } else {
                theme = await themeManager.currentTheme
            }
        } else {
            // 使用当前主题
            theme = await themeManager.currentTheme
        }
        
        // 2. 尝试加载主题 CSS
        do {
            let css = try await themeManager.getCSS(for: theme)
            return "<style>\(css)</style>"
        } catch {
            return "<style>\(CSSStyles.fallback)</style>"
        }
    }
    
    private func getMermaidScript() -> String {
        // 尝试从本地资源加载，如果失败则使用 CDN（降级方案）
        if let mermaidURL = getVendorResourceURL(filename: "mermaid.min.js"),
           let mermaidContent = try? String(contentsOf: mermaidURL, encoding: .utf8) {
            // 使用内联脚本（本地资源）
            return """
            <script>
            \(mermaidContent)
            </script>
            """
        } else {
            // 降级到 CDN（开发时或资源未找到时）
            return """
            <script src="https://cdn.jsdelivr.net/npm/mermaid@10.6.1/dist/mermaid.min.js"></script>
            """
        }
    }
    
    private func getKaTeXScript() -> String {
        // 尝试从本地资源加载，如果失败则使用 CDN（降级方案）
        var katexCSS = ""
        var katexJS = ""
        
        if let katexCSSURL = getVendorResourceURL(filename: "katex.min.css"),
           let cssContent = try? String(contentsOf: katexCSSURL, encoding: .utf8) {
            katexCSS = "<style>\(cssContent)</style>"
        } else {
            katexCSS = """
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
            """
        }
        
        if let katexJSURL = getVendorResourceURL(filename: "katex.min.js"),
           let jsContent = try? String(contentsOf: katexJSURL, encoding: .utf8) {
            katexJS = """
            <script>
            \(jsContent)
            </script>
            """
        } else {
            katexJS = """
            <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
            """
        }
        
        return katexCSS + "\n" + katexJS
    }
    
    /// 获取 Vendor 资源文件的 URL
    /// - Parameter filename: 文件名（如 "mermaid.min.js"）
    /// - Returns: 资源文件的 URL，如果找不到则返回 nil
    private func getVendorResourceURL(filename: String) -> URL? {
        // 使用安全的资源访问方式
        return Bundle.safeResourceURL(
            name: filename,
            withExtension: nil,
            subdirectory: "Resources/Vendor"
        )
    }
    
    /// 获取代码高亮 CSS 样式
    /// - Parameter themeId: 主题 ID（nil 表示使用当前主题）
    /// - Returns: 代码高亮 CSS 样式字符串
    private func getCodeHighlightCSS(for themeId: String?) async -> String {
        // 1. 检查是否使用自定义代码高亮主题
        let useCustom = UserDefaults.standard.bool(forKey: "useCustomCodeHighlightTheme")
        let customThemeRaw = UserDefaults.standard.string(forKey: "customCodeHighlightTheme")
        
        let codeTheme: CodeTheme
        if useCustom, let customThemeRaw = customThemeRaw,
           let customTheme = CodeTheme(rawValue: customThemeRaw) {
            // 使用用户自定义的代码高亮主题
            codeTheme = customTheme
        } else {
            // 使用预览主题的代码高亮主题
            let theme: ThemeConfig
            if let themeId = themeId {
                let availableThemes = await themeManager.availableThemes
                if let selectedTheme = availableThemes.first(where: { $0.id == themeId }) {
                    theme = selectedTheme
                } else {
                    theme = await themeManager.currentTheme
                }
            } else {
                theme = await themeManager.currentTheme
            }
            codeTheme = theme.codeHighlightTheme
        }
        
        // 2. 根据 codeTheme 获取颜色方案
        let colorScheme = getColorScheme(for: codeTheme)
        
        // 3. 生成 CSS（包含浅色和深色模式）
        // 注意：Splash 生成的 HTML 结构是 <code><span class="keyword">...</span></code>
        // 选择器需要匹配 .code-block code .keyword 或 .code-block code span.keyword
        return """
        <style>
        /* Splash 代码高亮样式 - 浅色模式（默认） */
        .code-block code .keyword,
        .code-block code span.keyword {
            color: \(colorScheme.light.keyword) !important;
            font-weight: 600;
        }
        
        .code-block code .string,
        .code-block code span.string {
            color: \(colorScheme.light.string) !important;
        }
        
        .code-block code .number,
        .code-block code span.number {
            color: \(colorScheme.light.number) !important;
        }
        
        .code-block code .comment,
        .code-block code span.comment {
            color: \(colorScheme.light.comment) !important;
            font-style: italic;
        }
        
        .code-block code .call,
        .code-block code span.call {
            color: \(colorScheme.light.call) !important;
        }
        
        .code-block code .type,
        .code-block code span.type {
            color: \(colorScheme.light.type) !important;
        }
        
        .code-block code .property,
        .code-block code span.property {
            color: \(colorScheme.light.property) !important;
        }
        
        .code-block code .dotAccess,
        .code-block code span.dotAccess {
            color: \(colorScheme.light.dotAccess) !important;
        }
        
        .code-block code .preprocessing,
        .code-block code span.preprocessing {
            color: \(colorScheme.light.preprocessing) !important;
        }
        
        /* Splash 代码高亮样式 - 深色模式 */
        @media (prefers-color-scheme: dark) {
            .code-block code .keyword,
            .code-block code span.keyword {
                color: \(colorScheme.dark.keyword) !important;
                font-weight: 600;
            }
            
            .code-block code .string,
            .code-block code span.string {
                color: \(colorScheme.dark.string) !important;
            }
            
            .code-block code .number,
            .code-block code span.number {
                color: \(colorScheme.dark.number) !important;
            }
            
            .code-block code .comment,
            .code-block code span.comment {
                color: \(colorScheme.dark.comment) !important;
                font-style: italic;
            }
            
            .code-block code .call,
            .code-block code span.call {
                color: \(colorScheme.dark.call) !important;
            }
            
            .code-block code .type,
            .code-block code span.type {
                color: \(colorScheme.dark.type) !important;
            }
            
            .code-block code .property,
            .code-block code span.property {
                color: \(colorScheme.dark.property) !important;
            }
            
            .code-block code .dotAccess,
            .code-block code span.dotAccess {
                color: \(colorScheme.dark.dotAccess) !important;
            }
            
            .code-block code .preprocessing,
            .code-block code span.preprocessing {
                color: \(colorScheme.dark.preprocessing) !important;
            }
        }
        </style>
        """
    }
    
    // MARK: - Code Highlight Color Schemes
    
    /// 代码高亮颜色方案
    private struct CodeHighlightColors {
        let keyword: String
        let string: String
        let number: String
        let comment: String
        let call: String
        let type: String
        let property: String
        let dotAccess: String
        let preprocessing: String
    }
    
    /// 颜色方案（包含浅色和深色）
    private struct ColorScheme {
        let light: CodeHighlightColors
        let dark: CodeHighlightColors
    }
    
    /// 根据 CodeTheme 获取颜色方案
    private func getColorScheme(for codeTheme: CodeTheme) -> ColorScheme {
        switch codeTheme {
        case .xcode:
            return ColorScheme(
                light: CodeHighlightColors(
                    keyword: "#AA0D91",    // 紫色
                    string: "#0080FF",     // 蓝色
                    number: "#1C00CF",     // 深蓝
                    comment: "#007400",     // 绿色
                    call: "#643820",       // 棕色
                    type: "#643820",        // 棕色
                    property: "#643820",     // 棕色
                    dotAccess: "#643820",   // 棕色
                    preprocessing: "#643820" // 棕色
                ),
                dark: CodeHighlightColors(
                    keyword: "#FF7AB2",     // 粉红
                    string: "#FC6A5D",      // 橙红
                    number: "#D0BF69",     // 黄色
                    comment: "#6A9955",     // 绿色
                    call: "#4EC9B0",       // 青色
                    type: "#4EC9B0",       // 青色
                    property: "#4EC9B0",   // 青色
                    dotAccess: "#4EC9B0",  // 青色
                    preprocessing: "#4EC9B0" // 青色
                )
            )
            
        case .github:
            return ColorScheme(
                light: CodeHighlightColors(
                    keyword: "#D73A49",    // 红色
                    string: "#032F62",      // 深蓝
                    number: "#005CC5",      // 蓝色
                    comment: "#6A737D",      // 灰色
                    call: "#6F42C1",        // 紫色
                    type: "#6F42C1",        // 紫色
                    property: "#005CC5",     // 蓝色
                    dotAccess: "#6F42C1",    // 紫色
                    preprocessing: "#6A737D" // 灰色
                ),
                dark: CodeHighlightColors(
                    keyword: "#FF79C6",     // 粉红
                    string: "#98D982",      // 绿色
                    number: "#BD93F9",      // 紫色
                    comment: "#6272A4",      // 蓝灰
                    call: "#50FA7B",        // 绿色
                    type: "#8BE9FD",        // 青色
                    property: "#50FA7B",     // 绿色
                    dotAccess: "#8BE9FD",    // 青色
                    preprocessing: "#6272A4" // 蓝灰
                )
            )
            
        case .monokai:
            // Monokai 主要是深色主题，浅色模式使用类似 Dracula 的配色
            return ColorScheme(
                light: CodeHighlightColors(
                    keyword: "#A626A4",     // 紫色
                    string: "#50A14F",      // 绿色
                    number: "#986801",      // 黄色
                    comment: "#A0A1A7",      // 灰色
                    call: "#4078F2",        // 蓝色
                    type: "#E45649",        // 红色
                    property: "#4078F2",     // 蓝色
                    dotAccess: "#4078F2",   // 蓝色
                    preprocessing: "#A0A1A7" // 灰色
                ),
                dark: CodeHighlightColors(
                    keyword: "#F92672",     // 粉红
                    string: "#E6DB74",      // 黄色
                    number: "#AE81FF",      // 紫色
                    comment: "#75715E",      // 灰绿
                    call: "#66D9EF",        // 青色
                    type: "#A6E22E",        // 绿色
                    property: "#66D9EF",     // 青色
                    dotAccess: "#66D9EF",   // 青色
                    preprocessing: "#75715E" // 灰绿
                )
            )
            
        case .dracula:
            return ColorScheme(
                light: CodeHighlightColors(
                    keyword: "#A626A4",     // 紫色
                    string: "#50A14F",      // 绿色
                    number: "#986801",      // 黄色
                    comment: "#A0A1A7",      // 灰色
                    call: "#4078F2",        // 蓝色
                    type: "#E45649",        // 红色
                    property: "#4078F2",     // 蓝色
                    dotAccess: "#4078F2",   // 蓝色
                    preprocessing: "#A0A1A7" // 灰色
                ),
                dark: CodeHighlightColors(
                    keyword: "#FF79C6",     // 粉红
                    string: "#F1FA8C",      // 黄色
                    number: "#BD93F9",      // 紫色
                    comment: "#6272A4",      // 蓝灰
                    call: "#50FA7B",        // 绿色
                    type: "#8BE9FD",        // 青色
                    property: "#50FA7B",     // 绿色
                    dotAccess: "#8BE9FD",    // 青色
                    preprocessing: "#6272A4" // 蓝灰
                )
            )
            
        case .solarizedLight:
            return ColorScheme(
                light: CodeHighlightColors(
                    keyword: "#859900",      // 绿色
                    string: "#2AA198",       // 青色
                    number: "#D33682",      // 品红
                    comment: "#93A1A1",      // 浅灰
                    call: "#268BD2",        // 蓝色
                    type: "#B58900",        // 黄色
                    property: "#268BD2",     // 蓝色
                    dotAccess: "#268BD2",    // 蓝色
                    preprocessing: "#93A1A1" // 浅灰
                ),
                dark: CodeHighlightColors(
                    keyword: "#859900",     // 绿色
                    string: "#2AA198",       // 青色
                    number: "#D33682",       // 品红
                    comment: "#586E75",      // 深灰
                    call: "#268BD2",        // 蓝色
                    type: "#B58900",        // 黄色
                    property: "#268BD2",     // 蓝色
                    dotAccess: "#268BD2",    // 蓝色
                    preprocessing: "#586E75" // 深灰
                )
            )
            
        case .solarizedDark:
            return ColorScheme(
                light: CodeHighlightColors(
                    keyword: "#859900",     // 绿色
                    string: "#2AA198",       // 青色
                    number: "#D33682",      // 品红
                    comment: "#586E75",      // 深灰
                    call: "#268BD2",        // 蓝色
                    type: "#B58900",        // 黄色
                    property: "#268BD2",     // 蓝色
                    dotAccess: "#268BD2",    // 蓝色
                    preprocessing: "#586E75" // 深灰
                ),
                dark: CodeHighlightColors(
                    keyword: "#859900",      // 绿色
                    string: "#2AA198",       // 青色
                    number: "#D33682",       // 品红
                    comment: "#586E75",       // 深灰
                    call: "#268BD2",        // 蓝色
                    type: "#B58900",         // 黄色
                    property: "#268BD2",     // 蓝色
                    dotAccess: "#268BD2",    // 蓝色
                    preprocessing: "#586E75" // 深灰
                )
            )
        }
    }
    
    /// 获取无效图片的 CSS 样式
    private func getImageErrorCSS() -> String {
        return """
        <style>
        /* 无效图片样式 */
        img[data-broken="true"] {
            border: 2px dashed #ff6b6b;
            background-color: #ffe0e0;
            padding: 20px;
            display: inline-block;
            position: relative;
            min-width: 200px;
            min-height: 100px;
        }
        
        img[data-broken="true"]::after {
            content: "图片无法加载";
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #ff6b6b;
            font-size: 12px;
            font-weight: 500;
            white-space: nowrap;
        }
        
        @media (prefers-color-scheme: dark) {
            img[data-broken="true"] {
                border-color: #ff6b6b;
                background-color: #3d2a2a;
            }
            
            img[data-broken="true"]::after {
                color: #ff8c8c;
            }
        }
        </style>
        """
    }
    
    /// 处理图片路径：验证相对路径文件是否存在，为无效图片添加标记
    private func processImagePaths(in html: String, noteDirectory: URL?) -> String {
        var result = html
        
        // 使用正则表达式匹配所有 <img> 标签
        // 匹配模式：<img ... src="..." ...>
        let pattern = "<img([^>]*?)src=\"([^\"]+)\"([^>]*?)>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return result
        }
        
        let matches = regex.matches(
            in: result,
            range: NSRange(result.startIndex..., in: result)
        )
        
        // 从后往前处理，避免索引偏移
        for match in matches.reversed() {
            guard match.numberOfRanges >= 4,
                  let beforeSrcRange = Range(match.range(at: 1), in: result),
                  let srcRange = Range(match.range(at: 2), in: result),
                  let afterSrcRange = Range(match.range(at: 3), in: result) else {
                continue
            }
            
            let beforeSrc = String(result[beforeSrcRange])
            let srcPath = String(result[srcRange])
            let afterSrc = String(result[afterSrcRange])
            
            // 检查路径类型
            let isNetworkURL = srcPath.hasPrefix("http://") || srcPath.hasPrefix("https://")
            let isDataURL = srcPath.hasPrefix("data:")
            let isAbsolutePath = srcPath.hasPrefix("/") || srcPath.hasPrefix("file://")
            
            // 如果是网络 URL 或 data URL，跳过验证
            if isNetworkURL || isDataURL {
                continue
            }
            
            // 如果是绝对路径，检查文件是否存在
            if isAbsolutePath {
                let fileURL: URL
                if srcPath.hasPrefix("file://") {
                    guard let url = URL(string: srcPath) else { continue }
                    fileURL = url
                } else {
                    fileURL = URL(fileURLWithPath: srcPath)
                }
                
                let fileManager = FileManager.default
                let exists = fileManager.fileExists(atPath: fileURL.path)
                if !exists {
                    // 文件不存在，添加错误标记
                    let newImgTag = "<img\(beforeSrc)src=\"\(srcPath)\"\(afterSrc) data-broken=\"true\">"
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(fullRange, with: newImgTag)
                }
                continue
            }
            
            // 相对路径：需要 noteDirectory 来解析
            guard let noteDir = noteDirectory else {
                continue
            }
            
            // 构建完整路径
            let imageURL = noteDir.appendingPathComponent(srcPath)
            
            let fileManager = FileManager.default
            let exists = fileManager.fileExists(atPath: imageURL.path)
            
            if exists {
                // 文件存在，转换为完整的 file:// URL
                // 这对于从 noteDirectory 内的临时 HTML 文件加载时是必需的
                let fullFileURL = imageURL.absoluteString
                let newImgTag = "<img\(beforeSrc)src=\"\(fullFileURL)\"\(afterSrc)>"
                let fullRange = Range(match.range, in: result)!
                result.replaceSubrange(fullRange, with: newImgTag)
            } else {
                // 文件不存在，添加错误标记
                let newImgTag = "<img\(beforeSrc)src=\"\(srcPath)\"\(afterSrc) data-broken=\"true\">"
                let fullRange = Range(match.range, in: result)!
                result.replaceSubrange(fullRange, with: newImgTag)
            }
        }
        
        return result
    }
}


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
    
    // MARK: - Public Methods
    
    /// 渲染 Markdown 为完整 HTML
    func renderToHTML(
        markdown: String,
        options: RenderOptions = .default
    ) async throws -> String {
        // 1. 预处理（提取 Mermaid、数学公式、代码块）
        let preprocessed = preprocess(markdown)
        
        // 2. Markdown → HTML（使用 Ink）
        var html = parser.html(from: preprocessed.markdown)
        
        // 3. 注入代码高亮
        html = highlightCodeBlocks(html)
        
        // 4. 注入 Mermaid 图表
        html = injectMermaidCharts(html, charts: preprocessed.mermaidCharts)
        
        // 5. 注入数学公式
        html = injectMathFormulas(html, formulas: preprocessed.mathFormulas)
        
        // 6. 生成 TOC（如果需要）
        let toc = options.includeTOC ? generateTOC(from: markdown) : nil
        
        // 7. 构建完整 HTML
        return buildFullHTML(
            content: html,
            toc: toc,
            options: options
        )
    }
    
    // MARK: - Private Methods
    
    /// 预处理 Markdown（提取特殊块）
    private func preprocess(_ markdown: String) -> PreprocessedMarkdown {
        var result = markdown
        var mermaidCharts: [String] = []
        var mathFormulas: [MathFormula] = []
        
        // 提取 Mermaid 代码块
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
        
        // 提取数学公式（块公式 $$...$$）
        let blockMathPattern = "\\$\\$([\\s\\S]*?)\\$\\$"
        if let regex = try? NSRegularExpression(pattern: blockMathPattern) {
            let matches = regex.matches(
                in: result,
                range: NSRange(result.startIndex..., in: result)
            )
            
            for (index, match) in matches.enumerated().reversed() {
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
        
        // 提取行内公式（$...$）
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
        
        return PreprocessedMarkdown(
            markdown: result,
            mermaidCharts: mermaidCharts,
            mathFormulas: mathFormulas
        )
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
            result.replaceSubrange(
                fullRange,
                with: """
                <pre class="code-block" data-language="\(language)">
                    <code class="language-\(language)">\(highlighted)</code>
                </pre>
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
    
    /// 生成 TOC
    private func generateTOC(from markdown: String) -> String {
        var toc = "<nav class=\"toc\">\n<h2>目录</h2>\n<ul>\n"
        
        let lines = markdown.components(separatedBy: .newlines)
        var currentLevel = 0
        
        for line in lines {
            if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                let title = line.dropFirst(level).trimmingCharacters(in: .whitespaces)
                let id = title.lowercased()
                    .replacingOccurrences(of: " ", with: "-")
                    .replacingOccurrences(of: "[^a-z0-9\\-]", with: "", options: .regularExpression)
                
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
                
                toc += "<li><a href=\"#\(id)\">\(escapeHTML(title))</a></li>\n"
                currentLevel = level
            }
        }
        
        // 关闭所有未关闭的标签
        for _ in 0..<currentLevel {
            toc += "</ul>\n"
        }
        
        toc += "</nav>"
        return toc
    }
    
    /// 构建完整 HTML
    private func buildFullHTML(
        content: String,
        toc: String?,
        options: RenderOptions
    ) -> String {
        let css = getCSS()
        
        return """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Preview</title>
            \(css)
            \(getMermaidScript())
            \(getKaTeXScript())
        </head>
        <body>
            <div class="container">
                \(toc ?? "")
                <article class="content">
                \(content)
                </article>
            </div>
            <script>
                // 初始化 Mermaid
                mermaid.initialize({ 
                    startOnLoad: true, 
                    theme: 'default' 
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
    
    private func getCSS() -> String {
        // 使用内置的基础样式
        return "<style>\(CSSStyles.base)</style>"
    }
    
    private func getMermaidScript() -> String {
        return """
        <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
        """
    }
    
    private func getKaTeXScript() -> String {
        return """
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
        <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
        """
    }
}


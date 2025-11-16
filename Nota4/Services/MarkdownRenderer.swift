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
        // 1. 检测并处理 [TOC] 标记
        let hasTOCMarker = markdown.contains("[TOC]") || markdown.contains("[toc]")
        var processedMarkdown = markdown
        
        // 2. 预处理（提取 Mermaid、数学公式、代码块）
        let preprocessed = preprocess(processedMarkdown)
        
        // 3. Markdown → HTML（使用 Ink）
        var html = parser.html(from: preprocessed.markdown)
        
        // 4. 注入代码高亮
        html = highlightCodeBlocks(html)
        
        // 5. 注入 Mermaid 图表
        html = injectMermaidCharts(html, charts: preprocessed.mermaidCharts)
        
        // 6. 注入数学公式
        html = injectMathFormulas(html, formulas: preprocessed.mathFormulas)
        
        // 7. 生成 TOC（如果有 [TOC] 标记或者选项启用）
        let shouldGenerateTOC = hasTOCMarker || options.includeTOC
        let toc = shouldGenerateTOC ? generateTOC(from: markdown) : nil
        
        // 8. 替换 [TOC] 标记
        if hasTOCMarker && toc != nil {
            html = html.replacingOccurrences(of: "<p>[TOC]</p>", with: toc!)
            html = html.replacingOccurrences(of: "<p>[toc]</p>", with: toc!)
        }
        
        // 9. 构建完整 HTML（如果有 [TOC] 标记，则不在顶部添加 TOC）
        return buildFullHTML(
            content: html,
            toc: hasTOCMarker ? nil : toc,
            options: options
        )
    }
    
    // MARK: - Private Methods
    
    /// 预处理 Markdown（提取特殊块）
    private func preprocess(_ markdown: String) -> PreprocessedMarkdown {
        var result = markdown
        var mermaidCharts: [String] = []
        var mathFormulas: [MathFormula] = []
        
        // 提取 Mermaid 代码块（支持多种换行符和可选空格）
        let mermaidPattern = "```mermaid\\s*\\r?\\n([\\s\\S]*?)```"
        if let regex = try? NSRegularExpression(pattern: mermaidPattern, options: []) {
            let matches = regex.matches(
                in: result,
                range: NSRange(result.startIndex..., in: result)
            )
            
            for (index, match) in matches.enumerated().reversed() {
                if let range = Range(match.range(at: 1), in: result) {
                    let chart = String(result[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                    mermaidCharts.insert(chart, at: 0)
                    
                    // 替换为占位符（使用唯一 ID）
                    let fullRange = Range(match.range, in: result)!
                    let placeholderId = "mermaid-\(UUID().uuidString)"
                    result.replaceSubrange(
                        fullRange,
                        with: "\n<div class=\"mermaid-placeholder\" id=\"\(placeholderId)\" data-index=\"\(index)\"></div>\n"
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
            // 使用正则匹配占位符（包括可能的 ID）
            let placeholderPattern = "<div class=\"mermaid-placeholder\"[^>]*data-index=\"\(index)\"[^>]*></div>"
            
            if let regex = try? NSRegularExpression(pattern: placeholderPattern, options: []) {
                let range = NSRange(result.startIndex..., in: result)
                if let match = regex.firstMatch(in: result, options: [], range: range),
                   let matchRange = Range(match.range, in: result) {
                    
                    // 直接插入 Mermaid 代码，不转义
                    let mermaidDiv = "<div class=\"mermaid\">\n\(chart)\n</div>"
                    result.replaceSubrange(matchRange, with: mermaidDiv)
                }
            }
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
                // 初始化 Mermaid - 配置所有图表类型
                mermaid.initialize({ 
                    startOnLoad: false,  // 改为 false，手动控制
                    theme: 'default',
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
                    logLevel: 'debug'  // 改为 debug 以便调试
                });
                
                // 等待 DOM 和 Mermaid 完全加载后再渲染
                window.addEventListener('load', function() {
                    console.log('🎨 [Mermaid] Starting rendering...');
                    
                    const mermaidElements = document.querySelectorAll('.mermaid');
                    console.log('🎨 [Mermaid] Found', mermaidElements.length, 'diagrams');
                    
                    if (mermaidElements.length > 0) {
                        try {
                            // 逐个渲染 Mermaid 图表
                            mermaidElements.forEach((element, index) => {
                                console.log('🎨 [Mermaid] Rendering diagram', index + 1);
                                console.log('📄 [Mermaid] Content:', element.textContent.substring(0, 100));
                                
                                try {
                                    mermaid.init(undefined, element);
                                    console.log('✅ [Mermaid] Diagram', index + 1, 'rendered successfully');
                                } catch (e) {
                                    console.error('❌ [Mermaid] Failed to render diagram', index + 1, ':', e);
                                    element.innerHTML = '<pre style="color: red; border: 1px solid red; padding: 10px;">Mermaid 渲染错误: ' + e.message + '</pre>';
                                }
                            });
                        } catch (e) {
                            console.error('❌ [Mermaid] Initialization error:', e);
                        }
                    } else {
                        console.log('⚠️ [Mermaid] No diagrams found');
                    }
                });
                
                // 初始化 KaTeX
                window.addEventListener('DOMContentLoaded', function() {
                    console.log('🔢 [KaTeX] Starting rendering...');
                    
                    document.querySelectorAll('.katex-formula').forEach((el, index) => {
                        const formula = el.dataset.formula;
                        const isBlock = el.parentElement.classList.contains('math-block');
                        try {
                            katex.render(formula, el, {
                                displayMode: isBlock,
                                throwOnError: false
                            });
                            console.log('✅ [KaTeX] Formula', index + 1, 'rendered');
                        } catch (e) {
                            console.error('❌ [KaTeX] Render error:', e);
                            el.textContent = formula;
                        }
                    });
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
        <script src="https://cdn.jsdelivr.net/npm/mermaid@10.6.1/dist/mermaid.min.js"></script>
        """
    }
    
    private func getKaTeXScript() -> String {
        return """
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
        <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
        """
    }
}


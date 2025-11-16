import Foundation

// MARK: - CSS Styles

/// CSS 样式集合
enum CSSStyles {
    /// 基础 Markdown 样式（降级方案）
    static let base = """
    /* 基础样式 */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    
    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', sans-serif;
        font-size: 16px;
        line-height: 1.6;
        color: #333;
        background: #fff;
        padding: 2rem;
    }
    
    @media (prefers-color-scheme: dark) {
        body {
            color: #e0e0e0;
            background: #1e1e1e;
        }
    }
    
    .container {
        max-width: 900px;
        margin: 0 auto;
    }
    
    /* 目录样式 */
    .toc {
        background: #f8f8f8;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        padding: 1.5rem;
        margin-bottom: 2rem;
    }
    
    @media (prefers-color-scheme: dark) {
        .toc {
            background: #2d2d2d;
            border-color: #404040;
        }
    }
    
    .toc h2 {
        font-size: 1.2rem;
        margin-bottom: 1rem;
    }
    
    .toc ul {
        list-style: none;
        padding-left: 1rem;
    }
    
    .toc li {
        margin: 0.5rem 0;
    }
    
    .toc a {
        color: #0066cc;
        text-decoration: none;
    }
    
    .toc a:hover {
        text-decoration: underline;
    }
    
    @media (prefers-color-scheme: dark) {
        .toc a {
            color: #4da6ff;
        }
    }
    
    /* 文章内容 */
    .content {
        line-height: 1.8;
    }
    
    /* 标题 */
    h1, h2, h3, h4, h5, h6 {
        margin: 1.5rem 0 1rem 0;
        font-weight: 600;
        line-height: 1.3;
    }
    
    h1 { 
        font-size: 2rem; 
        border-bottom: 2px solid #e0e0e0; 
        padding-bottom: 0.5rem; 
    }
    
    h2 { 
        font-size: 1.6rem; 
        border-bottom: 1px solid #e0e0e0; 
        padding-bottom: 0.3rem; 
    }
    
    h3 { font-size: 1.3rem; }
    h4 { font-size: 1.1rem; }
    h5 { font-size: 1rem; }
    h6 { font-size: 0.9rem; color: #666; }
    
    @media (prefers-color-scheme: dark) {
        h1, h2 {
            border-color: #404040;
        }
        h6 {
            color: #aaa;
        }
    }
    
    /* 段落 */
    p {
        margin: 1rem 0;
    }
    
    /* 链接 */
    a {
        color: #0066cc;
        text-decoration: none;
    }
    
    a:hover {
        text-decoration: underline;
    }
    
    @media (prefers-color-scheme: dark) {
        a {
            color: #4da6ff;
        }
    }
    
    /* 列表 */
    ul, ol {
        margin: 1rem 0;
        padding-left: 2rem;
    }
    
    li {
        margin: 0.3rem 0;
    }
    
    /* 引用 */
    blockquote {
        border-left: 4px solid #0066cc;
        padding-left: 1rem;
        margin: 1rem 0;
        color: #666;
        font-style: italic;
    }
    
    @media (prefers-color-scheme: dark) {
        blockquote {
            border-color: #4da6ff;
            color: #aaa;
        }
    }
    
    /* 代码块 */
    code {
        background: #f5f5f5;
        border: 1px solid #e0e0e0;
        border-radius: 3px;
        padding: 0.2rem 0.4rem;
        font-family: 'SF Mono', Monaco, Menlo, 'Courier New', monospace;
        font-size: 0.9em;
    }
    
    @media (prefers-color-scheme: dark) {
        code {
            background: #2d2d2d;
            border-color: #404040;
        }
    }
    
    pre {
        background: #f8f8f8;
        border: 1px solid #e0e0e0;
        border-radius: 6px;
        padding: 1rem;
        margin: 1rem 0;
        overflow-x: auto;
        position: relative;
    }
    
    @media (prefers-color-scheme: dark) {
        pre {
            background: #2d2d2d;
            border-color: #404040;
        }
    }
    
    pre code {
        background: none;
        border: none;
        padding: 0;
        display: block;
    }
    
    /* 代码高亮（Splash 输出） */
    .code-block {
        position: relative;
    }
    
    .code-block::before {
        content: attr(data-language);
        position: absolute;
        top: 0.5rem;
        right: 0.5rem;
        background: rgba(0, 0, 0, 0.1);
        padding: 0.2rem 0.5rem;
        border-radius: 3px;
        font-size: 0.75rem;
        text-transform: uppercase;
        color: #666;
    }
    
    @media (prefers-color-scheme: dark) {
        .code-block::before {
            background: rgba(255, 255, 255, 0.1);
            color: #aaa;
        }
    }
    
    /* 表格 */
    table {
        border-collapse: collapse;
        width: 100%;
        margin: 1rem 0;
        overflow: hidden;
        border-radius: 6px;
    }
    
    th, td {
        border: 1px solid #e0e0e0;
        padding: 0.75rem 1rem;
        text-align: left;
    }
    
    th {
        background: #f5f5f5;
        font-weight: 600;
    }
    
    @media (prefers-color-scheme: dark) {
        th, td {
            border-color: #404040;
        }
        
        th {
            background: #2d2d2d;
        }
    }
    
    /* 图片 */
    img {
        max-width: 100%;
        height: auto;
        border-radius: 6px;
        margin: 1rem 0;
        display: block;
    }
    
    /* 分隔线 */
    hr {
        border: none;
        border-top: 2px solid #e0e0e0;
        margin: 2rem 0;
    }
    
    @media (prefers-color-scheme: dark) {
        hr {
            border-color: #404040;
        }
    }
    
    /* Mermaid 图表 */
    .mermaid {
        background: #fff;
        border: 1px solid #e0e0e0;
        border-radius: 6px;
        padding: 1rem;
        margin: 1rem 0;
        text-align: center;
    }
    
    @media (prefers-color-scheme: dark) {
        .mermaid {
            background: #2d2d2d;
            border-color: #404040;
        }
    }
    
    /* 数学公式 */
    .math-block {
        margin: 1rem 0;
        overflow-x: auto;
        text-align: center;
    }
    
    .math-inline {
        display: inline-block;
        vertical-align: middle;
    }
    
    /* 打印优化 */
    @media print {
        body {
            padding: 0;
            font-size: 12pt;
            color: #000;
            background: #fff;
        }
        
        .container {
            max-width: none;
        }
        
        .toc {
            page-break-after: always;
        }
        
        h1, h2, h3, h4, h5, h6 {
            page-break-after: avoid;
        }
        
        pre, .mermaid {
            page-break-inside: avoid;
        }
        
        a {
            color: #000;
        }
        
        a[href^="http"]::after {
            content: " (" attr(href) ")";
            font-size: 0.8em;
            color: #666;
        }
    }
    """
    
    /// 降级样式（当其他样式加载失败时使用）
    static let fallback = base
}


import Foundation

// MARK: - Render Options

/// Markdown 渲染选项
struct RenderOptions: Equatable {
    /// 主题 ID（nil 表示使用当前全局主题）
    var themeId: String? = nil
    
    /// 是否包含目录（TOC）
    var includeTOC: Bool = false
    
    /// 是否显示代码行号
    var codeLineNumbers: Bool = false
    
    /// 笔记目录，用于解析相对路径（如图片路径）
    var noteDirectory: URL? = nil
    
    /// 左右边距（pt 单位）
    var horizontalPadding: CGFloat? = nil
    
    /// 上下边距（pt 单位）
    var verticalPadding: CGFloat? = nil
    
    /// 对齐方式（"center" 或 "left"）
    var alignment: String? = nil
    
    /// 最大行宽（pt 单位）
    var maxWidth: CGFloat? = nil
    
    /// 行间距（pt 单位）
    var lineSpacing: CGFloat? = nil
    
    /// 段落间距（em 单位）
    var paragraphSpacing: CGFloat? = nil
    
    static let `default` = RenderOptions()
}

// MARK: - Preprocessed Markdown

/// 预处理后的 Markdown 内容
struct PreprocessedMarkdown {
    /// 处理后的 Markdown 文本
    let markdown: String
    
    /// 提取的 Mermaid 图表
    let mermaidCharts: [String]
    
    /// 提取的数学公式
    let mathFormulas: [MathFormula]
}

// MARK: - Math Formula

/// 数学公式类型
enum MathFormula {
    /// 行内公式 $...$
    case inline(String)
    
    /// 块公式 $$...$$
    case block(String)
}

// MARK: - Render Error

/// 渲染错误类型
enum RenderError: LocalizedError {
    case parseError(String)
    case themeLoadError(String)
    case imageLoadError(URL)
    case cssNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .parseError(let message):
            return "Markdown 解析失败: \(message)"
        case .themeLoadError(let message):
            return "主题加载失败: \(message)"
        case .imageLoadError(let url):
            return "图片加载失败: \(url.absoluteString)"
        case .cssNotFound(let fileName):
            return "CSS 文件未找到: \(fileName)"
        }
    }
}


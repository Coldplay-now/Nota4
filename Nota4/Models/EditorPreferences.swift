import Foundation

/// 编辑器偏好设置
struct EditorPreferences: Codable, Equatable {
    // MARK: - 字体设置
    
    /// 标题字体名称
    var titleFontName: String = "System"
    
    /// 标题字号
    var titleFontSize: CGFloat = 24
    
    /// 正文字体名称
    var bodyFontName: String = "System"
    
    /// 正文字号
    var bodyFontSize: CGFloat = 17
    
    /// 代码字体名称
    var codeFontName: String = "Menlo"
    
    /// 代码字号
    var codeFontSize: CGFloat = 14
    
    // MARK: - 排版设置
    
    /// 行间距（pt 单位）
    var lineSpacing: CGFloat = 6
    
    /// 段落间距（em 单位）
    var paragraphSpacing: CGFloat = 0.8
    
    /// 最大行宽（pt 单位）
    var maxWidth: CGFloat = 800
    
    // MARK: - 布局设置
    
    /// 左右边距（pt 单位）
    var horizontalPadding: CGFloat = 24
    
    /// 上下边距（pt 单位）
    var verticalPadding: CGFloat = 20
    
    /// 对齐方式
    var alignment: Alignment = .center
    
    // MARK: - Nested Types
    
    /// 对齐方式
    enum Alignment: String, Codable, CaseIterable {
        case leading = "左对齐"
        case center = "居中"
    }
}

// MARK: - 可用字体列表

extension EditorPreferences {
    /// 系统字体列表
    static let systemFonts: [String] = [
        "System",
        "Songti SC",
        "Heiti SC",
        "Kaiti SC"
    ]
    
    /// 等宽字体列表
    static let monospacedFonts: [String] = [
        "Menlo",
        "Monaco",
        "Courier New",
        "SF Mono"
    ]
    
    /// 所有可用字体
    static let availableFonts: [String] = systemFonts + monospacedFonts
}


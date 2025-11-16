import Foundation

// MARK: - Theme Config

/// 主题配置
struct ThemeConfig: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let displayName: String
    let author: String?
    let version: String
    let description: String?
    
    // 样式文件
    let cssFileName: String
    
    // 代码高亮主题
    let codeHighlightTheme: CodeTheme
    
    // Mermaid 图表主题
    let mermaidTheme: String  // "default", "dark", "forest", "neutral"
    
    // 颜色变量（可选，用于动态配置）
    let colors: ThemeColors?
    
    // 字体配置（可选）
    let fonts: ThemeFonts?
    
    // 创建时间
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Theme Colors

/// 主题颜色配置
struct ThemeColors: Codable, Equatable {
    var primaryColor: String       // 主色调
    var backgroundColor: String    // 背景色
    var textColor: String          // 文本色
    var secondaryTextColor: String // 次要文本色
    var linkColor: String          // 链接色
    var codeBackgroundColor: String // 代码背景色
    var borderColor: String        // 边框色
    var accentColor: String        // 强调色
}

// MARK: - Theme Fonts

/// 字体配置
struct ThemeFonts: Codable, Equatable {
    var bodyFont: String    // 正文字体
    var headingFont: String // 标题字体
    var codeFont: String    // 代码字体
    var fontSize: Int       // 基础字体大小（px）
    var lineHeight: Double  // 行高
}

// MARK: - Code Theme

/// 代码高亮主题
enum CodeTheme: String, Codable, Equatable {
    case xcode = "xcode"
    case github = "github"
    case monokai = "monokai"
    case dracula = "dracula"
    case solarizedLight = "solarized-light"
    case solarizedDark = "solarized-dark"
}

// MARK: - Theme Error

/// 主题错误
enum ThemeError: LocalizedError {
    case themeNotFound(String)
    case themeAlreadyExists(String)
    case cssFileNotFound(String)
    case invalidThemePackage
    case cannotDeleteBuiltInTheme
    case cannotExportBuiltInTheme
    
    var errorDescription: String? {
        switch self {
        case .themeNotFound(let id):
            return "主题未找到: \(id)"
        case .themeAlreadyExists(let id):
            return "主题已存在: \(id)"
        case .cssFileNotFound(let name):
            return "CSS 文件未找到: \(name)"
        case .invalidThemePackage:
            return "无效的主题包"
        case .cannotDeleteBuiltInTheme:
            return "无法删除内置主题"
        case .cannotExportBuiltInTheme:
            return "无法导出内置主题"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}


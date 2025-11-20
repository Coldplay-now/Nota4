import Foundation
import AppKit

/// 编辑器偏好设置
struct EditorPreferences: Codable, Equatable {
    // MARK: - 编辑模式设置
    
    /// 编辑模式字体设置
    var editorFonts: FontSettings = FontSettings()
    
    /// 编辑模式排版布局设置
    var editorLayout: LayoutSettings = LayoutSettings(
        lineSpacing: 4,
        paragraphSpacing: 0.5,
        horizontalPadding: 16,
        verticalPadding: 12,
        alignment: .leading,
        maxWidth: nil  // 编辑模式不使用最大行宽
    )
    
    // MARK: - 预览模式设置
    
    /// 预览模式字体设置
    var previewFonts: FontSettings = FontSettings()
    
    /// 预览模式排版布局设置
    var previewLayout: LayoutSettings = LayoutSettings(
        lineSpacing: 6,
        paragraphSpacing: 0.8,
        horizontalPadding: 24,
        verticalPadding: 20,
        alignment: .leading,
        maxWidth: 800  // 预览模式使用最大行宽
    )
    
    // MARK: - 外观设置（预览相关）
    
    /// 预览主题ID（内置主题：builtin-light, builtin-dark, builtin-github, builtin-notion）
    var previewThemeId: String = "builtin-light"
    
    /// 代码高亮主题
    var codeHighlightTheme: CodeTheme = .xcode
    
    /// 代码高亮设置模式
    var codeHighlightMode: CodeHighlightMode = .followTheme
    
    // MARK: - Nested Types
    
    /// 字体设置
    struct FontSettings: Codable, Equatable {
        var bodyFontName: String = "System"
        var bodyFontSize: CGFloat = 17
        var titleFontName: String = "System"
        var titleFontSize: CGFloat = 24
        var codeFontName: String = "Menlo"
        var codeFontSize: CGFloat = 14
    }
    
    /// 排版布局设置
    struct LayoutSettings: Codable, Equatable {
        var lineSpacing: CGFloat
        var paragraphSpacing: CGFloat
        var horizontalPadding: CGFloat
        var verticalPadding: CGFloat
        var alignment: Alignment
        var maxWidth: CGFloat?  // 可选，仅预览模式使用
        
        enum Alignment: String, Codable, CaseIterable {
            case leading = "左对齐"
            case center = "居中"
        }
    }
    
    /// 代码高亮设置模式
    enum CodeHighlightMode: String, Codable, Equatable {
        case followTheme = "跟随主题"      // 使用主题的代码高亮设置
        case custom = "自定义"            // 使用自定义代码高亮主题
    }
}

// MARK: - 可用字体列表

extension EditorPreferences {
    /// 系统字体列表（常用字体）
    static let commonSystemFonts: [String] = [
        "System",
        "Songti SC",
        "Heiti SC",
        "Kaiti SC",
        "PingFang SC",
        "STHeiti",
        "STSong"
    ]
    
    /// 等宽字体列表
    static let monospacedFonts: [String] = [
        "Menlo",
        "Monaco",
        "Courier New",
        "SF Mono"
    ]
    
    /// 获取系统所有可用字体（排除等宽字体）
    static var allSystemFonts: [String] {
        var fonts: [String] = []
        
        // 添加常用字体
        fonts.append(contentsOf: commonSystemFonts)
        
        // 获取系统所有字体
        if let fontFamilies = NSFontManager.shared.availableFontFamilies as? [String] {
            let allFonts = fontFamilies.sorted()
            
            // 过滤掉等宽字体和已添加的字体
            for fontFamily in allFonts {
                // 跳过等宽字体
                if monospacedFonts.contains(fontFamily) {
                    continue
                }
                
                // 跳过已添加的字体
                if fonts.contains(fontFamily) {
                    continue
                }
                
                // 跳过一些系统字体变体（如 "Arial Black", "Arial Narrow" 等）
                if fontFamily.contains("Black") || fontFamily.contains("Narrow") || fontFamily.contains("Condensed") {
                    continue
                }
                
                fonts.append(fontFamily)
            }
        }
        
        return fonts
    }
    
    /// 获取系统所有等宽字体
    static var allMonospacedFonts: [String] {
        var fonts: [String] = []
        
        // 添加常用等宽字体
        fonts.append(contentsOf: monospacedFonts)
        
        // 获取系统所有字体
        if let fontFamilies = NSFontManager.shared.availableFontFamilies as? [String] {
            let allFonts = fontFamilies.sorted()
            
            // 过滤出等宽字体
            for fontFamily in allFonts {
                // 跳过已添加的字体
                if fonts.contains(fontFamily) {
                    continue
                }
                
                // 检查是否是等宽字体
                if let font = NSFont(name: fontFamily, size: 12) {
                    let fontDescriptor = font.fontDescriptor
                    if fontDescriptor.symbolicTraits.contains(.monoSpace) {
                        fonts.append(fontFamily)
                    }
                }
            }
        }
        
        return fonts
    }
    
    /// 系统字体列表（兼容旧代码）
    static var systemFonts: [String] {
        return allSystemFonts
    }
    
    /// 所有可用字体
    static var availableFonts: [String] {
        return allSystemFonts + allMonospacedFonts
    }
    
    // MARK: - 字体名称本地化
    
    /// 中文字体名称映射（英文名称 -> 中文显示名称）
    static let chineseFontNameMap: [String: String] = [
        "System": "系统字体",
        "Songti SC": "宋体",
        "Heiti SC": "黑体",
        "Kaiti SC": "楷体",
        "PingFang SC": "苹方",
        "STHeiti": "华文黑体",
        "STSong": "华文宋体",
        "STKaiti": "华文楷体",
        "STFangsong": "华文仿宋",
        "STXihei": "华文细黑",
        "STXingkai": "华文行楷",
        "STZhongsong": "华文中宋",
        "STCaiyun": "华文彩云",
        "STHupo": "华文琥珀",
        "STLiti": "华文隶书",
        "STXinwei": "华文新魏",
        "Menlo": "Menlo",
        "Monaco": "Monaco",
        "Courier New": "Courier New",
        "SF Mono": "SF Mono"
    ]
    
    /// 获取字体的显示名称（中文优先，使用系统本地化名称）
    static func fontDisplayName(for fontName: String) -> String {
        // 首先检查我们的中文映射
        if let chineseName = chineseFontNameMap[fontName] {
            return chineseName
        }
        
        // 尝试使用系统的本地化字体名称
        if let font = NSFont(name: fontName, size: 12) {
            let localizedName = font.displayName ?? fontName
            // 如果系统返回了本地化名称且与原始名称不同，使用本地化名称
            if localizedName != fontName {
                return localizedName
            }
        }
        
        // 否则返回原始名称
        return fontName
    }
}

// MARK: - 兼容性别名（用于在导入 CodeTheme 前使用）

// CodeTheme 在 ThemeConfig.swift 中定义，已经导入


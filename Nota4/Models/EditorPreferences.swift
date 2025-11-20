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
    var alignment: Alignment = .leading
    
    // MARK: - Nested Types
    
    /// 对齐方式
    enum Alignment: String, Codable, CaseIterable {
        case leading = "左对齐"
        case center = "居中"
    }
}

// MARK: - 可用字体列表

import AppKit

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


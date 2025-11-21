import Foundation
import AppKit

// MARK: - Export Options

/// 图片处理方式
enum ImageHandling: String, Equatable, Codable {
    /// 内嵌为 Base64（自包含，文件较大）
    case base64
    
    /// 相对路径（需要复制图片文件）
    case relativePath
    
    /// 绝对路径（不推荐，但保留选项）
    case absolutePath
}

/// HTML 导出选项
struct HTMLExportOptions: Equatable, Codable {
    /// 主题 ID（nil 表示使用当前预览主题）
    var themeId: String?
    
    /// 是否包含目录（TOC）
    var includeTOC: Bool = false
    
    /// 图片处理方式
    var imageHandling: ImageHandling = .base64
    
    static let `default` = HTMLExportOptions()
}

/// 纸张大小枚举（用于 Picker，避免 CGSize Hashable 问题）
enum PaperSize: String, CaseIterable, Hashable {
    case a4 = "A4"
    case letter = "Letter"
    
    var cgSize: CGSize {
        switch self {
        case .a4:
            return CGSize(width: 595, height: 842)
        case .letter:
            return CGSize(width: 612, height: 792)
        }
    }
    
    var displayName: String {
        rawValue
    }
}

/// PDF 导出选项
struct PDFExportOptions: Equatable, Codable {
    /// 主题 ID（nil 表示使用当前预览主题）
    var themeId: String?
    
    /// 是否包含目录（TOC）
    var includeTOC: Bool = false
    
    /// 页面大小
    var paperSize: CGSize
    
    /// 页边距（点）
    var margin: CGFloat = 72.0 // 默认 1 英寸
    
    init(
        themeId: String? = nil,
        includeTOC: Bool = false,
        paperSize: CGSize = CGSize(width: 595, height: 842), // A4 尺寸（点）
        margin: CGFloat = 72.0
    ) {
        self.themeId = themeId
        self.includeTOC = includeTOC
        self.paperSize = paperSize
        self.margin = margin
    }
    
    static let `default` = PDFExportOptions()
    
    /// A4 页面大小（点）
    static let a4Size = CGSize(width: 595, height: 842)
    
    /// Letter 页面大小（点）
    static let letterSize = CGSize(width: 612, height: 792)
    
    /// 从 PaperSize 枚举获取 CGSize
    var paperSizeEnum: PaperSize {
        if paperSize == PDFExportOptions.a4Size {
            return .a4
        } else if paperSize == PDFExportOptions.letterSize {
            return .letter
        } else {
            return .a4 // 默认
        }
    }
    
    /// 设置纸张大小（从枚举）
    mutating func setPaperSize(_ size: PaperSize) {
        paperSize = size.cgSize
    }
}

/// PNG 导出选项
struct PNGExportOptions: Equatable, Codable {
    /// 主题 ID（nil 表示使用当前预览主题）
    var themeId: String?
    
    /// 是否包含目录（TOC）
    var includeTOC: Bool = false
    
    /// 图片宽度（像素）
    var width: CGFloat = 1200
    
    /// 背景色（nil 表示使用主题背景色）
    var backgroundColor: String? = nil
    
    init(
        themeId: String? = nil,
        includeTOC: Bool = false,
        width: CGFloat = 1200,
        backgroundColor: String? = nil
    ) {
        self.themeId = themeId
        self.includeTOC = includeTOC
        self.width = width
        self.backgroundColor = backgroundColor
    }
    
    static let `default` = PNGExportOptions()
}

// MARK: - Note
// CGSize already conforms to Codable in CoreGraphics, so no extension needed


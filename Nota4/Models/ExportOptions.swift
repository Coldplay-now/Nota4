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

/// PDF 导出选项
struct PDFExportOptions: Equatable, Codable {
    /// 主题 ID（nil 表示使用当前预览主题）
    var themeId: String?
    
    /// 是否包含目录（TOC）
    var includeTOC: Bool = false
    
    /// 页面大小
    var paperSize: NSSize
    
    /// 页边距（点）
    var margin: CGFloat = 72.0 // 默认 1 英寸
    
    init(
        themeId: String? = nil,
        includeTOC: Bool = false,
        paperSize: NSSize = NSSize(width: 595, height: 842), // A4 尺寸（点）
        margin: CGFloat = 72.0
    ) {
        self.themeId = themeId
        self.includeTOC = includeTOC
        self.paperSize = paperSize
        self.margin = margin
    }
    
    static let `default` = PDFExportOptions()
    
    /// A4 页面大小（点）
    static let a4Size = NSSize(width: 595, height: 842)
    
    /// Letter 页面大小（点）
    static let letterSize = NSSize(width: 612, height: 792)
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

// MARK: - NSSize Codable Extension

extension NSSize: Codable {
    enum CodingKeys: String, CodingKey {
        case width
        case height
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decode(CGFloat.self, forKey: .width)
        let height = try container.decode(CGFloat.self, forKey: .height)
        self.init(width: width, height: height)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
}


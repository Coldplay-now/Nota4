import Foundation
import AppKit
import UniformTypeIdentifiers

// MARK: - File Dialog Helpers

/// 文件对话框工具函数
@MainActor
enum FileDialogHelpers {
    
    /// 显示文件保存对话框（单文件导出）
    /// - Parameters:
    ///   - defaultName: 默认文件名
    ///   - allowedFileTypes: 允许的文件类型（如 ["html", "pdf", "png"]）
    ///   - completion: 完成回调，返回选择的 URL（如果用户取消则为 nil）
    static func showSavePanel(
        defaultName: String,
        allowedFileTypes: [String],
        completion: @escaping (URL?) -> Void
    ) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = defaultName
        panel.allowedContentTypes = allowedFileTypes.compactMap { UTType(filenameExtension: $0) }
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                completion(url)
            } else {
                completion(nil)
            }
        }
    }
    
    /// 显示目录选择对话框（批量导出）
    /// - Parameter completion: 完成回调，返回选择的目录 URL（如果用户取消则为 nil）
    static func showDirectoryPanel(
        completion: @escaping (URL?) -> Void
    ) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.message = "选择导出位置"
        panel.prompt = "导出"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                completion(url)
            } else {
                completion(nil)
            }
        }
    }
    
    /// 清理文件名，移除不安全的字符
    /// - Parameter name: 原始文件名
    /// - Returns: 清理后的文件名
    static func sanitizeFileName(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
    
    /// 根据导出格式生成文件扩展名
    /// - Parameter format: 导出格式
    /// - Returns: 文件扩展名（不含点）
    @MainActor
    static func fileExtension(for format: ExportFeature.ExportFormat) -> String {
        switch format {
        case .nota:
            return "nota"
        case .markdown:
            return "md"
        case .html:
            return "html"
        case .pdf:
            return "pdf"
        case .png:
            return "png"
        }
    }
    
    /// 生成默认文件名
    /// - Parameters:
    ///   - note: 笔记
    ///   - format: 导出格式
    /// - Returns: 默认文件名（含扩展名）
    @MainActor
    static func defaultFileName(for note: Note, format: ExportFeature.ExportFormat) -> String {
        let title = note.title.isEmpty ? note.noteId : note.title
        let sanitizedTitle = sanitizeFileName(title)
        let fileExt = fileExtension(for: format)
        return "\(sanitizedTitle).\(fileExt)"
    }
}


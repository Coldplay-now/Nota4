import Foundation
import Yams

// MARK: - Services Namespace

enum Services {
    enum ExportFormat {
        case nota
        case markdown(includeMetadata: Bool)
        case html(options: HTMLExportOptions)      // 新增
        case pdf(options: PDFExportOptions)        // 新增
        case png(options: PNGExportOptions)         // 新增
    }
}

// MARK: - ExportService Protocol

protocol ExportServiceProtocol {
    func exportAsNota(note: Note, to url: URL) async throws
    func exportAsMarkdown(note: Note, to url: URL, includeMetadata: Bool) async throws
    func exportAsHTML(note: Note, to url: URL, options: HTMLExportOptions) async throws
    func exportAsPDF(note: Note, to url: URL, options: PDFExportOptions) async throws
    func exportAsPNG(note: Note, to url: URL, options: PNGExportOptions) async throws
    func exportMultipleNotes(notes: [Note], to directoryURL: URL, format: Services.ExportFormat) async throws
}

// MARK: - ExportService Error

enum ExportServiceError: Error, LocalizedError, Equatable {
    case invalidURL
    case fileWriteFailed
    case yamlSerializationFailed
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .fileWriteFailed:
            return "文件写入失败"
        case .yamlSerializationFailed:
            return "YAML 序列化失败"
        case .permissionDenied:
            return "权限不足"
        }
    }
}

// MARK: - ExportService Implementation

actor ExportServiceImpl: ExportServiceProtocol {
    
    private let markdownRenderer = MarkdownRenderer()
    
    func exportAsNota(note: Note, to url: URL) async throws {
        // 生成 YAML Front Matter
        let yamlDict: [String: Any] = [
            "id": note.noteId,
            "title": note.title,
            "created": formatDate(note.created),
            "updated": formatDate(note.updated),
            "starred": note.isStarred,
            "pinned": note.isPinned,
            "deleted": note.isDeleted,
            "tags": Array(note.tags)
        ]
        
        guard let yamlString = try? Yams.dump(object: yamlDict) else {
            throw ExportServiceError.yamlSerializationFailed
        }
        
        // 组合 YAML Front Matter 和 Markdown 内容
        let content = "---\n\(yamlString)---\n\n\(note.content)"
        
        // 写入文件
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw ExportServiceError.fileWriteFailed
        }
    }
    
    func exportAsMarkdown(note: Note, to url: URL, includeMetadata: Bool) async throws {
        var content = ""
        
        if includeMetadata {
            // 使用 YAML Front Matter 格式包含元数据
            let yamlDict: [String: Any] = [
                "title": note.title,
                "created": formatDate(note.created),
                "updated": formatDate(note.updated),
                "tags": Array(note.tags)
            ]
            
            if let yamlString = try? Yams.dump(object: yamlDict) {
                content = "---\n\(yamlString)---\n\n"
            }
        }
        
        // 添加标题（如果有）
        if !note.title.isEmpty {
            content += "# \(note.title)\n\n"
        }
        
        // 添加内容
        content += note.content
        
        // 写入文件
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw ExportServiceError.fileWriteFailed
        }
    }
    
    func exportAsHTML(note: Note, to url: URL, options: HTMLExportOptions) async throws {
        // 1. 获取笔记目录
        let libraryURL = try FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let notesDir = libraryURL
            .appendingPathComponent("Containers")
            .appendingPathComponent("com.nota4.Nota4")
            .appendingPathComponent("Data")
            .appendingPathComponent("Documents")
            .appendingPathComponent("NotaLibrary")
            .appendingPathComponent("notes")
        let noteDirectory = notesDir.appendingPathComponent(note.noteId)
        
        // 2. 使用 MarkdownRenderer 生成 HTML
        let renderOptions = RenderOptions(
            themeId: options.themeId,
            includeTOC: options.includeTOC,
            noteDirectory: noteDirectory
        )
        
        var html = try await markdownRenderer.renderToHTML(
            markdown: note.content,
            options: renderOptions
        )
        
        // 3. 处理图片（根据选项）
        switch options.imageHandling {
        case .base64:
            html = try await embedImagesAsBase64(html, noteId: note.noteId)
        case .relativePath:
            // 相对路径：保持原样（HTML 文件需要和图片在同一目录结构）
            // 这里暂时保持原样，后续可以实现复制图片的逻辑
            break
        case .absolutePath:
            // 绝对路径：保持原样
            break
        }
        
        // 4. 更新 HTML 标题
        html = updateHTMLTitle(html, title: note.title)
        
        // 5. 写入文件
        do {
            try html.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw ExportServiceError.fileWriteFailed
        }
    }
    
    func exportAsPDF(note: Note, to url: URL, options: PDFExportOptions) async throws {
        // 1. 获取笔记目录
        let libraryURL = try FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let notesDir = libraryURL
            .appendingPathComponent("Containers")
            .appendingPathComponent("com.nota4.Nota4")
            .appendingPathComponent("Data")
            .appendingPathComponent("Documents")
            .appendingPathComponent("NotaLibrary")
            .appendingPathComponent("notes")
        let noteDirectory = notesDir.appendingPathComponent(note.noteId)
        
        // 2. 使用 MarkdownRenderer 生成 HTML
        let renderOptions = RenderOptions(
            themeId: options.themeId,
            includeTOC: options.includeTOC,
            noteDirectory: noteDirectory
        )
        
        var html = try await markdownRenderer.renderToHTML(
            markdown: note.content,
            options: renderOptions
        )
        
        // 3. 处理图片（PDF 需要内嵌图片）
        html = try await embedImagesAsBase64(html, noteId: note.noteId)
        
        // 4. 生成 PDF
        let pdfGenerator = PDFGenerator()
        let pdfData = try await pdfGenerator.generateFromHTML(html: html, options: options)
        
        // 5. 写入文件
        do {
            try pdfData.write(to: url)
        } catch {
            throw ExportServiceError.fileWriteFailed
        }
    }
    
    func exportAsPNG(note: Note, to url: URL, options: PNGExportOptions) async throws {
        // 1. 获取笔记目录
        let libraryURL = try FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let notesDir = libraryURL
            .appendingPathComponent("Containers")
            .appendingPathComponent("com.nota4.Nota4")
            .appendingPathComponent("Data")
            .appendingPathComponent("Documents")
            .appendingPathComponent("NotaLibrary")
            .appendingPathComponent("notes")
        let noteDirectory = notesDir.appendingPathComponent(note.noteId)
        
        // 2. 使用 MarkdownRenderer 生成 HTML
        let renderOptions = RenderOptions(
            themeId: options.themeId,
            includeTOC: options.includeTOC,
            noteDirectory: noteDirectory
        )
        
        var html = try await markdownRenderer.renderToHTML(
            markdown: note.content,
            options: renderOptions
        )
        
        // 3. 处理图片（PNG 需要内嵌图片）
        html = try await embedImagesAsBase64(html, noteId: note.noteId)
        
        // 4. 生成 PNG
        let pngGenerator = PNGGenerator()
        let pngData = try await pngGenerator.generateFromHTML(html: html, options: options)
        
        // 5. 写入文件
        do {
            try pngData.write(to: url)
        } catch {
            throw ExportServiceError.fileWriteFailed
        }
    }
    
    func exportMultipleNotes(notes: [Note], to directoryURL: URL, format: Services.ExportFormat) async throws {
        // 确保目录存在
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        
        // 导出每个笔记
        for note in notes {
            let fileName: String
            switch format {
            case .nota:
                fileName = "\(note.noteId).nota"
            case .markdown:
                // 使用标题作为文件名，如果标题为空则使用ID
                let sanitizedTitle = sanitizeFileName(note.title.isEmpty ? note.noteId : note.title)
                fileName = "\(sanitizedTitle).md"
            case .html:
                let sanitizedTitle = sanitizeFileName(note.title.isEmpty ? note.noteId : note.title)
                fileName = "\(sanitizedTitle).html"
            case .pdf:
                let sanitizedTitle = sanitizeFileName(note.title.isEmpty ? note.noteId : note.title)
                fileName = "\(sanitizedTitle).pdf"
            case .png:
                let sanitizedTitle = sanitizeFileName(note.title.isEmpty ? note.noteId : note.title)
                fileName = "\(sanitizedTitle).png"
            }
            
            let fileURL = directoryURL.appendingPathComponent(fileName)
            
            switch format {
            case .nota:
                try await exportAsNota(note: note, to: fileURL)
            case .markdown(let includeMetadata):
                try await exportAsMarkdown(note: note, to: fileURL, includeMetadata: includeMetadata)
            case .html(let options):
                try await exportAsHTML(note: note, to: fileURL, options: options)
            case .pdf(let options):
                try await exportAsPDF(note: note, to: fileURL, options: options)
            case .png(let options):
                try await exportAsPNG(note: note, to: fileURL, options: options)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
    
    private func sanitizeFileName(_ name: String) -> String {
        // 移除不安全的文件名字符
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
    
    // MARK: - Image Processing Helpers
    
    /// 将 HTML 中的图片内嵌为 Base64
    func embedImagesAsBase64(_ html: String, noteId: String) async throws -> String {
        var result = html
        let pattern = #"<img([^>]*?)src="([^"]+)""#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return result
        }
        
        let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        
        for match in matches.reversed() {
            guard match.numberOfRanges >= 3,
                  let beforeSrcRange = Range(match.range(at: 1), in: html),
                  let srcRange = Range(match.range(at: 2), in: html) else {
                continue
            }
            
            let beforeSrc = String(html[beforeSrcRange])
            let srcPath = String(html[srcRange])
            
            // 跳过已经是 Base64 的图片
            if srcPath.hasPrefix("data:") {
                continue
            }
            
            // 跳过网络 URL
            if srcPath.hasPrefix("http://") || srcPath.hasPrefix("https://") {
                continue
            }
            
            // 解析图片路径
            if let imageURL = try await resolveImageURL(srcPath, noteId: noteId) {
                do {
                    let imageData = try Data(contentsOf: imageURL)
                    let base64 = imageData.base64EncodedString()
                    let mimeType = getMimeType(for: imageURL.pathExtension)
                    let base64Src = "data:\(mimeType);base64,\(base64)"
                    
                    // 替换 src 属性
                    let newImgTag = #"<img\#(beforeSrc)src="\#(base64Src)""#
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(fullRange, with: newImgTag)
                } catch {
                    print("⚠️ [EXPORT] 无法读取图片: \(imageURL.path), 错误: \(error)")
                    // 继续处理其他图片
                }
            }
        }
        
        return result
    }
    
    /// 解析图片 URL
    private func resolveImageURL(_ srcPath: String, noteId: String) async throws -> URL? {
        // 如果是绝对路径（file://）
        if srcPath.hasPrefix("file://") {
            return URL(string: srcPath)
        }
        
        // 如果是绝对路径（/开头）
        if srcPath.hasPrefix("/") {
            return URL(fileURLWithPath: srcPath)
        }
        
        // 相对路径：尝试从 attachments 目录解析
        if srcPath.hasPrefix("attachments/") {
            // 格式：attachments/{noteId}/{imageId}
            let components = srcPath.components(separatedBy: "/")
            if components.count >= 3 && components[1] == noteId {
                let imageId = components[2...].joined(separator: "/")
                let libraryURL = try FileManager.default.url(
                    for: .libraryDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )
                let attachmentsDir = libraryURL
                    .appendingPathComponent("Containers")
                    .appendingPathComponent("com.nota4.Nota4")
                    .appendingPathComponent("Data")
                    .appendingPathComponent("Documents")
                    .appendingPathComponent("NotaLibrary")
                    .appendingPathComponent("attachments")
                let imageURL = attachmentsDir.appendingPathComponent(noteId).appendingPathComponent(imageId)
                
                if FileManager.default.fileExists(atPath: imageURL.path) {
                    return imageURL
                }
            }
        }
        
        // 相对路径：尝试从 noteDirectory/assets 解析
        // 需要获取 noteDirectory
        let libraryURL = try FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let notesDir = libraryURL
            .appendingPathComponent("Containers")
            .appendingPathComponent("com.nota4.Nota4")
            .appendingPathComponent("Data")
            .appendingPathComponent("Documents")
            .appendingPathComponent("NotaLibrary")
            .appendingPathComponent("notes")
        let noteDir = notesDir.appendingPathComponent(noteId)
        let imageURL = noteDir.appendingPathComponent(srcPath)
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            return imageURL
        }
        
        return nil
    }
    
    /// 获取 MIME 类型
    private func getMimeType(for fileExtension: String) -> String {
        let ext = fileExtension.lowercased()
        switch ext {
        case "png":
            return "image/png"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "gif":
            return "image/gif"
        case "webp":
            return "image/webp"
        case "svg":
            return "image/svg+xml"
        default:
            return "image/png"
        }
    }
    
    /// 更新 HTML 标题
    func updateHTMLTitle(_ html: String, title: String) -> String {
        // 替换 <title> 标签
        let titlePattern = "<title>([^<]*)</title>"
        if let regex = try? NSRegularExpression(pattern: titlePattern) {
            let titleReplacement = "<title>\(title.isEmpty ? "Untitled" : title)</title>"
            if let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
               let range = Range(match.range, in: html) {
                var result = html
                result.replaceSubrange(range, with: titleReplacement)
                return result
            }
        }
        
        // 如果没有找到 <title> 标签，在 <head> 中添加
        if html.contains("<head>") && !html.contains("<title>") {
            return html.replacingOccurrences(of: "<head>", with: "<head>\n    <title>\(title.isEmpty ? "Untitled" : title)</title>")
        }
        
        return html
    }
}

// MARK: - Shared Instance

extension ExportServiceProtocol where Self == ExportServiceImpl {
    static var shared: ExportServiceProtocol {
        ExportServiceImpl()
    }
    
    static var mock: ExportServiceProtocol {
        ExportServiceMock()
    }
}

// MARK: - Mock for Testing

actor ExportServiceMock: ExportServiceProtocol {
    var exportedNotes: [Note] = []
    var exportedURLs: [URL] = []
    var shouldThrowError = false
    var errorToThrow: Error = ExportServiceError.fileWriteFailed
    
    func setShouldThrowError(_ value: Bool) {
        shouldThrowError = value
    }
    
    func setErrorToThrow(_ error: Error) {
        errorToThrow = error
    }
    
    func exportAsNota(note: Note, to url: URL) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        exportedNotes.append(note)
        exportedURLs.append(url)
    }
    
    func exportAsMarkdown(note: Note, to url: URL, includeMetadata: Bool) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        exportedNotes.append(note)
        exportedURLs.append(url)
    }
    
    func exportAsHTML(note: Note, to url: URL, options: HTMLExportOptions) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        exportedNotes.append(note)
        exportedURLs.append(url)
    }
    
    func exportAsPDF(note: Note, to url: URL, options: PDFExportOptions) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        exportedNotes.append(note)
        exportedURLs.append(url)
    }
    
    func exportAsPNG(note: Note, to url: URL, options: PNGExportOptions) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        exportedNotes.append(note)
        exportedURLs.append(url)
    }
    
    func exportMultipleNotes(notes: [Note], to directoryURL: URL, format: Services.ExportFormat) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        exportedNotes.append(contentsOf: notes)
        exportedURLs.append(directoryURL)
    }
}


import Foundation
import Yams

// MARK: - Services Namespace

enum Services {
    enum ExportFormat {
        case nota
        case markdown(includeMetadata: Bool)
    }
}

// MARK: - ExportService Protocol

protocol ExportServiceProtocol {
    func exportAsNota(note: Note, to url: URL) async throws
    func exportAsMarkdown(note: Note, to url: URL, includeMetadata: Bool) async throws
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
            }
            
            let fileURL = directoryURL.appendingPathComponent(fileName)
            
            switch format {
            case .nota:
                try await exportAsNota(note: note, to: fileURL)
            case .markdown(let includeMetadata):
                try await exportAsMarkdown(note: note, to: fileURL, includeMetadata: includeMetadata)
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
    
    func exportMultipleNotes(notes: [Note], to directoryURL: URL, format: Services.ExportFormat) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        exportedNotes.append(contentsOf: notes)
        exportedURLs.append(directoryURL)
    }
}


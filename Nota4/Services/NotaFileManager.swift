import Foundation
import Yams
import CryptoKit

/// Nota 文件管理器实现
actor NotaFileManagerImpl: NotaFileManagerProtocol {
    // MARK: - Properties
    
    private let notesDirectory: URL
    private let trashDirectory: URL
    private let attachmentsDirectory: URL
    
    // MARK: - Initialization
    
    init(notesDirectory: URL, trashDirectory: URL, attachmentsDirectory: URL) throws {
        self.notesDirectory = notesDirectory
        self.trashDirectory = trashDirectory
        self.attachmentsDirectory = attachmentsDirectory
        
        // 确保目录存在
        try FileManager.default.createDirectory(at: notesDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: trashDirectory, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: attachmentsDirectory, withIntermediateDirectories: true)
    }
    
    /// 便利初始化器（使用默认路径）
    static func `default`() throws -> NotaFileManagerImpl {
        let libraryURL = try FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let notaLibraryURL = libraryURL
            .appendingPathComponent("Containers")
            .appendingPathComponent("com.nota4.Nota4")
            .appendingPathComponent("Data")
            .appendingPathComponent("Documents")
            .appendingPathComponent("NotaLibrary")
        
        let notesDirectory = notaLibraryURL.appendingPathComponent("notes")
        let trashDirectory = notaLibraryURL.appendingPathComponent("trash")
        let attachmentsDirectory = notaLibraryURL.appendingPathComponent("attachments")
        
        return try NotaFileManagerImpl(
            notesDirectory: notesDirectory,
            trashDirectory: trashDirectory,
            attachmentsDirectory: attachmentsDirectory
        )
    }
    
    // MARK: - File CRUD
    
    func createNoteFile(_ note: Note) async throws {
        let fileURL = notesDirectory.appendingPathComponent(note.fileName)
        let content = try generateNotaFileContent(from: note)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    func readNoteFile(noteId: String) async throws -> String {
        let fileName = "\(noteId).nota"
        let fileURL = notesDirectory.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // 尝试在 trash 目录查找
            let trashURL = trashDirectory.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: trashURL.path) {
                return try String(contentsOf: trashURL, encoding: .utf8)
            }
            throw FileManagerError.fileNotFound(noteId)
        }
        
        return try String(contentsOf: fileURL, encoding: .utf8)
    }
    
    func updateNoteFile(_ note: Note) async throws {
        let fileURL = notesDirectory.appendingPathComponent(note.fileName)
        let content = try generateNotaFileContent(from: note)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    func deleteNoteFile(noteId: String) async throws {
        let fileName = "\(noteId).nota"
        let sourceURL = notesDirectory.appendingPathComponent(fileName)
        let destinationURL = trashDirectory.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw FileManagerError.fileNotFound(noteId)
        }
        
        // 如果目标已存在，先删除
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
    }
    
    // MARK: - YAML Parsing
    
    /// 解析 .nota 文件内容
    /// - Parameter content: 文件内容
    /// - Returns: (元数据字典, 正文内容)
    func parseNotaFile(content: String) -> (metadata: [String: Any], body: String) {
        // 匹配 YAML Front Matter: ---\n...\n---\n
        let pattern = #"^---\n(.*?)\n---\n(.*)$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]),
              let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
              let yamlRange = Range(match.range(at: 1), in: content),
              let bodyRange = Range(match.range(at: 2), in: content) else {
            // 没有元数据头，整个内容作为正文
            return (metadata: [:], body: content)
        }
        
        let yamlString = String(content[yamlRange])
        let body = String(content[bodyRange])
        
        // 解析 YAML
        let metadata = (try? Yams.load(yaml: yamlString) as? [String: Any]) ?? [:]
        
        return (metadata: metadata, body: body)
    }
    
    /// 生成 .nota 文件内容
    func generateNotaFileContent(from note: Note) throws -> String {
        // 创建元数据
        var metadata: [String: Any] = [
            "note_id": note.noteId,
            "title": note.title,
            "tags": Array(note.tags),
            "starred": note.isStarred,
            "pinned": note.isPinned,
            "created": ISO8601DateFormatter().string(from: note.created),
            "updated": ISO8601DateFormatter().string(from: note.updated)
        ]
        
        // 计算并添加 checksum
        let checksum = calculateChecksum(content: note.content)
        metadata["checksum"] = checksum
        
        // 生成 YAML
        let yamlString = try Yams.dump(object: metadata, allowUnicode: true)
        
        // 组合为完整文件
        return """
        ---
        \(yamlString)---
        
        \(note.content)
        """
    }
    
    /// 计算内容的 MD5 校验和
    func calculateChecksum(content: String) -> String {
        let data = Data(content.utf8)
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - File Operations
    
    func moveToTrash(noteId: String) async throws {
        try await deleteNoteFile(noteId: noteId)
    }
    
    func restoreFromTrash(noteId: String) async throws {
        let fileName = "\(noteId).nota"
        let sourceURL = trashDirectory.appendingPathComponent(fileName)
        let destinationURL = notesDirectory.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw FileManagerError.fileNotFound(noteId)
        }
        
        // 如果目标已存在，先删除
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
    }
    
    func permanentlyDelete(noteId: String) async throws {
        let fileName = "\(noteId).nota"
        let trashURL = trashDirectory.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: trashURL.path) else {
            throw FileManagerError.fileNotFound(noteId)
        }
        
        try FileManager.default.removeItem(at: trashURL)
    }
    
    /// 获取笔记的资源目录（用于存储 assets 和 attachments）
    func getNoteDirectory(for noteId: String) async throws -> URL {
        // 笔记目录：notesDirectory/{noteId}/
        let noteDir = notesDirectory.appendingPathComponent(noteId)
        
        // 确保目录存在
        try FileManager.default.createDirectory(
            at: noteDir,
            withIntermediateDirectories: true
        )
        
        return noteDir
    }
    
    // MARK: - Import/Export
    
    func importFile(from url: URL) async throws -> Note {
        let content = try String(contentsOf: url, encoding: .utf8)
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "nota":
            // 解析 .nota 文件
            let (metadata, body) = parseNotaFile(content: content)
            
            let noteId = metadata["note_id"] as? String ?? UUID().uuidString
            let title = metadata["title"] as? String ?? url.deletingPathExtension().lastPathComponent
            let tags = Set(metadata["tags"] as? [String] ?? [])
            let isStarred = metadata["starred"] as? Bool ?? false
            let isPinned = metadata["pinned"] as? Bool ?? false
            
            let created: Date
            let updated: Date
            
            if let createdString = metadata["created"] as? String {
                created = ISO8601DateFormatter().date(from: createdString) ?? Date()
            } else {
                created = Date()
            }
            
            if let updatedString = metadata["updated"] as? String {
                updated = ISO8601DateFormatter().date(from: updatedString) ?? Date()
            } else {
                updated = Date()
            }
            
            return Note(
                noteId: noteId,
                title: title,
                content: body,
                created: created,
                updated: updated,
                isStarred: isStarred,
                isPinned: isPinned,
                tags: tags
            )
            
        case "md", "markdown", "txt":
            // 导入 Markdown 或纯文本文件
            let title = url.deletingPathExtension().lastPathComponent
            return Note(
                noteId: UUID().uuidString,
                title: title,
                content: content,
                created: Date(),
                updated: Date()
            )
            
        default:
            throw FileManagerError.unsupportedFileFormat(fileExtension)
        }
    }
    
    func exportFile(note: Note, to url: URL, format: ExportFormat) async throws {
        switch format {
        case .nota:
            let content = try generateNotaFileContent(from: note)
            try content.write(to: url, atomically: true, encoding: .utf8)
            
        case .markdown:
            // 移除 YAML 头
            try note.content.write(to: url, atomically: true, encoding: .utf8)
            
        case .html, .pdf:
            // TODO: Implement in later phase
            throw FileManagerError.notImplemented
        }
    }
}

// MARK: - Export Format

enum ExportFormat {
    case nota
    case markdown
    case html
    case pdf
}

// MARK: - File Manager Error

enum FileManagerError: Error {
    case fileNotFound(String)
    case unsupportedFileFormat(String)
    case invalidContent
    case notImplemented
}

// MARK: - Namespace

enum NotaFileManager {
    static let shared: NotaFileManagerProtocol = {
        do {
            return try NotaFileManagerImpl.default()
        } catch {
            print("❌ Failed to initialize NotaFileManager: \(error)")
            print("⚠️  Falling back to mock implementation")
            return NotaFileManagerMock()
        }
    }()
    
    static var live: NotaFileManagerProtocol {
        get throws {
            try NotaFileManagerImpl.default()
        }
    }
    
    static var mock: NotaFileManagerProtocol {
        NotaFileManagerMock()
    }
}

// MARK: - Mock Implementation

actor NotaFileManagerMock: NotaFileManagerProtocol {
    func createNoteFile(_ note: Note) async throws {
        // Mock implementation
    }
    
    func readNoteFile(noteId: String) async throws -> String {
        return "# Mock Note\n\nContent..."
    }
    
    func updateNoteFile(_ note: Note) async throws {
        // Mock implementation
    }
    
    func deleteNoteFile(noteId: String) async throws {
        // Mock implementation
    }
    
    func restoreFromTrash(noteId: String) async throws {
        // Mock implementation
    }
    
    func getNoteDirectory(for noteId: String) async throws -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL.appendingPathComponent("NotaLibrary/notes/\(noteId)")
    }
}







import Foundation
import Yams

// MARK: - ImportService Protocol

protocol ImportServiceProtocol {
    func importNotaFile(from url: URL) async throws -> Note
    func importMarkdownFile(from url: URL) async throws -> Note
    func importMultipleFiles(from urls: [URL]) async throws -> [Note]
}

// MARK: - ImportService Error

enum ImportServiceError: Error, LocalizedError, Equatable {
    case invalidFileType
    case fileReadFailed
    case yamlParsingFailed
    case noteCreationFailed
    case conflictDetected(noteId: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidFileType:
            return "不支持的文件类型"
        case .fileReadFailed:
            return "文件读取失败"
        case .yamlParsingFailed:
            return "YAML 解析失败"
        case .noteCreationFailed:
            return "笔记创建失败"
        case .conflictDetected(let noteId):
            return "检测到冲突的笔记 ID: \(noteId)"
        }
    }
}

// MARK: - ImportService Implementation

actor ImportServiceImpl: ImportServiceProtocol {
    private let noteRepository: NoteRepositoryProtocol
    private let notaFileManager: NotaFileManagerProtocol
    
    init(
        noteRepository: NoteRepositoryProtocol,
        notaFileManager: NotaFileManagerProtocol
    ) {
        self.noteRepository = noteRepository
        self.notaFileManager = notaFileManager
    }
    
    func importNotaFile(from url: URL) async throws -> Note {
        // 检查文件扩展名
        guard url.pathExtension == "nota" else {
            throw ImportServiceError.invalidFileType
        }
        
        // 读取文件内容
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            throw ImportServiceError.fileReadFailed
        }
        
        // 解析 YAML Front Matter
        let note = try parseNotaContent(content)
        
        // 检查是否存在冲突
        if let _ = try? await noteRepository.fetchNote(byId: note.noteId) {
            // 如果已存在相同ID的笔记，生成新的ID
            var newNote = note
            let newId = UUID().uuidString
            newNote = Note(
                noteId: newId,
                title: newNote.title,
                content: newNote.content,
                created: newNote.created,
                updated: newNote.updated,
                isStarred: newNote.isStarred,
                isPinned: newNote.isPinned,
                isDeleted: newNote.isDeleted,
                tags: newNote.tags,
                checksum: newNote.checksum
            )
            return try await createAndSaveNote(newNote)
        }
        
        return try await createAndSaveNote(note)
    }
    
    func importMarkdownFile(from url: URL) async throws -> Note {
        print("📥 [IMPORT] Starting import of Markdown file: \(url.lastPathComponent)")
        
        // 检查文件扩展名
        guard url.pathExtension == "md" || url.pathExtension == "markdown" else {
            print("❌ [IMPORT] Invalid file type: \(url.pathExtension)")
            throw ImportServiceError.invalidFileType
        }
        
        // 读取文件内容
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("❌ [IMPORT] Failed to read file content")
            throw ImportServiceError.fileReadFailed
        }
        print("📄 [IMPORT] File content read successfully, length: \(content.count) characters")
        
        // 从文件名提取标题
        let title = url.deletingPathExtension().lastPathComponent
        print("📝 [IMPORT] Extracted title from filename: '\(title)'")
        
        // 检查是否有 YAML Front Matter
        let note: Note
        if content.hasPrefix("---") {
            print("🔍 [IMPORT] Found YAML Front Matter, parsing...")
            // 有 YAML Front Matter，尝试解析
            note = try parseNotaContent(content)
            print("✅ [IMPORT] YAML parsed successfully, title: '\(note.title)'")
        } else {
            print("📋 [IMPORT] No YAML Front Matter, creating new note")
            // 没有 YAML Front Matter，创建新笔记
            note = Note(
                noteId: UUID().uuidString,
                title: title,
                content: content,
                created: Date(),
                updated: Date()
            )
            print("✅ [IMPORT] New note created with ID: \(note.noteId), title: '\(note.title)'")
        }
        
        print("💾 [IMPORT] Saving note to database and filesystem...")
        let savedNote = try await createAndSaveNote(note)
        print("✅ [IMPORT] Note saved successfully! ID: \(savedNote.noteId), Title: '\(savedNote.title)'")
        
        return savedNote
    }
    
    func importMultipleFiles(from urls: [URL]) async throws -> [Note] {
        var importedNotes: [Note] = []
        var errors: [Error] = []
        
        for url in urls {
            do {
                let note: Note
                if url.pathExtension == "nota" {
                    note = try await importNotaFile(from: url)
                } else if url.pathExtension == "md" || url.pathExtension == "markdown" {
                    note = try await importMarkdownFile(from: url)
                } else {
                    throw ImportServiceError.invalidFileType
                }
                importedNotes.append(note)
            } catch {
                errors.append(error)
                // 继续处理其他文件
                continue
            }
        }
        
        // 如果有错误但也有成功导入的笔记，返回成功的笔记
        // 如果全部失败，抛出第一个错误
        if importedNotes.isEmpty && !errors.isEmpty {
            throw errors.first!
        }
        
        return importedNotes
    }
    
    // MARK: - Private Helpers
    
    private func parseNotaContent(_ content: String) throws -> Note {
        // 分离 YAML Front Matter 和 Markdown 内容
        guard content.hasPrefix("---") else {
            throw ImportServiceError.yamlParsingFailed
        }
        
        let components = content.components(separatedBy: "---")
        guard components.count >= 3 else {
            throw ImportServiceError.yamlParsingFailed
        }
        
        let yamlString = components[1]
        let markdownContent = components[2...].joined(separator: "---").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 解析 YAML
        guard let yamlDict = try? Yams.load(yaml: yamlString) as? [String: Any] else {
            throw ImportServiceError.yamlParsingFailed
        }
        
        // 提取字段
        let noteId = yamlDict["id"] as? String ?? UUID().uuidString
        let title = yamlDict["title"] as? String ?? ""
        let created = parseDate(yamlDict["created"] as? String) ?? Date()
        let updated = parseDate(yamlDict["updated"] as? String) ?? Date()
        let isStarred = yamlDict["starred"] as? Bool ?? false
        let isPinned = yamlDict["pinned"] as? Bool ?? false
        let isDeleted = yamlDict["deleted"] as? Bool ?? false
        let tags = yamlDict["tags"] as? [String] ?? []
        
        return Note(
            noteId: noteId,
            title: title,
            content: markdownContent,
            created: created,
            updated: updated,
            isStarred: isStarred,
            isPinned: isPinned,
            isDeleted: isDeleted,
            tags: Set(tags)
        )
    }
    
    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString)
    }
    
    private func createAndSaveNote(_ note: Note) async throws -> Note {
        // 保存到数据库
        try await noteRepository.createNote(note)
        
        // 保存到文件系统
        try await notaFileManager.createNoteFile(note)
        
        return note
    }
}

// MARK: - Dependency Injection

extension ImportServiceImpl {
    static func live() async throws -> ImportServiceImpl {
        let dbManager = try DatabaseManager.default()
        let dbQueue = await dbManager.getQueue()
        let noteRepository = NoteRepositoryImpl(dbQueue: dbQueue)
        
        // 设置默认目录
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("Nota4")
        
        let notesDir = appSupport.appendingPathComponent("notes")
        let trashDir = appSupport.appendingPathComponent("trash")
        let attachmentsDir = appSupport.appendingPathComponent("attachments")
        
        let notaFileManager = try NotaFileManagerImpl(
            notesDirectory: notesDir,
            trashDirectory: trashDir,
            attachmentsDirectory: attachmentsDir
        )
        
        return ImportServiceImpl(
            noteRepository: noteRepository,
            notaFileManager: notaFileManager
        )
    }
}

// MARK: - Shared Instance

private actor ImportServiceContainer {
    static let shared = ImportServiceContainer()
    
    private var _service: ImportServiceProtocol?
    
    private init() {}
    
    func getService() async -> ImportServiceProtocol {
        if let service = _service {
            return service
        }
        
        do {
            let service = try await ImportServiceImpl.live()
            _service = service
            print("✅ [IMPORT] ImportService initialized successfully")
            return service
        } catch {
            print("❌ [IMPORT] Failed to initialize ImportService: \(error), using mock")
            let mock = ImportServiceMock()
            _service = mock
            return mock
        }
    }
}

extension ImportServiceProtocol where Self == ImportServiceImpl {
    static var shared: ImportServiceProtocol {
        // 返回一个桥接对象，它会异步获取真实的 service
        ImportServiceBridge()
    }
    
    static var mock: ImportServiceProtocol {
        ImportServiceMock()
    }
}

// MARK: - Bridge for Synchronous Access

private actor ImportServiceBridge: ImportServiceProtocol {
    private var service: ImportServiceProtocol?
    
    private func getService() async -> ImportServiceProtocol {
        if let service = service {
            return service
        }
        let newService = await ImportServiceContainer.shared.getService()
        service = newService
        return newService
    }
    
    func importNotaFile(from url: URL) async throws -> Note {
        let service = await getService()
        return try await service.importNotaFile(from: url)
    }
    
    func importMarkdownFile(from url: URL) async throws -> Note {
        let service = await getService()
        return try await service.importMarkdownFile(from: url)
    }
    
    func importMultipleFiles(from urls: [URL]) async throws -> [Note] {
        let service = await getService()
        return try await service.importMultipleFiles(from: urls)
    }
}

// MARK: - Mock for Testing

actor ImportServiceMock: ImportServiceProtocol {
    var importedNotes: [Note] = []
    var shouldThrowError = false
    var errorToThrow: Error = ImportServiceError.fileReadFailed
    
    func setShouldThrowError(_ value: Bool) {
        shouldThrowError = value
    }
    
    func setErrorToThrow(_ error: Error) {
        errorToThrow = error
    }
    
    func importNotaFile(from url: URL) async throws -> Note {
        if shouldThrowError {
            throw errorToThrow
        }
        let note = Note(noteId: UUID().uuidString, title: "Imported Note", content: "Test Content")
        importedNotes.append(note)
        return note
    }
    
    func importMarkdownFile(from url: URL) async throws -> Note {
        if shouldThrowError {
            throw errorToThrow
        }
        let note = Note(noteId: UUID().uuidString, title: url.deletingPathExtension().lastPathComponent, content: "Markdown Content")
        importedNotes.append(note)
        return note
    }
    
    func importMultipleFiles(from urls: [URL]) async throws -> [Note] {
        if shouldThrowError {
            throw errorToThrow
        }
        var notes: [Note] = []
        for url in urls {
            // 模拟真实实现：根据文件扩展名调用相应方法
            let note: Note
            if url.pathExtension == "nota" {
                note = try await importNotaFile(from: url)
            } else if url.pathExtension == "md" || url.pathExtension == "markdown" {
                note = try await importMarkdownFile(from: url)
            } else {
                throw ImportServiceError.invalidFileType
            }
            notes.append(note)
        }
        return notes
    }
}


import Foundation
import GRDB

/// 笔记仓库实现
actor NoteRepositoryImpl: NoteRepositoryProtocol {
    // MARK: - Properties
    
    private let dbQueue: DatabaseQueue
    
    // MARK: - Initialization
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    // MARK: - Create
    
    func createNote(_ note: Note) async throws {
        try await dbQueue.write { [note] db in
            let mutableNote = note
            try mutableNote.insert(db)
            
            // 插入标签
            for tag in note.tags {
                try db.execute(
                    sql: "INSERT INTO note_tags (note_id, tag) VALUES (?, ?)",
                    arguments: [note.noteId, tag]
                )
            }
        }
    }
    
    // MARK: - Read
    
    func fetchNote(byId noteId: String) async throws -> Note {
        try await dbQueue.read { db in
            guard var note = try Note
                .filter(Note.Columns.noteId == noteId)
                .fetchOne(db) else {
                throw RepositoryError.noteNotFound(noteId)
            }
            
            // 加载标签
            let tags = try String.fetchAll(
                db,
                sql: "SELECT tag FROM note_tags WHERE note_id = ?",
                arguments: [noteId]
            )
            note.tags = Set(tags)
            
            return note
        }
    }
    
    func fetchNotes(filter: NoteListFeature.State.Filter) async throws -> [Note] {
        try await dbQueue.read { db in
            var request = Note.all()
            
            // 应用过滤器
            switch filter {
            case .none:
                // .none 表示获取所有笔记（包括已删除的），用于计算各分类数量
                break  // 不应用任何过滤
                
            case .category(let category):
                switch category {
                case .all:
                    request = request.filter(Note.Columns.isDeleted == false)
                case .starred:
                    request = request
                        .filter(Note.Columns.isStarred == true)
                        .filter(Note.Columns.isDeleted == false)
                case .trash:
                    request = request.filter(Note.Columns.isDeleted == true)
                }
                
            case .tags(let tags):
                // 加载带指定标签的笔记
                let placeholders = tags.map { _ in "?" }.joined(separator: ",")
                let noteIds = try String.fetchAll(
                    db,
                    sql: "SELECT DISTINCT note_id FROM note_tags WHERE tag IN (\(placeholders))",
                    arguments: StatementArguments(tags)
                )
                request = request
                    .filter(noteIds.contains(Note.Columns.noteId))
                    .filter(Note.Columns.isDeleted == false)
                
            case .noTags:
                // 加载没有标签的笔记（在note_tags表中不存在的noteId）
                let noteIdsWithTags = try String.fetchAll(
                    db,
                    sql: "SELECT DISTINCT note_id FROM note_tags"
                )
                request = request
                    .filter(!noteIdsWithTags.contains(Note.Columns.noteId))
                    .filter(Note.Columns.isDeleted == false)
                
            case .allTags:
                // 全部标签：显示所有未删除的笔记（不管有没有标签）
                request = request.filter(Note.Columns.isDeleted == false)
                
            case .search:
                // 不使用 FTS5，直接返回所有未删除的笔记
                // 搜索逻辑在 filteredNotes 计算属性中实现（支持所有字符类型，不依赖分词机制）
                request = request.filter(Note.Columns.isDeleted == false)
            }
            
            // 排序：置顶优先，然后按更新时间
            request = request.order(
                Note.Columns.isPinned.desc,
                Note.Columns.updated.desc
            )
            
            // 获取笔记
            var notes = try request.fetchAll(db)
            
            // 为每个笔记加载标签
            for i in 0..<notes.count {
                let tags = try String.fetchAll(
                    db,
                    sql: "SELECT tag FROM note_tags WHERE note_id = ?",
                    arguments: [notes[i].noteId]
                )
                notes[i].tags = Set(tags)
            }
            
            return notes
        }
    }
    
    // MARK: - Update
    
    func updateNote(_ note: Note) async throws {
        try await dbQueue.write { [note] db in
            try note.update(db)
            
            // 更新标签：先删除旧的，再插入新的
            try db.execute(
                sql: "DELETE FROM note_tags WHERE note_id = ?",
                arguments: [note.noteId]
            )
            
            for tag in note.tags {
                try db.execute(
                    sql: "INSERT INTO note_tags (note_id, tag) VALUES (?, ?)",
                    arguments: [note.noteId, tag]
                )
            }
        }
    }
    
    // MARK: - Delete
    
    func deleteNote(byId noteId: String) async throws {
        try await dbQueue.write { db in
            try db.execute(
                sql: "UPDATE notes SET is_deleted = 1, updated = ? WHERE noteId = ?",
                arguments: [Date(), noteId]
            )
        }
    }
    
    func deleteNotes(_ noteIds: Set<String>) async throws {
        try await dbQueue.write { db in
            for noteId in noteIds {
                try db.execute(
                    sql: "UPDATE notes SET is_deleted = 1, updated = ? WHERE noteId = ?",
                    arguments: [Date(), noteId]
                )
            }
        }
    }
    
    func restoreNotes(_ noteIds: Set<String>) async throws {
        try await dbQueue.write { db in
            for noteId in noteIds {
                try db.execute(
                    sql: "UPDATE notes SET is_deleted = 0, updated = ? WHERE noteId = ?",
                    arguments: [Date(), noteId]
                )
            }
        }
    }
    
    func permanentlyDeleteNotes(_ noteIds: Set<String>) async throws {
        try await dbQueue.write { db in
            for noteId in noteIds {
                // 删除标签
                try db.execute(
                    sql: "DELETE FROM note_tags WHERE note_id = ?",
                    arguments: [noteId]
                )
                
                // 删除笔记
                try db.execute(
                    sql: "DELETE FROM notes WHERE noteId = ?",
                    arguments: [noteId]
                )
            }
        }
    }
    
    // MARK: - Tags
    
    func fetchAllTags() async throws -> [SidebarFeature.State.Tag] {
        try await dbQueue.read { db in
            struct TagCount: Decodable, FetchableRecord {
                let tag: String
                let count: Int
            }
            
            let tagCounts = try TagCount.fetchAll(
                db,
                sql: """
                    SELECT tag, COUNT(*) as count 
                    FROM note_tags 
                    JOIN notes ON note_tags.note_id = notes.noteId 
                    WHERE notes.is_deleted = 0
                    GROUP BY tag 
                    ORDER BY count DESC, tag ASC
                    """
            )
            
            return tagCounts.map { tagCount in
                SidebarFeature.State.Tag(
                    name: tagCount.tag,
                    count: tagCount.count
                )
            }
        }
    }
    
    // MARK: - Statistics
    
    func getTotalCount() async throws -> Int {
        try await dbQueue.read { db in
            try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM notes WHERE is_deleted = 0"
            ) ?? 0
        }
    }
}

// MARK: - Repository Error

enum RepositoryError: Error {
    case noteNotFound(String)
    case databaseError(Error)
    case invalidData
}

// MARK: - Namespace

// 全局数据库管理器实例（在应用启动时初始化）
private let globalDatabaseManager: DatabaseManager? = {
    do {
        return try DatabaseManager.default()
    } catch {
        print("❌ Failed to initialize DatabaseManager: \(error)")
        return nil
    }
}()

enum NoteRepository {
    static let shared: NoteRepositoryProtocol = {
        guard let dbManager = globalDatabaseManager else {
            print("⚠️  Database not available, using mock implementation")
            return NoteRepositoryMock()
        }
        
        // 使用 Task 同步获取 queue
        var queue: DatabaseQueue?
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            queue = await dbManager.getQueue()
            semaphore.signal()
        }
        
        semaphore.wait()
        
        guard let dbQueue = queue else {
            print("⚠️  Failed to get database queue, using mock implementation")
            return NoteRepositoryMock()
        }
        
        return NoteRepositoryImpl(dbQueue: dbQueue)
    }()
    
    static var live: NoteRepositoryProtocol {
        get async throws {
            let dbManager = try DatabaseManager.default()
            let queue = await dbManager.getQueue()
            return NoteRepositoryImpl(dbQueue: queue)
        }
    }
    
    static var mock: NoteRepositoryProtocol {
        NoteRepositoryMock()
    }
}

actor NoteRepositoryMock: NoteRepositoryProtocol {
    private var notes: [Note] = Note.mockData
    
    func createNote(_ note: Note) async throws {
        notes.append(note)
    }
    
    func fetchNote(byId noteId: String) async throws -> Note {
        guard let note = notes.first(where: { $0.noteId == noteId }) else {
            throw RepositoryError.noteNotFound(noteId)
        }
        return note
    }
    
    func fetchNotes(filter: NoteListFeature.State.Filter) async throws -> [Note] {
        return notes.filter { !$0.isDeleted }
    }
    
    func updateNote(_ note: Note) async throws {
        if let index = notes.firstIndex(where: { $0.noteId == note.noteId }) {
            notes[index] = note
        }
    }
    
    func deleteNote(byId noteId: String) async throws {
        if let index = notes.firstIndex(where: { $0.noteId == noteId }) {
            notes[index].isDeleted = true
        }
    }
    
    func deleteNotes(_ noteIds: Set<String>) async throws {
        for noteId in noteIds {
            try await deleteNote(byId: noteId)
        }
    }
    
    func restoreNotes(_ noteIds: Set<String>) async throws {
        for noteId in noteIds {
            if let index = notes.firstIndex(where: { $0.noteId == noteId }) {
                notes[index].isDeleted = false
            }
        }
    }
    
    func permanentlyDeleteNotes(_ noteIds: Set<String>) async throws {
        notes.removeAll { noteIds.contains($0.noteId) }
    }
    
    func fetchAllTags() async throws -> [SidebarFeature.State.Tag] {
        return [
            SidebarFeature.State.Tag(name: "工作", count: 3),
            SidebarFeature.State.Tag(name: "学习", count: 2),
            SidebarFeature.State.Tag(name: "生活", count: 1),
        ]
    }
    
    func getTotalCount() async throws -> Int {
        return notes.filter { !$0.isDeleted }.count
    }
}


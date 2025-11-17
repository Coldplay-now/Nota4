import Foundation
import GRDB

/// 数据库管理器
actor DatabaseManager {
    // MARK: - Properties
    
    /// 数据库队列
    private let dbQueue: DatabaseQueue
    
    /// 数据库路径
    let databaseURL: URL
    
    // MARK: - Initialization
    
    init(databaseURL: URL) throws {
        self.databaseURL = databaseURL
        
        // 确保父目录存在
        let directory = databaseURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        // 创建或打开数据库
        self.dbQueue = try DatabaseQueue(path: databaseURL.path)
        
        // 执行迁移
        try performMigrations()
    }
    
    /// 便利初始化器（使用默认路径）
    static func `default`() throws -> DatabaseManager {
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
        
        let databaseURL = notaLibraryURL.appendingPathComponent("metadata.db")
        
        return try DatabaseManager(databaseURL: databaseURL)
    }
    
    // MARK: - Database Access
    
    /// 获取数据库队列（用于 Repository）
    func getQueue() -> DatabaseQueue {
        dbQueue
    }
    
    // MARK: - Migrations
    
    private nonisolated func performMigrations() throws {
        var migrator = DatabaseMigrator()
        
        // v1: 创建基础表
        migrator.registerMigration("v1_create_tables") { db in
            // 笔记表
            try db.create(table: "notes") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("noteId", .text).notNull().unique()
                t.column("title", .text).notNull().defaults(to: "")
                t.column("content", .text).notNull().defaults(to: "")
                t.column("created", .datetime).notNull()
                t.column("updated", .datetime).notNull()
                t.column("is_starred", .boolean).notNull().defaults(to: false)
                t.column("is_pinned", .boolean).notNull().defaults(to: false)
                t.column("is_deleted", .boolean).notNull().defaults(to: false)
                t.column("checksum", .text)
            }
            
            // 标签表（多对多关系）
            try db.create(table: "note_tags") { t in
                t.column("note_id", .text).notNull()
                t.column("tag", .text).notNull()
                t.primaryKey(["note_id", "tag"])
                t.foreignKey(["note_id"], references: "notes", columns: ["noteId"], onDelete: .cascade)
            }
            
            // 索引
            try db.create(index: "idx_noteId", on: "notes", columns: ["noteId"])
            try db.create(index: "idx_is_deleted", on: "notes", columns: ["is_deleted"])
            try db.create(index: "idx_is_starred", on: "notes", columns: ["is_starred"])
            try db.create(index: "idx_is_pinned", on: "notes", columns: ["is_pinned"])
            try db.create(index: "idx_updated", on: "notes", columns: ["updated"])
            try db.create(index: "idx_created", on: "notes", columns: ["created"])
            try db.create(index: "idx_note_tags_note_id", on: "note_tags", columns: ["note_id"])
            try db.create(index: "idx_note_tags_tag", on: "note_tags", columns: ["tag"])
        }
        
        // v2: 移除 FTS5（完全清理现有数据库中的 FTS5 表和触发器）
        migrator.registerMigration("v2_remove_fts") { db in
            // 删除触发器
            try db.execute(sql: "DROP TRIGGER IF EXISTS notes_fts_insert")
            try db.execute(sql: "DROP TRIGGER IF EXISTS notes_fts_update")
            try db.execute(sql: "DROP TRIGGER IF EXISTS notes_fts_delete")
            // 删除 FTS5 表
            try db.execute(sql: "DROP TABLE IF EXISTS notes_fts")
        }
        
        // 执行迁移
        try migrator.migrate(dbQueue)
    }
    
    // MARK: - Development Helpers
    
    #if DEBUG
    /// 清空所有数据（仅用于开发）
    func clearAllData() throws {
        try dbQueue.write { db in
            try db.execute(sql: "DELETE FROM note_tags")
            try db.execute(sql: "DELETE FROM notes")
        }
    }
    
    /// 填充测试数据
    func seedTestData() throws {
        try dbQueue.write { db in
            for note in Note.mockData {
                try note.insert(db)
                
                // 插入标签
                for tag in note.tags {
                    try db.execute(
                        sql: "INSERT INTO note_tags (note_id, tag) VALUES (?, ?)",
                        arguments: [note.noteId, tag]
                    )
                }
            }
        }
    }
    #endif
}







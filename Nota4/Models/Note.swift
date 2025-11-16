import Foundation
import GRDB

/// 笔记模型
struct Note: Codable, Equatable, Identifiable, Hashable {
    // MARK: - Properties
    
    /// 数据库主键（自增）
    var id: Int64?
    
    /// UUID，唯一标识（文件名）
    let noteId: String
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(noteId)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.noteId == rhs.noteId
    }
    
    /// 笔记标题
    var title: String
    
    /// Markdown 内容
    var content: String
    
    /// 创建时间
    let created: Date
    
    /// 最后更新时间
    var updated: Date
    
    /// 是否星标
    var isStarred: Bool
    
    /// 是否置顶
    var isPinned: Bool
    
    /// 是否已删除（软删除）
    var isDeleted: Bool
    
    /// 标签集合
    var tags: Set<String>
    
    /// MD5 校验和（用于检测文件变化）
    var checksum: String?
    
    // MARK: - Computed Properties
    
    /// 预览文本（前 100 个字符）
    var preview: String {
        let lines = content.split(separator: "\n")
        let preview = lines.prefix(3).joined(separator: " ")
        return String(preview.prefix(100))
    }
    
    /// 文件名：{noteId}.nota
    var fileName: String {
        "\(noteId).nota"
    }
    
    // MARK: - Initializers
    
    init(
        id: Int64? = nil,
        noteId: String = UUID().uuidString,
        title: String = "",
        content: String = "",
        created: Date = Date(),
        updated: Date = Date(),
        isStarred: Bool = false,
        isPinned: Bool = false,
        isDeleted: Bool = false,
        tags: Set<String> = [],
        checksum: String? = nil
    ) {
        self.id = id
        self.noteId = noteId
        self.title = title
        self.content = content
        self.created = created
        self.updated = updated
        self.isStarred = isStarred
        self.isPinned = isPinned
        self.isDeleted = isDeleted
        self.tags = tags
        self.checksum = checksum
    }
}

// MARK: - GRDB Support

extension Note: FetchableRecord, PersistableRecord {
    /// 列名定义
    enum Columns {
        static let id = Column("id")
        static let noteId = Column("noteId")
        static let title = Column("title")
        static let content = Column("content")
        static let created = Column("created")
        static let updated = Column("updated")
        static let isStarred = Column("is_starred")
        static let isPinned = Column("is_pinned")
        static let isDeleted = Column("is_deleted")
        static let checksum = Column("checksum")
    }
    
    /// 表名
    static let databaseTableName = "notes"
    
    /// 编码到数据库
    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.noteId] = noteId
        container[Columns.title] = title
        container[Columns.content] = content
        container[Columns.created] = created
        container[Columns.updated] = updated
        container[Columns.isStarred] = isStarred
        container[Columns.isPinned] = isPinned
        container[Columns.isDeleted] = isDeleted
        container[Columns.checksum] = checksum
    }
    
    /// 从数据库解码（需要手动处理 tags）
    init(row: Row) {
        id = row[Columns.id]
        noteId = row[Columns.noteId]
        title = row[Columns.title]
        content = row[Columns.content]
        created = row[Columns.created]
        updated = row[Columns.updated]
        isStarred = row[Columns.isStarred]
        isPinned = row[Columns.isPinned]
        isDeleted = row[Columns.isDeleted]
        checksum = row[Columns.checksum]
        tags = [] // 标签需要单独查询
    }
}

// MARK: - Mock Data (for testing)

#if DEBUG
extension Note {
    static let mock = Note(
        noteId: "mock-note-1",
        title: "测试笔记",
        content: "# 测试笔记\n\n这是一篇测试笔记。",
        created: Date(),
        updated: Date(),
        isStarred: false,
        isPinned: false,
        isDeleted: false,
        tags: ["测试", "开发"],
        checksum: "d41d8cd98f00b204e9800998ecf8427e"
    )
    
    static let mockData: [Note] = [
        Note(
            noteId: "note-1",
            title: "欢迎使用 Nota4",
            content: "# 欢迎使用 Nota4\n\n这是一个现代化的 Markdown 笔记应用。",
            isStarred: true,
            isPinned: true
        ),
        Note(
            noteId: "note-2",
            title: "学习 SwiftUI",
            content: "## SwiftUI 基础\n\n- 声明式语法\n- 状态管理\n- 组件化",
            tags: ["学习", "SwiftUI"]
        ),
        Note(
            noteId: "note-3",
            title: "TCA 架构",
            content: "## The Composable Architecture\n\n单向数据流...",
            tags: ["学习", "TCA"]
        ),
    ]
}
#endif


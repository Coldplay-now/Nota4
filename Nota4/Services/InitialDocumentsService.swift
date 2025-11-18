import Foundation
import ComposableArchitecture
import Yams

/// 初始文档服务
/// 负责在首次启动时导入帮助文档
actor InitialDocumentsService {
    static let shared = InitialDocumentsService()
    
    private let userDefaults = UserDefaults.standard
    private let hasImportedKey = "HasImportedInitialDocuments"
    
    private init() {}
    
    /// 检查是否需要导入初始文档
    func shouldImportInitialDocuments() -> Bool {
        return !userDefaults.bool(forKey: hasImportedKey)
    }
    
    /// 导入初始文档
    func importInitialDocuments(
        noteRepository: NoteRepositoryProtocol,
        notaFileManager: NotaFileManagerProtocol
    ) async throws {
        guard shouldImportInitialDocuments() else {
            print("⏭️ [INITIAL] 初始文档已导入过，跳过")
            return
        }
        
        print("📚 [INITIAL] 开始导入初始文档...")
        
        let documentNames = [
            "使用说明",
            "Markdown示例"
        ]
        
        for documentName in documentNames {
            do {
                // 从资源包中读取文档
                // 在 SPM 项目中，使用 Bundle.module 访问资源文件
                guard let documentURL = Bundle.module.url(
                    forResource: documentName,
                    withExtension: "nota",
                    subdirectory: "Resources/InitialDocuments"
                ) else {
                    print("⚠️ [INITIAL] 找不到资源文件: \(documentName).nota")
                    print("📁 [INITIAL] 尝试的路径: Resources/InitialDocuments/\(documentName).nota")
                    continue
                }
                
                let documentContent = try String(contentsOf: documentURL, encoding: .utf8)
                
                // 解析 .nota 文件
                let (metadata, body) = parseNotaFile(content: documentContent)
                
                // 从元数据中提取信息
                let title = metadata["title"] as? String ?? documentName
                let tagsArray = metadata["tags"] as? [String] ?? []
                let tags = Set(tagsArray)
                let isStarred = metadata["starred"] as? Bool ?? true
                let isPinned = metadata["pinned"] as? Bool ?? true
                
                // 解析日期
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
                
                // 生成新的笔记ID
                let noteId = UUID().uuidString
                
                // 创建 Note 对象
                let note = Note(
                    noteId: noteId,
                    title: title,
                    content: body,
                    created: created,
                    updated: updated,
                    isStarred: isStarred,
                    isPinned: isPinned,
                    tags: tags
                )
                
                // 保存到数据库
                try await noteRepository.createNote(note)
                
                // 保存到文件系统
                try await notaFileManager.createNoteFile(note)
                
                print("✅ [INITIAL] 成功导入: \(title)")
                
            } catch {
                print("❌ [INITIAL] 导入 \(documentName) 失败: \(error)")
            }
        }
        
        // 标记为已导入
        userDefaults.set(true, forKey: hasImportedKey)
        userDefaults.synchronize()
        
        print("🎉 [INITIAL] 初始文档导入完成！")
    }
    
    /// 解析 .nota 文件内容
    /// - Parameter content: 文件内容
    /// - Returns: (元数据字典, 正文内容)
    private func parseNotaFile(content: String) -> (metadata: [String: Any], body: String) {
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
}


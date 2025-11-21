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
            return
        }
        
        
        let documentNames = [
            "使用说明",
            "Markdown示例"
        ]
        
        for documentName in documentNames {
            do {
                // 从资源包中读取文档
                // 使用安全的资源访问方式，支持 SPM 开发和打包后的应用
                guard let documentURL = Bundle.safeResourceURL(
                    name: documentName,
                    withExtension: "nota",
                    subdirectory: "Resources/InitialDocuments"
                ) else {
                    print("⚠️ [INITIAL] 找不到资源文件: \(documentName).nota")
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
                
                // 复制文档中引用的图片文件到笔记目录
                try await copyReferencedImages(
                    from: body,
                    to: noteId,
                    notaFileManager: notaFileManager
                )
                
            } catch {
                print("❌ [INITIAL] 导入 \(documentName) 失败: \(error)")
            }
        }
        
        // 标记为已导入
        userDefaults.set(true, forKey: hasImportedKey)
        userDefaults.synchronize()
        
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
    
    /// 从文档内容中提取图片引用
    /// - Parameter content: Markdown 文档内容
    /// - Returns: 图片文件名数组（去重）
    private func extractImageReferences(from content: String) -> [String] {
        var imageFiles: Set<String> = []
        
        // 匹配图片语法：![alt](path) 或 [![alt](image)](link)
        // 匹配模式：![...](图片路径) 或 [![...](图片路径)](链接)
        let patterns = [
            #"!\[[^\]]*\]\(([^)]+)\)"#,  // ![alt](path)
            #"\[!\[[^\]]*\]\(([^)]+)\)\]"#  // [![alt](image)](link) - 只提取内层图片路径
        ]
        
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                continue
            }
            
            let matches = regex.matches(
                in: content,
                range: NSRange(content.startIndex..., in: content)
            )
            
            for match in matches {
                guard match.numberOfRanges >= 2,
                      let pathRange = Range(match.range(at: 1), in: content) else {
                    continue
                }
                
                let imagePath = String(content[pathRange])
                
                // 只处理相对路径（不是 http/https/data URL）
                if !imagePath.hasPrefix("http://") &&
                   !imagePath.hasPrefix("https://") &&
                   !imagePath.hasPrefix("data:") &&
                   !imagePath.hasPrefix("/") &&
                   !imagePath.hasPrefix("file://") {
                    // 提取文件名（处理可能的路径）
                    let fileName = (imagePath as NSString).lastPathComponent
                    if !fileName.isEmpty {
                        imageFiles.insert(fileName)
                    }
                }
            }
        }
        
        return Array(imageFiles)
    }
    
    /// 复制文档中引用的图片文件到笔记目录
    /// - Parameters:
    ///   - content: Markdown 文档内容
    ///   - noteId: 笔记 ID
    ///   - notaFileManager: 文件管理器
    private func copyReferencedImages(
        from content: String,
        to noteId: String,
        notaFileManager: NotaFileManagerProtocol
    ) async throws {
        // 提取图片引用
        let imageFiles = extractImageReferences(from: content)
        
        guard !imageFiles.isEmpty else {
            return
        }
        
        // 获取笔记目录
        let noteDirectory = try await notaFileManager.getNoteDirectory(for: noteId)
        
        // 从 bundle 复制每个图片文件
        for imageFile in imageFiles {
            do {
                // 从 bundle 读取图片文件
                guard let sourceURL = Bundle.safeResourceURL(
                    name: imageFile,
                    withExtension: nil,
                    subdirectory: "Resources/InitialDocuments"
                ) else {
                    print("⚠️ [INITIAL] 找不到图片资源: \(imageFile)")
                    continue
                }
                
                // 目标路径：笔记目录/图片文件名
                let destinationURL = noteDirectory.appendingPathComponent(imageFile)
                
                // 如果目标文件已存在，跳过（避免覆盖用户可能修改的图片）
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    continue
                }
                
                // 复制文件
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                print("✅ [INITIAL] 已复制图片: \(imageFile) → \(destinationURL.path)")
                
            } catch {
                // 图片复制失败不影响文档导入，只记录警告
                print("⚠️ [INITIAL] 复制图片失败 \(imageFile): \(error.localizedDescription)")
            }
        }
    }
}


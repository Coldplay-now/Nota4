import Foundation
import Yams

/// 帮助文档服务
/// 负责生成帮助文档的 HTML 预览
actor HelpDocumentService {
    static let shared = HelpDocumentService()
    
    private let helpHTMLFileName = "help.html"
    private let helpDocumentName = "使用说明"
    
    private init() {}
    
    /// 获取帮助文档 HTML 文件 URL
    /// 如果文件不存在，会尝试生成
    func getHelpHTMLURL() async -> URL? {
        // 检查应用支持目录中的 HTML 文件
        let appSupport = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        if let appSupport = appSupport {
            let helpHTMLURL = appSupport
                .appendingPathComponent("Nota4")
                .appendingPathComponent("Help")
                .appendingPathComponent(helpHTMLFileName)
            
            if FileManager.default.fileExists(atPath: helpHTMLURL.path) {
                print("✅ [HELP] 找到已存在的帮助文档: \(helpHTMLURL.path)")
                return helpHTMLURL
            } else {
                print("ℹ️ [HELP] 帮助文档不存在，准备生成: \(helpHTMLURL.path)")
            }
        }
        
        // 文件不存在，尝试生成
        do {
            print("🔄 [HELP] 开始生成帮助文档 HTML...")
            try await generateHelpHTML()
            
            // 再次尝试获取
            let appSupport = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            
            let helpHTMLURL = appSupport
                .appendingPathComponent("Nota4")
                .appendingPathComponent("Help")
                .appendingPathComponent(helpHTMLFileName)
            
            if FileManager.default.fileExists(atPath: helpHTMLURL.path) {
                print("✅ [HELP] 帮助文档 HTML 生成成功: \(helpHTMLURL.path)")
                return helpHTMLURL
            } else {
                print("❌ [HELP] 帮助文档 HTML 生成后文件仍不存在")
                return nil
            }
        } catch {
            print("❌ [HELP] 生成帮助文档 HTML 失败: \(error)")
            print("   [HELP] 错误详情: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 生成帮助文档 HTML
    func generateHelpHTML() async throws {
        // 1. 读取帮助文档 .nota 文件
        guard let documentURL = Bundle.safeResourceURL(
            name: helpDocumentName,
            withExtension: "nota",
            subdirectory: "Resources/InitialDocuments"
        ) else {
            print("❌ [HELP] 找不到帮助文档资源: \(helpDocumentName).nota")
            throw HelpDocumentError.documentNotFound
        }
        
        print("✅ [HELP] 找到帮助文档资源: \(documentURL.path)")
        let documentContent = try String(contentsOf: documentURL, encoding: .utf8)
        
        // 2. 解析 .nota 文件
        let (metadata, body) = parseNotaFile(content: documentContent)
        let title = metadata["title"] as? String ?? helpDocumentName
        
        // 3. 获取笔记目录（用于解析图片路径）
        // 帮助文档的图片在 bundle 的 Resources/InitialDocuments 中
        let noteDirectory = documentURL.deletingLastPathComponent()
        
        // 4. 使用 MarkdownRenderer 生成 HTML
        print("🔄 [HELP] 开始渲染 Markdown 为 HTML...")
        let renderer = MarkdownRenderer()
        let renderOptions = RenderOptions(
            themeId: "builtin-light",  // 使用浅色主题
            includeTOC: false,  // 文档中已有 [TOC]，不需要额外添加
            noteDirectory: noteDirectory
        )
        
        var html: String
        do {
            html = try await renderer.renderToHTML(
                markdown: body,
                options: renderOptions
            )
            print("✅ [HELP] Markdown 渲染完成，HTML 长度: \(html.count) 字符")
        } catch {
            print("❌ [HELP] Markdown 渲染失败: \(error)")
            throw HelpDocumentError.htmlGenerationFailed
        }
        
        // 5. 更新 HTML 标题
        html = updateHTMLTitle(html, title: title)
        
        // 6. 处理图片路径：将相对路径转换为绝对路径（file:// URL）
        // 因为 HTML 文件保存在应用支持目录，而图片在 bundle 中
        print("🔄 [HELP] 处理图片路径...")
        html = convertImagePathsToAbsolute(html, bundleDirectory: noteDirectory)
        print("✅ [HELP] 图片路径处理完成")
        
        // 7. 保存到应用支持目录
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let helpDirectory = appSupport
            .appendingPathComponent("Nota4")
            .appendingPathComponent("Help")
        
        try FileManager.default.createDirectory(
            at: helpDirectory,
            withIntermediateDirectories: true
        )
        
        let helpHTMLURL = helpDirectory.appendingPathComponent(helpHTMLFileName)
        try html.write(to: helpHTMLURL, atomically: true, encoding: .utf8)
        
        // 验证文件是否成功写入
        if FileManager.default.fileExists(atPath: helpHTMLURL.path) {
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: helpHTMLURL.path)[.size] as? Int64) ?? 0
            print("✅ [HELP] 帮助文档 HTML 已生成: \(helpHTMLURL.path) (大小: \(fileSize) 字节)")
        } else {
            print("❌ [HELP] 帮助文档 HTML 写入失败，文件不存在")
            throw HelpDocumentError.htmlGenerationFailed
        }
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
    
    /// 更新 HTML 标题
    private func updateHTMLTitle(_ html: String, title: String) -> String {
        // 替换 <title> 标签
        let titlePattern = #"<title>.*?</title>"#
        if let regex = try? NSRegularExpression(pattern: titlePattern, options: []) {
            let range = NSRange(html.startIndex..., in: html)
            let newTitle = "<title>\(escapeHTML(title))</title>"
            return regex.stringByReplacingMatches(
                in: html,
                options: [],
                range: range,
                withTemplate: newTitle
            )
        }
        return html
    }
    
    /// HTML 转义
    private func escapeHTML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
    
    /// 将 HTML 中的相对图片路径转换为绝对路径（file:// URL）
    /// 因为 HTML 文件保存在应用支持目录，而图片在 bundle 中
    private func convertImagePathsToAbsolute(_ html: String, bundleDirectory: URL) -> String {
        var result = html
        var convertedCount = 0
        
        // 匹配所有 <img> 标签中的 src 属性
        let pattern = #"<img([^>]*?)src="([^"]+)"([^>]*?)>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            print("⚠️ [HELP] 无法创建图片路径正则表达式")
            return result
        }
        
        let matches = regex.matches(
            in: result,
            range: NSRange(result.startIndex..., in: result)
        )
        
        print("ℹ️ [HELP] 找到 \(matches.count) 个图片标签")
        
        // 从后往前处理，避免索引偏移
        for match in matches.reversed() {
            guard match.numberOfRanges >= 4,
                  let beforeSrcRange = Range(match.range(at: 1), in: result),
                  let srcRange = Range(match.range(at: 2), in: result),
                  let afterSrcRange = Range(match.range(at: 3), in: result) else {
                continue
            }
            
            let beforeSrc = String(result[beforeSrcRange])
            let srcPath = String(result[srcRange])
            let afterSrc = String(result[afterSrcRange])
            
            // 跳过已经是绝对路径、网络 URL 或 data URL 的图片
            if srcPath.hasPrefix("http://") ||
               srcPath.hasPrefix("https://") ||
               srcPath.hasPrefix("data:") ||
               srcPath.hasPrefix("file://") ||
               srcPath.hasPrefix("/") {
                continue
            }
            
            // 构建完整路径
            let imageURL = bundleDirectory.appendingPathComponent(srcPath)
            
            // 检查文件是否存在
            if FileManager.default.fileExists(atPath: imageURL.path) {
                // 转换为 file:// URL
                let fileURL = imageURL.absoluteString
                let newImgTag = "<img\(beforeSrc)src=\"\(fileURL)\"\(afterSrc)>"
                let fullRange = Range(match.range, in: result)!
                result.replaceSubrange(fullRange, with: newImgTag)
                convertedCount += 1
                print("✅ [HELP] 转换图片路径: \(srcPath) → \(fileURL)")
            } else {
                print("⚠️ [HELP] 图片文件不存在: \(imageURL.path)")
            }
        }
        
        print("ℹ️ [HELP] 共转换了 \(convertedCount) 个图片路径")
        return result
    }
}

// MARK: - Help Document Error

enum HelpDocumentError: LocalizedError {
    case documentNotFound
    case htmlGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "找不到帮助文档文件"
        case .htmlGenerationFailed:
            return "生成帮助文档 HTML 失败"
        }
    }
}


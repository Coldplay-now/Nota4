# HTML/HTM 导入功能 PRD

**版本**: v1.0  
**日期**: 2025-11-21  
**状态**: 规划中  
**优先级**: P1  
**作者**: Nota4 开发团队

---

## 📋 目录

- [1. 产品概述](#1-产品概述)
- [2. 用户场景](#2-用户场景)
- [3. 功能需求](#3-功能需求)
- [4. 技术方案](#4-技术方案)
- [5. 实施计划](#5-实施计划)
- [6. 测试计划](#6-测试计划)
- [7. 风险评估](#7-风险评估)
- [8. 后续优化](#8-后续优化)

---

## 1. 产品概述

### 1.1 背景

Nota4 目前支持导入 `.nota` 和 `.md` 格式的笔记文件。为了满足用户从网页保存内容到笔记的需求，需要新增 HTML/HTM 文件导入功能。

### 1.2 目标

允许用户导入 HTML/HTM 文件及其相关资源文件夹，将网页内容转换为 Markdown 格式的笔记，并保持原始网页的排布和资源引用关系。

### 1.3 核心价值

- ✅ **网页内容保存**：将网页保存为笔记，便于后续编辑和管理
- ✅ **资源完整性**：自动处理图片、CSS、JS 等资源文件
- ✅ **格式转换**：HTML 自动转换为 Markdown，保持可编辑性
- ✅ **批量导入**：支持文件夹导入，一次性处理多个 HTML 文件

---

## 2. 用户场景

### 2.1 场景 1：单文件导入

**用户操作**：
1. 用户从浏览器保存了一个 HTML 文件（如 `article.html`）
2. 在 Nota4 中选择"导入" → "选择文件"
3. 选择 `article.html` 文件
4. 系统自动导入并转换为笔记

**期望结果**：
- 创建一篇新笔记，标题为文件名（不含扩展名）
- HTML 内容转换为 Markdown
- 笔记内容可正常预览和编辑

### 2.2 场景 2：文件夹导入（含资源）

**用户操作**：
1. 用户从浏览器保存了完整网页（HTML + 资源文件夹）
2. 文件夹结构：
   ```
   saved-page/
   ├── index.html
   ├── images/
   │   ├── logo.png
   │   └── banner.jpg
   ├── styles/
   │   └── main.css
   └── scripts/
       └── app.js
   ```
3. 在 Nota4 中选择"导入" → "选择文件夹"
4. 选择 `saved-page` 文件夹

**期望结果**：
- 识别文件夹中的 HTML 文件（`index.html`）
- 将 HTML 转换为 Markdown 笔记
- 自动复制资源文件到笔记目录
- 更新 Markdown 中的资源路径引用
- 保持原始网页的视觉排布

### 2.3 场景 3：多 HTML 文件导入

**用户操作**：
1. 用户有多个 HTML 文件需要导入
2. 选择多个 HTML 文件或包含多个 HTML 的文件夹
3. 批量导入

**期望结果**：
- 每个 HTML 文件转换为独立的笔记
- 每个笔记的资源文件独立管理
- 显示导入进度和结果统计

---

## 3. 功能需求

### 3.1 功能清单

| 功能 | 优先级 | 实现难度 | 预估工时 |
|------|--------|---------|---------|
| 单 HTML 文件导入 | **P0** | 🟡 中等 | 4h |
| HTML 转 Markdown 转换 | **P0** | 🟡 中等 | 6h |
| 资源文件识别和复制 | **P0** | 🟡 中等 | 4h |
| 资源路径更新 | **P0** | 🟡 中等 | 3h |
| 文件夹导入（递归查找 HTML） | **P1** | 🟢 简单 | 2h |
| 批量导入进度显示 | **P1** | 🟢 简单 | 2h |
| CSS 样式处理（可选） | **P2** | 🟠 困难 | 4h |
| JavaScript 处理（可选） | **P2** | 🟠 困难 | 4h |

### 3.2 详细需求

#### 3.2.1 文件格式支持

**支持的文件扩展名**：
- `.html`
- `.htm`

**支持的文件选择方式**：
- 单文件选择（NSOpenPanel）
- 文件夹选择（递归查找所有 HTML 文件）
- 多文件选择（批量导入）

#### 3.2.2 HTML 转 Markdown 转换

**转换规则**：

| HTML 元素 | Markdown 转换 |
|-----------|--------------|
| `<h1>` - `<h6>` | `#` - `######` |
| `<p>` | 段落（空行分隔） |
| `<strong>`, `<b>` | `**粗体**` |
| `<em>`, `<i>` | `*斜体*` |
| `<a href="...">` | `[链接文本](URL)` |
| `<img src="..." alt="...">` | `![alt](src)` |
| `<ul>`, `<ol>` | `-` 或 `1.` 列表 |
| `<blockquote>` | `>` 引用 |
| `<code>` | `` `代码` `` |
| `<pre><code>` | ` ```代码块``` ` |
| `<table>` | Markdown 表格 |
| `<hr>` | `---` |

**处理策略**：
- 使用 HTML 解析库（如 SwiftSoup）解析 HTML
- 遍历 DOM 树，按规则转换为 Markdown
- 保留文本内容和基本格式
- 忽略无法转换的复杂 HTML（如 `<script>`, `<style>` 等）

#### 3.2.3 资源文件处理

**资源类型识别**：
- 图片：`.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.svg`
- 样式：`.css`
- 脚本：`.js`
- 其他：`.woff`, `.woff2`, `.ttf`（字体文件）

**资源文件查找策略**：

1. **单文件导入**：
   - 解析 HTML 中的资源引用（`<img src>`, `<link href>`, `<script src>`）
   - 在 HTML 文件所在目录查找资源文件
   - 支持相对路径和绝对路径

2. **文件夹导入**：
   - 递归查找文件夹中的所有资源文件
   - 保持文件夹结构（可选）
   - 或扁平化到笔记的 `assets` 目录

**资源文件复制**：
- 复制到笔记目录的 `assets` 子目录
- 保持文件名唯一性（如有冲突，添加序号）
- 更新 Markdown 中的资源路径引用

#### 3.2.4 路径更新

**路径转换规则**：

| 原始路径 | 转换后路径 | 说明 |
|---------|-----------|------|
| `images/logo.png` | `assets/logo.png` | 相对路径 |
| `./images/logo.png` | `assets/logo.png` | 当前目录相对路径 |
| `../images/logo.png` | `assets/logo.png` | 上级目录相对路径 |
| `/images/logo.png` | `assets/logo.png` | 绝对路径（转换为相对） |
| `http://example.com/img.png` | `http://example.com/img.png` | 网络 URL（保持不变） |
| `https://example.com/img.png` | `https://example.com/img.png` | 网络 URL（保持不变） |

**实现逻辑**：
```swift
func updateResourcePaths(in markdown: String, resourceMap: [String: String]) -> String {
    // resourceMap: [原始路径: 新路径]
    // 使用正则表达式匹配 Markdown 中的图片和链接
    // 替换为新的资源路径
}
```

#### 3.2.5 标题提取

**标题提取策略**（按优先级）：
1. HTML `<title>` 标签
2. 第一个 `<h1>` 标签内容
3. HTML 文件名（不含扩展名）
4. 默认："导入的网页"

#### 3.2.6 元数据提取

**可提取的元数据**：
- `<title>` → 笔记标题
- `<meta name="description">` → 可添加到笔记开头作为摘要
- `<meta name="author">` → 可添加到笔记标签
- `<meta name="keywords">` → 可转换为笔记标签

---

## 4. 技术方案

### 4.1 架构设计

```
ImportService
├── importHTMLFile(from: URL) → Note
├── importHTMLFolder(from: URL) → [Note]
└── HTMLConverter
    ├── parseHTML(html: String) → DOM
    ├── convertToMarkdown(dom: DOM) → String
    ├── extractResources(html: String, baseURL: URL) → [Resource]
    └── updateResourcePaths(markdown: String, resourceMap: [String: String]) → String
```

### 4.2 依赖库选择

#### 4.2.1 HTML 解析库

**选项 A：SwiftSoup（推荐）**
- ✅ 纯 Swift 实现
- ✅ 类似 jQuery 的 API
- ✅ 支持 HTML 解析和 DOM 操作
- ✅ 活跃维护
- ⚠️ 需要添加依赖

**选项 B：Foundation XMLParser**
- ✅ 系统自带，无需依赖
- ❌ 只支持 XML，HTML 可能解析失败
- ❌ API 较复杂

**推荐**：使用 SwiftSoup

#### 4.2.2 HTML 转 Markdown 库

**选项 A：自实现转换器（推荐）**
- ✅ 完全控制转换规则
- ✅ 可定制化
- ✅ 无额外依赖
- ⚠️ 需要实现完整的转换逻辑

**选项 B：第三方库（如 html2markdown）**
- ✅ 功能完整
- ⚠️ 可能不符合需求
- ⚠️ 需要添加依赖

**推荐**：自实现转换器，基于 SwiftSoup 解析的 DOM 树进行转换

### 4.3 实现细节

#### 4.3.1 HTML 解析和转换

```swift
import SwiftSoup

actor HTMLConverter {
    /// 将 HTML 转换为 Markdown
    func convertToMarkdown(html: String, baseURL: URL) throws -> (markdown: String, resources: [Resource]) {
        // 1. 解析 HTML
        let doc = try SwiftSoup.parse(html, baseURL.absoluteString)
        
        // 2. 提取资源引用
        let resources = try extractResources(from: doc, baseURL: baseURL)
        
        // 3. 转换为 Markdown
        let markdown = try convertDocumentToMarkdown(doc)
        
        return (markdown, resources)
    }
    
    /// 提取资源文件引用
    private func extractResources(from doc: Document, baseURL: URL) throws -> [Resource] {
        var resources: [Resource] = []
        
        // 提取图片
        let images = try doc.select("img")
        for img in images {
            if let src = try? img.attr("src"),
               let url = URL(string: src, relativeTo: baseURL) {
                resources.append(Resource(
                    type: .image,
                    originalPath: src,
                    absoluteURL: url
                ))
            }
        }
        
        // 提取 CSS
        let stylesheets = try doc.select("link[rel=stylesheet]")
        for link in stylesheets {
            if let href = try? link.attr("href"),
               let url = URL(string: href, relativeTo: baseURL) {
                resources.append(Resource(
                    type: .stylesheet,
                    originalPath: href,
                    absoluteURL: url
                ))
            }
        }
        
        // 提取 JavaScript
        let scripts = try doc.select("script[src]")
        for script in scripts {
            if let src = try? script.attr("src"),
               let url = URL(string: src, relativeTo: baseURL) {
                resources.append(Resource(
                    type: .script,
                    originalPath: src,
                    absoluteURL: url
                ))
            }
        }
        
        return resources
    }
    
    /// 将 DOM 文档转换为 Markdown
    private func convertDocumentToMarkdown(_ doc: Document) throws -> String {
        var markdown = ""
        
        // 获取 body 内容
        guard let body = try? doc.body() else {
            return ""
        }
        
        // 遍历 body 的子元素
        for element in body.children() {
            markdown += convertElementToMarkdown(element)
            markdown += "\n\n"
        }
        
        return markdown.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 转换单个元素为 Markdown
    private func convertElementToMarkdown(_ element: Element) -> String {
        let tagName = element.tagName().lowercased()
        
        switch tagName {
        case "h1": return "# \(element.text())\n"
        case "h2": return "## \(element.text())\n"
        case "h3": return "### \(element.text())\n"
        case "h4": return "#### \(element.text())\n"
        case "h5": return "##### \(element.text())\n"
        case "h6": return "###### \(element.text())\n"
        case "p": return element.text()
        case "strong", "b": return "**\(element.text())**"
        case "em", "i": return "*\(element.text())*"
        case "a":
            let text = element.text()
            if let href = try? element.attr("href") {
                return "[\(text)](\(href))"
            }
            return text
        case "img":
            let alt = (try? element.attr("alt")) ?? ""
            if let src = try? element.attr("src") {
                return "![\(alt)](\(src))"
            }
            return ""
        case "ul", "ol":
            return convertListToMarkdown(element)
        case "blockquote":
            let text = element.text()
            return text.components(separatedBy: "\n")
                .map { "> \($0)" }
                .joined(separator: "\n")
        case "code":
            return "`\(element.text())`"
        case "pre":
            if let code = try? element.select("code").first() {
                let language = (try? code.attr("class"))?.replacingOccurrences(of: "language-", with: "") ?? ""
                return "```\(language)\n\(code.text())\n```"
            }
            return "```\n\(element.text())\n```"
        case "table":
            return convertTableToMarkdown(element)
        case "hr":
            return "---"
        default:
            // 递归处理子元素
            return element.children().map { convertElementToMarkdown($0) }.joined(separator: "")
        }
    }
}
```

#### 4.3.2 资源文件管理

```swift
struct Resource {
    enum ResourceType {
        case image
        case stylesheet
        case script
        case font
        case other
    }
    
    let type: ResourceType
    let originalPath: String
    let absoluteURL: URL
    var newPath: String?  // 复制后的新路径
}

actor ResourceManager {
    /// 复制资源文件到笔记目录
    func copyResources(
        _ resources: [Resource],
        to noteId: String,
        notaFileManager: NotaFileManagerProtocol
    ) async throws -> [String: String] {
        // resourceMap: [原始路径: 新路径]
        var resourceMap: [String: String] = [:]
        
        // 获取笔记目录
        let noteDirectory = try await notaFileManager.getNoteDirectory(for: noteId)
        let assetsDirectory = noteDirectory.appendingPathComponent("assets")
        
        // 创建 assets 目录
        try FileManager.default.createDirectory(
            at: assetsDirectory,
            withIntermediateDirectories: true
        )
        
        // 复制每个资源文件
        for resource in resources {
            // 跳过网络 URL
            guard resource.absoluteURL.scheme == "file" || resource.absoluteURL.scheme == nil else {
                continue
            }
            
            // 检查源文件是否存在
            guard FileManager.default.fileExists(atPath: resource.absoluteURL.path) else {
                print("⚠️ [HTML-IMPORT] 资源文件不存在: \(resource.absoluteURL.path)")
                continue
            }
            
            // 生成目标文件名（处理冲突）
            let fileName = resource.absoluteURL.lastPathComponent
            var destinationURL = assetsDirectory.appendingPathComponent(fileName)
            
            // 如果文件已存在，添加序号
            var counter = 1
            while FileManager.default.fileExists(atPath: destinationURL.path) {
                let nameWithoutExt = (fileName as NSString).deletingPathExtension
                let ext = (fileName as NSString).pathExtension
                let newFileName = "\(nameWithoutExt)_\(counter).\(ext)"
                destinationURL = assetsDirectory.appendingPathComponent(newFileName)
                counter += 1
            }
            
            // 复制文件
            try FileManager.default.copyItem(at: resource.absoluteURL, to: destinationURL)
            
            // 记录路径映射
            let newRelativePath = "assets/\(destinationURL.lastPathComponent)"
            resourceMap[resource.originalPath] = newRelativePath
            
            print("✅ [HTML-IMPORT] 已复制资源: \(resource.originalPath) → \(newRelativePath)")
        }
        
        return resourceMap
    }
}
```

#### 4.3.3 路径更新

```swift
extension HTMLConverter {
    /// 更新 Markdown 中的资源路径
    func updateResourcePaths(in markdown: String, resourceMap: [String: String]) -> String {
        var result = markdown
        
        // 更新图片路径：![alt](old_path) → ![alt](new_path)
        let imagePattern = #"!\[([^\]]*)\]\(([^)]+)\)"#
        if let regex = try? NSRegularExpression(pattern: imagePattern, options: []) {
            let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
            
            for match in matches.reversed() {
                guard match.numberOfRanges >= 3,
                      let altRange = Range(match.range(at: 1), in: result),
                      let pathRange = Range(match.range(at: 2), in: result) else {
                    continue
                }
                
                let alt = String(result[altRange])
                let oldPath = String(result[pathRange])
                
                // 查找新路径
                if let newPath = resourceMap[oldPath] {
                    let newImage = "![\(alt)](\(newPath))"
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(fullRange, with: newImage)
                }
            }
        }
        
        // 更新链接路径：[text](old_path) → [text](new_path)（仅限相对路径）
        let linkPattern = #"\[([^\]]+)\]\(([^)]+)\)"#
        if let regex = try? NSRegularExpression(pattern: linkPattern, options: []) {
            let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
            
            for match in matches.reversed() {
                guard match.numberOfRanges >= 3,
                      let textRange = Range(match.range(at: 1), in: result),
                      let pathRange = Range(match.range(at: 2), in: result) else {
                    continue
                }
                
                let text = String(result[textRange])
                let oldPath = String(result[pathRange])
                
                // 只更新相对路径（非 http/https）
                if !oldPath.hasPrefix("http://") && !oldPath.hasPrefix("https://") {
                    if let newPath = resourceMap[oldPath] {
                        let newLink = "[\(text)](\(newPath))"
                        let fullRange = Range(match.range, in: result)!
                        result.replaceSubrange(fullRange, with: newLink)
                    }
                }
            }
        }
        
        return result
    }
}
```

#### 4.3.4 导入服务扩展

```swift
extension ImportServiceImpl {
    /// 导入 HTML 文件
    func importHTMLFile(from url: URL) async throws -> Note {
        // 1. 检查文件扩展名
        guard url.pathExtension.lowercased() == "html" || url.pathExtension.lowercased() == "htm" else {
            throw ImportServiceError.invalidFileType
        }
        
        // 2. 读取 HTML 内容
        guard let htmlContent = try? String(contentsOf: url, encoding: .utf8) else {
            throw ImportServiceError.fileReadFailed
        }
        
        // 3. 转换 HTML 为 Markdown
        let converter = HTMLConverter()
        let baseURL = url.deletingLastPathComponent()
        let (markdown, resources) = try await converter.convertToMarkdown(
            html: htmlContent,
            baseURL: baseURL
        )
        
        // 4. 提取标题
        let title = try await converter.extractTitle(from: htmlContent) ?? url.deletingPathExtension().lastPathComponent
        
        // 5. 创建笔记
        let noteId = UUID().uuidString
        var note = Note(
            noteId: noteId,
            title: title,
            content: markdown,
            created: Date(),
            updated: Date()
        )
        
        // 6. 复制资源文件
        let resourceManager = ResourceManager()
        let resourceMap = try await resourceManager.copyResources(
            resources,
            to: noteId,
            notaFileManager: notaFileManager
        )
        
        // 7. 更新 Markdown 中的资源路径
        let updatedMarkdown = await converter.updateResourcePaths(
            in: markdown,
            resourceMap: resourceMap
        )
        note = Note(
            noteId: note.noteId,
            title: note.title,
            content: updatedMarkdown,
            created: note.created,
            updated: note.updated,
            isStarred: note.isStarred,
            isPinned: note.isPinned,
            isDeleted: note.isDeleted,
            tags: note.tags,
            checksum: note.checksum
        )
        
        // 8. 保存笔记
        return try await createAndSaveNote(note)
    }
    
    /// 导入 HTML 文件夹
    func importHTMLFolder(from url: URL) async throws -> [Note] {
        var notes: [Note] = []
        
        // 递归查找所有 HTML 文件
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        
        var htmlFiles: [URL] = []
        while let fileURL = enumerator?.nextObject() as? URL {
            let ext = fileURL.pathExtension.lowercased()
            if ext == "html" || ext == "htm" {
                htmlFiles.append(fileURL)
            }
        }
        
        // 导入每个 HTML 文件
        for htmlFile in htmlFiles {
            do {
                let note = try await importHTMLFile(from: htmlFile)
                notes.append(note)
            } catch {
                print("❌ [HTML-IMPORT] 导入失败 \(htmlFile.lastPathComponent): \(error)")
                // 继续处理其他文件
            }
        }
        
        return notes
    }
}
```

### 4.4 UI 更新

#### 4.4.1 ImportView 更新

```swift
// 在 ImportView.swift 中更新文件选择器
private func selectFilesToImport() {
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = true
    panel.canChooseDirectories = true  // 允许选择文件夹
    panel.canChooseFiles = true
    panel.allowedContentTypes = [
        .init(filenameExtension: "nota")!,
        .init(filenameExtension: "md")!,
        .init(filenameExtension: "html")!,  // 新增
        .init(filenameExtension: "htm")!     // 新增
    ]
    panel.message = "选择要导入的笔记文件或 HTML 文件"
    
    panel.begin { response in
        if response == .OK {
            // 区分文件和文件夹
            var fileURLs: [URL] = []
            var folderURLs: [URL] = []
            
            for url in panel.urls {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
                   isDirectory.boolValue {
                    folderURLs.append(url)
                } else {
                    fileURLs.append(url)
                }
            }
            
            // 发送导入请求
            store.send(.importFiles(fileURLs, folders: folderURLs))
        }
    }
}
```

#### 4.4.2 ImportFeature 更新

```swift
// 在 ImportFeature.swift 中添加新的 Action
enum Action: BindableAction {
    // ... existing actions ...
    case importFiles([URL], folders: [URL])  // 更新：支持文件夹
    case importHTMLFile(URL)
    case importHTMLFolder(URL)
}
```

---

## 5. 实施计划

### 5.1 阶段划分

#### 阶段 1：基础功能（P0）
- [ ] 添加 SwiftSoup 依赖
- [ ] 实现 HTMLConverter 基础类
- [ ] 实现 HTML 转 Markdown 转换（基本元素）
- [ ] 实现单 HTML 文件导入
- [ ] 更新 ImportService 协议和实现
- [ ] 更新 ImportView UI

**预估工时**：12 小时

#### 阶段 2：资源处理（P0）
- [ ] 实现资源文件识别和提取
- [ ] 实现资源文件复制逻辑
- [ ] 实现路径更新逻辑
- [ ] 测试资源文件处理

**预估工时**：8 小时

#### 阶段 3：文件夹导入（P1）
- [ ] 实现文件夹递归查找 HTML
- [ ] 实现批量导入逻辑
- [ ] 更新进度显示
- [ ] 测试批量导入

**预估工时**：4 小时

#### 阶段 4：优化和测试（P1）
- [ ] 处理边界情况（无效 HTML、缺失资源等）
- [ ] 性能优化
- [ ] 单元测试
- [ ] 集成测试

**预估工时**：6 小时

**总预估工时**：30 小时

### 5.2 依赖添加

在 `Package.swift` 中添加 SwiftSoup 依赖：

```swift
dependencies: [
    // ... existing dependencies ...
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0")
],
targets: [
    .target(
        name: "Nota4",
        dependencies: [
            // ... existing dependencies ...
            .product(name: "SwiftSoup", package: "SwiftSoup")
        ]
    )
]
```

---

## 6. 测试计划

### 6.1 单元测试

#### 6.1.1 HTML 转换测试

```swift
func testHTMLToMarkdownConversion() {
    let html = """
    <h1>标题</h1>
    <p>这是一个<strong>粗体</strong>段落。</p>
    <img src="image.png" alt="图片">
    """
    
    let converter = HTMLConverter()
    let (markdown, _) = try await converter.convertToMarkdown(html: html, baseURL: testURL)
    
    XCTAssertTrue(markdown.contains("# 标题"))
    XCTAssertTrue(markdown.contains("**粗体**"))
    XCTAssertTrue(markdown.contains("![图片](image.png)"))
}
```

#### 6.1.2 资源提取测试

```swift
func testResourceExtraction() {
    let html = """
    <html>
    <head>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <img src="images/logo.png" alt="Logo">
        <script src="scripts/app.js"></script>
    </body>
    </html>
    """
    
    let converter = HTMLConverter()
    let (_, resources) = try await converter.convertToMarkdown(html: html, baseURL: testURL)
    
    XCTAssertEqual(resources.count, 3)
    XCTAssertTrue(resources.contains { $0.type == .image && $0.originalPath == "images/logo.png" })
    XCTAssertTrue(resources.contains { $0.type == .stylesheet && $0.originalPath == "style.css" })
    XCTAssertTrue(resources.contains { $0.type == .script && $0.originalPath == "scripts/app.js" })
}
```

### 6.2 集成测试

#### 6.2.1 单文件导入测试

1. 准备测试 HTML 文件（包含图片引用）
2. 执行导入
3. 验证：
   - 笔记已创建
   - Markdown 内容正确
   - 图片文件已复制
   - 图片路径已更新

#### 6.2.2 文件夹导入测试

1. 准备测试文件夹（HTML + 资源文件夹）
2. 执行导入
3. 验证：
   - 所有 HTML 文件已导入
   - 资源文件已复制
   - 路径引用正确

### 6.3 边界情况测试

- 无效 HTML 文件
- 缺失资源文件
- 网络 URL 资源
- 超大 HTML 文件
- 嵌套文件夹结构
- 特殊字符文件名

---

## 7. 风险评估

### 7.1 技术风险

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|---------|
| HTML 解析失败 | 高 | 中 | 使用成熟的 SwiftSoup 库，添加错误处理 |
| 转换质量不佳 | 中 | 中 | 逐步完善转换规则，支持用户手动调整 |
| 资源路径解析错误 | 中 | 中 | 完善的路径解析逻辑，支持多种路径格式 |
| 性能问题（大文件） | 低 | 低 | 异步处理，显示进度 |

### 7.2 用户体验风险

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|---------|
| 转换后格式丢失 | 中 | 中 | 提供预览功能，允许用户调整 |
| 资源文件缺失 | 中 | 中 | 清晰的错误提示，支持手动添加资源 |
| 导入速度慢 | 低 | 低 | 显示进度，支持后台处理 |

---

## 8. 后续优化

### 8.1 功能增强（P2）

- **CSS 样式保留**：提取内联样式和外部 CSS，转换为 Markdown 的 HTML 块
- **JavaScript 处理**：提取并保留 JavaScript 代码（作为代码块）
- **表格优化**：改进复杂表格的 Markdown 转换
- **列表嵌套**：支持多级嵌套列表的准确转换

### 8.2 用户体验优化

- **导入预览**：导入前显示转换预览
- **选择性导入**：允许用户选择导入哪些资源文件
- **导入模板**：支持自定义导入规则和转换模板
- **批量重命名**：导入后批量重命名笔记

---

## 9. 验收标准

### 9.1 功能验收

- [ ] 可以导入单个 HTML 文件
- [ ] 可以导入包含 HTML 的文件夹
- [ ] HTML 内容正确转换为 Markdown
- [ ] 资源文件（图片、CSS、JS）正确复制
- [ ] Markdown 中的资源路径正确更新
- [ ] 支持批量导入多个 HTML 文件
- [ ] 导入进度正确显示
- [ ] 错误情况有清晰的提示

### 9.2 质量验收

- [ ] 单元测试覆盖率 > 80%
- [ ] 集成测试通过
- [ ] 性能测试通过（单文件 < 2s，批量导入有进度显示）
- [ ] 边界情况测试通过

---

## 10. 参考资料

- [SwiftSoup GitHub](https://github.com/scinfu/SwiftSoup)
- [HTML to Markdown 转换规范](https://daringfireball.net/projects/markdown/)
- [Nota4 导入导出功能文档](./IMPORT_EXPORT_ENHANCEMENT_PRD.md)

---

**文档版本历史**：
- v1.0 (2025-11-21): 初始版本


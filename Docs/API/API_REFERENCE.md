# Nota4 API 参考文档

**文档版本**: v1.1.1  
**创建日期**: 2025-11-19 08:26:02  
**最后更新**: 2025-11-19 08:26:02  
**目标读者**: 开发者、API 使用者

---

## 📋 目录

- [1. 概述](#1-概述)
- [2. 数据结构](#2-数据结构)
- [3. 服务接口](#3-服务接口)
- [4. 错误处理](#4-错误处理)
- [5. 使用示例](#5-使用示例)

---

## 1. 概述

### 1.1 API 架构

Nota4 采用 Protocol-Oriented Programming (POP) 设计，所有服务接口通过 Protocol 定义，支持依赖注入和 Mock 测试。

### 1.2 接口分类

| 分类 | 接口 | 位置 |
|------|------|------|
| **数据访问** | NoteRepositoryProtocol | Services/NoteRepository.swift |
| **文件管理** | NotaFileManagerProtocol | Services/NotaFileManager.swift |
| **图片管理** | ImageManagerProtocol | Services/ImageManager.swift |
| **导入服务** | ImportServiceProtocol | Services/ImportService.swift |
| **导出服务** | ExportServiceProtocol | Services/ExportService.swift |
| **主题管理** | ThemeManagerProtocol | Services/ThemeManager.swift |
| **Markdown 渲染** | MarkdownRenderer | Services/MarkdownRenderer.swift |

---

## 2. 数据结构

### 2.1 Note (笔记)

```swift
struct Note: Codable, Identifiable, Equatable, Hashable {
    /// 数据库主键（自增）
    var id: Int64?
    
    /// UUID，唯一标识（文件名）
    let noteId: String
    
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
}
```

**字段说明**:
- `id`: 数据库自增主键，新建时为 `nil`
- `noteId`: 业务主键，UUID 字符串，用于文件名
- `tags`: `Set<String>` 类型，保证标签唯一性
- `checksum`: 可选，用于文件变更检测

**计算属性**:
- `preview: String` - 预览文本（前 100 个字符）
- `fileName: String` - 文件名（`{noteId}.nota`）

### 2.2 EditorPreferences (编辑器偏好设置)

```swift
struct EditorPreferences: Codable, Equatable {
    // 字体设置
    var titleFontName: String = "System"
    var titleFontSize: CGFloat = 24
    var bodyFontName: String = "System"
    var bodyFontSize: CGFloat = 17
    var codeFontName: String = "Menlo"
    var codeFontSize: CGFloat = 14
    
    // 排版设置
    var lineSpacing: CGFloat = 6
    var paragraphSpacing: CGFloat = 0.8
    var maxWidth: CGFloat = 800
    
    // 布局设置
    var horizontalPadding: CGFloat = 24
    var verticalPadding: CGFloat = 20
    var alignment: Alignment = .center
    
    enum Alignment: String, Codable, CaseIterable {
        case leading = "左对齐"
        case center = "居中"
    }
}
```

### 2.3 ThemeConfig (主题配置)

```swift
struct ThemeConfig: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let displayName: String
    let author: String?
    let version: String
    let description: String?
    let cssFileName: String
    let codeHighlightTheme: CodeTheme
    let mermaidTheme: String
    let colors: ThemeColors?
    let fonts: ThemeFonts?
    let createdAt: Date
    let updatedAt: Date
}

struct ThemeColors: Codable, Equatable {
    var primaryColor: String
    var backgroundColor: String
    var textColor: String
    var secondaryTextColor: String
    var linkColor: String
    var codeBackgroundColor: String
    var borderColor: String
    var accentColor: String
}

enum CodeTheme: String, Codable, Equatable, CaseIterable {
    case xcode = "xcode"
    case github = "github"
    case monokai = "monokai"
    case dracula = "dracula"
    case solarizedLight = "solarized-light"
    case solarizedDark = "solarized-dark"
}
```

### 2.4 ExportOptions (导出选项)

```swift
struct HTMLExportOptions: Equatable, Codable {
    var themeId: String?
    var includeTOC: Bool = false
    var imageHandling: ImageHandling = .base64
}

struct PDFExportOptions: Equatable, Codable {
    var themeId: String?
    var includeTOC: Bool = false
    var paperSize: NSSize
    var margin: CGFloat = 72.0
}

struct PNGExportOptions: Equatable, Codable {
    var themeId: String?
    var includeTOC: Bool = false
    var width: CGFloat = 1200
    var backgroundColor: String? = nil
}

enum ImageHandling: String, Equatable, Codable {
    case base64        // 内嵌为 Base64
    case relativePath  // 相对路径
    case absolutePath  // 绝对路径
}
```

---

## 3. 服务接口

### 3.1 NoteRepositoryProtocol (笔记仓库)

**位置**: `Services/NoteRepository.swift`

**接口定义**:

```swift
protocol NoteRepositoryProtocol {
    // MARK: - CRUD 操作
    
    /// 创建笔记
    func createNote(_ note: Note) async throws
    
    /// 根据 ID 获取笔记
    func fetchNote(byId noteId: String) async throws -> Note
    
    /// 获取笔记列表（支持过滤）
    func fetchNotes(filter: NoteListFeature.State.Filter) async throws -> [Note]
    
    /// 更新笔记
    func updateNote(_ note: Note) async throws
    
    /// 删除笔记（软删除）
    func deleteNote(byId noteId: String) async throws
    
    // MARK: - 批量操作
    
    /// 批量删除笔记
    func deleteNotes(_ noteIds: Set<String>) async throws
    
    /// 恢复笔记
    func restoreNotes(_ noteIds: Set<String>) async throws
    
    /// 永久删除笔记
    func permanentlyDeleteNotes(_ noteIds: Set<String>) async throws
    
    // MARK: - 标签操作
    
    /// 获取所有标签及其计数
    func fetchAllTags() async throws -> [SidebarFeature.State.Tag]
    
    // MARK: - 统计
    
    /// 获取笔记总数
    func getTotalCount() async throws -> Int
}
```

**实现类**: `NoteRepositoryImpl` (Actor)

**使用示例**:

```swift
let repository: NoteRepositoryProtocol = NoteRepository.shared

// 创建笔记
let note = Note(
    noteId: UUID().uuidString,
    title: "新笔记",
    content: "# 标题\n\n内容"
)
try await repository.createNote(note)

// 获取笔记
let fetchedNote = try await repository.fetchNote(byId: note.noteId)

// 更新笔记
var updatedNote = fetchedNote
updatedNote.title = "更新后的标题"
try await repository.updateNote(updatedNote)

// 删除笔记
try await repository.deleteNote(byId: note.noteId)
```

### 3.2 NotaFileManagerProtocol (文件管理)

**位置**: `Services/NotaFileManager.swift`

**接口定义**:

```swift
protocol NotaFileManagerProtocol {
    /// 创建笔记文件
    func createNoteFile(_ note: Note) async throws
    
    /// 读取笔记文件
    func readNoteFile(noteId: String) async throws -> String
    
    /// 更新笔记文件
    func updateNoteFile(_ note: Note) async throws
    
    /// 删除笔记文件
    func deleteNoteFile(noteId: String) async throws
    
    /// 获取笔记目录
    func getNoteDirectory(for noteId: String) async throws -> URL
}
```

**实现类**: `NotaFileManagerImpl` (Actor)

**文件结构**:
```
NotaLibrary/
├── notes/
│   └── {noteId}.nota
├── trash/
│   └── {noteId}.nota
└── attachments/
    └── {noteId}/
        └── {imageId}.png
```

### 3.3 ImageManagerProtocol (图片管理)

**位置**: `Services/ImageManager.swift`

**接口定义**:

```swift
protocol ImageManagerProtocol {
    /// 复制图片到笔记附件目录
    /// - Returns: 图片 ID（用于 Markdown 引用）
    func copyImage(from sourceURL: URL, to noteId: String) async throws -> String
    
    /// 删除笔记的所有图片
    func deleteImages(forNote noteId: String) async throws
    
    /// 获取图片 URL
    func getImageURL(noteId: String, imageId: String) -> URL
}
```

**使用示例**:

```swift
let imageManager: ImageManagerProtocol = ImageManager.shared

// 复制图片
let imageId = try await imageManager.copyImage(
    from: sourceURL,
    to: note.noteId
)

// 在 Markdown 中引用
let imageMarkdown = "![Image](attachments/\(imageId))"

// 获取图片 URL
let imageURL = imageManager.getImageURL(
    noteId: note.noteId,
    imageId: imageId
)
```

### 3.4 ImportServiceProtocol (导入服务)

**位置**: `Services/ImportService.swift`

**接口定义**:

```swift
protocol ImportServiceProtocol {
    /// 导入 .nota 文件
    func importNotaFile(from url: URL) async throws -> Note
    
    /// 导入 .md 文件
    func importMarkdownFile(from url: URL) async throws -> Note
    
    /// 批量导入文件
    func importMultipleFiles(from urls: [URL]) async throws -> [Note]
}
```

**支持格式**:
- `.nota` - Nota4 专有格式（包含 YAML Front Matter）
- `.md`, `.markdown` - Markdown 格式

**使用示例**:

```swift
let importService: ImportServiceProtocol = ImportService.shared

// 导入单个文件
let note = try await importService.importNotaFile(from: fileURL)

// 批量导入
let notes = try await importService.importMultipleFiles(from: fileURLs)
```

### 3.5 ExportServiceProtocol (导出服务)

**位置**: `Services/ExportService.swift`

**接口定义**:

```swift
protocol ExportServiceProtocol {
    /// 导出为 .nota 格式
    func exportAsNota(note: Note, to url: URL) async throws
    
    /// 导出为 Markdown 格式
    func exportAsMarkdown(
        note: Note,
        to url: URL,
        includeMetadata: Bool
    ) async throws
    
    /// 导出为 HTML 格式
    func exportAsHTML(
        note: Note,
        to url: URL,
        options: HTMLExportOptions
    ) async throws
    
    /// 导出为 PDF 格式
    func exportAsPDF(
        note: Note,
        to url: URL,
        options: PDFExportOptions
    ) async throws
    
    /// 导出为 PNG 格式
    func exportAsPNG(
        note: Note,
        to url: URL,
        options: PNGExportOptions
    ) async throws
    
    /// 批量导出
    func exportMultipleNotes(
        notes: [Note],
        to directoryURL: URL,
        format: Services.ExportFormat
    ) async throws
}
```

**使用示例**:

```swift
let exportService: ExportServiceProtocol = ExportService.shared

// 导出为 HTML
try await exportService.exportAsHTML(
    note: note,
    to: outputURL,
    options: HTMLExportOptions(
        themeId: "light",
        includeTOC: true,
        imageHandling: .base64
    )
)

// 导出为 PDF
try await exportService.exportAsPDF(
    note: note,
    to: outputURL,
    options: PDFExportOptions(
        themeId: "light",
        includeTOC: true,
        paperSize: .a4Size,
        margin: 72.0
    )
)
```

### 3.6 ThemeManagerProtocol (主题管理)

**位置**: `Services/ThemeManager.swift`

**接口定义**:

```swift
protocol ThemeManagerProtocol {
    /// 获取所有可用主题
    func getAllThemes() async throws -> [ThemeConfig]
    
    /// 根据 ID 获取主题
    func getTheme(byId id: String) async throws -> ThemeConfig
    
    /// 获取当前主题
    func getCurrentTheme() async throws -> ThemeConfig
    
    /// 设置当前主题
    func setCurrentTheme(_ themeId: String) async throws
    
    /// 加载主题 CSS
    func loadThemeCSS(themeId: String) async throws -> String
}
```

### 3.7 MarkdownRenderer (Markdown 渲染)

**位置**: `Services/MarkdownRenderer.swift`

**接口定义**:

```swift
class MarkdownRenderer {
    /// 渲染 Markdown 为 HTML
    func render(
        markdown: String,
        themeId: String?,
        codeTheme: CodeTheme?,
        mermaidTheme: String?
    ) async throws -> String
    
    /// 渲染预览 HTML（包含完整页面结构）
    func renderPreview(
        markdown: String,
        themeId: String?,
        codeTheme: CodeTheme?,
        mermaidTheme: String?
    ) async throws -> String
}
```

**使用示例**:

```swift
let renderer = MarkdownRenderer()

// 渲染 HTML
let html = try await renderer.render(
    markdown: note.content,
    themeId: "light",
    codeTheme: .github,
    mermaidTheme: "default"
)

// 渲染预览
let previewHTML = try await renderer.renderPreview(
    markdown: note.content,
    themeId: "light",
    codeTheme: .github,
    mermaidTheme: "default"
)
```

---

## 4. 错误处理

### 4.1 错误类型

#### RepositoryError

```swift
enum RepositoryError: LocalizedError, Equatable {
    case noteNotFound(String)
    case databaseError(String)
    case invalidFilter
}
```

#### ImportServiceError

```swift
enum ImportServiceError: LocalizedError, Equatable {
    case invalidFileType
    case fileReadFailed
    case yamlParsingFailed
    case noteCreationFailed
    case conflictDetected(noteId: String)
}
```

#### ExportServiceError

```swift
enum ExportServiceError: LocalizedError, Equatable {
    case invalidURL
    case fileWriteFailed
    case yamlSerializationFailed
    case permissionDenied
}
```

#### ThemeError

```swift
enum ThemeError: LocalizedError {
    case themeNotFound(String)
    case themeAlreadyExists(String)
    case cssFileNotFound(String)
    case invalidThemePackage
    case cannotDeleteBuiltInTheme
    case cannotExportBuiltInTheme
}
```

### 4.2 错误处理模式

```swift
do {
    let note = try await repository.fetchNote(byId: noteId)
    // 处理成功
} catch RepositoryError.noteNotFound(let id) {
    // 处理笔记未找到
    print("Note not found: \(id)")
} catch RepositoryError.databaseError(let message) {
    // 处理数据库错误
    print("Database error: \(message)")
} catch {
    // 处理其他错误
    print("Unexpected error: \(error)")
}
```

---

## 5. 使用示例

### 5.1 创建并保存笔记

```swift
// 1. 创建笔记对象
let note = Note(
    noteId: UUID().uuidString,
    title: "新笔记",
    content: "# 标题\n\n这是内容",
    tags: ["工作", "重要"]
)

// 2. 保存到数据库
try await repository.createNote(note)

// 3. 保存到文件系统
try await fileManager.createNoteFile(note)
```

### 5.2 搜索笔记

```swift
// 使用 FTS5 全文搜索
let filter = NoteListFeature.State.Filter.search(keyword: "Swift")
let notes = try await repository.fetchNotes(filter: filter)
```

### 5.3 批量导出

```swift
// 获取所有笔记
let allNotes = try await repository.fetchNotes(filter: .category(.all))

// 批量导出为 HTML
let exportFormat = Services.ExportFormat.html(
    options: HTMLExportOptions(
        themeId: "light",
        includeTOC: true
    )
)
try await exportService.exportMultipleNotes(
    notes: allNotes,
    to: outputDirectory,
    format: exportFormat
)
```

### 5.4 在 TCA Feature 中使用

```swift
struct EditorFeature: Reducer {
    @Dependency(\.noteRepository) var noteRepository
    @Dependency(\.notaFileManager) var fileManager
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        case .save:
            return .run { [note = state.note] send in
                do {
                    // 更新数据库
                    try await noteRepository.updateNote(note)
                    
                    // 更新文件
                    try await fileManager.updateNoteFile(note)
                    
                    await send(.saveCompleted(.success(note)))
                } catch {
                    await send(.saveCompleted(.failure(error)))
                }
            }
    }
}
```

---

## 附录

### A. 依赖注入

所有服务通过 TCA Dependencies 系统注入：

```swift
extension DependencyValues {
    var noteRepository: NoteRepositoryProtocol {
        get { self[NoteRepositoryKey.self] }
        set { self[NoteRepositoryKey.self] = newValue }
    }
}
```

### B. Mock 实现

所有服务都提供 Mock 实现用于测试：

```swift
// 测试中使用 Mock
let mockRepository = NoteRepository.mock
let store = TestStore(initialState: State()) {
    EditorFeature()
} withDependencies: {
    $0.noteRepository = mockRepository
}
```

### C. 参考资料

- [TCA Dependencies](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/dependencymanagement/)
- [GRDB 文档](https://github.com/groue/GRDB.swift)
- [Swift Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)

---

**文档维护者**: Nota4 开发团队  
**最后审核**: 2025-11-19  
**文档状态**: ✅ 活跃维护中


# 🔌 API 文档

本目录存放 Nota4 的 API 接口文档、数据结构和文件格式规范。

---

## 📂 文档列表

| 文档 | 描述 | 更新日期 |
|------|------|---------|
| [API_REFERENCE.md](./API_REFERENCE.md) | API 参考文档（数据结构和接口） | 2025-11-19 |
| [FILE_FORMAT_SPEC.md](./FILE_FORMAT_SPEC.md) | 文件格式规范 (.nota) | 2025-11-19 |

---

## 📝 文档说明

### API_REFERENCE.md - API 参考文档

**内容包含**:
- 数据结构定义（Note, EditorPreferences, ThemeConfig, ExportOptions）
- 服务接口定义（NoteRepository, NotaFileManager, ImportService, ExportService 等）
- 错误处理
- 使用示例

**适用场景**:
- 开发新功能时参考接口
- 理解数据模型和服务接口
- 编写测试代码

### FILE_FORMAT_SPEC.md - 文件格式规范

**内容包含**:
- .nota 文件格式规范
- YAML Front Matter 元数据规范
- Markdown 内容规范
- 解析和生成规则
- 兼容性说明

**适用场景**:
- 开发格式解析器
- 实现导入/导出功能
- 与其他工具集成

---

## 🎯 核心接口

### 数据访问层

#### NoteRepositoryProtocol
**位置**: `Services/NoteRepository.swift`

**主要方法**:
- `createNote(_:)` - 创建笔记
- `fetchNote(byId:)` - 根据 ID 获取笔记
- `fetchNotes(filter:)` - 获取笔记列表（支持过滤）
- `updateNote(_:)` - 更新笔记
- `deleteNote(byId:)` - 删除笔记（软删除）
- `deleteNotes(_:)` - 批量删除
- `restoreNotes(_:)` - 恢复笔记
- `permanentlyDeleteNotes(_:)` - 永久删除
- `fetchAllTags()` - 获取所有标签
- `getTotalCount()` - 获取笔记总数

#### NotaFileManagerProtocol
**位置**: `Services/NotaFileManager.swift`

**主要方法**:
- `createNoteFile(_:)` - 创建笔记文件
- `readNoteFile(noteId:)` - 读取笔记文件
- `updateNoteFile(_:)` - 更新笔记文件
- `deleteNoteFile(noteId:)` - 删除笔记文件
- `getNoteDirectory(for:)` - 获取笔记目录

### 业务服务层

#### ImportServiceProtocol
**位置**: `Services/ImportService.swift`

**主要方法**:
- `importNotaFile(from:)` - 导入 .nota 文件
- `importMarkdownFile(from:)` - 导入 .md 文件
- `importMultipleFiles(from:)` - 批量导入

**支持格式**: `.nota`, `.md`, `.markdown`, `.txt`

#### ExportServiceProtocol
**位置**: `Services/ExportService.swift`

**主要方法**:
- `exportAsNota(note:to:)` - 导出为 .nota
- `exportAsMarkdown(note:to:includeMetadata:)` - 导出为 .md
- `exportAsHTML(note:to:options:)` - 导出为 .html
- `exportAsPDF(note:to:options:)` - 导出为 .pdf
- `exportAsPNG(note:to:options:)` - 导出为 .png
- `exportMultipleNotes(notes:to:format:)` - 批量导出

**支持格式**: `.nota`, `.md`, `.txt`, `.html`, `.pdf`, `.png`

#### ImageManagerProtocol
**位置**: `Services/ImageManager.swift`

**主要方法**:
- `copyImage(from:to:)` - 复制图片到笔记附件目录
- `deleteImages(forNote:)` - 删除笔记的所有图片
- `getImageURL(noteId:imageId:)` - 获取图片 URL

#### ThemeManagerProtocol
**位置**: `Services/ThemeManager.swift`

**主要方法**:
- `getAllThemes()` - 获取所有可用主题
- `getTheme(byId:)` - 根据 ID 获取主题
- `getCurrentTheme()` - 获取当前主题
- `setCurrentTheme(_:)` - 设置当前主题
- `loadThemeCSS(themeId:)` - 加载主题 CSS

### 渲染服务层

#### MarkdownRenderer
**位置**: `Services/MarkdownRenderer.swift`

**主要方法**:
- `render(markdown:themeId:codeTheme:mermaidTheme:)` - 渲染 Markdown 为 HTML
- `renderPreview(markdown:themeId:codeTheme:mermaidTheme:)` - 渲染预览 HTML（完整页面）

**支持特性**:
- 标准 Markdown 语法
- 代码高亮（多种主题）
- 数学公式（LaTeX，通过 KaTeX）
- Mermaid 图表（流程图、时序图等）
- 表格、任务列表、脚注等扩展语法

---

## 📚 数据结构

### 核心数据模型

- **Note**: 笔记数据模型（id, noteId, title, content, created, updated, isStarred, isPinned, isDeleted, tags, checksum）
- **EditorPreferences**: 编辑器偏好设置（字体、行距、边距、对齐方式等）
- **ThemeConfig**: 主题配置（id, name, cssFileName, codeHighlightTheme, mermaidTheme, colors, fonts）
- **ExportOptions**: 导出选项（HTMLExportOptions, PDFExportOptions, PNGExportOptions）

### 文件格式

- **.nota 格式**: YAML Front Matter + Markdown 正文
- **元数据字段**: id, title, created, updated, starred, pinned, deleted, tags, checksum
- **兼容性**: 与标准 Markdown 完全兼容

详见: [FILE_FORMAT_SPEC.md](./FILE_FORMAT_SPEC.md)

---

## 💡 使用指南

### 在 TCA Feature 中使用

```swift
struct MyFeature: Reducer {
    @Dependency(\.noteRepository) var noteRepository
    @Dependency(\.notaFileManager) var fileManager
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        case .loadNote(let noteId):
            return .run { send in
                let note = try await noteRepository.fetchNote(byId: noteId)
                await send(.noteLoaded(note))
            }
    }
}
```

### 错误处理

所有服务接口都使用 `async throws`，需要正确处理错误：

```swift
do {
    let note = try await repository.fetchNote(byId: noteId)
    // 处理成功
} catch RepositoryError.noteNotFound(let id) {
    // 处理笔记未找到
} catch {
    // 处理其他错误
}
```

### Mock 实现

所有服务都提供 Mock 实现用于测试：

```swift
let store = TestStore(initialState: State()) {
    MyFeature()
} withDependencies: {
    $0.noteRepository = NoteRepository.mock
    $0.notaFileManager = NotaFileManager.mock
}
```

---

## 🔗 相关文档

- [系统架构设计规范](../Architecture/SYSTEM_ARCHITECTURE_SPEC.md) - 了解整体架构
- [系统架构文档](../Architecture/SYSTEM_ARCHITECTURE.md) - 架构详细说明
- [产品需求文档](../PRD/NOTA4_PRD.md) - 了解功能需求
- [功能文档](../Features/) - 功能模块文档

---

**最后更新**: 2025-11-19 08:26:02  
**维护者**: Nota4 开发团队  
返回 [文档中心](../README.md)


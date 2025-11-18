# Nota4 导出功能分析与规划（HTML/PDF/PNG）

**创建时间**: 2025-11-18 15:21:50  
**文档类型**: 功能分析与设计规划  
**适用范围**: Nota4 导出功能扩展（HTML/PDF/PNG）

---

## 📋 目录

- [1. 现有导出功能分析](#1-现有导出功能分析)
- [2. 导出交互入口规划](#2-导出交互入口规划)
- [3. HTML/PDF/PNG 导出需求](#3-htmlpdfpng-导出需求)
- [4. 技术方案设计](#4-技术方案设计)
- [5. TCA 状态管理设计](#5-tca-状态管理设计)
- [6. 实施计划](#6-实施计划)
- [7. 测试计划](#7-测试计划)

---

## 1. 现有导出功能分析

### 1.1 架构概览

Nota4 的导出功能采用 **TCA (The Composable Architecture)** 状态管理模式，分为三层：

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer                             │
│  ExportView.swift - 用户界面，文件选择器                 │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              TCA Feature Layer                          │
│  ExportFeature.swift - 状态管理与业务逻辑               │
│  - State: 导出状态、进度、格式选择                       │
│  - Action: 导出操作、进度更新、错误处理                  │
│  - Reducer: 状态转换与副作用处理                         │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              Service Layer                              │
│  ExportService.swift - 实际导出逻辑                      │
│  - exportAsNota()                                       │
│  - exportAsMarkdown()                                   │
│  - exportMultipleNotes()                                │
└─────────────────────────────────────────────────────────┘
```

### 1.2 现有实现细节

#### **1.2.1 ExportFeature (TCA Feature)**

**位置**: `Nota4/Nota4/Features/Export/ExportFeature.swift`

**状态定义**:
```swift
@ObservableState
struct State: Equatable {
    var notesToExport: [Note]           // 待导出的笔记列表
    var isExporting = false              // 是否正在导出
    var exportFormat: ExportFormat = .nota  // 导出格式
    var includeMetadata = true           // 是否包含元数据
    var errorMessage: String?           // 错误信息
    var exportProgress: Double = 0.0    // 导出进度 (0.0-1.0)
    var exportCompleted = false         // 是否完成
}
```

**导出格式枚举**:
```swift
enum ExportFormat: Equatable {
    case nota
    case markdown
    // TODO: 需要添加 html, pdf, png
}
```

**关键 Action**:
- `exportToDirectory(URL)` - 触发导出到指定目录
- `exportStarted` - 导出开始
- `exportProgress(Double)` - 进度更新
- `exportCompleted` - 导出完成
- `exportFailed(Error)` - 导出失败

**Reducer 逻辑**:
```swift
case .exportToDirectory(let url):
    state.isExporting = true
    state.errorMessage = nil
    state.exportProgress = 0.0
    
    return .run { send in
        await send(.exportStarted)
        // 模拟进度更新
        for i in 1...10 {
            try await mainQueue.sleep(for: .milliseconds(100))
            await send(.exportProgress(Double(i) / 10.0))
        }
        // 调用 ExportService
        try await exportService.exportMultipleNotes(...)
        await send(.exportCompleted)
    }
```

**优点**:
- ✅ 完全符合 TCA 状态管理模式
- ✅ 状态可追踪、可测试
- ✅ 支持进度追踪和错误处理
- ✅ 使用 `@Dependency` 注入服务，便于测试

**待扩展**:
- ⚠️ `ExportFormat` 枚举需要添加 `.html`, `.pdf`, `.png`
- ⚠️ 需要支持单文件导出（HTML/PDF/PNG 通常是单文件）

#### **1.2.2 ExportService (Service Layer)**

**位置**: `Nota4/Nota4/Services/ExportService.swift`

**协议定义**:
```swift
protocol ExportServiceProtocol {
    func exportAsNota(note: Note, to url: URL) async throws
    func exportAsMarkdown(note: Note, to url: URL, includeMetadata: Bool) async throws
    func exportMultipleNotes(notes: [Note], to directoryURL: URL, format: Services.ExportFormat) async throws
}
```

**Services.ExportFormat**:
```swift
enum Services {
    enum ExportFormat {
        case nota
        case markdown(includeMetadata: Bool)
        // TODO: 需要添加 html, pdf, png
    }
}
```

**实现特点**:
- ✅ 使用 `actor` 确保线程安全
- ✅ 支持批量导出
- ✅ 文件名清理（移除不安全字符）
- ✅ 错误处理完善

**待扩展**:
- ⚠️ 需要添加 `exportAsHTML()`, `exportAsPDF()`, `exportAsPNG()` 方法
- ⚠️ HTML/PDF/PNG 导出需要依赖 `MarkdownRenderer`

#### **1.2.3 MarkdownRenderer (HTML 生成)**

**位置**: `Nota4/Nota4/Services/MarkdownRenderer.swift`

**核心方法**:
```swift
func renderToHTML(
    markdown: String,
    options: RenderOptions = .default
) async throws -> String
```

**功能特性**:
- ✅ 完整的 Markdown → HTML 转换
- ✅ 支持代码高亮（Splash）
- ✅ 支持 Mermaid 图表
- ✅ 支持数学公式（KaTeX）
- ✅ 支持 TOC（目录）
- ✅ 支持主题切换
- ✅ 图片路径处理

**关键输出**:
- 返回完整的 HTML 文档（包含 `<head>`, CSS, JavaScript）
- HTML 可以直接用于预览或导出

**优势**:
- ✅ **可直接复用**：HTML 导出可以直接使用 `renderToHTML()`
- ✅ **PDF/PNG 基础**：PDF 和 PNG 可以从 HTML 转换而来

---

## 2. 导出交互入口规划

### 2.1 现有入口分析

#### **2.1.1 菜单栏入口**

**位置**: `Nota4/Nota4/App/Nota4App.swift`

**当前实现**:
```swift
Button("导出笔记...") {
    // 导出当前选中的笔记或所有笔记
    store.send(.showExport([]))  // ⚠️ 传入空数组
}
.keyboardShortcut("e", modifiers: [.command, .shift])
```

**问题**:
- ⚠️ 传入空数组，无法知道要导出哪些笔记
- ⚠️ 没有根据当前选中笔记来导出
- ⚠️ 菜单项文本不够明确（单文件 vs 批量）

#### **2.1.2 笔记列表右键菜单**

**位置**: `Nota4/Nota4/Features/NoteList/NoteListView.swift`

**当前实现**:
- ✅ 有 `contextMenu` 实现
- ❌ **缺少导出选项**

**右键菜单当前包含**:
- 打开
- 星标/取消星标
- 置顶/取消置顶
- 删除
- 批量操作（多选时）

#### **2.1.3 笔记列表工具栏**

**位置**: `Nota4/Nota4/Features/NoteList/NoteListToolbar.swift`

**当前实现**:
- ✅ 有工具栏实现
- ❌ **缺少导出按钮**

**工具栏当前包含**:
- 搜索按钮
- 新建笔记按钮
- 排序菜单

#### **2.1.4 编辑器工具栏**

**位置**: `Nota4/Nota4/Features/Editor/IndependentToolbar.swift`

**当前实现**:
- ✅ 有工具栏实现
- ❌ **缺少导出按钮**

---

### 2.2 导出入口设计原则

#### **2.2.1 入口分类**

根据导出场景，分为两类：

1. **单文件导出**（Single File Export）
   - 导出当前正在编辑的笔记
   - 导出单个选中的笔记
   - 使用文件保存对话框（`NSSavePanel`）
   - 支持选择文件名和保存位置

2. **批量导出**（Batch Export）
   - 导出多个选中的笔记
   - 使用目录选择对话框（`NSOpenPanel`）
   - 所有笔记导出到同一目录
   - 每个笔记生成一个文件

#### **2.2.2 入口位置规划**

| 入口位置 | 单文件导出 | 批量导出 | 优先级 |
|---------|-----------|---------|--------|
| **菜单栏** | ✅ | ✅ | P0 |
| **笔记列表右键菜单** | ✅ | ✅ | P0 |
| **笔记列表工具栏** | ❌ | ✅ | P1 |
| **编辑器工具栏** | ✅ | ❌ | P1 |
| **编辑器右键菜单** | ✅ | ❌ | P2 |

---

### 2.3 详细入口设计

#### **2.3.1 菜单栏入口（P0）**

**位置**: `Nota4/Nota4/App/Nota4App.swift`

**设计**:

```swift
CommandGroup(after: .newItem) {
    // ... 现有菜单项 ...
    
    Divider()
    
    // 单文件导出（当前笔记）
    if let currentNote = store.state.editor.note {
        Menu("导出当前笔记") {
            Button("导出为 .nota...") {
                store.send(.exportCurrentNote(format: .nota))
            }
            Button("导出为 .md...") {
                store.send(.exportCurrentNote(format: .markdown))
            }
            Button("导出为 .html...") {
                store.send(.exportCurrentNote(format: .html))
            }
            Button("导出为 .pdf...") {
                store.send(.exportCurrentNote(format: .pdf))
            }
            Button("导出为 .png...") {
                store.send(.exportCurrentNote(format: .png))
            }
        }
        .disabled(currentNote == nil)
    }
    
    // 批量导出（选中的笔记）
    Menu("导出选中笔记...") {
        Button("导出为 .nota...") {
            store.send(.exportSelectedNotes(format: .nota))
        }
        Button("导出为 .md...") {
            store.send(.exportSelectedNotes(format: .markdown))
        }
        Button("导出为 .html...") {
            store.send(.exportSelectedNotes(format: .html))
        }
        Button("导出为 .pdf...") {
            store.send(.exportSelectedNotes(format: .pdf))
        }
        Button("导出为 .png...") {
            store.send(.exportSelectedNotes(format: .png))
        }
    }
    .disabled(store.state.noteList.selectedNoteIds.isEmpty)
    
    // 通用导出入口（兼容现有）
    Button("导出笔记...") {
        let notes = getNotesToExport(from: store.state)
        store.send(.showExport(notes))
    }
    .keyboardShortcut("e", modifiers: [.command, .shift])
}
```

**逻辑**:
- 根据当前状态（是否有当前笔记、是否有选中笔记）动态显示菜单项
- 单文件导出：使用 `NSSavePanel` 选择保存位置
- 批量导出：使用 `NSOpenPanel` 选择目录
- 保留通用导出入口作为后备

#### **2.3.2 笔记列表右键菜单（P0）**

**位置**: `Nota4/Nota4/Features/NoteList/NoteListView.swift`

**设计**:

```swift
.contextMenu {
    // ... 现有菜单项 ...
    
    Divider()
    
    // 单文件导出（单个笔记）
    if !isBatchSelection {
        Menu("导出为...") {
            Button("导出为 .nota...") {
                store.send(.exportNote(note.noteId, format: .nota))
            }
            Button("导出为 .md...") {
                store.send(.exportNote(note.noteId, format: .markdown))
            }
            Button("导出为 .html...") {
                store.send(.exportNote(note.noteId, format: .html))
            }
            Button("导出为 .pdf...") {
                store.send(.exportNote(note.noteId, format: .pdf))
            }
            Button("导出为 .png...") {
                store.send(.exportNote(note.noteId, format: .png))
            }
        }
    } else {
        // 批量导出（多个笔记）
        Menu("批量导出为...") {
            Button("导出为 .nota...") {
                store.send(.exportNotes(selectedNotes, format: .nota))
            }
            Button("导出为 .md...") {
                store.send(.exportNotes(selectedNotes, format: .markdown))
            }
            Button("导出为 .html...") {
                store.send(.exportNotes(selectedNotes, format: .html))
            }
            Button("导出为 .pdf...") {
                store.send(.exportNotes(selectedNotes, format: .pdf))
            }
            Button("导出为 .png...") {
                store.send(.exportNotes(selectedNotes, format: .png))
            }
        }
    }
}
```

**逻辑**:
- 单个笔记：显示"导出为..."子菜单
- 多个笔记：显示"批量导出为..."子菜单
- 根据选中数量动态显示

#### **2.3.3 笔记列表工具栏（P1）**

**位置**: `Nota4/Nota4/Features/NoteList/NoteListToolbar.swift`

**设计**:

```swift
// 在工具栏中添加导出按钮（仅在有多选时显示）
if store.selectedNoteIds.count > 1 {
    Divider()
        .frame(height: 16)
    
    Menu {
        Button("导出为 .nota...") {
            store.send(.exportNotes(store.selectedNoteIds, format: .nota))
        }
        Button("导出为 .md...") {
            store.send(.exportNotes(store.selectedNoteIds, format: .markdown))
        }
        Button("导出为 .html...") {
            store.send(.exportNotes(store.selectedNoteIds, format: .html))
        }
        Button("导出为 .pdf...") {
            store.send(.exportNotes(store.selectedNoteIds, format: .pdf))
        }
        Button("导出为 .png...") {
            store.send(.exportNotes(store.selectedNoteIds, format: .png))
        }
    } label: {
        Image(systemName: "square.and.arrow.up")
            .font(.system(size: 16, weight: .regular))
            .frame(width: 32, height: 32)
    }
    .buttonStyle(.plain)
    .help("导出选中笔记")
}
```

**逻辑**:
- 仅在有多选笔记时显示
- 点击后显示格式选择菜单
- 使用下拉菜单，节省工具栏空间

#### **2.3.4 编辑器工具栏（P1）**

**位置**: `Nota4/Nota4/Features/Editor/IndependentToolbar.swift`

**设计**:

```swift
// 在编辑器工具栏中添加导出按钮
if store.note != nil {
    Menu {
        Button("导出为 .nota...") {
            store.send(.exportCurrentNote(format: .nota))
        }
        Button("导出为 .md...") {
            store.send(.exportCurrentNote(format: .markdown))
        }
        Button("导出为 .html...") {
            store.send(.exportCurrentNote(format: .html))
        }
        Button("导出为 .pdf...") {
            store.send(.exportCurrentNote(format: .pdf))
        }
        Button("导出为 .png...") {
            store.send(.exportCurrentNote(format: .png))
        }
    } label: {
        Image(systemName: "square.and.arrow.up")
    }
    .help("导出当前笔记")
}
```

**逻辑**:
- 仅在编辑笔记时显示
- 导出当前正在编辑的笔记
- 使用下拉菜单，节省工具栏空间

#### **2.3.5 编辑器右键菜单（P2）**

**位置**: `Nota4/Nota4/Features/Editor/EditorContextMenu.swift`

**设计**:

```swift
// 在编辑器右键菜单中添加导出选项
Divider()

Menu("导出为...") {
    Button("导出为 .nota...") {
        store.send(.exportCurrentNote(format: .nota))
    }
    Button("导出为 .md...") {
        store.send(.exportCurrentNote(format: .markdown))
    }
    Button("导出为 .html...") {
        store.send(.exportCurrentNote(format: .html))
    }
    Button("导出为 .pdf...") {
        store.send(.exportCurrentNote(format: .pdf))
    }
    Button("导出为 .png...") {
        store.send(.exportCurrentNote(format: .png))
    }
}
```

**逻辑**:
- 导出当前正在编辑的笔记
- 作为辅助入口，优先级较低

---

### 2.4 TCA Action 扩展

#### **2.4.1 AppFeature.Action 扩展**

**位置**: `Nota4/Nota4/App/AppFeature.swift`

```swift
enum Action {
    // ... 现有 Actions ...
    
    // 单文件导出
    case exportCurrentNote(format: ExportFormat)
    case exportNote(String, format: ExportFormat)  // noteId, format
    
    // 批量导出
    case exportSelectedNotes(format: ExportFormat)
    case exportNotes(Set<String>, format: ExportFormat)  // noteIds, format
    
    // 通用导出（保留兼容）
    case showExport([Note])
    case dismissExport
}
```

#### **2.4.2 AppFeature.Reducer 扩展**

```swift
case .exportCurrentNote(let format):
    guard let note = state.editor.note else {
        return .none
    }
    // 触发单文件导出流程
    return .run { send in
        // 显示文件保存对话框
        let url = await showSavePanel(for: note, format: format)
        if let url = url {
            await send(.exportFeature(.exportToFile(url, format)))
        }
    }
    
case .exportNote(let noteId, let format):
    // 从仓库获取笔记
    return .run { send in
        let note = try await noteRepository.fetchNote(noteId)
        let url = await showSavePanel(for: note, format: format)
        if let url = url {
            await send(.exportFeature(.exportToFile(url, format)))
        }
    }
    
case .exportSelectedNotes(let format):
    let noteIds = state.noteList.selectedNoteIds
    guard !noteIds.isEmpty else {
        return .none
    }
    // 触发批量导出流程
    return .run { send in
        let notes = try await noteRepository.fetchNotes(ids: Array(noteIds))
        let url = await showDirectoryPanel()
        if let url = url {
            await send(.showExport(notes))
            await send(.exportFeature(.exportToDirectory(url)))
        }
    }
    
case .exportNotes(let noteIds, let format):
    // 从仓库获取笔记
    return .run { send in
        let notes = try await noteRepository.fetchNotes(ids: Array(noteIds))
        let url = await showDirectoryPanel()
        if let url = url {
            await send(.showExport(notes))
            await send(.exportFeature(.exportToDirectory(url)))
        }
    }
```

#### **2.4.3 NoteListFeature.Action 扩展**

**位置**: `Nota4/Nota4/Features/NoteList/NoteListFeature.swift`

```swift
enum Action {
    // ... 现有 Actions ...
    
    // 导出相关（需要向上传递到 AppFeature）
    case exportNote(String, format: ExportFormat)
    case exportNotes(Set<String>, format: ExportFormat)
}
```

**注意**: 这些 Action 需要在 `AppFeature` 中处理，`NoteListFeature` 只负责触发。

---

### 2.5 文件保存对话框实现

#### **2.5.1 单文件导出对话框**

```swift
@MainActor
func showSavePanel(for note: Note, format: ExportFormat) async -> URL? {
    return await withCheckedContinuation { continuation in
        let panel = NSSavePanel()
        
        // 设置默认文件名
        let defaultFileName = sanitizeFileName(note.title.isEmpty ? note.noteId : note.title)
        panel.nameFieldStringValue = defaultFileName
        
        // 设置允许的文件类型
        switch format {
        case .nota:
            panel.allowedContentTypes = [.init(filenameExtension: "nota")!]
            panel.nameFieldStringValue += ".nota"
        case .markdown:
            panel.allowedContentTypes = [.markdown]
            panel.nameFieldStringValue += ".md"
        case .html:
            panel.allowedContentTypes = [.html]
            panel.nameFieldStringValue += ".html"
        case .pdf:
            panel.allowedContentTypes = [.pdf]
            panel.nameFieldStringValue += ".pdf"
        case .png:
            panel.allowedContentTypes = [.png]
            panel.nameFieldStringValue += ".png"
        }
        
        panel.canCreateDirectories = true
        panel.message = "选择保存位置"
        panel.prompt = "导出"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                continuation.resume(returning: url)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
}
```

#### **2.5.2 批量导出对话框**

```swift
@MainActor
func showDirectoryPanel() async -> URL? {
    return await withCheckedContinuation { continuation in
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.message = "选择导出位置"
        panel.prompt = "导出"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                continuation.resume(returning: url)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
}
```

---

### 2.6 入口优先级总结

| 入口位置 | 单文件导出 | 批量导出 | 优先级 | 实现阶段 |
|---------|-----------|---------|--------|---------|
| **菜单栏** | ✅ | ✅ | P0 | 阶段 1 |
| **笔记列表右键菜单** | ✅ | ✅ | P0 | 阶段 1 |
| **笔记列表工具栏** | ❌ | ✅ | P1 | 阶段 2 |
| **编辑器工具栏** | ✅ | ❌ | P1 | 阶段 2 |
| **编辑器右键菜单** | ✅ | ❌ | P2 | 阶段 3 |

---

### 2.7 用户体验优化

#### **2.7.1 智能菜单项**

- **动态启用/禁用**: 根据当前状态（是否有选中笔记、是否有当前笔记）动态启用/禁用菜单项
- **菜单项文本**: 根据选中数量显示"导出当前笔记"或"导出 X 篇笔记"

#### **2.7.2 快捷键支持**

- **单文件导出**: `Cmd+E`（当前笔记）
- **批量导出**: `Cmd+Shift+E`（选中笔记）
- **格式快捷键**: 在子菜单中支持数字键快速选择（如 1=nota, 2=md, 3=html）

#### **2.7.3 进度反馈**

- **单文件导出**: 显示进度条（PDF/PNG 生成较慢）
- **批量导出**: 显示总体进度和当前文件进度

---

## 3. HTML/PDF/PNG 导出需求

### 3.1 功能需求

#### **3.1.1 HTML 导出**

**需求**:
- 将笔记导出为独立的 HTML 文件
- HTML 文件应包含所有样式和脚本（自包含）
- 图片应内嵌为 Base64 或使用相对路径
- 支持主题选择（使用当前预览主题或指定主题）
- 支持 TOC（目录）选项

**使用场景**:
- 在浏览器中查看笔记
- 分享给他人（无需 Nota4 应用）
- 备份笔记为网页格式

**技术要求**:
- 复用 `MarkdownRenderer.renderToHTML()`
- 处理图片路径（转换为 Base64 或相对路径）
- 确保 HTML 文件自包含（所有资源内嵌）

#### **2.1.2 PDF 导出**

**需求**:
- 将笔记导出为 PDF 文档
- 保留所有格式（标题、列表、代码块、图片等）
- 支持打印优化（分页、页眉页脚）
- 支持主题选择

**使用场景**:
- 打印笔记
- 分享为 PDF 文档
- 归档保存

**技术要求**:
- **方案 A（推荐）**: HTML → WKWebView → PDF
  - 使用 `WKWebView` 渲染 HTML
  - 使用 `PDFDocument` 或 `NSPrintOperation` 生成 PDF
  - 优点：简单、效果好、支持所有 HTML 特性
  - 缺点：需要 WebKit 框架（macOS 已内置）

- **方案 B**: 直接使用 PDFKit
  - 需要手动处理 Markdown 渲染和排版
  - 优点：无需 WebKit
  - 缺点：实现复杂、难以支持所有特性

**推荐方案**: **方案 A**（HTML → PDF）

#### **2.1.3 PNG 导出**

**需求**:
- 将笔记导出为 PNG 图片
- 支持高分辨率（Retina）
- 支持自定义尺寸（宽度）
- 支持主题选择

**使用场景**:
- 分享到社交媒体
- 制作笔记截图
- 嵌入到其他文档

**技术要求**:
- **方案 A（推荐）**: HTML → WKWebView → NSImage → PNG
  - 使用 `WKWebView` 渲染 HTML
  - 使用 `takeSnapshot()` 或 `dataRepresentation()` 获取图片
  - 优点：简单、效果好
  - 缺点：需要 WebKit 框架

- **方案 B**: 使用 Core Graphics 直接绘制
  - 需要手动处理 Markdown 渲染
  - 优点：无需 WebKit
  - 缺点：实现复杂

**推荐方案**: **方案 A**（HTML → PNG）

### 3.2 导出选项

#### **3.2.1 单文件 vs 批量导出**

| 格式 | 单文件导出 | 批量导出 | 说明 |
|------|-----------|---------|------|
| `.nota` | ✅ | ✅ | 每个笔记一个文件 |
| `.md` | ✅ | ✅ | 每个笔记一个文件 |
| `.html` | ✅ | ✅ | 每个笔记一个 HTML 文件 |
| `.pdf` | ✅ | ✅ | 每个笔记一个 PDF 文件 |
| `.png` | ✅ | ✅ | 每个笔记一个 PNG 文件 |

**设计决策**:
- HTML/PDF/PNG 支持单文件和批量导出
- 批量导出时，每个笔记生成一个独立文件
- 文件名使用笔记标题（清理后）或笔记 ID

#### **2.2.2 导出选项**

**HTML 导出选项**:
- 主题选择（使用当前预览主题或指定主题）
- 是否包含 TOC
- 图片处理方式（Base64 内嵌 / 相对路径 / 绝对路径）

**PDF 导出选项**:
- 主题选择
- 是否包含 TOC
- 页面大小（A4, Letter, 自定义）
- 页边距
- 是否包含页眉页脚

**PNG 导出选项**:
- 主题选择
- 图片宽度（像素）
- 是否包含 TOC
- 背景色（透明 / 白色 / 主题色）

---

## 3. 技术方案设计

### 3.1 HTML 导出实现

#### **3.1.1 架构设计**

```
ExportFeature (TCA)
    ↓
ExportService.exportAsHTML()
    ↓
MarkdownRenderer.renderToHTML()  [复用现有]
    ↓
HTMLProcessor.processImages()      [新增：处理图片]
    ↓
写入文件
```

#### **3.1.2 实现步骤**

**步骤 1**: 扩展 `ExportServiceProtocol`

```swift
protocol ExportServiceProtocol {
    // ... 现有方法 ...
    
    func exportAsHTML(
        note: Note,
        to url: URL,
        options: HTMLExportOptions
    ) async throws
}

struct HTMLExportOptions {
    var themeId: String?
    var includeTOC: Bool = false
    var imageHandling: ImageHandling = .base64
}

enum ImageHandling {
    case base64        // 内嵌为 Base64
    case relativePath  // 相对路径（需要复制图片）
    case absolutePath  // 绝对路径（不推荐）
}
```

**步骤 2**: 实现 `exportAsHTML()`

```swift
func exportAsHTML(note: Note, to url: URL, options: HTMLExportOptions) async throws {
    // 1. 使用 MarkdownRenderer 生成 HTML
    let renderOptions = RenderOptions(
        themeId: options.themeId,
        includeTOC: options.includeTOC,
        noteDirectory: getNoteDirectory(noteId: note.noteId)
    )
    
    var html = try await markdownRenderer.renderToHTML(
        markdown: note.content,
        options: renderOptions
    )
    
    // 2. 处理图片（根据选项）
    switch options.imageHandling {
    case .base64:
        html = try await embedImagesAsBase64(html, noteId: note.noteId)
    case .relativePath:
        // 复制图片到导出目录，使用相对路径
        html = try await copyImagesAndUpdatePaths(html, noteId: note.noteId, exportDir: url.deletingLastPathComponent())
    case .absolutePath:
        // 保持绝对路径（不推荐，但保留选项）
        break
    }
    
    // 3. 更新 HTML 标题
    html = updateHTMLTitle(html, title: note.title)
    
    // 4. 写入文件
    try html.write(to: url, atomically: true, encoding: .utf8)
}
```

**步骤 3**: 图片处理辅助方法

```swift
private func embedImagesAsBase64(_ html: String, noteId: String) async throws -> String {
    var result = html
    let pattern = #"<img src="([^"]+)""#
    let regex = try NSRegularExpression(pattern: pattern)
    
    let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
    
    for match in matches.reversed() {
        guard let srcRange = Range(match.range(at: 1), in: html) else { continue }
        let srcPath = String(html[srcRange])
        
        // 解析图片路径
        if let imageURL = resolveImageURL(srcPath, noteId: noteId) {
            let imageData = try Data(contentsOf: imageURL)
            let base64 = imageData.base64EncodedString()
            let mimeType = getMimeType(for: imageURL.pathExtension)
            let base64Src = "data:\(mimeType);base64,\(base64)"
            
            // 替换 src 属性
            result.replaceSubrange(match.range, with: #"<img src="\#(base64Src)""#)
        }
    }
    
    return result
}
```

### 3.2 PDF 导出实现

#### **3.2.1 架构设计**

```
ExportFeature (TCA)
    ↓
ExportService.exportAsPDF()
    ↓
MarkdownRenderer.renderToHTML()  [复用现有]
    ↓
PDFGenerator.generateFromHTML()   [新增：HTML → PDF]
    ↓
写入文件
```

#### **3.2.2 实现步骤**

**步骤 1**: 创建 `PDFGenerator` Service

```swift
import WebKit
import PDFKit

actor PDFGenerator {
    func generateFromHTML(
        html: String,
        options: PDFExportOptions
    ) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 1000))
                    
                    // 加载 HTML
                    webView.loadHTMLString(html, baseURL: nil)
                    
                    // 等待页面加载完成
                    try await waitForPageLoad(webView)
                    
                    // 生成 PDF
                    let pdfData = try await generatePDF(from: webView, options: options)
                    
                    continuation.resume(returning: pdfData)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func waitForPageLoad(_ webView: WKWebView) async throws {
        // 等待页面加载完成（包括 Mermaid、KaTeX 等异步内容）
        // 可以使用 JavaScript 检测内容是否完全渲染
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2秒延迟（可优化）
    }
    
    private func generatePDF(from webView: WKWebView, options: PDFExportOptions) async throws -> Data {
        let printInfo = NSPrintInfo.shared
        printInfo.paperSize = options.paperSize
        printInfo.topMargin = options.margin
        printInfo.bottomMargin = options.margin
        printInfo.leftMargin = options.margin
        printInfo.rightMargin = options.margin
        
        let printOperation = webView.printOperation(with: printInfo)
        let pdfData = printOperation.pdfPanel.dataWithPDF(inside: printOperation.pdfPanel.bounds)
        
        return pdfData
    }
}
```

**步骤 2**: 扩展 `ExportService`

```swift
func exportAsPDF(
    note: Note,
    to url: URL,
    options: PDFExportOptions
) async throws {
    // 1. 生成 HTML
    let renderOptions = RenderOptions(
        themeId: options.themeId,
        includeTOC: options.includeTOC,
        noteDirectory: getNoteDirectory(noteId: note.noteId)
    )
    
    var html = try await markdownRenderer.renderToHTML(
        markdown: note.content,
        options: renderOptions
    )
    
    // 2. 处理图片（PDF 需要内嵌图片）
    html = try await embedImagesAsBase64(html, noteId: note.noteId)
    
    // 3. 生成 PDF
    let pdfGenerator = PDFGenerator()
    let pdfData = try await pdfGenerator.generateFromHTML(html: html, options: options)
    
    // 4. 写入文件
    try pdfData.write(to: url)
}
```

**注意事项**:
- ⚠️ `WKWebView` 必须在主线程创建和使用
- ⚠️ 需要等待异步内容（Mermaid、KaTeX）渲染完成
- ⚠️ PDF 生成可能需要较长时间，需要显示进度

### 3.3 PNG 导出实现

#### **3.3.1 架构设计**

```
ExportFeature (TCA)
    ↓
ExportService.exportAsPNG()
    ↓
MarkdownRenderer.renderToHTML()  [复用现有]
    ↓
PNGGenerator.generateFromHTML()  [新增：HTML → PNG]
    ↓
写入文件
```

#### **3.3.2 实现步骤**

**步骤 1**: 创建 `PNGGenerator` Service

```swift
import WebKit
import AppKit

actor PNGGenerator {
    func generateFromHTML(
        html: String,
        options: PNGExportOptions
    ) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    let webView = WKWebView(frame: .init(x: 0, y: 0, width: options.width, height: 1000))
                    
                    // 加载 HTML
                    webView.loadHTMLString(html, baseURL: nil)
                    
                    // 等待页面加载完成
                    try await waitForPageLoad(webView)
                    
                    // 获取实际内容高度
                    let contentHeight = try await getContentHeight(webView)
                    
                    // 调整 WebView 高度
                    webView.frame = .init(x: 0, y: 0, width: options.width, height: contentHeight)
                    
                    // 等待重新布局
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
                    
                    // 生成 PNG
                    let imageData = try await generatePNG(from: webView, options: options)
                    
                    continuation.resume(returning: imageData)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func getContentHeight(_ webView: WKWebView) async throws -> CGFloat {
        return try await withCheckedThrowingContinuation { continuation in
            webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let height = result as? CGFloat {
                    continuation.resume(returning: height)
                } else {
                    continuation.resume(returning: 1000) // 默认高度
                }
            }
        }
    }
    
    private func generatePNG(from webView: WKWebView, options: PNGExportOptions) async throws -> Data {
        let config = WKSnapshotConfiguration()
        config.rect = webView.bounds
        
        let image = try await webView.takeSnapshot(configuration: config)
        let imageRep = NSBitmapImageRep(data: image.tiffRepresentation!)
        
        guard let pngData = imageRep?.representation(using: .png, properties: [:]) else {
            throw ExportServiceError.fileWriteFailed
        }
        
        return pngData
    }
}
```

**步骤 2**: 扩展 `ExportService`

```swift
func exportAsPNG(
    note: Note,
    to url: URL,
    options: PNGExportOptions
) async throws {
    // 1. 生成 HTML
    let renderOptions = RenderOptions(
        themeId: options.themeId,
        includeTOC: options.includeTOC,
        noteDirectory: getNoteDirectory(noteId: note.noteId)
    )
    
    var html = try await markdownRenderer.renderToHTML(
        markdown: note.content,
        options: renderOptions
    )
    
    // 2. 处理图片（PNG 需要内嵌图片）
    html = try await embedImagesAsBase64(html, noteId: note.noteId)
    
    // 3. 生成 PNG
    let pngGenerator = PNGGenerator()
    let pngData = try await pngGenerator.generateFromHTML(html: html, options: options)
    
    // 4. 写入文件
    try pngData.write(to: url)
}
```

**注意事项**:
- ⚠️ `WKWebView` 必须在主线程创建和使用
- ⚠️ 需要等待异步内容渲染完成
- ⚠️ 需要动态获取内容高度，避免截断
- ⚠️ 支持 Retina 分辨率（@2x）

---

## 4. TCA 状态管理设计

### 4.1 扩展 ExportFeature.State

```swift
@ObservableState
struct State: Equatable {
    var notesToExport: [Note]
    var isExporting = false
    var exportFormat: ExportFormat = .nota
    var includeMetadata = true
    var errorMessage: String?
    var exportProgress: Double = 0.0
    var exportCompleted = false
    
    // 新增：HTML 导出选项
    var htmlOptions: HTMLExportOptions = .default
    
    // 新增：PDF 导出选项
    var pdfOptions: PDFExportOptions = .default
    
    // 新增：PNG 导出选项
    var pngOptions: PNGExportOptions = .default
    
    // 新增：导出模式（单文件 vs 批量）
    var exportMode: ExportMode = .multiple
    
    init(notesToExport: [Note]) {
        self.notesToExport = notesToExport
        // 如果只有一篇笔记，默认单文件导出
        if notesToExport.count == 1 {
            self.exportMode = .single
        }
    }
}

enum ExportMode: Equatable {
    case single    // 单文件导出（选择保存位置）
    case multiple  // 批量导出（选择目录）
}

enum ExportFormat: Equatable {
    case nota
    case markdown
    case html      // 新增
    case pdf       // 新增
    case png       // 新增
}
```

### 4.2 扩展 ExportFeature.Action

```swift
enum Action: BindableAction {
    case binding(BindingAction<State>)
    
    // 现有 Actions
    case selectExportLocation
    case exportToDirectory(URL)
    case exportStarted
    case exportProgress(Double)
    case exportCompleted
    case exportFailed(Error)
    case dismissError
    case dismiss
    
    // 新增：单文件导出
    case selectExportFile(ExportFormat)
    case exportToFile(URL, ExportFormat)
    
    // 新增：选项更新
    case updateHTMLOptions(HTMLExportOptions)
    case updatePDFOptions(PDFExportOptions)
    case updatePNGOptions(PNGExportOptions)
}
```

### 4.3 扩展 ExportFeature.Reducer

```swift
var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
        switch action {
        // ... 现有 Actions ...
        
        case .selectExportFile(let format):
            // 显示文件保存对话框
            return .none
            
        case .exportToFile(let url, let format):
            state.isExporting = true
            state.errorMessage = nil
            state.exportProgress = 0.0
            state.exportCompleted = false
            
            guard let note = state.notesToExport.first else {
                return .send(.exportFailed(ExportServiceError.invalidURL))
            }
            
            return .run { send in
                await send(.exportStarted)
                
                do {
                    // 根据格式调用不同的导出方法
                    switch format {
                    case .html:
                        try await exportService.exportAsHTML(
                            note: note,
                            to: url,
                            options: state.htmlOptions
                        )
                    case .pdf:
                        // 更新进度（PDF 生成较慢）
                        await send(.exportProgress(0.3))
                        try await exportService.exportAsPDF(
                            note: note,
                            to: url,
                            options: state.pdfOptions
                        )
                    case .png:
                        // 更新进度（PNG 生成较慢）
                        await send(.exportProgress(0.3))
                        try await exportService.exportAsPNG(
                            note: note,
                            to: url,
                            options: state.pngOptions
                        )
                    default:
                        throw ExportServiceError.unsupportedFormat
                    }
                    
                    await send(.exportProgress(1.0))
                    await send(.exportCompleted)
                } catch {
                    await send(.exportFailed(error))
                }
            }
            
        case .exportToDirectory(let url):
            // 扩展现有逻辑，支持 HTML/PDF/PNG 批量导出
            state.isExporting = true
            state.errorMessage = nil
            state.exportProgress = 0.0
            state.exportCompleted = false
            
            let notes = state.notesToExport
            let format: Services.ExportFormat
            
            switch state.exportFormat {
            case .nota:
                format = .nota
            case .markdown:
                format = .markdown(includeMetadata: state.includeMetadata)
            case .html:
                format = .html(options: state.htmlOptions)
            case .pdf:
                format = .pdf(options: state.pdfOptions)
            case .png:
                format = .png(options: state.pngOptions)
            }
            
            return .run { send in
                await send(.exportStarted)
                
                do {
                    let totalNotes = notes.count
                    for (index, note) in notes.enumerated() {
                        // 更新进度
                        let progress = Double(index) / Double(totalNotes)
                        await send(.exportProgress(progress))
                        
                        // 导出单个笔记
                        let fileName = generateFileName(note: note, format: state.exportFormat)
                        let fileURL = url.appendingPathComponent(fileName)
                        
                        switch format {
                        case .html(let options):
                            try await exportService.exportAsHTML(note: note, to: fileURL, options: options)
                        case .pdf(let options):
                            try await exportService.exportAsPDF(note: note, to: fileURL, options: options)
                        case .png(let options):
                            try await exportService.exportAsPNG(note: note, to: fileURL, options: options)
                        // ... 其他格式 ...
                        }
                    }
                    
                    await send(.exportProgress(1.0))
                    await send(.exportCompleted)
                } catch {
                    await send(.exportFailed(error))
                }
            }
            
        // ... 其他 Actions ...
        }
    }
}
```

### 4.4 扩展 Services.ExportFormat

```swift
enum Services {
    enum ExportFormat {
        case nota
        case markdown(includeMetadata: Bool)
        case html(options: HTMLExportOptions)      // 新增
        case pdf(options: PDFExportOptions)        // 新增
        case png(options: PNGExportOptions)         // 新增
    }
}
```

### 4.5 TCA 设计原则遵循

✅ **单一数据源**: 所有导出状态都在 `ExportFeature.State` 中  
✅ **不可变状态**: 通过 Action → Reducer → State 流程更新  
✅ **副作用隔离**: 所有异步操作在 `.run` Effect 中处理  
✅ **依赖注入**: 使用 `@Dependency` 注入服务  
✅ **可测试性**: 所有逻辑都可以通过 TCA 测试框架测试  

---

## 5. 实施计划

### 5.1 阶段划分

#### **阶段 1: HTML 导出（P0）**

**任务**:
1. 扩展 `ExportServiceProtocol` 添加 `exportAsHTML()`
2. 实现 `HTMLExportOptions` 结构体
3. 实现图片处理逻辑（Base64 内嵌）
4. 扩展 `ExportFeature` 支持 HTML 格式
5. 更新 `ExportView` UI
6. 测试 HTML 导出功能

**预计时间**: 2-3 天

#### **阶段 2: PDF 导出（P0）**

**任务**:
1. 创建 `PDFGenerator` Service
2. 实现 `PDFExportOptions` 结构体
3. 扩展 `ExportService` 添加 `exportAsPDF()`
4. 扩展 `ExportFeature` 支持 PDF 格式
5. 更新 `ExportView` UI（添加 PDF 选项）
6. 测试 PDF 导出功能

**预计时间**: 3-4 天

#### **阶段 3: PNG 导出（P1）**

**任务**:
1. 创建 `PNGGenerator` Service
2. 实现 `PNGExportOptions` 结构体
3. 扩展 `ExportService` 添加 `exportAsPNG()`
4. 扩展 `ExportFeature` 支持 PNG 格式
5. 更新 `ExportView` UI（添加 PNG 选项）
6. 测试 PNG 导出功能

**预计时间**: 2-3 天

#### **阶段 4: 优化与完善（P2）**

**任务**:
1. 优化 PDF/PNG 生成性能（减少等待时间）
2. 添加更多导出选项（页眉页脚、自定义尺寸等）
3. 错误处理优化
4. 用户体验优化（进度显示、取消功能）
5. 文档完善

**预计时间**: 2-3 天

### 5.2 文件清单

#### **新增文件**:
- `Nota4/Nota4/Services/PDFGenerator.swift` - PDF 生成服务
- `Nota4/Nota4/Services/PNGGenerator.swift` - PNG 生成服务
- `Nota4/Nota4/Models/ExportOptions.swift` - 导出选项模型

#### **修改文件**:
- `Nota4/Nota4/Features/Export/ExportFeature.swift` - 扩展状态和 Action
- `Nota4/Nota4/Features/Export/ExportView.swift` - 更新 UI
- `Nota4/Nota4/Services/ExportService.swift` - 添加新导出方法
- `Nota4/Nota4Tests/Features/ExportFeatureTests.swift` - 添加测试

---

## 6. 测试计划

### 6.1 单元测试

#### **ExportService 测试**:
- ✅ HTML 导出：验证 HTML 文件内容正确
- ✅ PDF 导出：验证 PDF 文件生成成功
- ✅ PNG 导出：验证 PNG 文件生成成功
- ✅ 图片处理：验证 Base64 内嵌正确
- ✅ 错误处理：验证各种错误情况

#### **PDFGenerator 测试**:
- ✅ HTML → PDF 转换正确
- ✅ 页面大小设置生效
- ✅ 页边距设置生效
- ✅ 异步内容等待逻辑正确

#### **PNGGenerator 测试**:
- ✅ HTML → PNG 转换正确
- ✅ 图片尺寸正确
- ✅ 内容高度计算正确
- ✅ Retina 分辨率支持

### 6.2 集成测试

#### **ExportFeature 测试**:
- ✅ 单文件导出流程
- ✅ 批量导出流程
- ✅ 进度更新正确
- ✅ 错误处理正确
- ✅ 状态管理正确

### 6.3 手动测试

#### **功能测试**:
- ✅ 导出简单笔记（纯文本）
- ✅ 导出复杂笔记（代码块、图片、Mermaid、数学公式）
- ✅ 不同主题导出
- ✅ 不同选项组合
- ✅ 大文件导出（性能测试）

#### **兼容性测试**:
- ✅ 导出的 HTML 在不同浏览器中显示正确
- ✅ 导出的 PDF 在不同 PDF 阅读器中打开正确
- ✅ 导出的 PNG 在不同应用中打开正确

---

## 7. 风险评估

### 7.1 技术风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|---------|
| WKWebView 异步内容渲染不完整 | 高 | 中 | 增加等待时间，使用 JavaScript 检测 |
| PDF/PNG 生成性能问题 | 中 | 中 | 优化等待逻辑，添加进度显示 |
| 图片 Base64 编码导致文件过大 | 中 | 低 | 提供相对路径选项 |
| Sandbox 权限问题 | 高 | 低 | 使用正确的文件访问方式 |

### 7.2 用户体验风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|---------|
| PDF/PNG 生成时间过长 | 中 | 中 | 显示进度，支持取消 |
| 导出选项过于复杂 | 低 | 低 | 提供默认选项，简化 UI |
| 错误信息不清晰 | 中 | 中 | 提供详细的错误信息 |

---

## 8. 总结

### 8.1 设计要点

1. **复用现有架构**: 充分利用 `MarkdownRenderer` 和 TCA 状态管理
2. **渐进式实现**: 分阶段实施，先 HTML，再 PDF，最后 PNG
3. **用户体验优先**: 提供清晰的进度显示和错误处理
4. **可扩展性**: 设计支持未来添加更多导出格式

### 8.2 关键决策

1. **PDF/PNG 生成方案**: 选择 HTML → WKWebView → PDF/PNG（简单、效果好）
2. **图片处理**: 默认使用 Base64 内嵌（自包含），提供相对路径选项
3. **导出模式**: 支持单文件和批量导出
4. **状态管理**: 严格遵循 TCA 模式，确保可测试性和可维护性

---

**文档结束**


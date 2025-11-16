# 导入导出功能完善 PRD

**版本**: v1.0  
**日期**: 2025-11-16  
**状态**: 规划中  
**优先级**: P0-P1

---

## 📋 目录

- [1. 产品概述](#1-产品概述)
- [2. 现状评估](#2-现状评估)
- [3. 功能规划](#3-功能规划)
- [4. 技术方案](#4-技术方案)
- [5. 实施计划](#5-实施计划)
- [6. 测试计划](#6-测试计划)
- [7. 风险评估](#7-风险评估)

---

## 1. 产品概述

### 1.1 背景

Nota4 已经实现了基础的导入导出功能：
- ✅ 导入：`.nota`, `.md` 格式
- ✅ 导出：`.nota`, `.md` 格式

为了提供更完整的用户体验，需要补充以下功能：
- 导入：`.txt` 纯文本
- 导出：`.html`（HTML 渲染）, `.pdf`（PDF 文档）, `.txt`（纯文本）

### 1.2 目标用户

1. **普通用户**：需要将笔记导出为通用格式（HTML/PDF）分享
2. **开发者**：需要处理纯文本文件（.txt）
3. **跨平台用户**：需要在不同平台/应用间迁移笔记

### 1.3 核心价值

- ✅ **灵活性**：支持多种格式，满足不同场景
- ✅ **兼容性**：与其他笔记应用/平台互通
- ✅ **可分享性**：导出为 HTML/PDF 便于分享
- ✅ **数据安全**：支持多格式备份

---

## 2. 现状评估

### 2.1 已实现功能

#### **导入（Import）**

| 格式 | 状态 | 实现程度 | 说明 |
|------|------|---------|------|
| `.nota` | ✅ 已实现 | 100% | 完整支持 YAML Front Matter 解析 |
| `.md/.markdown` | ✅ 已实现 | 90% | 支持纯 Markdown 和带 YAML Front Matter |
| `.txt` | ❌ 未实现 | 0% | **需要实现** |

**已实现特性**：
- ✅ 单文件导入
- ✅ 批量导入（多文件）
- ✅ YAML Front Matter 解析
- ✅ 冲突检测（自动生成新 ID）
- ✅ 错误处理（部分失败继续处理）
- ✅ 进度追踪
- ✅ UI 界面

**存在的问题**：
- ✅ ~~导入后列表不更新~~ （已修复）
- ⚠️ MD 导入未提取第一个标题作为 title（可优化）

#### **导出（Export）**

| 格式 | 状态 | 实现程度 | 说明 |
|------|------|---------|------|
| `.nota` | ✅ 已实现 | 100% | YAML + Markdown 完整导出 |
| `.md` | ✅ 已实现 | 100% | 支持可选元数据 |
| `.html` | ❌ 未实现 | 0% | **需要实现** |
| `.pdf` | ❌ 未实现 | 0% | **需要实现** |
| `.txt` | ❌ 未实现 | 0% | **需要实现** |

**已实现特性**：
- ✅ 单笔记导出
- ✅ 批量导出
- ✅ 元数据选项
- ✅ 文件名清理
- ✅ 进度追踪
- ✅ UI 界面

---

## 3. 功能规划

### 3.1 优先级定义

- **P0（必须）**：核心功能，必须在本次版本实现
- **P1（重要）**：重要功能，建议在本次版本实现
- **P2（可选）**：锦上添花，可推迟到后续版本

### 3.2 功能清单

#### **3.2.1 导入功能**

| 功能 | 优先级 | 实现难度 | 预估工时 |
|------|--------|---------|---------|
| `.txt` 文件导入 | **P0** | 🟢 简单 | 2h |
| 改进 `.md` 导入（提取标题） | **P1** | 🟢 简单 | 1h |
| 导入时选择分类/标签 | **P2** | 🟡 中等 | 3h |

#### **3.2.2 导出功能**

| 功能 | 优先级 | 实现难度 | 预估工时 |
|------|--------|---------|---------|
| `.html` 导出（渲染） | **P0** | 🟡 中等 | 4h |
| `.pdf` 导出 | **P1** | 🟠 困难 | 6h |
| `.txt` 导出（纯文本） | **P0** | 🟢 简单 | 1h |
| HTML 样式定制 | **P2** | 🟡 中等 | 3h |
| 批量导出压缩包 | **P2** | 🟡 中等 | 2h |

---

## 4. 技术方案

### 4.1 导入功能

#### **4.1.1 TXT 文件导入（P0）**

**需求**：
- 读取纯文本文件（.txt）
- 自动将文件名作为标题
- 内容作为笔记正文
- 支持不同编码（UTF-8, GB2312 等）

**实现方案**：

```swift
func importTextFile(from url: URL) async throws -> Note {
    // 1. 检查文件扩展名
    guard url.pathExtension == "txt" else {
        throw ImportServiceError.invalidFileType
    }
    
    // 2. 读取文件内容（自动检测编码）
    var content: String?
    let encodings: [String.Encoding] = [.utf8, .utf16, .gb_18030_2000]
    
    for encoding in encodings {
        if let text = try? String(contentsOf: url, encoding: encoding) {
            content = text
            break
        }
    }
    
    guard let content = content else {
        throw ImportServiceError.fileReadFailed
    }
    
    // 3. 提取标题（文件名）
    let title = url.deletingPathExtension().lastPathComponent
    
    // 4. 创建笔记
    let note = Note(
        noteId: UUID().uuidString,
        title: title,
        content: content,
        created: Date(),
        updated: Date()
    )
    
    return try await createAndSaveNote(note)
}
```

**文件更新**：
- `ImportService.swift`：添加 `importTextFile` 方法
- `ImportService.swift`：更新 `importMultipleFiles` 支持 `.txt`

---

#### **4.1.2 改进 MD 导入（P1）**

**需求**：
- 如果 Markdown 文件的第一行是标题（`# Title`），提取作为 title
- 如果没有标题，使用文件名作为 title

**实现方案**：

```swift
func importMarkdownFile(from url: URL) async throws -> Note {
    // ... 现有代码 ...
    
    // 提取标题的改进逻辑
    var title = url.deletingPathExtension().lastPathComponent
    var content = rawContent
    
    // 检查第一行是否为 H1 标题
    let lines = content.components(separatedBy: .newlines)
    if let firstLine = lines.first, firstLine.hasPrefix("# ") {
        // 提取标题
        title = String(firstLine.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        // 移除第一行（标题行）
        content = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // ... 创建笔记 ...
}
```

---

### 4.2 导出功能

#### **4.2.1 TXT 导出（P0）**

**需求**：
- 导出为纯文本（移除 Markdown 格式）
- 保留基本结构（标题、段落）

**实现方案**：

```swift
func exportAsText(note: Note, to url: URL) async throws {
    var content = ""
    
    // 添加标题
    if !note.title.isEmpty {
        content += note.title + "\n"
        content += String(repeating: "=", count: note.title.count) + "\n\n"
    }
    
    // 简单移除 Markdown 格式
    let plainText = removeMarkdownFormatting(note.content)
    content += plainText
    
    // 写入文件
    try content.write(to: url, atomically: true, encoding: .utf8)
}

private func removeMarkdownFormatting(_ text: String) -> String {
    var result = text
    
    // 移除标题符号
    result = result.replacingOccurrences(of: #"^#{1,6}\s+"#, with: "", options: .regularExpression)
    
    // 移除加粗/斜体
    result = result.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "$1", options: .regularExpression)
    result = result.replacingOccurrences(of: #"\*(.+?)\*"#, with: "$1", options: .regularExpression)
    
    // 移除行内代码
    result = result.replacingOccurrences(of: #"`(.+?)`"#, with: "$1", options: .regularExpression)
    
    // 移除链接，保留文本
    result = result.replacingOccurrences(of: #"\[(.+?)\]\(.+?\)"#, with: "$1", options: .regularExpression)
    
    // 移除图片
    result = result.replacingOccurrences(of: #"!\[.+?\]\(.+?\)"#, with: "", options: .regularExpression)
    
    return result
}
```

**文件更新**：
- `ExportService.swift`：添加 `exportAsText` 方法
- `ExportService.swift`：添加 `removeMarkdownFormatting` 辅助方法
- `ExportFeature.swift`：添加 `.text` 格式选项

---

#### **4.2.2 HTML 导出（P0）**

**需求**：
- 将 Markdown 渲染为 HTML
- 包含 CSS 样式（美观、可打印）
- 可选：包含元数据（标题、日期、标签）

**技术选型**：
- 使用第三方 Markdown 渲染库：[Ink](https://github.com/JohnSundell/Ink)
- 轻量级、纯 Swift、无外部依赖

**实现方案**：

```swift
import Ink

func exportAsHTML(note: Note, to url: URL, includeMetadata: Bool) async throws {
    // 1. Markdown → HTML
    let parser = MarkdownParser()
    let html = parser.html(from: note.content)
    
    // 2. 构建完整 HTML
    var fullHTML = """
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>\(escapeHTML(note.title))</title>
        <style>
        \(getHTMLStyle())
        </style>
    </head>
    <body>
    """
    
    // 3. 元数据（可选）
    if includeMetadata {
        fullHTML += """
        <header class="metadata">
            <h1>\(escapeHTML(note.title))</h1>
            <div class="meta-info">
                <span>创建: \(formatDate(note.created))</span>
                <span>更新: \(formatDate(note.updated))</span>
            </div>
        """
        
        if !note.tags.isEmpty {
            fullHTML += """
            <div class="tags">
            """
            for tag in note.tags.sorted() {
                fullHTML += "<span class=\"tag\">\(escapeHTML(tag))</span>"
            }
            fullHTML += "</div>"
        }
        
        fullHTML += "</header>"
    }
    
    // 4. 正文
    fullHTML += """
    <article>
    \(html)
    </article>
    </body>
    </html>
    """
    
    // 5. 写入文件
    try fullHTML.write(to: url, atomically: true, encoding: .utf8)
}

private func getHTMLStyle() -> String {
    return """
    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', sans-serif;
        line-height: 1.6;
        max-width: 800px;
        margin: 0 auto;
        padding: 2rem;
        color: #333;
    }
    
    .metadata {
        border-bottom: 2px solid #e0e0e0;
        padding-bottom: 1rem;
        margin-bottom: 2rem;
    }
    
    .metadata h1 {
        margin: 0 0 0.5rem 0;
    }
    
    .meta-info {
        color: #666;
        font-size: 0.9rem;
    }
    
    .meta-info span {
        margin-right: 1rem;
    }
    
    .tags {
        margin-top: 0.5rem;
    }
    
    .tag {
        display: inline-block;
        background: #f0f0f0;
        padding: 0.2rem 0.6rem;
        border-radius: 4px;
        font-size: 0.85rem;
        margin-right: 0.5rem;
    }
    
    article {
        font-size: 1rem;
    }
    
    article h1, article h2, article h3 {
        margin-top: 1.5rem;
        margin-bottom: 0.5rem;
    }
    
    article pre {
        background: #f5f5f5;
        padding: 1rem;
        border-radius: 4px;
        overflow-x: auto;
    }
    
    article code {
        background: #f0f0f0;
        padding: 0.2rem 0.4rem;
        border-radius: 3px;
        font-family: 'SF Mono', Monaco, Menlo, monospace;
    }
    
    article pre code {
        background: none;
        padding: 0;
    }
    
    article blockquote {
        border-left: 4px solid #ddd;
        padding-left: 1rem;
        color: #666;
        margin: 1rem 0;
    }
    
    @media print {
        body {
            max-width: none;
        }
        .metadata {
            page-break-after: avoid;
        }
    }
    """
}

private func escapeHTML(_ text: String) -> String {
    text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&#39;")
}
```

**依赖更新**：
```swift
// Package.swift
dependencies: [
    // ... 现有依赖 ...
    .package(url: "https://github.com/JohnSundell/Ink.git", from: "0.6.0")
]
```

**文件更新**：
- `Package.swift`：添加 Ink 依赖
- `ExportService.swift`：添加 `exportAsHTML` 方法
- `ExportService.swift`：添加 HTML 样式和辅助方法
- `ExportFeature.swift`：添加 `.html` 格式选项

---

#### **4.2.3 PDF 导出（P1）**

**需求**：
- 将笔记导出为 PDF 文档
- 保留格式（标题、列表、代码块等）
- 支持打印优化

**技术方案**：
PDF 导出有两种实现方式：

**方式 A：HTML → PDF（推荐）**
- 先导出为 HTML
- 使用 `WKWebView` 将 HTML 渲染为 PDF
- 优点：简单、效果好、支持 CSS
- 缺点：需要 WebKit 框架

**方式 B：直接生成 PDF**
- 使用 `PDFKit` 直接生成
- 优点：无需 WebKit
- 缺点：需要手动处理 Markdown 渲染和排版

**推荐实现（方式 A）**：

```swift
import WebKit

func exportAsPDF(note: Note, to url: URL, includeMetadata: Bool) async throws {
    // 1. 先生成 HTML
    let tempURL = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("html")
    
    try await exportAsHTML(note: note, to: tempURL, includeMetadata: includeMetadata)
    
    // 2. 使用 WKWebView 转换为 PDF
    let webView = WKWebView()
    
    // 3. 加载 HTML
    let html = try String(contentsOf: tempURL, encoding: .utf8)
    webView.loadHTMLString(html, baseURL: nil)
    
    // 4. 等待加载完成
    try await waitForWebViewLoad(webView)
    
    // 5. 创建 PDF
    let pdfData = try await webView.pdf()
    try pdfData.write(to: url)
    
    // 6. 清理临时文件
    try? FileManager.default.removeItem(at: tempURL)
}

private func waitForWebViewLoad(_ webView: WKWebView) async throws {
    // 使用 Continuation 等待加载完成
    try await withCheckedThrowingContinuation { continuation in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            continuation.resume()
        }
    }
}

extension WKWebView {
    func pdf() async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            let config = WKPDFConfiguration()
            config.rect = .zero
            
            self.createPDF(configuration: config) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
```

**注意事项**：
- PDF 导出需要在主线程执行（WebKit 要求）
- 需要处理异步加载完成
- 大文档可能需要更长的加载时间

**文件更新**：
- `ExportService.swift`：添加 `exportAsPDF` 方法
- `ExportService.swift`：添加 WebKit 辅助方法
- `ExportFeature.swift`：添加 `.pdf` 格式选项

---

### 4.3 UI 更新

#### **4.3.1 导入界面**

**ExportFormat 枚举更新**：
```swift
enum ExportFormat: String, CaseIterable, Equatable {
    case nota = "Nota"
    case markdown = "Markdown"
    case html = "HTML"
    case pdf = "PDF"
    case text = "纯文本"
    
    var fileExtension: String {
        switch self {
        case .nota: return "nota"
        case .markdown: return "md"
        case .html: return "html"
        case .pdf: return "pdf"
        case .text: return "txt"
        }
    }
    
    var icon: String {
        switch self {
        case .nota: return "doc"
        case .markdown: return "doc.text"
        case .html: return "globe"
        case .pdf: return "doc.richtext"
        case .text: return "doc.plaintext"
        }
    }
}
```

**导出界面更新**：
```swift
// ExportView.swift
ForEach(ExportFormat.allCases, id: \.self) { format in
    Button {
        store.send(.binding(.set(\.exportFormat, format)))
    } label: {
        HStack {
            Image(systemName: format.icon)
            Text(format.rawValue)
            Spacer()
            if store.exportFormat == format {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
        }
    }
    .buttonStyle(.plain)
}
```

---

## 5. 实施计划

### 5.1 阶段划分

#### **Phase 1: P0 功能（必须完成）**
**时间**: 1-2 天  
**工时**: 7h

| 任务 | 负责模块 | 工时 | 状态 |
|------|---------|------|------|
| TXT 导入 | ImportService | 2h | 待开始 |
| TXT 导出 | ExportService | 1h | 待开始 |
| HTML 导出 | ExportService | 4h | 待开始 |

#### **Phase 2: P1 功能（重要）**
**时间**: 1-2 天  
**工时**: 7h

| 任务 | 负责模块 | 工时 | 状态 |
|------|---------|------|------|
| 改进 MD 导入 | ImportService | 1h | 待开始 |
| PDF 导出 | ExportService | 6h | 待开始 |

#### **Phase 3: P2 功能（可选）**
**时间**: 待定  
**工时**: 8h

| 任务 | 负责模块 | 工时 | 状态 |
|------|---------|------|------|
| HTML 样式定制 | ExportService | 3h | 待开始 |
| 批量导出压缩包 | ExportService | 2h | 待开始 |
| 导入时选择分类 | ImportFeature | 3h | 待开始 |

---

### 5.2 开发流程

每个功能的开发流程：

1. **代码实现**（60% 时间）
   - Service 层实现核心逻辑
   - Feature 层集成功能
   - UI 层更新界面

2. **测试验证**（30% 时间）
   - 单元测试（Service 层）
   - 集成测试（Feature 层）
   - 手动测试（UI 交互）

3. **文档更新**（10% 时间）
   - 更新 README
   - 更新用户文档
   - 记录技术细节

---

## 6. 测试计划

### 6.1 导入测试

#### **TXT 导入**
- [ ] 导入 UTF-8 编码的 TXT 文件
- [ ] 导入 GB2312 编码的 TXT 文件
- [ ] 导入空文件
- [ ] 导入超大文件（>10MB）
- [ ] 文件名包含特殊字符
- [ ] 批量导入多个 TXT 文件

#### **MD 导入改进**
- [ ] 第一行为 H1 标题的 MD 文件
- [ ] 第一行不是标题的 MD 文件
- [ ] 空 MD 文件
- [ ] 多个 H1 标题（只提取第一个）

---

### 6.2 导出测试

#### **TXT 导出**
- [ ] 导出纯文本笔记
- [ ] 导出包含 Markdown 格式的笔记
- [ ] 导出包含链接、图片的笔记
- [ ] 导出空笔记
- [ ] 批量导出为 TXT

#### **HTML 导出**
- [ ] 导出简单笔记
- [ ] 导出包含代码块的笔记
- [ ] 导出包含表格的笔记
- [ ] 导出包含列表的笔记
- [ ] 导出包含元数据
- [ ] 浏览器中打开验证渲染效果
- [ ] 打印预览效果

#### **PDF 导出**
- [ ] 导出简单笔记
- [ ] 导出长篇笔记（>10 页）
- [ ] 验证 PDF 格式正确性
- [ ] 验证字体渲染
- [ ] 验证中文显示
- [ ] 打印效果

---

### 6.3 性能测试

| 场景 | 预期性能 | 测试方法 |
|------|---------|---------|
| 导入 100 个 TXT 文件 | < 5s | 计时测试 |
| 导出单个 HTML | < 1s | 计时测试 |
| 导出单个 PDF | < 3s | 计时测试 |
| 导出 50 个笔记为 HTML | < 10s | 计时测试 |

---

### 6.4 兼容性测试

#### **导入兼容性**
- [ ] macOS 13+
- [ ] 不同编码的文本文件
- [ ] 不同来源的 Markdown 文件（Typora, Bear, Obsidian）

#### **导出兼容性**
- [ ] HTML 在 Safari 中打开
- [ ] HTML 在 Chrome 中打开
- [ ] PDF 在 Preview 中打开
- [ ] PDF 在 Adobe Reader 中打开

---

## 7. 风险评估

### 7.1 技术风险

| 风险 | 可能性 | 影响 | 缓解措施 |
|------|-------|------|---------|
| Markdown → HTML 渲染不完整 | 中 | 高 | 使用成熟的 Ink 库，充分测试 |
| PDF 生成失败 | 中 | 中 | 添加错误处理，fallback 到 HTML |
| 编码识别错误 | 低 | 中 | 支持多种编码尝试 |
| 大文件导出超时 | 低 | 低 | 添加超时提示和进度条 |

---

### 7.2 用户体验风险

| 风险 | 可能性 | 影响 | 缓解措施 |
|------|-------|------|---------|
| HTML 样式不美观 | 中 | 中 | 参考主流笔记应用样式 |
| PDF 导出慢 | 高 | 中 | 添加进度提示 |
| 文件格式选择困惑 | 中 | 低 | 添加格式说明和图标 |

---

### 7.3 性能风险

| 风险 | 可能性 | 影响 | 缓解措施 |
|------|-------|------|---------|
| 批量导出内存占用高 | 中 | 中 | 分批处理，释放内存 |
| 大 PDF 文件生成慢 | 高 | 中 | 异步处理，显示进度 |

---

## 8. 成功标准

### 8.1 功能完整性
- ✅ 支持 5 种格式导入（nota, md, txt）
- ✅ 支持 5 种格式导出（nota, md, html, pdf, txt）
- ✅ 导入导出成功率 > 99%

### 8.2 性能指标
- ✅ 单文件导入 < 1s
- ✅ 单文件导出（HTML/TXT）< 1s
- ✅ 单文件导出（PDF）< 3s
- ✅ 批量操作支持 100+ 文件

### 8.3 用户体验
- ✅ 导出的 HTML 样式美观
- ✅ 导出的 PDF 可正常打印
- ✅ 所有操作有清晰的进度提示
- ✅ 错误处理友好，给出明确提示

---

## 9. 附录

### 9.1 参考资料

- [Ink - Markdown Parser](https://github.com/JohnSundell/Ink)
- [WKWebView PDF Export](https://developer.apple.com/documentation/webkit/wkwebview)
- [Markdown 规范](https://commonmark.org/)

### 9.2 相关文档

- `IMPORT_EXPORT_ENHANCEMENT_PRD.md`（本文档）
- `NOTA4_PRD.md`（主 PRD）
- `TECHNICAL_SPEC.md`（技术规格）

---

**文档变更记录**：
- 2025-11-16: v1.0 初始版本，完整规划导入导出增强功能


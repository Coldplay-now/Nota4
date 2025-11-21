# 编辑区插入本地图片后预览渲染逻辑分析

**创建日期**: 2025-01-17  
**分析范围**: Nota4 图片插入和预览渲染机制

---

## 1. 图片插入流程

### 1.1 用户操作
1. 用户在编辑器中点击"插入图片"按钮
2. 触发 `EditorFeature.Action.showImagePicker`
3. 打开 `NSOpenPanel` 让用户选择图片文件

### 1.2 图片处理（EditorFeature.swift:870-901）

```swift
case .insertImage(let url):
    // 1. 获取笔记目录
    let noteDirectory = try await notaFileManager.getNoteDirectory(for: note.noteId)
    let assetsDirectory = noteDirectory.appendingPathComponent("assets")
    
    // 2. 确保 assets 目录存在
    try FileManager.default.createDirectory(
        at: assetsDirectory,
        withIntermediateDirectories: true
    )
    
    // 3. 生成文件名（UUID + 扩展名）
    let fileExtension = url.pathExtension.isEmpty ? "png" : url.pathExtension
    let imageId = UUID().uuidString
    let fileName = "\(imageId).\(fileExtension)"
    let destinationURL = assetsDirectory.appendingPathComponent(fileName)
    
    // 4. 复制文件到 assets 目录
    try FileManager.default.copyItem(at: url, to: destinationURL)
    
    // 5. 生成相对路径
    let relativePath = "assets/\(fileName)"
```

**关键点**：
- 图片存储在：`{noteDirectory}/assets/{UUID}.{ext}`
- Markdown 中使用相对路径：`assets/{UUID}.{ext}`
- 例如：`assets/550e8400-e29b-41d4-a716-446655440000.png`

### 1.3 插入 Markdown 语法（EditorFeature.swift:903-915）

```swift
case .imageInserted(let imageId, let relativePath):
    let result = MarkdownFormatter.insertImage(
        text: state.content,
        selection: state.selectionRange,
        altText: "图片",
        imagePath: relativePath
    )
    state.content = result.newText
    state.selectionRange = result.newSelection
```

**生成的 Markdown**：
```markdown
![图片](assets/550e8400-e29b-41d4-a716-446655440000.png)
```

---

## 2. 预览渲染流程

### 2.1 触发渲染（EditorFeature.swift:1020-1032）

当内容变化或切换到预览模式时：
```swift
case .preview(.contentChanged(let content)):
    let options = RenderOptions(
        themeId: state.preview.currentThemeId,
        includeTOC: state.preview.includeTOC
    )
    return .run { send in
        let html = try await markdownRenderer.renderToHTML(
            markdown: content,
            options: options
        )
        await send(.preview(.renderCompleted(.success(html))))
    }
```

### 2.2 Markdown → HTML 转换（MarkdownRenderer.swift）

**使用 Ink 解析器**：
```swift
private let parser = MarkdownParser()  // Ink 的 MarkdownParser

// 在 renderToHTML 中：
var html = parser.html(from: preprocessed.markdown)
```

**Ink 的行为**：
- Ink 会自动将 `![alt](path)` 转换为 `<img src="path" alt="alt">`
- **但是**：Ink 不会处理相对路径，直接输出原始路径
- 例如：`<img src="assets/550e8400-e29b-41d4-a716-446655440000.png" alt="图片">`

### 2.3 HTML 显示（WebViewWrapper.swift:17-22）

```swift
func updateNSView(_ webView: WKWebView, context: Context) {
    if context.coordinator.lastHTML != html {
        context.coordinator.lastHTML = html
        webView.loadHTMLString(html, baseURL: nil)  // ⚠️ baseURL 为 nil
    }
}
```

**关键问题**：
- `baseURL: nil` 意味着相对路径无法被解析
- `assets/filename.png` 无法转换为可访问的 `file://` URL
- **结果**：图片无法显示

---

## 3. 当前实现的问题

### 3.1 相对路径无法解析

**问题**：
- Markdown 中使用相对路径：`assets/filename.png`
- Ink 解析后：`<img src="assets/filename.png">`
- WebView 的 `baseURL` 为 `nil`，无法解析相对路径
- **结果**：图片无法显示

### 3.2 缺少路径转换逻辑

**对比其他项目**：
- **project7/Nota2**：使用自定义 `MarkdownService`，有 `visitImage()` 方法
- 在 `visitImage()` 中调用 `resolveImagePath()` 将相对路径转换为：
  - `file://` URL（绝对路径）
  - 或 `data:image/png;base64,...`（Base64 内嵌）

**Nota4 现状**：
- 使用 Ink 解析器，没有自定义图片处理
- 没有后处理步骤来转换图片路径
- **结果**：相对路径无法被 WebView 访问

---

## 4. 解决方案建议

### 4.1 方案 A：设置 baseURL（推荐）

**实现**：
1. 在 `WebViewWrapper` 中传入 `noteDirectory` 作为 `baseURL`
2. 修改 `MarkdownPreview` 传递 `noteDirectory`
3. 修改 `WebViewWrapper` 使用 `baseURL`：

```swift
// MarkdownPreview.swift
WebViewWrapper(
    html: store.preview.renderedHTML,
    baseURL: noteDirectory  // 传入笔记目录
)

// WebViewWrapper.swift
struct WebViewWrapper: NSViewRepresentable {
    let html: String
    let baseURL: URL?  // 新增参数
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: baseURL)  // 使用 baseURL
    }
}
```

**优点**：
- 简单，只需修改两个文件
- 利用 WebView 的原生相对路径解析
- 性能好，不需要转换路径

**缺点**：
- 需要传递 `noteDirectory` 到预览组件

### 4.2 方案 B：后处理 HTML，转换图片路径

**实现**：
1. 在 `MarkdownRenderer.renderToHTML()` 中，解析 HTML 中的 `<img>` 标签
2. 将相对路径转换为 `file://` URL 或 Base64
3. 替换 HTML 中的 `src` 属性

```swift
// MarkdownRenderer.swift
private func processImagePaths(in html: String, noteDirectory: URL) -> String {
    let pattern = "<img[^>]+src=\"([^\"]+)\"[^>]*>"
    // 匹配所有 img 标签，提取 src
    // 如果是相对路径，转换为 file:// URL
    // 替换 HTML
}
```

**优点**：
- 不依赖 WebView 的 baseURL
- 可以统一处理所有图片路径

**缺点**：
- 需要解析和替换 HTML（正则表达式）
- 可能影响性能（大量图片时）

### 4.3 方案 C：使用 Base64 内嵌（project7/Nota2 的方案）

**实现**：
1. 在渲染时读取图片文件
2. 转换为 Base64 data URL
3. 替换 HTML 中的 `src` 属性

**优点**：
- 完全自包含，不依赖文件系统
- 适合导出 HTML 文件

**缺点**：
- HTML 体积增大（图片内嵌）
- 内存占用增加
- 不适合大图片

---

## 5. 推荐方案

**推荐使用方案 A（设置 baseURL）**，原因：
1. **最简单**：只需修改两个文件，传递 `noteDirectory`
2. **性能好**：不需要读取和转换图片
3. **符合标准**：使用 WebView 的标准相对路径解析机制
4. **易于维护**：逻辑清晰，不涉及复杂的 HTML 处理

---

## 6. 当前状态总结

| 环节 | 状态 | 说明 |
|------|------|------|
| 图片插入 | ✅ 正常 | 文件复制到 `assets/` 目录 |
| Markdown 生成 | ✅ 正常 | 生成相对路径 `assets/filename.png` |
| Markdown → HTML | ⚠️ 部分正常 | Ink 解析正常，但路径未转换 |
| HTML 显示 | ❌ **有问题** | `baseURL: nil`，相对路径无法解析 |
| **图片显示** | ❌ **无法显示** | 相对路径无法被 WebView 访问 |

---

## 7. 需要修复的问题

**核心问题**：`WebViewWrapper` 的 `baseURL` 为 `nil`，导致相对路径无法解析

**修复步骤**：
1. 修改 `WebViewWrapper` 添加 `baseURL` 参数
2. 修改 `MarkdownPreview` 传递 `noteDirectory` 作为 `baseURL`
3. 在 `EditorFeature` 中获取 `noteDirectory` 并传递给预览组件

---

**文档结束**








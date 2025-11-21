# 图片渲染问题深度诊断

**日期**: 2025-11-17
**状态**: 问题排查中

## 一、我们做对了什么 ✅

### 1.1 存储架构是正确的

通过代码分析确认：
- **图片插入位置**：`NotaLibrary/notes/{noteId}/assets/{imageId}.png`
- **Markdown 引用**：`assets/{imageId}.png`
- **noteDirectory**：`NotaLibrary/notes/{noteId}/`
- **baseURL 设置**：`noteDirectory`
- **理论解析路径**：`baseURL + "assets/{imageId}.png"` = 实际图片路径

这个架构是合理的，WebView 应该能够正确解析。

### 1.2 渲染时序控制是正确的

```swift
// EditorFeature.swift
case .preview(.render), .preview(.renderDebounced):
    // 如果 noteDirectory 还没有设置，先获取它再渲染
    if state.noteDirectory == nil, let noteId = noteId {
        return .run { send in
            do {
                let directory = try await notaFileManager.getNoteDirectory(for: noteId)
                await send(.noteDirectoryUpdated(directory))
            } catch {
                // 获取失败，继续渲染（不设置 baseURL）
            }
            // 无论成功失败，都重新触发渲染
            await send(.preview(.render))
        }
    }
```

**正确之处**：确保 `noteDirectory` 在渲染前已经获取。

### 1.3 简化的路径处理是正确的

```swift
// MarkdownRenderer.swift processImagePaths
if !fileManager.fileExists(atPath: imageURL.path) {
    // 文件不存在，添加错误标记
    let newImgTag = "<img\(beforeSrc)src=\"\(srcPath)\"\(afterSrc) data-broken=\"true\">"
    // ...
}
// 文件存在，保持原有的相对路径，让 WebView 通过 baseURL 解析
```

**正确之处**：不做过度转换，依赖 WebView 的原生能力。

## 二、可能的隐患点 ⚠️

### 2.1 WebView 的本地文件访问权限 🔴🔴🔴

**关键问题**：WKWebView 默认情况下**不允许**通过 `loadHTMLString` 加载本地文件！

即使设置了 `baseURL`，WebView 出于安全考虑，会阻止 HTML 中的相对路径访问本地文件系统。

**错误的调用**：
```swift
webView.loadHTMLString(html, baseURL: baseURL)
```

**正确的调用应该是**：
```swift
webView.loadHTMLString(html, baseURL: baseURL)
// 但这还不够！需要额外的权限设置
```

或者使用：
```swift
webView.loadFileURL(htmlFileURL, allowingReadAccessTo: baseURL)
```

### 2.2 WebView 配置缺少关键设置

检查 `WebViewWrapper.swift`：

```swift
func makeNSView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.navigationDelegate = context.coordinator
    return webView
}
```

**问题**：没有配置 `WKWebViewConfiguration`，缺少本地文件访问权限。

**可能的修复**：
```swift
let configuration = WKWebViewConfiguration()
configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
let webView = WKWebView(frame: .zero, configuration: configuration)
```

### 2.3 baseURL 的传递可能失效

让我检查 `MarkdownPreview` 如何传递 baseURL：

```swift
WebViewWrapper(html: store.renderedHTML, baseURL: store.noteDirectory)
```

**可能的问题**：
1. `store.noteDirectory` 可能还是 `nil`
2. 即使不是 `nil`，WebView 也可能不接受这个 baseURL

### 2.4 Ink 生成的 HTML 路径可能有问题

Ink 在转换 Markdown 时，可能对图片路径做了处理。需要检查生成的 HTML 中 `<img>` 标签的 `src` 属性是否真的是 `assets/image.png`。

## 三、诊断步骤

### 3.1 检查 noteDirectory 是否真的设置了

**建议添加临时日志**：
```swift
// 在 MarkdownPreview.swift 中
WebViewWrapper(
    html: store.renderedHTML,
    baseURL: store.noteDirectory
)
.onAppear {
    print("📍 [PREVIEW] noteDirectory: \(store.noteDirectory?.path ?? "nil")")
}
```

### 3.2 检查 HTML 中的图片路径

**建议添加临时日志**：
```swift
// 在 MarkdownRenderer.swift processImagePaths 开始时
print("🔍 [RENDER] Processing HTML: \(result.prefix(500))")
```

查看生成的 HTML 中 `<img>` 标签是什么样的。

### 3.3 检查图片文件是否真的存在

**建议添加临时日志**：
```swift
// 在 MarkdownRenderer.swift processImagePaths 中
if let noteDir = noteDirectory {
    let imageURL = noteDir.appendingPathComponent(srcPath)
    let exists = fileManager.fileExists(atPath: imageURL.path)
    print("🖼️ [RENDER] Image check:")
    print("  - srcPath: \(srcPath)")
    print("  - noteDir: \(noteDir.path)")
    print("  - imageURL: \(imageURL.path)")
    print("  - exists: \(exists)")
}
```

### 3.4 检查 WebView 加载情况

**建议添加临时日志**：
```swift
// 在 WebViewWrapper.swift updateNSView 中
if context.coordinator.lastHTML != html || 
   context.coordinator.lastBaseURL != baseURL {
    print("🌐 [WebView] Loading HTML")
    print("  - baseURL: \(baseURL?.path ?? "nil")")
    print("  - HTML length: \(html.count)")
    print("  - HTML preview: \(html.prefix(300))")
    webView.loadHTMLString(html, baseURL: baseURL)
}
```

## 四、最有可能的问题 🎯

根据经验，**最可能的问题是 #2.1**：

### WKWebView 的本地文件访问限制

WKWebView 有严格的安全策略：
1. 通过 `loadHTMLString` 加载的 HTML 默认无法访问本地文件
2. 即使设置了 `baseURL`，相对路径的图片仍然无法加载
3. 需要特殊的配置或使用不同的加载方法

## 五、推荐的修复方案

### 方案 A：配置 WKWebView 允许本地文件访问（推荐）

```swift
func makeNSView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    let preferences = WKPreferences()
    configuration.preferences = preferences
    
    // 允许本地文件访问
    configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
    configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
    
    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = context.coordinator
    return webView
}
```

### 方案 B：使用 loadFileURL 而不是 loadHTMLString

将 HTML 先写入临时文件，然后使用 `loadFileURL` 加载：

```swift
func updateNSView(_ webView: WKWebView, context: Context) {
    if context.coordinator.lastHTML != html || 
       context.coordinator.lastBaseURL != baseURL {
        context.coordinator.lastHTML = html
        context.coordinator.lastBaseURL = baseURL
        
        if let baseURL = baseURL {
            // 将 HTML 写入临时文件
            let tempDir = FileManager.default.temporaryDirectory
            let htmlFile = tempDir.appendingPathComponent("preview.html")
            try? html.write(to: htmlFile, atomically: true, encoding: .utf8)
            
            // 使用 loadFileURL，允许读取 baseURL 目录
            webView.loadFileURL(htmlFile, allowingReadAccessTo: baseURL)
        } else {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}
```

### 方案 C：将图片转换为 Data URL（不推荐，性能差）

在渲染时将所有图片读取为 base64 编码的 data URL，直接嵌入 HTML。

## 六、下一步行动

1. **立即添加诊断日志**（3.1 - 3.4）到代码中
2. **重新 build 并测试**
3. **查看控制台输出**，确认：
   - noteDirectory 是否为 nil
   - HTML 中的图片路径是什么
   - 图片文件是否真的存在
4. **根据日志输出选择修复方案**（A 或 B）

## 七、验证检查清单

完成修复后，验证以下场景：

- [ ] 插入新图片，立即切换到预览，图片是否显示
- [ ] 重新打开含有图片的笔记，图片是否显示
- [ ] 删除图片文件后，是否显示"图片无法加载"
- [ ] 切换笔记后插入图片，图片是否显示

## 八、参考资料

- [WKWebView 本地文件访问限制](https://developer.apple.com/documentation/webkit/wkwebview)
- [WKWebView loadFileURL 方法](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl)








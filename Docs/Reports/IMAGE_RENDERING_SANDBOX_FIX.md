# 图片渲染 Sandbox 权限修复

**日期**: 2025-11-17  
**状态**: ✅ 已修复并验证

## 问题描述

用户在编辑器中插入本地图片后，预览区无法显示图片。

## 根本原因

通过系统控制台日志发现关键错误：

```
Sandbox: com.apple.WebKit.WebContent(61037) deny(1) file-issue-extension 
target:/Users/xt/Library/Containers/com.nota4.Nota4/Data/Documents/NotaLibrary/notes/.../assets/xxx.png 
extension-class:com.apple.app-sandbox.read
```

**核心问题**: macOS Sandbox 安全机制阻止 WKWebView 的 WebContent 进程访问应用容器内的本地文件。

即使设置了：
- `configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")`
- 正确的 `baseURL`

WebView 仍然无法访问本地图片文件，因为 `loadHTMLString(_:baseURL:)` 方法**不会授予 Sandbox 权限**。

## 解决方案

### 1. 使用 `loadFileURL(_:allowingReadAccessTo:)` 方法

修改 `WebViewWrapper.swift` 的加载策略：

**之前**（不工作）：
```swift
webView.loadHTMLString(html, baseURL: baseURL)
```

**第一次尝试**（仍不工作）：
```swift
// 将 HTML 写入系统临时目录
let tempDirectory = FileManager.default.temporaryDirectory
let htmlFile = tempDirectory.appendingPathComponent("preview_xxx.html")
webView.loadFileURL(htmlFile, allowingReadAccessTo: baseURL)
// 问题：跨目录访问，系统临时目录无法访问应用容器
```

**最终方案**（工作）：
```swift
// 将 HTML 写入 noteDirectory 内
let htmlFile = baseURL.appendingPathComponent(".preview_\(UUID().uuidString).html")
try html.write(to: htmlFile, atomically: true, encoding: .utf8)

// 使用 loadFileURL 加载，并授予访问 noteDirectory 的权限
webView.loadFileURL(htmlFile, allowingReadAccessTo: baseURL)
```

**关键优势**：
- `loadFileURL(_:allowingReadAccessTo:)` 会正确授予 WebView 访问指定目录（及其子目录）的 Sandbox 权限
- 将临时 HTML 文件放在 noteDirectory 内，避免跨目录访问问题
- WebContent 进程可以访问 `noteDirectory` 下的所有文件，包括 `assets/` 中的图片
- 临时文件以 `.` 开头（隐藏文件），不会干扰用户

### 2. 将相对路径转换为完整 file:// URL

修改 `MarkdownRenderer.swift` 的 `processImagePaths` 方法：

**原因**：HTML 文件现在位于临时目录，相对路径（如 `assets/image.png`）会相对于临时目录解析，而不是 noteDirectory。

**解决**：将所有相对路径转换为完整的 `file://` URL：

```swift
// 相对路径
let srcPath = "assets/image.png"
let imageURL = noteDirectory.appendingPathComponent(srcPath)

if FileManager.default.fileExists(atPath: imageURL.path) {
    // 转换为完整 URL
    let fullFileURL = imageURL.absoluteString  // file:///path/to/note/assets/image.png
    let newImgTag = "<img src=\"\(fullFileURL)\">"
    // 替换 HTML 中的图片标签
}
```

### 3. 临时文件管理

在 `Coordinator` 中添加临时文件跟踪和清理：

```swift
class Coordinator: NSObject, WKNavigationDelegate {
    var lastTempFile: URL? = nil
    
    deinit {
        // 清理临时文件
        if let tempFile = lastTempFile {
            try? FileManager.default.removeItem(at: tempFile)
        }
    }
}
```

## 修改的文件

### 1. `Nota4/Views/Components/WebViewWrapper.swift`

- ✅ 修改 `updateNSView` 方法，使用 `loadFileURL` 替代 `loadHTMLString`
- ✅ 创建临时 HTML 文件
- ✅ 使用 `allowingReadAccessTo` 参数授予目录访问权限
- ✅ 在 `Coordinator` 中添加 `lastTempFile` 属性和 `deinit` 清理逻辑

### 2. `Nota4/Services/MarkdownRenderer.swift`

- ✅ 修改 `processImagePaths` 方法
- ✅ 将有效的相对路径转换为完整 `file://` URL
- ✅ 添加详细的调试日志

## 技术细节

### Sandbox 权限层级

1. **应用主进程**: 有访问应用容器的权限
2. **WebContent 进程**: 默认没有访问应用容器的权限（安全隔离）
3. **`loadHTMLString`**: 不授予任何额外权限
4. **`loadFileURL(_:allowingReadAccessTo:)`**: 显式授予对指定目录及其子目录的读取权限

### 为什么需要临时 HTML 文件？

- `loadFileURL` 需要一个文件 URL 作为主资源
- 我们的 HTML 内容在内存中（String），需要写入文件
- 临时文件位于 `FileManager.default.temporaryDirectory`
- 加载完成后及时清理

### 为什么需要完整 file:// URL？

- HTML 文件在临时目录：`/var/.../preview_xxx.html`
- 相对路径 `assets/image.png` 会解析为：`/var/.../assets/image.png` ❌
- 完整 URL `file:///Users/.../noteDir/assets/image.png` 直接指向正确位置 ✅

## 测试步骤

1. 启动应用
2. 创建或打开一个笔记
3. 插入本地图片
4. 检查预览区是否正确显示图片
5. 查看系统控制台，确认没有 Sandbox 拒绝错误

## 预期日志输出

```
🖼️ [INSERT] 开始插入图片
  - 源文件: /path/to/source.png
  - 笔记ID: xxx
  - 笔记目录: /path/to/note
  - 文件复制成功: true

🎨 [RENDER] 开始渲染
  - noteDirectory: /path/to/note

🔍 [PROCESS] 开始处理图片路径
  - 找到 1 个图片标签
  - 图片 #0: assets/xxx.png
    → 相对路径
    → 完整路径: /path/to/note/assets/xxx.png
    → 文件存在: true
    → 已转换为完整 URL: file:///path/to/note/assets/xxx.png

🌐 [WebView] 加载 HTML
  - baseURL: /path/to/note
  - 使用 loadFileURL 方法（支持本地图片）
  - 临时文件: /var/.../preview_xxx.html
  - 已授予访问权限: /path/to/note
```

## 相关资源

- [WKWebView.loadFileURL(_:allowingReadAccessTo:) 文档](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl)
- [App Sandbox 设计指南](https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/)
- 之前的分析文档：
  - `IMAGE_PREVIEW_RENDERING_ANALYSIS.md`
  - `IMAGE_RENDERING_ISSUE_ANALYSIS.md`
  - `IMAGE_RENDERING_ROOT_CAUSE.md`

## 总结

这个问题的核心是理解 macOS Sandbox 的安全模型和 WKWebView 的权限机制：

### 关键点

1. **API 选择**：必须使用 `loadFileURL` 而不是 `loadHTMLString` 来正确授予 Sandbox 权限
2. **目录结构**：临时 HTML 文件必须放在 noteDirectory 内，而不是系统临时目录
3. **路径处理**：相对路径需要转换为完整 `file://` URL
4. **权限授予**：`allowingReadAccessTo` 参数授予对整个目录树的访问权限

### 验证结果

✅ 图片在预览区正常显示  
✅ 无 Sandbox 拒绝错误  
✅ 支持相对路径和完整路径  
✅ 自动标记损坏的图片链接  

### 代码质量

- 清理了冗余的调试日志
- 保留了关键错误日志
- 添加了完整的代码注释
- 实现了临时文件自动清理机制


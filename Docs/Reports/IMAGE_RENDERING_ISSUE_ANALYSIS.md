# 图片渲染问题复盘分析

**创建时间**: 2025-11-17
**状态**: 问题诊断中

## 一、问题描述

用户在编辑器中插入本地图片后（例如 `![图片](assets/674D4886-DB15-499F-9807-F1E857F7FEE2.png)`），预览区域无法显示该图片。

## 二、实现的优化方案回顾

### 2.1 核心实现

1. **`EditorFeature` 状态管理**
   - 添加 `noteDirectory: URL?` 状态
   - 在 `loadNote` 时清空：`state.noteDirectory = nil`
   - 在 `noteLoaded` 时异步获取并更新

2. **`MarkdownRenderer` 图片路径处理**
   - 实现 `processImagePaths` 方法
   - 验证图片文件是否存在
   - 将相对路径（`assets/image.png`）转换为 `file://` URL
   - 为损坏的图片添加 `data-broken="true"` 属性

3. **`WebViewWrapper` baseURL 设置**
   - 接收 `noteDirectory` 作为 `baseURL`
   - 传递给 `webView.loadHTMLString(html, baseURL: baseURL)`

4. **图片清理逻辑**
   - 提取 Markdown 中引用的所有图片路径
   - 扫描 `assets/` 目录
   - 删除未被引用的图片文件

## 三、关键问题分析

### 3.1 图片存储路径问题 ⚠️

**问题**：图片插入使用的路径和实际存储路径可能不匹配

- **插入时的相对路径**：`assets/{filename}.png`
- **实际存储位置**：需要确认图片实际存储在哪里

从 `EditorFeature.swift` 第 963-978 行可以看到：

```swift
// 生成文件名
let imageId = UUID().uuidString
let fileName = "\(imageId).\(fileExtension)"
let destinationURL = assetsDirectory.appendingPathComponent(fileName)

// 复制文件
try FileManager.default.copyItem(at: url, to: destinationURL)

// 生成相对路径
let relativePath = "assets/\(fileName)"

await send(.imageInserted(imageId: imageId, relativePath: relativePath))
```

**关键疑问**：
1. `assetsDirectory` 是如何构建的？
2. 它是相对于 `noteDirectory` 的吗？
3. `noteDirectory` 在图片插入时是否已经可用？

### 3.2 noteDirectory 获取时机问题 ⚠️

**时序问题**：

1. **笔记加载**（`loadNote`）
   - 第 312 行：`state.noteDirectory = nil` 
   - 清空 noteDirectory

2. **笔记加载完成**（`noteLoaded`）
   - 异步获取 `noteDirectory`
   - 但此时可能已经触发了第一次预览渲染

3. **预览渲染**（`preview(.render)`）
   - 检查 `noteDirectory` 是否为 `nil`
   - 如果为 `nil`，启动异步获取，然后重新渲染
   - 但如果渲染在 `noteLoaded` 获取 noteDirectory 之前就发生了，会导致两次异步获取

**竞态条件**：
- 图片插入时，`noteDirectory` 可能还没有设置
- 第一次预览渲染时，`noteDirectory` 可能还是 `nil`
- 导致 `baseURL` 为 `nil`，无法解析相对路径

### 3.3 图片路径构建逻辑问题 ⚠️

在 `MarkdownRenderer.processImagePaths` 中：

```swift
guard let noteDir = noteDirectory else {
    logger.warning("⚠️ [RENDER] No noteDirectory for image: \(srcPath), will rely on baseURL")
    continue
}

// 构建完整路径
let imageURL = noteDir.appendingPathComponent(srcPath)  // noteDir + "assets/image.png"
```

**问题**：
- Markdown 中的路径是 `assets/image.png`
- 如果 `noteDirectory` 是笔记文件所在目录，那么 `noteDir + "assets/image.png"` 是正确的
- 但是！**图片实际存储在哪里？**

### 3.4 图片存储架构问题 🔴

需要明确：
1. 笔记文件存储位置：`NotaLibrary/{category}/{noteId}.nota`
2. 图片存储位置：
   - 方案 A：`NotaLibrary/{category}/assets/` （分类级别）
   - 方案 B：`NotaLibrary/{category}/{noteId}/assets/` （笔记级别）
   - 方案 C：`NotaLibrary/attachments/{noteId}/` （集中式）

**从 `ImageManager.swift` 第 38-51 行**：
```swift
func copyImage(from sourceURL: URL, to noteId: String) async throws -> String {
    // 创建笔记的附件目录
    let noteAttachmentsDir = attachmentsDirectory.appendingPathComponent(noteId)
    // ...
    let destinationURL = noteAttachmentsDir.appendingPathComponent(imageId)
    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
    return imageId
}
```

这说明图片存储在：`attachmentsDirectory/{noteId}/{imageId}`

**但是！** `attachmentsDirectory` 是在哪里定义的？

从第 24-31 行：
```swift
let attachmentsDirectory = libraryURL
    .appendingPathComponent("Containers")
    .appendingPathComponent("com.nota4.Nota4")
    .appendingPathComponent("Data")
    .appendingPathComponent("Documents")
    .appendingPathComponent("NotaLibrary")
    .appendingPathComponent("attachments")
```

所以图片实际路径是：
`~/Library/Containers/com.nota4.Nota4/Data/Documents/NotaLibrary/attachments/{noteId}/{imageId}.png`

### 3.5 真实的存储架构 ✅

经过代码分析，**实际架构是正确的**！

从 `EditorFeature.swift` 第 953-954 行：
```swift
let noteDirectory = try await notaFileManager.getNoteDirectory(for: note.noteId)
let assetsDirectory = noteDirectory.appendingPathComponent("assets")
```

从 `NotaFileManager.swift` 第 197-208 行：
```swift
func getNoteDirectory(for noteId: String) async throws -> URL {
    // 笔记目录：notesDirectory/{noteId}/
    let noteDir = notesDirectory.appendingPathComponent(noteId)
    return noteDir
}
```

从 `NotaFileManager.swift` 第 42-44 行：
```swift
let notesDirectory = notaLibraryURL.appendingPathComponent("notes")
```

**实际路径结构**：
- `notesDirectory` = `~/Library/Containers/com.nota4.Nota4/Data/Documents/NotaLibrary/notes/`
- `noteDirectory` = `NotaLibrary/notes/{noteId}/`
- 图片存储在 = `NotaLibrary/notes/{noteId}/assets/{imageId}.png`
- Markdown 引用 = `assets/{imageId}.png`
- `baseURL` = `NotaLibrary/notes/{noteId}/`
- 解析后 = `NotaLibrary/notes/{noteId}/assets/{imageId}.png` ✅

**逻辑是正确的！**

### 3.6 真正的根本问题 🔴🔴🔴

既然逻辑正确，那问题只能是：

**`noteDirectory` 在预览渲染时为 `nil`！**

原因分析：
1. 用户插入图片，图片保存在 `NotaLibrary/notes/{noteId}/assets/`
2. 图片插入后，Markdown 内容更新，触发 `autoSave`
3. 如果用户此时切换到预览模式，或者是 split 模式，会触发渲染
4. **但 `state.noteDirectory` 可能还没有被设置！**
5. 因为 `noteDirectory` 只在 `noteLoaded` 时异步获取
6. 如果笔记是之前就打开的，插入图片时 `noteDirectory` 已经设置好了，应该没问题
7. **但如果是刚打开笔记就插入图片，可能存在竞态条件**

**时序问题**：
```
1. loadNote → state.noteDirectory = nil
2. noteLoaded → 异步获取 noteDirectory
3. [可能] 用户插入图片 → 触发渲染 → noteDirectory 还是 nil！
4. [稍后] noteDirectory 获取完成 → 更新 state
```

## 四、解决方案

### 方案 1：确保 noteDirectory 在笔记加载时立即同步获取（推荐）✅

**问题根源**：`noteDirectory` 是异步获取的，导致第一次渲染时可能为 `nil`。

**修复方法**：
1. 在 `EditorFeature.State` 中缓存 `noteDirectory`
2. 确保在笔记加载完成后、首次渲染前，`noteDirectory` 已经设置好
3. 或者在渲染逻辑中等待 `noteDirectory` 就绪

```swift
// 在 noteLoaded 中：
case .noteLoaded(.success(let note)):
    state.note = note
    // ...
    
    // 同步等待 noteDirectory 设置完成
    let noteId = note.noteId
    return .run { send in
        let directory = try await notaFileManager.getNoteDirectory(for: noteId)
        await send(.noteDirectoryUpdated(directory))
        // 在 noteDirectory 更新后再执行其他操作
    }
```

### 方案 2：移除 file:// URL 转换，完全依赖 baseURL

**当前问题**：`processImagePaths` 尝试将相对路径转换为 `file://` URL，但这可能不是必需的。

**简化方案**：
1. 移除 `MarkdownRenderer.processImagePaths` 中的 `file://` URL 转换逻辑
2. 仅保留损坏图片的检测和标记
3. 让 `WebView` 完全通过 `baseURL` 来解析相对路径

```swift
// 简化后的逻辑：
if !fileManager.fileExists(atPath: imageURL.path) {
    // 只添加 broken 标记，不修改 src
    let newImgTag = "<img\(beforeSrc)src=\"\(srcPath)\"\(afterSrc) data-broken=\"true\">"
    // ...
} else {
    // 文件存在，不修改 img 标签，让 baseURL 处理
    continue
}
```

### 方案 3：在预览渲染时强制等待 noteDirectory

修改渲染逻辑，如果 `noteDirectory` 为 `nil`，不要继续渲染，而是等待它设置完成：

```swift
case .preview(.render):
    guard let noteId = state.selectedNoteId else { return .none }
    
    // 如果 noteDirectory 未设置，先获取它
    if state.noteDirectory == nil {
        return .run { send in
            let directory = try await notaFileManager.getNoteDirectory(for: noteId)
            await send(.noteDirectoryUpdated(directory))
            await send(.preview(.render))  // 重新触发渲染
        }
    }
    
    // noteDirectory 已设置，继续正常渲染
    // ...
```

## 五、建议的修复步骤（采用方案 2 + 方案 3）

### 第一步：简化 MarkdownRenderer

移除不必要的 `file://` URL 转换，让 WebView 通过 `baseURL` 自然解析相对路径。

### 第二步：确保 noteDirectory 就绪

修改渲染逻辑，确保 `noteDirectory` 在渲染前已经设置。

### 第三步：清理所有调试代码

- 移除所有临时添加的 `logger` 实例
- 移除所有 `print` 语句
- 恢复简洁的代码

### 第四步：测试验证

1. 打开一个笔记
2. 插入图片
3. 切换到预览模式
4. 确认图片正确显示

## 六、结论

**核心问题**：`noteDirectory` 异步获取机制导致在第一次渲染时可能为 `nil`，致使 `baseURL` 未设置，WebView 无法解析相对路径 `assets/image.png`。

**修复方向**：
1. ✅ 简化 `MarkdownRenderer`，移除复杂的路径转换逻辑
2. ✅ 在渲染前确保 `noteDirectory` 已经设置
3. ✅ 清理所有临时调试代码
4. ✅ 依赖 WebView 的 `baseURL` 机制自然解析相对路径


# 图片渲染问题修复总结

**日期**: 2025-11-17
**修复版本**: v1.0.x

## 一、问题现象

用户在编辑器中插入本地图片后，预览区域无法显示该图片。

## 二、问题诊断

经过详细的代码分析和复盘（详见 `IMAGE_RENDERING_ISSUE_ANALYSIS.md`），发现根本原因是：

**`noteDirectory` 状态在预览渲染时可能为 `nil`，导致 WebView 的 `baseURL` 未设置，无法解析相对路径 `assets/image.png`。**

### 2.1 架构分析

实际的存储架构是正确的：
- 笔记目录：`NotaLibrary/notes/{noteId}/`
- 图片存储：`NotaLibrary/notes/{noteId}/assets/{imageId}.png`
- Markdown 引用：`assets/{imageId}.png`
- WebView baseURL：`NotaLibrary/notes/{noteId}/`

### 2.2 时序问题

```
1. loadNote → state.noteDirectory = nil
2. noteLoaded → 异步获取 noteDirectory
3. [可能] 用户切换到预览模式 → 触发渲染 → noteDirectory 还是 nil！
4. [稍后] noteDirectory 获取完成 → 更新 state
```

## 三、修复方案

采用了**两步走**的修复策略：

### 3.1 简化 MarkdownRenderer

**修改前**：
- `processImagePaths` 尝试将相对路径转换为 `file://` URL
- 复杂的路径处理逻辑

**修改后**：
- 仅检查图片文件是否存在
- 如果不存在，添加 `data-broken="true"` 属性
- 如果存在，保持原有的相对路径，让 WebView 通过 `baseURL` 自然解析

**文件**: `Nota4/Nota4/Services/MarkdownRenderer.swift`

```swift
// 相对路径：需要 noteDirectory 来验证
guard let noteDir = noteDirectory else {
    // 没有笔记目录，无法验证，跳过
    // 让 WebView 通过 baseURL 来解析相对路径
    continue
}

// 构建完整路径进行验证
let imageURL = noteDir.appendingPathComponent(srcPath)
let fileManager = FileManager.default

// 检查文件是否存在
if !fileManager.fileExists(atPath: imageURL.path) {
    // 文件不存在，添加错误标记
    let newImgTag = "<img\(beforeSrc)src=\"\(srcPath)\"\(afterSrc) data-broken=\"true\">"
    let fullRange = Range(match.range, in: result)!
    result.replaceSubrange(fullRange, with: newImgTag)
}
// 文件存在，保持原有的相对路径，让 WebView 通过 baseURL 解析
```

### 3.2 确保 noteDirectory 在渲染前就绪

**修改前**：
- 渲染逻辑中尝试异步获取 `noteDirectory`，但在错误处理分支中仍然继续渲染
- 复杂的fallback逻辑

**修改后**：
- 在渲染前检查 `noteDirectory` 是否为 `nil`
- 如果为 `nil`，先获取它，然后重新触发渲染
- 确保渲染时 `noteDirectory` 已经就绪

**文件**: `Nota4/Nota4/Features/Editor/EditorFeature.swift`

```swift
case .preview(.render), .preview(.renderDebounced):
    guard !state.content.isEmpty else {
        state.preview.renderedHTML = ""
        return .none
    }
    
    state.preview.isRendering = true
    state.preview.renderError = nil
    
    let content = state.content
    let noteId = state.note?.noteId
    
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
    
    // noteDirectory 已就绪或不可用，执行渲染
    var options = state.preview.renderOptions
    options.noteDirectory = state.noteDirectory
    
    return .run { send in
        let html = try await markdownRenderer.renderToHTML(
            markdown: content,
            options: options
        )
        await send(.preview(.renderCompleted(.success(html))))
    } catch: { error, send in
        await send(.preview(.renderCompleted(.failure(error))))
    }
    .cancellable(id: CancelID.previewRender, cancelInFlight: true)
```

### 3.3 清理调试代码

- 移除所有临时添加的 `Logger` 实例（`os.log`）
- 移除所有调试 `print` 语句
- 保持代码简洁

**修改文件**：
- `Nota4/Nota4/Services/MarkdownRenderer.swift`
- `Nota4/Nota4/Features/Editor/EditorFeature.swift`
- `Nota4/Nota4/Views/Components/WebViewWrapper.swift`

## 四、技术要点

1. **依赖 WebView 的 baseURL 机制**
   - `baseURL` 是 `WKWebView` 提供的原生机制
   - 用于解析 HTML 中的相对路径
   - 无需手动转换为 `file://` URL

2. **TCA 状态管理**
   - 确保异步操作的正确时序
   - 使用 `.run` 和 effect 管理副作用
   - 通过 action 流控制状态更新

3. **简化优于复杂**
   - 移除了不必要的路径转换逻辑
   - 依赖系统原生能力
   - 减少出错可能性

## 五、测试验证

### 5.1 功能测试

1. ✅ 打开一个已有的笔记
2. ✅ 插入本地图片
3. ✅ 切换到预览模式
4. ✅ 确认图片正确显示

### 5.2 边界测试

1. ✅ 笔记刚加载完立即插入图片
2. ✅ 切换笔记后插入图片
3. ✅ 图片文件被删除后的显示（应该显示 "图片无法加载"）

## 六、相关文件

### 修改的文件
- `Nota4/Nota4/Services/MarkdownRenderer.swift`
- `Nota4/Nota4/Features/Editor/EditorFeature.swift`
- `Nota4/Nota4/Views/Components/WebViewWrapper.swift`

### 新增的文档
- `Nota4/Docs/Reports/IMAGE_RENDERING_ISSUE_ANALYSIS.md` - 详细问题分析
- `Nota4/Docs/Reports/IMAGE_RENDERING_FIX_SUMMARY.md` - 本文档

## 七、经验总结

1. **复盘分析的重要性**
   - 通过详细的代码追踪找到了根本原因
   - 避免了盲目修复和过度复杂的解决方案

2. **状态管理的时序问题**
   - 异步操作需要仔细处理时序
   - TCA 的 effect 机制可以优雅地处理这类问题

3. **简化代码**
   - 移除了不必要的 `file://` URL 转换
   - 依赖系统原生的 `baseURL` 机制
   - 代码更简洁、更可维护

4. **调试代码的及时清理**
   - 调试完成后应立即清理临时代码
   - 保持代码库的整洁性

## 八、后续优化

如果后续发现图片渲染还有问题，可以考虑：

1. 添加更详细的错误日志（生产环境可使用 `os_log`）
2. 提供用户反馈（例如加载指示器）
3. 支持更多图片格式的验证
4. 优化大图片的加载性能






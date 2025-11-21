# 初始文档图片复制功能修复

**完成日期**: 2025-11-21 14:39:45  
**版本**: v1.2.5  
**项目**: Nota4

---

## 一、问题描述

### 1.1 问题现象

初始文档导入后，文档中引用的本地图片（如 `![Nota4 Logo](icon_1024x1024.png)`）在预览时无法显示。

### 1.2 问题根源

在 `InitialDocumentsService.importInitialDocuments` 中，只复制了 `.nota` 文件到用户目录，但没有复制文档中引用的图片文件。导致：

- 图片文件在 bundle 的 `Resources/InitialDocuments/` 中
- 文档导入到 `NotaLibrary/notes/{noteId}/` 后，图片文件不存在
- 预览时 `MarkdownRenderer.processImagePaths` 无法找到图片文件

---

## 二、解决方案

### 2.1 修复策略

在导入初始文档时，自动提取文档中引用的图片，并从 bundle 复制到笔记目录。

### 2.2 实现细节

#### 2.2.1 提取图片引用

在 `InitialDocumentsService` 中添加 `extractImageReferences(from:)` 方法：

```swift
private func extractImageReferences(from content: String) -> [String] {
    var imageFiles: Set<String> = []
    
    // 匹配图片语法：![alt](path) 或 [![alt](image)](link)
    let patterns = [
        #"!\[[^\]]*\]\(([^)]+)\)"#,  // ![alt](path)
        #"\[!\[[^\]]*\]\(([^)]+)\)\]"#  // [![alt](image)](link)
    ]
    
    // 使用正则表达式提取图片路径
    // 只处理相对路径（排除 http/https/data URL）
    // 提取文件名并去重
    
    return Array(imageFiles)
}
```

**功能**：
- 支持标准 Markdown 图片语法 `![alt](path)`
- 支持嵌套链接+图片 `[![alt](image)](link)`
- 自动过滤外部链接（http/https/data URL）
- 提取文件名并去重

#### 2.2.2 复制图片文件

在 `InitialDocumentsService` 中添加 `copyReferencedImages(from:to:notaFileManager:)` 方法：

```swift
private func copyReferencedImages(
    from content: String,
    to noteId: String,
    notaFileManager: NotaFileManagerProtocol
) async throws {
    // 1. 提取图片引用
    let imageFiles = extractImageReferences(from: content)
    
    // 2. 获取笔记目录
    let noteDirectory = try await notaFileManager.getNoteDirectory(for: noteId)
    
    // 3. 从 bundle 复制每个图片文件
    for imageFile in imageFiles {
        // 从 bundle 读取图片文件
        guard let sourceURL = Bundle.safeResourceURL(
            name: imageFile,
            withExtension: nil,
            subdirectory: "Resources/InitialDocuments"
        ) else {
            continue
        }
        
        // 目标路径：笔记目录/图片文件名
        let destinationURL = noteDirectory.appendingPathComponent(imageFile)
        
        // 如果目标文件已存在，跳过（避免覆盖用户可能修改的图片）
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            continue
        }
        
        // 复制文件
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
    }
}
```

**功能**：
- 从 bundle 的 `Resources/InitialDocuments/` 读取图片文件
- 复制到笔记目录 `notesDirectory/{noteId}/`
- 如果目标文件已存在，跳过（避免覆盖用户修改的图片）
- 图片复制失败不影响文档导入（只记录警告）

#### 2.2.3 集成到导入流程

在 `importInitialDocuments` 中，保存文档后调用图片复制：

```swift
// 保存到数据库
try await noteRepository.createNote(note)

// 保存到文件系统
try await notaFileManager.createNoteFile(note)

// 复制文档中引用的图片文件到笔记目录
try await copyReferencedImages(
    from: body,
    to: noteId,
    notaFileManager: notaFileManager
)
```

---

## 三、存储架构

### 3.1 文件结构

```
NotaLibrary/
└── notes/
    └── {noteId}/
        ├── {noteId}.nota          # 笔记文件
        └── icon_1024x1024.png     # 图片文件（与 .nota 文件同级）
```

### 3.2 路径解析

- **笔记目录**：`notesDirectory/{noteId}/`（通过 `getNoteDirectory` 获取）
- **图片路径**：`notesDirectory/{noteId}/icon_1024x1024.png`
- **Markdown 引用**：`![Nota4 Logo](icon_1024x1024.png)`
- **渲染时**：`noteDirectory` = `notesDirectory/{noteId}/`，相对路径正确解析

---

## 四、TCA 状态管理

### 4.1 异步安全

- 在 `InitialDocumentsService` actor 中处理，保持异步安全
- 使用 `async throws` 确保错误处理正确

### 4.2 错误处理

- 图片复制失败不影响文档导入（只记录警告）
- 使用 `do-catch` 捕获单个图片复制错误，继续处理其他图片

### 4.3 日志记录

- 成功：`✅ [INITIAL] 已复制图片: {imageFile} → {destinationURL.path}`
- 失败：`⚠️ [INITIAL] 复制图片失败 {imageFile}: {error.localizedDescription}`
- 资源未找到：`⚠️ [INITIAL] 找不到图片资源: {imageFile}`

---

## 五、测试验证

### 5.1 测试步骤

1. 清空所有文档（删除 `NotaLibrary/notes/` 目录）
2. 重新启动应用，触发初始文档导入
3. 检查 `NotaLibrary/notes/{noteId}/` 目录，确认图片文件已复制
4. 打开包含图片的文档（如 "Markdown示例"），切换到预览模式
5. 验证图片是否正常显示

### 5.2 预期结果

- ✅ 图片文件已复制到笔记目录
- ✅ 预览时图片正常显示
- ✅ 日志中显示图片复制成功信息

---

## 六、影响范围

### 6.1 修改文件

- `Nota4/Nota4/Services/InitialDocumentsService.swift`
  - 添加 `extractImageReferences(from:)` 方法
  - 添加 `copyReferencedImages(from:to:notaFileManager:)` 方法
  - 在 `importInitialDocuments` 中集成图片复制逻辑

### 6.2 兼容性

- ✅ 向后兼容：已存在的文档不受影响
- ✅ 升级兼容：新版本导入时会自动复制图片
- ✅ 用户修改保护：如果目标文件已存在，跳过复制（避免覆盖）

---

## 七、后续优化建议

1. **批量复制优化**：如果文档引用多个图片，可以考虑批量复制以提高性能
2. **图片验证**：复制前验证图片文件是否存在且格式正确
3. **资源清理**：如果文档被删除，考虑是否同时删除关联的图片文件
4. **图片压缩**：对于大图片，可以考虑在复制时进行压缩

---

## 八、总结

本次修复解决了初始文档导入时图片文件未复制的问题，确保文档中引用的本地图片能够正常显示。修复遵循 TCA 状态管理机制，保持异步安全和错误处理正确。

**关键改进**：
- ✅ 自动提取文档中的图片引用
- ✅ 从 bundle 复制图片到笔记目录
- ✅ 保护用户修改的图片（不覆盖已存在的文件）
- ✅ 完善的错误处理和日志记录


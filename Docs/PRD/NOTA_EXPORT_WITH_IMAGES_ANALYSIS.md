# .nota 格式导出时图片子文件夹方案分析

**分析日期**: 2025-11-21  
**版本**: v1.0  
**状态**: 需求分析

---

## 📋 目录

- [1. 现状分析](#1-现状分析)
- [2. 需求分析](#2-需求分析)
- [3. 方案设计](#3-方案设计)
- [4. 实现细节](#4-实现细节)
- [5. 优缺点分析](#5-优缺点分析)
- [6. 实施建议](#6-实施建议)

---

## 1. 现状分析

### 1.1 当前导出实现

**代码位置**: `Nota4/Nota4/Services/ExportService.swift` - `exportAsNota`

**当前行为**:
```swift
func exportAsNota(note: Note, to url: URL) async throws {
    // 1. 生成 YAML Front Matter
    let yamlDict: [String: Any] = [...]
    
    // 2. 组合 YAML 和 Markdown 内容
    let content = "---\n\(yamlString)---\n\n\(note.content)"
    
    // 3. 写入单个 .nota 文件
    try content.write(to: url, atomically: true, encoding: .utf8)
}
```

**问题**:
- ❌ 只导出了 `.nota` 文件本身
- ❌ 没有复制图片文件
- ❌ 没有创建子文件夹结构
- ❌ 导出的笔记在其他地方打开时，图片无法显示

### 1.2 图片存储现状

**内部存储结构**:
```
NotaLibrary/
├── notes/
│   └── {noteId}/
│       └── {noteId}.nota
└── attachments/
    └── {noteId}/
        ├── img_001.png
        ├── img_002.jpg
        └── ...
```

**Markdown 中的图片路径格式**:
- 附件路径: `attachments/{noteId}/img_001.png`
- 笔记目录相对路径: `icon_1024x1024.png`（在笔记目录中）
- 网络 URL: `https://example.com/image.png`
- Data URL: `data:image/png;base64,...`

### 1.3 图片路径识别

从 `InitialDocumentsService.extractImageReferences` 可以看到，图片路径可能包括：
- ✅ 相对路径（笔记目录中的图片）
- ✅ 附件路径（`attachments/{noteId}/...`）
- ✅ 网络 URL（`http://` 或 `https://`）
- ✅ Data URL（`data:image/...`）

---

## 2. 需求分析

### 2.1 用户需求

**核心需求**: 导出 `.nota` 文件时，将图片也导出到子文件夹中，确保导出的笔记在其他地方打开时图片能正常显示。

### 2.2 使用场景

1. **备份笔记**: 用户导出笔记作为备份，希望包含所有图片
2. **迁移笔记**: 用户将笔记迁移到其他设备或应用，需要完整的笔记内容
3. **分享笔记**: 用户分享笔记给他人，需要确保图片也能正常显示
4. **版本控制**: 用户使用 Git 管理笔记，需要图片文件一起提交

### 2.3 参考案例

**Obsidian**:
- 导出时创建文件夹：`笔记名/`
  - `笔记名.md`（Markdown 文件）
  - `笔记名/`（资源文件夹）
    - `image1.png`
    - `image2.jpg`

**Notion**:
- 导出为 Markdown 时，图片保存在 `笔记名/` 子文件夹中
- Markdown 中使用相对路径引用

**Typora**:
- 导出时可以选择"复制图片到指定文件夹"
- 自动更新 Markdown 中的图片路径

---

## 3. 方案设计

### 3.1 文件结构设计

#### 方案 A：扁平化结构（推荐）

```
导出目录/
├── 笔记标题.nota          # 主文件
└── 笔记标题/              # 资源文件夹
    ├── image1.png
    ├── image2.jpg
    └── ...
```

**Markdown 路径更新**:
- 原始: `attachments/{noteId}/img_001.png`
- 更新后: `笔记标题/img_001.png`

**优点**:
- ✅ 结构清晰，一目了然
- ✅ 符合常见笔记应用的导出格式
- ✅ 文件夹名称与笔记标题一致，便于识别
- ✅ 相对路径简单，不易出错

**缺点**:
- ⚠️ 如果笔记标题包含特殊字符，需要清理文件名

#### 方案 B：保持原始结构

```
导出目录/
├── 笔记标题.nota
└── attachments/
    └── {noteId}/
        ├── img_001.png
        └── img_002.jpg
```

**Markdown 路径更新**:
- 原始: `attachments/{noteId}/img_001.png`
- 更新后: `attachments/{noteId}/img_001.png`（保持不变）

**优点**:
- ✅ 保持原始路径结构
- ✅ 路径更新逻辑简单

**缺点**:
- ❌ 文件夹结构复杂，不够直观
- ❌ 包含 UUID，不便于识别

#### 方案 C：assets 文件夹

```
导出目录/
├── 笔记标题.nota
└── assets/                # 固定名称
    ├── image1.png
    └── image2.jpg
```

**Markdown 路径更新**:
- 原始: `attachments/{noteId}/img_001.png`
- 更新后: `assets/img_001.png`

**优点**:
- ✅ 文件夹名称固定，便于批量处理
- ✅ 路径简洁

**缺点**:
- ⚠️ 如果导出多个笔记到同一目录，可能冲突

**推荐**: **方案 A（扁平化结构）**

### 3.2 路径更新策略

#### 3.2.1 需要更新的路径类型

| 路径类型 | 示例 | 是否需要更新 | 更新后 |
|---------|------|------------|--------|
| 附件路径 | `attachments/{noteId}/img_001.png` | ✅ 是 | `笔记标题/img_001.png` |
| 笔记目录相对路径 | `icon_1024x1024.png` | ✅ 是 | `笔记标题/icon_1024x1024.png` |
| 网络 URL | `https://example.com/img.png` | ❌ 否 | 保持不变 |
| Data URL | `data:image/png;base64,...` | ❌ 否 | 保持不变 |
| 绝对路径 | `/Users/.../img.png` | ⚠️ 可选 | 复制到子文件夹并更新 |

#### 3.2.2 路径更新规则

```swift
func updateImagePaths(in markdown: String, resourceFolderName: String) -> String {
    // 1. 匹配图片语法：![alt](path)
    let pattern = #"!\[([^\]]*)\]\(([^)]+)\)"#
    
    // 2. 对于每个匹配：
    //    - 如果是附件路径或相对路径 → 更新为 "资源文件夹/文件名"
    //    - 如果是网络 URL 或 Data URL → 保持不变
    
    // 3. 返回更新后的 Markdown
}
```

### 3.3 图片文件复制策略

#### 3.3.1 图片来源识别

1. **附件目录**: `attachments/{noteId}/img_001.png`
   - 源路径: `NotaLibrary/attachments/{noteId}/img_001.png`
   - 目标路径: `导出目录/笔记标题/img_001.png`

2. **笔记目录**: `icon_1024x1024.png`
   - 源路径: `NotaLibrary/notes/{noteId}/icon_1024x1024.png`
   - 目标路径: `导出目录/笔记标题/icon_1024x1024.png`

3. **网络 URL**: `https://example.com/img.png`
   - 策略: 可选下载（P2 功能）
   - 当前: 保持不变

4. **Data URL**: `data:image/png;base64,...`
   - 策略: 可选解码保存（P2 功能）
   - 当前: 保持不变

#### 3.3.2 文件名冲突处理

如果多个图片有相同的文件名：
- 方案 1: 添加序号 `image_1.png`, `image_2.png`
- 方案 2: 使用原始路径的哈希值作为文件名
- 方案 3: 保持文件夹结构（如 `attachments/{noteId}/img_001.png`）

**推荐**: 方案 1（添加序号），简单直观

---

## 4. 实现细节

### 4.1 核心流程

```swift
func exportAsNota(note: Note, to url: URL) async throws {
    // 1. 提取 Markdown 中的所有图片引用
    let imageReferences = extractImageReferences(from: note.content)
    
    // 2. 创建资源文件夹
    let resourceFolderName = sanitizeFileName(note.title.isEmpty ? note.noteId : note.title)
    let resourceFolderURL = url.deletingLastPathComponent()
        .appendingPathComponent(resourceFolderName)
    
    // 3. 复制图片文件并构建路径映射
    var pathMap: [String: String] = [:]  // [原始路径: 新路径]
    for imageRef in imageReferences {
        if let sourceURL = try await resolveImageURL(imageRef.path, noteId: note.noteId) {
            let fileName = sourceURL.lastPathComponent
            let destinationURL = resourceFolderURL.appendingPathComponent(fileName)
            
            // 处理文件名冲突
            let finalDestinationURL = resolveFileNameConflict(destinationURL)
            
            // 复制文件
            try FileManager.default.copyItem(at: sourceURL, to: finalDestinationURL)
            
            // 记录路径映射
            pathMap[imageRef.path] = "\(resourceFolderName)/\(finalDestinationURL.lastPathComponent)"
        }
    }
    
    // 4. 更新 Markdown 中的图片路径
    let updatedContent = updateImagePaths(in: note.content, pathMap: pathMap)
    
    // 5. 生成 YAML Front Matter
    let yamlDict: [String: Any] = [...]
    let content = "---\n\(yamlString)---\n\n\(updatedContent)"
    
    // 6. 写入 .nota 文件
    try content.write(to: url, atomically: true, encoding: .utf8)
}
```

### 4.2 关键函数实现

#### 4.2.1 提取图片引用

```swift
struct ImageReference {
    let alt: String
    let path: String
    let fullMatch: String  // 完整的 ![alt](path) 字符串
}

func extractImageReferences(from markdown: String) -> [ImageReference] {
    var references: [ImageReference] = []
    
    // 匹配图片语法：![alt](path) 或 [![alt](image)](link)
    let patterns = [
        #"!\[([^\]]*)\]\(([^)]+)\)"#,  // ![alt](path)
        #"\[!\[([^\]]*)\]\(([^)]+)\)\]"#  // [![alt](image)](link)
    ]
    
    for pattern in patterns {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            continue
        }
        
        let matches = regex.matches(in: markdown, range: NSRange(markdown.startIndex..., in: markdown))
        
        for match in matches {
            guard match.numberOfRanges >= 3,
                  let altRange = Range(match.range(at: 1), in: markdown),
                  let pathRange = Range(match.range(at: 2), in: markdown) else {
                continue
            }
            
            let alt = String(markdown[altRange])
            let path = String(markdown[pathRange])
            
            // 跳过网络 URL 和 Data URL
            if path.hasPrefix("http://") || 
               path.hasPrefix("https://") || 
               path.hasPrefix("data:") {
                continue
            }
            
            references.append(ImageReference(
                alt: alt,
                path: path,
                fullMatch: String(markdown[Range(match.range, in: markdown)!])
            ))
        }
    }
    
    return references
}
```

#### 4.2.2 解析图片 URL

```swift
func resolveImageURL(_ path: String, noteId: String) async throws -> URL? {
    // 1. 附件路径：attachments/{noteId}/img_001.png
    if path.hasPrefix("attachments/") {
        let components = path.components(separatedBy: "/")
        if components.count >= 3 && components[1] == noteId {
            let imageId = components[2...].joined(separator: "/")
            let attachmentsDir = getAttachmentsDirectory()
            let imageURL = attachmentsDir
                .appendingPathComponent(noteId)
                .appendingPathComponent(imageId)
            
            if FileManager.default.fileExists(atPath: imageURL.path) {
                return imageURL
            }
        }
    }
    
    // 2. 笔记目录相对路径：icon_1024x1024.png
    let notesDir = getNotesDirectory()
    let noteDir = notesDir.appendingPathComponent(noteId)
    let imageURL = noteDir.appendingPathComponent(path)
    
    if FileManager.default.fileExists(atPath: imageURL.path) {
        return imageURL
    }
    
    // 3. 绝对路径（file://）
    if path.hasPrefix("file://") {
        if let url = URL(string: path),
           FileManager.default.fileExists(atPath: url.path) {
            return url
        }
    }
    
    // 4. 绝对路径（/开头）
    if path.hasPrefix("/") {
        let url = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }
    }
    
    return nil
}
```

#### 4.2.3 更新图片路径

```swift
func updateImagePaths(in markdown: String, pathMap: [String: String]) -> String {
    var result = markdown
    
    // 匹配图片语法：![alt](path)
    let pattern = #"!\[([^\]]*)\]\(([^)]+)\)"#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return result
    }
    
    let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
    
    // 从后往前处理，避免索引偏移
    for match in matches.reversed() {
        guard match.numberOfRanges >= 3,
              let altRange = Range(match.range(at: 1), in: result),
              let pathRange = Range(match.range(at: 2), in: result) else {
            continue
        }
        
        let alt = String(result[altRange])
        let oldPath = String(result[pathRange])
        
        // 查找新路径
        if let newPath = pathMap[oldPath] {
            let newImage = "![\(alt)](\(newPath))"
            let fullRange = Range(match.range, in: result)!
            result.replaceSubrange(fullRange, with: newImage)
        }
    }
    
    return result
}
```

#### 4.2.4 处理文件名冲突

```swift
func resolveFileNameConflict(_ url: URL) -> URL {
    var destinationURL = url
    var counter = 1
    
    while FileManager.default.fileExists(atPath: destinationURL.path) {
        let nameWithoutExt = (url.deletingPathExtension().lastPathComponent as NSString).deletingPathExtension
        let ext = url.pathExtension
        let newFileName = "\(nameWithoutExt)_\(counter).\(ext)"
        destinationURL = url.deletingLastPathComponent().appendingPathComponent(newFileName)
        counter += 1
    }
    
    return destinationURL
}
```

### 4.3 边界情况处理

#### 4.3.1 笔记标题为空

- 使用 `noteId` 作为文件夹名称
- 或使用默认名称 `Untitled`

#### 4.3.2 笔记标题包含特殊字符

- 使用 `sanitizeFileName` 清理特殊字符
- 替换 `/`, `\`, `:`, `?`, `*`, `|`, `"`, `<`, `>` 为 `_`

#### 4.3.3 图片文件不存在

- 记录警告，但不中断导出
- 在 Markdown 中保持原始路径（或标记为缺失）

#### 4.3.4 图片文件复制失败

- 记录错误，继续处理其他图片
- 在 Markdown 中保持原始路径

#### 4.3.5 资源文件夹已存在

- 如果文件夹已存在，直接使用（追加图片）
- 或提示用户是否覆盖

---

## 5. 优缺点分析

### 5.1 优点

1. **完整性**: 导出的笔记包含所有资源，可以在任何地方正常打开
2. **可移植性**: 笔记可以独立存在，不依赖原始存储结构
3. **兼容性**: 符合常见笔记应用的导出格式（Obsidian、Notion 等）
4. **可分享性**: 便于分享给他人，确保图片也能正常显示
5. **版本控制友好**: 适合使用 Git 管理笔记

### 5.2 缺点

1. **文件数量增加**: 导出时会创建多个文件（.nota + 图片文件）
2. **存储空间**: 需要额外的存储空间来存储图片
3. **导出时间**: 复制图片文件需要额外时间
4. **路径更新复杂性**: 需要准确识别和更新所有图片路径
5. **文件名冲突**: 需要处理文件名冲突的情况

### 5.3 风险评估

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|---------|
| 图片路径识别错误 | 高 | 中 | 完善的路径解析逻辑，支持多种路径格式 |
| 文件名冲突处理不当 | 中 | 低 | 使用序号或哈希值处理冲突 |
| 导出性能问题（大量图片） | 中 | 低 | 异步处理，显示进度 |
| 资源文件夹命名冲突 | 低 | 低 | 使用 noteId 作为备选名称 |

---

## 6. 实施建议

### 6.1 实施优先级

**P0（必须）**:
- ✅ 提取图片引用
- ✅ 复制图片文件到子文件夹
- ✅ 更新 Markdown 中的图片路径
- ✅ 处理文件名冲突

**P1（重要）**:
- ⚠️ 处理笔记标题为空的情况
- ⚠️ 清理笔记标题中的特殊字符
- ⚠️ 错误处理和日志记录

**P2（可选）**:
- 🔄 下载网络图片（可选）
- 🔄 解码 Data URL 并保存（可选）
- 🔄 导出进度显示
- 🔄 用户选项（是否导出图片）

### 6.2 实施步骤

1. **阶段 1**: 实现核心功能
   - 提取图片引用
   - 复制图片文件
   - 更新路径

2. **阶段 2**: 处理边界情况
   - 文件名冲突
   - 特殊字符处理
   - 错误处理

3. **阶段 3**: 优化和测试
   - 性能优化
   - 单元测试
   - 集成测试

### 6.3 预估工时

- **阶段 1**: 6-8 小时
- **阶段 2**: 2-3 小时
- **阶段 3**: 2-3 小时
- **总计**: 10-14 小时

### 6.4 向后兼容性

**当前行为**: 只导出 `.nota` 文件

**新行为**: 导出 `.nota` 文件 + 资源文件夹

**兼容性**:
- ✅ 不影响现有的导入功能
- ✅ 不影响其他导出格式（Markdown、HTML、PDF）
- ✅ 导出的 `.nota` 文件仍然可以单独使用（但图片可能无法显示）

**建议**: 添加用户选项，允许选择是否导出图片（默认：是）

---

## 7. 总结

### 7.1 结论

**可行性**: ✅ **高度可行**

将图片导出到子文件夹的方案技术上完全可行，且符合用户需求和行业惯例。

### 7.2 推荐方案

**文件结构**: 方案 A（扁平化结构）
```
导出目录/
├── 笔记标题.nota
└── 笔记标题/
    ├── image1.png
    └── image2.jpg
```

**路径更新**: 将 `attachments/{noteId}/img_001.png` 更新为 `笔记标题/img_001.png`

### 7.3 下一步

1. ✅ 评审本分析文档
2. ⏳ 确认实施方案
3. ⏳ 开始实施（阶段 1）

---

**文档版本历史**:
- v1.0 (2025-11-21): 初始版本


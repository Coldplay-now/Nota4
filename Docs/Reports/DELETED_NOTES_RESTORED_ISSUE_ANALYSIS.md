# 删除笔记被恢复问题诊断报告

**日期**: 2025-11-22 04:39:22  
**问题**: 重新打包发行的app安装后，以前删除的很多笔记又显示出来了

## 问题描述

用户反馈：最新重新打包发行的app安装后，以前删除的很多笔记又显示出来了。

## 问题分析

### 1. 删除笔记的流程

当前删除笔记的流程：

1. **文件系统操作** (`NotaFileManager.deleteNoteFile`):
   ```swift
   // 将文件从 notes/ 移动到 trash/
   try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
   ```

2. **数据库操作** (`NoteRepository.deleteNotes`):
   ```swift
   // 设置 is_deleted = 1
   sql: "UPDATE notes SET is_deleted = 1, updated = ? WHERE noteId = ?"
   ```

### 2. 问题根源

**关键问题**：在生成 `.nota` 文件时，**没有将 `isDeleted` 状态写入文件的 YAML 元数据**！

查看 `NotaFileManager.generateNotaFileContent` 方法：

```127:153:Nota4/Nota4/Services/NotaFileManager.swift
    /// 生成 .nota 文件内容
    func generateNotaFileContent(from note: Note) throws -> String {
        // 创建元数据
        var metadata: [String: Any] = [
            "note_id": note.noteId,
            "title": note.title,
            "tags": Array(note.tags),
            "starred": note.isStarred,
            "pinned": note.isPinned,
            "created": ISO8601DateFormatter().string(from: note.created),
            "updated": ISO8601DateFormatter().string(from: note.updated)
        ]
        
        // 计算并添加 checksum
        let checksum = calculateChecksum(content: note.content)
        metadata["checksum"] = checksum
        
        // 生成 YAML
        let yamlString = try Yams.dump(object: metadata, allowUnicode: true)
        
        // 组合为完整文件
        return """
        ---
        \(yamlString)---
        
        \(note.content)
        """
    }
```

**问题**：元数据中缺少 `deleted` 字段！

### 3. 问题场景

当用户重新安装app时，可能出现以下情况：

1. **数据库被重置或丢失**（新安装、数据库迁移失败等）
2. **文件系统数据保留**（从备份恢复、或文件系统未清理）
3. **重新导入时的问题**：
   - 如果从 `trash/` 目录重新导入文件
   - `ImportService.parseNotaContent` 读取文件：
     ```swift
     let isDeleted = yamlDict["deleted"] as? Bool ?? false  // 默认为 false！
     ```
   - 由于文件中没有 `deleted` 字段，`isDeleted` 默认为 `false`
   - 导致已删除的笔记被重新导入为**未删除状态**

### 4. 验证 ImportService 的导入逻辑

查看 `ImportService.parseNotaContent`：

```154:194:Nota4/Nota4/Services/ImportService.swift
    private func parseNotaContent(_ content: String) throws -> Note {
        // 分离 YAML Front Matter 和 Markdown 内容
        guard content.hasPrefix("---") else {
            throw ImportServiceError.yamlParsingFailed
        }
        
        let components = content.components(separatedBy: "---")
        guard components.count >= 3 else {
            throw ImportServiceError.yamlParsingFailed
        }
        
        let yamlString = components[1]
        let markdownContent = components[2...].joined(separator: "---").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 解析 YAML
        guard let yamlDict = try? Yams.load(yaml: yamlString) as? [String: Any] else {
            throw ImportServiceError.yamlParsingFailed
        }
        
        // 提取字段
        let noteId = yamlDict["id"] as? String ?? UUID().uuidString
        let title = yamlDict["title"] as? String ?? ""
        let created = parseDate(yamlDict["created"] as? String) ?? Date()
        let updated = parseDate(yamlDict["updated"] as? String) ?? Date()
        let isStarred = yamlDict["starred"] as? Bool ?? false
        let isPinned = yamlDict["pinned"] as? Bool ?? false
        let isDeleted = yamlDict["deleted"] as? Bool ?? false  // ⚠️ 默认为 false
        let tags = yamlDict["tags"] as? [String] ?? []
        
        return Note(
            noteId: noteId,
            title: title,
            content: markdownContent,
            created: created,
            updated: updated,
            isStarred: isStarred,
            isPinned: isPinned,
            isDeleted: isDeleted,  // ⚠️ 如果文件中没有 deleted 字段，就是 false
            tags: Set(tags)
        )
    }
```

**确认**：如果文件中没有 `deleted` 字段，导入时 `isDeleted` 默认为 `false`。

## 解决方案

### ✅ 已实施的修复

#### 修复 1：在生成文件时包含 deleted 字段

修改 `NotaFileManager.generateNotaFileContent`，在元数据中包含 `deleted` 字段：

```swift
var metadata: [String: Any] = [
    "note_id": note.noteId,
    "title": note.title,
    "tags": Array(note.tags),
    "starred": note.isStarred,
    "pinned": note.isPinned,
    "deleted": note.isDeleted,  // ✅ 添加 deleted 字段
    "created": ISO8601DateFormatter().string(from: note.created),
    "updated": ISO8601DateFormatter().string(from: note.updated)
]
```

#### 修复 2：删除时更新文件元数据

修改 `NotaFileManager.deleteNoteFile`，在移动文件到 trash 之前，先更新文件的 YAML 元数据，设置 `deleted: true`：

```swift
// 读取文件内容，解析并更新 deleted 状态
let fileContent = try String(contentsOf: sourceURL, encoding: .utf8)
let (metadata, body) = parseNotaFile(content: fileContent)

// 更新元数据，设置 deleted = true
var updatedMetadata = metadata
updatedMetadata["deleted"] = true
updatedMetadata["updated"] = ISO8601DateFormatter().string(from: Date())

// 重新生成文件内容并更新
// ... 然后移动文件到 trash
```

#### 修复 3：恢复时更新文件元数据

修改 `NotaFileManager.restoreFromTrash`，在移动文件回 notes 目录之前，先更新文件的 YAML 元数据，设置 `deleted: false`。

### 修复效果

1. **新创建/更新的笔记**：文件元数据中包含 `deleted` 字段，状态正确
2. **删除笔记时**：文件在移动到 trash 之前，元数据已更新为 `deleted: true`
3. **恢复笔记时**：文件在移动回 notes 之前，元数据已更新为 `deleted: false`
4. **重新导入时**：如果文件中有 `deleted: true`，导入时会正确设置为已删除状态

### 未来改进建议

可以考虑添加启动时的数据一致性检查：
- 如果数据库中有 `is_deleted = 1` 的记录，但文件在 `notes/` 目录，移动到 `trash/`
- 如果数据库中有 `is_deleted = 0` 的记录，但文件在 `trash/` 目录，移动到 `notes/`

## 影响范围

- **已删除的笔记**：如果文件在 `trash/` 目录但没有 `deleted: true` 元数据，重新导入时会恢复
- **数据库重置场景**：重新安装app时，如果数据库被重置但文件系统保留，会导致数据不一致

## 测试建议

1. ✅ **删除笔记测试**：
   - 创建一些笔记并删除
   - 检查 `trash/` 目录中的文件是否包含 `deleted: true` 元数据
   - 验证文件内容中的 YAML 元数据是否正确

2. ✅ **恢复笔记测试**：
   - 从 trash 恢复笔记
   - 检查 `notes/` 目录中的文件是否包含 `deleted: false` 元数据

3. ✅ **重新导入测试**：
   - 模拟数据库重置场景，重新导入文件
   - 验证包含 `deleted: true` 的文件是否正确导入为已删除状态

4. ⚠️ **数据修复**：
   - 对于已存在的、在 trash 目录但没有 `deleted: true` 元数据的文件，需要手动修复或添加数据迁移逻辑

## 相关文件

- `Nota4/Nota4/Services/NotaFileManager.swift` - 文件生成逻辑
- `Nota4/Nota4/Services/ImportService.swift` - 文件导入逻辑
- `Nota4/Nota4/Services/NoteRepository.swift` - 数据库操作


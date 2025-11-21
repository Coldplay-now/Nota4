# 笔记菜单动态状态优化实施总结

**实施时间**: 2025-11-20  
**优化范围**: 笔记菜单根据笔记状态和当前视图动态显示和禁用菜单项

---

## 一、执行摘要

本次优化实现了笔记菜单的动态状态管理，使菜单项根据笔记的当前状态（是否已删除、是否星标、是否置顶）和当前视图（是否在废纸篓）动态显示和禁用，提升了用户体验和操作逻辑的准确性。

### 完成的工作

1. ✅ **动态菜单项显示**：根据笔记状态和视图类型显示/禁用菜单项
2. ✅ **状态感知**：检测笔记是否已删除、是否在废纸篓视图
3. ✅ **智能按钮文本**：根据当前状态显示"星标"/"取消星标"、"置顶"/"取消置顶"
4. ✅ **快捷键优化**：调整恢复和永久删除的快捷键分配

---

## 二、优化内容

### 2.1 菜单项动态显示逻辑

#### 正常视图（非废纸篓）

**可用菜单项**:
- ✅ **星标/取消星标** (`⌘D`)
  - 文本：根据 `note.isStarred` 显示"星标笔记"或"取消星标"
  - 禁用条件：无笔记、在废纸篓视图、笔记已删除
- ✅ **置顶/取消置顶** (`⇧⌘P`)
  - 文本：根据 `note.isPinned` 显示"置顶笔记"或"取消置顶"
  - 禁用条件：无笔记、在废纸篓视图、笔记已删除
- ✅ **移至废纸篓** (`⌘⌫`)
  - 禁用条件：无笔记、在废纸篓视图、笔记已删除

**禁用菜单项**:
- ❌ **恢复**：在正常视图中禁用
- ❌ **永久删除**：在正常视图中禁用

#### 废纸篓视图

**可用菜单项**:
- ✅ **恢复** (`⌘⌫`)
  - 禁用条件：无笔记、不在废纸篓视图且笔记未删除
- ✅ **永久删除** (`⇧⌘⌫`)
  - 禁用条件：无笔记、不在废纸篓视图且笔记未删除

**禁用菜单项**:
- ❌ **星标/取消星标**：在废纸篓视图中禁用
- ❌ **置顶/取消置顶**：在废纸篓视图中禁用
- ❌ **移至废纸篓**：在废纸篓视图中禁用

---

## 三、实现细节

### 3.1 状态检测逻辑

**文件**: `Nota4/Nota4/App/Nota4App.swift`

```swift
// 获取当前笔记和状态
let currentNote = store.editor.note
let selectedNoteId = store.noteList.selectedNoteId
let selectedNoteIds = store.noteList.selectedNoteIds

// 判断是否在废纸篓视图
let isInTrash: Bool = {
    if case .category(let category) = store.noteList.filter {
        return category == .trash
    }
    return false
}()

// 获取目标笔记（优先使用编辑器中的笔记，其次使用选中的笔记）
let targetNote: Note? = {
    if let note = currentNote {
        return note
    } else if let noteId = selectedNoteId {
        return store.noteList.notes.first { $0.noteId == noteId }
    }
    return nil
}()

// 判断目标笔记是否已删除
let isNoteDeleted = targetNote?.isDeleted ?? false

// 判断是否有可操作的笔记
let hasNotes: Bool = {
    if currentNote != nil || selectedNoteId != nil {
        return true
    }
    return !selectedNoteIds.isEmpty
}()
```

### 3.2 菜单项实现

#### 星标/取消星标

```swift
Button(targetNote?.isStarred == true ? "取消星标" : "星标笔记") {
    if let noteId = currentNote?.noteId {
        store.send(.noteList(.toggleStar(noteId)))
    } else if let noteId = selectedNoteId {
        store.send(.noteList(.toggleStar(noteId)))
    }
}
.keyboardShortcut("d", modifiers: .command)
.disabled(!hasNotes || isInTrash || isNoteDeleted)
```

#### 置顶/取消置顶

```swift
Button(targetNote?.isPinned == true ? "取消置顶" : "置顶笔记") {
    if let noteId = currentNote?.noteId {
        store.send(.noteList(.togglePin(noteId)))
    } else if let noteId = selectedNoteId {
        store.send(.noteList(.togglePin(noteId)))
    }
}
.keyboardShortcut("p", modifiers: [.command, .shift])
.disabled(!hasNotes || isInTrash || isNoteDeleted)
```

#### 恢复笔记

```swift
Button("恢复") {
    let noteIds: Set<String>
    if let noteId = currentNote?.noteId {
        noteIds = [noteId]
    } else if let noteId = selectedNoteId {
        noteIds = [noteId]
    } else {
        noteIds = selectedNoteIds
    }
    if !noteIds.isEmpty {
        store.send(.noteList(.restoreNotes(noteIds)))
    }
}
.keyboardShortcut(.delete, modifiers: .command)
.disabled(!hasNotes || (!isInTrash && !isNoteDeleted))
```

#### 移至废纸篓

```swift
Button("移至废纸篓") {
    let noteIds: Set<String>
    if let noteId = currentNote?.noteId {
        noteIds = [noteId]
    } else if let noteId = selectedNoteId {
        noteIds = [noteId]
    } else {
        noteIds = selectedNoteIds
    }
    if !noteIds.isEmpty {
        store.send(.noteList(.deleteNotes(noteIds)))
    }
}
.keyboardShortcut(.delete, modifiers: .command)
.disabled(!hasNotes || isInTrash || isNoteDeleted)
```

#### 永久删除

```swift
Button("永久删除") {
    let noteIds: Set<String>
    if let noteId = currentNote?.noteId {
        noteIds = [noteId]
    } else if let noteId = selectedNoteId {
        noteIds = [noteId]
    } else {
        noteIds = selectedNoteIds
    }
    if !noteIds.isEmpty {
        store.send(.noteList(.permanentlyDeleteNotes(noteIds)))
    }
}
.keyboardShortcut(.delete, modifiers: [.command, .shift])
.disabled(!hasNotes || (!isInTrash && !isNoteDeleted))
```

---

## 四、快捷键分配

### 4.1 正常视图快捷键

| 快捷键 | 功能 | 状态 |
|--------|------|------|
| `⌘D` | 星标/取消星标 | ✅ 可用 |
| `⇧⌘P` | 置顶/取消置顶 | ✅ 可用 |
| `⌘⌫` | 移至废纸篓 | ✅ 可用 |

### 4.2 废纸篓视图快捷键

| 快捷键 | 功能 | 状态 |
|--------|------|------|
| `⌘⌫` | 恢复 | ✅ 可用 |
| `⇧⌘⌫` | 永久删除 | ✅ 可用 |

**注意**: 恢复和移至废纸篓使用相同的快捷键 `⌘⌫`，但根据当前视图自动切换功能。

---

## 五、状态判断逻辑

### 5.1 笔记选择优先级

1. **编辑器中的笔记** (`store.editor.note`)
   - 优先级最高
   - 如果编辑器中有打开的笔记，使用该笔记

2. **选中的笔记** (`store.noteList.selectedNoteId`)
   - 优先级次之
   - 如果笔记列表中有选中的笔记，使用该笔记

3. **批量选中的笔记** (`store.noteList.selectedNoteIds`)
   - 优先级最低
   - 用于批量操作

### 5.2 视图类型判断

```swift
let isInTrash: Bool = {
    if case .category(let category) = store.noteList.filter {
        return category == .trash
    }
    return false
}()
```

### 5.3 笔记状态判断

```swift
let isNoteDeleted = targetNote?.isDeleted ?? false
```

---

## 六、用户体验改进

### 6.1 智能菜单文本

- **星标按钮**：根据 `note.isStarred` 显示"星标笔记"或"取消星标"
- **置顶按钮**：根据 `note.isPinned` 显示"置顶笔记"或"取消置顶"

### 6.2 上下文感知

- **正常视图**：显示星标、置顶、移至废纸篓功能
- **废纸篓视图**：显示恢复、永久删除功能
- **自动禁用**：根据上下文自动禁用不相关的菜单项

### 6.3 操作安全性

- **防止误操作**：在正常视图中禁用永久删除
- **清晰的状态**：菜单项文本反映当前状态
- **批量操作支持**：支持批量选中笔记的操作

---

## 七、TCA 状态管理合规性

### 7.1 所有操作通过 TCA Action

✅ **星标操作**: `store.send(.noteList(.toggleStar(noteId)))`  
✅ **置顶操作**: `store.send(.noteList(.togglePin(noteId)))`  
✅ **删除操作**: `store.send(.noteList(.deleteNotes(noteIds)))`  
✅ **恢复操作**: `store.send(.noteList(.restoreNotes(noteIds)))`  
✅ **永久删除**: `store.send(.noteList(.permanentlyDeleteNotes(noteIds)))`

### 7.2 状态读取

- 所有状态读取都通过 `store` 访问
- 使用 `WithPerceptionTracking` 确保状态变化时菜单自动更新
- 状态判断逻辑清晰，易于维护

---

## 八、测试建议

### 8.1 正常视图测试

1. **星标功能**
   - 测试：在正常视图中选中笔记，使用 `⌘D` 星标
   - 预期：菜单显示"取消星标"，笔记被星标
   - 测试：再次使用 `⌘D`
   - 预期：菜单显示"星标笔记"，笔记取消星标

2. **置顶功能**
   - 测试：在正常视图中选中笔记，使用 `⇧⌘P` 置顶
   - 预期：菜单显示"取消置顶"，笔记被置顶
   - 测试：再次使用 `⇧⌘P`
   - 预期：菜单显示"置顶笔记"，笔记取消置顶

3. **移至废纸篓**
   - 测试：在正常视图中选中笔记，使用 `⌘⌫` 删除
   - 预期：笔记移至废纸篓，菜单项"恢复"和"永久删除"变为可用

### 8.2 废纸篓视图测试

1. **恢复功能**
   - 测试：在废纸篓视图中选中笔记，使用 `⌘⌫` 恢复
   - 预期：笔记恢复，菜单项"星标"、"置顶"、"移至废纸篓"变为可用

2. **永久删除**
   - 测试：在废纸篓视图中选中笔记，使用 `⇧⌘⌫` 永久删除
   - 预期：笔记被永久删除，从列表中移除

### 8.3 边界情况测试

1. **无笔记选中**
   - 测试：没有选中任何笔记时
   - 预期：所有菜单项都被禁用

2. **批量操作**
   - 测试：选中多个笔记时
   - 预期：批量操作正常工作

3. **编辑器中的笔记**
   - 测试：编辑器中有打开的笔记时
   - 预期：菜单操作针对编辑器中的笔记

---

## 九、修改文件清单

| 文件路径 | 修改内容 |
|---------|---------|
| `Nota4/Nota4/App/Nota4App.swift` | 优化笔记菜单，添加动态状态判断和菜单项禁用逻辑 |

---

## 十、总结

本次优化成功实现了笔记菜单的动态状态管理：

1. ✅ **根据笔记状态动态显示菜单项**
2. ✅ **根据当前视图智能禁用不相关功能**
3. ✅ **根据笔记状态显示正确的按钮文本**
4. ✅ **保持 TCA 状态管理合规性**
5. ✅ **提升用户体验和操作逻辑准确性**

所有修改都通过了编译检查，代码质量良好，符合 TCA 架构规范。

---

**实施完成时间**: 2025-11-20  
**实施人员**: AI Assistant  
**文档状态**: ✅ 完成



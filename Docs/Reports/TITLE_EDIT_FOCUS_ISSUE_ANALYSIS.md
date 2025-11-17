# 标题编辑焦点跳转问题分析报告

## 问题描述

在编辑区编辑标题时，每输入一个字符，焦点就会跳到卡片焦点上，影响了内容的编辑。

## 问题机制分析

### 1. 当前状态流转机制

#### 1.1 标题编辑流程
```
用户输入字符
  ↓
$store.title 绑定更新 (SwiftUI Binding)
  ↓
BindingAction<State> (TCA BindingReducer)
  ↓
EditorFeature.reducer: case .binding(\.title)
  ↓
目前只打印日志，不触发保存
```

#### 1.2 保存触发机制
```
标题失去焦点 (onFocusChange)
  ↓
store.send(.manualSave)
  ↓
EditorFeature.reducer: case .manualSave
  ↓
取消之前的 autoSave 任务
  ↓
立即发送 .autoSave
  ↓
EditorFeature.reducer: case .autoSave
  ↓
检查 hasUnsavedChanges
  ↓
更新 state.note
  ↓
异步保存到数据库 (noteRepository.updateNote)
  ↓
发送 .saveCompleted
```

#### 1.3 列表更新机制
```
EditorFeature: .saveCompleted
  ↓
AppFeature.reducer: case .editor(.saveCompleted)
  ↓
发送 .noteList(.updateNoteInList(updatedNote))  // 更新列表中的笔记
  ↓
发送 .noteList(.loadNotes)  // ⚠️ 问题：重新加载所有笔记
  ↓
发送 .sidebar(.loadCounts)  // 更新侧边栏计数
```

#### 1.4 列表重新渲染机制
```
NoteListFeature.reducer: case .loadNotes
  ↓
从数据库重新加载所有笔记
  ↓
state.notes 更新
  ↓
filteredNotes 计算属性重新计算
  ↓
filteredNotes 重新排序（按 updated 时间）
  ↓
NoteListView: ForEach(store.filteredNotes, ...) 重新渲染
  ↓
如果笔记位置改变，SwiftUI 重新创建视图
  ↓
⚠️ 焦点丢失
```

### 2. 问题根源

#### 2.1 核心问题
1. **每次保存后都重新加载列表**：`AppFeature` 在处理 `saveCompleted` 时，不仅调用 `updateNoteInList`，还调用了 `loadNotes`。
2. **重新加载导致重新排序**：`loadNotes` 会从数据库重新加载所有笔记，`filteredNotes` 会重新排序（按 `updated` 时间）。
3. **排序改变导致视图重建**：如果笔记因为 `updated` 时间改变而改变位置，SwiftUI 会重新创建列表项视图，导致焦点丢失。

#### 2.2 TCA 状态管理角度分析

**当前架构问题**：
- **同步更新 vs 异步加载**：`updateNoteInList` 是同步的乐观更新，但 `loadNotes` 是异步的数据库查询，两者同时执行会导致状态不一致。
- **不必要的状态更新**：每次保存都重新加载所有笔记，即使只有标题改变，也会触发整个列表的重新渲染。
- **焦点管理缺失**：列表重新渲染时，没有保持选中状态和焦点状态。

**TCA 最佳实践**：
- **乐观更新**：应该优先使用乐观更新（`updateNoteInList`），只在必要时才重新加载。
- **防抖机制**：对于频繁的输入操作，应该使用防抖来减少不必要的保存和更新。
- **状态隔离**：编辑状态和列表状态应该相对独立，编辑操作不应该频繁触发列表重新加载。

### 3. 解决方案

#### 3.1 方案一：移除不必要的 loadNotes（推荐）

**原理**：
- 使用 `updateNoteInList` 进行乐观更新，不重新加载列表。
- 只在必要时（如排序改变、筛选改变）才重新加载。

**实现**：
```swift
case .editor(.saveCompleted):
    if let updatedNote = state.editor.note {
        return .concatenate(
            .send(.noteList(.updateNoteInList(updatedNote))),
            // 移除 .send(.noteList(.loadNotes))，只更新不重新加载
            .send(.sidebar(.loadCounts))
        )
    }
    return .send(.sidebar(.loadCounts))
```

**优点**：
- 不会触发列表重新排序
- 不会导致视图重建
- 性能更好

**缺点**：
- 如果排序规则改变，列表可能不会立即反映最新排序

#### 3.2 方案二：标题编辑时不自动保存（已采用）

**原理**：
- 标题编辑时完全不触发保存，保证用户输入的连续性和完整性。
- 只有在用户手动切换焦点时（失去焦点）才触发保存。

**实现**：
```swift
case .binding(\.title):
    // 标题编辑时不自动保存，保证用户输入的连续性和完整性
    // 只有在用户手动切换焦点时（通过 onFocusChange）才触发保存
    return .none
```

**优点**：
- 完全避免输入过程中的保存和列表更新
- 保证用户输入的连续性和完整性
- 只有在用户主动切换焦点时才保存，符合用户预期

**缺点**：
- 无（失去焦点时会自动保存，不会丢失数据）

#### 3.3 方案三：保持选中状态

**原理**：
- 在列表更新时，保持当前选中的笔记 ID。
- 使用 `id` 和 `tag` 确保 SwiftUI 正确识别列表项。

**实现**：
- 已经在使用 `.id(note.noteId)` 和 `.tag(note.noteId)`，但需要确保选中状态不丢失。

### 4. 推荐方案（已实施）

**组合方案**：
1. **移除不必要的 loadNotes**：在 `saveCompleted` 时只使用 `updateNoteInList`，不重新加载。✅
2. **标题编辑时不自动保存**：标题编辑时完全不触发保存，只有在失去焦点时才保存。✅
3. **保持选中状态**：确保列表更新时保持选中状态。✅

## 实施计划（已完成）

1. ✅ 修改 `AppFeature` 中的 `saveCompleted` 处理，移除 `loadNotes`。
2. ✅ 在 `EditorFeature` 中移除标题编辑时的自动保存，只在失去焦点时保存。
3. ✅ 测试验证焦点不再跳转。

## 最终实现

### 标题编辑流程
```
用户输入字符
  ↓
$store.title 绑定更新
  ↓
BindingAction<State>
  ↓
EditorFeature.reducer: case .binding(\.title)
  ↓
return .none  // 不触发任何操作，保证输入连续性
  ↓
用户切换焦点（点击编辑区、列表栏、分类栏、或 app 外部）
  ↓
HighlightedTitleField: controlTextDidEndEditing
  ↓
onFocusChange(false)
  ↓
NoteEditorView: store.send(.manualSave)
  ↓
EditorFeature: manualSave → autoSave → saveCompleted
  ↓
AppFeature: updateNoteInList（乐观更新，不重新加载）
  ↓
列表卡片更新标题，但不重新排序，不移动位置
```

### 正文编辑流程（保持不变）
```
用户输入字符
  ↓
$store.content 绑定更新
  ↓
BindingAction<State>
  ↓
EditorFeature.reducer: case .binding(\.content)
  ↓
return .none  // 不触发保存（正文使用自动保存机制）
  ↓
自动保存机制（防抖）触发保存
  ↓
saveCompleted → updateNoteInList
  ↓
列表卡片更新预览，可能重新排序（符合用户预期）
```

## 技术细节

### TCA 状态管理最佳实践

1. **乐观更新优先**：对于 UI 更新，优先使用乐观更新，减少数据库查询。
2. **防抖机制**：对于频繁的输入操作，使用防抖来减少不必要的状态更新。
3. **状态隔离**：不同 Feature 之间的状态应该相对独立，避免不必要的耦合。
4. **焦点管理**：在列表更新时，应该保持选中状态和焦点状态。

## 总结

问题的根源是每次保存后都重新加载列表，导致列表重新排序和视图重建，从而丢失焦点。解决方案是使用乐观更新和防抖机制，减少不必要的列表重新加载。


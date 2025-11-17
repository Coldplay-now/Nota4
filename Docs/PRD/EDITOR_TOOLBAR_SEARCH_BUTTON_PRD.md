# 编辑区工具栏搜索按钮功能需求文档

**版本**: v1.0.0  
**创建日期**: 2025-11-17  
**最后更新**: 2025-11-17  
**状态**: 待实施

---

## 1. 功能概述

在编辑区的独立工具栏（`IndependentToolbar`）中增加一个搜索按钮，用于快速打开/关闭当前编辑文章的全文搜索和替换面板。该功能将复用现有的搜索面板（`SearchPanel`）和搜索机制，提供与笔记列表搜索按钮一致的交互体验。

---

## 2. 需求背景

### 2.1 现状分析

- **现有搜索面板**：`SearchPanel` 组件已实现完整的搜索和替换功能
  - 支持搜索、替换、导航（上一个/下一个）
  - 支持区分大小写、全词匹配、正则表达式等选项
  - 支持替换模式和替换全部功能
  - 搜索高亮已集成到 `MarkdownTextEditor` 中

- **现有工具栏**：`IndependentToolbar` 位于编辑器内容区域顶部
  - 包含格式化工具、插入工具、视图模式切换等
  - 按钮样式统一，使用 `NoteListToolbarButton` 风格

- **现有搜索状态管理**：`EditorFeature.State.SearchState`
  - `isSearchPanelVisible`: 控制搜索面板显示/隐藏
  - 完整的搜索选项和结果状态管理
  - 已实现 TCA Action 和 Reducer 逻辑

### 2.2 问题与机会

- **缺少快速入口**：用户需要通过快捷键（⌘F）或菜单打开搜索面板，缺少工具栏按钮入口
- **交互不一致**：笔记列表有搜索按钮，但编辑区没有，用户体验不统一
- **功能已就绪**：搜索面板和搜索机制已完整实现，只需添加工具栏按钮入口

---

## 3. 功能需求

### 3.1 核心功能

#### 3.1.1 搜索按钮

- **位置**：编辑区独立工具栏（`IndependentToolbar`）中
- **样式**：与笔记列表搜索按钮（`NoteListToolbarButton`）保持一致
  - 图标：`magnifyingglass`（未激活）/ `xmark.circle.fill`（已激活）
  - 尺寸：32x32 点
  - 圆角：6 点
  - 悬停效果：`Color(nsColor: .controlAccentColor).opacity(0.15)`
  - 动画：`.easeInOut(duration: 0.15)`

- **状态显示**：
  - **未激活**：显示 `magnifyingglass` 图标，提示文字 "搜索 (⌘F)"
  - **已激活**：显示 `xmark.circle.fill` 图标，提示文字 "关闭搜索 (⌘F)"

- **交互行为**：
  - 点击按钮：切换搜索面板显示/隐藏状态
  - 快捷键：⌘F（与系统标准一致）
  - 按钮状态与 `store.search.isSearchPanelVisible` 同步

#### 3.1.2 搜索面板集成

- **复用现有组件**：直接使用 `SearchPanel` 组件
- **显示位置**：在独立工具栏下方，编辑器内容区域上方
- **显示逻辑**：当 `store.search.isSearchPanelVisible == true` 时显示
- **动画效果**：使用 `.move(edge: .top).combined(with: .opacity)` 过渡动画

### 3.2 功能特性

#### 3.2.1 搜索功能

- **全文搜索**：在当前编辑的笔记内容中搜索
- **实时高亮**：搜索时实时高亮所有匹配项
- **当前匹配**：蓝色高亮显示当前匹配项
- **其他匹配**：黄色高亮显示其他匹配项
- **匹配计数**：显示 "当前索引/总匹配数"（如 "2/5"）

#### 3.2.2 替换功能

- **替换模式**：通过切换按钮开启/关闭替换模式
- **替换当前**：替换当前匹配项并自动跳转到下一个
- **全部替换**：一次性替换所有匹配项
- **替换后搜索**：替换后自动重新搜索，更新匹配结果

#### 3.2.3 搜索选项

- **区分大小写**：可选，默认关闭
- **全词匹配**：可选，默认关闭
- **正则表达式**：可选，默认关闭

#### 3.2.4 导航功能

- **上一个匹配**：⌘⇧G 或点击上箭头按钮
- **下一个匹配**：⌘G 或点击下箭头按钮
- **自动滚动**：导航时自动滚动到匹配项位置

---

## 4. 技术实现

### 4.1 TCA 状态管理

#### 4.1.1 状态结构

复用现有的 `EditorFeature.State.SearchState`：

```swift
struct SearchState: Equatable {
    var isSearchPanelVisible: Bool = false  // 搜索面板显示/隐藏
    var searchText: String = ""            // 搜索文本
    var replaceText: String = ""           // 替换文本
    var isReplaceMode: Bool = false        // 替换模式
    var matchCase: Bool = false            // 区分大小写
    var wholeWords: Bool = false           // 全词匹配
    var useRegex: Bool = false              // 正则表达式
    var matches: [NSRange] = []            // 匹配项范围
    var currentMatchIndex: Int = -1        // 当前匹配索引
}
```

#### 4.1.2 Action 定义

复用现有的 `EditorFeature.Action.search`：

```swift
enum Action {
    // ... 其他 actions
    case search(SearchAction)
}

enum SearchAction {
    case showSearchPanel      // 显示搜索面板
    case hideSearchPanel      // 隐藏搜索面板
    case toggleSearchPanel   // 切换搜索面板（新增）
    case searchTextChanged(String)
    case replaceTextChanged(String)
    case toggleReplaceMode
    case matchCaseToggled
    case wholeWordsToggled
    case useRegexToggled
    case findNext
    case findPrevious
    case replaceCurrent
    case replaceAll
    case updateMatches([NSRange])
    case selectMatch(Int)
}
```

#### 4.1.3 Reducer 逻辑

复用现有的 Reducer 逻辑，确保：
- `toggleSearchPanel` 切换 `isSearchPanelVisible` 状态
- 关闭搜索面板时清除搜索文本和匹配结果
- 搜索文本变化时触发异步搜索
- 替换操作后更新内容并重新搜索

### 4.2 UI 组件

#### 4.2.1 工具栏按钮

在 `IndependentToolbar` 中添加搜索按钮：

```swift
// 在 IndependentToolbar 的 HStack 中，位于 FormatButtonGroup 之前
if store.viewMode != .previewOnly {
    // 搜索按钮
    NoteListToolbarButton(
        title: store.search.isSearchPanelVisible ? "关闭搜索" : "搜索",
        icon: store.search.isSearchPanelVisible ? "xmark.circle.fill" : "magnifyingglass",
        shortcut: "⌘F",
        isEnabled: store.note != nil  // 只有有笔记时才启用
    ) {
        store.send(.search(.toggleSearchPanel))
    }
    
    Divider()
        .frame(height: 20)
    
    // 核心工具：始终显示
    FormatButtonGroup(store: store)
    // ... 其他按钮
}
```

#### 4.2.2 搜索面板显示

在 `NoteEditorView` 中，搜索面板已存在，只需确保显示逻辑正确：

```swift
// 在 NoteEditorView 中
if store.search.isSearchPanelVisible {
    SearchPanel(store: store)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.2), value: store.search.isSearchPanelVisible)
}
```

### 4.3 快捷键支持

- **⌘F**：切换搜索面板显示/隐藏
- **⌘G**：查找下一个匹配项
- **⌘⇧G**：查找上一个匹配项
- **ESC**：关闭搜索面板（在搜索面板内）

---

## 5. 交互流程

### 5.1 打开搜索

1. 用户点击工具栏搜索按钮或按 ⌘F
2. 发送 `search(.toggleSearchPanel)` action
3. `isSearchPanelVisible` 变为 `true`
4. 搜索面板从工具栏下方滑入显示
5. 搜索框自动获得焦点

### 5.2 执行搜索

1. 用户在搜索框中输入文本
2. 触发 `search(.searchTextChanged)` action
3. 异步执行搜索（防抖处理）
4. 更新 `matches` 和 `currentMatchIndex`
5. `MarkdownTextEditor` 自动更新高亮显示

### 5.3 导航匹配

1. 用户点击上/下箭头按钮或按 ⌘G/⌘⇧G
2. 触发 `search(.findNext)` 或 `search(.findPrevious)` action
3. 更新 `currentMatchIndex`
4. 编辑器自动滚动到当前匹配项位置
5. 高亮更新（当前匹配蓝色，其他黄色）

### 5.4 替换操作

1. 用户点击替换模式切换按钮
2. `isReplaceMode` 变为 `true`，显示替换输入框
3. 用户输入替换文本
4. 点击"替换"按钮：替换当前匹配并跳转下一个
5. 点击"全部替换"按钮：替换所有匹配项并清除搜索结果

### 5.5 关闭搜索

1. 用户点击工具栏搜索按钮（已激活状态）或按 ⌘F/ESC
2. 发送 `search(.toggleSearchPanel)` 或 `search(.hideSearchPanel)` action
3. `isSearchPanelVisible` 变为 `false`
4. 清除搜索文本和匹配结果
5. 搜索面板滑出隐藏

---

## 6. 设计规范

### 6.1 按钮样式

- **尺寸**：32x32 点
- **圆角**：6 点
- **图标**：SF Symbols，16 点，regular weight
- **悬停背景**：`Color(nsColor: .controlAccentColor).opacity(0.15)`
- **动画**：`.easeInOut(duration: 0.15)`

### 6.2 搜索面板样式

- **背景色**：`Color(nsColor: .controlBackgroundColor)`
- **边框**：底部 0.5 点分隔线，`Color(nsColor: .separatorColor)`
- **内边距**：水平 16 点，垂直 10 点
- **输入框**：圆角 6 点，边框 1 点，`Color(nsColor: .separatorColor)`

### 6.3 高亮样式

- **当前匹配**：蓝色背景，`NSColor.systemBlue.withAlphaComponent(0.3)`
- **其他匹配**：黄色背景，`NSColor.systemYellow.withAlphaComponent(0.2)`
- **文本颜色**：保持原文本颜色

---

## 7. 边界情况处理

### 7.1 无笔记时

- 搜索按钮禁用（`isEnabled: store.note != nil`）
- 提示文字显示为灰色

### 7.2 预览模式

- 搜索按钮在预览模式下隐藏（`if store.viewMode != .previewOnly`）
- 因为预览模式不支持编辑和搜索

### 7.3 搜索无结果

- 匹配计数不显示
- 导航按钮禁用
- 替换按钮禁用

### 7.4 替换后无匹配

- 自动清除搜索结果
- 清除搜索高亮
- 保持搜索面板打开（用户可能继续搜索）

### 7.5 切换笔记

- 关闭搜索面板
- 清除搜索状态
- 确保新笔记加载时搜索面板关闭

---

## 8. 测试要点

### 8.1 功能测试

- [ ] 点击搜索按钮打开/关闭搜索面板
- [ ] ⌘F 快捷键切换搜索面板
- [ ] 搜索文本实时高亮显示
- [ ] 导航按钮（上/下）正确跳转匹配项
- [ ] 替换当前匹配项功能正常
- [ ] 全部替换功能正常
- [ ] 搜索选项（区分大小写、全词匹配、正则表达式）生效
- [ ] 关闭搜索面板时清除搜索状态

### 8.2 交互测试

- [ ] 按钮悬停效果正常
- [ ] 搜索面板滑入/滑出动画流畅
- [ ] 搜索框自动获得焦点
- [ ] 编辑器自动滚动到匹配项位置
- [ ] 高亮颜色正确（当前蓝色，其他黄色）

### 8.3 边界测试

- [ ] 无笔记时按钮禁用
- [ ] 预览模式下按钮隐藏
- [ ] 搜索无结果时按钮禁用
- [ ] 切换笔记时搜索面板关闭
- [ ] 替换后搜索状态正确更新

---

## 9. 实施计划

### 9.1 阶段 1：基础功能（优先级：高）

1. 在 `IndependentToolbar` 中添加搜索按钮
2. 实现 `toggleSearchPanel` action 和 reducer
3. 确保搜索面板显示/隐藏逻辑正确
4. 测试按钮点击和快捷键功能

### 9.2 阶段 2：完善交互（优先级：中）

1. 优化按钮状态显示（图标切换）
2. 确保搜索面板动画流畅
3. 测试搜索和替换功能完整性
4. 验证边界情况处理

### 9.3 阶段 3：优化体验（优先级：低）

1. 优化搜索性能（大量文本时）
2. 添加搜索历史（可选）
3. 优化高亮显示性能

---

## 10. 依赖关系

### 10.1 现有组件

- `SearchPanel`：搜索面板组件（已存在）
- `NoteListToolbarButton`：工具栏按钮组件（已存在）
- `IndependentToolbar`：独立工具栏组件（已存在）
- `MarkdownTextEditor`：编辑器组件（已存在）

### 10.2 现有状态管理

- `EditorFeature.State.SearchState`：搜索状态（已存在）
- `EditorFeature.Action.search`：搜索相关 actions（已存在）
- `EditorFeature` reducer：搜索逻辑（已存在）

### 10.3 新增内容

- `toggleSearchPanel` action（需添加到 `SearchAction`）
- 工具栏搜索按钮（需添加到 `IndependentToolbar`）

---

## 11. 验收标准

### 11.1 功能完整性

- ✅ 搜索按钮可以打开/关闭搜索面板
- ✅ 搜索功能正常工作（实时高亮、导航、替换）
- ✅ 快捷键支持完整（⌘F、⌘G、⌘⇧G、ESC）
- ✅ 按钮状态与搜索面板状态同步

### 11.2 用户体验

- ✅ 按钮样式与笔记列表搜索按钮一致
- ✅ 搜索面板动画流畅
- ✅ 搜索框自动获得焦点
- ✅ 编辑器自动滚动到匹配项

### 11.3 代码质量

- ✅ 遵循 TCA 状态管理规范
- ✅ 代码复用现有组件和逻辑
- ✅ 无性能问题
- ✅ 边界情况处理完善

---

## 12. 版本历史

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| v1.0.0 | 2025-11-17 | AI Assistant | 初始版本，完整功能需求定义 |

---

## 13. 附录

### 13.1 参考文档

- `Nota4/Docs/PRD/NOTE_LIST_VISUAL_OPTIMIZATION_PRD.md`：笔记列表视觉优化 PRD（按钮样式参考）
- `Nota4/Nota4/Features/NoteList/NoteListToolbar.swift`：笔记列表工具栏实现（按钮样式参考）
- `Nota4/Nota4/Features/Editor/SearchPanel.swift`：搜索面板组件实现
- `Nota4/Nota4/Features/Editor/EditorFeature.swift`：编辑器状态管理实现

### 13.2 相关文件

- `Nota4/Nota4/Features/Editor/IndependentToolbar.swift`：独立工具栏组件
- `Nota4/Nota4/Features/Editor/NoteEditorView.swift`：编辑器主视图
- `Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift`：Markdown 编辑器组件

---

**文档结束**


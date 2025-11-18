# 布局模式切换交互设计方案

**设计时间**: 2025-11-18 17:45:00

## 需求概述

实现三种布局模式的切换：
1. **三栏模式**：分类侧边栏 + 笔记列表 + 编辑/预览
2. **两栏模式**：笔记列表 + 编辑/预览
3. **一栏模式**：编辑/预览

---

## 设计方案

### 1. 布局模式定义

#### 1.1 枚举定义

```swift
// AppFeature.swift
enum LayoutMode: String, Equatable, CaseIterable {
    case threeColumn = "三栏"
    case twoColumn = "两栏"
    case oneColumn = "一栏"
    
    var icon: String {
        switch self {
        case .threeColumn: return "rectangle.split.3x1"
        case .twoColumn: return "rectangle.split.2x1"
        case .oneColumn: return "rectangle"
        }
    }
    
    var description: String {
        switch self {
        case .threeColumn: return "分类 + 列表 + 编辑"
        case .twoColumn: return "列表 + 编辑"
        case .oneColumn: return "仅编辑"
        }
    }
    
    // 转换为 NavigationSplitViewVisibility
    var columnVisibility: NavigationSplitViewVisibility {
        switch self {
        case .threeColumn: return .all
        case .twoColumn: return .doubleColumn
        case .oneColumn: return .detailOnly
        }
    }
}
```

#### 1.2 状态管理（TCA）

```swift
// AppFeature.State
@ObservableState
struct State: Equatable {
    // ... 现有状态 ...
    var layoutMode: LayoutMode = .threeColumn  // 新增布局模式状态
    var columnVisibility: NavigationSplitViewVisibility = .all  // 保留，用于同步
    
    init() {}
}

// AppFeature.Action
enum Action {
    // ... 现有 Action ...
    case layoutModeChanged(LayoutMode)  // 新增布局模式切换 Action
    case columnVisibilityChanged(NavigationSplitViewVisibility)  // 保留，用于同步
}
```

---

### 2. 交互入口设计

#### 2.1 菜单栏入口（推荐）⭐

**位置**：`窗口` 菜单或 `视图` 菜单

```swift
// Nota4App.swift
CommandMenu("视图") {
    Menu("布局模式") {
        Button("三栏（分类 + 列表 + 编辑）") {
            store.send(.layoutModeChanged(.threeColumn))
        }
        .keyboardShortcut("1", modifiers: [.command, .shift])
        
        Button("两栏（列表 + 编辑）") {
            store.send(.layoutModeChanged(.twoColumn))
        }
        .keyboardShortcut("2", modifiers: [.command, .shift])
        
        Button("一栏（仅编辑）") {
            store.send(.layoutModeChanged(.oneColumn))
        }
        .keyboardShortcut("3", modifiers: [.command, .shift])
    }
    
    Divider()
    
    // 其他视图相关菜单项...
}
```

**菜单显示效果**：
```
视图
├─ 布局模式
│  ├─ 三栏（分类 + 列表 + 编辑）    ⇧⌘1
│  ├─ 两栏（列表 + 编辑）            ⇧⌘2
│  └─ 一栏（仅编辑）                 ⇧⌘3
├─ ────────────
└─ ...
```

**优点**：
- ✅ 符合 macOS 应用习惯（视图菜单）
- ✅ 快捷键清晰易记（⇧⌘1/2/3）
- ✅ 菜单项可以显示当前选中状态

---

#### 2.2 工具栏按钮（可选）⭐

**位置**：编辑器工具栏或独立工具栏

```swift
// IndependentToolbar.swift 或新建 LayoutToolbar.swift
struct LayoutModeControl: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Menu {
                Button {
                    store.send(.layoutModeChanged(.threeColumn))
                } label: {
                    Label("三栏", systemImage: "rectangle.split.3x1")
                    if store.layoutMode == .threeColumn {
                        Image(systemName: "checkmark")
                    }
                }
                
                Button {
                    store.send(.layoutModeChanged(.twoColumn))
                } label: {
                    Label("两栏", systemImage: "rectangle.split.2x1")
                    if store.layoutMode == .twoColumn {
                        Image(systemName: "checkmark")
                    }
                }
                
                Button {
                    store.send(.layoutModeChanged(.oneColumn))
                } label: {
                    Label("一栏", systemImage: "rectangle")
                    if store.layoutMode == .oneColumn {
                        Image(systemName: "checkmark")
                    }
                }
            } label: {
                Image(systemName: store.layoutMode.icon)
                    .font(.system(size: 14))
                    .frame(width: 32, height: 28)
            }
            .buttonStyle(.plain)
            .help("切换布局模式")
        }
    }
}
```

**优点**：
- ✅ 快速访问，无需打开菜单
- ✅ 图标直观，显示当前模式
- ✅ 与现有工具栏风格一致

**缺点**：
- ⚠️ 占用工具栏空间
- ⚠️ 可能与其他功能冲突

---

#### 2.3 快捷键直接切换（推荐）⭐

**快捷键设计**：
- `⇧⌘1`：切换到三栏模式
- `⇧⌘2`：切换到两栏模式
- `⇧⌘3`：切换到一栏模式

**实现**：
```swift
// Nota4App.swift
CommandGroup(after: .textEditing) {
    // ... 现有搜索命令 ...
    
    Divider()
    
    Button("三栏布局") {
        store.send(.layoutModeChanged(.threeColumn))
    }
    .keyboardShortcut("1", modifiers: [.command, .shift])
    
    Button("两栏布局") {
        store.send(.layoutModeChanged(.twoColumn))
    }
    .keyboardShortcut("2", modifiers: [.command, .shift])
    
    Button("一栏布局") {
        store.send(.layoutModeChanged(.oneColumn))
    }
    .keyboardShortcut("3", modifiers: [.command, .shift])
}
```

**优点**：
- ✅ 最快切换方式
- ✅ 符合 macOS 快捷键习惯
- ✅ 无需鼠标操作

---

#### 2.4 状态栏显示（可选）

**位置**：状态栏右侧

```swift
// StatusBarView.swift
HStack {
    // ... 现有状态栏内容 ...
    
    Spacer()
    
    // 布局模式指示器
    Button {
        // 循环切换布局模式
        let nextMode: LayoutMode = switch store.layoutMode {
        case .threeColumn: .twoColumn
        case .twoColumn: .oneColumn
        case .oneColumn: .threeColumn
        }
        store.send(.layoutModeChanged(nextMode))
    } label: {
        HStack(spacing: 4) {
            Image(systemName: store.layoutMode.icon)
                .font(.system(size: 10))
            Text(store.layoutMode.rawValue)
                .font(.system(size: 11))
        }
        .foregroundColor(.secondary)
    }
    .buttonStyle(.plain)
    .help("点击切换布局模式（⇧⌘1/2/3）")
}
```

**优点**：
- ✅ 始终可见，显示当前模式
- ✅ 点击快速切换
- ✅ 不占用主要界面空间

---

### 3. 实现细节

#### 3.1 Reducer 处理

```swift
// AppFeature.swift
case .layoutModeChanged(let mode):
    state.layoutMode = mode
    state.columnVisibility = mode.columnVisibility
    return .none

case .columnVisibilityChanged(let visibility):
    // 同步 columnVisibility 变化到 layoutMode
    // 当用户手动拖拽调整布局时，同步更新 layoutMode
    state.columnVisibility = visibility
    
    // 根据 visibility 推断 layoutMode
    switch visibility {
    case .all:
        state.layoutMode = .threeColumn
    case .doubleColumn:
        state.layoutMode = .twoColumn
    case .detailOnly:
        state.layoutMode = .oneColumn
    case .automatic:
        // 保持当前模式
        break
    }
    
    return .none
```

#### 3.2 视图更新

```swift
// Nota4App.swift - AppView
NavigationSplitView(
    columnVisibility: Binding(
        get: { store.layoutMode.columnVisibility },
        set: { newVisibility in
            // 当用户手动调整布局时，同步更新状态
            store.send(.columnVisibilityChanged(newVisibility))
        }
    )
) {
    // 侧边栏（三栏模式显示）
    SidebarView(...)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
} content: {
    // 笔记列表（三栏和两栏模式显示）
    NoteListView(...)
        .navigationSplitViewColumnWidth(min: 280, ideal: 280, max: 500)
} detail: {
    // 编辑器（所有模式都显示）
    NoteEditorView(...)
}
.navigationSplitViewStyle(.balanced)
```

---

### 4. 用户体验考虑

#### 4.1 切换动画

- ✅ `NavigationSplitView` 自带平滑过渡动画
- ✅ 无需额外实现动画效果

#### 4.2 状态持久化

**建议**：保存用户选择的布局模式到偏好设置

```swift
// AppFeature.swift
case .layoutModeChanged(let mode):
    state.layoutMode = mode
    state.columnVisibility = mode.columnVisibility
    
    // 保存到 UserDefaults
    UserDefaults.standard.set(mode.rawValue, forKey: "layoutMode")
    
    return .none

// 初始化时加载
init() {
    if let savedMode = UserDefaults.standard.string(forKey: "layoutMode"),
       let mode = LayoutMode(rawValue: savedMode) {
        self.layoutMode = mode
        self.columnVisibility = mode.columnVisibility
    }
}
```

#### 4.3 快捷键冲突检查

**潜在冲突**：
- `⇧⌘1/2/3` 可能与某些应用的快捷键冲突
- 建议：在偏好设置中允许用户自定义快捷键

#### 4.4 响应式布局

**窗口大小适配**：
- 小窗口（< 800pt）：自动切换到两栏或一栏模式
- 大窗口（> 1200pt）：支持三栏模式

```swift
// AppView.swift
.onChange(of: geometry.size.width) { oldWidth, newWidth in
    if newWidth < 800 && store.layoutMode == .threeColumn {
        // 窗口太小时，自动切换到两栏模式
        store.send(.layoutModeChanged(.twoColumn))
    }
}
```

---

### 5. 推荐实施方案

#### 方案 A：完整方案（推荐）⭐

**包含**：
1. ✅ 菜单栏入口（视图菜单）
2. ✅ 快捷键（⇧⌘1/2/3）
3. ✅ 状态栏显示（可选）
4. ✅ 状态持久化

**优点**：
- 功能完整，用户体验好
- 符合 macOS 应用标准

**实施难度**：中等

---

#### 方案 B：简化方案

**包含**：
1. ✅ 快捷键（⇧⌘1/2/3）
2. ✅ 状态持久化

**优点**：
- 实施简单，快速上线
- 核心功能完整

**缺点**：
- 缺少菜单入口，用户可能不知道快捷键

**实施难度**：低

---

#### 方案 C：最小方案

**包含**：
1. ✅ 快捷键（⇧⌘1/2/3）

**优点**：
- 最快实施
- 满足基本需求

**缺点**：
- 缺少状态持久化
- 缺少菜单入口

**实施难度**：极低

---

## 实施建议

### 阶段 1：核心功能（方案 C）
1. 定义 `LayoutMode` 枚举
2. 添加状态和 Action
3. 实现 Reducer 处理
4. 添加快捷键

### 阶段 2：完善体验（方案 B）
1. 添加状态持久化
2. 菜单栏入口

### 阶段 3：优化体验（方案 A）
1. 状态栏显示
2. 响应式布局
3. 快捷键自定义（可选）

---

## 技术要点

### 1. NavigationSplitViewVisibility 映射

```swift
extension LayoutMode {
    var columnVisibility: NavigationSplitViewVisibility {
        switch self {
        case .threeColumn: return .all
        case .twoColumn: return .doubleColumn
        case .oneColumn: return .detailOnly
        }
    }
}
```

### 2. 双向同步

- `layoutMode` → `columnVisibility`：程序切换布局时
- `columnVisibility` → `layoutMode`：用户手动拖拽调整时

### 3. TCA 状态管理

- ✅ 所有状态在 `AppFeature.State` 中管理
- ✅ 布局切换通过 Action 触发
- ✅ Reducer 处理业务逻辑

---

## 测试要点

1. **快捷键测试**：
   - 测试 ⇧⌘1/2/3 是否正常工作
   - 测试快捷键冲突

2. **状态持久化测试**：
   - 切换布局后重启应用，验证布局是否保持

3. **响应式测试**：
   - 调整窗口大小，验证布局是否自动适配

4. **动画测试**：
   - 验证布局切换是否有平滑动画

---

## 总结

**推荐方案**：方案 A（完整方案）

**核心交互**：
1. 菜单栏：视图 → 布局模式 → 选择模式
2. 快捷键：⇧⌘1/2/3 快速切换
3. 状态栏：显示当前模式，点击切换（可选）

**实施优先级**：
1. 🔴 高优先级：快捷键 + 状态持久化
2. 🟡 中优先级：菜单栏入口
3. 🟢 低优先级：状态栏显示、响应式布局


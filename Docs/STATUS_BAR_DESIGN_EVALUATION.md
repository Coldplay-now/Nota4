# Nota4 状态栏设计评估方案

> **文档版本**: v1.0  
> **创建日期**: 2025-11-16 21:42:53  
> **评估目标**: 确定状态栏的最佳实现方案  
> **状态**: 待决策

---

## 📋 目录

1. [需求背景](#1-需求背景)
2. [方案对比](#2-方案对比)
3. [详细分析](#3-详细分析)
4. [竞品分析](#4-竞品分析)
5. [推荐方案](#5-推荐方案)
6. [实现设计](#6-实现设计)
7. [技术实现](#7-技术实现)

---

## 1. 需求背景

### 1.1 当前状态

**Nota4 现有状态显示方式**：
- ✅ 工具栏中的保存状态指示器（右上角）
  - 保存中: `ProgressView`
  - 有未保存更改: 橙色圆点
  - 已保存: 绿色对勾

**存在的问题**：
- ❌ 信息单一，只显示保存状态
- ❌ 缺少笔记元信息（字数、修改时间等）
- ❌ 缺少光标位置信息
- ❌ 缺少全局统计信息

### 1.2 用户需求

**希望在状态栏中看到的信息**：
1. **编辑器信息**：
   - 字数统计（中英文分别统计）
   - 行数统计
   - 光标位置（行:列）
   - 选中字数

2. **笔记元信息**：
   - 最后修改时间
   - 文件大小
   - 保存状态

3. **全局信息**：
   - 当前笔记位置（第 X / 总共 Y 篇）
   - 数据库统计

---

## 2. 方案对比

### 方案 A：编辑器区域状态栏

```
┌──────────┬──────────────┬───────────────────────────────┐
│  Sidebar │  NoteList    │   NoteEditor                  │
│          │              │ ┌───────────────────────────┐ │
│          │              │ │ 标题栏                     │ │
│          │              │ ├───────────────────────────┤ │
│          │              │ │                           │ │
│          │              │ │ 编辑/预览区域              │ │
│          │              │ │                           │ │
│          │              │ ├───────────────────────────┤ │
│          │              │ │ ⏺ 第3行:12列 | 1,234字... │ │ ← 编辑器状态栏
│          │              │ └───────────────────────────┘ │
└──────────┴──────────────┴───────────────────────────────┘
```

**特点**：
- ✅ 专注于当前编辑的笔记信息
- ✅ 与编辑区域紧密关联
- ✅ 不影响其他区域
- ❌ 切换到其他区域时不可见

---

### 方案 B：全局底部状态栏

```
┌──────────┬──────────────┬───────────────────────────────┐
│  Sidebar │  NoteList    │   NoteEditor                  │
│          │              │                               │
│          │              │                               │
│          │              │                               │
│          │              │                               │
│          │              │                               │
├──────────┴──────────────┴───────────────────────────────┤
│ ⏺ 第3行:12列 | 1,234字 | 已保存 2分钟前 | 共42篇笔记      │ ← 全局状态栏
└─────────────────────────────────────────────────────────┘
```

**特点**：
- ✅ 全局可见，始终展示信息
- ✅ 符合传统桌面应用习惯
- ✅ 可显示多源信息（编辑器+列表+全局）
- ❌ 占用垂直空间（约22-24pt）

---

### 方案 C：混合方案（编辑器 + 全局）

```
┌──────────┬──────────────┬───────────────────────────────┐
│  Sidebar │  NoteList    │   NoteEditor                  │
│          │              │ ┌───────────────────────────┐ │
│          │              │ │ 编辑/预览区域              │ │
│          │              │ ├───────────────────────────┤ │
│          │              │ │ ⏺ 第3行:12列 | 1,234字    │ │ ← 编辑器状态栏
│          │              │ └───────────────────────────┘ │
├──────────┴──────────────┴───────────────────────────────┤
│ 共42篇笔记 | 8篇星标 | 数据库大小: 12.3 MB              │ ← 全局状态栏
└─────────────────────────────────────────────────────────┘
```

**特点**：
- ✅ 信息层次清晰
- ✅ 编辑器信息 + 全局信息分离
- ❌ 两个状态栏，视觉复杂度增加
- ❌ 占用更多空间

---

## 3. 详细分析

### 3.1 信息优先级分析

#### 高优先级信息（必须显示）
1. **保存状态** - 用户最关心
2. **字数统计** - 写作时重要参考
3. **光标位置** - 编辑时定位

#### 中优先级信息（建议显示）
4. **修改时间** - 了解笔记状态
5. **笔记总数** - 全局概览
6. **选中字数** - 选中文本时显示

#### 低优先级信息（可选显示）
7. **文件大小** - 技术信息
8. **数据库统计** - 开发/调试信息
9. **行数统计** - 可通过光标位置推断

---

### 3.2 用户场景分析

#### 场景1：专注写作

**主要活动**：
- 在编辑器中输入内容
- 查看字数统计
- 确认保存状态

**信息需求**：
- ✅ 字数统计
- ✅ 保存状态
- ✅ 光标位置
- ❌ 不需要全局统计

**适合方案**: **方案A（编辑器状态栏）**

---

#### 场景2：浏览管理笔记

**主要活动**：
- 在笔记列表中切换
- 查看笔记预览
- 了解笔记库整体情况

**信息需求**：
- ✅ 笔记总数
- ✅ 当前笔记索引
- ✅ 全局统计
- ⚠️ 编辑器信息次要

**适合方案**: **方案B（全局状态栏）**

---

#### 场景3：快速查看编辑

**主要活动**：
- 快速切换笔记
- 编辑后立即切换下一篇
- 需要知道全局进度

**信息需求**：
- ✅ 保存状态（避免数据丢失）
- ✅ 笔记位置（第X/Y篇）
- ✅ 字数统计
- ✅ 全局概览

**适合方案**: **方案B（全局状态栏）** 或 **方案C（混合）**

---

### 3.3 空间占用分析

#### 方案A：编辑器状态栏

```
占用空间：0pt（全局）
影响范围：仅 NoteEditor 区域
垂直空间损失：~22pt（编辑器内）
```

**优点**：
- 不影响整体窗口高度
- 编辑区域减少 ~22pt（影响小）

**缺点**：
- 在 previewOnly 模式下可能不适合

---

#### 方案B：全局状态栏

```
占用空间：~22-24pt（全局）
影响范围：所有区域
垂直空间损失：~22pt（整体）
```

**优点**：
- 一次性占用，清晰固定

**缺点**：
- 在小屏幕（MacBook Air 13"）上可能紧张
- 需要确保最小窗口高度足够（600pt → 622pt）

---

#### 方案C：混合方案

```
占用空间：~44-48pt（累计）
影响范围：所有区域
垂直空间损失：~44pt（整体）
```

**优点**：
- 信息完整

**缺点**：
- 空间占用过多
- 视觉复杂度增加

---

### 3.4 视觉一致性分析

#### macOS 原生应用参考

| 应用 | 状态栏位置 | 显示内容 |
|------|----------|---------|
| **Xcode** | 全局底部 | 编译状态、错误数、文件路径 |
| **VS Code** | 全局底部 | 行列号、语言、编码、Git信息 |
| **TextEdit** | 无 | 无状态栏 |
| **Notes** | 无 | 无状态栏 |
| **Bear** | 无 | 无状态栏（信息在标题区） |
| **Typora** | 编辑器底部 | 字数、行数、字符数 |
| **Ulysses** | 编辑器底部 | 字数、阅读时间 |

**观察结论**：
- ✅ **代码编辑器**：倾向全局底部状态栏（信息密集）
- ✅ **笔记应用**：倾向无状态栏或编辑器内状态栏（简洁）
- ✅ **写作应用**：倾向编辑器内状态栏（专注写作）

**Nota4 定位**：
- Markdown 笔记应用（更接近写作应用）
- 建议：**方案A（编辑器状态栏）** 或 **方案B（全局状态栏）**

---

## 4. 竞品分析

### 4.1 Bear（无状态栏）

```
┌──────────┬──────────────┬───────────────────────────────┐
│  Sidebar │  NoteList    │   NoteEditor                  │
│          │              │ [标题]                        │
│          │              │                               │
│          │              │ 正文内容...                    │
│          │              │                               │
│          │              │ [底部工具栏: 图片/链接/...]    │
└──────────┴──────────────┴───────────────────────────────┘
```

**特点**：
- 无状态栏，界面极简
- 字数统计在**菜单栏 → 显示字数统计**
- 保存状态通过 iCloud 图标显示

**评价**：
- ✅ 界面简洁
- ❌ 缺少实时字数统计
- ❌ 不适合重度写作用户

---

### 4.2 Typora（编辑器状态栏）

```
┌───────────────────────────────────────────────────────┐
│  NoteEditor                                           │
│                                                       │
│  # 笔记标题                                            │
│                                                       │
│  正文内容...                                           │
│                                                       │
├───────────────────────────────────────────────────────┤
│ 第5段落 | 1,234字 | 88行 | 当前行:12                   │ ← 编辑器状态栏
└───────────────────────────────────────────────────────┘
```

**特点**：
- 状态栏位于编辑器底部
- 显示：段落、字数、行数、当前行号
- 与编辑区域视觉分离清晰

**评价**：
- ✅ 信息丰富
- ✅ 不干扰写作
- ✅ 专注于编辑相关信息

---

### 4.3 VS Code（全局状态栏）

```
┌──────────┬────────────────────────────────────────────┐
│  Sidebar │  Editor                                    │
│          │                                            │
│          │  代码内容...                                │
│          │                                            │
├──────────┴────────────────────────────────────────────┤
│ ⚠ 2个问题 | UTF-8 | LF | JavaScript | 第3行:12列      │ ← 全局状态栏
└───────────────────────────────────────────────────────┘
```

**特点**：
- 全局底部状态栏
- 显示：错误、编码、语言、光标位置、Git状态
- 信息密集，面向开发者

**评价**：
- ✅ 信息完整
- ✅ 全局可见
- ❌ 复杂度较高（不适合笔记应用）

---

## 5. 推荐方案

### 🏆 推荐方案：方案B - 全局底部状态栏（简化版）

**选择理由**：

#### ✅ 优势
1. **符合用户习惯**：
   - 大多数桌面应用都有全局状态栏
   - 用户期望在底部看到信息

2. **信息全局可见**：
   - 无论在哪个区域操作，都能看到状态
   - 切换笔记时不会丢失信息

3. **可扩展性强**：
   - 可以根据当前焦点显示不同信息
   - 易于添加新功能（如搜索结果数、过滤器状态）

4. **与 Nota2 设计一致**：
   - Nota2 PRD 中已有全局状态栏设计
   - 保持产品系列一致性

5. **技术实现简单**：
   - SwiftUI 的 `VStack` 布局
   - TCA 状态管理清晰

#### ⚠️ 注意事项
1. **保持简洁**：
   - 只显示核心信息（3-5项）
   - 避免信息过载

2. **动态显示**：
   - 根据当前焦点调整显示内容
   - 编辑时显示编辑器信息
   - 浏览时显示全局信息

3. **可配置**：
   - 允许用户隐藏状态栏
   - 允许自定义显示项

---

### 📊 方案评分对比

| 维度 | 方案A<br/>编辑器状态栏 | 方案B<br/>全局状态栏 | 方案C<br/>混合方案 |
|------|:---:|:---:|:---:|
| **用户习惯** | 7/10 | 9/10 | 6/10 |
| **信息完整性** | 6/10 | 8/10 | 10/10 |
| **界面简洁性** | 9/10 | 8/10 | 5/10 |
| **空间占用** | 9/10 | 7/10 | 4/10 |
| **技术实现** | 7/10 | 9/10 | 6/10 |
| **可扩展性** | 6/10 | 9/10 | 8/10 |
| **与产品一致性** | 6/10 | 9/10 | 7/10 |
| **专注写作体验** | 9/10 | 7/10 | 6/10 |
| **综合评分** | **7.4/10** | **🏆 8.3/10** | **6.5/10** |

---

## 6. 实现设计

### 6.1 状态栏布局设计

#### 全局状态栏（推荐布局）

```
┌─────────────────────────────────────────────────────────────┐
│ [左侧信息组] ············ [中间信息组] ············ [右侧信息组] │
└─────────────────────────────────────────────────────────────┘
```

**信息分组**：

```swift
// 左侧：编辑器信息（当编辑器获得焦点时显示）
- 光标位置: "第 3 行: 12 列"
- 选中字数: "已选中 28 字"

// 中间：笔记信息（始终显示）
- 字数统计: "1,234 字 · 88 行"
- 最后保存: "2 分钟前"
- 保存状态: "● 已保存" / "⏺ 保存中" / "○ 未保存"

// 右侧：全局信息（始终显示）
- 笔记位置: "第 5 / 42 篇"
- 过滤状态: "星标 8 篇" / "已删除 3 篇" / "搜索到 15 篇"
```

---

### 6.2 状态栏高度与样式

#### 尺寸规范

```swift
struct StatusBarMetrics {
    static let height: CGFloat = 22          // 状态栏高度
    static let horizontalPadding: CGFloat = 16
    static let itemSpacing: CGFloat = 12      // 项目间距
    static let groupSpacing: CGFloat = 24     // 组间距
}
```

#### 视觉样式

```swift
struct StatusBarStyle {
    // 背景
    static let backgroundColor = Color(nsColor: .windowBackgroundColor)
    static let borderColor = Color(nsColor: .separatorColor)
    static let borderWidth: CGFloat = 0.5
    
    // 文字
    static let fontSize: CGFloat = 11
    static let textColor = Color.secondary
    static let labelFont = Font.system(size: 11, weight: .regular, design: .default)
    
    // 图标
    static let iconSize: CGFloat = 10
}
```

---

### 6.3 动态显示逻辑

#### 根据焦点状态切换显示内容

```swift
struct StatusBarState {
    enum FocusArea {
        case sidebar       // 侧边栏获得焦点
        case noteList      // 笔记列表获得焦点
        case editor        // 编辑器获得焦点
        case preview       // 预览获得焦点
        case none          // 无焦点
    }
    
    var currentFocus: FocusArea = .none
    
    // 根据焦点决定显示内容
    var leftContent: [StatusItem] {
        switch currentFocus {
        case .editor:
            return [.cursorPosition, .selectionCount]
        case .noteList:
            return [.notePosition]
        default:
            return []
        }
    }
    
    var centerContent: [StatusItem] {
        return [.wordCount, .lastSaved, .saveStatus]
    }
    
    var rightContent: [StatusItem] {
        return [.totalNotes, .filterStatus]
    }
}
```

---

### 6.4 信息项定义

#### StatusItem 枚举

```swift
enum StatusItem: Equatable {
    // 编辑器信息
    case cursorPosition(line: Int, column: Int)
    case selectionCount(count: Int)
    case wordCount(words: Int, lines: Int)
    
    // 笔记信息
    case lastSaved(date: Date)
    case saveStatus(SaveStatus)
    case fileSize(bytes: Int64)
    
    // 全局信息
    case notePosition(current: Int, total: Int)
    case totalNotes(count: Int)
    case filterStatus(FilterType, count: Int)
    
    enum SaveStatus {
        case saved
        case saving
        case unsaved
        case error(String)
    }
    
    enum FilterType {
        case all
        case starred
        case deleted
        case search
        case tag(String)
    }
    
    // 显示文本
    var displayText: String {
        switch self {
        case .cursorPosition(let line, let column):
            return "第 \(line) 行: \(column) 列"
        case .selectionCount(let count):
            return "已选中 \(count) 字"
        case .wordCount(let words, let lines):
            return "\(words) 字 · \(lines) 行"
        case .lastSaved(let date):
            return date.timeAgoString
        case .saveStatus(let status):
            return status.displayText
        case .notePosition(let current, let total):
            return "第 \(current) / \(total) 篇"
        case .totalNotes(let count):
            return "共 \(count) 篇笔记"
        case .filterStatus(let type, let count):
            return "\(type.displayName) \(count) 篇"
        case .fileSize(let bytes):
            return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
        }
    }
    
    // 显示图标
    var icon: String? {
        switch self {
        case .cursorPosition: return "arrow.up.and.down.text.horizontal"
        case .selectionCount: return "selection.pin.in.out"
        case .wordCount: return "textformat.abc"
        case .lastSaved: return "clock"
        case .saveStatus(.saved): return "checkmark.circle.fill"
        case .saveStatus(.saving): return "arrow.clockwise.circle"
        case .saveStatus(.unsaved): return "circle.fill"
        case .saveStatus(.error): return "exclamationmark.triangle.fill"
        case .notePosition: return "doc.text"
        case .totalNotes: return "folder"
        case .filterStatus: return "line.3.horizontal.decrease.circle"
        case .fileSize: return "doc.badge.gearshape"
        }
    }
}
```

---

### 6.5 智能显示策略

#### 优先级规则

```swift
struct StatusBarDisplayPolicy {
    // 空间不足时的显示优先级
    static let priorities: [StatusItem.Type: Int] = [
        .saveStatus: 10,      // 最高优先级
        .wordCount: 9,
        .lastSaved: 8,
        .cursorPosition: 7,
        .notePosition: 6,
        .totalNotes: 5,
        .selectionCount: 4,
        .filterStatus: 3,
        .fileSize: 2          // 最低优先级
    ]
    
    // 根据窗口宽度动态调整显示项
    static func visibleItems(
        for width: CGFloat,
        items: [StatusItem]
    ) -> [StatusItem] {
        // 小窗口（< 800pt）：只显示核心信息
        if width < 800 {
            return items.filter { priorities[$0.type] ?? 0 >= 8 }
        }
        
        // 中等窗口（800-1000pt）：显示重要信息
        if width < 1000 {
            return items.filter { priorities[$0.type] ?? 0 >= 5 }
        }
        
        // 大窗口（>= 1000pt）：显示所有信息
        return items
    }
}
```

---

## 7. 技术实现

### 7.1 TCA State 扩展

```swift
// AppFeature.State 扩展
extension AppFeature.State {
    struct StatusBarState: Equatable {
        // 编辑器信息
        var cursorLine: Int = 0
        var cursorColumn: Int = 0
        var selectionLength: Int = 0
        var wordCount: Int = 0
        var lineCount: Int = 0
        
        // 笔记信息
        var lastSaved: Date?
        var isSaving: Bool = false
        var hasUnsavedChanges: Bool = false
        var saveError: String?
        var fileSize: Int64 = 0
        
        // 全局信息
        var currentNoteIndex: Int = 0
        var totalNotesCount: Int = 0
        var filteredNotesCount: Int = 0
        var currentFilterType: FilterType = .all
        
        // 焦点状态
        var focusArea: FocusArea = .none
        
        enum FocusArea {
            case sidebar
            case noteList
            case editor
            case preview
            case none
        }
        
        enum FilterType {
            case all
            case starred
            case deleted
            case search(String)
            case tag(String)
            
            var displayName: String {
                switch self {
                case .all: return "全部"
                case .starred: return "星标"
                case .deleted: return "已删除"
                case .search: return "搜索结果"
                case .tag(let name): return "标签: \(name)"
                }
            }
        }
        
        // 计算属性：左侧显示项
        var leftItems: [StatusItem] {
            var items: [StatusItem] = []
            
            if focusArea == .editor {
                if cursorLine > 0 {
                    items.append(.cursorPosition(line: cursorLine, column: cursorColumn))
                }
                if selectionLength > 0 {
                    items.append(.selectionCount(count: selectionLength))
                }
            }
            
            return items
        }
        
        // 计算属性：中间显示项
        var centerItems: [StatusItem] {
            var items: [StatusItem] = []
            
            // 字数统计
            if wordCount > 0 {
                items.append(.wordCount(words: wordCount, lines: lineCount))
            }
            
            // 保存状态
            let saveStatus: StatusItem.SaveStatus
            if let error = saveError {
                saveStatus = .error(error)
            } else if isSaving {
                saveStatus = .saving
            } else if hasUnsavedChanges {
                saveStatus = .unsaved
            } else {
                saveStatus = .saved
            }
            items.append(.saveStatus(saveStatus))
            
            // 最后保存时间
            if let lastSaved = lastSaved {
                items.append(.lastSaved(date: lastSaved))
            }
            
            return items
        }
        
        // 计算属性：右侧显示项
        var rightItems: [StatusItem] {
            var items: [StatusItem] = []
            
            // 笔记位置
            if currentNoteIndex > 0 && totalNotesCount > 0 {
                items.append(.notePosition(current: currentNoteIndex, total: totalNotesCount))
            }
            
            // 过滤状态
            if currentFilterType != .all {
                items.append(.filterStatus(currentFilterType, count: filteredNotesCount))
            } else if totalNotesCount > 0 {
                items.append(.totalNotes(count: totalNotesCount))
            }
            
            return items
        }
    }
    
    var statusBar: StatusBarState = StatusBarState()
}
```

---

### 7.2 SwiftUI 视图实现

```swift
// Views/StatusBar/StatusBarView.swift
import SwiftUI
import ComposableArchitecture

struct StatusBarView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithPerceptionTracking {
            HStack(spacing: StatusBarMetrics.itemSpacing) {
                // 左侧：编辑器信息
                StatusItemGroup(items: store.statusBar.leftItems)
                
                Spacer()
                
                // 中间：笔记信息
                StatusItemGroup(items: store.statusBar.centerItems)
                
                Spacer()
                
                // 右侧：全局信息
                StatusItemGroup(items: store.statusBar.rightItems)
            }
            .padding(.horizontal, StatusBarMetrics.horizontalPadding)
            .frame(height: StatusBarMetrics.height)
            .background(StatusBarStyle.backgroundColor)
            .overlay(
                Rectangle()
                    .frame(height: StatusBarStyle.borderWidth)
                    .foregroundColor(StatusBarStyle.borderColor),
                alignment: .top
            )
        }
    }
}

// 状态项组
struct StatusItemGroup: View {
    let items: [StatusItem]
    
    var body: some View {
        HStack(spacing: StatusBarMetrics.itemSpacing) {
            ForEach(items.indices, id: \.self) { index in
                StatusItemView(item: items[index])
                
                if index < items.count - 1 {
                    Text("·")
                        .font(StatusBarStyle.labelFont)
                        .foregroundColor(StatusBarStyle.textColor.opacity(0.5))
                }
            }
        }
    }
}

// 单个状态项
struct StatusItemView: View {
    let item: StatusItem
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = item.icon {
                Image(systemName: icon)
                    .font(.system(size: StatusBarMetrics.iconSize))
                    .foregroundColor(iconColor)
            }
            
            Text(item.displayText)
                .font(StatusBarStyle.labelFont)
                .foregroundColor(StatusBarStyle.textColor)
        }
        .help(item.tooltip ?? item.displayText)
    }
    
    private var iconColor: Color {
        switch item {
        case .saveStatus(.saved):
            return .green
        case .saveStatus(.saving):
            return .blue
        case .saveStatus(.unsaved):
            return .orange
        case .saveStatus(.error):
            return .red
        default:
            return StatusBarStyle.textColor
        }
    }
}
```

---

### 7.3 Action 处理

```swift
// AppFeature.Action 扩展
extension AppFeature.Action {
    enum StatusBar {
        case focusChanged(StatusBarState.FocusArea)
        case cursorPositionChanged(line: Int, column: Int)
        case selectionChanged(length: Int)
        case wordCountUpdated(words: Int, lines: Int)
        case notePositionUpdated(current: Int, total: Int)
        case filterChanged(StatusBarState.FilterType, count: Int)
    }
}

// AppFeature.Reducer 扩展
extension AppFeature {
    func reduceStatusBar(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .statusBar(.focusChanged(let area)):
            state.statusBar.focusArea = area
            return .none
            
        case .statusBar(.cursorPositionChanged(let line, let column)):
            state.statusBar.cursorLine = line
            state.statusBar.cursorColumn = column
            return .none
            
        case .statusBar(.selectionChanged(let length)):
            state.statusBar.selectionLength = length
            return .none
            
        case .statusBar(.wordCountUpdated(let words, let lines)):
            state.statusBar.wordCount = words
            state.statusBar.lineCount = lines
            return .none
            
        case .statusBar(.notePositionUpdated(let current, let total)):
            state.statusBar.currentNoteIndex = current
            state.statusBar.totalNotesCount = total
            return .none
            
        case .statusBar(.filterChanged(let type, let count)):
            state.statusBar.currentFilterType = type
            state.statusBar.filteredNotesCount = count
            return .none
            
        // 从其他 Action 自动更新状态栏
        case .editor(.contentChanged(let content)):
            return .send(.statusBar(.wordCountUpdated(
                words: content.wordCount,
                lines: content.lineCount
            )))
            
        case .editor(.selectionChanged(let range)):
            return .send(.statusBar(.selectionChanged(length: range.length)))
            
        case .noteList(.noteSelected(let note)):
            return .send(.statusBar(.notePositionUpdated(
                current: state.noteList.notes.firstIndex(where: { $0.id == note.id }) ?? 0 + 1,
                total: state.noteList.notes.count
            )))
            
        default:
            return .none
        }
    }
}
```

---

### 7.4 集成到主界面

```swift
// AppView.swift
struct AppView: View {
    let store: StoreOf<AppFeature>
    let appDelegate: AppDelegate
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // 主内容区域（三栏布局）
                NavigationSplitView(
                    columnVisibility: Binding(
                        get: { store.columnVisibility },
                        set: { store.send(.columnVisibilityChanged($0)) }
                    )
                ) {
                    SidebarView(
                        store: store.scope(state: \.sidebar, action: \.sidebar)
                    )
                    .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
                } content: {
                    NoteListView(
                        store: store.scope(state: \.noteList, action: \.noteList)
                    )
                    .navigationSplitViewColumnWidth(min: 280, ideal: 350, max: 500)
                } detail: {
                    NoteEditorView(
                        store: store.scope(state: \.editor, action: \.editor)
                    )
                }
                .navigationSplitViewStyle(.balanced)
                
                // 状态栏
                StatusBarView(store: store)
            }
            .frame(minWidth: 800, minHeight: 622)  // 增加最小高度以容纳状态栏
            .onAppear {
                appDelegate.store = store
                store.send(.onAppear)
            }
            // ... 其他代码
        }
    }
}
```

---

### 7.5 工具扩展

```swift
// Utilities/Extensions/String+WordCount.swift
extension String {
    var wordCount: Int {
        // 中文字符数
        let chineseCount = self.filter { $0.unicodeScalars.first?.value ?? 0 > 0x4E00 && $0.unicodeScalars.first?.value ?? 0 < 0x9FA5 }.count
        
        // 英文单词数
        let words = self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty && $0.rangeOfCharacter(from: .letters) != nil }
        let englishWords = words.count
        
        return chineseCount + englishWords
    }
    
    var lineCount: Int {
        return self.components(separatedBy: .newlines).count
    }
}

// Utilities/Extensions/Date+TimeAgo.swift
extension Date {
    var timeAgoString: String {
        let interval = Date().timeIntervalSince(self)
        
        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) 分钟前"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) 小时前"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days) 天前"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: self)
        }
    }
}
```

---

## 8. 后续优化

### 8.1 Phase 2 功能

1. **右键菜单**：
   - 点击状态栏项显示详细信息
   - 自定义显示项

2. **可配置性**：
   - 在设置中允许用户选择显示项
   - 保存用户偏好

3. **动画效果**：
   - 保存状态切换时的动画
   - 字数变化的平滑过渡

### 8.2 Phase 3 功能

1. **高级统计**：
   - 阅读时间估算
   - 写作速度（字/分钟）
   - 笔记年龄（创建后多久）

2. **快捷操作**：
   - 点击笔记位置快速跳转
   - 点击字数查看详细统计

---

## 总结

### ✅ 推荐方案：全局底部状态栏

**核心原因**：
1. ✅ 符合用户习惯和行业惯例
2. ✅ 信息全局可见，始终展示状态
3. ✅ 与 Nota2 设计保持一致
4. ✅ 技术实现简单清晰
5. ✅ 易于扩展和维护

**显示内容**：
- **左侧**：编辑器信息（光标、选中）
- **中间**：笔记信息（字数、保存状态）
- **右侧**：全局信息（笔记总数、位置）

**实现要点**：
- TCA 状态管理
- 动态显示策略（根据焦点切换）
- 智能空间分配（窗口大小适配）
- 优雅的视觉设计

---

**是否批准此方案？** 🎯




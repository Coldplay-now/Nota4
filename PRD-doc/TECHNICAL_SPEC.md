# Nota4 技术规格总结 (Technical Specification)

> **版本**: v1.0  
> **更新日期**: 2025-11-15  
> **GitHub 仓库**: https://github.com/Coldplay-now/Nota4  
> **目标**: 指导 Nota4 开发，明确技术选型和核心注意点

---

## 📋 目录

1. [技术栈选型](#技术栈选型)
2. [核心架构](#核心架构)
3. [关键技术决策](#关键技术决策)
4. [核心问题与注意点](#核心问题与注意点)
5. [开发优先级](#开发优先级)
6. [性能指标](#性能指标)

---

## 1. 技术栈选型

### 1.1 核心框架

| 技术 | 版本 | 用途 | 选型理由 |
|-----|------|------|---------|
| **SwiftUI** | 4.0+ | UI 框架 | 声明式、自动管理状态、现代化、Liquid 动画 |
| **TCA** | 1.11+ | 状态管理 | 单向数据流、可预测、可测试、模块化 |
| **GRDB** | 6.0+ | 数据库 | 成熟稳定、高性能、支持 FTS5 全文搜索 |
| **MarkdownUI** | 2.0+ | Markdown 渲染 | 原生 SwiftUI、支持代码高亮和主题 |
| **Yams** | 5.0+ | YAML 解析 | 解析 .nota 文件的 YAML Front Matter |

### 1.2 系统要求

- **最低版本**: macOS 15.0+ (Sequoia)
- **开发工具**: Xcode 15.0+
- **包管理**: Swift Package Manager (SPM)

### 1.3 依赖清单

```swift
dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.11.0"),
    .package(url: "https://github.com/groue/GRDB.swift", from: "6.0.0"),
    .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.0"),
    .package(url: "https://github.com/jpsim/Yams", from: "5.0.0"),
]
```

---

## 2. 核心架构

### 2.1 架构模式

**TCA (The Composable Architecture)**

```
┌─────────────────────────────────────┐
│         AppState (单一数据源)         │
│  ├─ SidebarState                    │
│  ├─ NoteListState                   │
│  └─ EditorState                     │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│         AppReducer (纯函数)          │
│  ├─ sidebarReducer                  │
│  ├─ noteListReducer                 │
│  └─ editorReducer                   │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│      AppEnvironment (依赖注入)       │
│  ├─ noteRepository                  │
│  ├─ fileManager                     │
│  └─ imageManager                    │
└─────────────────────────────────────┘
```

**核心原则**:
- ✅ **单一数据源**: 所有状态存储在 AppState
- ✅ **单向数据流**: View → Action → Reducer → State → View
- ✅ **纯函数**: Reducer 无副作用，易于测试
- ✅ **依赖注入**: Environment 隔离外部依赖

### 2.2 UI 架构

**NavigationSplitView (三栏布局)**

```
┌──────────┬──────────────┬───────────────────┐
│ Sidebar  │  NoteList    │   NoteEditor      │
│ (200pt)  │  (350pt)     │   (剩余空间)       │
│          │              │                   │
│ 📝 全部  │ ┌──────────┐ │ ┌───────────────┐ │
│ ⭐ 星标  │ │ 笔记卡片  │ │ │ 编辑器/预览    │ │
│ 🏷️ 标签  │ └──────────┘ │ └───────────────┘ │
│ 🗑️ 已删除│              │                   │
└──────────┴──────────────┴───────────────────┘
```

**关键组件**:
- `SidebarView`: 分类和标签导航
- `NoteListView`: 笔记列表（支持搜索、排序、滑动操作）
- `NoteEditorView`: 编辑器（支持编辑/预览/分屏模式）

### 2.3 数据架构

**双写机制（文件 + 数据库）**

```
写入流程:
1. 更新 .nota 文件（文件系统）
2. 更新数据库记录（SQLite）
3. 更新全文搜索索引（FTS5）
4. 计算并更新 checksum

读取流程:
1. 从数据库读取元数据（快速）
2. 从文件读取完整内容（按需）
3. 校验 checksum（检测外部修改）
```

**核心原则**: **文件是"真理之源"，数据库是"性能缓存"**

---

## 3. 关键技术决策

### 3.1 文件格式

**选择**: `.nota` 格式（YAML Front Matter + Markdown）

**格式示例**:
```yaml
---
note_id: A464F114-7334-42E8-B58C-69E82F10E461
title: 我的笔记
tags: ["工作", "重要"]
starred: false
pinned: false
created: 2023-11-09T14:30:00+08:00
updated: 2023-11-09T15:45:00+08:00
checksum: d41d8cd98f00b204e9800998ecf8427e
---

# 我的笔记

正文内容...
```

**决策理由**:
- ✅ 兼容 Markdown（可无损转换）
- ✅ 元数据内嵌（不依赖数据库）
- ✅ 通用格式（Jekyll、Hugo 兼容）
- ✅ 避免并发冲突（专有扩展名）

### 3.2 图片存储

**选择**: 本地附件目录 + 相对路径引用

**目录结构**:
```
NotaLibrary/
├── notes/                 # 笔记文件
├── attachments/           # 图片附件
│   ├── {noteId}/         # 按笔记分组
│   │   ├── img_001.png
│   │   └── img_002.jpg
└── metadata.db           # 数据库
```

**Markdown 引用**:
```markdown
![图片](attachments/{noteId}/img_001.png)
```

**决策理由**:
- ✅ 按笔记分组，便于管理
- ✅ 相对路径，便于导出打包
- ✅ 支持多种格式（PNG、JPEG、GIF、WebP）

### 3.3 导入导出

**支持格式**:

| 操作 | 格式 | 实现方式 |
|-----|------|---------|
| **导入** | .nota | 解析 YAML + 复制附件 |
| | .md | 读取 Markdown |
| | .txt | 转换为 Markdown |
| **导出** | .nota | ZIP 打包（文件 + 附件） |
| | .md | 导出附件目录或 Base64 |
| | .html | Base64 内嵌图片 |
| | .pdf | WKWebView 渲染并打印 |

---

## 4. 核心问题与注意点

### 4.1 状态管理（最重要）⭐

**Nota2 的核心问题**:
- ❌ 4 个状态源不同步（tableView、currentSelectedNoteId、viewModel、cellView）
- ❌ 手动管理状态同步，容易出错
- ❌ 选中状态滞留、双选 bug

**Nota4 的解决方案**:
- ✅ **TCA 单一数据源**: 所有状态存储在 `AppState`
- ✅ **自动驱动 UI**: SwiftUI 根据状态自动更新
- ✅ **可追踪**: 所有变化通过 `Action` 记录

**关键注意点**:
1. **避免在视图层修改状态**: 所有状态修改必须通过 `Action`
2. **使用 ViewStore.scope**: 只订阅需要的状态子集，避免无效刷新
3. **Equatable 优化**: 为大型视图实现 `Equatable`，减少重绘

### 4.2 自动保存与光标管理

**Nota2 的问题**:
- ❌ 自动保存时光标跳到文件末尾
- ❌ 撤销栈被清空，导致无法撤销

**Nota4 的解决方案**:
- ✅ **防抖机制**: 0.8 秒延迟自动保存
- ✅ **不重新加载内容**: 保存后不触发 `loadNote`，保持编辑状态
- ✅ **保留撤销栈**: 只在必要时清空（如切换笔记）

**关键注意点**:
1. **区分 loadContent 场景**: 切换笔记清空撤销栈，自动保存不清空
2. **TCA Effect 防抖**: 使用 `.cancellable(id:)` 取消旧的保存任务
3. **动画控制**: 保存状态变化时添加 `.spring()` 动画

### 4.3 数据一致性

**核心问题**: 文件和数据库可能不同步

**解决方案**:
1. **Checksum 校验**: 每次读取文件时检查 MD5
2. **检测外部修改**: Checksum 不匹配时提示用户选择
3. **原子操作**: 数据库和文件同时更新，失败时回滚

**关键注意点**:
1. **双写顺序**: 先更新数据库，再更新文件，最后更新 FTS
2. **错误处理**: 捕获异常并回滚，保证一致性
3. **定期校验**: 启动时扫描所有文件，修复不一致

### 4.4 图片生命周期管理

**核心问题**: 笔记删除后图片如何处理？

**解决方案**:
1. **绑定生命周期**: 删除笔记时移动图片到 `trash_attachments/`
2. **恢复笔记**: 同时恢复图片目录
3. **永久删除**: 同时删除笔记文件和图片目录
4. **垃圾回收**: 定期清理未被引用的图片

**关键注意点**:
1. **同步操作**: 笔记和图片操作必须同步，避免孤儿文件
2. **正则匹配**: 扫描 Markdown 内容，找出未使用的图片
3. **用户确认**: 永久删除前提示用户，避免误删

### 4.5 性能优化

**关键点**:

1. **列表性能**:
   - 使用 `IdentifiedArrayOf` 高效管理列表
   - 为 `NoteRowView` 实现 `Equatable`
   - 使用 `.equatable()` 减少重绘

2. **搜索性能**:
   - 使用 SQLite FTS5 全文搜索索引
   - 搜索结果限制 100 条
   - 防抖搜索输入（300ms）

3. **渲染性能**:
   - 大文件分段加载
   - 图片懒加载（`AsyncImage`）
   - 预览模式按需渲染

4. **内存管理**:
   - 及时释放未使用的笔记内容
   - 限制缓存大小
   - 使用 `@ViewStore` 而非 `@ObservedObject`

---

## 5. 开发优先级

### 5.1 v1.0.0 MVP（Week 1-5，33.5 天）

**必须实现**:
- ✅ 笔记 CRUD（创建、读取、更新、删除）
- ✅ 笔记列表（显示、搜索、排序、过滤）
- ✅ 编辑器（Markdown 编辑、自动保存）
- ✅ 预览（MarkdownUI 渲染）
- ✅ 分栏布局（NavigationSplitView）
- ✅ 数据库（GRDB + FTS5）
- ✅ 文件系统（.nota 读写）
- ✅ TCA 架构（State + Reducer + Environment）
- ✅ 图片插入和预览（纯文本编辑器）
- ✅ 导入（.nota / .md / .txt）
- ✅ 导出（.nota / .md / .html / .pdf）

**辅助功能**:
- ✅ 星标笔记
- ✅ 置顶笔记
- ✅ 右键菜单
- ✅ 滑动操作
- ✅ 下拉刷新

### 5.2 v1.1.0 功能增强（Week 6-8，12 天）

- ✅ 标签系统
- ✅ 右键插入 Markdown 格式
- ✅ 性能优化（Equatable、ViewStore.scope）
- ✅ UI 优化（动画、渐变、阴影）
- 🤔 富文本编辑器（图片缩略图）- 可选
- 🤔 Touch Bar 支持 - 可选

### 5.3 v1.2.0 高级功能（Week 9-11，可选）

- ⏸️ Spotlight 集成
- ⏸️ PDF 附件
- ⏸️ 版本历史
- ⏸️ 缩略图生成
- ⏸️ iCloud 同步（最低优先级）

---

## 6. 性能指标

| 指标 | 目标 | 测量方式 |
|-----|------|---------|
| **启动时间** | < 1 秒 | Instruments |
| **列表滚动** | 60 FPS | Xcode Profiler |
| **搜索响应** | < 200ms | 单元测试 |
| **自动保存延迟** | 800ms | 用户感知 |
| **大文件加载** | < 500ms (10MB) | 性能测试 |
| **内存占用** | < 100MB | Activity Monitor |

---

## 7. 测试策略

### 7.1 单元测试（目标覆盖率 80%+）

**重点测试**:
- ✅ Reducer 逻辑（TCA TestStore）
- ✅ NoteRepository CRUD
- ✅ FileManager 文件操作
- ✅ YAML 解析和生成
- ✅ Checksum 校验

### 7.2 集成测试

- ✅ 数据库和文件同步
- ✅ 导入导出流程
- ✅ 全文搜索功能
- ✅ 图片插入和导出

### 7.3 UI 测试

- ✅ SwiftUI Previews（快速验证）
- ✅ 关键流程测试（创建、编辑、删除）
- ✅ 暗色主题适配

---

## 8. 开发注意事项

### 8.1 代码规范

1. **TCA 规范**:
   - State 只包含可序列化的数据
   - Reducer 必须是纯函数
   - 副作用只能在 Effect 中执行

2. **SwiftUI 规范**:
   - 视图只负责渲染，不包含业务逻辑
   - 使用 `@ViewStore` 订阅状态
   - 为大型视图实现 `Equatable`

3. **命名规范**:
   - Action 使用动词（`createNote`、`deleteNote`）
   - State 使用名词（`notes`、`selectedNoteId`）
   - Effect 使用 `.run { }` 或 `.task { }`

### 8.2 调试技巧

1. **TCA 调试**:
   - 使用 `_printChanges()` 查看状态变化
   - 使用 `.debug()` 打印 Action
   - 使用 TestStore 验证逻辑

2. **SwiftUI 调试**:
   - 使用 Xcode Previews 快速迭代
   - 使用 `Self._printChanges()` 查看重绘原因
   - 使用 Instruments 分析性能

3. **数据调试**:
   - 使用 DB Browser for SQLite 查看数据库
   - 使用 Finder 查看文件结构
   - 使用 Git diff 查看文件变化

### 8.3 常见陷阱

1. **状态管理**:
   - ❌ 在视图中修改状态
   - ❌ 订阅整个 AppState（应使用 scope）
   - ❌ 忘记实现 Equatable

2. **数据同步**:
   - ❌ 只更新数据库不更新文件
   - ❌ 不检查 checksum
   - ❌ 不处理外部修改冲突

3. **性能**:
   - ❌ 渲染大文件不分段
   - ❌ 列表不使用 Equatable
   - ❌ 频繁触发全局刷新

---

## 9. 参考资源

### 9.1 官方文档

- **TCA**: https://github.com/pointfreeco/swift-composable-architecture
- **SwiftUI**: https://developer.apple.com/documentation/swiftui
- **GRDB**: https://github.com/groue/GRDB.swift
- **MarkdownUI**: https://github.com/gonzalezreal/swift-markdown-ui
- **Yams**: https://github.com/jpsim/Yams

### 9.2 学习资源

- **TCA 教程**: https://www.pointfree.co/collections/composable-architecture
- **SwiftUI 教程**: https://developer.apple.com/tutorials/swiftui
- **GRDB FTS5**: https://github.com/groue/GRDB.swift/blob/master/Documentation/FullTextSearch.md

### 9.3 项目资源

- **GitHub 仓库**: https://github.com/Coldplay-now/Nota4
- **PRD 文档**: `/Nota4/PRD-doc/NOTA4_PRD.md`
- **更新日志**: `/Nota4/PRD-doc/UPDATES_2025-11-15.md`

---

## 10. 项目目录结构

### 10.1 标准目录规范

```
Nota4/
├── Nota4/                          # 主应用代码
│   ├── App/                        # 应用入口
│   │   ├── Nota4App.swift
│   │   └── AppView.swift
│   ├── Features/                   # 功能模块（TCA Feature）
│   │   ├── Sidebar/
│   │   │   ├── SidebarFeature.swift
│   │   │   └── SidebarView.swift
│   │   ├── NoteList/
│   │   │   ├── NoteListFeature.swift
│   │   │   ├── NoteListView.swift
│   │   │   └── NoteRowView.swift
│   │   └── Editor/
│   │       ├── EditorFeature.swift
│   │       ├── NoteEditorView.swift
│   │       └── MarkdownEditor.swift
│   ├── Models/                     # 数据模型
│   │   ├── Note.swift
│   │   ├── Tag.swift
│   │   └── Category.swift
│   ├── Services/                   # 业务服务
│   │   ├── NoteRepository.swift
│   │   ├── NotaFileManager.swift
│   │   ├── ImageManager.swift
│   │   └── DatabaseManager.swift
│   ├── Views/                      # 通用视图组件
│   │   ├── Components/
│   │   │   ├── EmptyStateView.swift
│   │   │   └── LoadingView.swift
│   │   └── Modifiers/
│   │       └── CardStyle.swift
│   ├── Utilities/                  # 工具类
│   │   ├── Extensions/
│   │   │   ├── Date+Extensions.swift
│   │   │   └── String+Extensions.swift
│   │   └── Helpers/
│   │       ├── ChecksumHelper.swift
│   │       └── YAMLParser.swift
│   └── Resources/                  # 资源文件
│       ├── Assets.xcassets/
│       └── Info.plist
│
├── Nota4Tests/                     # 单元测试 ⭐
│   ├── FeatureTests/               # 功能测试
│   │   ├── SidebarFeatureTests.swift
│   │   ├── NoteListFeatureTests.swift
│   │   └── EditorFeatureTests.swift
│   ├── ServiceTests/               # 服务测试
│   │   ├── NoteRepositoryTests.swift
│   │   ├── FileManagerTests.swift
│   │   └── ImageManagerTests.swift
│   ├── ModelTests/                 # 模型测试
│   │   └── NoteTests.swift
│   └── Mocks/                      # Mock 数据
│       ├── MockNote.swift
│       └── MockEnvironment.swift
│
├── Nota4UITests/                   # UI 测试 ⭐
│   ├── NoteListUITests.swift
│   ├── EditorUITests.swift
│   └── Helpers/
│       └── XCUIElementExtensions.swift
│
├── Scripts/                        # 自动化脚本 ⭐
│   ├── build/                      # 构建脚本
│   │   ├── build_debug.sh          # 调试构建
│   │   ├── build_release.sh        # 发布构建
│   │   └── build_universal.sh      # 通用二进制
│   ├── deploy/                     # 部署脚本
│   │   ├── sign_and_notarize.sh    # 签名和公证
│   │   ├── create_dmg.sh           # 创建 DMG
│   │   └── upload_release.sh       # 上传发布
│   ├── test/                       # 测试脚本
│   │   ├── run_unit_tests.sh       # 运行单元测试
│   │   ├── run_ui_tests.sh         # 运行 UI 测试
│   │   └── test_coverage.sh        # 测试覆盖率
│   ├── db/                         # 数据库脚本
│   │   ├── migrate.sh              # 数据库迁移
│   │   └── seed.sh                 # 测试数据填充
│   └── utils/                      # 工具脚本
│       ├── setup_dev_env.sh        # 开发环境设置
│       ├── clean_build.sh          # 清理构建
│       └── generate_icons.sh       # 生成图标
│
├── Docs/                           # 项目文档 ⭐
│   ├── PRD/                        # 产品需求文档
│   │   ├── NOTA4_PRD.md
│   │   ├── TECHNICAL_SPEC.md
│   │   └── UPDATES.md
│   ├── Architecture/               # 架构文档
│   │   ├── TCA_ARCHITECTURE.md     # TCA 架构说明
│   │   ├── DATA_FLOW.md            # 数据流设计
│   │   └── STATE_MANAGEMENT.md     # 状态管理
│   ├── Development/                # 开发文档
│   │   ├── SETUP_GUIDE.md          # 环境设置指南
│   │   ├── CODING_STANDARDS.md     # 代码规范
│   │   └── DEBUGGING_GUIDE.md      # 调试指南
│   ├── API/                        # API 文档
│   │   ├── NoteRepository.md
│   │   ├── FileManager.md
│   │   └── ImageManager.md
│   └── Process/                    # 过程文档 ⭐
│       ├── CHANGELOG.md            # 变更日志
│       ├── MEETING_NOTES/          # 会议记录
│       │   ├── 2025-11-15.md
│       │   └── ...
│       ├── DECISIONS/              # 技术决策记录
│       │   ├── 001-tca-adoption.md
│       │   ├── 002-file-format.md
│       │   └── ...
│       └── ITERATIONS/             # 迭代记录
│           ├── Week-01.md
│           ├── Week-02.md
│           └── ...
│
├── Tools/                          # 开发工具 ⭐
│   ├── CodeGen/                    # 代码生成器
│   │   └── generate_feature.sh     # TCA Feature 模板生成
│   ├── Linters/                    # 代码检查
│   │   └── swiftlint.yml
│   └── Formatters/                 # 代码格式化
│       └── swiftformat.yml
│
├── Config/                         # 配置文件
│   ├── Debug.xcconfig
│   ├── Release.xcconfig
│   └── Shared.xcconfig
│
├── Assets/                         # 设计资源（源文件）
│   ├── Icons/                      # 图标源文件
│   │   └── AppIcon.sketch
│   └── Screenshots/                # 截图
│       └── ...
│
├── .github/                        # GitHub 配置
│   ├── workflows/                  # CI/CD 工作流
│   │   ├── ci.yml                  # 持续集成
│   │   └── release.yml             # 发布流程
│   ├── ISSUE_TEMPLATE/             # Issue 模板
│   └── PULL_REQUEST_TEMPLATE.md    # PR 模板
│
├── Package.swift                   # SPM 配置
├── .gitignore                      # Git 忽略文件
├── .swiftlint.yml                  # SwiftLint 配置
├── README.md                       # 项目说明
└── LICENSE                         # 开源协议
```

### 10.2 目录规范说明

#### 10.2.1 核心原则

1. **按功能分层**: Features（功能）→ Services（服务）→ Models（模型）
2. **测试并行**: 测试目录结构与主代码对应
3. **脚本集中**: 所有自动化脚本放在 `Scripts/` 目录
4. **文档分类**: 按文档类型分类（PRD、架构、开发、过程）
5. **配置分离**: 配置文件独立目录，便于管理

#### 10.2.2 关键目录详解

**📁 Features/** - TCA 功能模块
- 每个功能一个子目录
- 包含 Feature（Reducer）和 View
- 完整的 TCA 模块封装

**📁 Scripts/** - 自动化脚本 ⭐
```bash
# 构建脚本示例
Scripts/build/build_release.sh

# 测试脚本示例
Scripts/test/run_unit_tests.sh

# 部署脚本示例
Scripts/deploy/sign_and_notarize.sh
```

**📁 Docs/Process/** - 过程文档 ⭐
- `CHANGELOG.md`: 版本变更记录
- `MEETING_NOTES/`: 会议记录（按日期）
- `DECISIONS/`: 技术决策记录（ADR）
- `ITERATIONS/`: 每周迭代总结

**📁 Tests/** - 测试目录 ⭐
- 与主代码结构对应
- Mocks 目录存放测试数据
- 目标覆盖率 80%+

#### 10.2.3 命名规范

| 类型 | 规范 | 示例 |
|-----|------|------|
| **TCA Feature** | `{Name}Feature.swift` | `EditorFeature.swift` |
| **视图** | `{Name}View.swift` | `NoteListView.swift` |
| **服务** | `{Name}Manager.swift` / `{Name}Repository.swift` | `ImageManager.swift` |
| **测试** | `{Name}Tests.swift` | `EditorFeatureTests.swift` |
| **脚本** | `{action}_{target}.sh` | `build_release.sh` |
| **文档** | `UPPERCASE.md` | `CHANGELOG.md` |

#### 10.2.4 脚本使用示例

**构建脚本**:
```bash
# 调试构建
./Scripts/build/build_debug.sh

# 发布构建（通用二进制）
./Scripts/build/build_universal.sh

# 签名和公证
./Scripts/deploy/sign_and_notarize.sh
```

**测试脚本**:
```bash
# 运行单元测试
./Scripts/test/run_unit_tests.sh

# 运行 UI 测试
./Scripts/test/run_ui_tests.sh

# 生成测试覆盖率报告
./Scripts/test/test_coverage.sh
```

**工具脚本**:
```bash
# 设置开发环境
./Scripts/utils/setup_dev_env.sh

# 清理构建缓存
./Scripts/utils/clean_build.sh

# 生成新的 TCA Feature
./Tools/CodeGen/generate_feature.sh EditorFeature
```

#### 10.2.5 过程文档规范

**技术决策记录（ADR）格式**:
```markdown
# ADR-001: 采用 TCA 架构

## 状态
✅ 已接受

## 背景
Nota2 使用 AppKit + MVVM，存在状态管理混乱问题...

## 决策
采用 TCA 1.11 作为状态管理框架

## 后果
- 正面：单一数据源、可预测、可测试
- 负面：学习曲线、初期开发速度慢

## 日期
2025-11-15
```

**迭代记录格式**:
```markdown
# Week 01 迭代总结

## 目标
- 创建项目
- 添加依赖
- 定义 AppState

## 完成情况
- ✅ 项目创建完成
- ✅ TCA 依赖添加
- 🟡 AppState 定义中（50%）

## 问题与解决
- 问题：SPM 依赖解析慢
- 解决：使用镜像源

## 下周计划
- 完成 AppState 定义
- 实现 NoteRepository
```

---

## 11. 快速开始

### 11.1 环境准备

```bash
# 1. 克隆仓库
git clone https://github.com/Coldplay-now/Nota4.git
cd Nota4

# 2. 运行设置脚本
./Scripts/utils/setup_dev_env.sh

# 3. 打开项目
open Nota4.xcodeproj
```

### 11.2 依赖安装

在 Xcode 中：
1. File → Add Packages...
2. 添加上述依赖清单中的包
3. 等待 SPM 解析依赖

### 11.3 第一周任务

1. **Day 1-2**: 创建项目，配置依赖
2. **Day 3-4**: 定义 AppState、AppAction、AppReducer
3. **Day 5**: 搭建 NavigationSplitView 基础布局

---

## 📝 总结

### ✅ 核心要点

1. **架构**: TCA + SwiftUI 4.0，单向数据流
2. **数据**: 双写机制（文件 + 数据库），文件为主
3. **性能**: Equatable + ViewStore.scope + FTS5
4. **图片**: 本地附件 + 相对路径 + Base64 导出
5. **测试**: 单元测试覆盖率 80%+
6. **目录结构**: 功能分层、脚本集中、文档分类 ⭐

### ⚠️ 重点注意

1. **状态管理**: 避免 Nota2 的多状态源问题
2. **自动保存**: 防抖 + 不清空撤销栈
3. **数据一致性**: Checksum 校验 + 原子操作
4. **图片管理**: 生命周期绑定 + 垃圾回收
5. **性能优化**: 懒加载 + 分段渲染 + Equatable
6. **目录规范**: Scripts/ 统一脚本，Docs/Process/ 记录过程 ⭐

### 🚀 开发准备

- ✅ PRD 已完成
- ✅ 技术规格已明确
- ✅ GitHub 仓库已创建
- ✅ 依赖清单已确定
- ✅ 开发优先级已确认

**可以开始 Week 1 的开发工作！** 🎉

---

*文档版本: v1.0*  
*最后更新: 2025-11-15*  
*GitHub: https://github.com/Coldplay-now/Nota4*


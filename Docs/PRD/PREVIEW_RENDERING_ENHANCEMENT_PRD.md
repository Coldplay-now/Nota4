# Markdown 预览渲染增强 PRD

**版本**: v1.2  
**日期**: 2025-11-16  
**状态**: 规划中（已完成 TCA 架构设计）  
**优先级**: P0（核心功能）

---

## 📋 目录

- [1. 产品概述](#1-产品概述)
- [2. 现状评估](#2-现状评估)
- [3. 功能规划](#3-功能规划)
- [4. 技术方案](#4-技术方案)
  - [4.1 技术栈选择](#41-技术栈选择)
  - [4.2 整体架构](#42-整体架构)
  - [4.3 主题系统设计](#43-主题系统设计) ⭐ 新增
  - [4.4 UI 交互设计](#44-ui-交互设计) ⭐ 新增
  - [4.5 TCA 状态管理](#45-tca-状态管理) ⭐ 新增
  - [4.6 核心实现](#46-核心实现)
- [5. 实施计划](#5-实施计划)
- [6. 测试计划](#6-测试计划)
- [7. 性能优化](#7-性能优化)
- [8. 风险评估](#8-风险评估)

---

## 1. 产品概述

### 1.1 背景

当前 Nota4 已经实现了基础的 Markdown 预览功能，但缺少专业笔记应用的标配特性：
- ❌ 代码块没有语法高亮
- ❌ 不支持 Mermaid 图表
- ❌ 不支持数学公式
- ❌ 没有目录（TOC）生成
- ❌ 外部图片链接无法预览
- ❌ 样式不够美观

### 1.2 目标用户

1. **开发者**：需要代码块语法高亮、Mermaid 图表
2. **学生/研究者**：需要数学公式渲染
3. **知识工作者**：需要美观的排版、图片预览
4. **长文写作者**：需要 TOC 导航

### 1.3 核心价值

- ✅ **专业性**：媲美 Typora、Obsidian 的渲染效果
- ✅ **易用性**：所见即所得，实时预览
- ✅ **完整性**：支持所有常见 Markdown 扩展语法
- ✅ **美观性**：现代化设计，可打印
- ✅ **可扩展性**：主题系统支持自定义和分享

### 1.4 UI 交互原则

- ✅ **配置集中化**：所有主题和样式配置统一在"首选项"中管理
- ✅ **预览简洁化**：预览界面不提供主题切换等配置选项，保持纯粹的内容展示
- ✅ **状态一致性**：通过 TCA 状态管理确保主题变更在全局生效
- ✅ **响应式更新**：主题切换后所有预览窗口自动更新

---

## 2. 现状评估

### 2.1 已实现功能

| 功能 | 状态 | 实现程度 | 说明 |
|------|------|---------|------|
| 基础 Markdown | ✅ 已实现 | 80% | 支持标题、列表、引用等 |
| 代码块 | ⚠️ 部分实现 | 40% | 显示代码，但无语法高亮 |
| 图片 | ⚠️ 部分实现 | 50% | 本地图片可预览，外链不支持 |
| 链接 | ✅ 已实现 | 100% | 支持超链接 |
| 表格 | ✅ 已实现 | 90% | 基础表格支持 |

### 2.2 缺失功能

| 功能 | 状态 | 优先级 | 技术复杂度 |
|------|------|--------|-----------|
| 代码语法高亮 | ❌ 未实现 | **P0** | 🟡 中等 |
| Mermaid 图表 | ❌ 未实现 | **P0** | 🟡 中等 |
| 数学公式 | ❌ 未实现 | **P0** | 🟡 中等 |
| TOC 目录 | ❌ 未实现 | **P0** | 🟢 简单 |
| 外部图片链接 | ❌ 未实现 | **P0** | 🟢 简单 |
| 样式优化 | ⚠️ 待改进 | **P0** | 🟢 简单 |
| **主题系统** | ❌ 未实现 | **P0** | 🟡 中等 |
| **样式模板** | ❌ 未实现 | **P0** | 🟡 中等 |
| 导出优化 | ⚠️ 待改进 | **P1** | 🟢 简单 |

---

## 3. 功能规划

### 3.1 功能清单

#### **3.1.1 基础渲染优化（P0）**

| 功能 | 优先级 | 工时 | 说明 |
|------|--------|------|------|
| Markdown 样式美化 | **P0** | 3h | 现代化 CSS 设计，参考 GitHub 样式 |
| 响应式布局 | **P0** | 2h | 适配不同窗口大小 |
| 打印优化 | **P0** | 1h | 打印友好的 CSS |

#### **3.1.2 代码增强（P0）**

| 功能 | 优先级 | 工时 | 说明 |
|------|--------|------|------|
| 代码块语法高亮 | **P0** | 3h | 支持 50+ 语言，多种主题 |
| 行号显示 | **P0** | 1h | 可选显示行号 |
| 代码复制按钮 | **P1** | 1h | 一键复制代码 |

#### **3.1.3 图表与可视化（P0）**

| 功能 | 优先级 | 工时 | 说明 |
|------|--------|------|------|
| Mermaid 图表 | **P0** | 4h | 流程图、时序图、甘特图等 |
| 图表主题 | **P1** | 1h | 适配明暗主题 |

#### **3.1.4 数学公式（P0）**

| 功能 | 优先级 | 工时 | 说明 |
|------|--------|------|------|
| 行内公式 `$...$` | **P0** | 2h | 使用 KaTeX 渲染 |
| 块公式 `$$...$$` | **P0** | 1h | 独立段落公式 |

#### **3.1.5 图片增强（P0）**

| 功能 | 优先级 | 工时 | 说明 |
|------|--------|------|------|
| 外部图片链接 | **P0** | 2h | 支持 HTTP/HTTPS 图片 |
| 图片缓存 | **P1** | 2h | 本地缓存，提升加载速度 |
| 图片点击放大 | **P1** | 2h | 点击查看大图 |
| 图片加载失败提示 | **P0** | 1h | 友好的错误提示 |

#### **3.1.6 导航增强（P0）**

| 功能 | 优先级 | 工时 | 说明 |
|------|--------|------|------|
| TOC 目录生成 | **P0** | 2h | 自动提取标题层级 |
| 目录点击跳转 | **P0** | 1h | 滚动到对应位置 |
| 目录折叠/展开 | **P1** | 1h | 支持折叠子标题 |

#### **3.1.7 主题系统（P0）**

| 功能 | 优先级 | 工时 | 说明 |
|------|--------|------|------|
| 主题配置模型 | **P0** | 2h | 定义主题结构，支持扩展 |
| 内置主题（Light/Dark） | **P0** | 3h | 提供默认明暗主题 |
| 主题动态加载 | **P0** | 2h | 运行时切换主题 |
| 主题管理器 | **P0** | 2h | 主题注册、切换、持久化 |

#### **3.1.8 样式模板（P0）**

| 功能 | 优先级 | 工时 | 说明 |
|------|--------|------|------|
| CSS 文件外置 | **P0** | 2h | 将CSS从代码中分离 |
| CSS 变量系统 | **P0** | 2h | 支持可配置的样式变量 |
| 模板文件结构 | **P0** | 1h | 定义主题目录结构 |
| 自定义主题导入 | **P1** | 3h | 用户可导入自定义CSS |
| 主题导出分享 | **P1** | 2h | 导出主题配置文件 |

---

### 3.2 功能优先级总结

**P0（必须实现）**：
- ✅ Markdown 样式美化
- ✅ 代码块语法高亮
- ✅ Mermaid 图表渲染
- ✅ 数学公式渲染
- ✅ TOC 目录生成
- ✅ 外部图片链接支持
- ✅ **主题系统架构**
- ✅ **CSS 样式模板化**
- ✅ **内置明暗主题**

**P1（重要功能）**：
- 📋 代码复制按钮
- 📋 图片缓存
- 📋 图片点击放大
- 📋 **自定义主题导入**
- 📋 **主题导出分享**

**P2（可选功能）**：
- 📋 导出模板定制
- 📋 Markdown 扩展语法（脚注、任务列表高亮等）
- 📋 **在线主题市场**

---

## 4. 技术方案

### 4.1 技术栈选择

| 功能模块 | 技术方案 | 理由 |
|---------|---------|------|
| **Markdown 解析** | [Ink](https://github.com/JohnSundell/Ink) | 纯 Swift、轻量、快速 |
| **代码高亮** | [Splash](https://github.com/JohnSundell/Splash) | 纯 Swift、支持多语言 |
| **Mermaid 图表** | [Mermaid.js](https://mermaid.js.org/) (WebKit) | 功能完整、社区活跃 |
| **数学公式** | [KaTeX](https://katex.org/) (WebKit) | 快速、体积小、离线可用 |
| **图片加载** | URLSession + ImageCache | 原生 API + 自定义缓存 |
| **渲染容器** | WKWebView | 支持 JavaScript、CSS、离线资源 |

---

### 4.2 整体架构

```
┌─────────────────────────────────────────┐
│     NoteEditorView (SwiftUI)            │
│  ┌────────────┐    ┌─────────────────┐ │
│  │  Editor    │    │ Preview         │ │
│  │ (NSTextView)│◄──►│ (MarkdownPreview)│ │
│  └────────────┘    └─────────────────┘ │
└─────────────────────────────────────────┘
                            │
                            ▼
            ┌───────────────────────────┐
            │ MarkdownRenderer (Service)│
            └───────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Ink Parser   │  │ Splash       │  │ WebKit       │
│ (Markdown→   │  │ (Code        │  │ (Mermaid/    │
│  HTML)       │  │  Highlight)  │  │  KaTeX)      │
└──────────────┘  └──────────────┘  └──────────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │ WKWebView    │
                    │ (Final       │
                    │  Rendering)  │
                    └──────────────┘
```

---

### 4.3 主题系统设计

#### **4.3.1 主题配置模型**

```swift
import Foundation

/// 主题配置
struct ThemeConfig: Codable, Identifiable {
    let id: String
    let name: String
    let displayName: String
    let author: String?
    let version: String
    let description: String?
    
    // 样式文件
    let cssFileName: String
    
    // 代码高亮主题
    let codeHighlightTheme: CodeTheme
    
    // Mermaid 图表主题
    let mermaidTheme: String  // "default", "dark", "forest", "neutral"
    
    // 颜色变量（可选，用于动态配置）
    let colors: ThemeColors?
    
    // 字体配置（可选）
    let fonts: ThemeFonts?
    
    // 创建时间
    let createdAt: Date
    let updatedAt: Date
}

/// 主题颜色配置
struct ThemeColors: Codable {
    var primaryColor: String       // 主色调
    var backgroundColor: String    // 背景色
    var textColor: String          // 文本色
    var secondaryTextColor: String // 次要文本色
    var linkColor: String          // 链接色
    var codeBackgroundColor: String // 代码背景色
    var borderColor: String        // 边框色
    var accentColor: String        // 强调色
}

/// 字体配置
struct ThemeFonts: Codable {
    var bodyFont: String    // 正文字体
    var headingFont: String // 标题字体
    var codeFont: String    // 代码字体
    var fontSize: Int       // 基础字体大小（px）
    var lineHeight: Double  // 行高
}

/// 代码高亮主题
enum CodeTheme: String, Codable {
    case xcode = "xcode"
    case github = "github"
    case monokai = "monokai"
    case dracula = "dracula"
    case solarizedLight = "solarized-light"
    case solarizedDark = "solarized-dark"
}
```

---

#### **4.3.2 主题管理器**

```swift
import Foundation

/// 主题管理器（单例）
actor ThemeManager {
    static let shared = ThemeManager()
    
    // MARK: - Properties
    
    private(set) var availableThemes: [ThemeConfig] = []
    private(set) var currentTheme: ThemeConfig
    
    private let themesDirectory: URL
    private let userThemesDirectory: URL
    
    // MARK: - Initialization
    
    private init() {
        // 内置主题目录
        themesDirectory = Bundle.main.url(
            forResource: "Themes",
            withExtension: nil
        )!
        
        // 用户自定义主题目录
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        userThemesDirectory = appSupport
            .appendingPathComponent("Nota4/Themes")
        
        // 创建用户主题目录
        try? FileManager.default.createDirectory(
            at: userThemesDirectory,
            withIntermediateDirectories: true
        )
        
        // 加载默认主题
        currentTheme = ThemeConfig.defaultLight
        
        // 异步加载所有主题
        Task {
            await loadAllThemes()
        }
    }
    
    // MARK: - Public Methods
    
    /// 加载所有主题
    func loadAllThemes() async {
        var themes: [ThemeConfig] = []
        
        // 加载内置主题
        themes.append(contentsOf: loadBuiltInThemes())
        
        // 加载用户主题
        themes.append(contentsOf: loadUserThemes())
        
        availableThemes = themes
        
        print("📚 [THEME] Loaded \(themes.count) themes")
    }
    
    /// 切换主题
    func switchTheme(to themeId: String) async throws {
        guard let theme = availableThemes.first(where: { $0.id == themeId }) else {
            throw ThemeError.themeNotFound(themeId)
        }
        
        currentTheme = theme
        
        // 持久化用户选择
        UserDefaults.standard.set(themeId, forKey: "selectedThemeId")
        
        // 发送通知（通知 UI 更新）
        await MainActor.run {
            NotificationCenter.default.post(
                name: .themeDidChange,
                object: theme
            )
        }
        
        print("🎨 [THEME] Switched to: \(theme.displayName)")
    }
    
    /// 导入自定义主题
    func importTheme(from url: URL) async throws -> ThemeConfig {
        // 1. 验证主题包
        let validator = ThemeValidator()
        try validator.validate(themePackageURL: url)
        
        // 2. 解压主题包到用户目录
        let themeId = url.deletingPathExtension().lastPathComponent
        let destination = userThemesDirectory.appendingPathComponent(themeId)
        
        if FileManager.default.fileExists(atPath: destination.path) {
            throw ThemeError.themeAlreadyExists(themeId)
        }
        
        try FileManager.default.copyItem(at: url, to: destination)
        
        // 3. 读取主题配置
        let configURL = destination.appendingPathComponent("theme.json")
        let data = try Data(contentsOf: configURL)
        let theme = try JSONDecoder().decode(ThemeConfig.self, from: data)
        
        // 4. 添加到可用主题列表
        availableThemes.append(theme)
        
        print("✅ [THEME] Imported: \(theme.displayName)")
        
        return theme
    }
    
    /// 导出主题
    func exportTheme(_ themeId: String, to destinationURL: URL) async throws {
        guard let theme = availableThemes.first(where: { $0.id == themeId }) else {
            throw ThemeError.themeNotFound(themeId)
        }
        
        // 查找主题文件
        let themeDir = userThemesDirectory.appendingPathComponent(themeId)
        
        guard FileManager.default.fileExists(atPath: themeDir.path) else {
            throw ThemeError.cannotExportBuiltInTheme
        }
        
        // 打包主题
        try FileManager.default.copyItem(at: themeDir, to: destinationURL)
        
        print("📤 [THEME] Exported: \(theme.displayName)")
    }
    
    /// 删除用户主题
    func deleteTheme(_ themeId: String) async throws {
        guard let theme = availableThemes.first(where: { $0.id == themeId }) else {
            throw ThemeError.themeNotFound(themeId)
        }
        
        // 不允许删除内置主题
        guard !theme.id.hasPrefix("builtin-") else {
            throw ThemeError.cannotDeleteBuiltInTheme
        }
        
        // 删除主题文件
        let themeDir = userThemesDirectory.appendingPathComponent(themeId)
        try FileManager.default.removeItem(at: themeDir)
        
        // 从列表中移除
        availableThemes.removeAll { $0.id == themeId }
        
        // 如果删除的是当前主题，切换到默认主题
        if currentTheme.id == themeId {
            try await switchTheme(to: "builtin-light")
        }
        
        print("🗑️ [THEME] Deleted: \(theme.displayName)")
    }
    
    /// 获取主题的 CSS 内容
    func getCSS(for theme: ThemeConfig) async throws -> String {
        // 1. 尝试从内置资源加载
        if let builtInURL = themesDirectory?.appendingPathComponent(theme.cssFileName),
           FileManager.default.fileExists(atPath: builtInURL.path) {
            return try String(contentsOf: builtInURL)
        }
        
        // 2. 尝试从用户主题加载
        let userURL = userThemesDirectory
            .appendingPathComponent(theme.id)
            .appendingPathComponent(theme.cssFileName)
        
        if FileManager.default.fileExists(atPath: userURL.path) {
            return try String(contentsOf: userURL)
        }
        
        throw ThemeError.cssFileNotFound(theme.cssFileName)
    }
    
    // MARK: - Private Methods
    
    private func loadBuiltInThemes() -> [ThemeConfig] {
        // 返回硬编码的内置主题
        return [
            ThemeConfig.defaultLight,
            ThemeConfig.defaultDark,
            ThemeConfig.github,
            ThemeConfig.notion
        ]
    }
    
    private func loadUserThemes() -> [ThemeConfig] {
        var themes: [ThemeConfig] = []
        
        guard let enumerator = FileManager.default.enumerator(
            at: userThemesDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return themes
        }
        
        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == "theme.json" {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let theme = try JSONDecoder().decode(ThemeConfig.self, from: data)
                    themes.append(theme)
                } catch {
                    print("⚠️ [THEME] Failed to load: \(fileURL.path)")
                }
            }
        }
        
        return themes
    }
}

// MARK: - Errors

enum ThemeError: LocalizedError {
    case themeNotFound(String)
    case themeAlreadyExists(String)
    case cssFileNotFound(String)
    case invalidThemePackage
    case cannotDeleteBuiltInTheme
    case cannotExportBuiltInTheme
    
    var errorDescription: String? {
        switch self {
        case .themeNotFound(let id):
            return "主题未找到: \(id)"
        case .themeAlreadyExists(let id):
            return "主题已存在: \(id)"
        case .cssFileNotFound(let name):
            return "CSS 文件未找到: \(name)"
        case .invalidThemePackage:
            return "无效的主题包"
        case .cannotDeleteBuiltInTheme:
            return "无法删除内置主题"
        case .cannotExportBuiltInTheme:
            return "无法导出内置主题"
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
```

---

#### **4.3.3 内置主题定义**

```swift
extension ThemeConfig {
    /// 默认浅色主题
    static let defaultLight = ThemeConfig(
        id: "builtin-light",
        name: "light",
        displayName: "浅色",
        author: "Nota4",
        version: "1.0.0",
        description: "默认浅色主题",
        cssFileName: "light.css",
        codeHighlightTheme: .xcode,
        mermaidTheme: "default",
        colors: ThemeColors(
            primaryColor: "#0066cc",
            backgroundColor: "#ffffff",
            textColor: "#333333",
            secondaryTextColor: "#666666",
            linkColor: "#0066cc",
            codeBackgroundColor: "#f5f5f5",
            borderColor: "#e0e0e0",
            accentColor: "#0066cc"
        ),
        fonts: ThemeFonts(
            bodyFont: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
            headingFont: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
            codeFont: "'SF Mono', Monaco, Menlo, 'Courier New', monospace",
            fontSize: 16,
            lineHeight: 1.6
        ),
        createdAt: Date(),
        updatedAt: Date()
    )
    
    /// 默认深色主题
    static let defaultDark = ThemeConfig(
        id: "builtin-dark",
        name: "dark",
        displayName: "深色",
        author: "Nota4",
        version: "1.0.0",
        description: "默认深色主题",
        cssFileName: "dark.css",
        codeHighlightTheme: .dracula,
        mermaidTheme: "dark",
        colors: ThemeColors(
            primaryColor: "#4da6ff",
            backgroundColor: "#1e1e1e",
            textColor: "#e0e0e0",
            secondaryTextColor: "#aaaaaa",
            linkColor: "#4da6ff",
            codeBackgroundColor: "#2d2d2d",
            borderColor: "#404040",
            accentColor: "#4da6ff"
        ),
        fonts: ThemeFonts(
            bodyFont: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
            headingFont: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
            codeFont: "'SF Mono', Monaco, Menlo, 'Courier New', monospace",
            fontSize: 16,
            lineHeight: 1.6
        ),
        createdAt: Date(),
        updatedAt: Date()
    )
    
    /// GitHub 风格主题
    static let github = ThemeConfig(
        id: "builtin-github",
        name: "github",
        displayName: "GitHub",
        author: "Nota4",
        version: "1.0.0",
        description: "GitHub 风格主题",
        cssFileName: "github.css",
        codeHighlightTheme: .github,
        mermaidTheme: "neutral",
        colors: nil,  // 使用 CSS 文件中的样式
        fonts: nil,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    /// Notion 风格主题
    static let notion = ThemeConfig(
        id: "builtin-notion",
        name: "notion",
        displayName: "Notion",
        author: "Nota4",
        version: "1.0.0",
        description: "Notion 风格主题",
        cssFileName: "notion.css",
        codeHighlightTheme: .github,
        mermaidTheme: "default",
        colors: nil,
        fonts: nil,
        createdAt: Date(),
        updatedAt: Date()
    )
}
```

---

#### **4.3.4 主题文件结构**

```
Nota4/
└── Resources/
    └── Themes/
        ├── light.css                # 浅色主题样式
        ├── dark.css                 # 深色主题样式
        ├── github.css               # GitHub 风格
        ├── notion.css               # Notion 风格
        └── template/                # 主题模板（用于创建自定义主题）
            ├── theme.json           # 主题配置示例
            ├── style.css            # CSS 模板
            └── README.md            # 主题开发指南

用户主题存储位置：
~/Library/Application Support/Nota4/Themes/
└── my-custom-theme/
    ├── theme.json               # 主题配置
    ├── style.css                # 自定义样式
    └── preview.png              # 主题预览图（可选）
```

---

#### **4.3.5 CSS 变量系统**

主题 CSS 文件应使用 CSS 变量，便于动态配置：

```css
/* light.css */
:root {
    /* 颜色变量 */
    --primary-color: #0066cc;
    --background-color: #ffffff;
    --text-color: #333333;
    --secondary-text-color: #666666;
    --link-color: #0066cc;
    --link-hover-color: #0052a3;
    --code-background-color: #f5f5f5;
    --code-border-color: #e0e0e0;
    --border-color: #e0e0e0;
    --accent-color: #0066cc;
    --blockquote-border-color: #0066cc;
    --table-header-bg: #f5f5f5;
    
    /* 字体变量 */
    --body-font: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', sans-serif;
    --heading-font: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    --code-font: 'SF Mono', Monaco, Menlo, 'Courier New', monospace;
    
    /* 尺寸变量 */
    --font-size: 16px;
    --line-height: 1.6;
    --heading-line-height: 1.3;
    --code-font-size: 0.9em;
    
    /* 间距变量 */
    --spacing-xs: 0.25rem;
    --spacing-sm: 0.5rem;
    --spacing-md: 1rem;
    --spacing-lg: 1.5rem;
    --spacing-xl: 2rem;
    
    /* 圆角变量 */
    --border-radius-sm: 3px;
    --border-radius-md: 6px;
    --border-radius-lg: 8px;
}

/* 使用变量 */
body {
    font-family: var(--body-font);
    font-size: var(--font-size);
    line-height: var(--line-height);
    color: var(--text-color);
    background: var(--background-color);
}

a {
    color: var(--link-color);
}

a:hover {
    color: var(--link-hover-color);
}

code {
    background: var(--code-background-color);
    border: 1px solid var(--code-border-color);
    border-radius: var(--border-radius-sm);
    font-family: var(--code-font);
    font-size: var(--code-font-size);
}

/* 其他样式... */
```

---

### 4.4 UI 交互设计

#### **4.4.1 首选项 - 主题设置卡片**

**位置**：`Preferences -> Appearance -> Preview Theme`

**功能布局**：

```
┌─────────────────────────────────────────────┐
│  预览主题                                     │
├─────────────────────────────────────────────┤
│                                             │
│  [○ 浅色]  [● 深色]  [○ GitHub]  [○ Notion] │
│                                             │
│  ───────────────────────────────────────── │
│                                             │
│  自定义主题列表：                              │
│  ┌─────────────────────────────────┐       │
│  │ • My Custom Theme    [导出][删除] │       │
│  │ • Dark Blue          [导出][删除] │       │
│  └─────────────────────────────────┘       │
│                                             │
│  [+ 导入主题]                                │
│                                             │
│  预览示例：                                   │
│  ┌─────────────────────────────────┐       │
│  │ # 标题示例                       │       │
│  │ 这是一段**粗体**文本             │       │
│  │ ```swift                        │       │
│  │ func hello() { }                │       │
│  │ ```                             │       │
│  └─────────────────────────────────┘       │
└─────────────────────────────────────────────┘
```

**交互规则**：

1. **主题选择**：
   - 点击任意主题卡片即可切换
   - 当前主题显示选中状态（蓝色边框 + 勾选图标）
   - 切换后立即保存到 UserDefaults
   - 所有打开的预览窗口自动更新

2. **导入主题**：
   - 点击"导入主题"按钮打开文件选择器
   - 支持 `.notatheme` 格式（包含 theme.json + CSS 文件的目录）
   - 验证主题包格式，失败显示错误提示
   - 导入成功后自动添加到自定义主题列表

3. **导出主题**：
   - 只能导出用户自定义主题（内置主题不可导出）
   - 点击"导出"打开保存对话框
   - 导出为 `.notatheme` 目录包

4. **删除主题**：
   - 只能删除用户自定义主题
   - 删除前显示确认对话框
   - 如果删除的是当前主题，自动切换到"浅色"

5. **实时预览**：
   - 预览示例区域实时显示当前主题效果
   - 包含标题、代码块、列表等常见元素

---

#### **4.4.2 预览界面 - 纯粹的内容展示**

**设计原则**：
- ❌ **不提供主题切换按钮** - 避免界面混乱
- ❌ **不显示主题名称** - 保持内容聚焦
- ✅ **自动响应主题变更** - 监听全局主题变更通知
- ✅ **无缝重新渲染** - 主题切换时平滑过渡

**实现方式**：
```swift
// PreviewView 只负责展示，不管理主题配置
struct MarkdownPreviewView: View {
    let markdown: String
    let store: StoreOf<PreviewFeature>
    
    var body: some View {
        WebView(html: viewStore.renderedHTML)
            .onReceive(NotificationCenter.default.publisher(for: .themeDidChange)) { _ in
                // 主题变更时自动重新渲染
                viewStore.send(.themeChanged)
            }
    }
}
```

---

### 4.5 TCA 状态管理

#### **4.5.1 架构原则**

在 TCA（The Composable Architecture）中管理主题系统需要遵循以下原则：

1. **单一数据源（Single Source of Truth）**：
   - 主题状态统一存储在 `AppState` 或 `PreferencesState` 中
   - 所有组件通过订阅状态变化来响应主题更新

2. **单向数据流（Unidirectional Data Flow）**：
   - 用户操作 → Action → Reducer → State 更新 → View 重新渲染

3. **副作用隔离（Side Effect Isolation）**：
   - 主题加载、导入、导出等异步操作通过 `Effect` 处理
   - 使用 `@Dependency` 注入 `ThemeManager`

4. **可测试性（Testability）**：
   - `ThemeManager` 通过依赖注入，测试时可替换为 Mock
   - Reducer 纯函数，易于单元测试

---

#### **4.5.2 State 定义**

```swift
import ComposableArchitecture

// MARK: - Theme State

/// 主题功能的状态
struct ThemeState: Equatable {
    /// 当前选中的主题 ID
    var currentThemeId: String = "builtin-light"
    
    /// 所有可用的主题列表
    var availableThemes: IdentifiedArrayOf<ThemeConfig> = []
    
    /// 主题加载状态
    var isLoadingThemes: Bool = false
    
    /// 主题导入/导出状态
    var importExportState: ImportExportState = .idle
    
    /// 错误信息
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    /// 当前主题配置
    var currentTheme: ThemeConfig? {
        availableThemes[id: currentThemeId]
    }
    
    /// 内置主题列表
    var builtInThemes: [ThemeConfig] {
        availableThemes.filter { $0.id.hasPrefix("builtin-") }
    }
    
    /// 用户自定义主题列表
    var customThemes: [ThemeConfig] {
        availableThemes.filter { !$0.id.hasPrefix("builtin-") }
    }
}

/// 导入/导出状态
enum ImportExportState: Equatable {
    case idle
    case importing
    case exporting
    case success
    case failure(String)
}
```

---

#### **4.5.3 Action 定义**

```swift
// MARK: - Theme Actions

enum ThemeAction: Equatable {
    // MARK: - Lifecycle
    case onAppear
    case loadThemes
    case themesLoaded(TaskResult<[ThemeConfig]>)
    
    // MARK: - Theme Selection
    case selectTheme(String)
    case themeSelected(TaskResult<ThemeConfig>)
    
    // MARK: - Import/Export
    case importThemeButtonTapped
    case importTheme(URL)
    case importThemeResponse(TaskResult<ThemeConfig>)
    
    case exportTheme(String)
    case exportThemeResponse(TaskResult<Void>)
    
    // MARK: - Delete
    case deleteTheme(String)
    case deleteThemeResponse(TaskResult<String>)
    case confirmDelete(String)
    case cancelDelete
    
    // MARK: - Error Handling
    case dismissError
}
```

---

#### **4.5.4 Reducer 实现**

```swift
import ComposableArchitecture

// MARK: - Theme Reducer

struct ThemeFeature: Reducer {
    struct State: Equatable {
        var theme: ThemeState = ThemeState()
        // ... 其他状态
    }
    
    enum Action: Equatable {
        case theme(ThemeAction)
        // ... 其他 Action
    }
    
    @Dependency(\.themeManager) var themeManager
    @Dependency(\.mainQueue) var mainQueue
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // MARK: - Lifecycle
            case .theme(.onAppear):
                return .send(.theme(.loadThemes))
                
            case .theme(.loadThemes):
                state.theme.isLoadingThemes = true
                return .run { send in
                    await send(.theme(.themesLoaded(
                        TaskResult {
                            await themeManager.loadAllThemes()
                            return await themeManager.availableThemes
                        }
                    )))
                }
                
            case let .theme(.themesLoaded(.success(themes))):
                state.theme.isLoadingThemes = false
                state.theme.availableThemes = IdentifiedArray(uniqueElements: themes)
                // 恢复上次选择的主题
                if let savedThemeId = UserDefaults.standard.string(forKey: "selectedThemeId") {
                    state.theme.currentThemeId = savedThemeId
                }
                return .none
                
            case let .theme(.themesLoaded(.failure(error))):
                state.theme.isLoadingThemes = false
                state.theme.errorMessage = error.localizedDescription
                return .none
                
            // MARK: - Theme Selection
            case let .theme(.selectTheme(themeId)):
                guard state.theme.currentThemeId != themeId else { return .none }
                
                return .run { send in
                    await send(.theme(.themeSelected(
                        TaskResult {
                            try await themeManager.switchTheme(to: themeId)
                            return await themeManager.currentTheme
                        }
                    )))
                }
                
            case let .theme(.themeSelected(.success(theme))):
                state.theme.currentThemeId = theme.id
                // 通知所有预览窗口更新
                // NotificationCenter 会在 ThemeManager 内部发送
                return .none
                
            case let .theme(.themeSelected(.failure(error))):
                state.theme.errorMessage = error.localizedDescription
                return .none
                
            // MARK: - Import Theme
            case let .theme(.importTheme(url)):
                state.theme.importExportState = .importing
                return .run { send in
                    await send(.theme(.importThemeResponse(
                        TaskResult {
                            try await themeManager.importTheme(from: url)
                        }
                    )))
                }
                
            case let .theme(.importThemeResponse(.success(theme))):
                state.theme.importExportState = .success
                state.theme.availableThemes.append(theme)
                // 2秒后重置状态
                return .run { send in
                    try await mainQueue.sleep(for: .seconds(2))
                    await send(.theme(.dismissError))
                }
                
            case let .theme(.importThemeResponse(.failure(error))):
                state.theme.importExportState = .failure(error.localizedDescription)
                return .none
                
            // MARK: - Export Theme
            case let .theme(.exportTheme(themeId)):
                state.theme.importExportState = .exporting
                // 打开保存对话框由 View 层处理
                return .none
                
            // MARK: - Delete Theme
            case let .theme(.confirmDelete(themeId)):
                return .run { send in
                    await send(.theme(.deleteThemeResponse(
                        TaskResult {
                            try await themeManager.deleteTheme(themeId)
                            return themeId
                        }
                    )))
                }
                
            case let .theme(.deleteThemeResponse(.success(themeId))):
                state.theme.availableThemes.remove(id: themeId)
                // 如果删除的是当前主题，切换到默认主题
                if state.theme.currentThemeId == themeId {
                    return .send(.theme(.selectTheme("builtin-light")))
                }
                return .none
                
            case let .theme(.deleteThemeResponse(.failure(error))):
                state.theme.errorMessage = error.localizedDescription
                return .none
                
            // MARK: - Error Handling
            case .theme(.dismissError):
                state.theme.errorMessage = nil
                state.theme.importExportState = .idle
                return .none
                
            default:
                return .none
            }
        }
    }
}
```

---

#### **4.5.5 Dependency 注入**

```swift
import ComposableArchitecture

// MARK: - ThemeManager Dependency

extension ThemeManager: DependencyKey {
    static let liveValue: ThemeManager = .shared
    
    static let testValue: ThemeManager = {
        // 测试用的 Mock ThemeManager
        let manager = ThemeManager()
        // 配置测试数据
        return manager
    }()
}

extension DependencyValues {
    var themeManager: ThemeManager {
        get { self[ThemeManager.self] }
        set { self[ThemeManager.self] = newValue }
    }
}
```

---

#### **4.5.6 预览功能集成**

```swift
// MARK: - Preview Feature State

struct PreviewFeature: Reducer {
    struct State: Equatable {
        var markdown: String = ""
        var renderedHTML: String = ""
        var isRendering: Bool = false
        
        // 不直接存储主题，而是通过全局状态获取
        var currentThemeId: String = ""
    }
    
    enum Action: Equatable {
        case markdownChanged(String)
        case renderMarkdown
        case renderCompleted(String)
        case themeChanged  // 响应全局主题变更
    }
    
    @Dependency(\.markdownRenderer) var markdownRenderer
    @Dependency(\.themeManager) var themeManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .markdownChanged(markdown):
                state.markdown = markdown
                return .send(.renderMarkdown)
                    .debounce(id: "render", for: .milliseconds(300), scheduler: mainQueue)
                
            case .renderMarkdown:
                state.isRendering = true
                let markdown = state.markdown
                
                return .run { send in
                    let html = try await markdownRenderer.renderToHTML(
                        markdown: markdown,
                        options: .default  // 使用当前主题
                    )
                    await send(.renderCompleted(html))
                }
                
            case let .renderCompleted(html):
                state.renderedHTML = html
                state.isRendering = false
                return .none
                
            case .themeChanged:
                // 主题变更时重新渲染
                state.currentThemeId = await themeManager.currentTheme.id
                return .send(.renderMarkdown)
            }
        }
    }
}
```

---

#### **4.5.7 TCA 最佳实践总结**

| 原则 | 说明 | 示例 |
|------|------|------|
| **状态不可变** | State 是 struct，通过 Reducer 纯函数更新 | `state.theme.currentThemeId = themeId` |
| **副作用隔离** | 异步操作通过 Effect 处理 | `.run { send in ... }` |
| **依赖注入** | 使用 `@Dependency` 注入外部依赖 | `@Dependency(\.themeManager)` |
| **可测试性** | Reducer 纯函数，副作用可模拟 | `ThemeManager.testValue` |
| **模块化** | 功能独立，通过 `Scope` 组合 | `ThemeFeature` 独立实现 |
| **错误处理** | 使用 `TaskResult` 统一处理成功/失败 | `.themesLoaded(TaskResult<[Theme]>)` |
| **防抖优化** | 使用 `.debounce()` 减少频繁更新 | 渲染防抖 300ms |

---

### 4.6 核心实现

#### **4.6.1 MarkdownRenderer 服务（更新版）**

```swift
import Foundation
import Ink
import Splash

/// Markdown 渲染服务
actor MarkdownRenderer {
    // MARK: - Properties
    
    private let parser = MarkdownParser()
    private let highlighter = SyntaxHighlighter(format: HTMLOutputFormat())
    private let imageCache = ImageCache.shared
    private let themeManager = ThemeManager.shared
    
    // MARK: - Public Methods
    
    /// 渲染 Markdown 为完整 HTML
    func renderToHTML(
        markdown: String,
        options: RenderOptions = .default
    ) async throws -> String {
        // 1. 预处理（提取 Mermaid、数学公式、代码块）
        let preprocessed = preprocess(markdown)
        
        // 2. Markdown → HTML（使用 Ink）
        var html = parser.html(from: preprocessed.markdown)
        
        // 3. 注入代码高亮
        html = highlightCodeBlocks(html)
        
        // 4. 注入 Mermaid 图表
        html = injectMermaidCharts(html, charts: preprocessed.mermaidCharts)
        
        // 5. 注入数学公式
        html = injectMathFormulas(html, formulas: preprocessed.mathFormulas)
        
        // 6. 处理外部图片链接
        html = try await processImageLinks(html)
        
        // 7. 生成 TOC（如果需要）
        let toc = options.includeTOC ? generateTOC(from: markdown) : nil
        
        // 8. 构建完整 HTML
        return await buildFullHTML(
            content: html,
            toc: toc,
            options: options
        )
    }
    
    // MARK: - Private Methods
    
    /// 预处理 Markdown（提取特殊块）
    private func preprocess(_ markdown: String) -> PreprocessedMarkdown {
        var result = markdown
        var mermaidCharts: [String] = []
        var mathFormulas: [MathFormula] = []
        
        // 提取 Mermaid 代码块
        let mermaidPattern = "```mermaid\\n([\\s\\S]*?)```"
        if let regex = try? NSRegularExpression(pattern: mermaidPattern) {
            let matches = regex.matches(
                in: result,
                range: NSRange(result.startIndex..., in: result)
            )
            
            for (index, match) in matches.enumerated().reversed() {
                if let range = Range(match.range(at: 1), in: result) {
                    let chart = String(result[range])
                    mermaidCharts.insert(chart, at: 0)
                    
                    // 替换为占位符
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(
                        fullRange,
                        with: "<div class=\"mermaid-placeholder\" data-index=\"\\(index)\"></div>"
                    )
                }
            }
        }
        
        // 提取数学公式（块公式 $$...$$）
        let blockMathPattern = "\\$\\$([\\s\\S]*?)\\$\\$"
        if let regex = try? NSRegularExpression(pattern: blockMathPattern) {
            let matches = regex.matches(
                in: result,
                range: NSRange(result.startIndex..., in: result)
            )
            
            for (index, match) in matches.enumerated().reversed() {
                if let range = Range(match.range(at: 1), in: result) {
                    let formula = String(result[range])
                    mathFormulas.insert(.block(formula), at: 0)
                    
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(
                        fullRange,
                        with: "<div class=\"math-placeholder block\" data-index=\"\\(index)\"></div>"
                    )
                }
            }
        }
        
        // 提取行内公式（$...$）
        let inlineMathPattern = "\\$([^$]+?)\\$"
        if let regex = try? NSRegularExpression(pattern: inlineMathPattern) {
            let matches = regex.matches(
                in: result,
                range: NSRange(result.startIndex..., in: result)
            )
            
            for (index, match) in matches.enumerated().reversed() {
                if let range = Range(match.range(at: 1), in: result) {
                    let formula = String(result[range])
                    mathFormulas.insert(.inline(formula), at: 0)
                    
                    let fullRange = Range(match.range, in: result)!
                    result.replaceSubrange(
                        fullRange,
                        with: "<span class=\"math-placeholder inline\" data-index=\"\\(index)\"></span>"
                    )
                }
            }
        }
        
        return PreprocessedMarkdown(
            markdown: result,
            mermaidCharts: mermaidCharts,
            mathFormulas: mathFormulas
        )
    }
    
    /// 代码块语法高亮
    private func highlightCodeBlocks(_ html: String) -> String {
        var result = html
        
        // 匹配代码块
        let pattern = "<pre><code class=\"language-(\\w+)\">([\\s\\S]*?)</code></pre>"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return result
        }
        
        let matches = regex.matches(
            in: result,
            range: NSRange(result.startIndex..., in: result)
        )
        
        for match in matches.reversed() {
            guard let langRange = Range(match.range(at: 1), in: result),
                  let codeRange = Range(match.range(at: 2), in: result) else {
                continue
            }
            
            let language = String(result[langRange])
            let code = String(result[codeRange])
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
                .replacingOccurrences(of: "&amp;", with: "&")
            
            // 使用 Splash 高亮
            let highlighted = highlighter.highlight(code)
            
            let fullRange = Range(match.range, in: result)!
            result.replaceSubrange(
                fullRange,
                with: """
                <pre class="code-block" data-language="\(language)">
                    <code class="language-\(language)">\(highlighted)</code>
                </pre>
                """
            )
        }
        
        return result
    }
    
    /// 注入 Mermaid 图表
    private func injectMermaidCharts(_ html: String, charts: [String]) -> String {
        var result = html
        
        for (index, chart) in charts.enumerated() {
            let placeholder = "<div class=\"mermaid-placeholder\" data-index=\"\\(index)\"></div>"
            let mermaidDiv = """
            <div class="mermaid">
            \(chart)
            </div>
            """
            result = result.replacingOccurrences(of: placeholder, with: mermaidDiv)
        }
        
        return result
    }
    
    /// 注入数学公式
    private func injectMathFormulas(_ html: String, formulas: [MathFormula]) -> String {
        var result = html
        
        for (index, formula) in formulas.enumerated() {
            switch formula {
            case .block(let latex):
                let placeholder = "<div class=\"math-placeholder block\" data-index=\"\\(index)\"></div>"
                let mathDiv = """
                <div class="math-block">
                    <span class="katex-formula" data-formula="\(escapeHTML(latex))"></span>
                </div>
                """
                result = result.replacingOccurrences(of: placeholder, with: mathDiv)
                
            case .inline(let latex):
                let placeholder = "<span class=\"math-placeholder inline\" data-index=\"\\(index)\"></span>"
                let mathSpan = """
                <span class="math-inline katex-formula" data-formula="\(escapeHTML(latex))"></span>
                """
                result = result.replacingOccurrences(of: placeholder, with: mathSpan)
            }
        }
        
        return result
    }
    
    /// 处理外部图片链接
    private func processImageLinks(_ html: String) async throws -> String {
        var result = html
        
        // 匹配图片标签
        let pattern = "<img src=\"([^\"]+)\" alt=\"([^\"]*)\"[^>]*>"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return result
        }
        
        let matches = regex.matches(
            in: result,
            range: NSRange(result.startIndex..., in: result)
        )
        
        for match in matches.reversed() {
            guard let srcRange = Range(match.range(at: 1), in: result) else {
                continue
            }
            
            let src = String(result[srcRange])
            
            // 处理外部链接
            if src.hasPrefix("http://") || src.hasPrefix("https://") {
                // 添加 loading 和 error 处理
                let fullRange = Range(match.range, in: result)!
                let original = String(result[fullRange])
                
                let enhanced = original
                    .replacingOccurrences(of: "<img ", with: "<img loading=\"lazy\" onerror=\"this.src='data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%22200%22 height=%22150%22%3E%3Crect fill=%22%23f0f0f0%22 width=%22200%22 height=%22150%22/%3E%3Ctext x=%2250%25%22 y=%2250%25%22 dominant-baseline=%22middle%22 text-anchor=%22middle%22 fill=%22%23999%22%3E加载失败%3C/text%3E%3C/svg%3E'\" ")
                
                result.replaceSubrange(fullRange, with: enhanced)
            }
        }
        
        return result
    }
    
    /// 生成 TOC
    private func generateTOC(from markdown: String) -> String {
        var toc = "<nav class=\"toc\">\n<h2>目录</h2>\n<ul>\n"
        
        let lines = markdown.components(separatedBy: .newlines)
        var currentLevel = 0
        
        for line in lines {
            if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                let title = line.dropFirst(level).trimmingCharacters(in: .whitespaces)
                let id = title.lowercased().replacingOccurrences(of: " ", with: "-")
                
                // 处理层级变化
                if level > currentLevel {
                    for _ in currentLevel..<level {
                        toc += "<ul>\n"
                    }
                } else if level < currentLevel {
                    for _ in level..<currentLevel {
                        toc += "</ul>\n</li>\n"
                    }
                }
                
                toc += "<li><a href=\"#\(id)\">\(escapeHTML(title))</a></li>\n"
                currentLevel = level
            }
        }
        
        // 关闭所有未关闭的标签
        for _ in 0..<currentLevel {
            toc += "</ul>\n"
        }
        
        toc += "</nav>"
        return toc
    }
    
    /// 构建完整 HTML
    private func buildFullHTML(
        content: String,
        toc: String?,
        options: RenderOptions
    ) async -> String {
        let css = await getCSS(themeId: options.themeId)
        let theme = await (options.themeId != nil ? 
            themeManager.availableThemes.first(where: { $0.id == options.themeId }) : 
            themeManager.currentTheme) ?? ThemeConfig.defaultLight
        
        return """
        <!DOCTYPE html>
        <html lang="zh-CN">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Preview</title>
            \(css)
            \(getMermaidScript())
            \(getKaTeXScript())
        </head>
        <body data-theme="\(theme.id)">
            <div class="container">
                \(toc ?? "")
                <article class="content">
                \(content)
                </article>
            </div>
            <script>
                // 初始化 Mermaid
                mermaid.initialize({ 
                    startOnLoad: true, 
                    theme: '\(theme.mermaidTheme)' 
                });
                
                // 初始化 KaTeX
                document.querySelectorAll('.katex-formula').forEach(el => {
                    const formula = el.dataset.formula;
                    const isBlock = el.parentElement.classList.contains('math-block');
                    katex.render(formula, el, {
                        displayMode: isBlock,
                        throwOnError: false
                    });
                });
            </script>
        </body>
        </html>
        """
    }
    
    // MARK: - Helper Methods
    
    private func escapeHTML(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
    
    private func getCSS(themeId: String?) async -> String {
        // 获取主题
        let theme: ThemeConfig
        if let id = themeId,
           let selectedTheme = await themeManager.availableThemes.first(where: { $0.id == id }) {
            theme = selectedTheme
        } else {
            theme = await themeManager.currentTheme
        }
        
        // 加载 CSS 文件
        do {
            let css = try await themeManager.getCSS(for: theme)
            
            // 如果主题有颜色配置，注入 CSS 变量
            var finalCSS = css
            if let colors = theme.colors {
                let variables = generateCSSVariables(colors: colors, fonts: theme.fonts)
                finalCSS = variables + "\n" + css
            }
            
            return "<style>\(finalCSS)</style>"
        } catch {
            print("⚠️ [RENDERER] Failed to load CSS: \(error)")
            // 降级方案：使用内置默认样式
            return "<style>\(CSSStyles.fallback)</style>"
        }
    }
    
    private func generateCSSVariables(colors: ThemeColors, fonts: ThemeFonts?) -> String {
        var css = ":root {\n"
        
        // 颜色变量
        css += "    --primary-color: \(colors.primaryColor);\n"
        css += "    --background-color: \(colors.backgroundColor);\n"
        css += "    --text-color: \(colors.textColor);\n"
        css += "    --secondary-text-color: \(colors.secondaryTextColor);\n"
        css += "    --link-color: \(colors.linkColor);\n"
        css += "    --code-background-color: \(colors.codeBackgroundColor);\n"
        css += "    --border-color: \(colors.borderColor);\n"
        css += "    --accent-color: \(colors.accentColor);\n"
        
        // 字体变量
        if let fonts = fonts {
            css += "    --body-font: \(fonts.bodyFont);\n"
            css += "    --heading-font: \(fonts.headingFont);\n"
            css += "    --code-font: \(fonts.codeFont);\n"
            css += "    --font-size: \(fonts.fontSize)px;\n"
            css += "    --line-height: \(fonts.lineHeight);\n"
        }
        
        css += "}\n"
        return css
    }
    
    private func getMermaidScript() -> String {
        // 从本地资源加载或使用 CDN
        return """
        <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
        """
    }
    
    private func getKaTeXScript() -> String {
        return """
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">
        <script src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
        """
    }
}

// MARK: - Supporting Types

struct PreprocessedMarkdown {
    let markdown: String
    let mermaidCharts: [String]
    let mathFormulas: [MathFormula]
}

enum MathFormula {
    case inline(String)
    case block(String)
}

struct RenderOptions {
    var themeId: String? = nil  // nil 表示使用当前主题
    var includeTOC: Bool = false
    var codeLineNumbers: Bool = false
    
    static let `default` = RenderOptions()
}
```

---

#### **4.4.2 CSS 降级方案**

```swift
enum CSSStyles {
    /// 降级方案：当无法加载主题 CSS 时使用
    static let fallback = """
    /* 基础样式 */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }
    
    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Hiragino Sans GB', sans-serif;
        font-size: 16px;
        line-height: 1.6;
        color: #333;
        background: #fff;
        padding: 2rem;
    }
    
    body.dark {
        color: #e0e0e0;
        background: #1e1e1e;
    }
    
    .container {
        max-width: 900px;
        margin: 0 auto;
    }
    
    /* 目录样式 */
    .toc {
        background: #f8f8f8;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        padding: 1.5rem;
        margin-bottom: 2rem;
    }
    
    body.dark .toc {
        background: #2d2d2d;
        border-color: #404040;
    }
    
    .toc h2 {
        font-size: 1.2rem;
        margin-bottom: 1rem;
    }
    
    .toc ul {
        list-style: none;
        padding-left: 1rem;
    }
    
    .toc li {
        margin: 0.5rem 0;
    }
    
    .toc a {
        color: #0066cc;
        text-decoration: none;
    }
    
    .toc a:hover {
        text-decoration: underline;
    }
    
    /* 文章内容 */
    .content {
        line-height: 1.8;
    }
    
    /* 标题 */
    h1, h2, h3, h4, h5, h6 {
        margin: 1.5rem 0 1rem 0;
        font-weight: 600;
        line-height: 1.3;
    }
    
    h1 { font-size: 2rem; border-bottom: 2px solid #e0e0e0; padding-bottom: 0.5rem; }
    h2 { font-size: 1.6rem; border-bottom: 1px solid #e0e0e0; padding-bottom: 0.3rem; }
    h3 { font-size: 1.3rem; }
    h4 { font-size: 1.1rem; }
    h5 { font-size: 1rem; }
    h6 { font-size: 0.9rem; color: #666; }
    
    /* 段落 */
    p {
        margin: 1rem 0;
    }
    
    /* 链接 */
    a {
        color: #0066cc;
        text-decoration: none;
    }
    
    a:hover {
        text-decoration: underline;
    }
    
    body.dark a {
        color: #4da6ff;
    }
    
    /* 列表 */
    ul, ol {
        margin: 1rem 0;
        padding-left: 2rem;
    }
    
    li {
        margin: 0.3rem 0;
    }
    
    /* 引用 */
    blockquote {
        border-left: 4px solid #0066cc;
        padding-left: 1rem;
        margin: 1rem 0;
        color: #666;
        font-style: italic;
    }
    
    body.dark blockquote {
        border-color: #4da6ff;
        color: #aaa;
    }
    
    /* 代码块 */
    code {
        background: #f5f5f5;
        border: 1px solid #e0e0e0;
        border-radius: 3px;
        padding: 0.2rem 0.4rem;
        font-family: 'SF Mono', Monaco, Menlo, 'Courier New', monospace;
        font-size: 0.9em;
    }
    
    body.dark code {
        background: #2d2d2d;
        border-color: #404040;
    }
    
    pre {
        background: #f8f8f8;
        border: 1px solid #e0e0e0;
        border-radius: 6px;
        padding: 1rem;
        margin: 1rem 0;
        overflow-x: auto;
        position: relative;
    }
    
    body.dark pre {
        background: #2d2d2d;
        border-color: #404040;
    }
    
    pre code {
        background: none;
        border: none;
        padding: 0;
        display: block;
    }
    
    /* 代码高亮（Splash 输出） */
    .code-block {
        position: relative;
    }
    
    .code-block::before {
        content: attr(data-language);
        position: absolute;
        top: 0.5rem;
        right: 0.5rem;
        background: rgba(0, 0, 0, 0.1);
        padding: 0.2rem 0.5rem;
        border-radius: 3px;
        font-size: 0.75rem;
        text-transform: uppercase;
        color: #666;
    }
    
    /* 表格 */
    table {
        border-collapse: collapse;
        width: 100%;
        margin: 1rem 0;
        overflow: hidden;
        border-radius: 6px;
    }
    
    th, td {
        border: 1px solid #e0e0e0;
        padding: 0.75rem 1rem;
        text-align: left;
    }
    
    th {
        background: #f5f5f5;
        font-weight: 600;
    }
    
    body.dark th, body.dark td {
        border-color: #404040;
    }
    
    body.dark th {
        background: #2d2d2d;
    }
    
    /* 图片 */
    img {
        max-width: 100%;
        height: auto;
        border-radius: 6px;
        margin: 1rem 0;
        display: block;
    }
    
    /* 分隔线 */
    hr {
        border: none;
        border-top: 2px solid #e0e0e0;
        margin: 2rem 0;
    }
    
    body.dark hr {
        border-color: #404040;
    }
    
    /* Mermaid 图表 */
    .mermaid {
        background: #fff;
        border: 1px solid #e0e0e0;
        border-radius: 6px;
        padding: 1rem;
        margin: 1rem 0;
        text-align: center;
    }
    
    body.dark .mermaid {
        background: #2d2d2d;
        border-color: #404040;
    }
    
    /* 数学公式 */
    .math-block {
        margin: 1rem 0;
        overflow-x: auto;
        text-align: center;
    }
    
    .math-inline {
        display: inline-block;
        vertical-align: middle;
    }
    
    /* 打印优化 */
    @media print {
        body {
            padding: 0;
            font-size: 12pt;
        }
        
        .container {
            max-width: none;
        }
        
        .toc {
            page-break-after: always;
        }
        
        h1, h2, h3, h4, h5, h6 {
            page-break-after: avoid;
        }
        
        pre, .mermaid {
            page-break-inside: avoid;
        }
        
        a {
            color: #000;
        }
        
        a[href^="http"]::after {
            content: " (" attr(href) ")";
            font-size: 0.8em;
            color: #666;
        }
    }
    """
}
```

---

#### **4.3.3 图片缓存实现**

```swift
import Foundation
import AppKit

/// 图片缓存管理器
actor ImageCache {
    static let shared = ImageCache()
    
    private var memoryCache: [URL: NSImage] = [:]
    private let diskCacheDir: URL
    private let maxMemoryCacheSize = 50 // 最多缓存 50 张图片
    
    private init() {
        let cacheDir = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("Nota4/ImageCache")
        
        try? FileManager.default.createDirectory(
            at: cacheDir,
            withIntermediateDirectories: true
        )
        
        self.diskCacheDir = cacheDir
    }
    
    /// 获取图片（先查内存，再查磁盘，最后下载）
    func image(for url: URL) async throws -> NSImage {
        // 1. 检查内存缓存
        if let cached = memoryCache[url] {
            print("📷 [IMAGE] Memory cache hit: \(url.lastPathComponent)")
            return cached
        }
        
        // 2. 检查磁盘缓存
        let diskPath = diskCacheDir.appendingPathComponent(url.lastPathComponent)
        if FileManager.default.fileExists(atPath: diskPath.path),
           let image = NSImage(contentsOf: diskPath) {
            print("📷 [IMAGE] Disk cache hit: \(url.lastPathComponent)")
            // 存入内存缓存
            await cacheInMemory(url: url, image: image)
            return image
        }
        
        // 3. 下载图片
        print("📷 [IMAGE] Downloading: \(url.absoluteString)")
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = NSImage(data: data) else {
            throw ImageCacheError.invalidImageData
        }
        
        // 4. 缓存到内存和磁盘
        await cacheInMemory(url: url, image: image)
        try? data.write(to: diskPath)
        
        return image
    }
    
    /// 存入内存缓存
    private func cacheInMemory(url: URL, image: NSImage) async {
        // 如果缓存已满，移除最旧的
        if memoryCache.count >= maxMemoryCacheSize {
            if let firstKey = memoryCache.keys.first {
                memoryCache.removeValue(forKey: firstKey)
            }
        }
        
        memoryCache[url] = image
    }
    
    /// 清空缓存
    func clearCache() async {
        memoryCache.removeAll()
        try? FileManager.default.removeItem(at: diskCacheDir)
        try? FileManager.default.createDirectory(
            at: diskCacheDir,
            withIntermediateDirectories: true
        )
        print("🧹 [IMAGE] Cache cleared")
    }
}

enum ImageCacheError: Error {
    case invalidImageData
}
```

---

### 4.4 依赖更新

需要在 `Package.swift` 中添加以下依赖：

```swift
dependencies: [
    // 现有依赖...
    .package(url: "https://github.com/JohnSundell/Ink.git", from: "0.6.0"),
    .package(url: "https://github.com/JohnSundell/Splash.git", from: "0.16.0")
],
targets: [
    .executableTarget(
        name: "Nota4",
        dependencies: [
            // 现有依赖...
            "Ink",
            "Splash"
        ]
    )
]
```

**注意**：Mermaid 和 KaTeX 通过 CDN 加载，无需 SPM 依赖。

---

## 5. 实施计划

### 5.1 三阶段实施

#### **Phase 1: 基础渲染 + 代码高亮**（1 天，6h）

**目标**：完成基础渲染架构和代码高亮

| 任务 | 工时 | 产出 |
|------|------|------|
| 集成 Ink 库 | 1h | Markdown → HTML 转换 |
| 集成 Splash 库 | 1h | 代码语法高亮 |
| 实现 MarkdownRenderer | 2h | 核心渲染服务 |
| CSS 样式设计 | 1.5h | 现代化样式表 |
| 集成到 MarkdownPreview | 0.5h | UI 层集成 |

**验收标准**：
- ✅ 基础 Markdown 正确渲染
- ✅ 代码块有语法高亮
- ✅ 样式美观，适配明暗主题

---

#### **Phase 2: 图表 + 公式**（1 天，7h）

**目标**：支持 Mermaid 和数学公式

| 任务 | 工时 | 产出 |
|------|------|------|
| Mermaid.js 集成 | 2h | 流程图、时序图等 |
| KaTeX 集成 | 2h | 行内和块公式 |
| 预处理逻辑 | 2h | 提取特殊块 |
| 测试验证 | 1h | 各种图表和公式 |

**验收标准**：
- ✅ Mermaid 图表正确渲染
- ✅ 数学公式正确渲染
- ✅ 支持复杂嵌套

---

#### **Phase 3: 主题系统**（1.5 天，12h）

**目标**：实现完整的主题系统架构 + TCA 集成

| 任务 | 工时 | 产出 |
|------|------|------|
| 主题配置模型 | 1h | ThemeConfig、ThemeColors、ThemeFonts |
| 主题管理器实现 | 2h | ThemeManager 单例 |
| 内置主题定义 | 1.5h | Light、Dark、GitHub、Notion |
| CSS 文件外置 | 2h | 创建独立 CSS 文件 |
| CSS 变量系统 | 1h | 定义可配置的 CSS 变量 |
| **TCA 状态管理** | **2h** | **ThemeState、ThemeAction、ThemeFeature** |
| **首选项 UI 实现** | **1.5h** | **主题设置卡片界面** |
| **预览自动更新** | **0.5h** | **监听主题变更通知** |
| 集成到渲染器 | 0.5h | MarkdownRenderer 集成主题 |

**验收标准**：
- ✅ 主题管理器正常工作
- ✅ 可以动态切换主题
- ✅ 4 个内置主题正确渲染
- ✅ CSS 变量系统生效
- ✅ 主题配置持久化
- ✅ **TCA 状态管理符合最佳实践**
- ✅ **首选项界面完整可用**
- ✅ **预览窗口自动响应主题变更**

---

#### **Phase 4: TOC + 图片增强**（半天，4h）

**目标**：完善导航和图片支持

| 任务 | 工时 | 产出 |
|------|------|------|
| TOC 生成 | 1.5h | 自动目录 |
| 外部图片链接支持 | 1h | HTTP/HTTPS 图片 |
| 图片缓存 | 1h | ImageCache 实现 |
| 错误处理优化 | 0.5h | 友好的错误提示 |

**验收标准**：
- ✅ TOC 正确生成，可点击跳转
- ✅ 外部图片正常显示
- ✅ 图片加载失败有提示
- ✅ 图片缓存生效

---

### 5.2 总工时估算

| 阶段 | 工时 | 说明 |
|------|------|------|
| Phase 1 | 6h | 基础渲染 + 代码高亮 |
| Phase 2 | 7h | 图表 + 公式 |
| Phase 3 | 12h | **主题系统 + TCA + UI** |
| Phase 4 | 4h | TOC + 图片增强 |
| 测试 + 优化 | 4h | 全面测试和性能优化 |
| **总计** | **33h** | **约 4 个工作日** |

**注**：
- 主题系统是新增的核心功能，提供了未来扩展的基础架构
- TCA 状态管理确保状态一致性和可测试性
- UI 交互遵循"配置集中化、预览简洁化"原则

---

## 6. 测试计划

### 6.1 功能测试

#### **6.1.1 基础 Markdown**
- [ ] 标题（H1-H6）
- [ ] 段落和换行
- [ ] 加粗、斜体、删除线
- [ ] 有序列表
- [ ] 无序列表
- [ ] 任务列表
- [ ] 引用块
- [ ] 链接
- [ ] 图片
- [ ] 表格
- [ ] 分隔线

#### **6.1.2 代码高亮**
- [ ] JavaScript 高亮
- [ ] Python 高亮
- [ ] Swift 高亮
- [ ] Java 高亮
- [ ] HTML/CSS 高亮
- [ ] SQL 高亮
- [ ] Bash/Shell 高亮
- [ ] 行号显示（可选）
- [ ] 语言标签显示

#### **6.1.3 Mermaid 图表**
- [ ] 流程图（Flowchart）
- [ ] 时序图（Sequence Diagram）
- [ ] 甘特图（Gantt Chart）
- [ ] 类图（Class Diagram）
- [ ] 状态图（State Diagram）
- [ ] 饼图（Pie Chart）
- [ ] 明暗主题适配

#### **6.1.4 数学公式**
- [ ] 行内公式 `$x^2$`
- [ ] 块公式 `$$\sum_{i=1}^{n}$$`
- [ ] 复杂公式（矩阵、积分等）
- [ ] 希腊字母
- [ ] 特殊符号

#### **6.1.5 图片支持**
- [ ] 本地图片（相对路径）
- [ ] 本地图片（绝对路径）
- [ ] HTTP 外链图片
- [ ] HTTPS 外链图片
- [ ] 图片加载中状态
- [ ] 图片加载失败提示
- [ ] 图片缓存生效

#### **6.1.6 TOC 目录**
- [ ] 自动提取标题
- [ ] 多级层级
- [ ] 点击跳转
- [ ] 滚动定位

#### **6.1.7 主题系统**
- [ ] 加载内置主题（Light、Dark、GitHub、Notion）
- [ ] 动态切换主题
- [ ] 主题配置持久化
- [ ] 导入自定义主题
- [ ] 导出用户主题
- [ ] 删除用户主题
- [ ] CSS 变量正确注入
- [ ] 主题切换后预览实时更新
- [ ] 主题与代码高亮配合
- [ ] 主题与 Mermaid 图表配合
- [ ] 无效主题降级处理

#### **6.1.8 TCA 状态管理**
- [ ] ThemeState 正确初始化
- [ ] 主题切换 Action 正确处理
- [ ] ThemeManager 依赖正确注入
- [ ] 异步加载主题正确处理
- [ ] 错误状态正确显示
- [ ] TaskResult 正确处理成功/失败
- [ ] 状态持久化到 UserDefaults
- [ ] 主题删除后自动切换到默认主题
- [ ] Reducer 测试覆盖所有 Action
- [ ] 防抖机制正确工作（预览渲染）

#### **6.1.9 UI 交互**
- [ ] 首选项主题卡片正确显示
- [ ] 当前主题显示选中状态
- [ ] 点击主题卡片正确切换
- [ ] 导入主题按钮打开文件选择器
- [ ] 导入成功显示提示
- [ ] 导入失败显示错误信息
- [ ] 导出按钮打开保存对话框
- [ ] 删除主题显示确认对话框
- [ ] 预览示例实时显示主题效果
- [ ] 预览界面不显示主题配置选项
- [ ] 预览界面自动响应主题变更

---

### 6.2 性能测试

| 场景 | 预期性能 | 测试方法 |
|------|---------|---------|
| 渲染 1000 行 Markdown | < 1s | 计时测试 |
| 渲染 10 个代码块 | < 0.5s | 计时测试 |
| 渲染 5 个 Mermaid 图表 | < 2s | 计时测试 |
| 渲染 20 个数学公式 | < 1s | 计时测试 |
| 加载 10 张外部图片 | < 3s | 网络测试 |
| 内存占用（正常使用） | < 200MB | 内存监控 |

---

### 6.3 兼容性测试

#### **Markdown 语法兼容**
- [ ] CommonMark 规范
- [ ] GitHub Flavored Markdown (GFM)
- [ ] 表格扩展语法
- [ ] 任务列表语法

#### **浏览器兼容**（WKWebView）
- [ ] macOS 13+
- [ ] 明暗主题切换
- [ ] 高 DPI 显示

---

### 6.4 边界测试

- [ ] 空文档
- [ ] 超长文档（>10000 行）
- [ ] 特殊字符（<, >, &, "）
- [ ] 嵌套结构（列表中的代码块）
- [ ] 无效的 Mermaid 语法
- [ ] 无效的数学公式
- [ ] 404 图片链接
- [ ] 超大图片（>10MB）

---

## 7. 性能优化

### 7.1 渲染优化

**策略**：
1. **增量渲染**：只重新渲染变化的部分
2. **防抖处理**：编辑时延迟 300ms 再渲染
3. **WebKit 缓存**：复用 WKWebView 实例

**实现**：
```swift
class PreviewCoordinator {
    private var renderTask: Task<Void, Never>?
    private let renderDelay: Duration = .milliseconds(300)
    
    func scheduleRender(markdown: String) {
        renderTask?.cancel()
        
        renderTask = Task {
            try? await Task.sleep(for: renderDelay)
            
            guard !Task.isCancelled else { return }
            
            await performRender(markdown)
        }
    }
}
```

---

### 7.2 图片加载优化

**策略**：
1. **懒加载**：使用 `loading="lazy"` 属性
2. **缓存机制**：内存 + 磁盘双层缓存
3. **并发控制**：限制同时下载数量

**实现**：
```swift
actor ImageDownloader {
    private let maxConcurrent = 3
    private var currentDownloads = 0
    
    func download(url: URL) async throws -> Data {
        // 等待可用槽位
        while currentDownloads >= maxConcurrent {
            try await Task.sleep(for: .milliseconds(100))
        }
        
        currentDownloads += 1
        defer { currentDownloads -= 1 }
        
        return try await URLSession.shared.data(from: url).0
    }
}
```

---

### 7.3 内存管理

**策略**：
1. **限制缓存大小**：内存缓存最多 50 张图片
2. **及时释放**：切换笔记时清理缓存
3. **监控内存**：超过阈值自动清理

---

## 8. 风险评估

### 8.1 技术风险

| 风险 | 可能性 | 影响 | 缓解措施 |
|------|-------|------|---------|
| Mermaid 渲染失败 | 中 | 中 | 添加错误处理，显示原始代码 |
| KaTeX 公式错误 | 中 | 低 | 容错模式，显示 LaTeX 源码 |
| 外部图片加载慢 | 高 | 中 | 添加缓存和 loading 提示 |
| WebKit 内存泄漏 | 低 | 高 | 定期释放 WKWebView |
| 大文档渲染慢 | 中 | 中 | 增量渲染 + 防抖 |

---

### 8.2 性能风险

| 风险 | 可能性 | 影响 | 缓解措施 |
|------|-------|------|---------|
| 实时预览卡顿 | 中 | 高 | 防抖 300ms + 增量渲染 |
| 图片加载阻塞 | 中 | 中 | 异步加载 + 懒加载 |
| 内存占用过高 | 低 | 中 | 限制缓存大小 |

---

### 8.3 用户体验风险

| 风险 | 可能性 | 影响 | 缓解措施 |
|------|-------|------|---------|
| 语法不兼容 | 中 | 中 | 支持 GFM，文档说明 |
| 图表渲染效果差 | 低 | 低 | 使用 Mermaid 官方库 |
| 样式不美观 | 低 | 中 | 参考 GitHub/Typora |

---

## 9. 成功标准

### 9.1 功能完整性
- ✅ 支持所有基础 Markdown 语法
- ✅ 代码块语法高亮（50+ 语言）
- ✅ Mermaid 图表渲染（6+ 类型）
- ✅ 数学公式渲染（行内 + 块）
- ✅ TOC 目录生成
- ✅ 外部图片链接支持

### 9.2 性能指标
- ✅ 1000 行文档渲染 < 1s
- ✅ 实时预览无明显卡顿
- ✅ 内存占用 < 200MB
- ✅ 图片缓存命中率 > 80%

### 9.3 用户体验
- ✅ 样式美观，媲美 Typora
- ✅ 明暗主题自适应
- ✅ 打印效果良好
- ✅ 错误提示友好

---

## 10. 后续优化（P2）

### 10.1 高级功能
- 📋 代码复制按钮
- 📋 图片点击放大
- 📋 导出 PDF 使用渲染效果
- 📋 Markdown 扩展语法（脚注、任务列表高亮）
- 📋 **在线主题市场/社区**
- 📋 **主题编辑器（可视化配置）**
- 📋 **主题预览功能**

### 10.2 性能优化
- 📋 虚拟滚动（超长文档）
- 📋 Worker 线程渲染
- 📋 离线 Mermaid/KaTeX 资源
- 📋 **主题 CSS 预编译和缓存**

---

## 11. 参考资料

- [Ink - Markdown Parser](https://github.com/JohnSundell/Ink)
- [Splash - Syntax Highlighter](https://github.com/JohnSundell/Splash)
- [Mermaid.js 官方文档](https://mermaid.js.org/)
- [KaTeX 官方文档](https://katex.org/)
- [CommonMark 规范](https://commonmark.org/)
- [GitHub Flavored Markdown (GFM)](https://github.github.com/gfm/)

---

**文档变更记录**：
- 2025-11-16 v1.2: 增加 UI 交互设计和 TCA 状态管理规范
  - 新增 1.4 UI 交互原则章节
  - 新增 4.4 UI 交互设计章节（首选项配置 + 预览简洁化）
  - 新增 4.5 TCA 状态管理章节（完整的 State/Action/Reducer 设计）
  - 明确配置集中化原则：所有主题配置在首选项管理
  - 明确预览简洁化原则：预览界面不提供主题配置
  - 增加 TCA 最佳实践总结和依赖注入规范
  - 增加主题系统 UI 交互测试项
  - 增加 TCA 状态管理测试项
  - 总工时从 29h 增加到 33h（约 4 个工作日）
- 2025-11-16 v1.1: 增加主题系统和样式模板扩展性设计
  - 新增 4.3 主题系统设计章节
  - 新增 ThemeManager、ThemeConfig 等核心组件
  - 将主题系统提升为 P0 优先级
  - 更新 MarkdownRenderer 以支持动态主题
  - 增加主题导入/导出功能规划
  - 更新测试计划和实施计划
  - 总工时从 20h 增加到 29h
- 2025-11-16 v1.0: 初始版本，完整规划预览渲染增强功能


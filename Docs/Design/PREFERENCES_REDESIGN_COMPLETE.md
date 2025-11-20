# 首选项配置完整重新设计方案

**设计时间**: 2025-11-20

## 一、设计目标

### 1.1 核心需求
1. **区分编辑模式和预览模式的设置**
   - 字体设置：编辑模式 vs 预览模式
   - 排版布局：编辑模式 vs 预览模式
2. **统一管理主题和代码高亮**
   - 预览主题（4种内置风格）
   - 代码高亮样式（独立或跟随主题）
3. **清晰的分类结构**
   - 编辑器设置（编辑模式）
   - 外观设置（预览模式）
4. **符合TCA架构**
   - 状态管理清晰
   - Action分类明确
   - 副作用处理规范

### 1.2 交叉影响分析

```
┌─────────────────────────────────────────────────────────┐
│                    首选项配置系统                          │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─ 编辑器设置 ───────────────────────────────────┐   │
│  │                                                   │   │
│  │  • 编辑模式字体（正文字体、标题字体、代码字体）    │   │
│  │  • 编辑模式排版布局（行间距、段落间距、边距、对齐）│   │
│  │                                                   │   │
│  │  影响范围：编辑器区域                              │   │
│  └───────────────────────────────────────────────────┘   │
│                                                           │
│  ┌─ 外观设置 ───────────────────────────────────┐   │
│  │                                                   │   │
│  │  • 预览模式字体（正文字体、标题字体、代码字体）    │   │
│  │  • 预览模式排版布局（行间距、段落间距、边距、对齐）│   │
│  │  • 预览主题（Light、Dark、GitHub、Notion）        │   │
│  │  • 代码高亮样式（Xcode、GitHub、Monokai等）       │   │
│  │                                                   │   │
│  │  影响范围：预览区域                                │   │
│  └───────────────────────────────────────────────────┘   │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 二、数据模型设计

### 2.1 核心数据结构

```swift
// EditorPreferences.swift

/// 编辑器偏好设置
struct EditorPreferences: Codable, Equatable {
    // MARK: - 编辑模式设置
    
    /// 编辑模式字体设置
    var editorFonts: FontSettings = FontSettings()
    
    /// 编辑模式排版布局设置
    var editorLayout: LayoutSettings = LayoutSettings(
        lineSpacing: 4,
        paragraphSpacing: 0.5,
        horizontalPadding: 16,
        verticalPadding: 12,
        alignment: .leading,
        maxWidth: nil  // 编辑模式不使用最大行宽
    )
    
    // MARK: - 预览模式设置
    
    /// 预览模式字体设置
    var previewFonts: FontSettings = FontSettings()
    
    /// 预览模式排版布局设置
    var previewLayout: LayoutSettings = LayoutSettings(
        lineSpacing: 6,
        paragraphSpacing: 0.8,
        horizontalPadding: 24,
        verticalPadding: 20,
        alignment: .leading,
        maxWidth: 800  // 预览模式使用最大行宽
    )
    
    // MARK: - 外观设置（预览相关）
    
    /// 预览主题ID（内置主题：builtin-light, builtin-dark, builtin-github, builtin-notion）
    var previewThemeId: String = "builtin-light"
    
    /// 代码高亮主题
    var codeHighlightTheme: CodeTheme = .xcode
    
    /// 代码高亮设置模式
    var codeHighlightMode: CodeHighlightMode = .followTheme
    
    // MARK: - Nested Types
    
    /// 字体设置
    struct FontSettings: Codable, Equatable {
        var bodyFontName: String = "System"
        var bodyFontSize: CGFloat = 17
        var titleFontName: String = "System"
        var titleFontSize: CGFloat = 24
        var codeFontName: String = "Menlo"
        var codeFontSize: CGFloat = 14
    }
    
    /// 排版布局设置
    struct LayoutSettings: Codable, Equatable {
        var lineSpacing: CGFloat
        var paragraphSpacing: CGFloat
        var horizontalPadding: CGFloat
        var verticalPadding: CGFloat
        var alignment: Alignment
        var maxWidth: CGFloat?  // 可选，仅预览模式使用
        
        enum Alignment: String, Codable, CaseIterable {
            case leading = "左对齐"
            case center = "居中"
        }
    }
    
    /// 代码高亮设置模式
    enum CodeHighlightMode: String, Codable, Equatable {
        case followTheme = "跟随主题"      // 使用主题的代码高亮设置
        case custom = "自定义"            // 使用自定义代码高亮主题
    }
}
```

### 2.2 主题配置结构（保持不变）

```swift
// ThemeConfig.swift（现有结构，保持不变）

struct ThemeConfig: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let displayName: String
    let codeHighlightTheme: CodeTheme  // 主题默认的代码高亮主题
    // ... 其他属性
}
```

---

## 三、TCA 状态管理设计

### 3.1 SettingsFeature.State

```swift
// SettingsFeature.swift

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        // 当前选中的分类
        var selectedCategory: SettingsCategory = .editor
        
        // 编辑器偏好设置
        var editorPreferences: EditorPreferences
        var originalEditorPreferences: EditorPreferences  // 用于取消操作
        
        // 主题状态
        var theme: ThemeState = ThemeState()
        
        init(editorPreferences: EditorPreferences) {
            self.editorPreferences = editorPreferences
            self.originalEditorPreferences = editorPreferences
            
            // 从 UserDefaults 加载保存的设置
            loadSavedSettings()
        }
        
        private mutating func loadSavedSettings() {
            // 加载预览主题ID
            if let themeId = UserDefaults.standard.string(forKey: "previewThemeId") {
                self.editorPreferences.previewThemeId = themeId
            }
            
            // 加载代码高亮设置
            if let codeThemeRaw = UserDefaults.standard.string(forKey: "codeHighlightTheme"),
               let codeTheme = CodeTheme(rawValue: codeThemeRaw) {
                self.editorPreferences.codeHighlightTheme = codeTheme
            }
            
            if let modeRaw = UserDefaults.standard.string(forKey: "codeHighlightMode"),
               let mode = EditorPreferences.CodeHighlightMode(rawValue: modeRaw) {
                self.editorPreferences.codeHighlightMode = mode
            }
        }
    }
    
    // MARK: - Theme State
    
    struct ThemeState: Equatable {
        var currentThemeId: String = "builtin-light"
        var availableThemes: IdentifiedArrayOf<ThemeConfig> = []
        var isLoadingThemes: Bool = false
        var importExportState: ImportExportState = .idle
        var errorMessage: String?
        
        var currentTheme: ThemeConfig? {
            availableThemes[id: currentThemeId]
        }
        
        var builtInThemes: [ThemeConfig] {
            availableThemes.filter { $0.id.hasPrefix("builtin-") }
        }
    }
}
```

### 3.2 SettingsFeature.Action

```swift
// SettingsFeature.swift

enum Action: BindableAction {
    case binding(BindingAction<State>)
    
    // MARK: - Category Selection
    case categorySelected(SettingsCategory)
    
    // MARK: - Editor Preferences Actions
    
    // 编辑模式字体
    case editorFontChanged(FontType, String)  // FontType: body, title, code
    case editorFontSizeChanged(FontType, CGFloat)
    
    // 编辑模式布局
    case editorLayoutChanged(EditorPreferences.LayoutSettings)
    
    // 预览模式字体
    case previewFontChanged(FontType, String)
    case previewFontSizeChanged(FontType, CGFloat)
    
    // 预览模式布局
    case previewLayoutChanged(EditorPreferences.LayoutSettings)
    
    // MARK: - Appearance Actions
    
    // 预览主题
    case theme(ThemeAction)
    
    // 代码高亮
    case codeHighlightModeChanged(EditorPreferences.CodeHighlightMode)
    case codeHighlightThemeChanged(CodeTheme)
    
    // MARK: - Config Management
    case resetToDefaults
    case exportConfig
    case importConfig
    case apply
    case cancel
    case dismiss
}

enum FontType {
    case body
    case title
    case code
}

enum ThemeAction {
    case onAppear
    case loadThemes
    case themesLoaded(TaskResult<[ThemeConfig]>)
    case selectTheme(String)
    case themeSelected(TaskResult<ThemeConfig>)
    case importTheme(URL)
    case exportTheme(String)
    // ... 其他主题相关Action
}
```

### 3.3 Reducer 实现要点

```swift
// SettingsFeature.swift

var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
        switch action {
        // MARK: - Editor Font Actions
        case .editorFontChanged(let type, let fontName):
            switch type {
            case .body:
                state.editorPreferences.editorFonts.bodyFontName = fontName
            case .title:
                state.editorPreferences.editorFonts.titleFontName = fontName
            case .code:
                state.editorPreferences.editorFonts.codeFontName = fontName
            }
            return .none
            
        case .editorFontSizeChanged(let type, let size):
            switch type {
            case .body:
                state.editorPreferences.editorFonts.bodyFontSize = size
            case .title:
                state.editorPreferences.editorFonts.titleFontSize = size
            case .code:
                state.editorPreferences.editorFonts.codeFontSize = size
            }
            return .none
            
        // MARK: - Preview Font Actions
        case .previewFontChanged(let type, let fontName):
            switch type {
            case .body:
                state.editorPreferences.previewFonts.bodyFontName = fontName
            case .title:
                state.editorPreferences.previewFonts.titleFontName = fontName
            case .code:
                state.editorPreferences.previewFonts.codeFontName = fontName
            }
            return .none
            
        case .previewFontSizeChanged(let type, let size):
            switch type {
            case .body:
                state.editorPreferences.previewFonts.bodyFontSize = size
            case .title:
                state.editorPreferences.previewFonts.titleFontSize = size
            case .code:
                state.editorPreferences.previewFonts.codeFontSize = size
            }
            return .none
            
        // MARK: - Code Highlight Actions
        case .codeHighlightModeChanged(let mode):
            state.editorPreferences.codeHighlightMode = mode
            
            // 如果切换到"跟随主题"，更新代码高亮主题为当前主题的默认值
            if mode == .followTheme,
               let currentTheme = state.theme.currentTheme {
                state.editorPreferences.codeHighlightTheme = currentTheme.codeHighlightTheme
            }
            return .none
            
        case .codeHighlightThemeChanged(let theme):
            state.editorPreferences.codeHighlightTheme = theme
            // 切换到自定义模式
            state.editorPreferences.codeHighlightMode = .custom
            return .none
            
        // MARK: - Theme Actions
        case .theme(.selectTheme(let themeId)):
            state.editorPreferences.previewThemeId = themeId
            state.theme.currentThemeId = themeId
            
            // 如果代码高亮模式是"跟随主题"，更新代码高亮主题
            if state.editorPreferences.codeHighlightMode == .followTheme,
               let theme = state.theme.currentTheme {
                state.editorPreferences.codeHighlightTheme = theme.codeHighlightTheme
            }
            return .send(.theme(.selectTheme(themeId)))
            
        // MARK: - Apply
        case .apply:
            // 保存到 UserDefaults
            return .run { [prefs = state.editorPreferences] send in
                try await PreferencesStorage.shared.save(prefs)
                
                // 保存外观相关设置
                UserDefaults.standard.set(prefs.previewThemeId, forKey: "previewThemeId")
                UserDefaults.standard.set(prefs.codeHighlightTheme.rawValue, forKey: "codeHighlightTheme")
                UserDefaults.standard.set(prefs.codeHighlightMode.rawValue, forKey: "codeHighlightMode")
                
                // 通知 AppFeature 应用设置
                await send(.dismiss)
            }
            
        // ... 其他Action处理
        }
    }
}
```

---

## 四、UI 设计

### 4.1 分类结构

```
首选项窗口
├── 左侧分类列表
│   ├── 📝 编辑器（编辑模式设置）
│   └── 🎨 外观（预览模式设置）
│
└── 右侧设置面板
    ├── 编辑器设置面板
    │   ├── 编辑模式字体
    │   ├── 编辑模式排版布局
    │   └── 配置管理
    │
    └── 外观设置面板
        ├── 预览模式字体
        ├── 预览模式排版布局
        ├── 预览主题
        ├── 代码高亮样式
        └── 主题管理
```

### 4.2 编辑器设置面板 UI

```swift
// SettingsView.swift

private struct EditorSettingsPanel: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 标题
                SettingsHeader(
                    title: "编辑器",
                    description: "自定义编辑器的字体和排版布局"
                )
                
                Divider()
                
                // 编辑模式字体设置
                SettingSection(
                    title: "编辑模式字体",
                    icon: "textformat",
                    description: "影响编辑器区域的字体显示"
                ) {
                    FontSettingsView(
                        fonts: $store.editorPreferences.editorFonts,
                        onFontChanged: { type, name in
                            store.send(.editorFontChanged(type, name))
                        },
                        onFontSizeChanged: { type, size in
                            store.send(.editorFontSizeChanged(type, size))
                        }
                    )
                }
                
                Divider()
                
                // 编辑模式排版布局
                SettingSection(
                    title: "编辑模式排版布局",
                    icon: "text.alignleft",
                    description: "影响编辑器区域的排版和布局"
                ) {
                    LayoutSettingsView(
                        layout: $store.editorPreferences.editorLayout,
                        showMaxWidth: false,  // 编辑模式不显示最大行宽
                        onLayoutChanged: { layout in
                            store.send(.editorLayoutChanged(layout))
                        }
                    )
                }
                
                Divider()
                
                // 配置管理
                SettingSection(
                    title: "配置管理",
                    icon: "gearshape"
                ) {
                    ConfigManagementView(store: store)
                }
                
                Spacer(minLength: 24)
            }
        }
    }
}
```

### 4.3 外观设置面板 UI

```swift
// AppearanceSettingsPanel.swift

struct AppearanceSettingsPanel: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 标题
                SettingsHeader(
                    title: "外观",
                    description: "自定义预览区域的字体、排版、主题和代码高亮"
                )
                
                Divider()
                
                // 预览模式字体设置
                SettingSection(
                    title: "预览模式字体",
                    icon: "textformat",
                    description: "影响预览区域的字体显示"
                ) {
                    FontSettingsView(
                        fonts: $store.editorPreferences.previewFonts,
                        onFontChanged: { type, name in
                            store.send(.previewFontChanged(type, name))
                        },
                        onFontSizeChanged: { type, size in
                            store.send(.previewFontSizeChanged(type, size))
                        }
                    )
                }
                
                Divider()
                
                // 预览模式排版布局
                SettingSection(
                    title: "预览模式排版布局",
                    icon: "text.alignleft",
                    description: "影响预览区域的排版和布局"
                ) {
                    LayoutSettingsView(
                        layout: $store.editorPreferences.previewLayout,
                        showMaxWidth: true,  // 预览模式显示最大行宽
                        onLayoutChanged: { layout in
                            store.send(.previewLayoutChanged(layout))
                        }
                    )
                }
                
                Divider()
                
                // 预览主题
                SettingSection(
                    title: "预览主题",
                    icon: "paintpalette",
                    description: "选择预览区域的整体风格"
                ) {
                    ThemeSelectionView(store: store)
                }
                
                Divider()
                
                // 代码高亮样式
                SettingSection(
                    title: "代码高亮样式",
                    icon: "curlybraces",
                    description: "选择代码块的语法高亮配色方案"
                ) {
                    CodeHighlightSettingsView(store: store)
                }
                
                Spacer(minLength: 24)
            }
        }
    }
}
```

### 4.4 代码高亮设置组件

```swift
// AppearanceSettingsPanel.swift

private struct CodeHighlightSettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 设置模式选择
            Picker("代码高亮模式", selection: Binding(
                get: { store.editorPreferences.codeHighlightMode },
                set: { store.send(.codeHighlightModeChanged($0)) }
            )) {
                Text("跟随主题").tag(EditorPreferences.CodeHighlightMode.followTheme)
                Text("自定义").tag(EditorPreferences.CodeHighlightMode.custom)
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            
            // 如果选择"跟随主题"，显示当前主题的代码高亮主题
            if store.editorPreferences.codeHighlightMode == .followTheme {
                HStack {
                    Text("当前主题代码高亮：")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(store.theme.currentTheme?.codeHighlightTheme.displayName ?? "未知")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.top, 4)
            } else {
                // 如果选择"自定义"，显示代码高亮主题选择器
                VStack(alignment: .leading, spacing: 12) {
                    Text("选择代码高亮主题")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 80), spacing: 8),
                        GridItem(.flexible(minimum: 80), spacing: 8),
                        GridItem(.flexible(minimum: 80), spacing: 8)
                    ], spacing: 8) {
                        ForEach(CodeTheme.allCases, id: \.self) { theme in
                            Button {
                                store.send(.codeHighlightThemeChanged(theme))
                            } label: {
                                Text(theme.displayName)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        store.editorPreferences.codeHighlightTheme == theme
                                            ? Color.accentColor
                                            : Color.secondary.opacity(0.1)
                                    )
                                    .foregroundColor(
                                        store.editorPreferences.codeHighlightTheme == theme
                                            ? .white
                                            : .primary
                                    )
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}
```

---

## 五、应用逻辑修改

### 5.1 EditorFeature.applyPreferences

```swift
// EditorFeature.swift

case .applyPreferences(let prefs):
    // 应用编辑器样式（使用编辑模式设置）
    state.editorStyle = EditorStyle(
        fontSize: prefs.editorFonts.bodyFontSize,
        lineSpacing: prefs.editorLayout.lineSpacing,
        horizontalPadding: prefs.editorLayout.horizontalPadding,
        verticalPadding: prefs.editorLayout.verticalPadding,
        maxWidth: 0,  // 编辑模式不使用最大行宽
        paragraphSpacing: prefs.editorLayout.paragraphSpacing,
        alignment: prefs.editorLayout.alignment == .center ? .center : .leading,
        fontName: prefs.editorFonts.bodyFontName != "System" ? prefs.editorFonts.bodyFontName : nil,
        titleFontName: prefs.editorFonts.titleFontName != "System" ? prefs.editorFonts.titleFontName : nil,
        titleFontSize: prefs.editorFonts.titleFontSize
    )
    
    // 应用预览渲染选项（使用预览模式设置）
    state.preview.renderOptions.horizontalPadding = prefs.previewLayout.horizontalPadding
    state.preview.renderOptions.verticalPadding = prefs.previewLayout.verticalPadding
    state.preview.renderOptions.alignment = prefs.previewLayout.alignment == .center ? "center" : "left"
    state.preview.renderOptions.maxWidth = prefs.previewLayout.maxWidth ?? 800
    state.preview.renderOptions.lineSpacing = prefs.previewLayout.lineSpacing
    state.preview.renderOptions.paragraphSpacing = prefs.previewLayout.paragraphSpacing
    
    // 应用预览主题
    state.preview.renderOptions.themeId = prefs.previewThemeId
    
    // 如果当前在预览模式，重新渲染以应用新设置
    if state.viewMode != .editOnly {
        return .send(.preview(.render))
    }
    return .none
```

### 5.2 MarkdownRenderer 代码高亮逻辑

```swift
// MarkdownRenderer.swift

private func getCodeHighlightCSS(for themeId: String?) async -> String {
    let codeTheme: CodeTheme
    
    // 1. 检查代码高亮模式
    let modeRaw = UserDefaults.standard.string(forKey: "codeHighlightMode") ?? "followTheme"
    let mode = EditorPreferences.CodeHighlightMode(rawValue: modeRaw) ?? .followTheme
    
    if mode == .custom {
        // 使用自定义代码高亮主题
        if let customThemeRaw = UserDefaults.standard.string(forKey: "codeHighlightTheme"),
           let customTheme = CodeTheme(rawValue: customThemeRaw) {
            codeTheme = customTheme
        } else {
            codeTheme = .xcode  // 默认值
        }
    } else {
        // 跟随主题：使用主题的代码高亮主题
        let theme: ThemeConfig
        if let themeId = themeId {
            let availableThemes = await themeManager.availableThemes
            if let selectedTheme = availableThemes.first(where: { $0.id == themeId }) {
                theme = selectedTheme
            } else {
                theme = await themeManager.currentTheme
            }
        } else {
            theme = await themeManager.currentTheme
        }
        codeTheme = theme.codeHighlightTheme
    }
    
    // 2. 根据 codeTheme 生成 CSS
    return generateCodeHighlightCSS(for: codeTheme)
}
```

---

## 六、数据迁移策略

### 6.1 从旧版本迁移

```swift
// EditorPreferences.swift

extension EditorPreferences {
    /// 从旧版本迁移（兼容旧数据）
    init(from old: OldEditorPreferences) {
        // 将旧的统一字体设置复制到编辑和预览模式
        self.editorFonts = FontSettings(
            bodyFontName: old.bodyFontName,
            bodyFontSize: old.bodyFontSize,
            titleFontName: old.titleFontName,
            titleFontSize: old.titleFontSize,
            codeFontName: old.codeFontName,
            codeFontSize: old.codeFontSize
        )
        
        self.previewFonts = FontSettings(
            bodyFontName: old.bodyFontName,
            bodyFontSize: old.bodyFontSize,
            titleFontName: old.titleFontName,
            titleFontSize: old.titleFontSize,
            codeFontName: old.codeFontName,
            codeFontSize: old.codeFontSize
        )
        
        // 将旧的统一布局设置分别应用到编辑和预览模式
        // 编辑模式使用更紧凑的默认值
        self.editorLayout = LayoutSettings(
            lineSpacing: old.lineSpacing - 2,
            paragraphSpacing: old.paragraphSpacing * 0.6,
            horizontalPadding: old.horizontalPadding - 8,
            verticalPadding: old.verticalPadding - 8,
            alignment: old.alignment,
            maxWidth: nil
        )
        
        // 预览模式保持原值
        self.previewLayout = LayoutSettings(
            lineSpacing: old.lineSpacing,
            paragraphSpacing: old.paragraphSpacing,
            horizontalPadding: old.horizontalPadding,
            verticalPadding: old.verticalPadding,
            alignment: old.alignment,
            maxWidth: old.maxWidth
        )
        
        // 外观设置
        self.previewThemeId = UserDefaults.standard.string(forKey: "previewThemeId") ?? "builtin-light"
        
        // 代码高亮设置
        if let codeThemeRaw = UserDefaults.standard.string(forKey: "customCodeHighlightTheme"),
           let codeTheme = CodeTheme(rawValue: codeThemeRaw) {
            self.codeHighlightTheme = codeTheme
            self.codeHighlightMode = .custom
        } else {
            self.codeHighlightTheme = .xcode
            self.codeHighlightMode = .followTheme
        }
    }
}
```

---

## 七、实施步骤

### 阶段1：数据模型重构
- [ ] 修改 `EditorPreferences` 结构
- [ ] 添加 `FontSettings` 和 `LayoutSettings` 嵌套结构
- [ ] 添加 `CodeHighlightMode` 枚举
- [ ] 实现数据迁移逻辑

### 阶段2：TCA 状态管理
- [ ] 修改 `SettingsFeature.State`
- [ ] 添加新的 Action
- [ ] 实现 Reducer 逻辑
- [ ] 处理代码高亮模式切换

### 阶段3：UI 重构
- [ ] 重构 `EditorSettingsPanel`
- [ ] 重构 `AppearanceSettingsPanel`
- [ ] 创建 `FontSettingsView` 组件
- [ ] 创建 `LayoutSettingsView` 组件
- [ ] 创建 `CodeHighlightSettingsView` 组件
- [ ] 创建 `SettingSection` 通用组件

### 阶段4：应用逻辑修改
- [ ] 修改 `EditorFeature.applyPreferences`
- [ ] 修改 `EditorStyle` 初始化
- [ ] 修改 `MarkdownRenderer` 代码高亮逻辑
- [ ] 更新预览渲染选项应用逻辑

### 阶段5：测试和优化
- [ ] 测试编辑模式设置应用
- [ ] 测试预览模式设置应用
- [ ] 测试代码高亮模式切换
- [ ] 测试主题切换和代码高亮联动
- [ ] 测试数据迁移
- [ ] UI/UX 优化

---

## 八、优势总结

### 8.1 分类清晰
- **编辑器设置**：专注于编辑模式体验
- **外观设置**：专注于预览模式体验
- 每个分类职责明确，用户易于理解

### 8.2 易于管理
- 编辑和预览设置完全独立
- 代码高亮可以跟随主题或自定义
- 所有设置统一在 `EditorPreferences` 中管理

### 8.3 符合TCA架构
- 状态结构清晰
- Action 分类明确
- Reducer 逻辑规范
- 副作用处理正确

### 8.4 灵活性强
- 编辑和预览可以有不同的字体和布局
- 代码高亮可以独立设置或跟随主题
- 支持未来扩展

---

## 九、UI 视觉设计

### 9.1 设置面板布局

```
┌─────────────────────────────────────────────────────┐
│  首选项                                    [取消] [应用] │
├──────────┬──────────────────────────────────────────┤
│          │                                          │
│ 📝 编辑器 │  ┌─ 编辑模式字体 ───────────────────┐   │
│          │  │                                  │   │
│ 🎨 外观  │  │  正文字体  [System ▼]  [17 pt]  │   │
│          │  │  标题字体  [System ▼]  [24 pt]  │   │
│          │  │  代码字体  [Menlo  ▼]  [14 pt]  │   │
│          │  └──────────────────────────────────┘   │
│          │                                          │
│          │  ┌─ 编辑模式排版布局 ───────────────┐   │
│          │  │                                  │   │
│          │  │  行间距      [====●====]  4 pt   │   │
│          │  │  段落间距    [====●====]  0.5    │   │
│          │  │  左右边距    [====●====]  16     │   │
│          │  │  上下边距    [====●====]  12     │   │
│          │  │  对齐方式    [左对齐│居中]      │   │
│          │  └──────────────────────────────────┘   │
│          │                                          │
└──────────┴──────────────────────────────────────────┘
```

### 9.2 代码高亮设置UI

```
┌─ 代码高亮样式 ───────────────────────────────────┐
│                                                    │
│  代码高亮模式  [跟随主题│自定义]                  │
│                                                    │
│  ┌─ 跟随主题模式 ───────────────────────────┐   │
│  │  当前主题代码高亮：Xcode                  │   │
│  │  （代码高亮将自动跟随预览主题）            │   │
│  └──────────────────────────────────────────┘   │
│                                                    │
│  或                                                │
│                                                    │
│  ┌─ 自定义模式 ─────────────────────────────┐   │
│  │  选择代码高亮主题：                        │   │
│  │  [Xcode] [GitHub] [Monokai] [Dracula]    │   │
│  │  [Solarized Light] [Solarized Dark]     │   │
│  └──────────────────────────────────────────┘   │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## 十、总结

本设计方案实现了：

1. ✅ **清晰的分类**：编辑器设置 vs 外观设置
2. ✅ **完整的分离**：编辑模式 vs 预览模式
3. ✅ **统一的管理**：所有设置在 `EditorPreferences` 中
4. ✅ **灵活的配置**：代码高亮可以跟随主题或自定义
5. ✅ **TCA 合规**：状态管理清晰，Action 分类明确
6. ✅ **向后兼容**：支持从旧版本迁移

该设计为 Nota4 提供了一个清晰、灵活、易于维护的首选项配置系统。


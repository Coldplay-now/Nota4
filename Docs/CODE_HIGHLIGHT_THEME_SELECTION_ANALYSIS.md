# 代码高亮主题选择功能分析

## 当前实现

### 现状

1. **代码高亮主题绑定在预览主题中**：
   - 每个 `ThemeConfig` 都有一个 `codeHighlightTheme: CodeTheme` 属性
   - 用户选择预览主题时，代码高亮主题会跟随主题的 `codeHighlightTheme` 设置
   - 例如：浅色主题使用 `.xcode`，深色主题使用 `.dracula`

2. **可用的代码高亮主题**：
   ```swift
   enum CodeTheme: String, Codable, Equatable {
       case xcode = "xcode"              // Xcode 风格（浅色/深色）
       case github = "github"            // GitHub 风格（浅色/深色）
       case monokai = "monokai"          // Monokai 风格（浅色/深色）
       case dracula = "dracula"          // Dracula 风格（浅色/深色）
       case solarizedLight = "solarized-light"  // Solarized Light
       case solarizedDark = "solarized-dark"    // Solarized Dark
   }
   ```

3. **用户需求**：
   - 用户希望可以独立选择代码高亮配色方案
   - 不受预览主题的限制
   - 例如：使用浅色预览主题，但代码高亮使用 Dracula 风格

## 方案设计

### 方案A：在"外观"设置面板中添加独立选择器（推荐）

**实现位置**：`AppearanceSettingsPanel.swift`

**优点**：
- ✅ 代码高亮是预览渲染的一部分，属于"外观"设置
- ✅ 与预览主题选择在同一个面板，用户体验更连贯
- ✅ 不需要修改 `EditorPreferences`（编辑器设置主要关注编辑体验）
- ✅ 符合 macOS 系统设置的分类逻辑

**实现方式**：
1. 在 `AppearanceSettingsPanel` 中添加"代码高亮主题"区域
2. 使用 `Picker` 或 `SegmentedControl` 显示所有可用的代码高亮主题
3. 在 `SettingsFeature.State` 中添加 `codeHighlightTheme: CodeTheme` 状态
4. 在 `SettingsFeature` 中添加 `codeHighlightThemeChanged(CodeTheme)` Action
5. 将选择的代码高亮主题保存到 `UserDefaults`
6. 在 `MarkdownRenderer` 中优先使用用户选择的代码高亮主题，如果没有则使用主题的 `codeHighlightTheme`

**UI 设计**：
```
外观设置面板
├── 预览主题
│   ├── 内置主题（卡片网格）
│   └── 自定义主题（列表）
│
└── 代码高亮主题（新增）
    └── Picker: [Xcode] [GitHub] [Monokai] [Dracula] [Solarized Light] [Solarized Dark]
```

### 方案B：在"编辑器"设置面板中添加

**实现位置**：`EditorSettingsPanel.swift`

**优点**：
- ✅ 代码高亮可以视为编辑器/预览的通用设置

**缺点**：
- ❌ 代码高亮主要影响预览渲染，不是编辑体验
- ❌ 与预览主题分离，用户可能找不到设置位置
- ❌ 需要修改 `EditorPreferences`，增加复杂度

### 方案C：代码高亮主题与预览主题保持绑定

**优点**：
- ✅ 实现简单，无需修改
- ✅ 主题体验一致

**缺点**：
- ❌ 灵活性不足，用户无法独立选择
- ❌ 不符合用户需求

## 推荐方案：方案A

### 实施步骤

#### 1. 扩展 `SettingsFeature.State`

```swift
@ObservableState
struct State: Equatable {
    var selectedCategory: SettingsCategory = .editor
    var editorPreferences: EditorPreferences
    var originalEditorPreferences: EditorPreferences
    var theme: ThemeState = ThemeState()
    var codeHighlightTheme: CodeTheme = .xcode  // 新增：用户选择的代码高亮主题
    var useCustomCodeHighlightTheme: Bool = false  // 新增：是否使用自定义代码高亮主题
    // ...
}
```

#### 2. 添加 Action

```swift
enum Action: BindableAction {
    // ... existing actions ...
    case codeHighlightThemeChanged(CodeTheme)  // 新增
    case useCustomCodeHighlightThemeToggled(Bool)  // 新增
}
```

#### 3. 在 Reducer 中处理

```swift
case .codeHighlightThemeChanged(let theme):
    state.codeHighlightTheme = theme
    // 保存到 UserDefaults
    UserDefaults.standard.set(theme.rawValue, forKey: "customCodeHighlightTheme")
    return .none

case .useCustomCodeHighlightThemeToggled(let enabled):
    state.useCustomCodeHighlightTheme = enabled
    UserDefaults.standard.set(enabled, forKey: "useCustomCodeHighlightTheme")
    return .none
```

#### 4. 在 `AppearanceSettingsPanel` 中添加 UI

```swift
// 代码高亮主题选择区域
VStack(alignment: .leading, spacing: 12) {
    HStack {
        Text("代码高亮主题")
            .font(.subheadline)
            .foregroundColor(.secondary)
        
        Spacer()
        
        Toggle("独立设置", isOn: Binding(
            get: { store.useCustomCodeHighlightTheme },
            set: { store.send(.useCustomCodeHighlightThemeToggled($0)) }
        ))
    }
    
    if store.useCustomCodeHighlightTheme {
        Picker("", selection: Binding(
            get: { store.codeHighlightTheme },
            set: { store.send(.codeHighlightThemeChanged($0)) }
        )) {
            ForEach(CodeTheme.allCases, id: \.self) { theme in
                Text(theme.displayName).tag(theme)
            }
        }
        .pickerStyle(.segmented)
    } else {
        Text("使用预览主题的代码高亮设置")
            .font(.caption)
            .foregroundColor(.secondary)
            .italic()
    }
}
```

#### 5. 修改 `MarkdownRenderer.getCodeHighlightCSS`

```swift
private func getCodeHighlightCSS(for themeId: String?) async -> String {
    // 1. 检查是否使用自定义代码高亮主题
    let useCustom = UserDefaults.standard.bool(forKey: "useCustomCodeHighlightTheme")
    let customThemeRaw = UserDefaults.standard.string(forKey: "customCodeHighlightTheme")
    
    let codeTheme: CodeTheme
    if useCustom, let customThemeRaw = customThemeRaw, 
       let customTheme = CodeTheme(rawValue: customThemeRaw) {
        // 使用用户自定义的代码高亮主题
        codeTheme = customTheme
    } else {
        // 使用预览主题的代码高亮主题
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
    
    // 2. 根据 codeTheme 获取颜色方案
    let colorScheme = getColorScheme(for: codeTheme)
    
    // 3. 生成 CSS...
}
```

#### 6. 初始化时加载用户选择

```swift
init(editorPreferences: EditorPreferences) {
    self.editorPreferences = editorPreferences
    self.originalEditorPreferences = editorPreferences
    
    // 加载用户选择的代码高亮主题
    if let savedThemeRaw = UserDefaults.standard.string(forKey: "customCodeHighlightTheme"),
       let savedTheme = CodeTheme(rawValue: savedThemeRaw) {
        self.codeHighlightTheme = savedTheme
    }
    
    self.useCustomCodeHighlightTheme = UserDefaults.standard.bool(forKey: "useCustomCodeHighlightTheme")
}
```

### CodeTheme 扩展

需要为 `CodeTheme` 添加 `allCases` 和 `displayName`：

```swift
extension CodeTheme: CaseIterable {
    static var allCases: [CodeTheme] {
        [.xcode, .github, .monokai, .dracula, .solarizedLight, .solarizedDark]
    }
    
    var displayName: String {
        switch self {
        case .xcode: return "Xcode"
        case .github: return "GitHub"
        case .monokai: return "Monokai"
        case .dracula: return "Dracula"
        case .solarizedLight: return "Solarized Light"
        case .solarizedDark: return "Solarized Dark"
        }
    }
}
```

## TCA 状态管理机制检查

### 符合 TCA 原则

- ✅ **状态在 Feature 中定义**：`codeHighlightTheme` 和 `useCustomCodeHighlightTheme` 在 `SettingsFeature.State` 中
- ✅ **通过 Action 更新状态**：`codeHighlightThemeChanged` 和 `useCustomCodeHighlightThemeToggled`
- ✅ **持久化在 Reducer 中处理**：保存到 `UserDefaults`
- ✅ **渲染逻辑在 Service 层**：`MarkdownRenderer` 读取 `UserDefaults`，不直接访问 Feature 状态
- ✅ **不涉及业务逻辑**：纯配置管理，符合 TCA 的纯函数式处理

### 状态流转

```
用户选择代码高亮主题
  ↓
SettingsFeature.codeHighlightThemeChanged
  ↓
更新 State.codeHighlightTheme
  ↓
保存到 UserDefaults
  ↓
MarkdownRenderer.getCodeHighlightCSS 读取 UserDefaults
  ↓
生成对应的 CSS
  ↓
预览更新
```

## 总结

**推荐方案**：方案A - 在"外观"设置面板中添加独立的代码高亮主题选择器

**优点**：
- ✅ 符合用户需求：可以独立选择代码高亮配色方案
- ✅ 用户体验好：与预览主题在同一面板，逻辑清晰
- ✅ 实现简单：只需扩展 `SettingsFeature` 和 `AppearanceSettingsPanel`
- ✅ 符合 TCA 架构：状态管理清晰，职责分离

**实施优先级**：高（用户明确需求）


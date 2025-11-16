# Nota4 编辑器偏好设置 - 实施计划

**文档版本**: v1.0  
**创建日期**: 2025年11月16日  
**预计工期**: 6-9 天  
**状态**: 待开始

---

## 一、总体规划

### 1.1 目标

实现一个完整的编辑器偏好设置系统，包括：
- ✅ 字体管理（标题/正文/代码）
- ✅ 排版控制（字号/行高/间距/行宽）
- ✅ 布局设置（边距/对齐）
- ✅ 预设方案（4种）
- ✅ 配置管理（导入/导出/恢复）

### 1.2 技术栈

- SwiftUI for UI
- TCA (The Composable Architecture) for State Management
- UserDefaults for Persistence
- Codable for Serialization

### 1.3 开发原则

1. **渐进式交付**: 每个阶段都能产出可用功能
2. **测试驱动**: 关键功能先写测试
3. **性能优先**: 关注响应速度和内存占用
4. **用户体验**: 界面简洁，交互流畅

---

## 二、详细计划

### 阶段 1：基础架构（Day 1-2）

#### Day 1 上午：数据模型

**任务：创建 `EditorPreferences.swift`**

```swift
// Nota4/Models/EditorPreferences.swift

import Foundation

struct EditorPreferences: Codable, Equatable {
    // 预设方案
    var preset: PresetType = .comfortable
    
    // 字体设置
    var titleFontName: String = "System"
    var titleFontSize: CGFloat = 24
    var bodyFontName: String = "System"
    var bodyFontSize: CGFloat = 17
    var codeFontName: String = "Menlo"
    var codeFontSize: CGFloat = 14
    
    // 排版设置
    var lineHeight: CGFloat = 1.6        // em
    var lineSpacing: CGFloat = 6         // pt
    var letterSpacing: CGFloat = 0       // em
    var paragraphSpacing: CGFloat = 0.8  // em
    var paragraphIndent: CGFloat = 0     // em
    var maxWidth: CGFloat = 800          // pt
    
    // 布局设置
    var horizontalPadding: CGFloat = 24  // pt
    var verticalPadding: CGFloat = 20    // pt
    var alignment: Alignment = .center
    
    enum PresetType: String, Codable, CaseIterable {
        case comfortable = "舒适阅读"
        case professional = "专业写作"
        case code = "代码编辑"
        case custom = "自定义"
        
        var preferences: EditorPreferences {
            switch self {
            case .comfortable:
                return EditorPreferences.defaultComfortable
            case .professional:
                return EditorPreferences.defaultProfessional
            case .code:
                return EditorPreferences.defaultCode
            case .custom:
                return EditorPreferences()
            }
        }
    }
    
    enum Alignment: String, Codable, CaseIterable {
        case leading = "左对齐"
        case center = "居中"
    }
    
    // 预设配置
    static let defaultComfortable = EditorPreferences()
    
    static let defaultProfessional = EditorPreferences(
        preset: .professional,
        bodyFontSize: 18,
        lineHeight: 1.8,
        lineSpacing: 8,
        letterSpacing: 0.05,
        paragraphSpacing: 1.0,
        maxWidth: 750,
        horizontalPadding: 32,
        verticalPadding: 24
    )
    
    static let defaultCode = EditorPreferences(
        preset: .code,
        bodyFontSize: 15,
        codeFontSize: 15,
        lineHeight: 1.5,
        lineSpacing: 4,
        paragraphSpacing: 0.5,
        maxWidth: 900,
        horizontalPadding: 20,
        verticalPadding: 16
    )
}
```

**验收标准：**
- [ ] 模型编译通过
- [ ] 包含所有需要的字段
- [ ] 支持 Codable
- [ ] 包含预设配置

#### Day 1 下午：持久化存储

**任务：创建 `PreferencesStorage.swift`**

```swift
// Nota4/Services/PreferencesStorage.swift

import Foundation

actor PreferencesStorage {
    static let shared = PreferencesStorage()
    
    private let key = "editorPreferences"
    private let defaults = UserDefaults.standard
    
    func load() -> EditorPreferences {
        guard let data = defaults.data(forKey: key),
              let preferences = try? JSONDecoder().decode(EditorPreferences.self, from: data) else {
            print("⚪ [PREFS] No saved preferences, using defaults")
            return EditorPreferences()
        }
        print("✅ [PREFS] Loaded preferences from storage")
        return preferences
    }
    
    func save(_ preferences: EditorPreferences) throws {
        let data = try JSONEncoder().encode(preferences)
        defaults.set(data, forKey: key)
        print("✅ [PREFS] Saved preferences to storage")
    }
    
    func reset() throws {
        defaults.removeObject(forKey: key)
        print("✅ [PREFS] Reset preferences to defaults")
    }
    
    // 导入导出
    func exportToJSON() throws -> Data {
        let preferences = load()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(preferences)
    }
    
    func importFromJSON(_ data: Data) throws {
        let preferences = try JSONDecoder().decode(EditorPreferences.self, from: data)
        try save(preferences)
    }
}
```

**验收标准：**
- [ ] 能正确保存和加载配置
- [ ] 支持导入导出 JSON
- [ ] 错误处理完善
- [ ] 添加日志

#### Day 2：集成到 AppFeature

**任务：修改 `AppFeature.swift`**

```swift
// 在 AppFeature.State 中添加
var preferences: EditorPreferences = EditorPreferences()

// 在 Action 中添加
case preferencesLoaded(EditorPreferences)
case preferencesUpdated(EditorPreferences)
case showPreferences
case dismissPreferences

// 在 Reducer 中添加
case .onAppear:
    return .merge(
        .send(.noteList(.loadNotes)),
        .run { send in
            let prefs = await PreferencesStorage.shared.load()
            await send(.preferencesLoaded(prefs))
        }
    )

case .preferencesLoaded(let prefs):
    state.preferences = prefs
    return .send(.editor(.applyPreferences(prefs)))

case .preferencesUpdated(let prefs):
    state.preferences = prefs
    return .merge(
        .run { _ in
            try await PreferencesStorage.shared.save(prefs)
        },
        .send(.editor(.applyPreferences(prefs)))
    )
```

**验收标准：**
- [ ] 应用启动时加载配置
- [ ] 配置变化时通知编辑器
- [ ] 数据流正确

---

### 阶段 2：设置界面（Day 3-5）

#### Day 3：主窗口布局

**任务：创建 `PreferencesView.swift`**

```swift
// Nota4/Features/Preferences/PreferencesView.swift

import SwiftUI
import ComposableArchitecture

struct PreferencesView: View {
    @Bindable var store: StoreOf<PreferencesFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("编辑器偏好设置")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("✕") {
                    store.send(.dismiss)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // 主内容区域
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 预设方案选择
                    PresetPickerView(store: store)
                    
                    Divider()
                    
                    // 字体设置
                    FontSettingsView(store: store)
                    
                    Divider()
                    
                    // 排版设置
                    TypographySettingsView(store: store)
                    
                    Divider()
                    
                    // 布局设置
                    LayoutSettingsView(store: store)
                    
                    Divider()
                    
                    // 配置管理
                    ConfigManagementView(store: store)
                }
                .padding()
            }
            
            Divider()
            
            // 底部按钮栏
            HStack {
                Spacer()
                Button("取消") {
                    store.send(.cancel)
                }
                Button("应用") {
                    store.send(.apply)
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 600, height: 700)
    }
}
```

**验收标准：**
- [ ] 窗口布局合理
- [ ] 分组清晰
- [ ] 支持滚动
- [ ] 按钮功能正常

#### Day 4：各个设置面板

**1. 预设选择器**

```swift
struct PresetPickerView: View {
    @Bindable var store: StoreOf<PreferencesFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("预设方案")
                .font(.headline)
            
            HStack(spacing: 16) {
                ForEach(EditorPreferences.PresetType.allCases, id: \.self) { preset in
                    PresetButton(
                        preset: preset,
                        isSelected: store.preferences.preset == preset
                    ) {
                        store.send(.presetSelected(preset))
                    }
                }
            }
        }
    }
}
```

**2. 字体设置面板**

```swift
struct FontSettingsView: View {
    @Bindable var store: StoreOf<PreferencesFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("字体设置")
                .font(.headline)
            
            // 标题字体
            HStack {
                Text("标题字体")
                    .frame(width: 100, alignment: .leading)
                Picker("", selection: $store.preferences.titleFontName) {
                    ForEach(availableFonts, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
                .frame(width: 200)
                
                Stepper("\(Int(store.preferences.titleFontSize)) pt", 
                       value: $store.preferences.titleFontSize, 
                       in: 18...32)
            }
            
            // 正文字体
            HStack {
                Text("正文字体")
                    .frame(width: 100, alignment: .leading)
                Picker("", selection: $store.preferences.bodyFontName) {
                    ForEach(availableFonts, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
                .frame(width: 200)
                
                Stepper("\(Int(store.preferences.bodyFontSize)) pt", 
                       value: $store.preferences.bodyFontSize, 
                       in: 12...24)
            }
            
            // 代码字体
            HStack {
                Text("代码字体")
                    .frame(width: 100, alignment: .leading)
                Picker("", selection: $store.preferences.codeFontName) {
                    ForEach(monospacedFonts, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
                .frame(width: 200)
                
                Stepper("\(Int(store.preferences.codeFontSize)) pt", 
                       value: $store.preferences.codeFontSize, 
                       in: 10...20)
            }
        }
    }
    
    private var availableFonts: [String] {
        ["System", "Songti SC", "Heiti SC", "Kaiti SC"]
    }
    
    private var monospacedFonts: [String] {
        ["Menlo", "Monaco", "Courier New", "SF Mono"]
    }
}
```

**3. 排版设置面板**

```swift
struct TypographySettingsView: View {
    @Bindable var store: StoreOf<PreferencesFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("排版设置")
                .font(.headline)
            
            // 行高
            SliderRow(
                title: "行高",
                value: $store.preferences.lineHeight,
                range: 1.0...2.5,
                unit: "em"
            )
            
            // 行间距
            SliderRow(
                title: "行间距",
                value: $store.preferences.lineSpacing,
                range: 0...20,
                unit: "pt"
            )
            
            // 字间距
            SliderRow(
                title: "字间距",
                value: $store.preferences.letterSpacing,
                range: -0.2...1.0,
                unit: "em"
            )
            
            // 段落间距
            SliderRow(
                title: "段落间距",
                value: $store.preferences.paragraphSpacing,
                range: 0...2.0,
                unit: "em"
            )
            
            // 段落缩进
            SliderRow(
                title: "段落缩进",
                value: $store.preferences.paragraphIndent,
                range: 0...4.0,
                unit: "em"
            )
            
            // 最大行宽
            SliderRow(
                title: "最大行宽",
                value: $store.preferences.maxWidth,
                range: 500...1200,
                unit: "pt"
            )
        }
    }
}

// 辅助组件
struct SliderRow: View {
    let title: String
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let unit: String
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 100, alignment: .leading)
            
            Slider(value: $value, in: range)
                .frame(width: 300)
            
            Text(String(format: "%.1f %@", value, unit))
                .frame(width: 80, alignment: .trailing)
                .monospacedDigit()
        }
    }
}
```

**4. 布局设置面板**

```swift
struct LayoutSettingsView: View {
    @Bindable var store: StoreOf<PreferencesFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("布局设置")
                .font(.headline)
            
            // 左右边距
            SliderRow(
                title: "左右边距",
                value: $store.preferences.horizontalPadding,
                range: 8...64,
                unit: "pt"
            )
            
            // 上下边距
            SliderRow(
                title: "上下边距",
                value: $store.preferences.verticalPadding,
                range: 8...64,
                unit: "pt"
            )
            
            // 对齐方式
            HStack {
                Text("对齐方式")
                    .frame(width: 100, alignment: .leading)
                
                Picker("", selection: $store.preferences.alignment) {
                    ForEach(EditorPreferences.Alignment.allCases, id: \.self) { alignment in
                        Text(alignment.rawValue).tag(alignment)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
        }
    }
}
```

**5. 配置管理面板**

```swift
struct ConfigManagementView: View {
    let store: StoreOf<PreferencesFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("配置管理")
                .font(.headline)
            
            HStack(spacing: 12) {
                Button("导入配置") {
                    store.send(.importConfig)
                }
                
                Button("导出配置") {
                    store.send(.exportConfig)
                }
                
                Button("恢复默认") {
                    store.send(.resetToDefaults)
                }
                .foregroundColor(.red)
            }
        }
    }
}
```

**验收标准：**
- [ ] 所有面板正常显示
- [ ] 参数可以调整
- [ ] 数值实时更新
- [ ] UI 响应流畅

#### Day 5：TCA Feature

**任务：创建 `PreferencesFeature.swift`**

```swift
// Nota4/Features/Preferences/PreferencesFeature.swift

import ComposableArchitecture
import Foundation

@Reducer
struct PreferencesFeature {
    @ObservableState
    struct State: Equatable {
        var preferences: EditorPreferences
        var originalPreferences: EditorPreferences
        
        init(preferences: EditorPreferences = EditorPreferences()) {
            self.preferences = preferences
            self.originalPreferences = preferences
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case presetSelected(EditorPreferences.PresetType)
        case importConfig
        case exportConfig
        case resetToDefaults
        case apply
        case cancel
        case dismiss
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                // 任何参数改变，都设置为自定义模式
                if state.preferences.preset != .custom {
                    state.preferences.preset = .custom
                }
                return .none
                
            case .presetSelected(let preset):
                state.preferences = preset.preferences
                return .none
                
            case .importConfig:
                // TODO: 打开文件选择器导入
                return .none
                
            case .exportConfig:
                // TODO: 打开文件保存器导出
                return .none
                
            case .resetToDefaults:
                state.preferences = EditorPreferences()
                return .none
                
            case .apply:
                // 保存并通知
                return .run { [preferences = state.preferences] send in
                    try await PreferencesStorage.shared.save(preferences)
                }
                
            case .cancel:
                // 恢复原始值
                state.preferences = state.originalPreferences
                return .send(.dismiss)
                
            case .dismiss:
                return .none
            }
        }
    }
}
```

**验收标准：**
- [ ] 状态管理正确
- [ ] Action 处理完整
- [ ] 数据流清晰
- [ ] 编译通过

---

### 阶段 3：样式应用（Day 6-7）

#### Day 6：扩展 EditorStyle

**任务：修改 `EditorStyle.swift`**

```swift
// 扩展 EditorStyle 支持所有新参数
struct EditorStyle {
    // 字体
    let fontSize: CGFloat
    let fontDesign: Font.Design
    let fontWeight: Font.Weight
    
    // 排版
    let lineHeight: CGFloat        // em
    let lineSpacing: CGFloat       // pt
    let letterSpacing: CGFloat     // em
    let paragraphSpacing: CGFloat  // em
    let paragraphIndent: CGFloat   // em
    
    // 布局
    let maxWidth: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let alignment: Alignment
    
    // 从 EditorPreferences 创建
    init(from preferences: EditorPreferences) {
        self.fontSize = preferences.bodyFontSize
        self.fontDesign = .default  // TODO: 根据字体名称映射
        self.fontWeight = .regular
        self.lineHeight = preferences.lineHeight
        self.lineSpacing = preferences.lineSpacing
        self.letterSpacing = preferences.letterSpacing
        self.paragraphSpacing = preferences.paragraphSpacing
        self.paragraphIndent = preferences.paragraphIndent
        self.maxWidth = preferences.maxWidth
        self.horizontalPadding = preferences.horizontalPadding
        self.verticalPadding = preferences.verticalPadding
        self.alignment = preferences.alignment == .center ? .center : .leading
    }
}
```

**验收标准：**
- [ ] 支持所有新参数
- [ ] 转换逻辑正确
- [ ] 编译通过

#### Day 7：集成到编辑器

**任务：修改 `EditorFeature.swift` 和 `NoteEditorView.swift`**

```swift
// EditorFeature 添加 Action
case applyPreferences(EditorPreferences)

// EditorFeature Reducer
case .applyPreferences(let prefs):
    state.editorStyle = EditorStyle(from: prefs)
    return .none

// NoteEditorView 使用动态样式
.editorStyle(store.editorStyle)
```

**验收标准：**
- [ ] 配置变化时编辑器实时更新
- [ ] 所有参数都能生效
- [ ] 性能良好

---

### 阶段 4：测试（Day 8）

#### 测试清单

**功能测试：**
- [ ] 切换预设方案
- [ ] 调整所有参数
- [ ] 保存和加载配置
- [ ] 导入导出配置
- [ ] 恢复默认值
- [ ] 实时预览

**性能测试：**
- [ ] 窗口打开时间 < 200ms
- [ ] 参数调整响应 < 50ms
- [ ] 内存占用 < 10MB

**兼容性测试：**
- [ ] macOS 14.0+
- [ ] 亮色/暗色主题
- [ ] 不同分辨率

---

### 阶段 5：优化完善（Day 9）

**任务：**
- [ ] UI 细节调整
- [ ] 添加工具提示
- [ ] 键盘导航支持
- [ ] 文档编写
- [ ] 代码审查

---

## 三、验收标准

### 3.1 必须完成

- [ ] 所有预设方案可用
- [ ] 所有参数可调整
- [ ] 配置可保存加载
- [ ] 实时预览正常
- [ ] 导入导出功能正常

### 3.2 性能指标

- [ ] 窗口打开 < 200ms
- [ ] 参数调整响应 < 50ms
- [ ] 无卡顿延迟

### 3.3 用户体验

- [ ] 界面清晰易懂
- [ ] 交互流畅
- [ ] 错误提示友好

---

## 四、风险控制

### 4.1 技术风险

| 风险 | 应对 |
|------|------|
| TextEditor 限制 | 提前测试，准备降级方案 |
| 性能问题 | 使用防抖，优化渲染 |
| 字体加载问题 | 提供默认字体列表 |

### 4.2 进度风险

| 风险 | 应对 |
|------|------|
| 工期延误 | 优先完成核心功能 |
| 测试时间不足 | 边开发边测试 |
| Bug 积累 | 每日 Bug 清零 |

---

## 五、下一步行动

**立即开始：**
1. 创建 `EditorPreferences.swift`
2. 创建 `PreferencesStorage.swift`
3. 编写单元测试

**准备工作：**
- [ ] 审查 PRD
- [ ] 评估技术风险
- [ ] 准备测试数据

---

**文档结束**

*准备好开始实施了吗？* 🚀


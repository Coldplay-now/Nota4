# 编辑模式与预览模式排版布局分离设计方案

**设计时间**: 2025-11-20

## 一、需求概述

当前排版布局设置是统一的，但编辑模式和预览模式有不同的显示需求：
- **编辑模式**：需要适合写作的布局（如更紧凑的行间距、较小的边距）
- **预览模式**：需要适合阅读的布局（如更宽松的行间距、较大的边距、居中对齐）

需要将排版布局设置区分为：
1. **编辑模式设置**：仅影响编辑器的显示
2. **预览模式设置**：仅影响预览区域的显示

---

## 二、设计方案

### 2.1 数据模型设计

#### 方案A：嵌套结构（推荐）⭐

```swift
// EditorPreferences.swift
struct EditorPreferences: Codable, Equatable {
    // MARK: - 字体设置（共享）
    var titleFontName: String = "System"
    var titleFontSize: CGFloat = 24
    var bodyFontName: String = "System"
    var bodyFontSize: CGFloat = 17
    var codeFontName: String = "Menlo"
    var codeFontSize: CGFloat = 14
    
    // MARK: - 编辑模式排版布局
    var editorLayout: LayoutSettings = LayoutSettings(
        lineSpacing: 4,           // 编辑模式更紧凑
        paragraphSpacing: 0.5,
        horizontalPadding: 16,    // 编辑模式边距更小
        verticalPadding: 12,
        alignment: .leading        // 编辑模式默认左对齐
    )
    
    // MARK: - 预览模式排版布局
    var previewLayout: LayoutSettings = LayoutSettings(
        lineSpacing: 6,           // 预览模式更宽松
        paragraphSpacing: 0.8,
        maxWidth: 800,             // 仅预览模式需要
        horizontalPadding: 24,     // 预览模式边距更大
        verticalPadding: 20,
        alignment: .leading        // 预览模式默认左对齐
    )
    
    // MARK: - Nested Types
    struct LayoutSettings: Codable, Equatable {
        var lineSpacing: CGFloat
        var paragraphSpacing: CGFloat
        var maxWidth: CGFloat?     // 可选，仅预览模式使用
        var horizontalPadding: CGFloat
        var verticalPadding: CGFloat
        var alignment: Alignment
        
        enum Alignment: String, Codable, CaseIterable {
            case leading = "左对齐"
            case center = "居中"
        }
    }
}
```

**优点**：
- 结构清晰，易于理解
- 编辑和预览设置完全独立
- 易于扩展和维护

**缺点**：
- 需要修改现有代码较多

---

#### 方案B：前缀命名（备选）

```swift
// EditorPreferences.swift
struct EditorPreferences: Codable, Equatable {
    // 字体设置（共享）
    // ...
    
    // 编辑模式设置
    var editorLineSpacing: CGFloat = 4
    var editorParagraphSpacing: CGFloat = 0.5
    var editorHorizontalPadding: CGFloat = 16
    var editorVerticalPadding: CGFloat = 12
    var editorAlignment: Alignment = .leading
    
    // 预览模式设置
    var previewLineSpacing: CGFloat = 6
    var previewParagraphSpacing: CGFloat = 0.8
    var previewMaxWidth: CGFloat = 800
    var previewHorizontalPadding: CGFloat = 24
    var previewVerticalPadding: CGFloat = 20
    var previewAlignment: Alignment = .leading
}
```

**优点**：
- 实现简单，修改量小
- 属性名清晰

**缺点**：
- 属性较多，代码冗长
- 不够优雅

---

### 2.2 UI 设计

#### 设计思路

使用 **分组 + 标签页** 或 **折叠面板** 的方式展示两种模式的设置。

#### 方案A：分组展示（推荐）⭐

```
┌─────────────────────────────────────────┐
│  排版布局                                │
├─────────────────────────────────────────┤
│                                          │
│  ┌─ 编辑模式设置 ───────────────────┐   │
│  │                                  │   │
│  │  行间距        [====●====]  4 pt │   │
│  │  段落间距      [====●====]  0.5 │   │
│  │  左右边距      [====●====]  16  │   │
│  │  上下边距      [====●====]  12  │   │
│  │  对齐方式      [左对齐│居中]    │   │
│  │                                  │   │
│  └──────────────────────────────────┘   │
│                                          │
│  ┌─ 预览模式设置 ───────────────────┐   │
│  │                                  │   │
│  │  行间距        [====●====]  6 pt │   │
│  │  段落间距      [====●====]  0.8 │   │
│  │  最大行宽      [====●====]  800 │   │
│  │  左右边距      [====●====]  24  │   │
│  │  上下边距      [====●====]  20  │   │
│  │  对齐方式      [左对齐│居中]    │   │
│  │                                  │   │
│  └──────────────────────────────────┘   │
│                                          │
└─────────────────────────────────────────┘
```

#### 方案B：标签页切换

```
┌─────────────────────────────────────────┐
│  排版布局  [编辑模式] [预览模式]         │
├─────────────────────────────────────────┤
│                                          │
│  行间距        [====●====]  6 pt        │
│  段落间距      [====●====]  0.8         │
│  最大行宽      [====●====]  800         │
│  左右边距      [====●====]  24          │
│  上下边距      [====●====]  20          │
│  对齐方式      [左对齐│居中]            │
│                                          │
└─────────────────────────────────────────┘
```

**推荐方案A**：分组展示更直观，用户可以同时看到两种模式的设置，方便对比和调整。

---

### 2.3 UI 实现代码

```swift
// SettingsView.swift
private struct TypographyAndLayoutSettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 编辑模式设置
            LayoutSettingsGroup(
                title: "编辑模式设置",
                icon: "pencil",
                description: "影响编辑器区域的显示效果",
                layout: $store.editorPreferences.editorLayout,
                showMaxWidth: false  // 编辑模式不需要最大行宽
            )
            
            Divider()
                .padding(.vertical, 8)
            
            // 预览模式设置
            LayoutSettingsGroup(
                title: "预览模式设置",
                icon: "eye",
                description: "影响预览区域的显示效果",
                layout: $store.editorPreferences.previewLayout,
                showMaxWidth: true  // 预览模式需要最大行宽
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 40)
    }
}

// 布局设置组组件
private struct LayoutSettingsGroup: View {
    let title: String
    let icon: String
    let description: String
    @Binding var layout: EditorPreferences.LayoutSettings
    let showMaxWidth: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            
            // 描述
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 设置项
            VStack(alignment: .leading, spacing: 16) {
                SliderRow(
                    title: "行间距",
                    value: $layout.lineSpacing,
                    range: 4...50,
                    unit: "pt",
                    step: 1
                )
                
                SliderRow(
                    title: "段落间距",
                    value: $layout.paragraphSpacing,
                    range: 0.5...6.0,
                    unit: "em",
                    step: 0.1
                )
                
                if showMaxWidth {
                    VStack(alignment: .leading, spacing: 4) {
                        SliderRow(
                            title: "最大行宽",
                            value: Binding(
                                get: { layout.maxWidth ?? 800 },
                                set: { layout.maxWidth = $0 }
                            ),
                            range: 600...1200,
                            unit: "pt",
                            step: 50
                        )
                        Text("预览模式下的最大行宽，编辑模式会根据编辑区域宽度自动适应")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                SliderRow(
                    title: "左右边距",
                    value: $layout.horizontalPadding,
                    range: 16...80,
                    unit: "pt",
                    step: 4
                )
                
                SliderRow(
                    title: "上下边距",
                    value: $layout.verticalPadding,
                    range: 12...100,
                    unit: "pt",
                    step: 4
                )
                
                // 对齐方式
                HStack(spacing: 12) {
                    Picker("", selection: $layout.alignment) {
                        ForEach(EditorPreferences.LayoutSettings.Alignment.allCases, id: \.self) { alignment in
                            Text(alignment.rawValue).tag(alignment)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 20)  // 缩进，表示这是子设置
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }
}
```

---

### 2.4 应用逻辑修改

#### EditorFeature.swift

```swift
case .applyPreferences(let prefs):
    // 应用编辑器样式（使用编辑模式设置）
    state.editorStyle = EditorStyle(
        fontSize: prefs.bodyFontSize,
        lineSpacing: prefs.editorLayout.lineSpacing,
        horizontalPadding: prefs.editorLayout.horizontalPadding,
        verticalPadding: prefs.editorLayout.verticalPadding,
        maxWidth: 0,  // 编辑模式不使用最大行宽
        paragraphSpacing: prefs.editorLayout.paragraphSpacing,
        alignment: prefs.editorLayout.alignment == .center ? .center : .leading,
        fontName: prefs.bodyFontName != "System" ? prefs.bodyFontName : nil,
        titleFontName: prefs.titleFontName != "System" ? prefs.titleFontName : nil,
        titleFontSize: prefs.titleFontSize
    )
    
    // 应用预览渲染选项（使用预览模式设置）
    state.preview.renderOptions.horizontalPadding = prefs.previewLayout.horizontalPadding
    state.preview.renderOptions.verticalPadding = prefs.previewLayout.verticalPadding
    state.preview.renderOptions.alignment = prefs.previewLayout.alignment == .center ? "center" : "left"
    state.preview.renderOptions.maxWidth = prefs.previewLayout.maxWidth ?? 800
    state.preview.renderOptions.lineSpacing = prefs.previewLayout.lineSpacing
    state.preview.renderOptions.paragraphSpacing = prefs.previewLayout.paragraphSpacing
    
    // 如果当前在预览模式，重新渲染以应用新设置
    if state.viewMode != .editOnly {
        return .send(.preview(.render))
    }
    return .none
```

---

### 2.5 迁移策略

为了保持向后兼容，需要处理旧数据的迁移：

```swift
// EditorPreferences.swift
extension EditorPreferences {
    /// 从旧版本迁移（兼容旧数据）
    init(from old: OldEditorPreferences) {
        // 字体设置直接复制
        self.titleFontName = old.titleFontName
        self.titleFontSize = old.titleFontSize
        self.bodyFontName = old.bodyFontName
        self.bodyFontSize = old.bodyFontSize
        self.codeFontName = old.codeFontName
        self.codeFontSize = old.codeFontSize
        
        // 将旧的统一设置复制到编辑和预览模式
        // 编辑模式使用更紧凑的默认值
        self.editorLayout = LayoutSettings(
            lineSpacing: old.lineSpacing - 2,  // 编辑模式更紧凑
            paragraphSpacing: old.paragraphSpacing * 0.6,
            maxWidth: nil,
            horizontalPadding: old.horizontalPadding - 8,
            verticalPadding: old.verticalPadding - 8,
            alignment: old.alignment
        )
        
        // 预览模式保持原值
        self.previewLayout = LayoutSettings(
            lineSpacing: old.lineSpacing,
            paragraphSpacing: old.paragraphSpacing,
            maxWidth: old.maxWidth,
            horizontalPadding: old.horizontalPadding,
            verticalPadding: old.verticalPadding,
            alignment: old.alignment
        )
    }
}
```

---

## 三、默认值建议

### 编辑模式（适合写作）
- 行间距：4pt（紧凑，适合快速输入）
- 段落间距：0.5em（较小，节省空间）
- 左右边距：16pt（较小，最大化编辑区域）
- 上下边距：12pt（较小）
- 对齐方式：左对齐（符合写作习惯）

### 预览模式（适合阅读）
- 行间距：6pt（宽松，适合阅读）
- 段落间距：0.8em（较大，清晰分隔）
- 最大行宽：800pt（适合阅读的行宽）
- 左右边距：24pt（较大，舒适阅读）
- 上下边距：20pt（较大）
- 对齐方式：左对齐（默认，用户可改为居中）

---

## 四、实施步骤

1. **数据模型修改**
   - [ ] 修改 `EditorPreferences` 结构，添加 `editorLayout` 和 `previewLayout`
   - [ ] 添加 `LayoutSettings` 嵌套结构
   - [ ] 实现数据迁移逻辑

2. **UI 修改**
   - [ ] 创建 `LayoutSettingsGroup` 组件
   - [ ] 修改 `TypographyAndLayoutSettingsView`，使用分组展示
   - [ ] 更新 `SliderRow` 以支持新的绑定

3. **应用逻辑修改**
   - [ ] 修改 `EditorFeature.applyPreferences`，分别应用编辑和预览设置
   - [ ] 修改 `EditorStyle` 初始化，使用编辑模式设置
   - [ ] 修改预览渲染选项，使用预览模式设置

4. **测试**
   - [ ] 测试编辑模式设置是否正确应用
   - [ ] 测试预览模式设置是否正确应用
   - [ ] 测试数据迁移是否正确
   - [ ] 测试保存和加载配置

---

## 五、优势总结

1. **用户体验**：编辑和预览可以有不同的布局，更符合实际使用场景
2. **灵活性**：用户可以根据需要分别调整两种模式的设置
3. **清晰性**：UI 上明确区分两种模式的设置，避免混淆
4. **向后兼容**：通过迁移策略，旧数据可以平滑升级

---

## 六、备选方案

如果觉得分组展示占用空间太大，可以考虑：

### 方案C：折叠面板

使用 `DisclosureGroup` 实现折叠：

```swift
DisclosureGroup {
    // 设置项
} label: {
    HStack {
        Image(systemName: "pencil")
        Text("编辑模式设置")
    }
}
```

用户可以根据需要展开/折叠，节省空间。

---

## 七、推荐方案

**推荐使用方案A（嵌套结构 + 分组展示）**：
- 数据模型清晰
- UI 直观易懂
- 用户体验好
- 易于维护和扩展



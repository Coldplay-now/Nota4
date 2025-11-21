import SwiftUI
import ComposableArchitecture
import AppKit

// MARK: - Appearance Settings Panel

/// 外观设置面板
/// 用于管理预览模式的字体、布局、主题和代码高亮
struct AppearanceSettingsPanel: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                    // 标题
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("外观")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("自定义预览区域的字体、排版、主题和代码高亮")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    Divider()
                    
                    // 预览模式字体设置
                    SettingSection(
                        title: "预览模式字体",
                        icon: "textformat",
                        description: "影响预览区域的字体显示"
                    ) {
                        PreviewFontSettingsView(store: store)
                    }
                    
                    Divider()
                    
                    // 预览模式排版布局
                    SettingSection(
                        title: "预览模式排版布局",
                        icon: "text.alignleft",
                        description: "影响预览区域的排版和布局"
                    ) {
                        PreviewLayoutSettingsView(store: store)
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
            .background(Color(nsColor: .controlBackgroundColor))
            .onAppear {
                store.send(.theme(.onAppear))
            }
        }
    }
}

// MARK: - Setting Section

private struct SettingSection<Content: View>: View {
    let title: String
    let icon: String
    let description: String?
    @ViewBuilder let content: Content
    
    init(
        title: String,
        icon: String,
        description: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.description = description
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let description = description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            content
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

// MARK: - Preview Font Settings

private struct PreviewFontSettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 正文字体
            HStack(alignment: .center, spacing: 12) {
                Text("正文字体")
                    .frame(width: 80, alignment: .leading)
                    .font(.subheadline)
                
                FontPickerView(
                    selectedFont: $store.editorPreferences.previewFonts.bodyFontName,
                    fonts: EditorPreferences.allSystemFonts
                )
                .frame(width: 180, alignment: .leading)
                .onChange(of: store.editorPreferences.previewFonts.bodyFontName) { _, newValue in
                    store.send(.previewFontChanged(.body, newValue))
                }
                
                Stepper("\(Int(store.editorPreferences.previewFonts.bodyFontSize)) pt",
                       value: $store.editorPreferences.previewFonts.bodyFontSize,
                       in: 12...24,
                       step: 1)
                .frame(width: 120)
                .onChange(of: store.editorPreferences.previewFonts.bodyFontSize) { _, newValue in
                    store.send(.previewFontSizeChanged(.body, newValue))
                }
            }
            
            // 标题字体
            HStack(alignment: .center, spacing: 12) {
                Text("标题字体")
                    .frame(width: 80, alignment: .leading)
                    .font(.subheadline)
                
                FontPickerView(
                    selectedFont: $store.editorPreferences.previewFonts.titleFontName,
                    fonts: EditorPreferences.allSystemFonts
                )
                .frame(width: 180, alignment: .leading)
                .onChange(of: store.editorPreferences.previewFonts.titleFontName) { _, newValue in
                    store.send(.previewFontChanged(.title, newValue))
                }
                
                Stepper("\(Int(store.editorPreferences.previewFonts.titleFontSize)) pt",
                       value: $store.editorPreferences.previewFonts.titleFontSize,
                       in: 18...32,
                       step: 1)
                .frame(width: 120)
                .onChange(of: store.editorPreferences.previewFonts.titleFontSize) { _, newValue in
                    store.send(.previewFontSizeChanged(.title, newValue))
                }
            }
            
            // 代码字体
            HStack(alignment: .center, spacing: 12) {
                Text("代码字体")
                    .frame(width: 80, alignment: .leading)
                    .font(.subheadline)
                
                FontPickerView(
                    selectedFont: $store.editorPreferences.previewFonts.codeFontName,
                    fonts: EditorPreferences.allMonospacedFonts
                )
                .frame(width: 180, alignment: .leading)
                .onChange(of: store.editorPreferences.previewFonts.codeFontName) { _, newValue in
                    store.send(.previewFontChanged(.code, newValue))
                }
                
                Stepper("\(Int(store.editorPreferences.previewFonts.codeFontSize)) pt",
                       value: $store.editorPreferences.previewFonts.codeFontSize,
                       in: 10...20,
                       step: 1)
                .frame(width: 120)
                .onChange(of: store.editorPreferences.previewFonts.codeFontSize) { _, newValue in
                    store.send(.previewFontSizeChanged(.code, newValue))
                }
            }
        }
    }
}

// MARK: - Preview Layout Settings

private struct PreviewLayoutSettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SliderRow(
                title: "行间距",
                value: $store.editorPreferences.previewLayout.lineSpacing,
                range: 4...50,
                unit: "pt",
                step: 1
            )
            .onChange(of: store.editorPreferences.previewLayout.lineSpacing) { _, _ in
                store.send(.previewLayoutChanged(store.editorPreferences.previewLayout))
            }
            
            SliderRow(
                title: "段落间距",
                value: $store.editorPreferences.previewLayout.paragraphSpacing,
                range: 0.5...6.0,
                unit: "em",
                step: 0.1
            )
            .onChange(of: store.editorPreferences.previewLayout.paragraphSpacing) { _, _ in
                store.send(.previewLayoutChanged(store.editorPreferences.previewLayout))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                SliderRow(
                    title: "最大行宽",
                    value: Binding(
                        get: { store.editorPreferences.previewLayout.maxWidth ?? 800 },
                        set: { store.editorPreferences.previewLayout.maxWidth = $0 }
                    ),
                    range: 600...1200,
                    unit: "pt",
                    step: 50
                )
                .onChange(of: store.editorPreferences.previewLayout.maxWidth) { _, _ in
                    store.send(.previewLayoutChanged(store.editorPreferences.previewLayout))
                }
                
                Text("预览模式下的最大行宽")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            SliderRow(
                title: "左右边距",
                value: $store.editorPreferences.previewLayout.horizontalPadding,
                range: 16...80,
                unit: "pt",
                step: 4
            )
            .onChange(of: store.editorPreferences.previewLayout.horizontalPadding) { _, _ in
                store.send(.previewLayoutChanged(store.editorPreferences.previewLayout))
            }
            
            SliderRow(
                title: "上下边距",
                value: $store.editorPreferences.previewLayout.verticalPadding,
                range: 12...100,
                unit: "pt",
                step: 4
            )
            .onChange(of: store.editorPreferences.previewLayout.verticalPadding) { _, _ in
                store.send(.previewLayoutChanged(store.editorPreferences.previewLayout))
            }
            
            HStack(spacing: 12) {
                Picker("", selection: $store.editorPreferences.previewLayout.alignment) {
                    ForEach(EditorPreferences.LayoutSettings.Alignment.allCases, id: \.self) { alignment in
                        Text(alignment.rawValue).tag(alignment)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200, alignment: .leading)
                .onChange(of: store.editorPreferences.previewLayout.alignment) { _, _ in
                    store.send(.previewLayoutChanged(store.editorPreferences.previewLayout))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 40)
    }
}

// MARK: - Theme Selection

private struct ThemeSelectionView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !store.theme.builtInThemes.isEmpty {
                VStack(spacing: 12) {
                    ForEach(store.theme.builtInThemes) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: theme.id == store.theme.currentThemeId,
                            onSelect: {
                                store.send(.theme(.selectTheme(theme.id)))
                            }
                        )
                    }
                }
            }
            
            // 导入/导出状态提示
            if case .importing = store.theme.importExportState {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("正在导入主题...")
                        .font(.caption)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
            
            if case .success = store.theme.importExportState {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("操作成功")
                        .font(.caption)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            // 错误提示
            if let error = store.theme.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                    Spacer()
                    Button("关闭") {
                        store.send(.theme(.dismissError))
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Code Highlight Settings

private struct CodeHighlightSettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    private var codeHighlightModeBinding: Binding<EditorPreferences.CodeHighlightMode> {
        Binding(
            get: { store.editorPreferences.codeHighlightMode },
            set: { newValue in
                store.send(.codeHighlightModeChanged(newValue))
            }
        )
    }
    
    private var currentTheme: ThemeConfig? {
        store.theme.currentTheme
    }
    
    private var codeHighlightThemeName: String {
        currentTheme?.codeHighlightTheme.displayName ?? "未知"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 设置模式选择
            Picker("代码高亮模式", selection: codeHighlightModeBinding) {
                Text("跟随主题").tag(EditorPreferences.CodeHighlightMode.followTheme)
                Text("自定义").tag(EditorPreferences.CodeHighlightMode.custom)
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            
            // 详细设置视图
            detailSettingsView
        }
    }
    
    @ViewBuilder
    private var detailSettingsView: some View {
        if store.editorPreferences.codeHighlightMode == .followTheme {
            HStack {
                Text("当前主题代码高亮：")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(codeHighlightThemeName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.top, 4)
        } else {
            customThemeSelector
        }
    }
    
    private var customThemeSelector: some View {
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
                    themeButton(for: theme)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func themeButton(for theme: CodeTheme) -> some View {
        let isSelected = store.editorPreferences.codeHighlightTheme == theme
        return Button {
            store.send(.codeHighlightThemeChanged(theme))
        } label: {
            Text(theme.displayName)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ? Color.accentColor : Color.secondary.opacity(0.1)
                )
                .foregroundColor(
                    isSelected ? .white : .primary
                )
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Slider Row

private struct SliderRow: View {
    let title: String
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let unit: String
    let step: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(String(format: "%.1f %@", value, unit))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .fontWeight(.medium)
                .font(.subheadline)
                .frame(width: 80, alignment: .trailing)
            
            Slider(value: $value, in: range, step: step) {
                Text(title)
            }
            .accentColor(.accentColor)
            .frame(maxWidth: 400)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Theme Card

private struct ThemeCard: View {
    let theme: ThemeConfig
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(theme.displayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                
                if let description = theme.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    AppearanceSettingsPanel(
        store: Store(
            initialState: SettingsFeature.State(
                editorPreferences: EditorPreferences()
            )
        ) {
            SettingsFeature()
        }
    )
    .frame(width: 600, height: 800)
}


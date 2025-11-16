import SwiftUI
import ComposableArchitecture

/// Settings Window - macOS 系统设置风格
struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HSplitView {
            // 左侧分类列表
            SettingsSidebarView(store: store)
                .frame(minWidth: 200, maxWidth: 250)
            
            // 右侧设置面板
            SettingsDetailView(store: store)
                .frame(minWidth: 500, maxWidth: .infinity)
        }
        .frame(width: 800, height: 600)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    store.send(.cancel)
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("应用") {
                    store.send(.apply)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}

// MARK: - Sidebar

private struct SettingsSidebarView: View {
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        List(SettingsCategory.allCases, selection: Binding(
            get: { store.selectedCategory },
            set: { store.send(.categorySelected($0)) }
        )) { category in
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.rawValue)
                        .font(.body)
                    Text(category.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 32, height: 32)
            }
            .tag(category)
        }
        .listStyle(.sidebar)
        .navigationTitle("首选项")
    }
}

// MARK: - Detail View

private struct SettingsDetailView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                switch store.selectedCategory {
                case .editor:
                    EditorSettingsPanel(store: store)
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

// MARK: - Editor Settings Panel

private struct EditorSettingsPanel: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 标题
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("编辑器")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("自定义编辑器的字体、排版和布局")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)
            
            Divider()
            
            // 字体设置
            SettingSection(title: "字体", icon: "textformat") {
                FontSettingsView(store: store)
            }
            
            Divider()
            
            // 排版设置
            SettingSection(title: "排版", icon: "text.alignleft") {
                TypographySettingsView(store: store)
            }
            
            Divider()
            
            // 布局设置
            SettingSection(title: "布局", icon: "sidebar.left") {
                LayoutSettingsView(store: store)
            }
            
            Divider()
            
            // 配置管理
            SettingSection(title: "配置管理", icon: "gearshape") {
                ConfigManagementView(store: store)
            }
            
            Spacer(minLength: 32)
        }
    }
}

// MARK: - Setting Section

private struct SettingSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)
            
            content
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
    }
}

// MARK: - Font Settings

private struct FontSettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 正文字体
            HStack {
                Text("正文字体")
                    .frame(width: 100, alignment: .leading)
                    .foregroundStyle(.secondary)
                
                Picker("", selection: $store.editorPreferences.bodyFontName) {
                    ForEach(EditorPreferences.systemFonts, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
                .frame(width: 180)
                
                Stepper("\(Int(store.editorPreferences.bodyFontSize)) pt",
                       value: $store.editorPreferences.bodyFontSize,
                       in: 12...24,
                       step: 1)
                .frame(width: 120)
            }
            
            // 标题字体
            HStack {
                Text("标题字体")
                    .frame(width: 100, alignment: .leading)
                    .foregroundStyle(.secondary)
                
                Picker("", selection: $store.editorPreferences.titleFontName) {
                    ForEach(EditorPreferences.systemFonts, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
                .frame(width: 180)
                
                Stepper("\(Int(store.editorPreferences.titleFontSize)) pt",
                       value: $store.editorPreferences.titleFontSize,
                       in: 18...32,
                       step: 1)
                .frame(width: 120)
            }
            
            // 代码字体
            HStack {
                Text("代码字体")
                    .frame(width: 100, alignment: .leading)
                    .foregroundStyle(.secondary)
                
                Picker("", selection: $store.editorPreferences.codeFontName) {
                    ForEach(EditorPreferences.monospacedFonts, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
                .frame(width: 180)
                
                Stepper("\(Int(store.editorPreferences.codeFontSize)) pt",
                       value: $store.editorPreferences.codeFontSize,
                       in: 10...20,
                       step: 1)
                .frame(width: 120)
            }
        }
    }
}

// MARK: - Typography Settings

private struct TypographySettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SliderRow(
                title: "行间距",
                value: $store.editorPreferences.lineSpacing,
                range: 4...12,
                unit: "pt",
                step: 1
            )
            
            SliderRow(
                title: "段落间距",
                value: $store.editorPreferences.paragraphSpacing,
                range: 0.5...2.0,
                unit: "em",
                step: 0.1
            )
            
            SliderRow(
                title: "最大行宽",
                value: $store.editorPreferences.maxWidth,
                range: 600...1200,
                unit: "pt",
                step: 50
            )
        }
    }
}

// MARK: - Layout Settings

private struct LayoutSettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SliderRow(
                title: "左右边距",
                value: $store.editorPreferences.horizontalPadding,
                range: 16...48,
                unit: "pt",
                step: 4
            )
            
            SliderRow(
                title: "上下边距",
                value: $store.editorPreferences.verticalPadding,
                range: 12...32,
                unit: "pt",
                step: 4
            )
            
            HStack {
                Text("对齐方式")
                    .frame(width: 100, alignment: .leading)
                    .foregroundStyle(.secondary)
                
                Picker("", selection: $store.editorPreferences.alignment) {
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

// MARK: - Config Management

private struct ConfigManagementView: View {
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                store.send(.importConfig)
            } label: {
                Label("导入配置", systemImage: "square.and.arrow.down")
            }
            
            Button {
                store.send(.exportConfig)
            } label: {
                Label("导出配置", systemImage: "square.and.arrow.up")
            }
            
            Spacer()
            
            Button {
                store.send(.resetToDefaults)
            } label: {
                Label("恢复默认", systemImage: "arrow.counterclockwise")
            }
            .foregroundColor(.red)
        }
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f %@", value, unit))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .fontWeight(.medium)
            }
            
            Slider(value: $value, in: range, step: step) {
                Text(title)
            }
            .accentColor(.accentColor)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(
        store: Store(initialState: SettingsFeature.State(editorPreferences: EditorPreferences())) {
            SettingsFeature()
        }
    )
}


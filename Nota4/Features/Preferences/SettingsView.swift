import SwiftUI
import ComposableArchitecture
import AppKit

/// Settings Window - macOS 系统设置风格
struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            HSplitView {
                // 左侧分类列表
                SettingsSidebarView(store: store)
                    .frame(minWidth: 200, idealWidth: 220, maxWidth: 280)
                
                // 右侧设置面板
                SettingsDetailView(store: store)
                    .frame(minWidth: 500, idealWidth: 600, maxWidth: .infinity)
            }
            .frame(width: min(geometry.size.width, 900), height: min(geometry.size.height, 700))
        }
        .frame(minWidth: 700, idealWidth: 900, minHeight: 500, idealHeight: 700)
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
                case .appearance:
                    AppearanceSettingsPanel(store: store)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

// MARK: - Editor Settings Panel

private struct EditorSettingsPanel: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Divider()
            
            // 字体设置
            CompactSettingSection {
                FontSettingsView(store: store)
            }
            
            Divider()
            
            // 排版和布局设置（合并）
            CompactSettingSection {
                Text("排版布局")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)
                
                TypographyAndLayoutSettingsView(store: store)
            }
            
            Divider()
            
            // 配置管理
            CompactSettingSection {
                ConfigManagementView(store: store)
            }
            
            Spacer(minLength: 24)
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

// MARK: - Compact Setting Section (无标题版本)

private struct CompactSettingSection<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

// MARK: - Font Settings

private struct FontSettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 正文字体
            HStack(alignment: .center, spacing: 12) {
                Text("正文字体")
                    .frame(width: 80, alignment: .leading)
                    .font(.subheadline)
                
                FontPickerView(
                    selectedFont: $store.editorPreferences.bodyFontName,
                    fonts: EditorPreferences.allSystemFonts
                )
                .frame(width: 180, alignment: .leading)
                
                Stepper("\(Int(store.editorPreferences.bodyFontSize)) pt",
                       value: $store.editorPreferences.bodyFontSize,
                       in: 12...24,
                       step: 1)
                .frame(width: 120)
            }
            
            // 标题字体
            HStack(alignment: .center, spacing: 12) {
                Text("标题字体")
                    .frame(width: 80, alignment: .leading)
                    .font(.subheadline)
                
                FontPickerView(
                    selectedFont: $store.editorPreferences.titleFontName,
                    fonts: EditorPreferences.allSystemFonts
                )
                .frame(width: 180, alignment: .leading)
                
                Stepper("\(Int(store.editorPreferences.titleFontSize)) pt",
                       value: $store.editorPreferences.titleFontSize,
                       in: 18...32,
                       step: 1)
                .frame(width: 120)
            }
            
            // 代码字体
            HStack(alignment: .center, spacing: 12) {
                Text("代码字体")
                    .frame(width: 80, alignment: .leading)
                    .font(.subheadline)
                
                FontPickerView(
                    selectedFont: $store.editorPreferences.codeFontName,
                    fonts: EditorPreferences.allMonospacedFonts
                )
                .frame(width: 180, alignment: .leading)
                
                Stepper("\(Int(store.editorPreferences.codeFontSize)) pt",
                       value: $store.editorPreferences.codeFontSize,
                       in: 10...20,
                       step: 1)
                .frame(width: 120)
            }
        }
    }
}

// MARK: - Typography and Layout Settings (合并)

private struct TypographyAndLayoutSettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 排版设置
            SliderRow(
                title: "行间距",
                value: $store.editorPreferences.lineSpacing,
                range: 4...50,
                unit: "pt",
                step: 1
            )
            
            SliderRow(
                title: "段落间距",
                value: $store.editorPreferences.paragraphSpacing,
                range: 0.5...6.0,
                unit: "em",
                step: 0.1
            )
            
            VStack(alignment: .leading, spacing: 4) {
                SliderRow(
                    title: "最大行宽",
                    value: $store.editorPreferences.maxWidth,
                    range: 600...1200,
                    unit: "pt",
                    step: 50
                )
                Text("预览模式下的最大行宽，编辑模式会根据编辑区域宽度自动适应")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 0)  // 左对齐，不再需要特殊对齐
            }
            
            // 布局设置
            SliderRow(
                title: "左右边距",
                value: $store.editorPreferences.horizontalPadding,
                range: 16...80,
                unit: "pt",
                step: 4
            )
            
            SliderRow(
                title: "上下边距",
                value: $store.editorPreferences.verticalPadding,
                range: 12...100,
                unit: "pt",
                step: 4
            )
            
            // 对齐方式
            HStack(spacing: 12) {
                Picker("", selection: $store.editorPreferences.alignment) {
                    ForEach(EditorPreferences.Alignment.allCases, id: \.self) { alignment in
                        Text(alignment.rawValue).tag(alignment)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Config Management

private struct ConfigManagementView: View {
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                importConfig()
            } label: {
                Label("导入配置", systemImage: "square.and.arrow.down")
            }
            
            Button {
                exportConfig()
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
    
    private func importConfig() {
        let panel = NSOpenPanel()
        panel.title = "选择配置文件"
        panel.message = "请选择 Nota4 配置文件 (.json)"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.json]
        
        DispatchQueue.main.async {
            panel.begin { response in
                guard response == .OK, let url = panel.url else { return }
                
                Task {
                    do {
                        try PreferencesStorage.shared.importFromFile(at: url)
                        let newPrefs = await PreferencesStorage.shared.load()
                        
                        await MainActor.run {
                            // 更新 store 中的配置
                            var state = store.withState { $0 }
                            state.editorPreferences = newPrefs
                            state.originalEditorPreferences = newPrefs
                            
                            // 显示成功提示
                            let alert = NSAlert()
                            alert.messageText = "导入成功"
                            alert.informativeText = "配置已导入，请点击【应用】按钮使其生效"
                            alert.alertStyle = .informational
                            alert.addButton(withTitle: "好的")
                            alert.runModal()
                        }
                    } catch {
                        await MainActor.run {
                            let alert = NSAlert()
                            alert.messageText = "导入失败"
                            alert.informativeText = error.localizedDescription
                            alert.alertStyle = .warning
                            alert.addButton(withTitle: "好的")
                            alert.runModal()
                        }
                    }
                }
            }
        }
    }
    
    private func exportConfig() {
        let panel = NSSavePanel()
        panel.title = "导出配置"
        panel.message = "选择保存位置"
        panel.nameFieldStringValue = "nota4-config.json"
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        
        DispatchQueue.main.async {
            panel.begin { response in
                guard response == .OK, let url = panel.url else { return }
                
                Task {
                    do {
                        try await PreferencesStorage.shared.exportToFile(at: url)
                        await MainActor.run {
                            let alert = NSAlert()
                            alert.messageText = "导出成功"
                            alert.informativeText = "配置已保存到：\n\(url.path)"
                            alert.alertStyle = .informational
                            alert.addButton(withTitle: "好的")
                            alert.runModal()
                        }
                    } catch {
                        await MainActor.run {
                            let alert = NSAlert()
                            alert.messageText = "导出失败"
                            alert.informativeText = error.localizedDescription
                            alert.alertStyle = .warning
                            alert.addButton(withTitle: "好的")
                            alert.runModal()
                        }
                    }
                }
            }
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
        HStack(alignment: .center, spacing: 12) {
            // 移除灰色标题文字，只显示数值和滑块
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
            .frame(maxWidth: 400)  // 适度缩短滑块宽度，最大值不变
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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


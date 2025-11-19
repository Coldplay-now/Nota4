import SwiftUI
import ComposableArchitecture
import AppKit

// MARK: - Appearance Settings Panel

/// 外观设置面板
/// 用于管理主题和预览样式
struct AppearanceSettingsPanel: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        WithPerceptionTracking {
                VStack(alignment: .leading, spacing: 20) {
                    // 标题
                HStack {
                    Text("预览主题")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                    
                    // 内置主题
                    if !store.theme.builtInThemes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("内置主题")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                            
                        // 使用自适应网格布局
                            LazyVGrid(columns: [
                            GridItem(.flexible(minimum: 100, maximum: 200), spacing: 12),
                            GridItem(.flexible(minimum: 100, maximum: 200), spacing: 12)
                            ], spacing: 12) {
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
                        .padding(.horizontal, 20)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    
                    // 代码高亮主题选择区域
                    VStack(alignment: .leading, spacing: 12) {
                        Text("代码高亮主题")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Toggle("独立设置代码高亮主题", isOn: Binding(
                                get: { store.useCustomCodeHighlightTheme },
                                set: { store.send(.useCustomCodeHighlightThemeToggled($0)) }
                            ))
                            
                            Spacer()
                        }
                        
                        if store.useCustomCodeHighlightTheme {
                            // 使用网格布局，两排显示
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
                                                store.codeHighlightTheme == theme
                                                    ? Color.accentColor
                                                    : Color.secondary.opacity(0.1)
                                            )
                                            .foregroundColor(
                                                store.codeHighlightTheme == theme
                                                    ? .white
                                                    : .primary
                                            )
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } else {
                            Text("使用预览主题的代码高亮设置")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                .padding(.horizontal, 20)
                    
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
                    .padding(.horizontal, 20)
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
                    .padding(.horizontal, 20)
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
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                store.send(.theme(.onAppear))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func importTheme() {
        let panel = NSOpenPanel()
        panel.title = "选择主题文件夹"
        panel.message = "请选择包含 theme.json 的主题文件夹"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        DispatchQueue.main.async {
            panel.begin { response in
                guard response == .OK, let url = panel.url else { return }
                self.store.send(.theme(.importTheme(url)))
            }
        }
    }
    
    private func exportTheme(themeId: String, themeName: String) {
        let panel = NSSavePanel()
        panel.title = "导出主题"
        panel.message = "选择导出位置"
        panel.nameFieldStringValue = themeName
        panel.canCreateDirectories = true
        
        DispatchQueue.main.async {
            panel.begin { response in
                guard response == .OK, let url = panel.url else { return }
                
                Task {
                    do {
                        try await ThemeManager.shared.exportTheme(themeId, to: url)
                        await MainActor.run {
                            self.store.send(.theme(.exportThemeResponse(.success(()))))
                        }
                    } catch {
                        await MainActor.run {
                            self.store.send(.theme(.exportThemeResponse(.failure(error))))
                        }
                    }
                }
            }
        }
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

// MARK: - Custom Theme Row

private struct CustomThemeRow: View {
    let theme: ThemeConfig
    let isSelected: Bool
    let onSelect: () -> Void
    let onExport: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onSelect) {
                HStack {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(theme.displayName)
                            .font(.body)
                        
                        if let author = theme.author {
                            Text("作者: \(author)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            
            Button {
                onExport()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("导出主题")
            
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .help("删除主题")
        }
        .padding()
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}

// MARK: - Color Dot

private struct ColorDot: View {
    let color: String
    
    var body: some View {
        Circle()
            .fill(Color(hex: color) ?? .gray)
            .frame(width: 12, height: 12)
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let length = hexSanitized.count
        let r, g, b, a: Double
        
        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
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


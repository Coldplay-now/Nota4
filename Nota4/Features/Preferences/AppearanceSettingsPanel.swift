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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 标题
                    Text("预览主题")
                        .font(.headline)
                    
                    // 内置主题
                    if !store.theme.builtInThemes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("内置主题")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
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
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // 自定义主题
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("自定义主题")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button {
                                importTheme()
                            } label: {
                                Label("导入", systemImage: "square.and.arrow.down")
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        
                        if store.theme.customThemes.isEmpty {
                            ContentUnavailableView(
                                "暂无自定义主题",
                                systemImage: "paintbrush",
                                description: Text("点击【导入】按钮添加自定义主题")
                            )
                            .frame(height: 150)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(store.theme.customThemes) { theme in
                                    CustomThemeRow(
                                        theme: theme,
                                        isSelected: theme.id == store.theme.currentThemeId,
                                        onSelect: {
                                            store.send(.theme(.selectTheme(theme.id)))
                                        },
                                        onExport: {
                                            exportTheme(themeId: theme.id, themeName: theme.displayName)
                                        },
                                        onDelete: {
                                            store.send(.theme(.confirmDelete(theme.id)))
                                        }
                                    )
                                }
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
                .padding()
            }
            .onAppear {
                store.send(.theme(.onAppear))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func importTheme() {
        print("🎨 [IMPORT] Import button clicked")
        let panel = NSOpenPanel()
        panel.title = "选择主题文件夹"
        panel.message = "请选择包含 theme.json 的主题文件夹"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        DispatchQueue.main.async {
            panel.begin { response in
                print("🎨 [IMPORT] Panel response: \(response)")
                guard response == .OK, let url = panel.url else { 
                    print("🎨 [IMPORT] User cancelled or no URL")
                    return 
                }
                print("🎨 [IMPORT] Selected URL: \(url)")
                self.store.send(.theme(.importTheme(url)))
            }
        }
    }
    
    private func exportTheme(themeId: String, themeName: String) {
        print("🎨 [EXPORT] Export button clicked for theme: \(themeId)")
        let panel = NSSavePanel()
        panel.title = "导出主题"
        panel.message = "选择导出位置"
        panel.nameFieldStringValue = themeName
        panel.canCreateDirectories = true
        
        DispatchQueue.main.async {
            panel.begin { response in
                print("🎨 [EXPORT] Panel response: \(response)")
                guard response == .OK, let url = panel.url else { 
                    print("🎨 [EXPORT] User cancelled or no URL")
                    return 
                }
                print("🎨 [EXPORT] Selected URL: \(url)")
                
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
                
                // 颜色预览
                if let colors = theme.colors {
                    HStack(spacing: 4) {
                        ColorDot(color: colors.backgroundColor)
                        ColorDot(color: colors.textColor)
                        ColorDot(color: colors.primaryColor)
                        ColorDot(color: colors.accentColor)
                    }
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


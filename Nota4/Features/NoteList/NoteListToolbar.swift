import SwiftUI
import ComposableArchitecture

// MARK: - 笔记列表工具栏

/// 笔记列表工具栏组件
/// 位于笔记列表顶部，提供搜索、新建、排序等功能
struct NoteListToolbar: View {
    let store: StoreOf<NoteListFeature>
    @State private var availableWidth: CGFloat = 0
    
    var body: some View {
        WithPerceptionTracking {
            HStack(spacing: 8) {
                // 搜索按钮
                NoteListToolbarButton(
                    title: store.isSearchPanelVisible ? "关闭搜索" : "搜索",
                    icon: store.isSearchPanelVisible ? "xmark.circle.fill" : "magnifyingglass",
                    shortcut: "⌘F",
                    isEnabled: true
                ) {
                    store.send(.toggleSearchPanel)
                }
                
                Divider()
                    .frame(height: 16)
                
                // 新建笔记按钮
                NoteListToolbarButton(
                    title: "新建笔记",
                    icon: "square.and.pencil",
                    shortcut: "⌘N",
                    isEnabled: true
                ) {
                    store.send(.createNote)
                }
                
                Divider()
                    .frame(height: 16)
                
                // 排序菜单
                SortMenuButton(store: store)
                
                // 导出按钮（仅在多选时显示）
                if store.selectedNoteIds.count > 1 {
                    Divider()
                        .frame(height: 16)
                    
                    Menu {
                        Button("导出为 .nota") {
                            let notesToExport = store.notes.filter { store.selectedNoteIds.contains($0.noteId) }
                            store.send(.exportNotes(notesToExport, .nota))
                        }
                        Button("导出为 .md") {
                            let notesToExport = store.notes.filter { store.selectedNoteIds.contains($0.noteId) }
                            store.send(.exportNotes(notesToExport, .markdown))
                        }
                        Button("导出为 .html") {
                            let notesToExport = store.notes.filter { store.selectedNoteIds.contains($0.noteId) }
                            store.send(.exportNotes(notesToExport, .html))
                        }
                        Button("导出为 .pdf") {
                            let notesToExport = store.notes.filter { store.selectedNoteIds.contains($0.noteId) }
                            store.send(.exportNotes(notesToExport, .pdf))
                        }
                        Button("导出为 .png") {
                            let notesToExport = store.notes.filter { store.selectedNoteIds.contains($0.noteId) }
                            store.send(.exportNotes(notesToExport, .png))
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .regular))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.plain)
                    .help("导出选中笔记")
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(height: 40)
            .background(Color(nsColor: .controlBackgroundColor))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(nsColor: .separatorColor)),
                alignment: .bottom
            )
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            availableWidth = geometry.size.width
                        }
                        .onChange(of: geometry.size.width) { _, width in
                            availableWidth = width
                        }
                }
            )
        }
    }
}

// MARK: - 自定义搜索框

struct CustomSearchField: View {
    @Binding var text: String
    @Binding var isPresented: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 14))
            
            TextField("搜索笔记...", text: $text)
                .textFieldStyle(.plain)
                .focused($isFocused)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                )
        )
        .frame(minWidth: 200)
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                isFocused = true
            }
        }
    }
}

// MARK: - 排序菜单按钮

struct SortMenuButton: View {
    let store: StoreOf<NoteListFeature>
    @State private var isHovered = false
    
    var body: some View {
        Menu {
            Picker("排序", selection: Binding(
                get: { store.sortOrder },
                set: { store.send(.sortOrderChanged($0)) }
            )) {
                Label("最近更新", systemImage: "clock")
                    .tag(NoteListFeature.State.SortOrder.updated)
                Label("创建时间", systemImage: "calendar")
                    .tag(NoteListFeature.State.SortOrder.created)
                Label("标题", systemImage: "textformat")
                    .tag(NoteListFeature.State.SortOrder.title)
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 16, weight: .regular))
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .help("排序")
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)
        )
        .foregroundColor(.primary)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
    
    private var backgroundColor: Color {
        if isHovered {
            return Color(nsColor: .controlAccentColor).opacity(0.15)
        }
        return Color.clear
    }
}

// MARK: - 工具栏按钮组件

struct NoteListToolbarButton: View {
    let title: String
    let icon: String
    let shortcut: String?
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular))
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)
        )
        .foregroundColor(foregroundColor)
        .contentShape(Rectangle())
        .help(helpText)
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return Color.clear
        }
        if isHovered {
            return Color(nsColor: .controlAccentColor).opacity(0.15)
        }
        return Color.clear
    }
    
    private var foregroundColor: Color {
        if !isEnabled {
            return Color.secondary.opacity(0.4)
        }
        return Color.primary
    }
    
    private var helpText: String {
        if let shortcut = shortcut {
            return "\(title) (\(shortcut))"
        }
        return title
    }
}


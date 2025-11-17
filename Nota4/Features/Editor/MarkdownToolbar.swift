import SwiftUI
import ComposableArchitecture

// MARK: - Markdown 工具栏主组件

/// Markdown 格式工具栏
/// 提供可视化的 Markdown 格式化按钮
struct MarkdownToolbar: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        ViewThatFits {
            // 完整布局：所有按钮平铺显示
            fullLayout
            
            // 紧凑布局：部分按钮收起到"更多"菜单
            compactLayout
        }
    }
    
    // MARK: - 完整布局
    
    private var fullLayout: some View {
        HStack(spacing: 8) {
            // 格式按钮组
            FormatButtonGroup(store: store)
            
            Divider()
            
            // 标题菜单（阶段 2 实现）
            HeadingMenu(store: store)
            
            Divider()
            
            // 列表按钮组
            ListButtonGroup(store: store)
            
            Divider()
            
            // 插入按钮组
            InsertButtonGroup(store: store)
            
            Divider()
            
            // 星标按钮
            StarButton(store: store)
        }
    }
    
    // MARK: - 紧凑布局
    
    private var compactLayout: some View {
        HStack(spacing: 8) {
            // 格式按钮组（最常用，始终显示）
            FormatButtonGroup(store: store)
            
            Divider()
            
            // 标题菜单（常用，始终显示）
            HeadingMenu(store: store)
            
            Divider()
            
            // "更多"菜单（收起不常用的功能）
            Menu {
                Section("列表") {
                    Button("无序列表", systemImage: "list.bullet") {
                        store.send(.insertUnorderedList)
                    }
                    .keyboardShortcut("l", modifiers: .command)
                    
                    Button("有序列表", systemImage: "list.number") {
                        store.send(.insertOrderedList)
                    }
                    .keyboardShortcut("l", modifiers: [.command, .shift])
                    
                    Button("任务列表", systemImage: "checklist") {
                        store.send(.insertTaskList)
                    }
                    .keyboardShortcut("l", modifiers: [.command, .option])
                }
                
                Divider()
                
                Section("插入") {
                    Button("链接", systemImage: "link") {
                        store.send(.insertLink)
                    }
                    .keyboardShortcut("k", modifiers: .command)
                    
                    Button("代码块", systemImage: "curlybraces") {
                        store.send(.insertCodeBlock)
                    }
                    .keyboardShortcut("k", modifiers: [.command, .shift])
                }
                
                Divider()
                
                Section("笔记") {
                    Button("切换星标", systemImage: store.note?.isStarred ?? false ? "star.fill" : "star") {
                        store.send(.toggleStar)
                    }
                    .keyboardShortcut("d", modifiers: .command)
                    .disabled(store.note == nil)
                }
            } label: {
                Label("更多", systemImage: "ellipsis.circle")
                    .labelStyle(.iconOnly)
            }
            .help("更多格式选项")
        }
    }
}

// MARK: - 格式按钮组

struct FormatButtonGroup: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ControlGroup {
                ToolbarButton(
                    title: "加粗",
                    icon: "bold",
                    shortcut: "⌘B",
                    isActive: store.isBoldActive,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.formatBold)
                }
                
                ToolbarButton(
                    title: "斜体",
                    icon: "italic",
                    shortcut: "⌘I",
                    isActive: store.isItalicActive,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.formatItalic)
                }
                
                ToolbarButton(
                    title: "行内代码",
                    icon: "chevron.left.forwardslash.chevron.right",
                    shortcut: "⌘E",
                    isActive: store.isInlineCodeActive,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.formatInlineCode)
                }
                
                ToolbarButton(
                    title: "删除线",
                    icon: "strikethrough",
                    shortcut: "⌘⇧X",
                    isActive: store.isStrikethroughActive,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.formatStrikethrough)
                }
            }
        }
    }
}

// MARK: - 区块按钮组

struct BlockButtonGroup: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ControlGroup {
                ToolbarButton(
                    title: "区块引用",
                    icon: "quote.opening",
                    shortcut: "⌘⇧Q",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertBlockquote)
                }
                
                ToolbarButton(
                    title: "分隔线",
                    icon: "minus",
                    shortcut: "⌘⇧-",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertHorizontalRule)
                }
            }
        }
    }
}

// MARK: - 标题菜单

struct HeadingMenu: View {
    let store: StoreOf<EditorFeature>
    @State private var isHovered = false
    
    var body: some View {
        WithPerceptionTracking {
            Menu {
                Button("标题 1", systemImage: "h1.square") {
                    store.send(.insertHeading1)
                }
                .keyboardShortcut("1", modifiers: .command)
                
                Button("标题 2", systemImage: "h2.square") {
                    store.send(.insertHeading2)
                }
                .keyboardShortcut("2", modifiers: .command)
                
                Button("标题 3", systemImage: "h3.square") {
                    store.send(.insertHeading3)
                }
                .keyboardShortcut("3", modifiers: .command)
                
                Button("标题 4", systemImage: "h4.square") {
                    store.send(.insertHeading4)
                }
                .keyboardShortcut("4", modifiers: .command)
                
                Button("标题 5", systemImage: "h5.square") {
                    store.send(.insertHeading5)
                }
                .keyboardShortcut("5", modifiers: .command)
                
                Button("标题 6", systemImage: "h6.square") {
                    store.send(.insertHeading6)
                }
                .keyboardShortcut("6", modifiers: .command)
            } label: {
                Label("标题", systemImage: "textformat")
                    .labelStyle(.iconOnly)
                    .frame(width: 32, height: 32)
            }
            .help("插入标题（H1-H6）")
            .disabled(!store.isToolbarEnabled)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color(nsColor: .controlAccentColor).opacity(0.15) : Color.clear)
            )
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovered = hovering
            }
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
    }
}

// MARK: - 列表按钮组

struct ListButtonGroup: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ControlGroup {
                ToolbarButton(
                    title: "无序列表",
                    icon: "list.bullet",
                    shortcut: "⌘L",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertUnorderedList)
                }
                
                ToolbarButton(
                    title: "有序列表",
                    icon: "list.number",
                    shortcut: "⇧⌘L",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertOrderedList)
                }
                
                ToolbarButton(
                    title: "任务列表",
                    icon: "checklist",
                    shortcut: "⌥⌘L",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertTaskList)
                }
            }
        }
    }
}

// MARK: - 插入按钮组

struct InsertButtonGroup: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ControlGroup {
                ToolbarButton(
                    title: "链接",
                    icon: "link",
                    shortcut: "⌘K",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertLink)
                }
                
                ToolbarButton(
                    title: "代码块",
                    icon: "curlybraces",
                    shortcut: "⇧⌘K",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.insertCodeBlock)
                }
                
                ToolbarButton(
                    title: "插入图片",
                    icon: "photo",
                    shortcut: "⌘⇧I",
                    isActive: false,
                    isEnabled: store.isToolbarEnabled
                ) {
                    store.send(.showImagePicker)
                }
            }
        }
    }
}

// MARK: - 表格菜单

struct TableMenu: View {
    let store: StoreOf<EditorFeature>
    @State private var isHovered = false
    
    var body: some View {
        WithPerceptionTracking {
            Menu {
                Section("常用尺寸") {
                    Button("2x3 表格", systemImage: "tablecells") {
                        store.send(.insertTable(columns: 2, rows: 3))
                    }
                    
                    Button("3x4 表格", systemImage: "tablecells") {
                        store.send(.insertTable(columns: 3, rows: 4))
                    }
                    
                    Button("4x5 表格", systemImage: "tablecells") {
                        store.send(.insertTable(columns: 4, rows: 5))
                    }
                }
            } label: {
                Label("表格", systemImage: "tablecells")
                    .labelStyle(.iconOnly)
                    .frame(width: 32, height: 32)
            }
            .help("插入表格")
            .disabled(!store.isToolbarEnabled)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color(nsColor: .controlAccentColor).opacity(0.15) : Color.clear)
            )
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovered = hovering
            }
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
    }
}

// MARK: - 星标按钮

struct StarButton: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ToolbarButton(
                title: "切换星标",
                icon: store.note?.isStarred ?? false ? "star.fill" : "star",
                shortcut: "⌘D",
                isActive: store.note?.isStarred ?? false,
                isEnabled: store.isToolbarEnabled
            ) {
                store.send(.toggleStar)
            }
        }
    }
}

// MARK: - 可复用工具栏按钮

struct ToolbarButton: View {
    let title: String
    let icon: String
    let shortcut: String
    let isActive: Bool
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
        .help("\(title) \(shortcut)")
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(.easeInOut(duration: 0.15), value: isActive)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return Color.clear
        }
        if isActive {
            return Color.accentColor.opacity(0.15)
        }
        if isHovered {
            // 增强 hover 效果，使用更明显的背景色
            return Color(nsColor: .controlAccentColor).opacity(0.15)
        }
        return Color.clear
    }
    
    private var foregroundColor: Color {
        if !isEnabled {
            return Color.secondary.opacity(0.4)
        }
        if isActive {
            return Color.accentColor
        }
        return Color.primary
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            VStack {
                MarkdownToolbar(
                    store: Store(initialState: EditorFeature.State()) {
                        EditorFeature()
                    }
                )
                .padding()
                
                Spacer()
                
                Text("工具栏预览")
                    .font(.headline)
                
                Spacer()
            }
        }
    }
    
    return PreviewWrapper()
}


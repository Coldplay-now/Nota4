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
        ControlGroup {
            ToolbarButton(
                title: "加粗",
                icon: "bold",
                shortcut: "⌘B"
            ) {
                store.send(.formatBold)
            }
            .disabled(store.note == nil)
            
            ToolbarButton(
                title: "斜体",
                icon: "italic",
                shortcut: "⌘I"
            ) {
                store.send(.formatItalic)
            }
            .disabled(store.note == nil)
            
            ToolbarButton(
                title: "行内代码",
                icon: "chevron.left.forwardslash.chevron.right",
                shortcut: "⌘E"
            ) {
                store.send(.formatInlineCode)
            }
            .disabled(store.note == nil)
        }
    }
}

// MARK: - 标题菜单

struct HeadingMenu: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
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
        } label: {
            Label("标题", systemImage: "h.square")
                .labelStyle(.iconOnly)
        }
        .help("插入标题（H1/H2/H3）")
        .disabled(store.note == nil)
    }
}

// MARK: - 列表按钮组

struct ListButtonGroup: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        ControlGroup {
            ToolbarButton(
                title: "无序列表",
                icon: "list.bullet",
                shortcut: "⌘L"
            ) {
                store.send(.insertUnorderedList)
            }
            .disabled(store.note == nil)
            
            ToolbarButton(
                title: "有序列表",
                icon: "list.number",
                shortcut: "⇧⌘L"
            ) {
                store.send(.insertOrderedList)
            }
            .disabled(store.note == nil)
            
            ToolbarButton(
                title: "任务列表",
                icon: "checklist",
                shortcut: "⌥⌘L"
            ) {
                store.send(.insertTaskList)
            }
            .disabled(store.note == nil)
        }
    }
}

// MARK: - 插入按钮组

struct InsertButtonGroup: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        ControlGroup {
            ToolbarButton(
                title: "链接",
                icon: "link",
                shortcut: "⌘K"
            ) {
                store.send(.insertLink)
            }
            .disabled(store.note == nil)
            
            ToolbarButton(
                title: "代码块",
                icon: "curlybraces",
                shortcut: "⇧⌘K"
            ) {
                store.send(.insertCodeBlock)
            }
            .disabled(store.note == nil)
        }
    }
}

// MARK: - 星标按钮

struct StarButton: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        ToolbarButton(
            title: "切换星标",
            icon: store.note?.isStarred ?? false ? "star.fill" : "star",
            shortcut: "⌘D"
        ) {
            store.send(.toggleStar)
        }
        .disabled(store.note == nil)
    }
}

// MARK: - 可复用工具栏按钮

struct ToolbarButton: View {
    let title: String
    let icon: String
    let shortcut: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .labelStyle(.iconOnly)
        }
        .help("\(title) \(shortcut)")
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


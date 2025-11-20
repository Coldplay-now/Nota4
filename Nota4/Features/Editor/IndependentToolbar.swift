import SwiftUI
import ComposableArchitecture

// MARK: - 独立工具栏容器

/// 独立工具栏组件
/// 位于编辑器内容区域顶部，提供 Markdown 格式化工具
struct IndependentToolbar: View {
    let store: StoreOf<EditorFeature>
    @State private var availableWidth: CGFloat = 0
    
    var body: some View {
        WithPerceptionTracking {
            HStack(spacing: 12) {
                // 预览模式下隐藏所有编辑按钮，只显示视图模式切换
                if store.viewMode != .previewOnly {
                    // 搜索按钮
                    NoteListToolbarButton(
                        title: store.search.isSearchPanelVisible ? "关闭搜索" : "搜索",
                        icon: store.search.isSearchPanelVisible ? "xmark.circle.fill" : "magnifyingglass",
                        shortcut: "⌘F",
                        isEnabled: store.note != nil
                    ) {
                        store.send(.search(.toggleSearchPanel))
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    // 核心工具：始终显示
                    FormatButtonGroup(store: store)
                    
                    Divider()
                        .frame(height: 20)
                    
                    HeadingMenu(store: store)
                    
                    // 扩展工具：根据空间显示
                    if availableWidth > 400 {
                        Divider()
                            .frame(height: 20)
                        
                        ListButtonGroup(store: store)
                    }
                    
                    if availableWidth > 550 {
                        Divider()
                            .frame(height: 20)
                        
                        InsertButtonGroup(store: store)
                        
                        Divider()
                            .frame(height: 20)
                        
                        TableMenu(store: store)
                    }
                    
                    // 区块按钮组：根据空间显示
                    if availableWidth > 650 {
                        Divider()
                            .frame(height: 20)
                        
                        BlockButtonGroup(store: store)
                    }
                    
                    // 更多菜单
                    Divider()
                        .frame(height: 20)
                    
                    MoreMenu(store: store, hiddenTools: availableWidth < 400)
                }
                
                Spacer()
                
                // 视图模式切换：始终显示
                ViewModeControl(store: store)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(height: 44)
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

// MARK: - 更多菜单

struct MoreMenu: View {
    let store: StoreOf<EditorFeature>
    let hiddenTools: Bool  // 是否隐藏了列表和插入工具
    @State private var isHovered = false
    
    var body: some View {
        WithPerceptionTracking {
            Menu {
                if hiddenTools {
                    Section("列表") {
                        Button("无序列表", systemImage: "list.bullet") {
                            store.send(.insertUnorderedList)
                        }
                        .keyboardShortcut("l", modifiers: .command)
                        
                        Button("有序列表", systemImage: "list.number") {
                            store.send(.insertOrderedList)
                        }
                        .keyboardShortcut("l", modifiers: [.command, .option])
                        
                        Button("任务列表", systemImage: "checklist") {
                            store.send(.insertTaskList)
                        }
                        .keyboardShortcut("l", modifiers: [.command, .option, .shift])
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
                        
                        Button("跨行代码块", systemImage: "curlybraces.square") {
                            store.send(.insertCodeBlockWithLanguage)
                        }
                        .keyboardShortcut("k", modifiers: [.command, .option])
                    }
                    
                    Divider()
                }
                
                Section("插入") {
                    Button("插入附件", systemImage: "paperclip") {
                        store.send(.showAttachmentPicker)
                    }
                    .keyboardShortcut("a", modifiers: [.command, .shift])
                }
                
                Divider()
                
                Section("格式") {
                    Button("下划线", systemImage: "underline") {
                        store.send(.formatUnderline)
                    }
                    .keyboardShortcut("u", modifiers: [.command, .shift])
                    
                    Button("脚注", systemImage: "textformat.superscript") {
                        store.send(.insertFootnote(footnoteNumber: store.footnoteCounter))
                    }
                    
                    Button("行内公式", systemImage: "function") {
                        store.send(.insertInlineMath)
                    }
                    
                    Button("行间公式", systemImage: "function") {
                        store.send(.insertBlockMath)
                    }
                }
                
                Divider()
                
                Section("笔记") {
                    Button("切换星标", systemImage: store.note?.isStarred ?? false ? "star.fill" : "star") {
                        store.send(.toggleStar)
                    }
                    .keyboardShortcut("d", modifiers: .command)
                    .disabled(store.note == nil)
                    
                    Button("切换置顶", systemImage: store.note?.isPinned ?? false ? "pin.fill" : "pin") {
                        store.send(.togglePin)
                    }
                    .keyboardShortcut("p", modifiers: [.command, .shift])
                    .disabled(store.note == nil)
                }
                
                Divider()
                
                Section("导出") {
                    Button("导出为 .nota") {
                        store.send(.exportCurrentNote(.nota))
                    }
                    .disabled(store.note == nil)
                    
                    Button("导出为 .md") {
                        store.send(.exportCurrentNote(.markdown))
                    }
                    .disabled(store.note == nil)
                    
                    Button("导出为 .html") {
                        store.send(.exportCurrentNote(.html))
                    }
                    .disabled(store.note == nil)
                    
                    Button("导出为 .pdf") {
                        store.send(.exportCurrentNote(.pdf))
                    }
                    .disabled(store.note == nil)
                    
                    Button("导出为 .png") {
                        store.send(.exportCurrentNote(.png))
                    }
                    .disabled(store.note == nil)
                }
            } label: {
                Label("更多", systemImage: "ellipsis.circle")
                    .labelStyle(.iconOnly)
                    .frame(width: 32, height: 32)
            }
            .help("更多格式选项")
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


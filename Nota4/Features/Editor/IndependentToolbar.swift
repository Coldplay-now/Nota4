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
            .frame(height: 48)
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
                }
                
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
                    .frame(width: 32, height: 32)
            }
            .help("更多格式选项")
            .disabled(!store.isToolbarEnabled)
        }
    }
}


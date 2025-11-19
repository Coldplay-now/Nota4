import SwiftUI
import ComposableArchitecture

/// 编辑器右键菜单
struct EditorContextMenu: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        Group {
            // MARK: - Markdown 格式
            
            Button("加粗", systemImage: "bold") {
                store.send(.formatBold)
            }
            .keyboardShortcut("b", modifiers: .command)
            
            Button("斜体", systemImage: "italic") {
                store.send(.formatItalic)
            }
            .keyboardShortcut("i", modifiers: .command)
            
            Button("行内代码", systemImage: "chevron.left.forwardslash.chevron.right") {
                store.send(.formatInlineCode)
            }
            .keyboardShortcut("e", modifiers: .command)
            
            Divider()
            
            // MARK: - 标题
            
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
            
            Divider()
            
            // MARK: - 列表
            
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
            
            Divider()
            
            // MARK: - 插入
            
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
            
            Divider()
            
            // MARK: - 笔记操作
            
            Button("切换星标", systemImage: "star") {
                store.send(.toggleStar)
            }
            .keyboardShortcut("d", modifiers: .command)
            .disabled(store.note == nil)
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            Text("Right-click me")
                .frame(width: 300, height: 200)
                .contextMenu {
                    EditorContextMenu(
                        store: Store(initialState: EditorFeature.State()) {
                            EditorFeature()
                        }
                    )
                }
        }
    }
    
    return PreviewWrapper()
}









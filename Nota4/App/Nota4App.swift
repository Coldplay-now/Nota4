import SwiftUI
import ComposableArchitecture

@main
struct Nota4App: App {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建笔记") {
                    store.send(.editor(.createNote))
                }
                .keyboardShortcut("n")
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationSplitView(
                columnVisibility: Binding(
                    get: { store.columnVisibility },
                    set: { store.send(.columnVisibilityChanged($0)) }
                )
            ) {
                // 侧边栏
                SidebarView(
                    store: store.scope(state: \.sidebar, action: \.sidebar)
                )
                .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
            } content: {
                // 笔记列表
                NoteListView(
                    store: store.scope(state: \.noteList, action: \.noteList)
                )
                .navigationSplitViewColumnWidth(min: 280, ideal: 350, max: 500)
            } detail: {
                // 编辑器
                NoteEditorView(
                    store: store.scope(state: \.editor, action: \.editor)
                )
            }
            .navigationSplitViewStyle(.balanced)
            .frame(minWidth: 800, minHeight: 600)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}


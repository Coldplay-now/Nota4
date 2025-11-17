import SwiftUI
import ComposableArchitecture

@main
struct Nota4App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store, appDelegate: appDelegate)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建笔记") {
                    store.send(.editor(.createNote))
                }
                .keyboardShortcut("n")
            }
            
            CommandGroup(after: .newItem) {
                Button("保存") {
                    store.send(.editor(.manualSave))
                }
                .keyboardShortcut("s")
                
                Divider()
                
                Button("导入笔记...") {
                    store.send(.showImport)
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])
                
                Button("导出笔记...") {
                    // 导出当前选中的笔记或所有笔记
                    store.send(.showExport([]))
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }
            
            CommandGroup(after: .appSettings) {
                Button("首选项...") {
                    store.send(.showSettings)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
            
            // MARK: - Search Commands
            
            CommandGroup(after: .textEditing) {
                Button("查找") {
                    store.send(.editor(.search(.showSearchPanel)))
                }
                .keyboardShortcut("f", modifiers: .command)
                
                Button("查找并替换") {
                    store.send(.editor(.search(.toggleReplaceMode)))
                    if !store.editor.search.isSearchPanelVisible {
                        store.send(.editor(.search(.showSearchPanel)))
                    }
                }
                .keyboardShortcut("f", modifiers: [.command, .option])
                
                Divider()
                
                Button("查找下一个") {
                    store.send(.editor(.search(.findNext)))
                }
                .keyboardShortcut("g", modifiers: .command)
                
                Button("查找上一个") {
                    store.send(.editor(.search(.findPrevious)))
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
                
                Divider()
                
                Button("替换") {
                    store.send(.editor(.search(.replaceCurrent)))
                }
                .keyboardShortcut("e", modifiers: [.command, .option])
                
                Button("全部替换") {
                    store.send(.editor(.search(.replaceAll)))
                }
                .keyboardShortcut("e", modifiers: [.command, .option, .shift])
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    let appDelegate: AppDelegate
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // 主内容区域
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
                    .navigationSplitViewColumnWidth(min: 280, ideal: 280, max: 500)
            } detail: {
                // 编辑器
                NoteEditorView(
                    store: store.scope(state: \.editor, action: \.editor)
                )
                    // 不设置最小宽度，让编辑器区域灵活适应窗口大小
            }
            .navigationSplitViewStyle(.balanced)
                
                // 状态栏
                StatusBarView(store: store)
            }
            .frame(minWidth: 800, minHeight: 622)
            .onAppear {
                // 设置 AppDelegate 的 store 引用
                appDelegate.store = store
                store.send(.onAppear)
            }
            .sheet(isPresented: Binding(
                get: { store.importFeature != nil },
                set: { if !$0 { store.send(.dismissImport) } }
            )) {
                if let importStore = store.scope(state: \.importFeature, action: \.importFeature) {
                    ImportView(store: importStore)
                }
            }
            .sheet(isPresented: Binding(
                get: { store.exportFeature != nil },
                set: { if !$0 { store.send(.dismissExport) } }
            )) {
                if let exportStore = store.scope(state: \.exportFeature, action: \.exportFeature) {
                    ExportView(store: exportStore)
                }
            }
            .sheet(isPresented: Binding(
                get: { store.settingsFeature != nil },
                set: { if !$0 { store.send(.dismissSettings) } }
            )) {
                if let settingsStore = store.scope(state: \.settingsFeature, action: \.settingsFeature.presented) {
                    SettingsView(store: settingsStore)
                }
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        },
        appDelegate: AppDelegate()
    )
}


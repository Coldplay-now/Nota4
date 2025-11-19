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
                    // 如果有选中的笔记，导出选中的；否则导出当前笔记或所有笔记
                    let selectedNotes = store.noteList.notes.filter { store.noteList.selectedNoteIds.contains($0.noteId) }
                    if !selectedNotes.isEmpty {
                        store.send(.showExport(selectedNotes))
                    } else if let currentNote = store.editor.note {
                        store.send(.showExport([currentNote]))
                    } else {
                    store.send(.showExport([]))
                    }
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
            
            // MARK: - View Commands (Layout Mode)
            
            CommandMenu("视图") {
                Menu("布局模式") {
                    Button("三栏（分类 + 列表 + 编辑）") {
                        store.send(.layoutModeChanged(.threeColumn))
                    }
                    .keyboardShortcut("1", modifiers: [.command, .shift])
                    
                    Button("两栏（列表 + 编辑）") {
                        store.send(.layoutModeChanged(.twoColumn))
                    }
                    .keyboardShortcut("2", modifiers: [.command, .shift])
                    
                    Button("一栏（仅编辑）") {
                        store.send(.layoutModeChanged(.oneColumn))
                    }
                    .keyboardShortcut("3", modifiers: [.command, .shift])
                }
                
                Divider()
                
                // 快速切换按钮（循环切换）
                Button("切换布局模式") {
                    let nextMode: LayoutMode = switch store.layoutMode {
                    case .threeColumn: .twoColumn
                    case .twoColumn: .oneColumn
                    case .oneColumn: .threeColumn
                    }
                    store.send(.layoutModeChanged(nextMode))
                    }
                .keyboardShortcut("l", modifiers: [.command, .shift])
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
                // 根据布局模式选择不同的布局结构
                Group {
                    if store.layoutMode == .oneColumn {
                        // 一栏模式：直接显示编辑器，不使用 NavigationSplitView
                        oneColumnLayout
                    } else {
                        // 两栏/三栏模式：使用 NavigationSplitView
                        multiColumnLayout
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: store.layoutMode)
                .transition(.opacity)
                
                // 状态栏
                StatusBarView(store: store)
            }
            .frame(minWidth: minWindowWidth, minHeight: 622)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onChange(of: geometry.size.width) { oldValue, newValue in
                            // 根据窗口大小自动调整布局
                            autoAdjustLayoutForWindowWidth(newValue)
                        }
                }
            )
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
    
    // MARK: - Layout Views
    
    // 一栏布局
    private var oneColumnLayout: some View {
        NoteEditorView(
            store: store.scope(state: \.editor, action: \.editor)
        )
    }
    
    // 多栏布局
    private var multiColumnLayout: some View {
        NavigationSplitView(
            columnVisibility: Binding(
                get: { 
                    // 返回当前布局模式对应的 columnVisibility
                    store.layoutMode.columnVisibility
                },
                set: { newVisibility in
                    // 如果正在切换布局，忽略用户拖拽
                    if !store.isLayoutTransitioning {
                        // 当用户手动拖拽调整布局时，同步更新状态
                        // 只有当新的 visibility 与当前 layoutMode 的 columnVisibility 不同时，才认为是用户手动调整
                        if newVisibility != store.layoutMode.columnVisibility {
                            store.send(.columnVisibilityChanged(newVisibility))
                        }
                    }
                }
            )
        ) {
            // 侧边栏（所有模式都需要，NavigationSplitView 会自动控制显示/隐藏）
            SidebarView(
                store: store.scope(state: \.sidebar, action: \.sidebar)
            )
            .navigationSplitViewColumnWidth(
                min: store.columnWidths.sidebarMin,
                ideal: getSidebarIdealWidth(),
                max: store.columnWidths.sidebarMax
            )
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ColumnWidthKey.self,
                        value: geometry.size.width
                    )
                }
            )
            .onPreferenceChange(ColumnWidthKey.self) { width in
                // 用户拖拽调整宽度时，保存到状态
                if !store.isLayoutTransitioning && width > 0 {
                    store.send(.columnWidthAdjusted(sidebar: width, list: nil))
                }
            }
            // 移除 .toolbar 修饰符，避免在 .hiddenTitleBar 模式下创建工具栏区域
            // 工具栏区域会延伸到窗口顶部，视觉上包裹窗口控制按钮
        } content: {
            // 笔记列表（所有模式都需要，NavigationSplitView 会自动控制显示/隐藏）
            NoteListView(
                store: store.scope(state: \.noteList, action: \.noteList)
            )
            .navigationSplitViewColumnWidth(
                min: store.columnWidths.listMin,
                ideal: getListIdealWidth(),
                max: store.columnWidths.listMax
            )
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ColumnWidthKey.self,
                        value: geometry.size.width
                    )
                }
            )
            .onPreferenceChange(ColumnWidthKey.self) { width in
                // 用户拖拽调整宽度时，保存到状态
                if !store.isLayoutTransitioning && width > 0 {
                    store.send(.columnWidthAdjusted(sidebar: nil, list: width))
                }
            }
        } detail: {
            // 编辑器（所有模式都显示）
            NoteEditorView(
                store: store.scope(state: \.editor, action: \.editor)
            )
            // 不设置最小宽度，让编辑器区域灵活适应窗口大小
        }
        .navigationSplitViewStyle(.balanced)
        .padding(0)  // 移除默认内边距，让内容贴近窗口边缘（方案一：紧凑型布局）
    }
    
    // 获取侧边栏理想宽度
    private func getSidebarIdealWidth() -> CGFloat {
        switch store.layoutMode {
        case .threeColumn:
            return store.columnWidths.threeColumnWidths.sidebar ?? 200
        case .twoColumn, .oneColumn:
            return 200  // 两栏和一栏模式不使用侧边栏
        }
    }
    
    // 获取列表理想宽度
    private func getListIdealWidth() -> CGFloat {
        switch store.layoutMode {
        case .threeColumn:
            return store.columnWidths.threeColumnWidths.list ?? 280
        case .twoColumn:
            return store.columnWidths.twoColumnWidths ?? 280
        case .oneColumn:
            return 280  // 一栏模式不使用列表
        }
    }
    
    // 动态最小宽度
    private var minWindowWidth: CGFloat {
        switch store.layoutMode {
        case .threeColumn: return 1000
        case .twoColumn: return 700
        case .oneColumn: return 500
        }
    }
    
    // 根据窗口宽度自动调整布局
    private func autoAdjustLayoutForWindowWidth(_ width: CGFloat) {
        // 如果正在切换布局，不自动调整
        if store.isLayoutTransitioning {
            return
        }
        
        // 避免频繁切换（添加最小时间间隔检查）
        // 这里简化处理，实际可以使用更复杂的防抖逻辑
        
        let currentMode = store.layoutMode
        
        // 窗口宽度 < 1000pt 且当前为三栏模式，自动切换到两栏
        if width < 1000 && currentMode == .threeColumn {
            store.send(.layoutModeChanged(.twoColumn))
        }
        // 窗口宽度 < 600pt 且当前为两栏模式，自动切换到一栏
        else if width < 600 && currentMode == .twoColumn {
            store.send(.layoutModeChanged(.oneColumn))
        }
        // 窗口宽度 >= 1000pt 且当前为一栏模式，可以切换到两栏（可选）
        // 这里不自动切换，让用户手动选择
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


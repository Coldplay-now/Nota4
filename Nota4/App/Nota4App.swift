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
                Button("打开...") {
                    store.send(.showImport)
                }
                .keyboardShortcut("o", modifiers: .command)
                
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
                
                Divider()
                
                Button("关闭窗口") {
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut("w", modifiers: .command)
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
            
            // MARK: - Format Commands
            
            CommandMenu("格式") {
                // 文本格式
                Button("加粗") {
                    store.send(.editor(.formatBold))
                }
                .keyboardShortcut("b", modifiers: .command)
                
                Button("斜体") {
                    store.send(.editor(.formatItalic))
                }
                .keyboardShortcut("i", modifiers: .command)
                
                Button("下划线") {
                    store.send(.editor(.formatUnderline))
                }
                .keyboardShortcut("u", modifiers: [.command, .shift])
                
                Button("删除线") {
                    store.send(.editor(.formatStrikethrough))
                }
                .keyboardShortcut("x", modifiers: [.command, .shift])
                
                Divider()
                
                // 标题子菜单
                Menu("标题") {
                    Button("标题 1") {
                        store.send(.editor(.insertHeading1))
                    }
                    .keyboardShortcut("1", modifiers: [.command, .option])
                    
                    Button("标题 2") {
                        store.send(.editor(.insertHeading2))
                    }
                    .keyboardShortcut("2", modifiers: [.command, .option])
                    
                    Button("标题 3") {
                        store.send(.editor(.insertHeading3))
                    }
                    .keyboardShortcut("3", modifiers: [.command, .option])
                    
                    Button("标题 4") {
                        store.send(.editor(.insertHeading4))
                    }
                    .keyboardShortcut("4", modifiers: [.command, .option])
                    
                    Button("标题 5") {
                        store.send(.editor(.insertHeading5))
                    }
                    .keyboardShortcut("5", modifiers: [.command, .option])
                    
                    Button("标题 6") {
                        store.send(.editor(.insertHeading6))
                    }
                    .keyboardShortcut("6", modifiers: [.command, .option])
                }
                
                Divider()
                
                // 列表子菜单
                Menu("列表") {
                    Button("无序列表") {
                        store.send(.editor(.insertUnorderedList))
                    }
                    .keyboardShortcut("l", modifiers: .command)
                    
                    Button("有序列表") {
                        store.send(.editor(.insertOrderedList))
                    }
                    .keyboardShortcut("l", modifiers: [.command, .option])
                    
                    Button("任务列表") {
                        store.send(.editor(.insertTaskList))
                    }
                    .keyboardShortcut("l", modifiers: [.command, .option, .shift])
                }
                
                Divider()
                
                // 插入子菜单
                Menu("插入") {
                    Button("链接") {
                        store.send(.editor(.insertLink))
                    }
                    .keyboardShortcut("k", modifiers: .command)
                    
                    Button("代码块") {
                        store.send(.editor(.insertCodeBlock))
                    }
                    .keyboardShortcut("k", modifiers: [.command, .shift])
                    
                    Button("跨行代码块") {
                        store.send(.editor(.insertCodeBlockWithLanguage))
                    }
                    .keyboardShortcut("k", modifiers: [.command, .option])
                    
                    Button("行内代码") {
                        store.send(.editor(.formatInlineCode))
                    }
                    .keyboardShortcut("e", modifiers: .command)
                    
                    Button("区块引用") {
                        store.send(.editor(.insertBlockquote))
                    }
                    .keyboardShortcut("q", modifiers: [.command, .shift])
                    
                    Button("分隔线") {
                        store.send(.editor(.insertHorizontalRule))
                    }
                    .keyboardShortcut("-", modifiers: [.command, .shift])
                }
                
                Divider()
                
                Button("插入附件") {
                    store.send(.editor(.showAttachmentPicker))
                }
                .keyboardShortcut("a", modifiers: [.command, .shift])
            }
            
            // MARK: - Note Commands
            
            CommandMenu("笔记") {
                // 获取当前笔记和状态
                let currentNote = store.editor.note
                let selectedNoteId = store.noteList.selectedNoteId
                let selectedNoteIds = store.noteList.selectedNoteIds
                
                // 判断是否在废纸篓视图
                let isInTrash: Bool = {
                    if case .category(let category) = store.noteList.filter {
                        return category == .trash
                    }
                    return false
                }()
                
                // 获取目标笔记（优先使用编辑器中的笔记，其次使用选中的笔记）
                let targetNote: Note? = {
                    if let note = currentNote {
                        return note
                    } else if let noteId = selectedNoteId {
                        return store.noteList.notes.first { $0.noteId == noteId }
                    }
                    return nil
                }()
                
                // 判断目标笔记是否已删除
                let isNoteDeleted = targetNote?.isDeleted ?? false
                
                // 判断是否有可操作的笔记
                let hasNotes: Bool = {
                    if currentNote != nil || selectedNoteId != nil {
                        return true
                    }
                    return !selectedNoteIds.isEmpty
                }()
                
                // 星标/取消星标
                Button(targetNote?.isStarred == true ? "取消星标" : "星标笔记") {
                    if let noteId = currentNote?.noteId {
                        store.send(.noteList(.toggleStar(noteId)))
                    } else if let noteId = selectedNoteId {
                        store.send(.noteList(.toggleStar(noteId)))
                    }
                }
                .keyboardShortcut("d", modifiers: .command)
                .disabled(!hasNotes || isInTrash || isNoteDeleted)
                
                // 置顶/取消置顶
                Button(targetNote?.isPinned == true ? "取消置顶" : "置顶笔记") {
                    if let noteId = currentNote?.noteId {
                        store.send(.noteList(.togglePin(noteId)))
                    } else if let noteId = selectedNoteId {
                        store.send(.noteList(.togglePin(noteId)))
                    }
                }
                .keyboardShortcut("p", modifiers: [.command, .shift])
                .disabled(!hasNotes || isInTrash || isNoteDeleted)
                
                Divider()
                
                // 恢复笔记（仅在废纸篓中可用）
                Button("恢复") {
                    let noteIds: Set<String>
                    if let noteId = currentNote?.noteId {
                        noteIds = [noteId]
                    } else if let noteId = selectedNoteId {
                        noteIds = [noteId]
                    } else {
                        noteIds = selectedNoteIds
                    }
                    if !noteIds.isEmpty {
                        store.send(.noteList(.restoreNotes(noteIds)))
                    }
                }
                .keyboardShortcut(.delete, modifiers: .command)
                .disabled(!hasNotes || (!isInTrash && !isNoteDeleted))
                
                // 移至废纸篓
                Button("移至废纸篓") {
                    let noteIds: Set<String>
                    if let noteId = currentNote?.noteId {
                        noteIds = [noteId]
                    } else if let noteId = selectedNoteId {
                        noteIds = [noteId]
                    } else {
                        noteIds = selectedNoteIds
                    }
                    if !noteIds.isEmpty {
                        store.send(.noteList(.deleteNotes(noteIds)))
                    }
                }
                .keyboardShortcut(.delete, modifiers: .command)
                .disabled(!hasNotes || isInTrash || isNoteDeleted)
                
                // 永久删除（仅在废纸篓中可用）
                Button("永久删除") {
                    let noteIds: Set<String>
                    if let noteId = currentNote?.noteId {
                        noteIds = [noteId]
                    } else if let noteId = selectedNoteId {
                        noteIds = [noteId]
                    } else {
                        noteIds = selectedNoteIds
                    }
                    if !noteIds.isEmpty {
                        store.send(.noteList(.permanentlyDeleteNotes(noteIds)))
                    }
                }
                .keyboardShortcut(.delete, modifiers: [.command, .shift])
                .disabled(!hasNotes || (!isInTrash && !isNoteDeleted))
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
                
                Divider()
                
                Button("进入全屏") {
                    NSApplication.shared.keyWindow?.toggleFullScreen(nil)
                }
                .keyboardShortcut("f", modifiers: [.control, .command])
            }
            
            // MARK: - Window Commands
            
            CommandGroup(replacing: .windowArrangement) {
                Button("最小化") {
                    NSApplication.shared.keyWindow?.miniaturize(nil)
                }
                .keyboardShortcut("m", modifiers: .command)
                
                Button("缩放") {
                    NSApplication.shared.keyWindow?.zoom(nil)
                }
            }
            
            CommandGroup(after: .windowArrangement) {
                Button("前置全部窗口") {
                    NSApplication.shared.arrangeInFront(nil)
                }
            }
            
            // MARK: - Help Commands
            
            CommandGroup(replacing: .help) {
                Button("Nota4 帮助") {
                    Task {
                        print("🔄 [HELP] 用户点击帮助菜单")
                        // 获取帮助文档 HTML URL
                        let helpURL = await HelpDocumentService.shared.getHelpHTMLURL()
                        
                        if let url = helpURL {
                            print("✅ [HELP] 打开帮助文档: \(url.path)")
                            // 打开 HTML 文件
                            NSWorkspace.shared.open(url)
                        } else {
                            print("⚠️ [HELP] 无法获取帮助文档 URL，回退到 GitHub")
                            // 回退：打开 GitHub 仓库
                            if let githubURL = URL(string: "https://github.com/Coldplay-now/Nota4") {
                                NSWorkspace.shared.open(githubURL)
                            }
                        }
                    }
                }
                .keyboardShortcut("?", modifiers: .command)
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    let appDelegate: AppDelegate
    
    var body: some View {
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


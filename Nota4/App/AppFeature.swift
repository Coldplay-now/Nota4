import ComposableArchitecture
import SwiftUI

// MARK: - Column Widths

struct ColumnWidths: Equatable {
    var sidebarWidth: CGFloat? = nil      // nil 表示使用默认值
    var listWidth: CGFloat? = nil
    var sidebarMin: CGFloat = 180
    var sidebarMax: CGFloat = 250
    var listMin: CGFloat = 280
    var listMax: CGFloat = 500
    
    // 为不同布局模式保存不同的宽度
    var threeColumnWidths: (sidebar: CGFloat?, list: CGFloat?) = (nil, nil)
    var twoColumnWidths: CGFloat? = nil  // 两栏模式只保存列表宽度
    
    // 手动实现 Equatable，因为元组不能自动合成
    static func == (lhs: ColumnWidths, rhs: ColumnWidths) -> Bool {
        return lhs.sidebarWidth == rhs.sidebarWidth &&
               lhs.listWidth == rhs.listWidth &&
               lhs.sidebarMin == rhs.sidebarMin &&
               lhs.sidebarMax == rhs.sidebarMax &&
               lhs.listMin == rhs.listMin &&
               lhs.listMax == rhs.listMax &&
               lhs.threeColumnWidths.sidebar == rhs.threeColumnWidths.sidebar &&
               lhs.threeColumnWidths.list == rhs.threeColumnWidths.list &&
               lhs.twoColumnWidths == rhs.twoColumnWidths
    }
}

// MARK: - Layout Mode

enum LayoutMode: String, Equatable, CaseIterable {
    case threeColumn = "三栏"
    case twoColumn = "两栏"
    case oneColumn = "一栏"
    
    var icon: String {
        switch self {
        case .threeColumn: return "rectangle.split.3x1"
        case .twoColumn: return "rectangle.split.2x1"
        case .oneColumn: return "rectangle"
        }
    }
    
    var description: String {
        switch self {
        case .threeColumn: return "分类 + 列表 + 编辑"
        case .twoColumn: return "列表 + 编辑"
        case .oneColumn: return "仅编辑"
        }
    }
    
    // 转换为 NavigationSplitViewVisibility
    var columnVisibility: NavigationSplitViewVisibility {
        switch self {
        case .threeColumn: return .all
        case .twoColumn: return .doubleColumn
        case .oneColumn: return .detailOnly
        }
    }
    
    // 从 NavigationSplitViewVisibility 创建
    static func from(_ visibility: NavigationSplitViewVisibility) -> LayoutMode {
        switch visibility {
        case .all: return .threeColumn
        case .doubleColumn: return .twoColumn
        case .detailOnly: return .oneColumn
        case .automatic: return .threeColumn  // 默认三栏
        default: return .threeColumn
        }
    }
}

// MARK: - App State Extension

extension AppFeature.State {
    // 计算属性：从 layoutMode 计算 columnVisibility
    var columnVisibility: NavigationSplitViewVisibility {
        switch layoutMode {
        case .threeColumn: return .all
        case .twoColumn: return .doubleColumn
        case .oneColumn: return .detailOnly  // 虽然 macOS 上可能不生效，但保留用于兼容
        }
    }
    
    // 判断是否应该使用条件渲染（一栏模式）
    var shouldUseConditionalRendering: Bool {
        return layoutMode == .oneColumn
    }
}

// MARK: - Helper Functions

func loadColumnWidthsFromUserDefaults(for mode: LayoutMode, into columnWidths: inout ColumnWidths) {
    switch mode {
    case .threeColumn:
        if let sidebarWidth = UserDefaults.standard.object(forKey: "columnWidths_三栏_sidebar") as? CGFloat {
            columnWidths.threeColumnWidths.sidebar = sidebarWidth
        }
        if let listWidth = UserDefaults.standard.object(forKey: "columnWidths_三栏_list") as? CGFloat {
            columnWidths.threeColumnWidths.list = listWidth
        }
    case .twoColumn:
        if let listWidth = UserDefaults.standard.object(forKey: "columnWidths_两栏_list") as? CGFloat {
            columnWidths.twoColumnWidths = listWidth
        }
    case .oneColumn:
        break
    }
}

// MARK: - App State

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var sidebar = SidebarFeature.State()
        var noteList = NoteListFeature.State()
        var editor = EditorFeature.State()
        var importFeature: ImportFeature.State?
        var exportFeature: ExportFeature.State?
        @Presents var settingsFeature: SettingsFeature.State?
        var layoutMode: LayoutMode = .threeColumn  // 布局模式（单一数据源）
        var isLayoutTransitioning: Bool = false   // 布局切换状态标记
        var columnWidths: ColumnWidths = ColumnWidths()  // 用户自定义宽度
        var preferences = EditorPreferences()
        
        init() {
            // 从 UserDefaults 加载保存的布局模式
            if let savedMode = UserDefaults.standard.string(forKey: "layoutMode"),
               let mode = LayoutMode(rawValue: savedMode) {
                self.layoutMode = mode
            }
            
            // 加载保存的宽度设置
            loadColumnWidths()
        }
        
        // 加载保存的宽度设置
        mutating func loadColumnWidths() {
            // 加载三栏模式宽度
            if let sidebarWidth = UserDefaults.standard.object(forKey: "columnWidths_三栏_sidebar") as? CGFloat {
                columnWidths.threeColumnWidths.sidebar = sidebarWidth
            }
            if let listWidth = UserDefaults.standard.object(forKey: "columnWidths_三栏_list") as? CGFloat {
                columnWidths.threeColumnWidths.list = listWidth
            }
            
            // 加载两栏模式宽度
            if let listWidth = UserDefaults.standard.object(forKey: "columnWidths_两栏_list") as? CGFloat {
                columnWidths.twoColumnWidths = listWidth
            }
        }
    }
    
    // MARK: - App Action
    
    enum Action {
        case sidebar(SidebarFeature.Action)
        case noteList(NoteListFeature.Action)
        case editor(EditorFeature.Action)
        case importFeature(ImportFeature.Action)
        case exportFeature(ExportFeature.Action)
        case settingsFeature(PresentationAction<SettingsFeature.Action>)
        case onAppear
        case layoutModeChanged(LayoutMode)  // 布局模式切换
        case layoutTransitionStarted(LayoutMode)  // 布局切换开始（传入目标模式）
        case layoutTransitionCompleted    // 布局切换完成
        case columnVisibilityChanged(NavigationSplitViewVisibility)  // 保留，用于兼容
        case columnWidthAdjusted(sidebar: CGFloat?, list: CGFloat?)  // 用户拖拽调整宽度
        case saveColumnWidths(for: LayoutMode)  // 保存宽度设置
        case resetColumnWidths(for: LayoutMode)  // 重置宽度设置
        case showImport
        case dismissImport
        case showExport([Note])
        case dismissExport
        case showSettings
        case dismissSettings
        case preferencesLoaded(EditorPreferences)
        case preferencesUpdated(EditorPreferences)
        
        // 新增：导出 Actions
        case exportCurrentNote(ExportFeature.ExportFormat)
        case exportNote(Note, ExportFeature.ExportFormat)
        case exportSelectedNotes(ExportFeature.ExportFormat)
        case exportNotes([Note], ExportFeature.ExportFormat)
    }
    
    // MARK: - App Environment (Dependencies)
    
    @Dependency(\.noteRepository) var noteRepository
    @Dependency(\.notaFileManager) var notaFileManager
    @Dependency(\.imageManager) var imageManager
    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    @Dependency(\.mainQueue) var mainQueue
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        Scope(state: \.sidebar, action: \.sidebar) {
            SidebarFeature()
        }
        
        Scope(state: \.noteList, action: \.noteList) {
            NoteListFeature()
        }
        
        Scope(state: \.editor, action: \.editor) {
            EditorFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 应用启动时加载笔记、侧边栏计数、状态栏统计和偏好设置
                return .merge(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts)),  // 加载侧边栏计数
                    .run { send in
                        let prefs = await PreferencesStorage.shared.load()
                        await send(.preferencesLoaded(prefs))
                    },
                    // 导入初始文档（首次启动）
                    .run { send in
                        let service = InitialDocumentsService.shared
                        if await service.shouldImportInitialDocuments() {
                            do {
                                // 在导入前验证资源是否存在（可选，但有助于诊断问题）
                                let documentNames = ["使用说明", "Markdown示例"]
                                var missingResources: [String] = []
                                for documentName in documentNames {
                                    if Bundle.safeResourceURL(
                                        name: documentName,
                                        withExtension: "nota",
                                        subdirectory: "Resources/InitialDocuments"
                                    ) == nil {
                                        missingResources.append(documentName)
                                    }
                                }
                                
                                if !missingResources.isEmpty {
                                    print("⚠️ [APP] 初始文档资源缺失: \(missingResources.joined(separator: ", "))")
                                    print("   [APP] 将跳过这些文档的导入，但不影响应用启动")
                                }
                                
                                try await service.importInitialDocuments(
                                    noteRepository: noteRepository,
                                    notaFileManager: notaFileManager
                                )
                                
                                // 导入完成后刷新笔记列表、侧边栏计数和标签列表
                                await send(.noteList(.loadNotes))
                                await send(.sidebar(.loadCounts))
                                await send(.sidebar(.loadTags))
                                
                                if !missingResources.isEmpty {
                                    print("✅ [APP] 初始文档导入完成（部分资源缺失，已跳过）")
                                } else {
                                    print("✅ [APP] 初始文档导入完成")
                                }
                            } catch {
                                // 错误处理：记录日志但不影响应用启动
                                print("❌ [APP] 导入初始文档失败: \(error)")
                                print("   [APP] 错误详情: \(error.localizedDescription)")
                                // 注意：这里不发送错误 Action，因为初始文档导入失败不应该阻止应用启动
                                // 如果需要在 UI 中显示错误，可以添加一个可选的错误状态
                            }
                        }
                    }
                )
                
            case .preferencesLoaded(let prefs):
                state.preferences = prefs
                // 应用偏好设置到编辑器，这会同时更新预览的渲染选项
                return .send(.editor(.applyPreferences(prefs)))
                
            case .preferencesUpdated(let prefs):
                state.preferences = prefs
                return .merge(
                    .run { _ in
                        try await PreferencesStorage.shared.save(prefs)
                    },
                    .send(.editor(.applyPreferences(prefs)))
                )
                
            case .layoutModeChanged(let mode):
                // 如果已经是目标模式，直接返回
                guard mode != state.layoutMode else { return .none }
                
                // 保存当前布局的宽度（如果用户调整过）
                let currentMode = state.layoutMode
                state.isLayoutTransitioning = true
                
                // 保存当前布局的宽度，然后更新布局模式
                return .concatenate(
                    .send(.saveColumnWidths(for: currentMode)),
                    .run { send in
                        // 更新布局模式
                        await send(.layoutTransitionStarted(mode))
                    }
                )
                
            case .layoutTransitionStarted(let mode):
                // 更新布局模式
                state.layoutMode = mode
                
                // 保存到 UserDefaults
                UserDefaults.standard.set(mode.rawValue, forKey: "layoutMode")
                
                // 加载新布局模式的宽度设置
                loadColumnWidthsFromUserDefaults(for: mode, into: &state.columnWidths)
                
                return .run { send in
                    // 等待布局切换动画完成
                    try await mainQueue.sleep(for: .milliseconds(300))
                    await send(.layoutTransitionCompleted)
                }
                
            case .layoutTransitionCompleted:
                state.isLayoutTransitioning = false
                return .none
                
            case .columnWidthAdjusted(let sidebar, let list):
                // 更新当前布局模式的宽度
                switch state.layoutMode {
                case .threeColumn:
                    state.columnWidths.threeColumnWidths = (sidebar, list)
                case .twoColumn:
                    state.columnWidths.twoColumnWidths = list
                case .oneColumn:
                    // 一栏模式不需要保存宽度
                    break
                }
                return .none
                
            case .saveColumnWidths(for: let mode):
                // 保存到 UserDefaults
                switch mode {
                case .threeColumn:
                    if let sidebar = state.columnWidths.threeColumnWidths.sidebar {
                        UserDefaults.standard.set(sidebar, forKey: "columnWidths_三栏_sidebar")
                    }
                    if let list = state.columnWidths.threeColumnWidths.list {
                        UserDefaults.standard.set(list, forKey: "columnWidths_三栏_list")
                    }
                case .twoColumn:
                    if let list = state.columnWidths.twoColumnWidths {
                        UserDefaults.standard.set(list, forKey: "columnWidths_两栏_list")
                    }
                case .oneColumn:
                    // 一栏模式不需要保存宽度
                    break
                }
                return .none
                
            case .resetColumnWidths(for: let mode):
                // 重置为默认值
                switch mode {
                case .threeColumn:
                    state.columnWidths.threeColumnWidths = (nil, nil)
                    UserDefaults.standard.removeObject(forKey: "columnWidths_三栏_sidebar")
                    UserDefaults.standard.removeObject(forKey: "columnWidths_三栏_list")
                case .twoColumn:
                    state.columnWidths.twoColumnWidths = nil
                    UserDefaults.standard.removeObject(forKey: "columnWidths_两栏_list")
                case .oneColumn:
                    break
                }
                return .none
                
            case .columnVisibilityChanged(let visibility):
                // 如果正在切换布局，忽略用户拖拽
                if state.isLayoutTransitioning {
                    return .none
                }
                
                // 将 visibility 转换为 layoutMode
                let newMode = LayoutMode.from(visibility)
                
                // 如果模式改变，触发布局切换
                if newMode != state.layoutMode {
                    return .send(.layoutModeChanged(newMode))
                }
                
                return .none
                
            case .showImport:
                state.importFeature = ImportFeature.State()
                return .none
                
            case .dismissImport:
                state.importFeature = nil
                return .concatenate(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts))
                )
                
            case .importFeature(.importCompleted):
                // 导入完成后，立即刷新列表和侧边栏计数，延迟关闭导入窗口
                return .concatenate(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts)),
                    .run { send in
                        try await mainQueue.sleep(for: .seconds(1.5))
                        await send(.dismissImport)
                    }
                )
                
            case .importFeature:
                return .none
                
            case .showExport(let notes):
                // showExport 现在只用于传统导出对话框，格式由用户选择
                state.exportFeature = ExportFeature.State(notesToExport: notes)
                return .none
                
            case .dismissExport:
                state.exportFeature = nil
                return .none
                
            case .exportFeature:
                return .none
                
            // MARK: - Export Actions
            
            case .exportCurrentNote(let format):
                // 导出当前正在编辑的笔记
                guard let note = state.editor.note else {
                    return .none
                }
                return .send(.exportNote(note, format))
                
            case .exportNote(let note, let format):
                // 单文件导出：显示保存对话框
                return .run { send in
                    await MainActor.run {
                        let defaultName = FileDialogHelpers.defaultFileName(for: note, format: format)
                        let fileExtension = FileDialogHelpers.fileExtension(for: format)
                        
                        FileDialogHelpers.showSavePanel(
                            defaultName: defaultName,
                            allowedFileTypes: [fileExtension]
                        ) { url in
                            guard let url = url else { return }
                            
                            // 创建导出状态并触发导出
                            Task { @MainActor in
                                // 发送导出 action（格式会在 exportToFile 中处理）
                                send(.showExport([note]))
                                
                                // 等待 ExportFeature 初始化后触发导出
                                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
                                
                                // 更新格式
                                send(.exportFeature(.binding(.set(\.exportFormat, format))))
                                
                                // 再等待一下确保格式已更新
                                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05秒
                                send(.exportFeature(.exportToFile(url, format)))
                            }
                        }
                    }
                }
                
            case .exportSelectedNotes(let format):
                // 导出选中的笔记（批量）
                let selectedNoteIds = state.noteList.selectedNoteIds
                guard !selectedNoteIds.isEmpty else {
                    return .none
                }
                
                // 从列表中获取选中的笔记
                let selectedNotes = state.noteList.notes.filter { selectedNoteIds.contains($0.noteId) }
                return .send(.exportNotes(selectedNotes, format))
                
            case .exportNotes(let notes, let format):
                // 批量导出：显示目录选择对话框
                guard !notes.isEmpty else {
                    return .none
                }
                
                if notes.count == 1 {
                    // 单文件导出
                    return .send(.exportNote(notes[0], format))
                } else {
                    // 批量导出：显示目录选择对话框
                    return .run { send in
                        await MainActor.run {
                            FileDialogHelpers.showDirectoryPanel { url in
                                guard let url = url else { return }
                                
                                // 创建导出状态并触发导出
                                Task { @MainActor in
                                    // 将 Services.ExportFormat 转换为 ExportFeature.ExportFormat
                                    let exportFeatureFormat: ExportFeature.ExportFormat
                                    switch format {
                                    case .nota:
                                        exportFeatureFormat = .nota
                                    case .markdown:
                                        exportFeatureFormat = .markdown
                                    case .html:
                                        exportFeatureFormat = .html
                                    case .pdf:
                                        exportFeatureFormat = .pdf
                                    case .png:
                                        exportFeatureFormat = .png
                                    }
                                    
                                    // 创建导出状态并设置格式
                                    var exportState = ExportFeature.State(notesToExport: notes, exportFormat: exportFeatureFormat)
                                    exportState.exportMode = .multiple
                                    
                                    // 设置导出状态（使用带格式的初始化）
                                    send(.showExport(notes))
                                    
                                    // 等待 ExportFeature 初始化后设置格式并触发导出
                                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
                                    
                                    // 更新格式
                                    send(.exportFeature(.binding(.set(\.exportFormat, exportFeatureFormat))))
                                    
                                    // 再等待一下确保格式已更新
                                    try? await Task.sleep(nanoseconds: 50_000_000) // 0.05秒
                                    send(.exportFeature(.exportToDirectory(url)))
                                }
                            }
                        }
                    }
                }
                
            case .showSettings:
                state.settingsFeature = SettingsFeature.State(editorPreferences: state.preferences)
                return .none
                
            case .dismissSettings:
                state.settingsFeature = nil
                return .none
                
            case .settingsFeature(.presented(.apply)):
                // 应用设置后更新preferences（包括 AI 配置）
                if let settingsState = state.settingsFeature {
                    var newPrefs = settingsState.editorPreferences
                    // 确保 AI 配置也被更新
                    newPrefs.aiConfig = settingsState.aiConfig
                    print("🔄 [APP] Updating preferences with AI config - apiKey length: \(newPrefs.aiConfig.apiKey.count)")
                    return .send(.preferencesUpdated(newPrefs))
                }
                return .none
                
            case .settingsFeature:
                return .none
                
            // MARK: - Cross-Module Coordination
                
            // 侧边栏分类切换 → 更新笔记列表过滤
            case .sidebar(.categorySelected(let category)):
                state.noteList.filter = .category(category)
                return .concatenate(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts))  // 同时更新侧边栏计数
                )
                
            // 侧边栏标签切换 → 更新笔记列表过滤
            case .sidebar(.tagToggled):
                if !state.sidebar.selectedTags.isEmpty {
                    state.noteList.filter = .tags(state.sidebar.selectedTags)
                } else if state.sidebar.isNoTagsSelected {
                    state.noteList.filter = .noTags
                } else {
                    state.noteList.filter = .category(state.sidebar.selectedCategory)
                }
                return .send(.noteList(.loadNotes))
                
            // 侧边栏标签单选 → 更新笔记列表过滤
            case .sidebar(.tagSelected):
                if !state.sidebar.selectedTags.isEmpty {
                    state.noteList.filter = .tags(state.sidebar.selectedTags)
                } else {
                    state.noteList.filter = .category(state.sidebar.selectedCategory)
                }
                return .send(.noteList(.loadNotes))
                
            // 侧边栏"全部标签"选择 → 更新笔记列表过滤
            case .sidebar(.allTagsSelected):
                state.noteList.filter = .allTags
                return .send(.noteList(.loadNotes))
                
            // 侧边栏"无标签"选择 → 更新笔记列表过滤
            case .sidebar(.noTagsSelected):
                state.noteList.filter = .noTags
                return .send(.noteList(.loadNotes))
                
            // 笔记列表选中 → 加载到编辑器
            case .noteList(.noteSelected(let id)):
                // 检查是否有搜索关键词，如果有则传递给编辑器用于自动高亮
                let searchKeywords = state.noteList.searchKeywords
                if !searchKeywords.isEmpty {
                    return .concatenate(
                        .send(.editor(.setListSearchKeywords(searchKeywords))),
                        .send(.editor(.loadNote(id)))
                    )
                } else {
                    // 没有搜索关键词，清除之前的高亮
                    return .concatenate(
                        .send(.editor(.setListSearchKeywords([]))),
                        .send(.editor(.loadNote(id)))
                    )
                }
                
            // 笔记列表多选 → 清空编辑器
            case .noteList(.notesSelected(let ids)) where ids.count > 1:
                state.editor.note = nil
                state.editor.content = ""
                state.editor.title = ""
                return .none
                
            // 编辑器保存完成 → 立即更新列表中的笔记（实时预览）
            // 注意：只使用 updateNoteInList 进行乐观更新，不重新加载列表
            // 这样可以避免列表重新排序导致的焦点丢失问题
            case .editor(.saveCompleted):
                if let updatedNote = state.editor.note {
                    return .concatenate(
                        .send(.noteList(.updateNoteInList(updatedNote))),
                        // 移除 .loadNotes，避免重新排序导致焦点丢失
                        // 只在必要时（如排序规则改变）才重新加载
                        .send(.sidebar(.loadCounts))
                    )
                }
                return .send(.sidebar(.loadCounts))
                
            // 笔记列表加载完成 → 不再更新侧边栏统计
            // （因为 notes 是过滤后的，不能用来计算全局计数）
            case .noteList(.notesLoaded(.success(_))):
                return .none
                
            // 编辑器创建笔记完成 → 刷新笔记列表和侧边栏计数，并选中新创建的笔记
            case .editor(.noteCreated(.success(let note))):
                return .concatenate(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts)),
                    // 等待列表加载完成后选中新创建的笔记
                    .run { send in
                        // 给列表一点时间加载
                        try await Task.sleep(for: .milliseconds(100))
                        await send(.noteList(.selectNoteAfterCreate(note.noteId)))
                    }
                )
                
            // 编辑器星标切换完成 → 更新笔记列表和侧边栏计数
            case .editor(.starToggled):
                if let updatedNote = state.editor.note {
                    return .concatenate(
                        .send(.noteList(.updateNoteInList(updatedNote))),
                        .send(.noteList(.loadNotes)),
                        .send(.sidebar(.loadCounts))
                    )
                }
                return .concatenate(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts))
                )
                
            // 编辑器置顶切换完成 → 更新笔记列表和侧边栏计数
            case .editor(.pinToggled):
                if let updatedNote = state.editor.note {
                    return .concatenate(
                        .send(.noteList(.updateNoteInList(updatedNote))),
                        .send(.noteList(.loadNotes)),
                        .send(.sidebar(.loadCounts))
                    )
                }
                return .concatenate(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts))
                )
                
            // 编辑器标签保存完成 → 更新笔记列表、侧边栏计数和标签列表
            case .editor(.tagsSaved):
                if let updatedNote = state.editor.note {
                    return .concatenate(
                        .send(.noteList(.updateNoteInList(updatedNote))),
                        .send(.noteList(.loadNotes)),
                        .send(.sidebar(.loadCounts)),
                        .send(.sidebar(.loadTags))  // 刷新侧边栏标签列表
                    )
                }
                return .concatenate(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts)),
                    .send(.sidebar(.loadTags))  // 刷新侧边栏标签列表
                )
                
            // 编辑器删除笔记完成 → 更新笔记列表和侧边栏计数
            case .editor(.noteDeleted):
                return .concatenate(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts))
                )
                
            // 笔记列表切换星标 → 更新侧边栏计数（列表已有乐观更新）
            case .noteList(.toggleStar):
                return .send(.sidebar(.loadCounts))
                
            // 笔记列表删除笔记 → 只处理编辑器清空，不更新计数（计数在删除完成后更新）
            case .noteList(.deleteNotes(let ids)):
                // 如果删除的笔记中包含当前编辑的笔记，清空编辑器
                if let currentNoteId = state.editor.selectedNoteId, ids.contains(currentNoteId) {
                    state.editor.note = nil
                    state.editor.selectedNoteId = nil
                    state.editor.content = ""
                    state.editor.title = ""
                    state.editor.lastSavedContent = ""
                    state.editor.lastSavedTitle = ""
                }
                return .none  // 不立即更新计数，等待删除完成通知
                
            // 删除完成 → 更新侧边栏计数
            case .noteList(.deleteNotesCompleted):
                return .send(.sidebar(.loadCounts))
                
            // 笔记列表切换置顶 → 更新侧边栏计数（列表会重新加载）
            case .noteList(.togglePin):
                return .send(.sidebar(.loadCounts))
                
            // 笔记列表恢复笔记 → 不立即更新计数（计数在恢复完成后更新）
            case .noteList(.restoreNotes):
                return .none  // 不立即更新计数，等待恢复完成通知
                
            // 恢复完成 → 更新侧边栏计数
            case .noteList(.restoreNotesCompleted):
                return .send(.sidebar(.loadCounts))
                
            // 笔记列表永久删除笔记 → 不立即更新计数（计数在永久删除完成后更新）
            case .noteList(.permanentlyDeleteNotes):
                return .none  // 不立即更新计数，等待永久删除完成通知
                
            // 永久删除完成 → 更新侧边栏计数
            case .noteList(.permanentlyDeleteNotesCompleted):
                return .send(.sidebar(.loadCounts))
                
            // 笔记列表请求创建 → 转发给编辑器
            case .noteList(.createNote):
                return .send(.editor(.createNote))
                
            // 笔记列表导出 → 转发到 AppFeature 导出 actions
            case .noteList(.exportNote(let note, let format)):
                return .send(.exportNote(note, format))
                
            case .noteList(.exportNotes(let notes, let format)):
                return .send(.exportNotes(notes, format))
                
            // 编辑器导出 → 转发到 AppFeature 导出 actions
            case .editor(.exportCurrentNote(let format)):
                return .send(.exportCurrentNote(format))
                
            default:
                return .none
            }
        }
        .ifLet(\.importFeature, action: \.importFeature) {
            ImportFeature()
        }
        .ifLet(\.exportFeature, action: \.exportFeature) {
            ExportFeature()
        }
        .ifLet(\.$settingsFeature, action: \.settingsFeature) {
            SettingsFeature()
        }
    }
}


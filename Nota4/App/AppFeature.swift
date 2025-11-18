import ComposableArchitecture
import SwiftUI

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
        var columnVisibility: NavigationSplitViewVisibility = .all
        var preferences = EditorPreferences()
        
        init() {}
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
        case columnVisibilityChanged(NavigationSplitViewVisibility)
        case showImport
        case dismissImport
        case showExport([Note])
        case dismissExport
        case showSettings
        case dismissSettings
        case preferencesLoaded(EditorPreferences)
        case preferencesUpdated(EditorPreferences)
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
                                try await service.importInitialDocuments(
                                    noteRepository: noteRepository,
                                    notaFileManager: notaFileManager
                                )
                                // 导入完成后刷新笔记列表和侧边栏计数
                                await send(.noteList(.loadNotes))
                                await send(.sidebar(.loadCounts))
                            } catch {
                                print("❌ [APP] 导入初始文档失败: \(error)")
                            }
                        }
                    }
                )
                
            case .preferencesLoaded(let prefs):
                print("📐 [APP] Preferences loaded")
                state.preferences = prefs
                return .send(.editor(.applyPreferences(prefs)))
                
            case .preferencesUpdated(let prefs):
                print("📐 [APP] Preferences updated")
                state.preferences = prefs
                return .merge(
                    .run { _ in
                        try await PreferencesStorage.shared.save(prefs)
                    },
                    .send(.editor(.applyPreferences(prefs)))
                )
                
            case .columnVisibilityChanged(let visibility):
                state.columnVisibility = visibility
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
                state.exportFeature = ExportFeature.State(notesToExport: notes)
                return .none
                
            case .dismissExport:
                state.exportFeature = nil
                return .none
                
            case .exportFeature:
                return .none
                
            case .showSettings:
                state.settingsFeature = SettingsFeature.State(editorPreferences: state.preferences)
                return .none
                
            case .dismissSettings:
                state.settingsFeature = nil
                return .none
                
            case .settingsFeature(.presented(.apply)):
                // 应用设置后更新preferences
                if let newPrefs = state.settingsFeature?.editorPreferences {
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
            case .noteList(.notesLoaded(.success(let notes))):
                print("📊 [APP] Notes loaded (filtered), total: \(notes.count)")
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


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
                // 应用启动时加载笔记、侧边栏计数和偏好设置
                return .merge(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts)),  // 加载侧边栏计数
                    .run { send in
                        let prefs = await PreferencesStorage.shared.load()
                        await send(.preferencesLoaded(prefs))
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
                } else {
                    state.noteList.filter = .category(state.sidebar.selectedCategory)
                }
                return .send(.noteList(.loadNotes))
                
            // 笔记列表选中 → 加载到编辑器
            case .noteList(.noteSelected(let id)):
                return .send(.editor(.loadNote(id)))
                
            // 笔记列表多选 → 清空编辑器
            case .noteList(.notesSelected(let ids)) where ids.count > 1:
                state.editor.note = nil
                state.editor.content = ""
                state.editor.title = ""
                return .none
                
            // 编辑器保存完成 → 立即更新列表中的笔记（实时预览）
            case .editor(.saveCompleted):
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
                
            // 笔记列表加载完成 → 不再更新侧边栏统计
            // （因为 notes 是过滤后的，不能用来计算全局计数）
            case .noteList(.notesLoaded(.success(let notes))):
                print("📊 [APP] Notes loaded (filtered), total: \(notes.count)")
                return .none
                
            // 编辑器创建笔记完成 → 刷新笔记列表和侧边栏计数
            case .editor(.noteCreated(.success)):
                return .concatenate(
                    .send(.noteList(.loadNotes)),
                    .send(.sidebar(.loadCounts))
                )
                
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


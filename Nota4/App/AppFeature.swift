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
        var columnVisibility: NavigationSplitViewVisibility = .all
        
        init() {}
    }
    
    // MARK: - App Action
    
    enum Action {
        case sidebar(SidebarFeature.Action)
        case noteList(NoteListFeature.Action)
        case editor(EditorFeature.Action)
        case onAppear
        case columnVisibilityChanged(NavigationSplitViewVisibility)
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
                // 应用启动时加载笔记
                return .send(.noteList(.loadNotes))
                
            case .columnVisibilityChanged(let visibility):
                state.columnVisibility = visibility
                return .none
                
            // MARK: - Cross-Module Coordination
                
            // 侧边栏分类切换 → 更新笔记列表过滤
            case .sidebar(.categorySelected(let category)):
                state.noteList.filter = .category(category)
                return .send(.noteList(.loadNotes))
                
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
                
            // 编辑器保存完成 → 刷新笔记列表
            case .editor(.saveCompleted):
                return .send(.noteList(.loadNotes))
                
            // 笔记列表加载完成 → 更新侧边栏统计
            case .noteList(.notesLoaded(.success(let notes))):
                let counts: [SidebarFeature.State.Category: Int] = [
                    .all: notes.filter { !$0.isDeleted }.count,
                    .starred: notes.filter { $0.isStarred && !$0.isDeleted }.count,
                    .trash: notes.filter { $0.isDeleted }.count
                ]
                return .send(.sidebar(.updateCounts(counts)))
                
            default:
                return .none
            }
        }
    }
}


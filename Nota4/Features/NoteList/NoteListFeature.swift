import ComposableArchitecture
import Foundation

// MARK: - NoteList Feature

@Reducer
struct NoteListFeature {
    @ObservableState
    struct State: Equatable {
        var notes: [Note] = []
        var selectedNoteId: String?
        var selectedNoteIds: Set<String> = []
        var searchText: String = ""
        var isSearching: Bool = false
        var isSearchPanelVisible: Bool = false  // 搜索面板是否可见
        var sortOrder: SortOrder = .updated
        var isLoading: Bool = false
        var filter: Filter = .none
        var showPermanentDeleteConfirmation: Bool = false
        var pendingPermanentDeleteIds: Set<String> = []
        
        // MARK: - Sort Order
        
        enum SortOrder: Equatable {
            case updated
            case created
            case title
        }
        
        // MARK: - Filter
        
        enum Filter: Equatable {
            case none
            case category(SidebarFeature.State.Category)
            case tags(Set<String>)
            case search(String)
        }
        
        // MARK: - Computed Properties
        
        /// 当前搜索关键词（用于高亮）
        var searchKeywords: [String] {
            if case .search(let keyword) = filter {
                return keyword.split(separator: " ").map(String.init)
            }
            return []
        }
        
        /// 过滤并排序后的笔记
        var filteredNotes: [Note] {
            notes
                .filter { note in
                    switch filter {
                    case .none:
                        return true
                    case .category(let category):
                        switch category {
                        case .all:
                            return !note.isDeleted
                        case .starred:
                            return note.isStarred && !note.isDeleted
                        case .trash:
                            return note.isDeleted
                        }
                    case .tags(let tags):
                        return !note.tags.isDisjoint(with: tags) && !note.isDeleted
                    case .search(let keyword):
                        guard !keyword.isEmpty else {
                            return !note.isDeleted
                        }
                        
                        // 不区分大小写的搜索
                        let lowercaseKeyword = keyword.lowercased()
                        let lowercaseTitle = note.title.lowercased()
                        let lowercaseContent = note.content.lowercased()
                        
                        // 支持空格分词：每个词都必须匹配
                        let keywords = lowercaseKeyword.split(separator: " ").map(String.init)
                        
                        // 单个关键词（可能是单个字符、标点符号、中文单字）
                        if keywords.count == 1 {
                            let word = keywords[0]
                            // 直接使用 contains，支持所有字符类型（中文、英文、标点符号）
                            let matches = lowercaseTitle.contains(word) || lowercaseContent.contains(word)
                            return matches && !note.isDeleted
                        }
                        
                        // 多个关键词：每个词都必须匹配（AND 逻辑）
                        let matches = keywords.allSatisfy { word in
                            lowercaseTitle.contains(word) || lowercaseContent.contains(word)
                        }
                        
                        return matches && !note.isDeleted
                    }
                }
                .sorted { lhs, rhs in
                    // 置顶优先
                    if lhs.isPinned != rhs.isPinned {
                        return lhs.isPinned
                    }
                    
                    // 按排序方式
                    switch sortOrder {
                    case .updated:
                        return lhs.updated > rhs.updated
                    case .created:
                        return lhs.created > rhs.created
                    case .title:
                        return lhs.title < rhs.title
                    }
                }
        }
        
        init() {}
    }
    
    // MARK: - Action
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case loadNotes
        case notesLoaded(Result<[Note], Error>)
        case noteSelected(String)
        case notesSelected(Set<String>)
        case deleteNotes(Set<String>)
        case restoreNotes(Set<String>)
        case permanentlyDeleteNotes(Set<String>)
        case toggleStar(String)
        case togglePin(String)
        case filterChanged(State.Filter)
        case sortOrderChanged(State.SortOrder)
        case searchDebounced(String)
        case toggleSearchPanel  // 切换搜索面板显示/隐藏
        case closeSearchPanel   // 关闭搜索面板并清除搜索
        case createNote
        case updateNoteInList(Note) // 直接更新列表中的笔记
        case requestPermanentDelete(Set<String>)
        case confirmPermanentDelete
        case cancelPermanentDelete
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.noteRepository) var noteRepository
    @Dependency(\.notaFileManager) var notaFileManager
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.date) var date
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.searchText):
                // 防抖搜索
                return .run { [searchText = state.searchText] send in
                    try await mainQueue.sleep(for: .milliseconds(300))
                    await send(.searchDebounced(searchText))
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)
                
            case .binding:
                return .none
                
            case .loadNotes:
                state.isLoading = true
                return .run { [filter = state.filter] send in
                    let notes = try await noteRepository.fetchNotes(filter: filter)
                    await send(.notesLoaded(.success(notes)))
                } catch: { error, send in
                    await send(.notesLoaded(.failure(error)))
                }
                
            case .notesLoaded(.success(let notes)):
                state.notes = notes
                state.isLoading = false
                return .none
                
            case .notesLoaded(.failure(let error)):
                state.isLoading = false
                print("❌ 加载笔记失败: \(error)")
                return .none
                
            case .noteSelected(let id):
                state.selectedNoteId = id
                state.selectedNoteIds.removeAll()
                return .none
                
            case .notesSelected(let ids):
                state.selectedNoteIds = ids
                state.selectedNoteId = ids.count == 1 ? ids.first : nil
                return .none
                
            case .deleteNotes(let ids):
                return .run { send in
                    try await noteRepository.deleteNotes(ids)
                    await send(.loadNotes)
                }
                
            case .restoreNotes(let ids):
                return .run { send in
                    try await noteRepository.restoreNotes(ids)
                    await send(.loadNotes)
                }
                
            case .requestPermanentDelete(let ids):
                // 显示确认对话框
                state.showPermanentDeleteConfirmation = true
                state.pendingPermanentDeleteIds = ids
                return .none
                
            case .confirmPermanentDelete:
                // 确认永久删除
                let ids = state.pendingPermanentDeleteIds
                state.showPermanentDeleteConfirmation = false
                state.pendingPermanentDeleteIds = []
                return .run { send in
                    try await noteRepository.permanentlyDeleteNotes(ids)
                    for id in ids {
                        try await notaFileManager.deleteNoteFile(noteId: id)
                    }
                    await send(.loadNotes)
                }
                
            case .cancelPermanentDelete:
                // 取消永久删除
                state.showPermanentDeleteConfirmation = false
                state.pendingPermanentDeleteIds = []
                return .none
                
            case .permanentlyDeleteNotes(let ids):
                // 直接永久删除（用于滑动操作等不需要确认的场景）
                return .run { send in
                    try await noteRepository.permanentlyDeleteNotes(ids)
                    for id in ids {
                        try await notaFileManager.deleteNoteFile(noteId: id)
                    }
                    await send(.loadNotes)
                }
                
            case .toggleStar(let id):
                guard let note = state.notes.first(where: { $0.noteId == id }) else {
                    return .none
                }
                
                var updatedNote = note
                updatedNote.isStarred.toggle()
                updatedNote.updated = date.now
                
                // 乐观更新
                if let index = state.notes.firstIndex(where: { $0.noteId == id }) {
                    state.notes[index] = updatedNote
                }
                
                return .run { send in
                    try await noteRepository.updateNote(updatedNote)
                }
                
            case .togglePin(let id):
                guard let note = state.notes.first(where: { $0.noteId == id }) else {
                    return .none
                }
                
                var updatedNote = note
                updatedNote.isPinned.toggle()
                updatedNote.updated = date.now
                
                // 乐观更新
                if let index = state.notes.firstIndex(where: { $0.noteId == id }) {
                    state.notes[index] = updatedNote
                }
                
                return .run { send in
                    try await noteRepository.updateNote(updatedNote)
                    await send(.loadNotes) // 重新排序
                }
                
            case .filterChanged(let filter):
                state.filter = filter
                return .send(.loadNotes)
                
            case .sortOrderChanged(let order):
                state.sortOrder = order
                return .none
                
            case .searchDebounced(let keyword):
                guard !keyword.isEmpty else {
                    state.filter = .category(.all)
                    return .send(.loadNotes)
                }
                state.filter = .search(keyword)
                return .send(.loadNotes)
                
            case .toggleSearchPanel:
                state.isSearchPanelVisible.toggle()
                // 如果关闭搜索面板，清除搜索并返回完整列表
                if !state.isSearchPanelVisible {
                    state.searchText = ""
                    state.filter = .category(.all)
                    return .send(.loadNotes)
                }
                return .none
                
            case .closeSearchPanel:
                state.isSearchPanelVisible = false
                state.searchText = ""
                state.filter = .category(.all)
                return .send(.loadNotes)
                
            case .createNote:
                // 由 AppFeature 处理，转发给 editor
                return .none
                
            case .updateNoteInList(let updatedNote):
                print("📋 [LIST] Updating note in list: \(updatedNote.noteId)")
                print("📋 [LIST] Title: '\(updatedNote.title)'")
                print("📋 [LIST] Content preview: '\(updatedNote.preview.prefix(50))...'")
                
                // 直接更新列表中的笔记，实现实时预览
                if let index = state.notes.firstIndex(where: { $0.noteId == updatedNote.noteId }) {
                    print("📋 [LIST] Found note at index \(index), updating...")
                    state.notes[index] = updatedNote
                    print("✅ [LIST] Note updated successfully")
                } else {
                    print("⚠️ [LIST] Note not found in list")
                }
                return .none
            }
        }
    }
    
    // MARK: - Cancel IDs
    
    enum CancelID {
        case search
    }
}


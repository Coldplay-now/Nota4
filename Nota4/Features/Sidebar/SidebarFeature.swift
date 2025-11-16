import ComposableArchitecture
import Foundation

// MARK: - Sidebar Feature

@Reducer
struct SidebarFeature {
    @ObservableState
    struct State: Equatable {
        var selectedCategory: Category = .all
        var tags: [Tag] = []
        var selectedTags: Set<String> = []
        var categoryCounts: [Category: Int] = [
            .all: 0,
            .starred: 0,
            .trash: 0
        ]
        
        // MARK: - Category
        
        enum Category: String, CaseIterable, Identifiable {
            case all = "全部笔记"
            case starred = "星标笔记"
            case trash = "已删除"
            
            var id: String { rawValue }
            
            var icon: String {
                switch self {
                case .all: return "note.text"
                case .starred: return "star.fill"
                case .trash: return "trash"
                }
            }
        }
        
        // MARK: - Tag
        
        struct Tag: Equatable, Identifiable {
            let id: String
            let name: String
            var count: Int = 0
            
            init(id: String = UUID().uuidString, name: String, count: Int = 0) {
                self.id = id
                self.name = name
                self.count = count
            }
        }
        
        init() {}
    }
    
    // MARK: - Action
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case categorySelected(State.Category)
        case tagSelected(String)
        case tagToggled(String)
        case loadTags
        case tagsLoaded(TaskResult<[State.Tag]>)
        case loadCounts
        case updateCounts([State.Category: Int])
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.noteRepository) var noteRepository
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
    }
    
    func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
            
        case .categorySelected(let category):
            state.selectedCategory = category
            state.selectedTags.removeAll() // 切换分类时清空标签选择
            return .none
            
        case .tagSelected(let tag):
            state.selectedTags = [tag]
            return .none
            
        case .tagToggled(let tag):
            if state.selectedTags.contains(tag) {
                state.selectedTags.remove(tag)
            } else {
                state.selectedTags.insert(tag)
            }
            return .none
            
        case .loadTags:
            return .run { send in
                await send(.tagsLoaded(
                    TaskResult { try await noteRepository.fetchAllTags() }
                ))
            }
            
        case .tagsLoaded(.success(let tags)):
            state.tags = tags
            return .none
            
        case .tagsLoaded(.failure):
            return .none
            
        case .loadCounts:
            return .run { send in
                let allNotes = try await noteRepository.fetchNotes(filter: .none)
                let counts: [State.Category: Int] = [
                    .all: allNotes.filter { !$0.isDeleted }.count,
                    .starred: allNotes.filter { $0.isStarred && !$0.isDeleted }.count,
                    .trash: allNotes.filter { $0.isDeleted }.count
                ]
                await send(.updateCounts(counts))
            } catch: { error, send in
                print("❌ 加载计数失败: \(error)")
            }
            
        case .updateCounts(let counts):
            state.categoryCounts = counts
            return .none
        }
    }
}







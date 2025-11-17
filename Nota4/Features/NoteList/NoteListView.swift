import SwiftUI
import ComposableArchitecture

struct NoteListView: View {
    let store: StoreOf<NoteListFeature>
    @State private var selectedNotes = Set<String>()
    
    private var permanentDeleteMessage: String {
        let count = store.pendingPermanentDeleteIds.count
        if count == 1 {
            return "确定要永久删除这篇笔记吗？此操作无法恢复。"
        } else {
            return "确定要永久删除这 \(count) 篇笔记吗？此操作无法恢复。"
        }
    }
    
    private var isTrashFilter: Bool {
        if case .category(let category) = store.filter {
            return category == .trash
        }
        return false
    }
    
    var body: some View {
        WithPerceptionTracking {
            List(store.filteredNotes, id: \.noteId, selection: $selectedNotes) { note in
                noteRow(note: note, store: store)
            }
            .listStyle(.plain)
            .searchable(
                text: Binding(
                    get: { store.searchText },
                    set: { store.send(.binding(.set(\.searchText, $0))) }
                ),
                isPresented: Binding(
                    get: { store.isSearching },
                    set: { store.send(.binding(.set(\.isSearching, $0))) }
                )
            )
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    // 新建笔记按钮
                    Button {
                        store.send(.createNote)
                    } label: {
                        Label("新建笔记", systemImage: "square.and.pencil")
                    }
                    .help("创建新笔记 (⌘N)")
                    
                    // 排序菜单
                    Menu {
                        Picker("排序", selection: Binding(
                            get: { store.sortOrder },
                            set: { store.send(.sortOrderChanged($0)) }
                        )) {
                            Label("最近更新", systemImage: "clock")
                                .tag(NoteListFeature.State.SortOrder.updated)
                            Label("创建时间", systemImage: "calendar")
                                .tag(NoteListFeature.State.SortOrder.created)
                            Label("标题", systemImage: "textformat")
                                .tag(NoteListFeature.State.SortOrder.title)
                        }
                    } label: {
                        Label("排序", systemImage: "arrow.up.arrow.down")
                }
                
                    // 批量删除
                if !selectedNotes.isEmpty {
                        Button(role: .destructive) {
                            store.send(.deleteNotes(selectedNotes))
                            selectedNotes.removeAll()
                        } label: {
                            Label("删除 \(selectedNotes.count) 项", systemImage: "trash")
                        }
                    }
                }
            }
            .onChange(of: selectedNotes) { _, newValue in
                if newValue.count == 1 {
                    store.send(.noteSelected(newValue.first!))
                } else {
                    store.send(.notesSelected(newValue))
                }
            }
            .overlay {
                if store.isLoading {
                    ProgressView()
                } else if store.filteredNotes.isEmpty {
                    ContentUnavailableView(
                        "暂无笔记",
                        systemImage: "note.text",
                        description: Text("创建你的第一篇笔记")
                    )
                }
            }
            .confirmationDialog(
                "确认永久删除",
                isPresented: Binding(
                    get: { store.showPermanentDeleteConfirmation },
                    set: { _ in store.send(.cancelPermanentDelete) }
                ),
                titleVisibility: .visible
            ) {
                Button("永久删除", role: .destructive) {
                    store.send(.confirmPermanentDelete)
                }
                Button("取消", role: .cancel) {
                    store.send(.cancelPermanentDelete)
                }
            } message: {
                Text(permanentDeleteMessage)
            }
        }
    }
    
    @ViewBuilder
    private func noteRow(note: Note, store: StoreOf<NoteListFeature>) -> some View {
        let isTrash: Bool = {
            if case .category(let category) = store.filter {
                return category == .trash
            }
            return false
        }()
        NoteRowView(note: note, searchKeywords: store.searchKeywords)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if isTrash {
                    Button(role: .destructive) {
                        store.send(.permanentlyDeleteNotes([note.noteId]))
                    } label: {
                        Label("永久删除", systemImage: "trash.fill")
                    }
                    .tint(.red)
                } else {
                    Button(role: .destructive) {
                        store.send(.deleteNotes([note.noteId]))
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                    .tint(.red)
                    
                    Button {
                        store.send(.toggleStar(note.noteId))
                    } label: {
                        Label(
                            note.isStarred ? "取消星标" : "星标",
                            systemImage: note.isStarred ? "star.slash" : "star"
                        )
                    }
                    .tint(.yellow)
                }
            }
            .swipeActions(edge: .leading) {
                if isTrash {
                    Button {
                        store.send(.restoreNotes([note.noteId]))
                    } label: {
                        Label("恢复", systemImage: "arrow.uturn.backward")
                    }
                    .tint(.green)
                } else {
                    Button {
                        store.send(.togglePin(note.noteId))
                    } label: {
                        Label(
                            note.isPinned ? "取消置顶" : "置顶",
                            systemImage: note.isPinned ? "pin.slash" : "pin"
                        )
                    }
                    .tint(.orange)
                }
            }
            .contextMenu {
                Button("打开") {
                    store.send(.noteSelected(note.noteId))
                }
                Divider()
                
                if isTrash {
                    Button("恢复笔记") {
                        store.send(.restoreNotes([note.noteId]))
                    }
                    
                    Divider()
                    
                    Button("永久删除", role: .destructive) {
                        store.send(.requestPermanentDelete([note.noteId]))
                    }
                } else {
                    Button("星标") {
                        store.send(.toggleStar(note.noteId))
                    }
                    
                    Button("删除", role: .destructive) {
                        store.send(.deleteNotes([note.noteId]))
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        NoteListView(
            store: Store(initialState: NoteListFeature.State()) {
                NoteListFeature()
            }
        )
    }
}







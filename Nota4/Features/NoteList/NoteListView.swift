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
            VStack(spacing: 0) {
                // 工具栏
                NoteListToolbar(store: store)
                
                // 可展开的搜索框（条件显示）
                if store.isSearchPanelVisible {
                    ExpandableSearchField(store: store)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.2), value: store.isSearchPanelVisible)
                }
                
                // 笔记列表
                List(store.filteredNotes, id: \.noteId, selection: $selectedNotes) { note in
                    noteRow(note: note, store: store)
                }
                .listStyle(.plain)
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
        
        // 检查是否批量选择（当前笔记在选中列表中，且选中数量 > 1）
        let isBatchSelection = selectedNotes.count > 1 && selectedNotes.contains(note.noteId)
        
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
                    // 批量选择时，显示两个菜单项
                    if isBatchSelection {
                        Button("星标") {
                            // 为所有选中的笔记添加星标（只对没有星标的笔记操作）
                            for noteId in selectedNotes {
                                if let note = store.notes.first(where: { $0.noteId == noteId }), !note.isStarred {
                                    store.send(.toggleStar(noteId))
                                }
                            }
                        }
                        
                        Button("去除星标") {
                            // 为所有选中的笔记去除星标（只对有星标的笔记操作）
                            for noteId in selectedNotes {
                                if let note = store.notes.first(where: { $0.noteId == noteId }), note.isStarred {
                                    store.send(.toggleStar(noteId))
                                }
                            }
                        }
                    } else {
                        // 单个笔记，根据星标状态显示对应菜单
                        if note.isStarred {
                            Button("去除星标") {
                                store.send(.toggleStar(note.noteId))
                            }
                        } else {
                            Button("星标") {
                                store.send(.toggleStar(note.noteId))
                            }
                        }
                    }
                    
                    Button("删除", role: .destructive) {
                        if isBatchSelection {
                            store.send(.deleteNotes(selectedNotes))
                        } else {
                            store.send(.deleteNotes([note.noteId]))
                        }
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







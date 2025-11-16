import SwiftUI
import ComposableArchitecture

struct NoteListView: View {
    let store: StoreOf<NoteListFeature>
    @State private var selectedNotes = Set<String>()
    
    var body: some View {
        WithPerceptionTracking {
            List(store.filteredNotes, id: \.noteId, selection: $selectedNotes) { note in
                NoteRowView(note: note)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
                    .swipeActions(edge: .leading) {
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
                    .contextMenu {
                        Button("打开") {
                            store.send(.noteSelected(note.noteId))
                        }
                        Divider()
                        Button("星标") {
                            store.send(.toggleStar(note.noteId))
                        }
                        Button("删除", role: .destructive) {
                            store.send(.deleteNotes([note.noteId]))
                        }
                    }
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
                ToolbarItem {
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
                }
                
                // 批量操作
                if !selectedNotes.isEmpty {
                    ToolbarItem {
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







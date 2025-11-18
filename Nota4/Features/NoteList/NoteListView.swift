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
                List(selection: $selectedNotes) {
                    ForEach(store.filteredNotes, id: \.noteId) { note in
                        noteRow(note: note, store: store, isSelected: selectedNotes.contains(note.noteId))
                            .id(note.noteId)
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .listRowBackground(EmptyView()) // 完全禁用系统默认背景和选中样式
                            .listRowSeparator(.hidden)
                            .tag(note.noteId)
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: false)) // 使用 inset 样式以支持 swipeActions
                .scrollContentBackground(.hidden)
                .background(Color(nsColor: .textBackgroundColor)) // 使用文本背景色，更接近白色
                .environment(\.defaultMinListRowHeight, 0) // 移除默认行高样式
                .animation(.easeInOut(duration: 0.2), value: selectedNotes)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.filteredNotes.map { $0.noteId })
            }
            .onChange(of: selectedNotes) { _, newValue in
                if newValue.count == 1 {
                    store.send(.noteSelected(newValue.first!))
                } else {
                    store.send(.notesSelected(newValue))
                }
            }
            .onChange(of: store.selectedNoteId) { _, newNoteId in
                // 只在以下情况更新 selectedNotes：
                // 1. selectedNoteId 被设置，且 selectedNotes 为空或只包含该 ID（单选场景）
                // 2. selectedNoteId 被清除，且 selectedNotes 为空（清除选择）
                // 这样可以避免在多选时覆盖多选状态
                if let noteId = newNoteId {
                    // 如果 selectedNotes 不包含该 ID，更新 selectedNotes（包括新建笔记的场景）
                    if !selectedNotes.contains(noteId) {
                        selectedNotes = [noteId]
                    } else if selectedNotes.count == 1 && selectedNotes.contains(noteId) {
                        // 如果已经是唯一选中项，保持不变
                        // 这个分支实际上不需要，但保留以保持逻辑清晰
                    }
                } else if newNoteId == nil && selectedNotes.isEmpty {
                    // 只在 selectedNotes 为空时才清除（避免覆盖多选状态）
                    selectedNotes = []
                }
            }
            .onChange(of: store.selectedNoteIds) { _, newIds in
                // 同步 store.selectedNoteIds 到 selectedNotes（用于批量选择）
                if !newIds.isEmpty {
                    // 如果 store.selectedNoteIds 有值，同步到 selectedNotes
                    selectedNotes = newIds
                } else if newIds.isEmpty && !selectedNotes.isEmpty {
                    // 如果 selectedNoteIds 被清除（例如删除后），也清除 selectedNotes
                    selectedNotes = []
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
    private func noteRow(note: Note, store: StoreOf<NoteListFeature>, isSelected: Bool) -> some View {
        let isTrash: Bool = {
            if case .category(let category) = store.filter {
                return category == .trash
            }
            return false
        }()
        
        // 检查是否批量选择（当前笔记在选中列表中，且选中数量 > 1）
        let isBatchSelection = selectedNotes.count > 1 && selectedNotes.contains(note.noteId)
        
        NoteRowView(note: note, searchKeywords: store.searchKeywords, isSelected: isSelected)
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
                    // 批量选择时，显示批量操作菜单
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
                        
                        Divider()
                        
                        Button("置顶") {
                            // 为所有选中的笔记添加置顶（只对没有置顶的笔记操作）
                            for noteId in selectedNotes {
                                if let note = store.notes.first(where: { $0.noteId == noteId }), !note.isPinned {
                                    store.send(.togglePin(noteId))
                                }
                            }
                        }
                        
                        Button("取消置顶") {
                            // 为所有选中的笔记取消置顶（只对有置顶的笔记操作）
                            for noteId in selectedNotes {
                                if let note = store.notes.first(where: { $0.noteId == noteId }), note.isPinned {
                                    store.send(.togglePin(noteId))
                                }
                            }
                        }
                    } else {
                        // 单个笔记，根据状态显示对应菜单
                        if note.isStarred {
                            Button("去除星标") {
                                store.send(.toggleStar(note.noteId))
                            }
                        } else {
                            Button("星标") {
                                store.send(.toggleStar(note.noteId))
                            }
                        }
                        
                        Divider()
                        
                        if note.isPinned {
                            Button("取消置顶") {
                                store.send(.togglePin(note.noteId))
                            }
                        } else {
                            Button("置顶") {
                                store.send(.togglePin(note.noteId))
                            }
                        }
                    }
                    
                    Divider()
                    
                    // 导出菜单
                    if isBatchSelection {
                        // 批量导出
                        Menu("批量导出为...") {
                            Button(".nota") {
                                let notesToExport = store.notes.filter { store.selectedNoteIds.contains($0.noteId) }
                                store.send(.exportNotes(notesToExport, .nota))
                            }
                            Button(".md") {
                                let notesToExport = store.notes.filter { store.selectedNoteIds.contains($0.noteId) }
                                store.send(.exportNotes(notesToExport, .markdown))
                            }
                            Button(".html") {
                                let notesToExport = store.notes.filter { store.selectedNoteIds.contains($0.noteId) }
                                store.send(.exportNotes(notesToExport, .html))
                            }
                            Button(".pdf") {
                                let notesToExport = store.notes.filter { store.selectedNoteIds.contains($0.noteId) }
                                store.send(.exportNotes(notesToExport, .pdf))
                            }
                            Button(".png") {
                                let notesToExport = store.notes.filter { store.selectedNoteIds.contains($0.noteId) }
                                store.send(.exportNotes(notesToExport, .png))
                            }
                        }
                    } else {
                        // 单个笔记导出
                        Menu("导出为...") {
                            Button(".nota") {
                                store.send(.exportNote(note, .nota))
                            }
                            Button(".md") {
                                store.send(.exportNote(note, .markdown))
                            }
                            Button(".html") {
                                store.send(.exportNote(note, .html))
                            }
                            Button(".pdf") {
                                store.send(.exportNote(note, .pdf))
                            }
                            Button(".png") {
                                store.send(.exportNote(note, .png))
                            }
                        }
                    }
                    
                    Divider()
                    
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







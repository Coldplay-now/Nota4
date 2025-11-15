import XCTest
import ComposableArchitecture
@testable import Nota4

@MainActor
final class NoteListFeatureTests: XCTestCase {
    
    // MARK: - Test 1: Load Notes
    
    func testLoadNotes() async {
        let store = TestStore(initialState: NoteListFeature.State()) {
            NoteListFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        await store.send(.loadNotes) {
            $0.isLoading = true
        }
    }
    
    // MARK: - Test 2: Note Selection
    
    func testNoteSelection() async {
        let store = TestStore(initialState: NoteListFeature.State()) {
            NoteListFeature()
        }
        
        await store.send(.noteSelected("test-id")) {
            $0.selectedNoteId = "test-id"
        }
    }
    
    // MARK: - Test 3: Multi Select
    
    func testMultiSelect() async {
        let store = TestStore(initialState: NoteListFeature.State()) {
            NoteListFeature()
        }
        
        let selectedIds: Set<String> = ["id1", "id2", "id3"]
        
        await store.send(.notesSelected(selectedIds)) {
            $0.selectedNoteIds = selectedIds
        }
    }
    
    // MARK: - Test 4: Filter Changed
    
    func testFilterChanged() async {
        let store = TestStore(initialState: NoteListFeature.State()) {
            NoteListFeature()
        }
        
        store.exhaustivity = .off
        
        await store.send(.filterChanged(.category(.starred))) {
            $0.filter = .category(.starred)
        }
        
        await store.send(.filterChanged(.tags(["work"]))) {
            $0.filter = .tags(["work"])
        }
    }
    
    // MARK: - Test 5: Sort Order Changed
    
    func testSortOrderChanged() async {
        let store = TestStore(initialState: NoteListFeature.State()) {
            NoteListFeature()
        }
        
        // Initial sort order is .updated
        XCTAssertEqual(store.state.sortOrder, .updated)
        
        await store.send(.sortOrderChanged(.title)) {
            $0.sortOrder = .title
        }
        
        await store.send(.sortOrderChanged(.created)) {
            $0.sortOrder = .created
        }
    }
    
    // MARK: - Test 6: Delete Notes
    
    func testDeleteNotes() async {
        let store = TestStore(initialState: NoteListFeature.State()) {
            NoteListFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        let noteIds: Set<String> = ["id1", "id2"]
        await store.send(.deleteNotes(noteIds))
    }
    
    // MARK: - Test 7: Restore Notes
    
    func testRestoreNotes() async {
        let store = TestStore(initialState: NoteListFeature.State()) {
            NoteListFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        let noteIds: Set<String> = ["id1"]
        await store.send(.restoreNotes(noteIds))
    }
    
    // MARK: - Test 8: Toggle Star
    
    func testToggleStar() async {
        var initialState = NoteListFeature.State()
        initialState.notes = [
            Note(noteId: "id1", title: "Note 1", content: "Content 1", isStarred: false)
        ]
        
        let store = TestStore(initialState: initialState) {
            NoteListFeature()
        } withDependencies: {
            $0.date = .constant(Date())
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        await store.send(.toggleStar("id1"))
    }
    
    // MARK: - Test 9: Toggle Pin
    
    func testTogglePin() async {
        var initialState = NoteListFeature.State()
        initialState.notes = [
            Note(noteId: "id1", title: "Note 1", content: "Content 1", isPinned: false)
        ]
        
        let store = TestStore(initialState: initialState) {
            NoteListFeature()
        } withDependencies: {
            $0.date = .constant(Date())
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        await store.send(.togglePin("id1"))
    }
    
    // MARK: - Test 10: Filtered Notes - All Category
    
    func testFilteredNotes_AllCategory() {
        var state = NoteListFeature.State()
        state.notes = [
            Note(noteId: "1", title: "Normal", content: "Content", isDeleted: false),
            Note(noteId: "2", title: "Deleted", content: "Content", isDeleted: true)
        ]
        state.filter = .category(.all)
        
        let filtered = state.filteredNotes
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.noteId, "1")
    }
    
    // MARK: - Test 11: Filtered Notes - Starred Category
    
    func testFilteredNotes_StarredCategory() {
        var state = NoteListFeature.State()
        state.notes = [
            Note(noteId: "1", title: "Starred", content: "Content", isStarred: true, isDeleted: false),
            Note(noteId: "2", title: "Not Starred", content: "Content", isStarred: false, isDeleted: false)
        ]
        state.filter = .category(.starred)
        
        let filtered = state.filteredNotes
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.noteId, "1")
    }
    
    // MARK: - Test 12: Filtered Notes - Sort by Pinned and Updated
    
    func testFilteredNotes_SortByPinnedAndUpdated() {
        let date1 = Date(timeIntervalSince1970: 1000)
        let date2 = Date(timeIntervalSince1970: 2000)
        
        var state = NoteListFeature.State()
        state.notes = [
            Note(noteId: "1", title: "Older", content: "Content", updated: date1, isPinned: false),
            Note(noteId: "2", title: "Pinned", content: "Content", updated: date1, isPinned: true),
            Note(noteId: "3", title: "Newer", content: "Content", updated: date2, isPinned: false)
        ]
        state.filter = .none
        state.sortOrder = .updated
        
        let filtered = state.filteredNotes
        
        // Pinned note should be first
        XCTAssertEqual(filtered[0].noteId, "2")
        // Then sorted by updated date (newest first)
        XCTAssertEqual(filtered[1].noteId, "3")
        XCTAssertEqual(filtered[2].noteId, "1")
    }
}


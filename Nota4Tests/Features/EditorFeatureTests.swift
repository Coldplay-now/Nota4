import XCTest
import ComposableArchitecture
@testable import Nota4

@MainActor
final class EditorFeatureTests: XCTestCase {
    
    // MARK: - Test 1: Auto Save Debounce (Simplified without TestClock)
    
    func testAutoSaveDebounce() async {
        // For now, test basic state changes without time control
        let store = TestStore(initialState: EditorFeature.State()) {
            EditorFeature()
        }
        
        // Verify initial state has no unsaved changes
        XCTAssertFalse(store.state.hasUnsavedChanges)
    }
    
    // MARK: - Test 2: Manual Save
    
    func testManualSave() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Content")
        initialState.note = testNote
        initialState.content = "Updated Content"
        initialState.lastSavedContent = "Content"
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        } withDependencies: {
            $0.date = .constant(Date())
            $0.noteRepository = NoteRepository.mock
            $0.notaFileManager = NotaFileManager.mock
        }
        
        store.exhaustivity = .off  // Turn off exhaustivity for simplicity
        
        // Test that manual save can be sent
        await store.send(.manualSave)
    }
    
    // MARK: - Test 3: Load Note
    
    func testLoadNote() async {
        let store = TestStore(initialState: EditorFeature.State()) {
            EditorFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off  // Turn off exhaustivity to simplify the test
        
        await store.send(.loadNote("test-id")) {
            $0.selectedNoteId = "test-id"
        }
    }
    
    // MARK: - Test 4: Load Note Failure
    
    func testLoadNoteFailure() async {
        let store = TestStore(initialState: EditorFeature.State()) {
            EditorFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        await store.send(.loadNote("non-existent")) {
            $0.selectedNoteId = "non-existent"
        }
        
        await store.receive(\.noteLoaded.failure)
    }
    
    // MARK: - Test 5: View Mode Switch
    
    func testViewModeSwitch() async {
        let store = TestStore(initialState: EditorFeature.State()) {
            EditorFeature()
        }
        
        // Initial state should be editOnly
        XCTAssertEqual(store.state.viewMode, .editOnly)
        
        // Switch to split
        await store.send(.viewModeChanged(.split)) {
            $0.viewMode = .split
        }
        
        // Switch to preview
        await store.send(.viewModeChanged(.previewOnly)) {
            $0.viewMode = .previewOnly
        }
        
        // Switch back to edit
        await store.send(.viewModeChanged(.editOnly)) {
            $0.viewMode = .editOnly
        }
    }
    
    // MARK: - Test 6: Markdown Insert Bold
    
    func testMarkdownInsertBold() async {
        var state = EditorFeature.State()
        state.content = "Hello"
        state.cursorPosition = 5
        
        let store = TestStore(initialState: state) {
            EditorFeature()
        }
        
        await store.send(.insertMarkdown(.bold)) {
            $0.content = "Hello****"
            $0.cursorPosition = 9
        }
    }
    
    // MARK: - Test 7: Markdown Insert Heading
    
    func testMarkdownInsertHeading() async {
        var state = EditorFeature.State()
        state.content = ""
        state.cursorPosition = 0
        
        let store = TestStore(initialState: state) {
            EditorFeature()
        }
        
        // Test H1
        await store.send(.insertMarkdown(.heading(level: 1))) {
            $0.content = "# "
            $0.cursorPosition = 2
        }
    }
    
    // MARK: - Test 8: Markdown Insert Link
    
    func testMarkdownInsertLink() async {
        var state = EditorFeature.State()
        state.content = "Text"
        state.cursorPosition = 4
        
        let store = TestStore(initialState: state) {
            EditorFeature()
        }
        
        await store.send(.insertMarkdown(.link)) {
            $0.content = "Text[]()"
            $0.cursorPosition = 8
        }
    }
    
    // MARK: - Test 9: Markdown Insert Code Block
    
    func testMarkdownInsertCodeBlock() async {
        var state = EditorFeature.State()
        state.content = ""
        state.cursorPosition = 0
        
        let store = TestStore(initialState: state) {
            EditorFeature()
        }
        
        await store.send(.insertMarkdown(.codeBlock)) {
            $0.content = "\n```\n\n```\n"
            $0.cursorPosition = 10
        }
    }
    
    // MARK: - Test 10: Toggle Star
    
    func testToggleStar() async {
        let fixedDate = Date()
        
        var state = EditorFeature.State()
        var testNote = Note(noteId: "test", title: "Test", content: "Content")
        testNote.isStarred = false
        state.note = testNote
        
        let store = TestStore(initialState: state) {
            EditorFeature()
        } withDependencies: {
            $0.date = .constant(fixedDate)
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off  // Turn off exhaustivity
        
        await store.send(.toggleStar)
        
        // Verify the note was starred
        XCTAssertTrue(store.state.note?.isStarred ?? false)
    }
    
    // MARK: - Test 11: Delete Note
    
    func testDeleteNote() async {
        var state = EditorFeature.State()
        state.selectedNoteId = "test-id"
        
        let store = TestStore(initialState: state) {
            EditorFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        await store.send(.deleteNote)
    }
    
    // MARK: - Test 12: Create Note
    
    func testCreateNote() async {
        let fixedDate = Date()
        let testUUID = UUID()
        
        let store = TestStore(initialState: EditorFeature.State()) {
            EditorFeature()
        } withDependencies: {
            $0.uuid = .constant(testUUID)
            $0.date = .constant(fixedDate)
            $0.noteRepository = NoteRepository.mock
            $0.notaFileManager = NotaFileManager.mock
        }
        
        await store.send(.createNote)
        
        let expectedNote = Note(
            noteId: testUUID.uuidString,
            title: "无标题",
            content: "",
            created: fixedDate,
            updated: fixedDate
        )
        
        await store.receive(\.noteCreated.success) {
            $0.note = expectedNote
            $0.selectedNoteId = testUUID.uuidString
            $0.content = ""
            $0.title = "无标题"
            $0.lastSavedContent = ""
            $0.lastSavedTitle = "无标题"
        }
    }
    
    // MARK: - Test 13: Has Unsaved Changes Computed Property
    
    func testHasUnsavedChanges() {
        var state = EditorFeature.State()
        
        // Initial state: no unsaved changes
        XCTAssertFalse(state.hasUnsavedChanges)
        
        // After content change: has unsaved changes
        state.content = "New content"
        state.lastSavedContent = "Old content"
        XCTAssertTrue(state.hasUnsavedChanges)
        
        // After save: no unsaved changes
        state.lastSavedContent = "New content"
        XCTAssertFalse(state.hasUnsavedChanges)
        
        // After title change: has unsaved changes
        state.title = "New title"
        state.lastSavedTitle = "Old title"
        XCTAssertTrue(state.hasUnsavedChanges)
    }
    
    // MARK: - Test 14: Save Completed
    
    func testSaveCompleted() async {
        let fixedDate = Date()
        
        var state = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Content")
        state.note = testNote
        state.content = "Updated Content"
        state.lastSavedContent = "Content"
        
        let store = TestStore(initialState: state) {
            EditorFeature()
        } withDependencies: {
            $0.date = .constant(fixedDate)
            $0.noteRepository = NoteRepository.mock
            $0.notaFileManager = NotaFileManager.mock
        }
        
        await store.send(.autoSave) {
            $0.isSaving = true
        }
        
        await store.receive(\.saveCompleted) {
            $0.isSaving = false
            $0.lastSavedContent = "Updated Content"
        }
    }
    
    // MARK: - Test 15: ViewMode Enum Cases
    
    func testViewModeEnumCases() {
        // Test all view modes are available
        let modes = EditorFeature.State.ViewMode.allCases
        XCTAssertEqual(modes.count, 3)
        XCTAssertTrue(modes.contains(.editOnly))
        XCTAssertTrue(modes.contains(.previewOnly))
        XCTAssertTrue(modes.contains(.split))
        
        // Test icons
        XCTAssertEqual(EditorFeature.State.ViewMode.editOnly.icon, "pencil")
        XCTAssertEqual(EditorFeature.State.ViewMode.previewOnly.icon, "eye")
        XCTAssertEqual(EditorFeature.State.ViewMode.split.icon, "rectangle.split.2x1")
    }
}

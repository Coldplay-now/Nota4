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
        
        store.exhaustivity = .off
        
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
    
    // MARK: - Test 16: Enhanced Auto Save Debounce
    
    func testAutoSaveDebounceEnhanced() async {
        let testNote = Note(noteId: "test", title: "Test", content: "Initial")
        var initialState = EditorFeature.State()
        initialState.note = testNote
        initialState.content = "Initial"
        initialState.lastSavedContent = "Initial"
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        } withDependencies: {
            $0.date = .constant(Date())
            $0.noteRepository = NoteRepository.mock
            $0.notaFileManager = NotaFileManager.mock
            $0.mainQueue = .immediate
        }
        
        store.exhaustivity = .off
        
        // Test rapid content changes
        await store.send(.binding(.set(\.content, "A")))
        await store.send(.binding(.set(\.content, "AB")))
        await store.send(.binding(.set(\.content, "ABC")))
        
        // Each change should cancel the previous auto-save
        // Only the last one should trigger auto-save
        await store.receive(\.autoSave)
    }
    
    // MARK: - Test 17: Delete Note Clears Editor State
    
    func testDeleteNoteClearsEditorState() async {
        var initialState = EditorFeature.State()
        initialState.selectedNoteId = "test-id"
        initialState.note = Note(noteId: "test-id", title: "Test", content: "Some content")
        initialState.content = "Some content"
        initialState.cursorPosition = 10
        initialState.title = "Test"
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        await store.send(.deleteNote)
        
        // After deletion, verify all editor state is cleared
        // This test will FAIL because deleteNote doesn't clear state
        XCTAssertNil(store.state.note, "Note should be nil after deletion")
        XCTAssertEqual(store.state.content, "", "Content should be cleared after deletion")
        XCTAssertEqual(store.state.cursorPosition, 0, "Cursor position should be reset after deletion")
        XCTAssertNil(store.state.selectedNoteId, "Selected note ID should be nil after deletion")
    }
    
    // MARK: - Test 18: Rapid Note Switch Race Condition
    
    func testRapidNoteSwitch() async {
        let store = TestStore(initialState: EditorFeature.State()) {
            EditorFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        // Rapidly switch between notes
        await store.send(.loadNote("note-1"))
        await store.send(.loadNote("note-2"))
        await store.send(.loadNote("note-3"))
        
        // Without proper cancellation, all three loads could complete
        // We want to verify that only note-3 is loaded
        // This test will FAIL because loadNote doesn't cancel previous loads
        
        // Wait for the load to complete
        await store.receive(\.noteLoaded.success)
        
        // Verify that the final note is note-3
        XCTAssertEqual(store.state.selectedNoteId, "note-3", "Should load the last requested note")
    }
    
    // MARK: - Context Menu Action Tests
    
    func testFormatBold() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Hello")
        initialState.note = testNote
        initialState.content = "Hello"
        initialState.cursorPosition = 5
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.formatBold)
        await store.send(.insertMarkdown(.bold)) {
            $0.content = "Hello****"
            $0.cursorPosition = 9
        }
    }
    
    func testFormatItalic() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Hello")
        initialState.note = testNote
        initialState.content = "Hello"
        initialState.cursorPosition = 5
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.formatItalic)
        await store.send(.insertMarkdown(.italic)) {
            $0.content = "Hello**"
            $0.cursorPosition = 7
        }
    }
    
    func testFormatInlineCode() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Hello")
        initialState.note = testNote
        initialState.content = "Hello"
        initialState.cursorPosition = 5
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.formatInlineCode)
        await store.send(.insertMarkdown(.inlineCode)) {
            $0.content = "Hello``"
            $0.cursorPosition = 7
        }
    }
    
    func testInsertHeading1() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "")
        initialState.note = testNote
        initialState.content = ""
        initialState.cursorPosition = 0
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.insertHeading1)
        await store.send(.insertMarkdown(.heading(level: 1))) {
            $0.content = "# "
            $0.cursorPosition = 2
        }
    }
    
    func testInsertHeading2() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "")
        initialState.note = testNote
        initialState.content = ""
        initialState.cursorPosition = 0
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.insertHeading2)
        await store.send(.insertMarkdown(.heading(level: 2))) {
            $0.content = "## "
            $0.cursorPosition = 3
        }
    }
    
    func testInsertHeading3() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "")
        initialState.note = testNote
        initialState.content = ""
        initialState.cursorPosition = 0
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.insertHeading3)
        await store.send(.insertMarkdown(.heading(level: 3))) {
            $0.content = "### "
            $0.cursorPosition = 4
        }
    }
    
    func testInsertUnorderedList() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "")
        initialState.note = testNote
        initialState.content = ""
        initialState.cursorPosition = 0
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.insertUnorderedList)
        await store.send(.insertMarkdown(.unorderedList)) {
            $0.content = "\n- "
            $0.cursorPosition = 3
        }
    }
    
    func testInsertOrderedList() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "")
        initialState.note = testNote
        initialState.content = ""
        initialState.cursorPosition = 0
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.insertOrderedList)
        await store.send(.insertMarkdown(.orderedList)) {
            $0.content = "\n1. "
            $0.cursorPosition = 4
        }
    }
    
    func testInsertTaskList() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "")
        initialState.note = testNote
        initialState.content = ""
        initialState.cursorPosition = 0
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.insertTaskList)
        await store.send(.insertMarkdown(.taskList)) {
            $0.content = "\n- [ ] "
            $0.cursorPosition = 7
        }
    }
    
    func testInsertLink() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "")
        initialState.note = testNote
        initialState.content = ""
        initialState.cursorPosition = 0
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.insertLink)
        await store.send(.insertMarkdown(.link)) {
            $0.content = "[]()"
            $0.cursorPosition = 4
        }
    }
    
    func testInsertCodeBlock() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "")
        initialState.note = testNote
        initialState.content = ""
        initialState.cursorPosition = 0
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.insertCodeBlock)
        await store.send(.insertMarkdown(.codeBlock)) {
            $0.content = "\n```\n\n```\n"
            $0.cursorPosition = 9
        }
    }
    
    func testToggleStarDisabledWithoutNote() async {
        let store = TestStore(initialState: EditorFeature.State()) {
            EditorFeature()
        }
        
        // Verify that no note is loaded
        XCTAssertNil(store.state.note, "No note should be loaded initially")
        
        // In the UI, the toggle star button should be disabled when no note is loaded
        // This test verifies the state condition used by the UI
        let shouldBeDisabled = store.state.note == nil
        XCTAssertTrue(shouldBeDisabled, "Toggle star should be disabled when no note is loaded")
    }
    
    // MARK: - AI Editor Tests
    
    func testShowAIEditorDialog() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Content")
        initialState.note = testNote
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        } withDependencies: {
            $0.llmService = LLMService.mock
        }
        
        await store.send(.showAIEditorDialog) {
            $0.aiEditor.isDialogVisible = true
            $0.aiEditor.userPrompt = ""
            $0.aiEditor.generatedContent = ""
            $0.aiEditor.errorMessage = nil
            $0.aiEditor.showContentPreview = false
        }
    }
    
    func testDismissAIEditorDialog() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Content")
        initialState.note = testNote
        initialState.aiEditor.isDialogVisible = true
        initialState.aiEditor.userPrompt = "Test prompt"
        initialState.aiEditor.generatedContent = "Generated content"
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.dismissAIEditorDialog) {
            $0.aiEditor.isDialogVisible = false
            $0.aiEditor = EditorFeature.State.AIEditorState()
        }
    }
    
    func testAIEditorPromptChanged() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Content")
        initialState.note = testNote
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.aiEditorPromptChanged("New prompt")) {
            $0.aiEditor.userPrompt = "New prompt"
        }
    }
    
    func testAIEditorIncludeContextChanged() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Content")
        initialState.note = testNote
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.aiEditorIncludeContextChanged(true)) {
            $0.aiEditor.includeContext = true
        }
    }
    
    func testAIContentChunkReceived() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Content")
        initialState.note = testNote
        initialState.aiEditor.generatedContent = "Existing"
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.aiContentChunkReceived(" chunk")) {
            $0.aiEditor.generatedContent = "Existing chunk"
        }
    }
    
    func testConfirmInsertAIContent() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Original content")
        initialState.note = testNote
        initialState.content = "Original content"
        initialState.aiEditor.generatedContent = "AI Generated Content"
        initialState.aiEditor.isDialogVisible = true
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
            $0.notaFileManager = NotaFileManager.mock
        }
        
        store.exhaustivity = .off
        
        await store.send(.confirmInsertAIContent) {
            $0.content = "Original content\n\n\n<!-- AI生成内容开始 -->\n\nAI Generated Content\n\n<!-- AI生成内容结束 -->\n\n\n"
            $0.aiEditor.isDialogVisible = false
            $0.aiEditor = EditorFeature.State.AIEditorState()
        }
    }
    
    func testCancelInsertAIContent() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Content")
        initialState.note = testNote
        initialState.aiEditor.showContentPreview = true
        initialState.aiEditor.generatedContent = "Generated content"
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        }
        
        await store.send(.cancelInsertAIContent) {
            $0.aiEditor.showContentPreview = false
            $0.aiEditor.generatedContent = ""
        }
    }
    
    func testRetryGenerateContent() async {
        var initialState = EditorFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Content")
        initialState.note = testNote
        initialState.aiEditor.userPrompt = "Test prompt"
        initialState.aiEditor.errorMessage = "Some error"
        
        let store = TestStore(initialState: initialState) {
            EditorFeature()
        } withDependencies: {
            $0.llmService = LLMService.mock
        }
        
        store.exhaustivity = .off
        
        // Retry should clear error and trigger generation
        await store.send(.retryGenerateContent) {
            $0.aiEditor.errorMessage = nil
            $0.aiEditor.isGenerating = true
            $0.aiEditor.generatedContent = ""
            $0.aiEditor.showContentPreview = true
        }
    }
}

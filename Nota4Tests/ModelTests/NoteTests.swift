import XCTest
@testable import Nota4

final class NoteTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testNoteInitialization() {
        let note = Note(
            noteId: "test-id",
            title: "Test Note",
            content: "Test content"
        )
        
        XCTAssertEqual(note.noteId, "test-id")
        XCTAssertEqual(note.title, "Test Note")
        XCTAssertEqual(note.content, "Test content")
        XCTAssertNil(note.id)
        XCTAssertFalse(note.isStarred)
        XCTAssertFalse(note.isPinned)
        XCTAssertFalse(note.isDeleted)
        XCTAssertTrue(note.tags.isEmpty)
    }
    
    func testNoteDefaultInitialization() {
        let note = Note()
        
        XCTAssertFalse(note.noteId.isEmpty)
        XCTAssertEqual(note.title, "")
        XCTAssertEqual(note.content, "")
        XCTAssertFalse(note.isStarred)
        XCTAssertFalse(note.isPinned)
        XCTAssertFalse(note.isDeleted)
    }
    
    // MARK: - Computed Properties Tests
    
    func testPreview() {
        let note = Note(
            title: "Test",
            content: "Line 1\nLine 2\nLine 3\nLine 4"
        )
        
        let preview = note.preview
        XCTAssertTrue(preview.contains("Line 1"))
        XCTAssertTrue(preview.contains("Line 2"))
        XCTAssertTrue(preview.contains("Line 3"))
        XCTAssertTrue(preview.count <= 100)
    }
    
    func testPreviewWithLongContent() {
        let longContent = String(repeating: "a", count: 200)
        let note = Note(content: longContent)
        
        let preview = note.preview
        XCTAssertEqual(preview.count, 100)
    }
    
    func testFileName() {
        let note = Note(noteId: "ABC-123")
        XCTAssertEqual(note.fileName, "ABC-123.nota")
    }
    
    // MARK: - Equatable Tests
    
    func testEquality() {
        let date = Date()
        let note1 = Note(noteId: "test-1", title: "Test", created: date, updated: date)
        let note2 = Note(noteId: "test-1", title: "Test", created: date, updated: date)
        
        XCTAssertEqual(note1, note2)
    }
    
    func testInequality() {
        let note1 = Note(noteId: "test-1", title: "Test 1")
        let note2 = Note(noteId: "test-2", title: "Test 2")
        
        XCTAssertNotEqual(note1, note2)
    }
    
    // MARK: - Codable Tests
    
    func testEncodingDecoding() throws {
        let note = Note(
            noteId: "test-id",
            title: "Test Note",
            content: "Test content",
            isStarred: true,
            tags: ["tag1", "tag2"]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(note)
        
        let decoder = JSONDecoder()
        let decodedNote = try decoder.decode(Note.self, from: data)
        
        XCTAssertEqual(note.noteId, decodedNote.noteId)
        XCTAssertEqual(note.title, decodedNote.title)
        XCTAssertEqual(note.content, decodedNote.content)
        XCTAssertEqual(note.isStarred, decodedNote.isStarred)
        XCTAssertEqual(note.tags, decodedNote.tags)
    }
    
    // MARK: - Hashable Tests
    
    func testHashable() {
        let note1 = Note(noteId: "test-1")
        let note2 = Note(noteId: "test-2")
        let note3 = Note(noteId: "test-1")
        
        var set = Set<Note>()
        set.insert(note1)
        set.insert(note2)
        set.insert(note3)
        
        XCTAssertEqual(set.count, 2) // note1 和 note3 相同
    }
    
    // MARK: - Tags Tests
    
    func testTagsManipulation() {
        var note = Note()
        
        note.tags.insert("tag1")
        note.tags.insert("tag2")
        
        XCTAssertEqual(note.tags.count, 2)
        XCTAssertTrue(note.tags.contains("tag1"))
        XCTAssertTrue(note.tags.contains("tag2"))
        
        note.tags.remove("tag1")
        XCTAssertEqual(note.tags.count, 1)
        XCTAssertFalse(note.tags.contains("tag1"))
    }
    
    // MARK: - Mock Data Tests
    
    #if DEBUG
    func testMockData() {
        XCTAssertEqual(Note.mock.noteId, "mock-note-1")
        XCTAssertEqual(Note.mock.title, "测试笔记")
        
        XCTAssertEqual(Note.mockData.count, 3)
        XCTAssertTrue(Note.mockData[0].isStarred)
        XCTAssertTrue(Note.mockData[0].isPinned)
    }
    #endif
}


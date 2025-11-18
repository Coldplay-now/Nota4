import XCTest
@testable import Nota4

final class NotaFileManagerTests: XCTestCase {
    
    // MARK: - Test 1: File Manager Initialization
    
    func testFileManagerInitialization() {
        let fileManager = NotaFileManager.mock
        XCTAssertNotNil(fileManager)
    }
    
    // MARK: - Test 2: Create Note File
    
    func testCreateNoteFile() async throws {
        let fileManager = NotaFileManager.mock
        let testNote = Note(
            noteId: "test-file-creation",
            title: "Test Note",
            content: "Test Content"
        )
        
        // Should not throw
        try await fileManager.createNoteFile(testNote)
    }
    
    // MARK: - Test 3: Read Note File
    
    func testReadNoteFile() async throws {
        let fileManager = NotaFileManager.mock
        
        // Mock should return a default value
        let content = try await fileManager.readNoteFile(noteId: "test-id")
        XCTAssertNotNil(content)
    }
    
    // MARK: - Test 4: Update Note File
    
    func testUpdateNoteFile() async throws {
        let fileManager = NotaFileManager.mock
        let testNote = Note(
            noteId: "test-update",
            title: "Updated Title",
            content: "Updated Content"
        )
        
        // Should not throw
        try await fileManager.updateNoteFile(testNote)
    }
    
    // MARK: - Test 5: Delete Note File
    
    func testDeleteNoteFile() async throws {
        let fileManager = NotaFileManager.mock
        
        // Should not throw
        try await fileManager.deleteNoteFile(noteId: "test-delete")
    }
}








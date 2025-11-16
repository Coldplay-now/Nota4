import XCTest
@testable import Nota4

final class ExportServiceTests: XCTestCase {
    var exportService: ExportServiceMock!
    
    override func setUp() async throws {
        exportService = ExportServiceMock()
    }
    
    override func tearDown() async throws {
        exportService = nil
    }
    
    // MARK: - Export .nota File Tests
    
    func testExportAsNotaSuccess() async throws {
        // Given
        let note = Note(noteId: "test-id", title: "Test Note", content: "Test Content")
        let testURL = URL(fileURLWithPath: "/test/note.nota")
        
        // When
        try await exportService.exportAsNota(note: note, to: testURL)
        
        // Then
        let notesCount = await exportService.exportedNotes.count
        let firstNoteId = await exportService.exportedNotes.first?.noteId
        let firstURL = await exportService.exportedURLs.first
        XCTAssertEqual(notesCount, 1)
        XCTAssertEqual(firstNoteId, "test-id")
        XCTAssertEqual(firstURL, testURL)
    }
    
    func testExportAsNotaWithError() async throws {
        // Given
        let note = Note(noteId: "test-id", title: "Test Note", content: "Test Content")
        let testURL = URL(fileURLWithPath: "/test/note.nota")
        await exportService.setShouldThrowError(true)
        await exportService.setErrorToThrow(ExportServiceError.fileWriteFailed)
        
        // When/Then
        do {
            try await exportService.exportAsNota(note: note, to: testURL)
            XCTFail("Should throw file write failed error")
        } catch let error as ExportServiceError {
            XCTAssertEqual(error, ExportServiceError.fileWriteFailed)
        }
    }
    
    // MARK: - Export Markdown File Tests
    
    func testExportAsMarkdownSuccess() async throws {
        // Given
        let note = Note(noteId: "test-id", title: "Test Note", content: "Test Content")
        let testURL = URL(fileURLWithPath: "/test/note.md")
        
        // When
        try await exportService.exportAsMarkdown(note: note, to: testURL, includeMetadata: true)
        
        // Then
        let notesCount = await exportService.exportedNotes.count
        let firstTitle = await exportService.exportedNotes.first?.title
        let firstURL = await exportService.exportedURLs.first
        XCTAssertEqual(notesCount, 1)
        XCTAssertEqual(firstTitle, "Test Note")
        XCTAssertEqual(firstURL, testURL)
    }
    
    func testExportAsMarkdownWithoutMetadata() async throws {
        // Given
        let note = Note(noteId: "test-id", title: "Test Note", content: "Test Content")
        let testURL = URL(fileURLWithPath: "/test/note.md")
        
        // When
        try await exportService.exportAsMarkdown(note: note, to: testURL, includeMetadata: false)
        
        // Then
        let count = await exportService.exportedNotes.count
        XCTAssertEqual(count, 1)
    }
    
    // MARK: - Batch Export Tests
    
    func testExportMultipleNotesSuccess() async throws {
        // Given
        let notes = [
            Note(noteId: "test-1", title: "Note 1", content: "Content 1"),
            Note(noteId: "test-2", title: "Note 2", content: "Content 2"),
            Note(noteId: "test-3", title: "Note 3", content: "Content 3")
        ]
        let directoryURL = URL(fileURLWithPath: "/test/exports/")
        
        // When
        try await exportService.exportMultipleNotes(
            notes: notes,
            to: directoryURL,
            format: .nota
        )
        
        // Then
        let notesCount = await exportService.exportedNotes.count
        let firstURL = await exportService.exportedURLs.first
        XCTAssertEqual(notesCount, 3)
        XCTAssertEqual(firstURL, directoryURL)
    }
    
    func testExportMultipleNotesWithError() async throws {
        // Given
        let notes = [
            Note(noteId: "test-1", title: "Note 1", content: "Content 1")
        ]
        let directoryURL = URL(fileURLWithPath: "/test/exports/")
        await exportService.setShouldThrowError(true)
        
        // When/Then
        do {
            try await exportService.exportMultipleNotes(
                notes: notes,
                to: directoryURL,
                format: .nota
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testExportServiceErrors() {
        let errors: [ExportServiceError] = [
            .invalidURL,
            .fileWriteFailed,
            .yamlSerializationFailed,
            .permissionDenied
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
        }
    }
}


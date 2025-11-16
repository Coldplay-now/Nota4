import XCTest
@testable import Nota4

final class ImportServiceTests: XCTestCase {
    var importService: ImportServiceMock!
    
    override func setUp() async throws {
        importService = ImportServiceMock()
    }
    
    override func tearDown() async throws {
        importService = nil
    }
    
    // MARK: - Import .nota File Tests
    
    func testImportNotaFileSuccess() async throws {
        // Given
        let testURL = URL(fileURLWithPath: "/test/note.nota")
        
        // When
        let note = try await importService.importNotaFile(from: testURL)
        
        // Then
        XCTAssertEqual(note.title, "Imported Note")
        XCTAssertEqual(note.content, "Test Content")
        let count = await importService.importedNotes.count
        XCTAssertEqual(count, 1)
    }
    
    func testImportNotaFileWithInvalidExtension() async throws {
        // Given
        let testURL = URL(fileURLWithPath: "/test/note.txt")
        await importService.setShouldThrowError(true)
        await importService.setErrorToThrow(ImportServiceError.invalidFileType)
        
        // When/Then
        do {
            _ = try await importService.importNotaFile(from: testURL)
            XCTFail("Should throw invalid file type error")
        } catch let error as ImportServiceError {
            XCTAssertEqual(error, ImportServiceError.invalidFileType)
        }
    }
    
    // MARK: - Import Markdown File Tests
    
    func testImportMarkdownFileSuccess() async throws {
        // Given
        let testURL = URL(fileURLWithPath: "/test/note.md")
        
        // When
        let note = try await importService.importMarkdownFile(from: testURL)
        
        // Then
        XCTAssertEqual(note.title, "note") // deletingPathExtension removes .md
        XCTAssertEqual(note.content, "Markdown Content")
        let count = await importService.importedNotes.count
        XCTAssertEqual(count, 1)
    }
    
    func testImportMarkdownFileWithMarkdownExtension() async throws {
        // Given
        let testURL = URL(fileURLWithPath: "/test/note.markdown")
        
        // When
        let note = try await importService.importMarkdownFile(from: testURL)
        
        // Then
        XCTAssertEqual(note.title, "note")
        let count = await importService.importedNotes.count
        XCTAssertEqual(count, 1)
    }
    
    // MARK: - Batch Import Tests
    
    func testImportMultipleFilesSuccess() async throws {
        // Given
        let urls = [
            URL(fileURLWithPath: "/test/note1.nota"),
            URL(fileURLWithPath: "/test/note2.md"),
            URL(fileURLWithPath: "/test/note3.nota")
        ]
        
        // When
        let notes = try await importService.importMultipleFiles(from: urls)
        
        // Then
        XCTAssertEqual(notes.count, 3)
        let count = await importService.importedNotes.count
        XCTAssertEqual(count, 3)
    }
    
    func testImportMultipleFilesWithError() async throws {
        // Given
        let urls = [
            URL(fileURLWithPath: "/test/note1.nota"),
            URL(fileURLWithPath: "/test/note2.md")
        ]
        await importService.setShouldThrowError(true)
        
        // When/Then
        do {
            _ = try await importService.importMultipleFiles(from: urls)
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testImportServiceErrors() {
        let errors: [ImportServiceError] = [
            .invalidFileType,
            .fileReadFailed,
            .yamlParsingFailed,
            .noteCreationFailed,
            .conflictDetected(noteId: "test-id")
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
        }
    }
}


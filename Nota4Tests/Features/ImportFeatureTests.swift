import XCTest
import ComposableArchitecture
@testable import Nota4

@MainActor
final class ImportFeatureTests: XCTestCase {
    
    func testImportFiles() async {
        let testURL = URL(fileURLWithPath: "/test/note.nota")
        let mockService = ImportServiceMock()
        
        let store = TestStore(initialState: ImportFeature.State()) {
            ImportFeature()
        } withDependencies: {
            $0.importService = mockService
            $0.mainQueue = .immediate
        }
        
        await store.send(.importFiles([testURL])) {
            $0.isImporting = true
            $0.errorMessage = nil
            $0.importProgress = 0.0
        }
        
        await store.receive(\.importStarted)
        
        // 接收进度更新
        for i in 1...10 {
            await store.receive(\.importProgress) {
                $0.importProgress = Double(i) / 10.0
            }
        }
        
        await store.receive(\.importCompleted) {
            $0.isImporting = false
            $0.importProgress = 1.0
            // Verify the imported notes
            XCTAssertEqual($0.importedNotes.count, 1)
            XCTAssertEqual($0.importedNotes.first?.title, "Imported Note")
        }
    }
    
    func testImportFilesFailure() async {
        let testURL = URL(fileURLWithPath: "/test/note.txt")
        let mockService = ImportServiceMock()
        await mockService.setShouldThrowError(true)
        await mockService.setErrorToThrow(ImportServiceError.invalidFileType)
        
        let store = TestStore(initialState: ImportFeature.State()) {
            ImportFeature()
        } withDependencies: {
            $0.importService = mockService
            $0.mainQueue = .immediate
        }
        
        await store.send(.importFiles([testURL])) {
            $0.isImporting = true
            $0.errorMessage = nil
            $0.importProgress = 0.0
        }
        
        await store.receive(\.importStarted)
        
        // 接收进度更新
        for i in 1...10 {
            await store.receive(\.importProgress) {
                $0.importProgress = Double(i) / 10.0
            }
        }
        
        await store.receive(\.importFailed) {
            $0.isImporting = false
            $0.errorMessage = "不支持的文件类型"
            $0.importProgress = 0.0
        }
    }
    
    func testDismissError() async {
        let store = TestStore(
            initialState: ImportFeature.State(
                errorMessage: "Test Error"
            )
        ) {
            ImportFeature()
        }
        
        await store.send(.dismissError) {
            $0.errorMessage = nil
        }
    }
}


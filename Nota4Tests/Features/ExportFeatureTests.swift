import XCTest
import ComposableArchitecture
@testable import Nota4

@MainActor
final class ExportFeatureTests: XCTestCase {
    
    func testExportNotes() async {
        let testNotes = [
            Note(noteId: "test-1", title: "Note 1", content: "Content 1"),
            Note(noteId: "test-2", title: "Note 2", content: "Content 2")
        ]
        let testURL = URL(fileURLWithPath: "/test/exports/")
        let mockService = ExportServiceMock()
        
        let store = TestStore(
            initialState: ExportFeature.State(notesToExport: testNotes)
        ) {
            ExportFeature()
        } withDependencies: {
            $0.exportService = mockService
            $0.mainQueue = .immediate
        }
        
        await store.send(.exportToDirectory(testURL)) {
            $0.isExporting = true
            $0.errorMessage = nil
            $0.exportProgress = 0.0
            $0.exportCompleted = false
        }
        
        await store.receive(\.exportStarted)
        
        // 接收进度更新
        for i in 1...10 {
            await store.receive(\.exportProgress) {
                $0.exportProgress = Double(i) / 10.0
            }
        }
        
        await store.receive(\.exportCompleted) {
            $0.isExporting = false
            $0.exportCompleted = true
            $0.exportProgress = 1.0
        }
    }
    
    func testExportNotesFailure() async {
        let testNotes = [Note(noteId: "test-1", title: "Note 1", content: "Content 1")]
        let testURL = URL(fileURLWithPath: "/test/exports/")
        let mockService = ExportServiceMock()
        await mockService.setShouldThrowError(true)
        await mockService.setErrorToThrow(ExportServiceError.fileWriteFailed)
        
        let store = TestStore(
            initialState: ExportFeature.State(notesToExport: testNotes)
        ) {
            ExportFeature()
        } withDependencies: {
            $0.exportService = mockService
            $0.mainQueue = .immediate
        }
        
        await store.send(.exportToDirectory(testURL)) {
            $0.isExporting = true
            $0.errorMessage = nil
            $0.exportProgress = 0.0
            $0.exportCompleted = false
        }
        
        await store.receive(\.exportStarted)
        
        // 接收进度更新
        for i in 1...10 {
            await store.receive(\.exportProgress) {
                $0.exportProgress = Double(i) / 10.0
            }
        }
        
        await store.receive(\.exportFailed) {
            $0.isExporting = false
            $0.errorMessage = "文件写入失败"
            $0.exportProgress = 0.0
        }
    }
    
    func testDismissError() async {
        let testNotes = [Note(noteId: "test-1", title: "Note 1", content: "Content 1")]
        var initialState = ExportFeature.State(notesToExport: testNotes)
        initialState.errorMessage = "Test Error"
        
        let store = TestStore(initialState: initialState) {
            ExportFeature()
        }
        
        await store.send(.dismissError) {
            $0.errorMessage = nil
        }
    }
}


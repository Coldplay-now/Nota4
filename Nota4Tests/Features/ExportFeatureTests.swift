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
    
    // MARK: - Single File Export Tests
    
    func testExportToFileHTML() async {
        let testNote = Note(noteId: "test-1", title: "Note 1", content: "Content 1")
        let testURL = URL(fileURLWithPath: "/test/note.html")
        let mockService = ExportServiceMock()
        
        let store = TestStore(
            initialState: ExportFeature.State(notesToExport: [testNote])
        ) {
            ExportFeature()
        } withDependencies: {
            $0.exportService = mockService
            $0.mainQueue = .immediate
        }
        
        await store.send(.exportToFile(testURL, .html)) {
            $0.isExporting = true
            $0.errorMessage = nil
            $0.exportProgress = 0.0
            $0.exportCompleted = false
        }
        
        await store.receive(\.exportStarted)
        await store.receive(\.exportProgress) { $0.exportProgress = 1.0 }
        await store.receive(\.exportCompleted) {
            $0.isExporting = false
            $0.exportCompleted = true
            $0.exportProgress = 1.0
        }
    }
    
    // MARK: - Options Update Tests
    
    func testUpdateHTMLOptions() async {
        let testNotes = [Note(noteId: "test-1", title: "Note 1", content: "Content 1")]
        let store = TestStore(
            initialState: ExportFeature.State(notesToExport: testNotes)
        ) {
            ExportFeature()
        }
        
        var newOptions = HTMLExportOptions()
        newOptions.includeTOC = true
        newOptions.imageHandling = .base64
        
        await store.send(.updateHTMLOptions(newOptions)) {
            $0.htmlOptions = newOptions
        }
    }
    
    func testUpdatePDFOptions() async {
        let testNotes = [Note(noteId: "test-1", title: "Note 1", content: "Content 1")]
        let store = TestStore(
            initialState: ExportFeature.State(notesToExport: testNotes)
        ) {
            ExportFeature()
        }
        
        var newOptions = PDFExportOptions()
        newOptions.includeTOC = true
        newOptions.paperSize = PDFExportOptions.letterSize
        
        await store.send(.updatePDFOptions(newOptions)) {
            $0.pdfOptions = newOptions
        }
    }
    
    func testUpdatePNGOptions() async {
        let testNotes = [Note(noteId: "test-1", title: "Note 1", content: "Content 1")]
        let store = TestStore(
            initialState: ExportFeature.State(notesToExport: testNotes)
        ) {
            ExportFeature()
        }
        
        var newOptions = PNGExportOptions()
        newOptions.includeTOC = true
        newOptions.width = 1600
        newOptions.backgroundColor = "#FFFFFF"
        
        await store.send(.updatePNGOptions(newOptions)) {
            $0.pngOptions = newOptions
        }
    }
}


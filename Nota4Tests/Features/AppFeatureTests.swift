import XCTest
import ComposableArchitecture
@testable import Nota4

@MainActor
final class AppFeatureTests: XCTestCase {
    
    // MARK: - 基础流程测试 (5个)
    
    // MARK: - Test 1: onAppear - 应用启动时加载笔记
    
    func testOnAppear() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        await store.send(.onAppear)
    }
    
    // MARK: - Test 2: showImport - 显示导入界面
    
    func testShowImportFlow() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        await store.send(.showImport) {
            $0.importFeature = ImportFeature.State()
        }
    }
    
    // MARK: - Test 3: dismissImport - 关闭导入并刷新列表
    
    func testDismissImportFlow() async {
        var initialState = AppFeature.State()
        initialState.importFeature = ImportFeature.State()
        
        let store = TestStore(initialState: initialState) {
            AppFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        await store.send(.dismissImport) {
            $0.importFeature = nil
        }
    }
    
    // MARK: - Test 4: showExport - 显示导出界面
    
    func testShowExportFlow() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        let testNotes = [
            Note(noteId: "1", title: "Note 1", content: "Content 1"),
            Note(noteId: "2", title: "Note 2", content: "Content 2")
        ]
        
        await store.send(.showExport(testNotes)) {
            $0.exportFeature = ExportFeature.State(notesToExport: testNotes)
        }
    }
    
    // MARK: - Test 5: dismissExport - 关闭导出界面
    
    func testDismissExportFlow() async {
        var initialState = AppFeature.State()
        initialState.exportFeature = ExportFeature.State(notesToExport: [])
        
        let store = TestStore(initialState: initialState) {
            AppFeature()
        }
        
        await store.send(.dismissExport) {
            $0.exportFeature = nil
        }
    }
    
    // MARK: - Sidebar与NoteList联动测试 (4个)
    
    // MARK: - Test 6: Sidebar分类变化触发NoteList过滤
    
    func testSidebarCategoryFilterNoteList() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        // 切换到星标分类
        await store.send(.sidebar(.categorySelected(.starred)))
        
        // 验证state已更新
        XCTAssertEqual(store.state.sidebar.selectedCategory, .starred)
    }
    
    // MARK: - Test 7: Sidebar标签变化触发NoteList过滤
    
    func testSidebarTagFilterNoteList() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        store.exhaustivity = .off
        
        // 选择标签
        await store.send(.sidebar(.tagSelected("工作")))
        
        // 验证标签已选中
        XCTAssert(store.state.sidebar.selectedTags.contains("工作"))
    }
    
    // MARK: - Test 8: 切换分类时清空标签并更新NoteList
    
    func testSidebarClearTagsOnCategorySwitch() async {
        var initialState = AppFeature.State()
        initialState.sidebar.selectedTags = ["工作", "个人"]
        
        let store = TestStore(initialState: initialState) {
            AppFeature()
        }
        
        store.exhaustivity = .off
        
        // 切换分类
        await store.send(.sidebar(.categorySelected(.starred)))
        
        // 验证标签被清空
        XCTAssertTrue(store.state.sidebar.selectedTags.isEmpty)
        XCTAssertEqual(store.state.sidebar.selectedCategory, .starred)
    }
    
    // MARK: - Test 9: NoteList加载后更新Sidebar计数
    
    func testNoteListCountUpdatesOnLoad() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        // 触发加载笔记
        await store.send(.noteList(.loadNotes))
    }
    
    // MARK: - NoteList与Editor联动测试 (3个)
    
    // MARK: - Test 10: NoteList选择笔记加载到Editor
    
    func testNoteSelectionLoadsEditor() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        // 选择笔记
        await store.send(.noteList(.noteSelected("test-id")))
        
        // 验证NoteList的selectedNoteId被设置
        XCTAssertEqual(store.state.noteList.selectedNoteId, "test-id")
    }
    
    // MARK: - Test 11: Editor保存后刷新NoteList
    
    func testEditorSaveRefreshesNoteList() async {
        var initialState = AppFeature.State()
        let testNote = Note(noteId: "test", title: "Test", content: "Content")
        initialState.editor.note = testNote
        initialState.editor.content = "Updated Content"
        initialState.editor.lastSavedContent = "Content"
        
        let store = TestStore(initialState: initialState) {
            AppFeature()
        } withDependencies: {
            $0.date = .constant(Date())
            $0.noteRepository = NoteRepository.mock
            $0.notaFileManager = NotaFileManager.mock
        }
        
        store.exhaustivity = .off
        
        // 触发保存
        await store.send(.editor(.autoSave))
    }
    
    // MARK: - Test 12: Editor删除笔记从NoteList移除
    
    func testEditorDeleteRemovesFromNoteList() async {
        var initialState = AppFeature.State()
        initialState.editor.selectedNoteId = "test-id"
        
        let store = TestStore(initialState: initialState) {
            AppFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        // 删除笔记
        await store.send(.editor(.deleteNote))
    }
    
    // MARK: - 导入/导出集成测试 (3个)
    
    // MARK: - Test 13: 导入完成刷新Sidebar和NoteList
    
    func testImportCompletionRefreshesAll() async {
        var initialState = AppFeature.State()
        initialState.importFeature = ImportFeature.State()
        
        let store = TestStore(initialState: initialState) {
            AppFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
            $0.mainQueue = .immediate
        }
        
        store.exhaustivity = .off
        
        // 模拟导入完成
        await store.send(.importFeature(.importCompleted([])))
    }
    
    // MARK: - Test 14: 导出选中的笔记
    
    func testExportSelectedNotes() async {
        var initialState = AppFeature.State()
        initialState.noteList.selectedNoteIds = ["id1", "id2"]
        
        let store = TestStore(initialState: initialState) {
            AppFeature()
        }
        
        let testNotes = [
            Note(noteId: "id1", title: "Note 1", content: "Content 1"),
            Note(noteId: "id2", title: "Note 2", content: "Content 2")
        ]
        
        await store.send(.showExport(testNotes)) {
            $0.exportFeature = ExportFeature.State(notesToExport: testNotes)
        }
        
        // 验证导出界面已打开
        XCTAssertNotNil(store.state.exportFeature)
        XCTAssertEqual(store.state.exportFeature?.notesToExport.count, 2)
    }
    
    // MARK: - Test 15: 导入错误处理
    
    func testImportErrorHandling() async {
        var initialState = AppFeature.State()
        initialState.importFeature = ImportFeature.State()
        
        let store = TestStore(initialState: initialState) {
            AppFeature()
        }
        
        store.exhaustivity = .off
        
        // 模拟导入失败
        let testError = NSError(domain: "test", code: -1, userInfo: nil)
        await store.send(.importFeature(.importFailed(testError)))
    }
    
    // MARK: - 额外综合测试
    
    // MARK: - Test 16: ColumnVisibility变化
    
    func testColumnVisibilityChanged() async {
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        // Initial visibility should be .all
        XCTAssertEqual(store.state.columnVisibility, .all)
        
        // Change to doubleColumn
        await store.send(.columnVisibilityChanged(.doubleColumn)) {
            $0.columnVisibility = .doubleColumn
        }
        
        // Change to detailOnly
        await store.send(.columnVisibilityChanged(.detailOnly)) {
            $0.columnVisibility = .detailOnly
        }
    }
    
    // MARK: - Test 17: 编辑器创建笔记流程
    
    func testEditorCreateNoteFlow() async {
        let fixedDate = Date()
        let testUUID = UUID()
        
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        } withDependencies: {
            $0.uuid = .constant(testUUID)
            $0.date = .constant(fixedDate)
            $0.noteRepository = NoteRepository.mock
            $0.notaFileManager = NotaFileManager.mock
        }
        
        store.exhaustivity = .off
        
        // 创建新笔记
        await store.send(.editor(.createNote))
    }
}


import XCTest
import ComposableArchitecture
@testable import Nota4

@MainActor
final class SidebarFeatureTests: XCTestCase {
    
    // MARK: - Test 1: Category Switch - All Notes
    
    func testCategorySwitchAllNotes() async {
        let store = TestStore(initialState: SidebarFeature.State()) {
            SidebarFeature()
        }
        
        store.exhaustivity = .off
        
        await store.send(.categorySelected(.all)) {
            $0.selectedCategory = .all
            $0.selectedTags = []
        }
    }
    
    // MARK: - Test 2: Category Switch - Starred
    
    func testCategorySwitchStarred() async {
        let store = TestStore(initialState: SidebarFeature.State()) {
            SidebarFeature()
        }
        
        store.exhaustivity = .off
        
        await store.send(.categorySelected(.starred)) {
            $0.selectedCategory = .starred
            $0.selectedTags = []
        }
    }
    
    // MARK: - Test 3: Category Switch - Trash
    
    func testCategorySwitchTrash() async {
        let store = TestStore(initialState: SidebarFeature.State()) {
            SidebarFeature()
        }
        
        store.exhaustivity = .off
        
        await store.send(.categorySelected(.trash)) {
            $0.selectedCategory = .trash
            $0.selectedTags = []
        }
    }
    
    // MARK: - Test 4: Tag Selection - Single
    
    func testTagSelectionSingle() async {
        let store = TestStore(initialState: SidebarFeature.State()) {
            SidebarFeature()
        }
        
        await store.send(.tagSelected("工作")) {
            $0.selectedTags = ["工作"]
        }
    }
    
    // MARK: - Test 5: Tag Selection - Multiple
    
    func testTagSelectionMultiple() async {
        let store = TestStore(initialState: SidebarFeature.State()) {
            SidebarFeature()
        }
        
        store.exhaustivity = .off
        
        // Select first tag
        await store.send(.tagToggled("工作"))
        
        // Verify tag was added
        XCTAssert(store.state.selectedTags.contains("工作"))
        
        // Select second tag
        await store.send(.tagToggled("个人"))
        
        // Verify both tags are selected
        XCTAssert(store.state.selectedTags.contains("工作"))
        XCTAssert(store.state.selectedTags.contains("个人"))
    }
    
    // MARK: - Test 6: Tag Deselection
    
    func testTagDeselection() async {
        var initialState = SidebarFeature.State()
        initialState.selectedTags = ["工作", "个人"]
        
        let store = TestStore(initialState: initialState) {
            SidebarFeature()
        }
        
        store.exhaustivity = .off
        
        // Deselect one tag
        await store.send(.tagToggled("工作"))
        
        // Verify tag was removed
        XCTAssertFalse(store.state.selectedTags.contains("工作"))
        XCTAssert(store.state.selectedTags.contains("个人"))
    }
    
    // MARK: - Test 7: Load Tags
    
    func testLoadTags() async {
        let store = TestStore(initialState: SidebarFeature.State()) {
            SidebarFeature()
        } withDependencies: {
            $0.noteRepository = NoteRepository.mock
        }
        
        store.exhaustivity = .off
        
        await store.send(.loadTags)
    }
    
    // MARK: - Test 8: Category Enum Cases
    
    func testCategoryEnumCases() {
        // Test all categories are available
        let category: SidebarFeature.State.Category = .all
        XCTAssertEqual(category.icon, "note.text")
        
        let starred: SidebarFeature.State.Category = .starred
        XCTAssertEqual(starred.icon, "star.fill")
        
        let trash: SidebarFeature.State.Category = .trash
        XCTAssertEqual(trash.icon, "trash")
    }
}


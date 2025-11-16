import ComposableArchitecture
import Foundation

@Reducer
struct ImportFeature {
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable {
        var isImporting = false
        var importedNotes: [Note] = []
        var errorMessage: String?
        var importProgress: Double = 0.0
    }
    
    // MARK: - Action
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case importFiles([URL])
        case importStarted
        case importProgress(Double)
        case importCompleted([Note])
        case importFailed(Error)
        case dismissError
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.importService) var importService
    @Dependency(\.mainQueue) var mainQueue
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .importFiles(let urls):
                print("📂 [IMPORT FEATURE] Starting import of \(urls.count) file(s)")
                for url in urls {
                    print("  - \(url.lastPathComponent)")
                }
                
                state.isImporting = true
                state.errorMessage = nil
                state.importProgress = 0.0
                
                return .run { send in
                    await send(.importStarted)
                    
                    do {
                        // 模拟进度更新
                        for i in 1...10 {
                            try await mainQueue.sleep(for: .milliseconds(100))
                            await send(.importProgress(Double(i) / 10.0))
                        }
                        
                        print("🔄 [IMPORT FEATURE] Calling importService...")
                        let notes = try await importService.importMultipleFiles(from: urls)
                        print("✅ [IMPORT FEATURE] Import completed successfully! Imported \(notes.count) note(s)")
                        for note in notes {
                            print("  ✓ \(note.title) (ID: \(note.noteId))")
                        }
                        await send(.importCompleted(notes))
                    } catch {
                        print("❌ [IMPORT FEATURE] Import failed with error: \(error)")
                        await send(.importFailed(error))
                    }
                }
                
            case .importStarted:
                return .none
                
            case .importProgress(let progress):
                state.importProgress = progress
                return .none
                
            case .importCompleted(let notes):
                print("🎉 [IMPORT FEATURE] Import completed state updated, \(notes.count) notes imported")
                state.isImporting = false
                state.importedNotes = notes
                state.importProgress = 1.0
                return .none
                
            case .importFailed(let error):
                state.isImporting = false
                state.errorMessage = error.localizedDescription
                state.importProgress = 0.0
                return .none
                
            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}

// MARK: - Dependency Key

private enum ImportServiceKey: DependencyKey {
    static let liveValue: ImportServiceProtocol = ImportServiceImpl.shared
    static let testValue: ImportServiceProtocol = ImportServiceImpl.mock
}

extension DependencyValues {
    var importService: ImportServiceProtocol {
        get { self[ImportServiceKey.self] }
        set { self[ImportServiceKey.self] = newValue }
    }
}







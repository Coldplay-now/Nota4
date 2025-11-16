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
                        
                        let notes = try await importService.importMultipleFiles(from: urls)
                        await send(.importCompleted(notes))
                    } catch {
                        await send(.importFailed(error))
                    }
                }
                
            case .importStarted:
                return .none
                
            case .importProgress(let progress):
                state.importProgress = progress
                return .none
                
            case .importCompleted(let notes):
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
    static let liveValue: ImportServiceProtocol = {
        // 这里使用一个临时的包装器来处理 async throws 初始化
        // 在实际运行时，应该在 App 启动时初始化
        class ImportServiceContainer {
            static var shared: ImportServiceProtocol = ImportServiceMock()
        }
        return ImportServiceContainer.shared
    }()
    
    static let testValue: ImportServiceProtocol = ImportServiceMock()
}

extension DependencyValues {
    var importService: ImportServiceProtocol {
        get { self[ImportServiceKey.self] }
        set { self[ImportServiceKey.self] = newValue }
    }
}







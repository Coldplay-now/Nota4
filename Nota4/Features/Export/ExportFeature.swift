import ComposableArchitecture
import Foundation

@Reducer
struct ExportFeature {
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable {
        var notesToExport: [Note]
        var isExporting = false
        var exportFormat: ExportFormat = .nota
        var includeMetadata = true
        var errorMessage: String?
        var exportProgress: Double = 0.0
        var exportCompleted = false
        
        init(notesToExport: [Note]) {
            self.notesToExport = notesToExport
        }
    }
    
    enum ExportFormat: Equatable {
        case nota
        case markdown
    }
    
    // MARK: - Action
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case selectExportLocation
        case exportToDirectory(URL)
        case exportStarted
        case exportProgress(Double)
        case exportCompleted
        case exportFailed(Error)
        case dismissError
        case dismiss
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.exportService) var exportService
    @Dependency(\.mainQueue) var mainQueue
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .selectExportLocation:
                // 这个动作由 View 处理，显示文件选择器
                return .none
                
            case .exportToDirectory(let url):
                state.isExporting = true
                state.errorMessage = nil
                state.exportProgress = 0.0
                state.exportCompleted = false
                
                let notes = state.notesToExport
                let format: Services.ExportFormat
                
                switch state.exportFormat {
                case .nota:
                    format = .nota
                case .markdown:
                    format = .markdown(includeMetadata: state.includeMetadata)
                }
                
                return .run { send in
                    await send(.exportStarted)
                    
                    do {
                        // 模拟进度更新
                        for i in 1...10 {
                            try await mainQueue.sleep(for: .milliseconds(100))
                            await send(.exportProgress(Double(i) / 10.0))
                        }
                        
                        try await exportService.exportMultipleNotes(
                            notes: notes,
                            to: url,
                            format: format
                        )
                        await send(.exportCompleted)
                    } catch {
                        await send(.exportFailed(error))
                    }
                }
                
            case .exportStarted:
                return .none
                
            case .exportProgress(let progress):
                state.exportProgress = progress
                return .none
                
            case .exportCompleted:
                state.isExporting = false
                state.exportCompleted = true
                state.exportProgress = 1.0
                return .none
                
            case .exportFailed(let error):
                state.isExporting = false
                state.errorMessage = error.localizedDescription
                state.exportProgress = 0.0
                return .none
                
            case .dismissError:
                state.errorMessage = nil
                return .none
                
            case .dismiss:
                return .none
            }
        }
    }
}

// MARK: - Dependency Key

private enum ExportServiceKey: DependencyKey {
    static let liveValue: ExportServiceProtocol = ExportServiceImpl()
    static let testValue: ExportServiceProtocol = ExportServiceMock()
}

extension DependencyValues {
    var exportService: ExportServiceProtocol {
        get { self[ExportServiceKey.self] }
        set { self[ExportServiceKey.self] = newValue }
    }
}







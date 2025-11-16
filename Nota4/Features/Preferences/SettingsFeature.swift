import ComposableArchitecture
import Foundation

/// Settings Feature - macOS 系统设置风格
@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        var selectedCategory: SettingsCategory = .editor
        var editorPreferences: EditorPreferences
        var originalEditorPreferences: EditorPreferences
        
        init(editorPreferences: EditorPreferences) {
            self.editorPreferences = editorPreferences
            self.originalEditorPreferences = editorPreferences
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case categorySelected(SettingsCategory)
        case resetToDefaults
        case exportConfig
        case importConfig
        case apply
        case cancel
        case dismiss
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .categorySelected(let category):
                state.selectedCategory = category
                return .none
                
            case .resetToDefaults:
                print("⚙️ [SETTINGS] Reset to defaults")
                state.editorPreferences = EditorPreferences()
                return .none
                
            case .exportConfig:
                print("⚙️ [SETTINGS] Export config")
                // TODO: 实现导出功能
                return .none
                
            case .importConfig:
                print("⚙️ [SETTINGS] Import config")
                // TODO: 实现导入功能
                return .none
                
            case .apply:
                print("⚙️ [SETTINGS] Applying settings")
                return .none
                
            case .cancel:
                print("⚙️ [SETTINGS] Canceling, restoring original settings")
                state.editorPreferences = state.originalEditorPreferences
                return .send(.dismiss)
                
            case .dismiss:
                return .none
            }
        }
    }
}

// MARK: - Settings Category

enum SettingsCategory: String, CaseIterable, Identifiable {
    case editor = "编辑器"
    // 未来可扩展：
    // case general = "通用"
    // case appearance = "外观"
    // case shortcuts = "快捷键"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .editor: return "textformat"
        }
    }
    
    var description: String {
        switch self {
        case .editor: return "字体、排版和布局设置"
        }
    }
}


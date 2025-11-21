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
        var theme: ThemeState = ThemeState()
        
        init(editorPreferences: EditorPreferences) {
            self.editorPreferences = editorPreferences
            self.originalEditorPreferences = editorPreferences
        }
    }
    
    // MARK: - Theme State
    
    struct ThemeState: Equatable {
        var currentThemeId: String = "builtin-light"
        var availableThemes: IdentifiedArrayOf<ThemeConfig> = []
        var isLoadingThemes: Bool = false
        var importExportState: ImportExportState = .idle
        var errorMessage: String?
        
        // Computed properties
        var currentTheme: ThemeConfig? {
            availableThemes[id: currentThemeId]
        }
        
        var builtInThemes: [ThemeConfig] {
            availableThemes.filter { $0.id.hasPrefix("builtin-") }
        }
        
        var customThemes: [ThemeConfig] {
            availableThemes.filter { !$0.id.hasPrefix("builtin-") }
        }
    }
    
    enum ImportExportState: Equatable {
        case idle
        case importing
        case exporting
        case success
        case failure(String)
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
        
        // Theme actions
        case theme(ThemeAction)
    }
    
    enum ThemeAction {
        // Lifecycle
        case onAppear
        case loadThemes
        case themesLoaded(TaskResult<[ThemeConfig]>)
        case syncCurrentTheme(String)
        
        // Theme selection
        case selectTheme(String)
        case themeSelected(TaskResult<ThemeConfig>)
        
        // Import/Export
        case importThemeButtonTapped
        case importTheme(URL)
        case importThemeResponse(TaskResult<ThemeConfig>)
        
        case exportTheme(String)
        case exportThemeResponse(TaskResult<Void>)
        
        // Delete
        case deleteTheme(String)
        case deleteThemeResponse(TaskResult<String>)
        case confirmDelete(String)
        case cancelDelete
        
        // Error handling
        case dismissError
    }
    
    @Dependency(\.themeManager) var themeManager
    @Dependency(\.mainQueue) var mainQueue
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .categorySelected(let category):
                state.selectedCategory = category
                // 当选择外观分类时，加载主题
                if category == .appearance {
                    return .send(.theme(.loadThemes))
                }
                return .none
                
            case .resetToDefaults:
                print("⚙️ [SETTINGS] Reset to defaults")
                state.editorPreferences = EditorPreferences()
                return .none
                
            case .exportConfig:
                // 导出配置通过 View 层的文件选择器处理
                return .none
                
            case .importConfig:
                // 导入配置通过 View 层的文件选择器处理
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
            
            // MARK: - Theme Actions
            
            case .theme(.onAppear), .theme(.loadThemes):
                state.theme.isLoadingThemes = true
                return .run { send in
                    await send(.theme(.themesLoaded(
                        TaskResult {
                            await themeManager.loadAllThemes()
                            return await themeManager.availableThemes
                        }
                    )))
                }
            
            case .theme(.themesLoaded(.success(let themes))):
                state.theme.isLoadingThemes = false
                state.theme.availableThemes = IdentifiedArray(uniqueElements: themes)
                
                // 从 ThemeManager 获取当前实际主题（确保同步）
                return .run { send in
                    let currentTheme = await themeManager.currentTheme
                    await send(.theme(.syncCurrentTheme(currentTheme.id)))
                }
            
            case .theme(.themesLoaded(.failure(let error))):
                state.theme.isLoadingThemes = false
                state.theme.errorMessage = error.localizedDescription
                return .none
            
            case .theme(.syncCurrentTheme(let themeId)):
                state.theme.currentThemeId = themeId
                print("🔄 [THEME] Synced current theme: \(themeId)")
                return .none
            
            case .theme(.selectTheme(let themeId)):
                guard state.theme.currentThemeId != themeId else { return .none }
                
                return .run { send in
                    await send(.theme(.themeSelected(
                        TaskResult {
                            try await themeManager.switchTheme(to: themeId)
                            return await themeManager.currentTheme
                        }
                    )))
                }
            
            case .theme(.themeSelected(.success(let theme))):
                state.theme.currentThemeId = theme.id
                return .none
            
            case .theme(.themeSelected(.failure(let error))):
                state.theme.errorMessage = error.localizedDescription
                return .none
            
            case .theme(.importTheme(let url)):
                state.theme.importExportState = .importing
                return .run { send in
                    await send(.theme(.importThemeResponse(
                        TaskResult {
                            try await themeManager.importTheme(from: url)
                        }
                    )))
                }
            
            case .theme(.importThemeResponse(.success(let theme))):
                state.theme.importExportState = .success
                state.theme.availableThemes.append(theme)
                // 2秒后重置状态
                return .run { send in
                    try await mainQueue.sleep(for: .seconds(2))
                    await send(.theme(.dismissError))
                }
            
            case .theme(.importThemeResponse(.failure(let error))):
                state.theme.importExportState = .failure(error.localizedDescription)
                return .none
            
            case .theme(.confirmDelete(let themeId)):
                return .run { send in
                    await send(.theme(.deleteThemeResponse(
                        TaskResult {
                            try await themeManager.deleteTheme(themeId)
                            return themeId
                        }
                    )))
                }
            
            case .theme(.deleteThemeResponse(.success(let themeId))):
                state.theme.availableThemes.remove(id: themeId)
                // 如果删除的是当前主题，切换到默认主题
                if state.theme.currentThemeId == themeId {
                    return .send(.theme(.selectTheme("builtin-light")))
                }
                return .none
            
            case .theme(.deleteThemeResponse(.failure(let error))):
                state.theme.errorMessage = error.localizedDescription
                return .none
            
            case .theme(.dismissError):
                state.theme.errorMessage = nil
                state.theme.importExportState = .idle
                return .none
            
            case .theme(.exportThemeResponse(.success)):
                state.theme.importExportState = .success
                return .run { send in
                    try await mainQueue.sleep(for: .seconds(2))
                    await send(.theme(.dismissError))
                }
            
            case .theme(.exportThemeResponse(.failure(let error))):
                state.theme.errorMessage = "导出失败: \(error.localizedDescription)"
                return .none
            
            case .theme(.importThemeButtonTapped),
                 .theme(.exportTheme),
                 .theme(.deleteTheme),
                 .theme(.cancelDelete):
                // These are handled by the view layer
                return .none
            }
        }
    }
}

// MARK: - Settings Category

enum SettingsCategory: String, CaseIterable, Identifiable {
    case editor = "编辑器"
    case appearance = "外观"
    // 未来可扩展：
    // case general = "通用"
    // case shortcuts = "快捷键"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .editor: return "textformat"
        case .appearance: return "paintbrush"
        }
    }
    
    var description: String {
        switch self {
        case .editor: return "字体、排版和布局设置"
        case .appearance: return "主题和预览样式设置"
        }
    }
}


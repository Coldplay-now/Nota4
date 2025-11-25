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
        
        // MARK: - AI 配置状态
        var aiConfig: EditorPreferences.AIConfig
        var originalAiConfig: EditorPreferences.AIConfig
        
        init(editorPreferences: EditorPreferences) {
            self.editorPreferences = editorPreferences
            self.originalEditorPreferences = editorPreferences
            self.aiConfig = editorPreferences.aiConfig
            self.originalAiConfig = editorPreferences.aiConfig
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
        
        // MARK: - Editor Font Actions
        case editorFontChanged(FontType, String)
        case editorFontSizeChanged(FontType, CGFloat)
        
        // MARK: - Editor Layout Actions
        case editorLayoutChanged(EditorPreferences.LayoutSettings)
        
        // MARK: - Preview Font Actions
        case previewFontChanged(FontType, String)
        case previewFontSizeChanged(FontType, CGFloat)
        
        // MARK: - Preview Layout Actions
        case previewLayoutChanged(EditorPreferences.LayoutSettings)
        
        // MARK: - Code Highlight Actions
        case codeHighlightModeChanged(EditorPreferences.CodeHighlightMode)
        case codeHighlightThemeChanged(CodeTheme)
        
        // MARK: - AI Config Actions
        case aiEndpointChanged(String)
        case aiApiKeyChanged(String)
        case aiModelChanged(String)
        case aiSystemPromptChanged(String)
        
        // Theme actions
        case theme(ThemeAction)
    }
    
    enum FontType {
        case body
        case title
        case code
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
                return .run { [state] send in
                    var prefs = state.editorPreferences
                    // 保存主题设置
                    prefs.previewThemeId = state.theme.currentThemeId
                    // 保存 AI 配置（确保 API Key 也被保存）
                    prefs.aiConfig = state.aiConfig
                    print("💾 [SETTINGS] Saving AI config - endpoint: \(prefs.aiConfig.endpoint), model: \(prefs.aiConfig.model), apiKey length: \(prefs.aiConfig.apiKey.count)")
                    try await PreferencesStorage.shared.save(prefs)
                    // 验证保存是否成功
                    let savedPrefs = await PreferencesStorage.shared.load()
                    print("✅ [SETTINGS] Saved AI config - endpoint: \(savedPrefs.aiConfig.endpoint), model: \(savedPrefs.aiConfig.model), apiKey length: \(savedPrefs.aiConfig.apiKey.count)")
                    await send(.dismiss)
                }
                
            case .cancel:
                print("⚙️ [SETTINGS] Canceling, restoring original settings")
                state.editorPreferences = state.originalEditorPreferences
                state.theme.currentThemeId = state.originalEditorPreferences.previewThemeId
                state.aiConfig = state.originalAiConfig
                return .send(.dismiss)
                
            case .dismiss:
                return .none
            
            // MARK: - Editor Font Actions
            
            case .editorFontChanged(let type, let fontName):
                switch type {
                case .body:
                    state.editorPreferences.editorFonts.bodyFontName = fontName
                case .title:
                    state.editorPreferences.editorFonts.titleFontName = fontName
                case .code:
                    state.editorPreferences.editorFonts.codeFontName = fontName
                }
                return .none
                
            case .editorFontSizeChanged(let type, let size):
                switch type {
                case .body:
                    state.editorPreferences.editorFonts.bodyFontSize = size
                case .title:
                    state.editorPreferences.editorFonts.titleFontSize = size
                case .code:
                    state.editorPreferences.editorFonts.codeFontSize = size
                }
                return .none
            
            // MARK: - Editor Layout Actions
            
            case .editorLayoutChanged(let layout):
                state.editorPreferences.editorLayout = layout
                return .none
            
            // MARK: - Preview Font Actions
            
            case .previewFontChanged(let type, let fontName):
                switch type {
                case .body:
                    state.editorPreferences.previewFonts.bodyFontName = fontName
                case .title:
                    state.editorPreferences.previewFonts.titleFontName = fontName
                case .code:
                    state.editorPreferences.previewFonts.codeFontName = fontName
                }
                return .none
                
            case .previewFontSizeChanged(let type, let size):
                switch type {
                case .body:
                    state.editorPreferences.previewFonts.bodyFontSize = size
                case .title:
                    state.editorPreferences.previewFonts.titleFontSize = size
                case .code:
                    state.editorPreferences.previewFonts.codeFontSize = size
                }
                return .none
            
            // MARK: - Preview Layout Actions
            
            case .previewLayoutChanged(let layout):
                state.editorPreferences.previewLayout = layout
                return .none
            
            // MARK: - Code Highlight Actions
            
            case .codeHighlightModeChanged(let mode):
                state.editorPreferences.codeHighlightMode = mode
                return .none
                
            case .codeHighlightThemeChanged(let theme):
                state.editorPreferences.codeHighlightTheme = theme
                return .none
            
            // MARK: - AI Config Actions
            
            case .aiEndpointChanged(let endpoint):
                state.aiConfig.endpoint = endpoint
                return .none
                
            case .aiApiKeyChanged(let apiKey):
                state.aiConfig.apiKey = apiKey
                return .none
                
            case .aiModelChanged(let model):
                state.aiConfig.model = model
                return .none
                
            case .aiSystemPromptChanged(let prompt):
                state.aiConfig.systemPrompt = prompt
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
    case ai = "AI 助手"
    // 未来可扩展：
    // case general = "通用"
    // case shortcuts = "快捷键"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .editor: return "textformat"
        case .appearance: return "paintbrush"
        case .ai: return "sparkles"
        }
    }
    
    var description: String {
        switch self {
        case .editor: return "字体、排版和布局设置"
        case .appearance: return "主题和预览样式设置"
        case .ai: return "LLM API 配置和系统提示词设置"
        }
    }
}


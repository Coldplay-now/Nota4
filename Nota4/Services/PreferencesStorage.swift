import Foundation

/// 编辑器偏好设置存储服务
actor PreferencesStorage {
    // MARK: - Singleton
    
    static let shared = PreferencesStorage()
    
    // MARK: - Properties
    
    private let key = "editorPreferences"
    private let defaults = UserDefaults.standard
    
    // MARK: - Private Init
    
    private init() {
    }
    
    // MARK: - Load
    
    /// 加载配置
    func load() -> EditorPreferences {
        guard let data = defaults.data(forKey: key) else {
            return EditorPreferences()
        }
        
        do {
            let preferences = try JSONDecoder().decode(EditorPreferences.self, from: data)
            return preferences
        } catch {
            print("❌ [PREFS] Failed to decode preferences: \(error)")
            return EditorPreferences()
        }
    }
    
    // MARK: - Save
    
    /// 保存配置
    func save(_ preferences: EditorPreferences) throws {
        let data = try JSONEncoder().encode(preferences)
        defaults.set(data, forKey: key)
    }
    
    // MARK: - Reset
    
    /// 重置为默认配置
    func reset() {
        defaults.removeObject(forKey: key)
    }
    
    // MARK: - Import/Export
    
    /// 导出配置为 JSON 数据
    func exportToJSON() throws -> Data {
        let preferences = load()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(preferences)
        return data
    }
    
    /// 从 JSON 数据导入配置
    func importFromJSON(_ data: Data) throws {
        let preferences = try JSONDecoder().decode(EditorPreferences.self, from: data)
        try save(preferences)
    }
    
    /// 导出配置为文件
    func exportToFile(at url: URL) throws {
        let data = try exportToJSON()
        try data.write(to: url)
    }
    
    /// 从文件导入配置
    func importFromFile(at url: URL) async throws {
        let data = try Data(contentsOf: url)
        try importFromJSON(data)
    }
    
    // MARK: - Validation
    
    /// 验证配置是否有效
    func validate(_ preferences: EditorPreferences) -> Bool {
        // 编辑模式字号范围检查
        guard preferences.editorFonts.titleFontSize >= 18 && preferences.editorFonts.titleFontSize <= 32 else {
            return false
        }
        
        guard preferences.editorFonts.bodyFontSize >= 12 && preferences.editorFonts.bodyFontSize <= 24 else {
            return false
        }
        
        guard preferences.editorFonts.codeFontSize >= 10 && preferences.editorFonts.codeFontSize <= 20 else {
            return false
        }
        
        // 预览模式字号范围检查
        guard preferences.previewFonts.titleFontSize >= 18 && preferences.previewFonts.titleFontSize <= 32 else {
            return false
        }
        
        guard preferences.previewFonts.bodyFontSize >= 12 && preferences.previewFonts.bodyFontSize <= 24 else {
            return false
        }
        
        guard preferences.previewFonts.codeFontSize >= 10 && preferences.previewFonts.codeFontSize <= 20 else {
            return false
        }
        
        // 编辑模式行间距范围检查
        guard preferences.editorLayout.lineSpacing >= 4 && preferences.editorLayout.lineSpacing <= 50 else {
            return false
        }
        
        // 预览模式行间距范围检查
        guard preferences.previewLayout.lineSpacing >= 4 && preferences.previewLayout.lineSpacing <= 50 else {
            return false
        }
        
        // 预览模式行宽范围检查
        if let maxWidth = preferences.previewLayout.maxWidth {
            guard maxWidth >= 600 && maxWidth <= 1200 else {
                return false
            }
        }
        
        return true
    }
}


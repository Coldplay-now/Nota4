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
        print("📐 [PREFS] PreferencesStorage initialized")
    }
    
    // MARK: - Load
    
    /// 加载配置
    func load() -> EditorPreferences {
        guard let data = defaults.data(forKey: key) else {
            print("⚪ [PREFS] No saved preferences found, using defaults")
            return EditorPreferences()
        }
        
        do {
            let preferences = try JSONDecoder().decode(EditorPreferences.self, from: data)
            print("✅ [PREFS] Loaded preferences from storage")
            print("📐 [PREFS] Body font: \(preferences.bodyFontName) \(Int(preferences.bodyFontSize))pt")
            return preferences
        } catch {
            print("❌ [PREFS] Failed to decode preferences: \(error)")
            print("⚪ [PREFS] Using default preferences")
            return EditorPreferences()
        }
    }
    
    // MARK: - Save
    
    /// 保存配置
    func save(_ preferences: EditorPreferences) throws {
        let data = try JSONEncoder().encode(preferences)
        defaults.set(data, forKey: key)
        print("✅ [PREFS] Saved preferences to storage")
    }
    
    // MARK: - Reset
    
    /// 重置为默认配置
    func reset() {
        defaults.removeObject(forKey: key)
        print("✅ [PREFS] Reset preferences to defaults")
    }
    
    // MARK: - Import/Export
    
    /// 导出配置为 JSON 数据
    func exportToJSON() throws -> Data {
        let preferences = load()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(preferences)
        print("✅ [PREFS] Exported preferences to JSON")
        return data
    }
    
    /// 从 JSON 数据导入配置
    func importFromJSON(_ data: Data) throws {
        let preferences = try JSONDecoder().decode(EditorPreferences.self, from: data)
        try save(preferences)
        print("✅ [PREFS] Imported preferences from JSON")
    }
    
    /// 导出配置为文件
    func exportToFile(at url: URL) throws {
        let data = try exportToJSON()
        try data.write(to: url)
        print("✅ [PREFS] Exported preferences to file: \(url.lastPathComponent)")
    }
    
    /// 从文件导入配置
    func importFromFile(at url: URL) throws {
        let data = try Data(contentsOf: url)
        try importFromJSON(data)
        print("✅ [PREFS] Imported preferences from file: \(url.lastPathComponent)")
    }
    
    // MARK: - Validation
    
    /// 验证配置是否有效
    func validate(_ preferences: EditorPreferences) -> Bool {
        // 字号范围检查
        guard preferences.titleFontSize >= 18 && preferences.titleFontSize <= 32 else {
            print("⚠️ [PREFS] Invalid title font size: \(preferences.titleFontSize)")
            return false
        }
        
        guard preferences.bodyFontSize >= 12 && preferences.bodyFontSize <= 24 else {
            print("⚠️ [PREFS] Invalid body font size: \(preferences.bodyFontSize)")
            return false
        }
        
        guard preferences.codeFontSize >= 10 && preferences.codeFontSize <= 20 else {
            print("⚠️ [PREFS] Invalid code font size: \(preferences.codeFontSize)")
            return false
        }
        
        // 行间距范围检查
        guard preferences.lineSpacing >= 4 && preferences.lineSpacing <= 12 else {
            print("⚠️ [PREFS] Invalid line spacing: \(preferences.lineSpacing)")
            return false
        }
        
        // 行宽范围检查
        guard preferences.maxWidth >= 500 && preferences.maxWidth <= 1200 else {
            print("⚠️ [PREFS] Invalid max width: \(preferences.maxWidth)")
            return false
        }
        
        print("✅ [PREFS] Preferences validation passed")
        return true
    }
}


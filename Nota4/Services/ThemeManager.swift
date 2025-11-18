import Foundation

// MARK: - Theme Manager

/// 主题管理器（单例）
/// 负责主题的加载、切换、导入、导出等操作
actor ThemeManager {
    static let shared = ThemeManager()
    
    // MARK: - Properties
    
    private(set) var availableThemes: [ThemeConfig] = []
    private(set) var currentTheme: ThemeConfig
    
    private let themesDirectory: URL?
    private let userThemesDirectory: URL
    
    // MARK: - Initialization
    
    private init() {
        // 内置主题目录
        // 对于我们的 .app bundle，主题资源在 Contents/Resources/Themes
        if let resourcePath = Bundle.main.resourcePath {
            themesDirectory = URL(fileURLWithPath: resourcePath)
                .appendingPathComponent("Themes")
            
            if let themesDir = themesDirectory {
                let exists = FileManager.default.fileExists(atPath: themesDir.path)
                if exists {
                    let files = (try? FileManager.default.contentsOfDirectory(atPath: themesDir.path)) ?? []
                }
            }
        } else {
            themesDirectory = nil
            print("⚠️ [THEME] Bundle.main.resourcePath is nil!")
        }
        
        // 用户自定义主题目录
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        userThemesDirectory = appSupport
            .appendingPathComponent("Nota4/Themes")
        
        // 创建用户主题目录
        try? FileManager.default.createDirectory(
            at: userThemesDirectory,
            withIntermediateDirectories: true
        )
        
        // 加载默认主题
        currentTheme = ThemeConfig.defaultLight
        
        // 异步加载所有主题
        Task { [weak self] in
            guard let self = self else { return }
            await self.loadAllThemes()
            
            // 恢复上次选择的主题
            if let savedThemeId = UserDefaults.standard.string(forKey: "selectedThemeId") {
                let themes = await self.availableThemes
                if let theme = themes.first(where: { $0.id == savedThemeId }) {
                    await self.restoreTheme(theme)
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// 加载所有主题
    func loadAllThemes() async {
        var themes: [ThemeConfig] = []
        
        // 加载内置主题
        themes.append(contentsOf: loadBuiltInThemes())
        
        // 加载用户主题
        themes.append(contentsOf: loadUserThemes())
        
        availableThemes = themes
        
    }
    
    /// 恢复主题（内部使用，不发送通知）
    private func restoreTheme(_ theme: ThemeConfig) {
        currentTheme = theme
    }
    
    /// 切换主题
    func switchTheme(to themeId: String) async throws {
        guard let theme = availableThemes.first(where: { $0.id == themeId }) else {
            throw ThemeError.themeNotFound(themeId)
        }
        
        currentTheme = theme
        
        // 持久化用户选择
        UserDefaults.standard.set(themeId, forKey: "selectedThemeId")
        
        // 发送通知（通知 UI 更新）
        await MainActor.run {
            NotificationCenter.default.post(
                name: .themeDidChange,
                object: theme
            )
        }
        
    }
    
    /// 导入自定义主题
    func importTheme(from url: URL) async throws -> ThemeConfig {
        // 1. 验证主题包（这里简化处理，实际应该验证）
        let themeId = url.deletingPathExtension().lastPathComponent
        let destination = userThemesDirectory.appendingPathComponent(themeId)
        
        if FileManager.default.fileExists(atPath: destination.path) {
            throw ThemeError.themeAlreadyExists(themeId)
        }
        
        // 2. 复制主题包到用户目录
        try FileManager.default.copyItem(at: url, to: destination)
        
        // 3. 读取主题配置
        let configURL = destination.appendingPathComponent("theme.json")
        let data = try Data(contentsOf: configURL)
        let theme = try JSONDecoder().decode(ThemeConfig.self, from: data)
        
        // 4. 添加到可用主题列表
        availableThemes.append(theme)
        
        
        return theme
    }
    
    /// 导出主题
    func exportTheme(_ themeId: String, to destinationURL: URL) async throws {
        guard let theme = availableThemes.first(where: { $0.id == themeId }) else {
            throw ThemeError.themeNotFound(themeId)
        }
        
        // 不允许导出内置主题
        guard !theme.id.hasPrefix("builtin-") else {
            throw ThemeError.cannotExportBuiltInTheme
        }
        
        // 查找主题文件
        let themeDir = userThemesDirectory.appendingPathComponent(themeId)
        
        guard FileManager.default.fileExists(atPath: themeDir.path) else {
            throw ThemeError.cannotExportBuiltInTheme
        }
        
        // 打包主题
        try FileManager.default.copyItem(at: themeDir, to: destinationURL)
        
    }
    
    /// 删除用户主题
    func deleteTheme(_ themeId: String) async throws {
        guard let theme = availableThemes.first(where: { $0.id == themeId }) else {
            throw ThemeError.themeNotFound(themeId)
        }
        
        // 不允许删除内置主题
        guard !theme.id.hasPrefix("builtin-") else {
            throw ThemeError.cannotDeleteBuiltInTheme
        }
        
        // 删除主题文件
        let themeDir = userThemesDirectory.appendingPathComponent(themeId)
        try FileManager.default.removeItem(at: themeDir)
        
        // 从列表中移除
        availableThemes.removeAll { $0.id == themeId }
        
        // 如果删除的是当前主题，切换到默认主题
        if currentTheme.id == themeId {
            try await switchTheme(to: "builtin-light")
        }
        
    }
    
    /// 获取主题的 CSS 内容
    func getCSS(for theme: ThemeConfig) async throws -> String {
        // 1. 尝试从内置资源加载
        if let builtInURL = themesDirectory?.appendingPathComponent(theme.cssFileName),
           FileManager.default.fileExists(atPath: builtInURL.path) {
            return try String(contentsOf: builtInURL)
        }
        
        // 2. 尝试从用户主题加载
        let userURL = userThemesDirectory
            .appendingPathComponent(theme.id)
            .appendingPathComponent(theme.cssFileName)
        
        if FileManager.default.fileExists(atPath: userURL.path) {
            return try String(contentsOf: userURL)
        }
        
        throw ThemeError.cssFileNotFound(theme.cssFileName)
    }
    
    // MARK: - Private Methods
    
    private func loadBuiltInThemes() -> [ThemeConfig] {
        // 返回硬编码的内置主题
        return [
            ThemeConfig.defaultLight,
            ThemeConfig.defaultDark,
            ThemeConfig.github,
            ThemeConfig.notion
        ]
    }
    
    private func loadUserThemes() -> [ThemeConfig] {
        var themes: [ThemeConfig] = []
        
        guard let enumerator = FileManager.default.enumerator(
            at: userThemesDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return themes
        }
        
        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == "theme.json" {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let theme = try JSONDecoder().decode(ThemeConfig.self, from: data)
                    themes.append(theme)
                } catch {
                    print("⚠️ [THEME] Failed to load: \(fileURL.path)")
                }
            }
        }
        
        return themes
    }
}


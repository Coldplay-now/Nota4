import Foundation

// MARK: - Built-in Themes

extension ThemeConfig {
    /// 默认浅色主题
    static let defaultLight = ThemeConfig(
        id: "builtin-light",
        name: "light",
        displayName: "浅色",
        author: "Nota4",
        version: "1.0.0",
        description: "默认浅色主题",
        cssFileName: "light.css",
        codeHighlightTheme: .xcode,
        mermaidTheme: "default",
        colors: ThemeColors(
            primaryColor: "#0066cc",
            backgroundColor: "#ffffff",
            textColor: "#333333",
            secondaryTextColor: "#666666",
            linkColor: "#0066cc",
            codeBackgroundColor: "#f5f5f5",
            borderColor: "#e0e0e0",
            accentColor: "#0066cc"
        ),
        fonts: ThemeFonts(
            bodyFont: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
            headingFont: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
            codeFont: "'SF Mono', Monaco, Menlo, 'Courier New', monospace",
            fontSize: 16,
            lineHeight: 1.6
        ),
        createdAt: Date(),
        updatedAt: Date()
    )
    
    /// 默认深色主题
    static let defaultDark = ThemeConfig(
        id: "builtin-dark",
        name: "dark",
        displayName: "深色",
        author: "Nota4",
        version: "1.0.0",
        description: "默认深色主题",
        cssFileName: "dark.css",
        codeHighlightTheme: .dracula,
        mermaidTheme: "dark",
        colors: ThemeColors(
            primaryColor: "#4da6ff",
            backgroundColor: "#1e1e1e",
            textColor: "#e0e0e0",
            secondaryTextColor: "#aaaaaa",
            linkColor: "#4da6ff",
            codeBackgroundColor: "#2d2d2d",
            borderColor: "#404040",
            accentColor: "#4da6ff"
        ),
        fonts: ThemeFonts(
            bodyFont: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
            headingFont: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
            codeFont: "'SF Mono', Monaco, Menlo, 'Courier New', monospace",
            fontSize: 16,
            lineHeight: 1.6
        ),
        createdAt: Date(),
        updatedAt: Date()
    )
    
    /// GitHub 风格主题
    static let github = ThemeConfig(
        id: "builtin-github",
        name: "github",
        displayName: "GitHub",
        author: "Nota4",
        version: "1.0.0",
        description: "GitHub 风格主题",
        cssFileName: "github.css",
        codeHighlightTheme: .github,
        mermaidTheme: "neutral",
        colors: nil,  // 使用 CSS 文件中的样式
        fonts: nil,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    /// Notion 风格主题
    static let notion = ThemeConfig(
        id: "builtin-notion",
        name: "notion",
        displayName: "Notion",
        author: "Nota4",
        version: "1.0.0",
        description: "Notion 风格主题",
        cssFileName: "notion.css",
        codeHighlightTheme: .github,
        mermaidTheme: "default",
        colors: nil,
        fonts: nil,
        createdAt: Date(),
        updatedAt: Date()
    )
}


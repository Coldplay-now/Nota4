import SwiftUI

/// 编辑器样式配置
struct EditorStyle: Equatable {
    let fontSize: CGFloat
    let lineSpacing: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let maxWidth: CGFloat
    let fontDesign: Font.Design
    let fontWeight: Font.Weight
    let paragraphSpacing: CGFloat
    let alignment: Alignment
    let fontName: String?  // 具体字体名称
    let titleFontName: String?  // 标题字体名称
    let titleFontSize: CGFloat  // 标题字号
    
    /// 完整初始化方法
    init(
        fontSize: CGFloat,
        lineSpacing: CGFloat,
        horizontalPadding: CGFloat,
        verticalPadding: CGFloat,
        maxWidth: CGFloat,
        fontDesign: Font.Design,
        fontWeight: Font.Weight,
        paragraphSpacing: CGFloat,
        alignment: Alignment,
        fontName: String? = nil,
        titleFontName: String? = nil,
        titleFontSize: CGFloat = 28
    ) {
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.maxWidth = maxWidth
        self.fontDesign = fontDesign
        self.fontWeight = fontWeight
        self.paragraphSpacing = paragraphSpacing
        self.alignment = alignment
        self.fontName = fontName
        self.titleFontName = titleFontName
        self.titleFontSize = titleFontSize
    }
    
    /// 默认舒适型
    static let comfortable = EditorStyle(
        fontSize: 17,
        lineSpacing: 6,
        horizontalPadding: 24,
        verticalPadding: 20,
        maxWidth: 800,
        fontDesign: .default,
        fontWeight: .regular,
        paragraphSpacing: 0.8,
        alignment: .center,
        titleFontName: nil,
        titleFontSize: 28
    )
    
    /// 从 EditorPreferences 创建样式（使用编辑模式设置）
    init(from preferences: EditorPreferences) {
        self.fontSize = preferences.editorFonts.bodyFontSize
        self.lineSpacing = preferences.editorLayout.lineSpacing
        self.horizontalPadding = preferences.editorLayout.horizontalPadding
        self.verticalPadding = preferences.editorLayout.verticalPadding
        self.maxWidth = preferences.editorLayout.maxWidth ?? 0  // 编辑模式不使用最大行宽
        self.paragraphSpacing = preferences.editorLayout.paragraphSpacing
        self.alignment = preferences.editorLayout.alignment == .center ? .center : .leading
        
        // 使用实际字体名称（如果不是 "System"）
        self.fontName = preferences.editorFonts.bodyFontName != "System" ? preferences.editorFonts.bodyFontName : nil
        
        // 标题字体设置
        self.titleFontName = preferences.editorFonts.titleFontName != "System" ? preferences.editorFonts.titleFontName : nil
        self.titleFontSize = preferences.editorFonts.titleFontSize
        
        // 根据字体名称映射 fontDesign（作为后备）
        if preferences.editorFonts.bodyFontName.contains("Menlo") || 
           preferences.editorFonts.bodyFontName.contains("Monaco") ||
           preferences.editorFonts.bodyFontName.contains("Courier") ||
           preferences.editorFonts.bodyFontName.contains("SF Mono") {
            self.fontDesign = .monospaced
        } else if preferences.editorFonts.bodyFontName.contains("Songti") ||
                  preferences.editorFonts.bodyFontName.contains("Kaiti") {
            self.fontDesign = .serif
        } else {
            self.fontDesign = .default
        }
        
        self.fontWeight = .regular
    }
}

// MARK: - View Modifier

extension View {
    /// 应用编辑器样式
    func editorStyle(_ style: EditorStyle = .comfortable) -> some View {
        Group {
            if let fontName = style.fontName {
                // 使用自定义字体
                self.font(.custom(fontName, size: style.fontSize))
            } else {
                // 使用系统字体设计
                self.font(.system(size: style.fontSize, weight: style.fontWeight, design: style.fontDesign))
            }
        }
        .lineSpacing(style.lineSpacing)
        .padding(.horizontal, style.horizontalPadding)
        .padding(.vertical, style.verticalPadding)
        .frame(maxWidth: style.maxWidth)
        .frame(maxWidth: .infinity, alignment: .top)
    }
}


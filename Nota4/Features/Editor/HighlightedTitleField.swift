import SwiftUI
import AppKit

/// 支持搜索高亮的标题输入框
struct HighlightedTitleField: NSViewRepresentable {
    @Binding var text: String
    var searchKeywords: [String]
    var fontName: String?
    var fontSize: CGFloat
    var onFocusChange: (Bool) -> Void
    @Binding var isFocused: Bool
    var onReturnKey: (() -> Void)? = nil  // 回车键回调
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.isEditable = true
        textField.isSelectable = true
        textField.isBordered = false
        textField.drawsBackground = false
        
        // 使用传入的字体设置
        if let fontName = fontName, let font = NSFont(name: fontName, size: fontSize) {
            textField.font = font
        } else {
            textField.font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
        }
        
        textField.textColor = .labelColor
        textField.placeholderString = "标题"
        textField.delegate = context.coordinator
        
        // 设置自动布局
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }
    
    func updateNSView(_ textField: NSTextField, context: Context) {
        // 检查当前是否有编辑器正在编辑（用户正在输入）
        let currentEditor = textField.currentEditor()
        let isCurrentlyEditing = textField.window?.firstResponder == currentEditor
        
        // 检查是否是首次加载或文本从空变为有值
        let currentText = textField.stringValue
        let isInitialLoad = currentText.isEmpty && !text.isEmpty
        let isTextChanged = currentText != text
        
        // 如果用户正在编辑且不是首次加载，不更新文本和高亮，不管理焦点
        // 把焦点选择完全还给用户，避免任何干扰
        if isCurrentlyEditing && !isInitialLoad {
            // 用户正在输入，不进行任何更新操作，避免干扰焦点和光标位置
            return
        }
        
        // 用户没有在编辑时，才进行更新操作
        
        // 更新文本（仅在文本不同时更新，避免循环更新）
        if isTextChanged {
            textField.stringValue = text
        }
        
        // 更新字体（如果字体设置已改变）
        if let fontName = fontName, let font = NSFont(name: fontName, size: fontSize) {
            if textField.font != font {
                textField.font = font
            }
        } else {
            let systemFont = NSFont.systemFont(ofSize: fontSize, weight: .bold)
            if textField.font != systemFont {
                textField.font = systemFont
            }
        }
        
        // 更新高亮（即使文本相同，关键词可能已变化）
        context.coordinator.updateHighlights(
            text: text,
            keywords: searchKeywords,
            textField: textField,
            fontName: fontName,
            fontSize: fontSize
        )
        
        // 只有在用户没有在编辑时，才根据 isFocused 绑定来设置焦点
        // 这通常发生在外部明确要求设置焦点时（例如程序化设置焦点）
        if isFocused && !isCurrentlyEditing {
            textField.window?.makeFirstResponder(textField)
        } else if !isFocused && isCurrentlyEditing {
            textField.window?.makeFirstResponder(nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: HighlightedTitleField
        
        init(_ parent: HighlightedTitleField) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            // 更新文本绑定，但不触发焦点管理
            // 让用户自由编辑，不干扰焦点
            parent.text = textField.stringValue
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            // 用户开始编辑时，更新焦点状态
            parent.isFocused = true
            parent.onFocusChange(true)
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            // 用户结束编辑时，更新焦点状态并触发保存
            parent.isFocused = false
            parent.onFocusChange(false)
        }
        
        // 处理键盘命令（拦截回车键）
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            // 拦截回车键（insertNewline:）
            if commandSelector == #selector(NSTextView.insertNewline(_:)) {
                // 先让标题框失去焦点
                if let window = control.window {
                    window.makeFirstResponder(nil)
                }
                
                // 延迟调用回调，确保标题框完全失去焦点
                DispatchQueue.main.async {
                    self.parent.onReturnKey?()
                }
                
                // 返回 true 表示已处理，阻止默认行为（插入换行）
                return true
            }
            // 其他命令不处理，返回 false 使用默认行为
            return false
        }
        
        func updateHighlights(text: String, keywords: [String], textField: NSTextField, fontName: String?, fontSize: CGFloat) {
            guard !keywords.isEmpty else {
                // 没有关键词，清除高亮
                let attributedString = NSMutableAttributedString(string: text)
                
                // 使用传入的字体设置
                let font: NSFont
                if let fontName = fontName, let customFont = NSFont(name: fontName, size: fontSize) {
                    font = customFont
                } else {
                    font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
                }
                
                attributedString.addAttribute(
                    .font,
                    value: font,
                    range: NSRange(location: 0, length: text.count)
                )
                attributedString.addAttribute(
                    .foregroundColor,
                    value: NSColor.labelColor,
                    range: NSRange(location: 0, length: text.count)
                )
                textField.attributedStringValue = attributedString
                return
            }
            
            let attributedString = NSMutableAttributedString(string: text)
            let lowercaseText = text.lowercased()
            
            // 为所有关键词添加高亮
            for keyword in keywords {
                guard !keyword.isEmpty else { continue }
                let lowercaseKeyword = keyword.lowercased()
                
                var searchRange = NSRange(location: 0, length: text.count)
                while searchRange.location < text.count {
                    if let range = lowercaseText.range(
                        of: lowercaseKeyword,
                        range: Range(searchRange, in: lowercaseText)
                    ) {
                        let nsRange = NSRange(range, in: text)
                        // 应用橙色背景高亮（提升饱和度）
                        attributedString.addAttribute(
                            .backgroundColor,
                            value: NSColor.systemOrange.withAlphaComponent(0.4),
                            range: nsRange
                        )
                        attributedString.addAttribute(
                            .foregroundColor,
                            value: NSColor.labelColor,
                            range: nsRange
                        )
                        
                        // 继续搜索下一个匹配项
                        let nextLocation = nsRange.location + nsRange.length
                        if nextLocation >= text.count {
                            break
                        }
                        searchRange = NSRange(location: nextLocation, length: text.count - nextLocation)
                    } else {
                        break
                    }
                }
            }
            
            // 使用传入的字体设置
            let font: NSFont
            if let fontName = fontName, let customFont = NSFont(name: fontName, size: fontSize) {
                font = customFont
            } else {
                font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
            }
            
            // 设置字体
            attributedString.addAttribute(
                .font,
                value: font,
                range: NSRange(location: 0, length: text.count)
            )
            
            // 设置默认文本颜色（用于没有高亮的部分）
            attributedString.addAttribute(
                .foregroundColor,
                value: NSColor.labelColor,
                range: NSRange(location: 0, length: text.count)
            )
            
            textField.attributedStringValue = attributedString
        }
    }
}


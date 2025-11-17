import SwiftUI
import AppKit

/// 支持搜索高亮的标题输入框
struct HighlightedTitleField: NSViewRepresentable {
    @Binding var text: String
    var searchKeywords: [String]
    var onFocusChange: (Bool) -> Void
    @Binding var isFocused: Bool
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.isEditable = true
        textField.isSelectable = true
        textField.isBordered = false
        textField.drawsBackground = false
        textField.font = NSFont.systemFont(ofSize: 28, weight: .bold)
        textField.textColor = .labelColor
        textField.placeholderString = "标题"
        textField.delegate = context.coordinator
        
        // 设置自动布局
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }
    
    func updateNSView(_ textField: NSTextField, context: Context) {
        // 更新文本（仅在文本不同时更新，避免循环更新）
        let currentText = textField.stringValue
        if currentText != text {
            textField.stringValue = text
        }
        
        // 更新高亮（即使文本相同，关键词可能已变化）
        context.coordinator.updateHighlights(
            text: text,
            keywords: searchKeywords,
            textField: textField
        )
        
        // 更新焦点状态
        let currentEditor = textField.currentEditor()
        let isCurrentlyFocused = textField.window?.firstResponder == currentEditor
        if isFocused && !isCurrentlyFocused {
            textField.window?.makeFirstResponder(textField)
        } else if !isFocused && isCurrentlyFocused {
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
            parent.text = textField.stringValue
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            parent.isFocused = true
            parent.onFocusChange(true)
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            parent.isFocused = false
            parent.onFocusChange(false)
        }
        
        func updateHighlights(text: String, keywords: [String], textField: NSTextField) {
            guard !keywords.isEmpty else {
                // 没有关键词，清除高亮
                let attributedString = NSMutableAttributedString(string: text)
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
                        // 应用黄色背景高亮
                        attributedString.addAttribute(
                            .backgroundColor,
                            value: NSColor.systemYellow.withAlphaComponent(0.2),
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
            
            // 设置字体
            attributedString.addAttribute(
                .font,
                value: NSFont.systemFont(ofSize: 28, weight: .bold),
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


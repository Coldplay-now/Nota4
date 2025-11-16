import SwiftUI
import AppKit

/// NSTextView 包装器，支持光标位置和选中文本检测
struct MarkdownTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var selection: NSRange
    let font: NSFont
    let textColor: NSColor
    let backgroundColor: NSColor
    let lineSpacing: CGFloat
    let paragraphSpacing: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let onSelectionChange: (NSRange) -> Void
    let onFocusChange: (Bool) -> Void
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        // 配置 TextView
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = false
        textView.usesFontPanel = false
        textView.usesRuler = false
        textView.drawsBackground = true
        textView.backgroundColor = backgroundColor
        textView.textColor = textColor
        textView.font = font
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        
        // 设置文本容器（使用传入的 padding 值）
        textView.textContainer?.lineFragmentPadding = horizontalPadding
        textView.textContainerInset = NSSize(width: 0, height: verticalPadding)
        
        // 设置段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        textView.defaultParagraphStyle = paragraphStyle
        
        // 将段落样式应用到初始文本
        if let textStorage = textView.textStorage, textStorage.length > 0 {
            let fullRange = NSRange(location: 0, length: textStorage.length)
            textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
            textStorage.addAttribute(.font, value: font, range: fullRange)
        }
        
        // 设置代理
        textView.delegate = context.coordinator
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        // 检查样式是否改变
        let stylesChanged = textView.font != font ||
                           textView.textColor != textColor ||
                           textView.backgroundColor != backgroundColor ||
                           textView.defaultParagraphStyle?.lineSpacing != lineSpacing ||
                           textView.defaultParagraphStyle?.paragraphSpacing != paragraphSpacing
        
        // 更新文本（只在从外部改变时，不在用户输入时）
        if textView.string != text {
            let wasEditing = textView.window?.firstResponder == textView
            
            // 取消输入法的 marked text（关键：避免输入法冲突）
            if textView.hasMarkedText() {
                textView.unmarkText()
            }
            
            textView.string = text
            
            // 如果正在编辑，应用样式
            if wasEditing, let textStorage = textView.textStorage, textStorage.length > 0 {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = lineSpacing
                paragraphStyle.paragraphSpacing = paragraphSpacing
                
                let fullRange = NSRange(location: 0, length: textStorage.length)
                textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
                textStorage.addAttribute(.font, value: font, range: fullRange)
            }
        }
        
        // 应用绑定的选中范围（如果与当前不同）
        // 但不要在输入法输入过程中改变选中范围
        if !textView.hasMarkedText() {
            let currentSelection = textView.selectedRange()
            if currentSelection.location != selection.location || currentSelection.length != selection.length {
                // 确保选中范围在有效范围内
                let safeLocation = min(selection.location, text.count)
                let safeLength = min(selection.length, text.count - safeLocation)
                let safeSelection = NSRange(location: safeLocation, length: safeLength)
                
                textView.setSelectedRange(safeSelection)
                textView.scrollRangeToVisible(safeSelection)
            }
        }
        
        // 只在样式改变时更新样式和应用到全文
        if stylesChanged {
            textView.font = font
            textView.textColor = textColor
            textView.backgroundColor = backgroundColor
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.paragraphSpacing = paragraphSpacing
            textView.defaultParagraphStyle = paragraphStyle
            
            // 将新样式应用到已有文本
            if let textStorage = textView.textStorage, textStorage.length > 0 {
                let fullRange = NSRange(location: 0, length: textStorage.length)
                textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
                textStorage.addAttribute(.font, value: font, range: fullRange)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownTextEditor
        
        init(_ parent: MarkdownTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // 如果输入法正在输入（有 marked text），不更新状态
            // 避免干扰输入法的临时输入
            if textView.hasMarkedText() {
                return
            }
            
            parent.text = textView.string
            parent.onSelectionChange(textView.selectedRange())
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // 如果输入法正在输入，不更新选中范围
            if textView.hasMarkedText() {
                return
            }
            
            parent.onSelectionChange(textView.selectedRange())
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            parent.onFocusChange(true)
        }
        
        func textDidEndEditing(_ notification: Notification) {
            parent.onFocusChange(false)
        }
    }
}

// MARK: - Markdown 格式化工具

struct MarkdownFormatter {
    
    /// 格式化文本（包裹选中文本或插入占位符）
    static func formatWrap(
        text: String,
        selection: NSRange,
        prefix: String,
        suffix: String? = nil,
        placeholder: String
    ) -> (newText: String, newSelection: NSRange) {
        let suffix = suffix ?? prefix
        let selectedText = (text as NSString).substring(with: selection)
        
        let mutableText = NSMutableString(string: text)
        
        // 情况 3：选中的是已格式化文本，移除格式
        if selectedText.hasPrefix(prefix) && selectedText.hasSuffix(suffix) {
            let unwrapped = String(selectedText.dropFirst(prefix.count).dropLast(suffix.count))
            mutableText.replaceCharacters(in: selection, with: unwrapped)
            return (
                newText: mutableText as String,
                newSelection: NSRange(location: selection.location, length: unwrapped.count)
            )
        }
        
        // 情况 1：有选中文本，包裹
        if selection.length > 0 {
            let wrapped = "\(prefix)\(selectedText)\(suffix)"
            mutableText.replaceCharacters(in: selection, with: wrapped)
            return (
                newText: mutableText as String,
                newSelection: NSRange(location: selection.location + prefix.count, length: selectedText.count)
            )
        }
        
        // 情况 2：无选中文本，插入占位符并自动选中
        let insertion = "\(prefix)\(placeholder)\(suffix)"
        mutableText.insert(insertion, at: selection.location)
        
        return (
            newText: mutableText as String,
            newSelection: NSRange(location: selection.location + prefix.count, length: placeholder.count)
        )
    }
    
    /// 在行首插入（标题、列表）
    static func formatLineStart(
        text: String,
        selection: NSRange,
        prefix: String,
        replaceExistingPrefixes: [String] = []
    ) -> (newText: String, newSelection: NSRange) {
        let nsText = text as NSString
        
        // 获取选中范围所在行的起始位置
        let lineRange = nsText.lineRange(for: selection)
        let lineStartLocation = lineRange.location
        
        // 获取这些行的文本（不包括尾部换行符）
        var linesText = nsText.substring(with: lineRange)
        
        // 移除尾部换行符以避免多余的空行
        while linesText.hasSuffix("\n") {
            linesText.removeLast()
        }
        
        // 如果是空行，直接插入前缀
        if linesText.isEmpty {
            let insertion = "\(prefix) "
            let mutableText = NSMutableString(string: text)
            mutableText.insert(insertion, at: lineStartLocation)
            
            // 光标移动到前缀后面
            let newLocation = lineStartLocation + insertion.count
            return (
                newText: mutableText as String,
                newSelection: NSRange(location: newLocation, length: 0)
            )
        }
        
        let lines = linesText.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        
        var newLines: [String] = []
        var firstLineOffsetDelta = 0
        
        for (index, line) in lines.enumerated() {
            var currentLine = line
            var lineOffsetDelta = 0
            
            // 检查是否已有前缀，如果有则替换
            var replaced = false
            for existingPrefix in replaceExistingPrefixes {
                if currentLine.hasPrefix(existingPrefix + " ") {
                    // 移除旧前缀和空格
                    currentLine = String(currentLine.dropFirst(existingPrefix.count + 1))
                    lineOffsetDelta = -(existingPrefix.count + 1)
                    replaced = true
                    break
                } else if currentLine.hasPrefix(existingPrefix) {
                    // 移除旧前缀（无空格）
                    currentLine = String(currentLine.dropFirst(existingPrefix.count))
                    lineOffsetDelta = -existingPrefix.count
                    replaced = true
                    break
                }
            }
            
            // 添加新前缀
            currentLine = "\(prefix) \(currentLine)"
            if !replaced {
                lineOffsetDelta = prefix.count + 1
            }
            
            newLines.append(currentLine)
            
            // 记录第一行的偏移量
            if index == 0 {
                firstLineOffsetDelta = lineOffsetDelta
            }
        }
        
        // 重新组合文本
        let newLinesText = newLines.joined(separator: "\n")
        
        // 替换原文本中的行范围（使用 NSMutableString 避免编码问题）
        let mutableText = NSMutableString(string: text)
        let replacementRange = NSRange(
            location: lineStartLocation,
            length: linesText.count
        )
        mutableText.replaceCharacters(in: replacementRange, with: newLinesText)
        let newText = mutableText as String
        
        // 计算光标在当前行中的相对位置
        let relativePositionInLine = selection.location - lineStartLocation
        
        // 新的光标位置 = 行首 + 相对位置 + 偏移量
        // 如果光标在行首，移动到前缀后面；否则保持相对位置
        let newLocation: Int
        if relativePositionInLine == 0 {
            // 光标在行首，移动到前缀后面
            newLocation = lineStartLocation + firstLineOffsetDelta
        } else {
            // 光标在行中，保持相对位置并加上偏移
            newLocation = lineStartLocation + relativePositionInLine + firstLineOffsetDelta
        }
        
        let newSelection = NSRange(
            location: max(0, newLocation),
            length: selection.length
        )
        
        return (newText: newText, newSelection: newSelection)
    }
    
    /// 插入代码块
    static func insertCodeBlock(
        text: String,
        selection: NSRange
    ) -> (newText: String, newSelection: NSRange) {
        let selectedText = (text as NSString).substring(with: selection)
        let mutableText = NSMutableString(string: text)
        
        if selection.length > 0 {
            // 有选中文本，包裹在代码块中
            let insertion = "```\n\(selectedText)\n```"
            mutableText.replaceCharacters(in: selection, with: insertion)
            return (
                newText: mutableText as String,
                newSelection: NSRange(location: selection.location + 4, length: selectedText.count)
            )
        } else {
            // 无选中文本，插入占位符
            let insertion = "```\n代码\n```"
            mutableText.insert(insertion, at: selection.location)
            return (
                newText: mutableText as String,
                newSelection: NSRange(location: selection.location + 4, length: 2)
            )
        }
    }
}

// MARK: - String Extension

extension String {
    func trimmingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}


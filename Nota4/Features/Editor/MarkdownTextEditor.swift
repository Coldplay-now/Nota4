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
    let alignment: Alignment
    let onSelectionChange: (NSRange) -> Void
    let onFocusChange: (Bool) -> Void
    
    // 搜索高亮相关
    var searchMatches: [NSRange] = []
    var currentSearchIndex: Int = -1
    
    // 将 SwiftUI.Alignment 转换为 NSTextAlignment
    private var nsTextAlignment: NSTextAlignment {
        switch alignment {
        case .leading: return .left
        case .center: return .center
        case .trailing: return .right
        default: return .left
        }
    }
    
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
        // textContainerInset 控制整个文本容器的边距（更明显）
        textView.textContainerInset = NSSize(width: horizontalPadding, height: verticalPadding)
        // lineFragmentPadding 控制文本行的左右边距（设置为较小值，避免双重边距）
        textView.textContainer?.lineFragmentPadding = 0
        
        // 设置段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.alignment = nsTextAlignment
        textView.defaultParagraphStyle = paragraphStyle
        
        // 将段落样式应用到初始文本
        if let textStorage = textView.textStorage, textStorage.length > 0 {
            let fullRange = NSRange(location: 0, length: textStorage.length)
            textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
            textStorage.addAttribute(.font, value: font, range: fullRange)
        }
        
        // 设置代理
        textView.delegate = context.coordinator
        
        // 保存 textView 引用到 coordinator
        context.coordinator.textView = textView
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        // 检查样式是否改变
        let stylesChanged = textView.font != font ||
                           textView.textColor != textColor ||
                           textView.backgroundColor != backgroundColor ||
                           textView.defaultParagraphStyle?.lineSpacing != lineSpacing ||
                           textView.defaultParagraphStyle?.paragraphSpacing != paragraphSpacing ||
                           textView.defaultParagraphStyle?.alignment != nsTextAlignment
        
        // 检查边距是否改变
        let paddingChanged = textView.textContainerInset.width != horizontalPadding ||
                            textView.textContainerInset.height != verticalPadding ||
                            textView.textContainer?.lineFragmentPadding != 0
        
        // 更新文本（只在从外部改变时，不在用户输入时）
        // 注意：如果正在执行替换操作，不要更新 textView.string，否则会清除 undo stack
        if textView.string != text && !context.coordinator.isReplacing {
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
                paragraphStyle.alignment = nsTextAlignment
                
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
        
        // 更新边距（如果改变）
        if paddingChanged {
            textView.textContainerInset = NSSize(width: horizontalPadding, height: verticalPadding)
            textView.textContainer?.lineFragmentPadding = 0
        }
        
        // 只在样式改变时更新样式和应用到全文
        if stylesChanged {
            textView.font = font
            textView.textColor = textColor
            textView.backgroundColor = backgroundColor
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.paragraphSpacing = paragraphSpacing
            paragraphStyle.alignment = nsTextAlignment
            textView.defaultParagraphStyle = paragraphStyle
            
            // 将新样式应用到已有文本
            if let textStorage = textView.textStorage, textStorage.length > 0 {
                let fullRange = NSRange(location: 0, length: textStorage.length)
                textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
                textStorage.addAttribute(.font, value: font, range: fullRange)
            }
        }
        
        // 确保 textView 引用已设置
        if context.coordinator.textView == nil {
            context.coordinator.textView = textView
        }
        
        // 更新搜索高亮（每次 updateNSView 都检查，因为 searchMatches 或 currentSearchIndex 可能已改变）
        // 检查是否需要更新（避免不必要的更新）
        let needsUpdate = searchMatches.count != context.coordinator.searchHighlights.count || 
                         currentSearchIndex != context.coordinator.currentHighlightIndex ||
                         (searchMatches.count > 0 && context.coordinator.searchHighlights.count == 0) ||
                         (searchMatches.count == 0 && context.coordinator.searchHighlights.count > 0)
        
        if needsUpdate {
            context.coordinator.updateSearchHighlights(
                matches: searchMatches,
                currentIndex: currentSearchIndex
            )
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownTextEditor
        weak var textView: NSTextView?
        var searchHighlights: [NSRange] = []
        var currentHighlightIndex: Int = -1
        var isReplacing: Bool = false  // 标记是否正在执行替换操作
        
        init(_ parent: MarkdownTextEditor) {
            self.parent = parent
            super.init()
            // 监听替换操作通知
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleReplaceNotification(_:)),
                name: NSNotification.Name("PerformReplaceInTextView"),
                object: nil
            )
            // 监听焦点跳转通知（从标题框按回车时）
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleFocusToContentStart(_:)),
                name: NSNotification.Name("MoveFocusToContentStart"),
                object: nil
            )
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
            
            // 清理未完成的 undo group（防止崩溃）
            if let textView = textView, let undoManager = textView.undoManager {
                // 检查是否有未结束的 undo group
                while undoManager.groupingLevel > 0 {
                    undoManager.endUndoGrouping()
                }
            }
        }
        
        @objc func handleFocusToContentStart(_ notification: Notification) {
            guard let textView = textView else { return }
            
            // 延迟执行，确保标题框完全失去焦点
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                // 设置光标到文首
                textView.setSelectedRange(NSRange(location: 0, length: 0))
                textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
                
                // 设置焦点
                if let window = textView.window {
                    window.makeFirstResponder(textView)
                    
                    // 再次确保光标在文首
                    DispatchQueue.main.async {
                        textView.setSelectedRange(NSRange(location: 0, length: 0))
                        textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
                    }
                }
            }
        }
        
        @objc func handleReplaceNotification(_ notification: Notification) {
            guard let textView = textView,
                  textView.window != nil,  // 确保 textView 仍然在视图层次中
                  let userInfo = notification.userInfo,
                  let range = userInfo["range"] as? NSRange,
                  let replacement = userInfo["replacement"] as? String,
                  let textStorage = textView.textStorage,
                  let undoManager = textView.undoManager else {
                return
            }
            
            // 获取可选的分组信息（用于"全部替换"）
            let isGrouped = userInfo["isGrouped"] as? Bool ?? false
            let isFirst = userInfo["isFirst"] as? Bool ?? false
            let isLast = userInfo["isLast"] as? Bool ?? false
            
            // 确保 range 有效
            guard range.location != NSNotFound,
                  range.location >= 0,
                  range.location + range.length <= textView.string.count else {
                return
            }
            
            // 标记正在执行替换操作，防止 updateNSView 清除 undo stack
            isReplacing = true
            
            // 如果是分组操作（全部替换），在第一次替换时开始 undo group
            if isGrouped && isFirst {
                undoManager.beginUndoGrouping()
            }
            
            // 选中要替换的范围
            textView.setSelectedRange(range)
            
            // 使用 shouldChangeText 检查是否可以更改（这会自动准备 undo 操作）
            // shouldChangeText 会通知 textStorage 准备 undo，并返回是否可以更改
            let shouldChange = textView.shouldChangeText(in: range, replacementString: replacement)
            if shouldChange {
                // 执行替换（textStorage 已经通过 shouldChangeText 准备好了 undo）
                textStorage.replaceCharacters(in: range, with: replacement)
                
                // 调用 didChangeText 通知系统（这会完成 undo 记录的注册）
                // didChangeText 会自动注册 undo，使用 shouldChangeText 时保存的原始内容
                textView.didChangeText()
                
                // 设置 undo 操作的名称
                undoManager.setActionName("替换文本")
                
                // 更新选中范围到替换后的位置
                let newRange = NSRange(location: range.location, length: replacement.count)
                textView.setSelectedRange(newRange)
            }
            
            // 如果是分组操作，在最后一次替换时结束 undo group
            if isGrouped && isLast {
                undoManager.endUndoGrouping()
                // 对于全部替换，在所有替换完成后才重置标记
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.isReplacing = false
                }
            } else if !isGrouped {
                // 单个替换，在替换完成后重置标记
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                    self?.isReplacing = false
                }
            }
            
            // 通知父组件内容已改变（通过 textDidChange 会自动触发，但这里也手动更新以确保同步）
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let textView = self.textView else { return }
                self.parent.text = textView.string
            }
        }
        
        // MARK: - Context Menu Filtering
        
        /// 过滤系统右键菜单，只保留需要的菜单项
        func textView(_ textView: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
            // 创建新菜单，只包含需要的菜单项
            let filteredMenu = NSMenu()
            
            // 允许的菜单项 action（保留这些）
            let allowedActions: Set<Selector> = [
                #selector(NSText.cut(_:)),                // Cut
                #selector(NSText.copy(_:)),               // Copy
                #selector(NSText.paste(_:))              // Paste
            ]
            
            // Undo/Redo 的 action selector（NSResponder 标准方法）
            let undoAction = Selector(("undo:"))
            let redoAction = Selector(("redo:"))
            
            // Share 菜单的标题关键词（中英文）
            let shareKeywords = ["Share", "分享", "共享"]
            
            // Undo/Redo 菜单的标题关键词（中英文）
            let undoKeywords = ["Undo", "撤销", "撤消"]
            let redoKeywords = ["Redo", "重做", "恢复"]
            
            // 遍历系统菜单，只添加允许的菜单项
            for item in menu.items {
                // 检查是否是 Undo 菜单（通过 action 或标题识别）
                if let action = item.action, (action == undoAction || undoKeywords.contains(where: { item.title.contains($0) })) {
                    let newItem = item.copy() as! NSMenuItem
                    // 不设置 target，让响应链自动找到 textView（这样 validateUserInterfaceItem 才能正常工作）
                    newItem.target = nil
                    newItem.title = "撤销"  // 确保使用中文标题
                    filteredMenu.addItem(newItem)
                }
                // 检查是否是 Redo 菜单（通过 action 或标题识别）
                else if let action = item.action, (action == redoAction || redoKeywords.contains(where: { item.title.contains($0) })) {
                    let newItem = item.copy() as! NSMenuItem
                    // 不设置 target，让响应链自动找到 textView（这样 validateUserInterfaceItem 才能正常工作）
                    newItem.target = nil
                    newItem.title = "重做"  // 确保使用中文标题
                    filteredMenu.addItem(newItem)
                }
                // 检查是否是允许的 action（Cut, Copy, Paste）
                else if let action = item.action, allowedActions.contains(action) {
                    // 复制菜单项
                    let newItem = item.copy() as! NSMenuItem
                    // 确保使用中文标题
                    if action == #selector(NSText.cut(_:)) {
                        newItem.title = "剪切"
                    } else if action == #selector(NSText.copy(_:)) {
                        newItem.title = "复制"
                    } else if action == #selector(NSText.paste(_:)) {
                        newItem.title = "粘贴"
                    }
                    filteredMenu.addItem(newItem)
                }
                // 检查是否是 Share 菜单（通过标题识别）
                else if shareKeywords.contains(where: { item.title.contains($0) }) {
                    let newItem = item.copy() as! NSMenuItem
                    newItem.title = "分享"  // 确保使用中文标题
                    filteredMenu.addItem(newItem)
                }
                // 处理分隔符（但只在有内容时添加）
                else if item.isSeparatorItem {
                    if filteredMenu.items.count > 0 && !filteredMenu.items.last!.isSeparatorItem {
                        filteredMenu.addItem(NSMenuItem.separator())
                    }
                }
            }
            
            // 如果系统菜单中没有 Undo/Redo，手动添加
            let hasUndo = filteredMenu.items.contains { item in
                if let action = item.action {
                    return action == undoAction || undoKeywords.contains(where: { item.title.contains($0) })
                }
                return false
            }
            let hasRedo = filteredMenu.items.contains { item in
                if let action = item.action {
                    return action == redoAction || redoKeywords.contains(where: { item.title.contains($0) })
                }
                return false
            }
            
            // 如果没有 Undo，手动添加
            if !hasUndo {
                let undoItem = NSMenuItem(title: "撤销", action: undoAction, keyEquivalent: "z")
                // 不设置 target，让响应链自动找到 textView（这样 validateUserInterfaceItem 才能正常工作）
                undoItem.keyEquivalentModifierMask = .command
                filteredMenu.insertItem(undoItem, at: 0)
            } else {
                // 如果系统菜单中有 Undo，确保使用中文标题
                // 遍历所有菜单项，找到所有 Undo 菜单项并设置为中文
                for item in filteredMenu.items {
                    if let action = item.action, (action == undoAction || undoKeywords.contains(where: { item.title.contains($0) })) {
                        item.title = "撤销"
                        // 不设置 target，让响应链自动找到 textView
                        item.target = nil
                    }
                }
            }
            
            // 如果没有 Redo，手动添加
            if !hasRedo {
                let redoItem = NSMenuItem(title: "重做", action: redoAction, keyEquivalent: "z")
                // 不设置 target，让响应链自动找到 textView（这样 validateUserInterfaceItem 才能正常工作）
                redoItem.keyEquivalentModifierMask = [.command, .shift]
                if hasUndo {
                    filteredMenu.insertItem(redoItem, at: 1)
                } else {
                    filteredMenu.insertItem(redoItem, at: 0)
                }
            } else {
                // 如果系统菜单中有 Redo，确保使用中文标题
                // 遍历所有菜单项，找到所有 Redo 菜单项并设置为中文
                for item in filteredMenu.items {
                    if let action = item.action, (action == redoAction || redoKeywords.contains(where: { item.title.contains($0) })) {
                        item.title = "重做"
                        // 不设置 target，让响应链自动找到 textView
                        item.target = nil
                    }
                }
            }
            
            // 在 Undo/Redo 后添加分隔符（如果还没有）
            if filteredMenu.items.count > 0 && !filteredMenu.items[0].isSeparatorItem {
                filteredMenu.insertItem(NSMenuItem.separator(), at: hasUndo && hasRedo ? 2 : (hasUndo || hasRedo ? 1 : 0))
            }
            
            // 如果没有找到任何菜单项，返回 nil（使用系统默认菜单）
            return filteredMenu.items.isEmpty ? nil : filteredMenu
        }
        
        // MARK: - Search Highlight Methods
        
        func updateSearchHighlights(matches: [NSRange], currentIndex: Int) {
            guard let textView = textView else {
                print("⚠️ [SEARCH] textView 未设置，无法更新高亮")
                return
            }
            guard let textStorage = textView.textStorage else {
                print("⚠️ [SEARCH] textStorage 未设置，无法更新高亮")
                return
            }
            
            // 如果 matches 为空，清除高亮
            if matches.isEmpty {
                clearSearchHighlights()
                return
            }
            
            
            // 清除之前的高亮
            clearSearchHighlights()
            
            // 保存高亮范围
            searchHighlights = matches
            currentHighlightIndex = currentIndex
            
            // 应用高亮
            for (index, range) in matches.enumerated() {
                guard range.location != NSNotFound,
                      range.location >= 0,
                      range.location + range.length <= textStorage.length else {
                    print("⚠️ [SEARCH] 无效的范围: \(range), textStorage.length: \(textStorage.length)")
                    continue
                }
                
                // 获取该范围内的现有属性（保留字体、段落样式等）
                let existingAttributes = textStorage.attributes(at: range.location, effectiveRange: nil)
                var newAttributes = existingAttributes
                
                // 当前匹配项使用蓝色背景（提升饱和度）
                if index == currentIndex {
                    newAttributes[.backgroundColor] = NSColor.systemBlue.withAlphaComponent(0.5)
                    newAttributes[.foregroundColor] = NSColor.labelColor
                } else {
                    // 其他匹配项使用橙色背景（提升饱和度）
                    newAttributes[.backgroundColor] = NSColor.systemOrange.withAlphaComponent(0.4)
                    newAttributes[.foregroundColor] = NSColor.labelColor
                }
                
                // 使用 setAttributes 确保覆盖已有属性（包括代码块、引用块等的灰色背景）
                textStorage.setAttributes(newAttributes, range: range)
            }
            
            // 滚动到当前匹配项
            if currentIndex >= 0 && currentIndex < matches.count {
                let range = matches[currentIndex]
                textView.scrollRangeToVisible(range)
                textView.setSelectedRange(range)
            }
        }
        
        func clearSearchHighlights() {
            guard let textView = textView else { return }
            guard let textStorage = textView.textStorage else { return }
            
            // 移除所有高亮属性（但保留字体和段落样式）
            let fullRange = NSRange(location: 0, length: textStorage.length)
            textStorage.removeAttribute(.backgroundColor, range: fullRange)
            textStorage.removeAttribute(.foregroundColor, range: fullRange)
            
            searchHighlights = []
            currentHighlightIndex = -1
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
        
        // MARK: - List Continuation Support
        
        /// 拦截命令（用于实现列表自动续行和缩进）
        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            // 拦截 Tab 键
            if commandSelector == #selector(NSTextView.insertTab(_:)) {
                return handleTabKey(textView: textView, isShiftPressed: false)
            }
            // 拦截 Shift+Tab 键
            if commandSelector == #selector(NSTextView.insertBacktab(_:)) {
                return handleTabKey(textView: textView, isShiftPressed: true)
            }
            // 拦截回车键
            if commandSelector == #selector(NSTextView.insertNewline(_:)) {
                return handleEnterKey(textView: textView)
            }
            return false
        }
        
        /// 处理回车键，实现列表自动续行
        private func handleEnterKey(textView: NSTextView) -> Bool {
            let text = textView.string
            let selection = textView.selectedRange()
            
            // 获取当前行
            let nsText = text as NSString
            let lineRange = nsText.lineRange(for: selection)
            let fullLineText = nsText.substring(with: lineRange)  // 包含缩进的完整行
            let trimmedLineText = fullLineText.trimmingCharacters(in: .whitespacesAndNewlines)  // 去除缩进用于检测
            
            // 检测列表类型
            guard let listInfo = detectListType(line: trimmedLineText) else {
                // 不是列表项，执行默认行为
                return false
            }
            
            // 计算新行的列表标记
            let newListMarker: String
            switch listInfo {
            case .ordered(let number):
                // 检测当前行的缩进层级
                let indentLevel = detectIndentLevel(line: fullLineText)
                
                // 提取列表内容
                let content = extractListContent(from: trimmedLineText)
                
                // 计算新行的序号
                let newNumber: Int
                if content.isEmpty {
                    // 空列表项，保持相同序号
                    newNumber = number
                } else {
                    // 有内容，直接递增序号
                    // 因为当前行本身就是同级列表项的一部分，下一个序号应该是当前序号 + 1
                    newNumber = number + 1
                }
                
                // 根据层级生成对应格式的标记
                let newMarker = generateListMarker(level: indentLevel, number: newNumber)
                
                // 保持相同的缩进
                let indent = String(repeating: " ", count: indentLevel * 2)
                
                // 生成新行的列表标记（包含缩进）
                newListMarker = "\(indent)\(newMarker) "
            case .unordered:
                // 提取当前行的标记（- 或 * 或 +）
                if trimmedLineText.hasPrefix("- ") {
                    newListMarker = "- "
                } else if trimmedLineText.hasPrefix("* ") {
                    newListMarker = "* "
                } else if trimmedLineText.hasPrefix("+ ") {
                    newListMarker = "+ "
                } else {
                    // 默认使用 "- "
                    newListMarker = "- "
                }
            case .task:
                // 提取当前行的标记
                if trimmedLineText.hasPrefix("- [") {
                    newListMarker = "- [ ] "
                } else if trimmedLineText.hasPrefix("* [") {
                    newListMarker = "* [ ] "
                } else if trimmedLineText.hasPrefix("+ [") {
                    newListMarker = "+ [ ] "
                } else {
                    // 默认使用 "- [ ] "
                    newListMarker = "- [ ] "
                }
            }
            
            // 插入新行和列表标记
            let insertion = "\n\(newListMarker)"
            let insertionRange = NSRange(location: selection.location, length: 0)
            
            // 使用 shouldChangeText 准备 undo
            guard textView.shouldChangeText(in: insertionRange, replacementString: insertion) else {
                return false
            }
            
            // 执行插入
            if let textStorage = textView.textStorage {
                textStorage.replaceCharacters(in: insertionRange, with: insertion)
                textView.didChangeText()
                
                // 更新选中范围到新行的列表标记后面
                let newSelection = NSRange(location: selection.location + insertion.count, length: 0)
                textView.setSelectedRange(newSelection)
                textView.scrollRangeToVisible(newSelection)
                
                // 通知父组件内容已改变
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.parent.text = textView.string
                    self.parent.onSelectionChange(newSelection)
                }
            }
            
            return true
        }
        
        /// 检测列表类型
        private func detectListType(line: String) -> ListType? {
            // 先检测任务列表（因为任务列表也以 "- " 开头，需要优先匹配）
            // 匹配 "- [ ] " 或 "- [x] " 或 "* [ ] " 等
            if line.hasPrefix("- [ ] ") || line.hasPrefix("- [x] ") ||
               line.hasPrefix("* [ ] ") || line.hasPrefix("* [x] ") ||
               line.hasPrefix("+ [ ] ") || line.hasPrefix("+ [x] ") {
                return .task
            }
            
            // 移除前导空格以检测列表标记
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // 检测有序列表：匹配 "数字. "、"字母. " 或 "罗马数字. " 模式
            if let match = trimmed.range(of: #"^(\d+|[a-z]|[A-Z]|[ivxlcdmIVXLCDM]+)\.\s"#, options: .regularExpression) {
                let markerStr = String(trimmed[..<match.upperBound].dropLast(2))
                
                // 尝试解析为数字
                if let number = Int(markerStr) {
                    return .ordered(number: number)
                }
                
                // 尝试解析为小写字母
                if markerStr.count == 1, let char = markerStr.first, char.isLowercase {
                    let number = Int(char.asciiValue! - 96)  // a=1, b=2, ...
                    return .ordered(number: number)
                }
                
                // 尝试解析为大写字母
                if markerStr.count == 1, let char = markerStr.first, char.isUppercase {
                    let number = Int(char.asciiValue! - 64)  // A=1, B=2, ...
                    return .ordered(number: number)
                }
                
                // 尝试解析为罗马数字
                if let romanNumber = parseRomanNumeral(markerStr) {
                    return .ordered(number: romanNumber)
                }
            }
            
            // 检测无序列表：匹配 "- " 或 "* " 或 "+ "（但不能是任务列表）
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
                return .unordered
            }
            
            return nil
        }
        
        // MARK: - List Indent Support
        
        /// 检测行的缩进层级
        private func detectIndentLevel(line: String) -> Int {
            var indentCount = 0
            var index = line.startIndex
            
            while index < line.endIndex {
                if line[index] == " " {
                    indentCount += 1
                    index = line.index(after: index)
                } else if line[index] == "\t" {
                    // Tab 键通常等于 4 个空格
                    indentCount += 4
                    index = line.index(after: index)
                } else {
                    break
                }
            }
            
            // 每 2 个空格为一个层级（Markdown 标准）
            return indentCount / 2
        }
        
        /// 计算 Tab/Shift+Tab 后的目标层级
        private func calculateTargetLevel(currentLevel: Int, isShiftPressed: Bool) -> Int {
            if isShiftPressed {
                // Shift+Tab: 减少缩进
                return max(0, currentLevel - 1)
            } else {
                // Tab: 增加缩进
                return min(5, currentLevel + 1)  // 最多5层
            }
        }
        
        /// 将数字转换为罗马数字
        private func romanNumeral(_ number: Int, uppercase: Bool) -> String {
            guard number > 0 && number < 4000 else {
                return "\(number)"  // 超出范围，返回原数字
            }
            
            let values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
            let symbols = uppercase
                ? ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
                : ["m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i"]
            
            var result = ""
            var remaining = number
            
            for (index, value) in values.enumerated() {
                let count = remaining / value
                if count > 0 {
                    result += String(repeating: symbols[index], count: count)
                    remaining -= value * count
                }
            }
            
            return result
        }
        
        /// 解析罗马数字为整数
        private func parseRomanNumeral(_ roman: String) -> Int? {
            let romanUpper = roman.uppercased()
            let romanMap: [Character: Int] = [
                "I": 1, "V": 5, "X": 10, "L": 50,
                "C": 100, "D": 500, "M": 1000
            ]
            
            var result = 0
            var previous = 0
            
            for char in romanUpper.reversed() {
                guard let value = romanMap[char] else {
                    return nil
                }
                
                if value < previous {
                    result -= value
                } else {
                    result += value
                }
                
                previous = value
            }
            
            return result > 0 ? result : nil
        }
        
        /// 根据层级和序号生成列表标记
        private func generateListMarker(level: Int, number: Int) -> String {
            switch level {
            case 0:
                return "\(number)."
            case 1:
                // a, b, c, ...
                let char = Character(UnicodeScalar(96 + number)!)
                return "\(char)."
            case 2:
                // i, ii, iii, ...
                return "\(romanNumeral(number, uppercase: false))."
            case 3:
                // A, B, C, ...
                let char = Character(UnicodeScalar(64 + number)!)
                return "\(char)."
            case 4:
                // I, II, III, ...
                return "\(romanNumeral(number, uppercase: true))."
            default:
                // 超过5层，循环使用小写字母
                let char = Character(UnicodeScalar(96 + number)!)
                return "\(char)."
            }
        }
        
        /// 从列表行中提取序号
        private func extractListNumber(from line: String) -> Int? {
            // 移除前导空格
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // 匹配有序列表：数字. 或 字母. 或 罗马数字.
            if let match = trimmed.range(of: #"^(\d+|[a-z]|[A-Z]|[ivxlcdmIVXLCDM]+)\.\s"#, options: .regularExpression) {
                let numberStr = String(trimmed[..<match.upperBound].dropLast(2))
                
                // 尝试解析为数字
                if let number = Int(numberStr) {
                    return number
                }
                
                // 尝试解析为字母
                if numberStr.count == 1, let char = numberStr.first {
                    if char.isLowercase {
                        return Int(char.asciiValue! - 96)  // a=1, b=2, ...
                    } else if char.isUppercase {
                        return Int(char.asciiValue! - 64)  // A=1, B=2, ...
                    }
                }
                
                // 尝试解析为罗马数字
                if let roman = parseRomanNumeral(numberStr) {
                    return roman
                }
            }
            
            return nil
        }
        
        /// 从列表行中提取内容（去除缩进和标记）
        private func extractListContent(from line: String) -> String {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 匹配并移除列表标记
            if let match = trimmed.range(of: #"^(\d+|[a-z]|[A-Z]|[ivxlcdmIVXLCDM]+)\.\s*"#, options: .regularExpression) {
                return String(trimmed[match.upperBound...])
            }
            
            return trimmed
        }
        
        /// 检测当前列表项在同级中的序号
        private func detectListNumber(
            text: String,
            currentLineIndex: Int,
            indentLevel: Int
        ) -> Int {
            let lines = text.components(separatedBy: .newlines)
            var number = 1
            
            // 向前查找，找到第一个同级或更高级的列表项
            for i in stride(from: currentLineIndex - 1, through: 0, by: -1) {
                guard i < lines.count else { break }
                let line = lines[i]
                let lineIndent = detectIndentLevel(line: line)
                
                if lineIndent < indentLevel {
                    // 找到了更高级的列表项，停止查找
                    break
                } else if lineIndent == indentLevel {
                    // 找到了同级列表项，提取序号并递增
                    if let listNumber = extractListNumber(from: line) {
                        number = listNumber + 1
                        break
                    }
                } else if lineIndent > indentLevel {
                    // 子级列表项，继续查找
                    continue
                }
            }
            
            return number
        }
        
        /// 处理 Tab 键，实现列表缩进
        private func handleTabKey(textView: NSTextView, isShiftPressed: Bool) -> Bool {
            let text = textView.string
            let selection = textView.selectedRange()
            
            // 获取当前行
            let nsText = text as NSString
            let lineRange = nsText.lineRange(for: selection)
            let lineText = nsText.substring(with: lineRange)
            
            // 检测是否是列表项（需要保留前导空格）
            let trimmedLineText = lineText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let listInfo = detectListType(line: trimmedLineText) else {
                // 不是列表项，执行默认 Tab 行为（插入制表符或空格）
                return false
            }
            
            // 只处理有序列表
            guard case .ordered = listInfo else {
                // 无序列表或任务列表，执行默认 Tab 行为
                return false
            }
            
            // 检测当前缩进层级
            let currentIndentLevel = detectIndentLevel(line: lineText)
            let targetIndentLevel = calculateTargetLevel(
                currentLevel: currentIndentLevel,
                isShiftPressed: isShiftPressed
            )
            
            // 如果层级没有变化，不处理
            if currentIndentLevel == targetIndentLevel {
                return false
            }
            
            // 计算新的缩进和序号
            let newIndent = String(repeating: " ", count: targetIndentLevel * 2)
            
            // 计算当前行在文本中的行号（通过计算换行符数量）
            let currentLineIndex = nsText.substring(to: selection.location).components(separatedBy: .newlines).count - 1
            let listNumber = detectListNumber(
                text: text,
                currentLineIndex: currentLineIndex,
                indentLevel: targetIndentLevel
            )
            let newMarker = generateListMarker(level: targetIndentLevel, number: listNumber)
            
            // 移除旧的列表标记和缩进，添加新的
            let content = extractListContent(from: trimmedLineText)
            // 如果内容为空，只保留标记后的空格
            let newLine = content.isEmpty ? "\(newIndent)\(newMarker) " : "\(newIndent)\(newMarker) \(content)"
            
            // 替换当前行
            let replacementRange = lineRange
            guard textView.shouldChangeText(in: replacementRange, replacementString: newLine) else {
                return false
            }
            
            if let textStorage = textView.textStorage {
                textStorage.replaceCharacters(in: replacementRange, with: newLine)
                textView.didChangeText()
                
                // 更新选中范围到新行的列表标记后面
                let newSelection = NSRange(
                    location: replacementRange.location + newIndent.count + newMarker.count + 1,
                    length: 0
                )
                textView.setSelectedRange(newSelection)
                textView.scrollRangeToVisible(newSelection)
                
                // 通知父组件内容已改变
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.parent.text = textView.string
                    self.parent.onSelectionChange(newSelection)
                }
            }
            
            return true
        }
        
        /// 列表类型枚举
        private enum ListType {
            case ordered(number: Int)
            case unordered
            case task
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
    
    /// 插入表格
    static func insertTable(
        text: String,
        selection: NSRange,
        columns: Int,
        rows: Int
    ) -> (newText: String, newSelection: NSRange) {
        // 生成表头
        let headerCells = (1...columns).map { "列\($0)" }
        let header = "| " + headerCells.joined(separator: " | ") + " |"
        
        // 生成分隔线
        let separator = "| " + (1...columns).map { _ in "-----" }.joined(separator: " | ") + " |"
        
        // 生成表格行
        var tableRows: [String] = []
        for _ in 1...rows {
            let rowCells = (1...columns).map { _ in "单元格" }
            let row = "| " + rowCells.joined(separator: " | ") + " |"
            tableRows.append(row)
        }
        
        // 组合表格
        let table = "\n\(header)\n\(separator)\n\(tableRows.joined(separator: "\n"))\n"
        
        // 插入到文本
        let mutableText = NSMutableString(string: text)
        mutableText.insert(table, at: selection.location)
        
        // 光标定位到第一个单元格（表头第一列）
        let newLocation = selection.location + header.count - headerCells[0].count - 3 // "| 列1" 的位置
        let newSelection = NSRange(location: newLocation, length: headerCells[0].count)
        
        return (
            newText: mutableText as String,
            newSelection: newSelection
        )
    }
    
    /// 插入图片
    static func insertImage(
        text: String,
        selection: NSRange,
        altText: String,
        imagePath: String
    ) -> (newText: String, newSelection: NSRange) {
        let markdown = "![\(altText)](\(imagePath))"
        let mutableText = NSMutableString(string: text)
        mutableText.insert(markdown, at: selection.location)
        
        // 光标定位到 alt text 位置
        let altTextStart = selection.location + 2 // "![" 后面
        let newSelection = NSRange(location: altTextStart, length: altText.count)
        
        return (
            newText: mutableText as String,
            newSelection: newSelection
        )
    }
    
    /// 插入附件链接
    static func insertAttachment(
        text: String,
        selection: NSRange,
        fileName: String,
        filePath: String
    ) -> (newText: String, newSelection: NSRange) {
        let markdown = "[\(fileName)](\(filePath))"
        let mutableText = NSMutableString(string: text)
        mutableText.insert(markdown, at: selection.location)
        
        // 光标定位到文件名位置
        let fileNameStart = selection.location + 1 // "[" 后面
        let newSelection = NSRange(location: fileNameStart, length: fileName.count)
        
        return (
            newText: mutableText as String,
            newSelection: newSelection
        )
    }
    
    /// 插入区块引用
    static func insertBlockquote(
        text: String,
        selection: NSRange
    ) -> (newText: String, newSelection: NSRange) {
        return formatLineStart(
            text: text,
            selection: selection,
            prefix: ">",
            replaceExistingPrefixes: []
        )
    }
    
    /// 插入分隔线
    static func insertHorizontalRule(
        text: String,
        selection: NSRange
    ) -> (newText: String, newSelection: NSRange) {
        let insertion = "\n---\n"
        let mutableText = NSMutableString(string: text)
        mutableText.insert(insertion, at: selection.location)
        
        // 光标定位到分隔线后
        let newLocation = selection.location + insertion.count
        return (
            newText: mutableText as String,
            newSelection: NSRange(location: newLocation, length: 0)
        )
    }
    
    /// 格式化删除线
    static func formatStrikethrough(
        text: String,
        selection: NSRange
    ) -> (newText: String, newSelection: NSRange) {
        return formatWrap(
            text: text,
            selection: selection,
            prefix: "~~",
            suffix: "~~",
            placeholder: "删除的文本"
        )
    }
    
    /// 格式化下划线（使用 HTML 标签）
    static func formatUnderline(
        text: String,
        selection: NSRange
    ) -> (newText: String, newSelection: NSRange) {
        return formatWrap(
            text: text,
            selection: selection,
            prefix: "<u>",
            suffix: "</u>",
            placeholder: "下划线文本"
        )
    }
    
    /// 插入带语言标识的跨行代码块
    static func insertCodeBlockWithLanguage(
        text: String,
        selection: NSRange,
        language: String = "swift"
    ) -> (newText: String, newSelection: NSRange) {
        let selectedText = (text as NSString).substring(with: selection)
        let mutableText = NSMutableString(string: text)
        
        if selection.length > 0 {
            // 有选中文本，包裹在带语言标识的代码块中
            let insertion = "```\(language)\n\(selectedText)\n```"
            mutableText.replaceCharacters(in: selection, with: insertion)
            return (
                newText: mutableText as String,
                newSelection: NSRange(location: selection.location + 4 + language.count, length: selectedText.count)
            )
        } else {
            // 无选中文本，插入带语言标识的代码块占位符
            let insertion = "```\(language)\n代码\n```"
            mutableText.insert(insertion, at: selection.location)
            return (
                newText: mutableText as String,
                newSelection: NSRange(location: selection.location + 4 + language.count, length: 2)
            )
        }
    }
    
    /// 插入脚注
    static func insertFootnote(
        text: String,
        selection: NSRange,
        footnoteNumber: Int
    ) -> (newText: String, newSelection: NSRange) {
        let mutableText = NSMutableString(string: text)
        
        // 插入脚注引用
        let footnoteRef = "[^\(footnoteNumber)]"
        mutableText.insert(footnoteRef, at: selection.location)
        
        // 在文档末尾添加脚注定义
        let footnoteDef = "\n\n[^\(footnoteNumber)]: 脚注内容"
        mutableText.append(footnoteDef)
        
        // 光标定位到脚注引用位置
        let newLocation = selection.location + footnoteRef.count
        return (
            newText: mutableText as String,
            newSelection: NSRange(location: newLocation, length: 0)
        )
    }
    
    /// 插入行内公式
    static func insertInlineMath(
        text: String,
        selection: NSRange
    ) -> (newText: String, newSelection: NSRange) {
        return formatWrap(
            text: text,
            selection: selection,
            prefix: "$",
            suffix: "$",
            placeholder: "E = mc^2"
        )
    }
    
    /// 插入行间公式
    static func insertBlockMath(
        text: String,
        selection: NSRange
    ) -> (newText: String, newSelection: NSRange) {
        let selectedText = (text as NSString).substring(with: selection)
        let mutableText = NSMutableString(string: text)
        
        if selection.length > 0 {
            // 有选中文本，包裹在公式块中
            let insertion = "$$\n\(selectedText)\n$$"
            mutableText.replaceCharacters(in: selection, with: insertion)
            return (
                newText: mutableText as String,
                newSelection: NSRange(location: selection.location + 3, length: selectedText.count)
            )
        } else {
            // 无选中文本，插入占位符
            let insertion = "$$\nE = mc^2\n$$"
            mutableText.insert(insertion, at: selection.location)
            return (
                newText: mutableText as String,
                newSelection: NSRange(location: selection.location + 3, length: 9)
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


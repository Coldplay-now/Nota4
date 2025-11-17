import ComposableArchitecture
import Foundation

// MARK: - Editor Feature

@Reducer
struct EditorFeature {
    @ObservableState
    struct State: Equatable {
        var selectedNoteId: String?
        var note: Note?
        var content: String = ""
        var title: String = ""
        var viewMode: ViewMode = .editOnly
        var isSaving: Bool = false
        var lastSavedContent: String = ""
        var lastSavedTitle: String = ""
        var cursorPosition: Int = 0
        var selectionRange: NSRange = NSRange(location: 0, length: 0)
        var editorStyle: EditorStyle = .comfortable
        var preview: PreviewState = PreviewState()
        var showDeleteConfirmation: Bool = false
        
        // MARK: - Insert Dialog States
        
        var showImagePicker: Bool = false
        var showAttachmentPicker: Bool = false
        var isInsertingImage: Bool = false
        var isInsertingAttachment: Bool = false
        var insertError: String? = nil
        var footnoteCounter: Int = 1  // 脚注计数器
        
        // MARK: - Preview State
        
        struct PreviewState: Equatable {
            var renderedHTML: String = ""
            var isRendering: Bool = false
            var renderError: String? = nil
            var currentThemeId: String? = nil
            var includeTOC: Bool = false
            var renderOptions: RenderOptions = .default
        }
        
        // MARK: - Search State
        
        struct SearchState: Equatable {
            var isSearchPanelVisible: Bool = false
            var searchText: String = ""
            var replaceText: String = ""
            var isReplaceMode: Bool = false  // 是否为替换模式
            var matchCase: Bool = false      // 区分大小写
            var wholeWords: Bool = false     // 全词匹配
            var useRegex: Bool = false       // 使用正则表达式
            
            // 搜索结果
            var matches: [NSRange] = []      // 所有匹配项的范围
            var currentMatchIndex: Int = -1   // 当前选中的匹配项索引（-1 表示未选中）
            
            // 计算属性
            var hasMatches: Bool {
                !matches.isEmpty
            }
            
            var matchCount: Int {
                matches.count
            }
            
            var currentMatch: NSRange? {
                guard currentMatchIndex >= 0 && currentMatchIndex < matches.count else {
                    return nil
                }
                return matches[currentMatchIndex]
            }
        }
        
        var search: SearchState = SearchState()
        
        // 从笔记列表搜索传递过来的关键词（用于自动高亮）
        var listSearchKeywords: [String] = []
        
        // MARK: - Computed Properties
        
        var hasUnsavedChanges: Bool {
            content != lastSavedContent || title != lastSavedTitle
        }
        
        // MARK: - View Mode
        
        enum ViewMode: String, Equatable, CaseIterable {
            case editOnly = "仅编辑"
            case previewOnly = "仅预览"
            case split = "分屏"
            
            var icon: String {
                switch self {
                case .editOnly: return "pencil"
                case .previewOnly: return "eye"
                case .split: return "rectangle.split.2x1"
                }
            }
        }
        
        init() {}
    }
    
    // MARK: - Action
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case loadNote(String)
        case noteLoaded(Result<Note, Error>)
        case setListSearchKeywords([String])  // 设置从笔记列表搜索传递过来的关键词
        case viewModeChanged(State.ViewMode)
        case autoSave
        case manualSave
        case saveCompleted
        case saveFailed(Error)
        case insertMarkdown(MarkdownFormat)
        case insertImage(URL)
        case imageInserted(imageId: String, relativePath: String)
        case imageInsertFailed(Error)
        case toggleStar
        case togglePin
        case starToggled  // 星标切换完成通知
        case pinToggled   // 置顶切换完成通知
        case requestDeleteNote
        case confirmDeleteNote
        case noteDeleted(String)  // 笔记删除完成通知（noteId）
        case cancelDeleteNote
        case createNote
        case applyPreferences(EditorPreferences)
        case noteCreated(Result<Note, Error>)
        case selectionChanged(NSRange)
        case focusChanged(Bool)
        
        // MARK: - Preview Actions
        
        case preview(PreviewAction)
        
        enum PreviewAction: Equatable {
            // 生命周期
            case onAppear
            case contentChanged(String)
            
            // 渲染控制
            case render
            case renderDebounced
            case renderCompleted(TaskResult<String>)
            case cancelRender
            
            // 主题响应
            case themeChanged(String)
            case renderOptionsChanged(RenderOptions)
            
            // 错误处理
            case dismissError
        }
        
        // MARK: - Context Menu Actions
        
        case formatBold
        case formatItalic
        case formatInlineCode
        case insertHeading1
        case insertHeading2
        case insertHeading3
        case insertHeading4
        case insertHeading5
        case insertHeading6
        case insertUnorderedList
        case insertOrderedList
        case insertTaskList
        case insertLink
        case insertCodeBlock
        case insertTable(columns: Int, rows: Int)
        case insertBlockquote
        case insertHorizontalRule
        case formatStrikethrough
        case formatUnderline
        case insertFootnote(footnoteNumber: Int)
        case insertInlineMath
        case insertBlockMath
        
        // MARK: - Image and Attachment Actions
        
        case showImagePicker
        case dismissImagePicker
        case showAttachmentPicker
        case dismissAttachmentPicker
        case insertAttachment(URL)
        case attachmentInserted(fileName: String, relativePath: String)
        case attachmentInsertFailed(Error)
        
        // MARK: - Search Actions
        
        case search(SearchAction)
        
        enum SearchAction: Equatable {
            case showSearchPanel
            case hideSearchPanel
            case toggleSearchPanel  // 切换搜索面板显示/隐藏
            case toggleReplaceMode
            case searchTextChanged(String)
            case replaceTextChanged(String)
            case matchCaseToggled
            case wholeWordsToggled
            case useRegexToggled
            case findNext
            case findPrevious
            case replaceCurrent
            case replaceAll
            case updateMatches([NSRange])  // 内部使用，更新匹配项
            case selectMatch(Int)          // 内部使用，选中指定匹配项
        }
        
        // MARK: - Search Highlight Actions
        
        case updateSearchHighlights(matches: [NSRange], currentIndex: Int)
        case clearSearchHighlights
        
        // MARK: - Markdown Format
        
        enum MarkdownFormat: Equatable {
            case heading(level: Int)
            case bold
            case italic
            case inlineCode
            case codeBlock
            case unorderedList
            case orderedList
            case taskList
            case link
            case image
            
            var markdownText: String {
                switch self {
                case .heading(let level):
                    return "\(String(repeating: "#", count: level)) "
                case .bold:
                    return "****"
                case .italic:
                    return "**"
                case .inlineCode:
                    return "``"
                case .codeBlock:
                    return "\n```\n\n```\n"
                case .unorderedList:
                    return "\n- "
                case .orderedList:
                    return "\n1. "
                case .taskList:
                    return "\n- [ ] "
                case .link:
                    return "[]()"
                case .image:
                    return "![]()"
                }
            }
        }
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.noteRepository) var noteRepository
    @Dependency(\.notaFileManager) var notaFileManager
    @Dependency(\.imageManager) var imageManager
    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.markdownRenderer) var markdownRenderer
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.content):
                print("⚪ [BINDING] Content changed: length=\(state.content.count)")
                // 仅在预览模式下触发渲染
                if state.viewMode != .editOnly {
                    return .send(.preview(.contentChanged(state.content)))
                }
                return .none
                
            case .binding(\.title):
                print("⚪ [BINDING] Title changed: '\(state.title)'")
                // 标题编辑时不自动保存，保证用户输入的连续性和完整性
                // 只有在用户手动切换焦点时（通过 onFocusChange）才触发保存
                // 这样可以避免输入过程中触发列表更新和卡片移动
                return .none
                
            case .binding:
                return .none
                
            case .loadNote(let id):
                print("🟢 [LOAD] Loading note: \(id)")
                print("🟢 [LOAD] Current note: \(state.note?.noteId ?? "none")")
                print("🟢 [LOAD] Has unsaved changes: \(state.hasUnsavedChanges)")
                
                // 判断是否是切换笔记（不是首次加载）
                let isSwitchingNote = state.note != nil && state.note?.noteId != id
                
                // 切换笔记前先保存当前笔记（仅当已有笔记时）
                if state.note != nil && state.hasUnsavedChanges {
                    print("🟡 [LOAD] Saving current note before switching...")
                    return .concatenate(
                        .send(.manualSave),
                        .run { send in
                            // 等待保存完成
                            try await mainQueue.sleep(for: .milliseconds(100))
                            await send(.loadNote(id))
                        }
                    )
                }
                
                // 如果是切换笔记，重置为编辑模式并清除预览内容
                if isSwitchingNote {
                    print("🔄 [LOAD] Switching note - resetting to edit mode")
                    state.viewMode = .editOnly
                    state.preview.renderedHTML = ""
                    state.preview.isRendering = false
                    state.preview.renderError = nil
                    // 取消正在进行的预览渲染
                    return .merge(
                        .cancel(id: CancelID.previewRender),
                        .cancel(id: CancelID.loadNote),
                        .run { send in
                            let note = try await noteRepository.fetchNote(byId: id)
                            await send(.noteLoaded(.success(note)))
                        } catch: { error, send in
                            await send(.noteLoaded(.failure(error)))
                        }
                        .cancellable(id: CancelID.loadNote, cancelInFlight: true)
                    )
                }
                
                state.selectedNoteId = id
                return .merge(
                    .cancel(id: CancelID.loadNote),
                    .run { send in
                        let note = try await noteRepository.fetchNote(byId: id)
                        await send(.noteLoaded(.success(note)))
                    } catch: { error, send in
                        await send(.noteLoaded(.failure(error)))
                    }
                    .cancellable(id: CancelID.loadNote, cancelInFlight: true)
                )
                
            case .noteLoaded(.success(let note)):
                print("✅ [LOAD] Note loaded: \(note.noteId)")
                state.note = note
                state.content = note.content
                state.title = note.title
                state.lastSavedContent = note.content
                state.lastSavedTitle = note.title
                
                // 切换笔记时关闭搜索面板并清除搜索状态
                if state.search.isSearchPanelVisible {
                    state.search.isSearchPanelVisible = false
                    state.search.searchText = ""
                    state.search.replaceText = ""
                    state.search.matches = []
                    state.search.currentMatchIndex = -1
                }

                // 确保切换笔记后始终回到编辑模式
                // 这样可以避免预览内容残留的问题
                if state.viewMode != .editOnly {
                    print("🔄 [LOAD] Resetting to edit mode after note loaded")
                    state.viewMode = .editOnly
                    state.preview.renderedHTML = ""
                    state.preview.isRendering = false
                    state.preview.renderError = nil
                }
                
                // 如果有从笔记列表搜索传递过来的关键词，自动执行搜索并高亮
                if !state.listSearchKeywords.isEmpty {
                    print("🔍 [LOAD] 自动高亮搜索关键词: \(state.listSearchKeywords)")
                    // 捕获关键词和内容，避免在异步闭包中捕获 inout 参数
                    let keywords = state.listSearchKeywords
                    let content = state.content
                    // 使用普通搜索（不区分大小写，不使用正则表达式）
                    return .run { send in
                        let matches = await performListSearch(
                            keywords: keywords,
                            in: content
                        )
                        await send(.updateSearchHighlights(matches: matches, currentIndex: 0))
                    }
                }
                
                return .none
                
            case .noteLoaded(.failure(let error)):
                print("❌ 加载笔记失败: \(error)")
                return .none
                
            case .viewModeChanged(let mode):
                let oldMode = state.viewMode
                // 立即更新状态，确保 UI 立即响应
                state.viewMode = mode
                
                // 切换到预览模式时触发渲染（异步，不阻塞 UI）
                if mode != .editOnly && oldMode == .editOnly {
                    // 直接发送渲染任务，TCA 会异步执行，不会阻塞状态更新
                    return .send(.preview(.render))
                }
                
                // 从预览模式切换到仅编辑
                if mode == .editOnly && oldMode != .editOnly {
                    // 取消渲染任务，释放资源
                    return .cancel(id: CancelID.previewRender)
                }
                
                return .none
                
            case .autoSave:
                print("🔵 [SAVE] autoSave triggered")
                print("🔵 [SAVE] hasUnsavedChanges: \(state.hasUnsavedChanges)")
                print("🔵 [SAVE] note exists: \(state.note != nil)")
                if let note = state.note {
                    print("🔵 [SAVE] note id: \(note.noteId)")
                    print("🔵 [SAVE] Current title: '\(state.title)'")
                    print("🔵 [SAVE] Last saved title: '\(state.lastSavedTitle)'")
                    print("🔵 [SAVE] Current content length: \(state.content.count)")
                    print("🔵 [SAVE] Last saved content length: \(state.lastSavedContent.count)")
                    print("🔵 [SAVE] Title changed: \(state.title != state.lastSavedTitle)")
                    print("🔵 [SAVE] Content changed: \(state.content != state.lastSavedContent)")
                }
                
                guard state.hasUnsavedChanges, let note = state.note else {
                    print("🔴 [SAVE] Skip save - no changes or no note")
                    return .none
                }
                
                print("🟢 [SAVE] Saving note...")
                state.isSaving = true
                
                var updatedNote = note
                updatedNote.title = state.title
                updatedNote.content = state.content
                updatedNote.updated = date.now
                
                // 立即更新本地 state.note，避免状态不一致
                state.note = updatedNote
                
                return .run { [updatedNote] send in
                    try await noteRepository.updateNote(updatedNote)
                    try await notaFileManager.updateNoteFile(updatedNote)
                    await send(.saveCompleted, animation: .spring())
                } catch: { error, send in
                    await send(.saveFailed(error))
                }
                
            case .manualSave:
                print("🟡 [SAVE] manualSave triggered")
                // 手动保存立即触发，不防抖
                return .concatenate(
                    .cancel(id: CancelID.autoSave),
                    .send(.autoSave)
                )
                
            case .saveCompleted:
                print("✅ [SAVE] Save completed successfully")
                state.isSaving = false
                state.lastSavedContent = state.content
                state.lastSavedTitle = state.title
                
                // 更新 state.note 以反映最新的内容和标题
                if var note = state.note {
                    note.title = state.title
                    note.content = state.content
                    note.updated = date.now
                    state.note = note
                }
                
                return .none
                
            case .saveFailed(let error):
                state.isSaving = false
                print("❌ 保存失败: \(error)")
                return .none
                
            case .insertMarkdown(let format):
                let insertion = format.markdownText
                let index = state.content.index(
                    state.content.startIndex,
                    offsetBy: state.cursorPosition,
                    limitedBy: state.content.endIndex
                ) ?? state.content.endIndex
                state.content.insert(contentsOf: insertion, at: index)
                state.cursorPosition += insertion.count
                return .none
                
            case .toggleStar:
                guard var note = state.note else { return .none }
                note.isStarred.toggle()
                note.updated = date.now
                state.note = note
                
                return .run { [note] send in
                    try await noteRepository.updateNote(note)
                    await send(.starToggled)  // 发送完成通知
                }
                
            case .togglePin:
                guard var note = state.note else { return .none }
                note.isPinned.toggle()
                note.updated = date.now
                state.note = note
                
                return .run { [note] send in
                    try await noteRepository.updateNote(note)
                    await send(.pinToggled)  // 发送完成通知
                }
                
            case .starToggled:
                // 完成通知，由 AppFeature 处理
                return .none
                
            case .pinToggled:
                // 完成通知，由 AppFeature 处理
                return .none
                
            case .requestDeleteNote:
                // 显示删除确认对话框
                state.showDeleteConfirmation = true
                return .none
                
            case .confirmDeleteNote:
                // 确认删除
                state.showDeleteConfirmation = false
                guard let noteId = state.selectedNoteId else { return .none }
                
                // 清空所有编辑器状态
                state.note = nil
                state.selectedNoteId = nil
                state.content = ""
                state.title = ""
                state.lastSavedContent = ""
                state.lastSavedTitle = ""
                state.cursorPosition = 0
                
                return .run { send in
                    try await noteRepository.deleteNote(byId: noteId)
                    await send(.noteDeleted(noteId))  // 发送完成通知
                }
                
            case .noteDeleted:
                // 完成通知，由 AppFeature 处理
                return .none
                
            case .cancelDeleteNote:
                // 取消删除
                state.showDeleteConfirmation = false
                return .none
                
            case .createNote:
                print("🆕 [CREATE] Creating new note...")
                let noteId = uuid().uuidString
                let now = date.now
                let newNote = Note(
                    noteId: noteId,
                    title: "无标题",
                    content: "",
                    created: now,
                    updated: now
                )
                print("🆕 [CREATE] New note id: \(noteId)")
                
                return .run { send in
                    try await noteRepository.createNote(newNote)
                    try await notaFileManager.createNoteFile(newNote)
                    await send(.noteCreated(.success(newNote)))
                } catch: { error, send in
                    await send(.noteCreated(.failure(error)))
                }
                
            case .noteCreated(.success(let note)):
                print("✅ [CREATE] Note created successfully: \(note.noteId)")
                state.note = note
                state.selectedNoteId = note.noteId
                state.content = note.content
                state.title = note.title
                state.lastSavedContent = note.content
                state.lastSavedTitle = note.title
                return .none
                
            case .noteCreated(.failure(let error)):
                print("❌ 创建笔记失败: \(error)")
                return .none
                
            case .applyPreferences(let prefs):
                print("📐 [EDITOR] Applying preferences")
                state.editorStyle = EditorStyle(from: prefs)
                return .none
                
            // MARK: - Context Menu Action Handlers
                
            case .formatBold:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatWrap(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "**",
                    placeholder: "粗体文本"
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                // 格式化后触发保存
                return .send(.manualSave)
                
            case .formatItalic:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatWrap(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "*",
                    placeholder: "斜体文本"
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .formatInlineCode:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatWrap(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "`",
                    placeholder: "代码"
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertHeading1:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatLineStart(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "#",
                    replaceExistingPrefixes: ["#", "##", "###", "####", "#####", "######"]
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertHeading2:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatLineStart(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "##",
                    replaceExistingPrefixes: ["#", "##", "###", "####", "#####", "######"]
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertHeading3:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatLineStart(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "###",
                    replaceExistingPrefixes: ["#", "##", "###", "####", "#####", "######"]
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertHeading4:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatLineStart(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "####",
                    replaceExistingPrefixes: ["#", "##", "###", "####", "#####", "######"]
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertHeading5:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatLineStart(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "#####",
                    replaceExistingPrefixes: ["#", "##", "###", "####", "#####", "######"]
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertHeading6:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatLineStart(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "######",
                    replaceExistingPrefixes: ["#", "##", "###", "####", "#####", "######"]
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertUnorderedList:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatLineStart(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "-",
                    replaceExistingPrefixes: ["-", "*", "+"]
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertOrderedList:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatLineStart(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "1.",
                    replaceExistingPrefixes: []
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertTaskList:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatLineStart(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "- [ ]",
                    replaceExistingPrefixes: ["- [ ]", "- [x]"]
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertLink:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatWrap(
                    text: state.content,
                    selection: state.selectionRange,
                    prefix: "[",
                    suffix: "](url)",
                    placeholder: "链接文本"
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertCodeBlock:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.insertCodeBlock(
                    text: state.content,
                    selection: state.selectionRange
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertTable(let columns, let rows):
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.insertTable(
                    text: state.content,
                    selection: state.selectionRange,
                    columns: columns,
                    rows: rows
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertBlockquote:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.insertBlockquote(
                    text: state.content,
                    selection: state.selectionRange
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertHorizontalRule:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.insertHorizontalRule(
                    text: state.content,
                    selection: state.selectionRange
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .formatStrikethrough:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatStrikethrough(
                    text: state.content,
                    selection: state.selectionRange
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .formatUnderline:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.formatUnderline(
                    text: state.content,
                    selection: state.selectionRange
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertFootnote(let footnoteNumber):
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.insertFootnote(
                    text: state.content,
                    selection: state.selectionRange,
                    footnoteNumber: state.footnoteCounter
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                state.footnoteCounter += 1
                return .send(.manualSave)
                
            case .insertInlineMath:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.insertInlineMath(
                    text: state.content,
                    selection: state.selectionRange
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .insertBlockMath:
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.insertBlockMath(
                    text: state.content,
                    selection: state.selectionRange
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                return .send(.manualSave)
                
            case .showImagePicker:
                state.showImagePicker = true
                return .none
                
            case .dismissImagePicker:
                state.showImagePicker = false
                return .none
                
            case .showAttachmentPicker:
                state.showAttachmentPicker = true
                return .none
                
            case .dismissAttachmentPicker:
                state.showAttachmentPicker = false
                return .none
                
            case .insertImage(let url):
                guard let note = state.note else { return .none }
                state.isInsertingImage = true
                state.insertError = nil
                
                return .run { [url, note] send in
                    // 获取笔记目录
                    let noteDirectory = try await notaFileManager.getNoteDirectory(for: note.noteId)
                    let assetsDirectory = noteDirectory.appendingPathComponent("assets")
                    
                    // 确保 assets 目录存在
                    try FileManager.default.createDirectory(
                        at: assetsDirectory,
                        withIntermediateDirectories: true
                    )
                    
                    // 生成文件名
                    let fileExtension = url.pathExtension.isEmpty ? "png" : url.pathExtension
                    let imageId = UUID().uuidString
                    let fileName = "\(imageId).\(fileExtension)"
                    let destinationURL = assetsDirectory.appendingPathComponent(fileName)
                    
                    // 复制文件
                    try FileManager.default.copyItem(at: url, to: destinationURL)
                    
                    // 生成相对路径
                    let relativePath = "assets/\(fileName)"
                    
                    await send(.imageInserted(imageId: imageId, relativePath: relativePath))
                } catch: { error, send in
                    await send(.imageInsertFailed(error))
                }
                
            case .imageInserted(let imageId, let relativePath):
                state.isInsertingImage = false
                guard state.note != nil else { return .none }
                let result = MarkdownFormatter.insertImage(
                    text: state.content,
                    selection: state.selectionRange,
                    altText: "图片",
                    imagePath: relativePath
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                state.showImagePicker = false
                return .send(.manualSave)
                
            case .imageInsertFailed(let error):
                state.isInsertingImage = false
                state.insertError = error.localizedDescription
                state.showImagePicker = false
                return .none
                
            case .insertAttachment(let url):
                guard let note = state.note else { return .none }
                state.isInsertingAttachment = true
                state.insertError = nil
                
                return .run { [url, note] send in
                    // 获取笔记目录
                    let noteDirectory = try await notaFileManager.getNoteDirectory(for: note.noteId)
                    let attachmentsDirectory = noteDirectory.appendingPathComponent("attachments")
                    
                    // 确保 attachments 目录存在
                    try FileManager.default.createDirectory(
                        at: attachmentsDirectory,
                        withIntermediateDirectories: true
                    )
                    
                    // 获取文件名
                    let fileName = url.lastPathComponent
                    let destinationURL = attachmentsDirectory.appendingPathComponent(fileName)
                    
                    // 如果文件已存在，添加序号
                    var finalFileName = fileName
                    var finalDestinationURL = destinationURL
                    var counter = 1
                    while FileManager.default.fileExists(atPath: finalDestinationURL.path) {
                        let nameWithoutExt = (fileName as NSString).deletingPathExtension
                        let ext = (fileName as NSString).pathExtension
                        finalFileName = "\(nameWithoutExt)_\(counter).\(ext)"
                        finalDestinationURL = attachmentsDirectory.appendingPathComponent(finalFileName)
                        counter += 1
                    }
                    
                    // 复制文件
                    try FileManager.default.copyItem(at: url, to: finalDestinationURL)
                    
                    // 生成相对路径
                    let relativePath = "attachments/\(finalFileName)"
                    
                    await send(.attachmentInserted(fileName: finalFileName, relativePath: relativePath))
                } catch: { error, send in
                    await send(.attachmentInsertFailed(error))
                }
                
            case .attachmentInserted(let fileName, let relativePath):
                state.isInsertingAttachment = false
                guard state.note != nil else { return .none }
                let nameWithoutExt = (fileName as NSString).deletingPathExtension
                let result = MarkdownFormatter.insertAttachment(
                    text: state.content,
                    selection: state.selectionRange,
                    fileName: nameWithoutExt,
                    filePath: relativePath
                )
                state.content = result.newText
                state.selectionRange = result.newSelection
                state.showAttachmentPicker = false
                return .send(.manualSave)
                
            case .attachmentInsertFailed(let error):
                state.isInsertingAttachment = false
                state.insertError = error.localizedDescription
                state.showAttachmentPicker = false
                return .none
                
            case .selectionChanged(let range):
                state.selectionRange = range
                return .none
                
            case .focusChanged(let isFocused):
                // 失去焦点时保存
                if !isFocused {
                    print("🟡 [FOCUS] Editor lost focus, triggering save")
                    return .send(.manualSave)
                }
                return .none
            
            // MARK: - Preview Action Handlers
            
            case .preview(.onAppear):
                // 预览组件加载时，如果已有内容则渲染
                if !state.content.isEmpty && state.preview.renderedHTML.isEmpty {
                    return .send(.preview(.render))
                }
                return .none
            
            case .preview(.contentChanged(let content)):
                // 防抖 300ms 后再渲染
                return .send(.preview(.renderDebounced))
                    .debounce(id: CancelID.previewRender, for: .milliseconds(300), scheduler: mainQueue)
            
            case .preview(.render), .preview(.renderDebounced):
                // 取消之前的渲染任务
                guard !state.content.isEmpty else {
                    state.preview.renderedHTML = ""
                    return .none
                }
                
                state.preview.isRendering = true
                state.preview.renderError = nil
                
                let content = state.content
                let options = state.preview.renderOptions
                
                return .run { send in
                    let html = try await markdownRenderer.renderToHTML(
                        markdown: content,
                        options: options
                    )
                    await send(.preview(.renderCompleted(.success(html))))
                } catch: { error, send in
                    await send(.preview(.renderCompleted(.failure(error))))
                }
                .cancellable(id: CancelID.previewRender, cancelInFlight: true)
            
            case .preview(.renderCompleted(.success(let html))):
                state.preview.isRendering = false
                state.preview.renderedHTML = html
                return .none
            
            case .preview(.renderCompleted(.failure(let error))):
                state.preview.isRendering = false
                state.preview.renderError = error.localizedDescription
                return .none
            
            case .preview(.themeChanged(let themeId)):
                // 主题变更时重新渲染
                state.preview.currentThemeId = themeId
                state.preview.renderOptions.themeId = themeId
                if state.viewMode != .editOnly {
                    return .send(.preview(.render))
                }
                return .none
            
            case .preview(.renderOptionsChanged(let options)):
                state.preview.renderOptions = options
                if state.viewMode != .editOnly {
                    return .send(.preview(.render))
                }
                return .none
            
            case .preview(.cancelRender):
                return .cancel(id: CancelID.previewRender)
            
            case .preview(.dismissError):
                state.preview.renderError = nil
                return .none
            
            // MARK: - Search Action Handlers
            
            case .search(.showSearchPanel):
                state.search.isSearchPanelVisible = true
                return .none
                
            case .search(.hideSearchPanel):
                state.search.isSearchPanelVisible = false
                state.search.searchText = ""
                state.search.replaceText = ""
                state.search.matches = []
                state.search.currentMatchIndex = -1
                return .run { send in
                    // 清除编辑器中的高亮
                    await send(.clearSearchHighlights)
                }
                
            case .search(.toggleSearchPanel):
                // 切换搜索面板显示/隐藏状态
                state.search.isSearchPanelVisible.toggle()
                // 如果关闭面板，清除搜索文本和匹配结果
                if !state.search.isSearchPanelVisible {
                    state.search.searchText = ""
                    state.search.replaceText = ""
                    state.search.matches = []
                    state.search.currentMatchIndex = -1
                    return .run { send in
                        // 清除编辑器中的高亮
                        await send(.clearSearchHighlights)
                    }
                }
                return .none
                
            case .search(.toggleReplaceMode):
                state.search.isReplaceMode.toggle()
                print("🔄 [SEARCH] 替换模式切换: \(state.search.isReplaceMode)")
                return .none
                
            case .search(.searchTextChanged(let text)):
                state.search.searchText = text
                if text.isEmpty {
                    state.search.matches = []
                    state.search.currentMatchIndex = -1
                    return .run { send in
                        await send(.clearSearchHighlights)
                    }
                }
                // 执行搜索（异步）
                // 注意：需要捕获当前的 search state，因为 state 可能在闭包执行前改变
                let currentOptions = state.search
                return .run { [content = state.content] send in
                    let matches = await performSearch(
                        text: text,
                        in: content,
                        options: currentOptions
                    )
                    await send(.search(.updateMatches(matches)))
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)
                
            case .search(.replaceTextChanged(let text)):
                state.search.replaceText = text
                return .none
                
            case .search(.matchCaseToggled):
                state.search.matchCase.toggle()
                // 重新搜索
                if !state.search.searchText.isEmpty {
                    return .run { [content = state.content, searchText = state.search.searchText, options = state.search] send in
                        let matches = await performSearch(
                            text: searchText,
                            in: content,
                            options: options
                        )
                        await send(.search(.updateMatches(matches)))
                    }
                }
                return .none
                
            case .search(.wholeWordsToggled):
                state.search.wholeWords.toggle()
                // 重新搜索
                if !state.search.searchText.isEmpty {
                    return .run { [content = state.content, searchText = state.search.searchText, options = state.search] send in
                        let matches = await performSearch(
                            text: searchText,
                            in: content,
                            options: options
                        )
                        await send(.search(.updateMatches(matches)))
                    }
                }
                return .none
                
            case .search(.useRegexToggled):
                state.search.useRegex.toggle()
                // 重新搜索
                if !state.search.searchText.isEmpty {
                    return .run { [content = state.content, searchText = state.search.searchText, options = state.search] send in
                        let matches = await performSearch(
                            text: searchText,
                            in: content,
                            options: options
                        )
                        await send(.search(.updateMatches(matches)))
                    }
                }
                return .none
                
            case .search(.updateMatches(let matches)):
                print("🔍 [SEARCH] 更新匹配项: \(matches.count) 个")
                state.search.matches = matches
                if matches.isEmpty {
                    state.search.currentMatchIndex = -1
                } else if state.search.currentMatchIndex < 0 {
                    // 如果有匹配项但未选中，选中第一个
                    state.search.currentMatchIndex = 0
                }
                let currentIndex = state.search.currentMatchIndex
                print("🔍 [SEARCH] 当前匹配索引: \(currentIndex)")
                // 状态更新会自动触发 MarkdownTextEditor 的 updateNSView
                // 通过 searchMatches 和 currentSearchIndex 参数传递
                return .none
                
            case .search(.findNext):
                guard !state.search.matches.isEmpty else { return .none }
                let nextIndex = (state.search.currentMatchIndex + 1) % state.search.matches.count
                state.search.currentMatchIndex = nextIndex
                // 状态更新会自动触发 MarkdownTextEditor 的 updateNSView
                return .none
                
            case .search(.findPrevious):
                guard !state.search.matches.isEmpty else { return .none }
                let prevIndex = state.search.currentMatchIndex <= 0 
                    ? state.search.matches.count - 1 
                    : state.search.currentMatchIndex - 1
                state.search.currentMatchIndex = prevIndex
                // 状态更新会自动触发 MarkdownTextEditor 的 updateNSView
                return .none
                
            case .search(.replaceCurrent):
                guard let currentMatch = state.search.currentMatch,
                      !state.search.replaceText.isEmpty else {
                    return .none
                }
                // 通过 NotificationCenter 通知 NSTextView 执行替换（支持 undo/redo）
                // isGrouped = false 表示这是单个替换操作，不需要 undo grouping
                NotificationCenter.default.post(
                    name: NSNotification.Name("PerformReplaceInTextView"),
                    object: nil,
                    userInfo: [
                        "range": currentMatch,
                        "replacement": state.search.replaceText,
                        "isGrouped": false
                    ]
                )
                
                // 不立即更新 state.content，等待 textDidChange 通知来更新
                // 这样可以避免 updateNSView 中的 textView.string = text 清除 undo stack
                // 先计算预期的新内容用于重新搜索
                let mutableText = NSMutableString(string: state.content)
                mutableText.replaceCharacters(in: currentMatch, with: state.search.replaceText)
                let expectedContent = mutableText as String
                
                // 重新搜索（因为内容已改变）
                let searchText = state.search.searchText
                let searchOptions = state.search
                return .run { send in
                    // 等待 NSTextView 完成替换并触发 textDidChange 更新 state.content
                    try? await Task.sleep(for: .milliseconds(100))
                    // 使用预期内容进行搜索（实际内容应该已经通过 textDidChange 同步）
                    let matches = await performSearch(
                        text: searchText,
                        in: expectedContent,
                        options: searchOptions
                    )
                    await send(.search(.updateMatches(matches)))
                }
                
            case .search(.replaceAll):
                guard !state.search.matches.isEmpty,
                      !state.search.replaceText.isEmpty else {
                    return .none
                }
                // 从后往前替换，避免索引偏移（通过 NotificationCenter 通知 NSTextView）
                // 使用 isGrouped = true 将所有替换操作放在一个 undo group 中
                let ranges = state.search.matches.reversed()
                let totalCount = ranges.count
                for (index, range) in ranges.enumerated() {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("PerformReplaceInTextView"),
                        object: nil,
                        userInfo: [
                            "range": range,
                            "replacement": state.search.replaceText,
                            "isGrouped": true,
                            "isFirst": index == 0,
                            "isLast": index == totalCount - 1
                        ]
                    )
                }
                
                // 不立即更新 state.content，等待 textDidChange 通知来更新
                // 这样可以避免 updateNSView 中的 textView.string = text 清除 undo stack
                
                // 清除搜索结果
                state.search.matches = []
                state.search.currentMatchIndex = -1
                return .run { send in
                    // 等待一小段时间，让所有替换完成并触发 textDidChange
                    try? await Task.sleep(for: .milliseconds(150))
                    await send(.clearSearchHighlights)
                }
                
            case .search(.selectMatch(let index)):
                // 内部使用，由高亮逻辑处理
                return .none
            
            // MARK: - Search Highlight Action Handlers
            
            case .updateSearchHighlights(let matches, let currentIndex):
                // 更新搜索高亮状态
                state.search.matches = matches
                state.search.currentMatchIndex = currentIndex
                print("🔍 [HIGHLIGHT] 更新高亮: \(matches.count) 个匹配项, 当前索引: \(currentIndex)")
                // 状态更新会触发 MarkdownTextEditor 的 updateNSView，从而更新高亮
                return .none
                
            case .clearSearchHighlights:
                // 清除高亮：将 matches 和 currentIndex 重置
                // 状态更新会触发 MarkdownTextEditor 的 updateNSView，从而清除高亮
                state.search.matches = []
                state.search.currentMatchIndex = -1
                return .none
                
            case .setListSearchKeywords(let keywords):
                // 设置从笔记列表搜索传递过来的关键词
                state.listSearchKeywords = keywords
                print("🔍 [LIST_SEARCH] 设置搜索关键词: \(keywords)")
                return .none
            }
        }
    }
    
    // MARK: - Search Helper Functions
    
    /// 执行笔记列表搜索（支持多关键词，AND 逻辑）
    private func performListSearch(
        keywords: [String],
        in content: String
    ) async -> [NSRange] {
        guard !keywords.isEmpty else { return [] }
        
        let nsContent = content as NSString
        let lowercaseContent = content.lowercased()
        var allMatches: [NSRange] = []
        
        // 对于每个关键词，找到所有匹配项
        for keyword in keywords {
            guard !keyword.isEmpty else { continue }
            let lowercaseKeyword = keyword.lowercased()
            var keywordMatches: [NSRange] = []
            
            var searchRange = NSRange(location: 0, length: nsContent.length)
            while searchRange.location < nsContent.length {
                // 在 lowercaseContent 中搜索（不区分大小写）
                if let range = lowercaseContent.range(
                    of: lowercaseKeyword,
                    range: Range(searchRange, in: lowercaseContent)
                ) {
                    let nsRange = NSRange(range, in: content)
                    keywordMatches.append(nsRange)
                    
                    // 继续搜索下一个匹配项
                    let nextLocation = nsRange.location + nsRange.length
                    if nextLocation >= nsContent.length {
                        break
                    }
                    searchRange = NSRange(location: nextLocation, length: nsContent.length - nextLocation)
                } else {
                    break
                }
            }
            
            // 如果是第一个关键词，直接使用其匹配项
            if allMatches.isEmpty {
                allMatches = keywordMatches
            } else {
                // 对于后续关键词，只保留与之前匹配项重叠或相邻的匹配项
                // 这里简化处理：保留所有匹配项，让用户看到所有可能的匹配
                allMatches.append(contentsOf: keywordMatches)
            }
        }
        
        // 去重并排序
        allMatches = Array(Set(allMatches)).sorted { $0.location < $1.location }
        
        return allMatches
    }
    
    /// 执行搜索
    private func performSearch(
        text: String,
        in content: String,
        options: State.SearchState
    ) async -> [NSRange] {
        guard !text.isEmpty else { return [] }
        
        var searchText = text
        var contentText = content
        
        // 处理大小写
        if !options.matchCase {
            searchText = searchText.lowercased()
            contentText = contentText.lowercased()
        }
        
        // 处理正则表达式
        if options.useRegex {
            return await performRegexSearch(
                pattern: text,  // 使用原始文本，不转换大小写
                in: content,   // 使用原始内容
                matchCase: options.matchCase
            )
        }
        
        // 处理全词匹配
        if options.wholeWords {
            return await performWholeWordSearch(
                word: text,     // 使用原始文本
                in: content,   // 使用原始内容
                matchCase: options.matchCase
            )
        }
        
        // 普通搜索
        // 使用 NSString 的 rangeOfString 方法，它更可靠地处理 Unicode 和大小写
        var matches: [NSRange] = []
        let nsContent = content as NSString
        
        var searchOptions: NSString.CompareOptions = []
        if !options.matchCase {
            searchOptions.insert(.caseInsensitive)
        }
        
        var searchRange = NSRange(location: 0, length: nsContent.length)
        while searchRange.location < nsContent.length {
            let foundRange = nsContent.range(
                of: text,
                options: searchOptions,
                range: searchRange
            )
            
            if foundRange.location == NSNotFound {
                break
            }
            
            matches.append(foundRange)
            
            // 继续搜索下一个匹配项
            let nextLocation = foundRange.location + foundRange.length
            if nextLocation >= nsContent.length {
                break
            }
            searchRange = NSRange(location: nextLocation, length: nsContent.length - nextLocation)
        }
        
        return matches
    }
    
    /// 执行正则表达式搜索
    private func performRegexSearch(
        pattern: String,
        in content: String,
        matchCase: Bool
    ) async -> [NSRange] {
        var options: NSRegularExpression.Options = []
        if !matchCase {
            options.insert(.caseInsensitive)
        }
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return []
        }
        
        let nsContent = content as NSString
        let matches = regex.matches(in: content, range: NSRange(location: 0, length: nsContent.length))
        return matches.map { $0.range }
    }
    
    /// 执行全词匹配搜索
    private func performWholeWordSearch(
        word: String,
        in content: String,
        matchCase: Bool
    ) async -> [NSRange] {
        var searchText = word
        var contentText = content
        
        if !matchCase {
            searchText = searchText.lowercased()
            contentText = contentText.lowercased()
        }
        
        var matches: [NSRange] = []
        let nsContent = content as NSString
        let nsContentLower = contentText as NSString
        
        // 使用正则表达式匹配单词边界
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: searchText))\\b"
        let options: NSRegularExpression.Options = matchCase ? [] : .caseInsensitive
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return []
        }
        
        let regexMatches = regex.matches(in: content, range: NSRange(location: 0, length: nsContent.length))
        return regexMatches.map { $0.range }
    }
    
    // MARK: - Cancel IDs
    
    enum CancelID {
        case autoSave
        case loadNote
        case previewRender
        case search
    }
}

// MARK: - EditorFeature.State Extension - Toolbar Derived State

extension EditorFeature.State {
    // MARK: - Toolbar State (Derived)
    
    /// 检测当前选中文本是否为加粗格式
    var isBoldActive: Bool {
        guard selectionRange.length > 0 else { return false }
        guard selectionRange.location < content.utf16.count else { return false }
        guard selectionRange.location + selectionRange.length <= content.utf16.count else { return false }
        
        let selectedText = (content as NSString).substring(with: selectionRange)
        return selectedText.hasPrefix("**") && selectedText.hasSuffix("**")
    }
    
    /// 检测当前选中文本是否为斜体格式
    var isItalicActive: Bool {
        guard selectionRange.length > 0 else { return false }
        guard selectionRange.location < content.utf16.count else { return false }
        guard selectionRange.location + selectionRange.length <= content.utf16.count else { return false }
        
        let selectedText = (content as NSString).substring(with: selectionRange)
        // 排除加粗（**text**），只检测斜体（*text*）
        if selectedText.hasPrefix("**") && selectedText.hasSuffix("**") {
            return false
        }
        return selectedText.hasPrefix("*") && selectedText.hasSuffix("*")
    }
    
    /// 检测当前选中文本是否为行内代码
    var isInlineCodeActive: Bool {
        guard selectionRange.length > 0 else { return false }
        guard selectionRange.location < content.utf16.count else { return false }
        guard selectionRange.location + selectionRange.length <= content.utf16.count else { return false }
        
        let selectedText = (content as NSString).substring(with: selectionRange)
        return selectedText.hasPrefix("`") && selectedText.hasSuffix("`")
    }
    
    /// 检测当前选中文本是否为删除线格式
    var isStrikethroughActive: Bool {
        guard selectionRange.length > 0 else { return false }
        guard selectionRange.location < content.utf16.count else { return false }
        guard selectionRange.location + selectionRange.length <= content.utf16.count else { return false }
        
        let selectedText = (content as NSString).substring(with: selectionRange)
        return selectedText.hasPrefix("~~") && selectedText.hasSuffix("~~")
    }
    
    /// 检测当前行是否为标题，返回标题级别（1-6）或 nil
    var currentHeadingLevel: Int? {
        guard selectionRange.location < content.utf16.count else { return nil }
        
        // 计算当前行号
        let textBeforeSelection = (content as NSString).substring(to: selectionRange.location)
        let lines = textBeforeSelection.components(separatedBy: .newlines)
        let lineNumber = lines.count - 1
        
        // 获取所有行
        let allLines = content.components(separatedBy: .newlines)
        guard lineNumber >= 0 && lineNumber < allLines.count else { return nil }
        
        let currentLine = allLines[lineNumber]
        
        // 检测标题级别
        if currentLine.hasPrefix("# ") { return 1 }
        if currentLine.hasPrefix("## ") { return 2 }
        if currentLine.hasPrefix("### ") { return 3 }
        if currentLine.hasPrefix("#### ") { return 4 }
        if currentLine.hasPrefix("##### ") { return 5 }
        if currentLine.hasPrefix("###### ") { return 6 }
        
        return nil
    }
    
    /// 工具栏是否可用（有打开的笔记）
    var isToolbarEnabled: Bool {
        note != nil
    }
}


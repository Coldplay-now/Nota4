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
        
        // MARK: - Preview State
        
        struct PreviewState: Equatable {
            var renderedHTML: String = ""
            var isRendering: Bool = false
            var renderError: String? = nil
            var currentThemeId: String? = nil
            var includeTOC: Bool = false
            var renderOptions: RenderOptions = .default
        }
        
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
        case deleteNote
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
        case insertUnorderedList
        case insertOrderedList
        case insertTaskList
        case insertLink
        case insertCodeBlock
        
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
                // 不再自动保存，避免干扰输入
                return .none
                
            case .binding:
                return .none
                
            case .loadNote(let id):
                print("🟢 [LOAD] Loading note: \(id)")
                print("🟢 [LOAD] Current note: \(state.note?.noteId ?? "none")")
                print("🟢 [LOAD] Has unsaved changes: \(state.hasUnsavedChanges)")
                
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
                state.note = note
                state.content = note.content
                state.title = note.title
                state.lastSavedContent = note.content
                state.lastSavedTitle = note.title
                return .none
                
            case .noteLoaded(.failure(let error)):
                print("❌ 加载笔记失败: \(error)")
                return .none
                
            case .viewModeChanged(let mode):
                let oldMode = state.viewMode
                state.viewMode = mode
                
                // 切换到预览模式时触发渲染
                if mode != .editOnly && oldMode == .editOnly {
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
                
            case .insertImage(let sourceURL):
                guard let noteId = state.selectedNoteId else {
                    return .none
                }
                
                return .run { send in
                    let imageId = try await imageManager.copyImage(from: sourceURL, to: noteId)
                    let relativePath = "attachments/\(noteId)/\(imageId)"
                    await send(.imageInserted(imageId: imageId, relativePath: relativePath))
                } catch: { error, send in
                    await send(.imageInsertFailed(error))
                }
                
            case .imageInserted(_, let relativePath):
                let markdown = "\n![\(relativePath)](\(relativePath))\n"
                let index = state.content.index(
                    state.content.startIndex,
                    offsetBy: state.cursorPosition,
                    limitedBy: state.content.endIndex
                ) ?? state.content.endIndex
                state.content.insert(contentsOf: markdown, at: index)
                state.cursorPosition += markdown.count
                return .none
                
            case .imageInsertFailed(let error):
                print("❌ 插入图片失败: \(error)")
                return .none
                
            case .toggleStar:
                guard var note = state.note else { return .none }
                note.isStarred.toggle()
                note.updated = date.now
                state.note = note
                
                return .run { [note] send in
                    try await noteRepository.updateNote(note)
                }
                
            case .deleteNote:
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
                }
                
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
            }
        }
    }
    
    // MARK: - Cancel IDs
    
    enum CancelID {
        case autoSave
        case loadNote
        case previewRender
    }
}


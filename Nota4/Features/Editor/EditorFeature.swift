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
        case noteCreated(Result<Note, Error>)
        
        // MARK: - Markdown Format
        
        enum MarkdownFormat: Equatable {
            case heading(level: Int)
            case bold
            case italic
            case codeBlock
            case unorderedList
            case orderedList
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
                case .codeBlock:
                    return "\n```\n\n```\n"
                case .unorderedList:
                    return "\n- "
                case .orderedList:
                    return "\n1. "
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
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.content):
                // 防抖自动保存（2 秒 - 避免干扰快速输入）
                return .run { send in
                    try await mainQueue.sleep(for: .milliseconds(2000))
                    await send(.autoSave, animation: .spring())
                }
                .cancellable(id: CancelID.autoSave, cancelInFlight: true)
                
            case .binding(\.title):
                // 防抖自动保存（2 秒 - 避免干扰快速输入）
                return .run { send in
                    try await mainQueue.sleep(for: .milliseconds(2000))
                    await send(.autoSave, animation: .spring())
                }
                .cancellable(id: CancelID.autoSave, cancelInFlight: true)
                
            case .binding:
                return .none
                
            case .loadNote(let id):
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
                state.viewMode = mode
                return .none
                
            case .autoSave:
                guard state.hasUnsavedChanges, let note = state.note else {
                    return .none
                }
                
                state.isSaving = true
                
                var updatedNote = note
                updatedNote.title = state.title
                updatedNote.content = state.content
                updatedNote.updated = date.now
                
                return .run { [updatedNote] send in
                    try await noteRepository.updateNote(updatedNote)
                    try await notaFileManager.updateNoteFile(updatedNote)
                    await send(.saveCompleted, animation: .spring())
                } catch: { error, send in
                    await send(.saveFailed(error))
                }
                
            case .manualSave:
                // 手动保存立即触发，不防抖
                return .concatenate(
                    .cancel(id: CancelID.autoSave),
                    .send(.autoSave)
                )
                
            case .saveCompleted:
                state.isSaving = false
                state.lastSavedContent = state.content
                state.lastSavedTitle = state.title
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
                let noteId = uuid().uuidString
                let now = date.now
                let newNote = Note(
                    noteId: noteId,
                    title: "无标题",
                    content: "",
                    created: now,
                    updated: now
                )
                
                return .run { send in
                    try await noteRepository.createNote(newNote)
                    try await notaFileManager.createNoteFile(newNote)
                    await send(.noteCreated(.success(newNote)))
                } catch: { error, send in
                    await send(.noteCreated(.failure(error)))
                }
                
            case .noteCreated(.success(let note)):
                state.note = note
                state.selectedNoteId = note.noteId
                state.content = ""
                state.title = "无标题"
                state.lastSavedContent = ""
                state.lastSavedTitle = "无标题"
                return .none
                
            case .noteCreated(.failure(let error)):
                print("❌ 创建笔记失败: \(error)")
                return .none
            }
        }
    }
    
    // MARK: - Cancel IDs
    
    enum CancelID {
        case autoSave
        case loadNote
    }
}


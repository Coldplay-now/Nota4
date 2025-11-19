import ComposableArchitecture
import Foundation
import GRDB

// MARK: - NoteRepository Dependency

extension DependencyValues {
    var noteRepository: NoteRepositoryProtocol {
        get { self[NoteRepositoryKey.self] }
        set { self[NoteRepositoryKey.self] = newValue }
    }
}

private enum NoteRepositoryKey: DependencyKey {
    static let liveValue: NoteRepositoryProtocol = NoteRepository.shared
    static let testValue: NoteRepositoryProtocol = NoteRepository.mock
}

// MARK: - NotaFileManager Dependency

extension DependencyValues {
    var notaFileManager: NotaFileManagerProtocol {
        get { self[NotaFileManagerKey.self] }
        set { self[NotaFileManagerKey.self] = newValue }
    }
}

private enum NotaFileManagerKey: DependencyKey {
    static let liveValue: NotaFileManagerProtocol = NotaFileManager.shared
    static let testValue: NotaFileManagerProtocol = NotaFileManager.mock
}

// MARK: - ImageManager Dependency

extension DependencyValues {
    var imageManager: ImageManagerProtocol {
        get { self[ImageManagerKey.self] }
        set { self[ImageManagerKey.self] = newValue }
    }
}

private enum ImageManagerKey: DependencyKey {
    static let liveValue: ImageManagerProtocol = ImageManager.shared
    static let testValue: ImageManagerProtocol = ImageManager.mock
}

// MARK: - MarkdownRenderer Dependency

extension DependencyValues {
    var markdownRenderer: MarkdownRenderer {
        get { self[MarkdownRendererKey.self] }
        set { self[MarkdownRendererKey.self] = newValue }
    }
}

private enum MarkdownRendererKey: DependencyKey {
    static let liveValue: MarkdownRenderer = MarkdownRenderer()
    static let testValue: MarkdownRenderer = MarkdownRenderer()
}

// MARK: - Protocol Definitions

protocol NoteRepositoryProtocol {
    func createNote(_ note: Note) async throws
    func fetchNote(byId noteId: String) async throws -> Note
    func fetchNotes(filter: NoteListFeature.State.Filter) async throws -> [Note]
    func updateNote(_ note: Note) async throws
    func deleteNote(byId noteId: String) async throws
    func deleteNotes(_ noteIds: Set<String>) async throws
    func restoreNotes(_ noteIds: Set<String>) async throws
    func permanentlyDeleteNotes(_ noteIds: Set<String>) async throws
    func fetchAllTags() async throws -> [SidebarFeature.State.Tag]
    func getTotalCount() async throws -> Int
}

protocol NotaFileManagerProtocol {
    func createNoteFile(_ note: Note) async throws
    func readNoteFile(noteId: String) async throws -> String
    func updateNoteFile(_ note: Note) async throws
    func deleteNoteFile(noteId: String) async throws
    func restoreFromTrash(noteId: String) async throws
    func getNoteDirectory(for noteId: String) async throws -> URL
}

protocol ImageManagerProtocol {
    func copyImage(from sourceURL: URL, to noteId: String) async throws -> String
    func deleteImages(forNote noteId: String) async throws
    func getImageURL(noteId: String, imageId: String) -> URL
}

// MARK: - Mock Implementations

// NoteRepository is now defined in NoteRepository.swift

// NotaFileManager is now defined in NotaFileManager.swift

// ImageManager is now defined in ImageManager.swift


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
    static let liveValue: NoteRepositoryProtocol = NoteRepository.live
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
    static let liveValue: NotaFileManagerProtocol = NotaFileManager.live
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
    static let liveValue: ImageManagerProtocol = ImageManager.live
    static let testValue: ImageManagerProtocol = ImageManager.mock
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
}

protocol NotaFileManagerProtocol {
    func createNoteFile(_ note: Note) async throws
    func readNoteFile(noteId: String) async throws -> String
    func updateNoteFile(_ note: Note) async throws
    func deleteNoteFile(noteId: String) async throws
}

protocol ImageManagerProtocol {
    func copyImage(from sourceURL: URL, to noteId: String) async throws -> String
    func deleteImages(forNote noteId: String) async throws
    func getImageURL(noteId: String, imageId: String) -> URL
}

// MARK: - Mock Implementations

struct NoteRepository: NoteRepositoryProtocol {
    static let live = NoteRepository()
    static let mock = NoteRepository()
    
    func createNote(_ note: Note) async throws {
        // TODO: Implement in Week 2
        print("📝 Creating note: \(note.title)")
    }
    
    func fetchNote(byId noteId: String) async throws -> Note {
        // TODO: Implement in Week 2
        print("📖 Fetching note: \(noteId)")
        return Note.mock
    }
    
    func fetchNotes(filter: NoteListFeature.State.Filter) async throws -> [Note] {
        // TODO: Implement in Week 2
        print("📚 Fetching notes with filter")
        return Note.mockData
    }
    
    func updateNote(_ note: Note) async throws {
        // TODO: Implement in Week 2
        print("💾 Updating note: \(note.title)")
    }
    
    func deleteNote(byId noteId: String) async throws {
        // TODO: Implement in Week 2
        print("🗑️ Deleting note: \(noteId)")
    }
    
    func deleteNotes(_ noteIds: Set<String>) async throws {
        // TODO: Implement in Week 2
        print("🗑️ Deleting \(noteIds.count) notes")
    }
    
    func restoreNotes(_ noteIds: Set<String>) async throws {
        // TODO: Implement in Week 2
        print("♻️ Restoring \(noteIds.count) notes")
    }
    
    func permanentlyDeleteNotes(_ noteIds: Set<String>) async throws {
        // TODO: Implement in Week 2
        print("💣 Permanently deleting \(noteIds.count) notes")
    }
    
    func fetchAllTags() async throws -> [SidebarFeature.State.Tag] {
        // TODO: Implement in Week 2
        return [
            SidebarFeature.State.Tag(name: "工作", count: 3),
            SidebarFeature.State.Tag(name: "学习", count: 2),
            SidebarFeature.State.Tag(name: "生活", count: 1),
        ]
    }
}

struct NotaFileManager: NotaFileManagerProtocol {
    static let live = NotaFileManager()
    static let mock = NotaFileManager()
    
    func createNoteFile(_ note: Note) async throws {
        // TODO: Implement in Week 2
        print("📄 Creating note file: \(note.fileName)")
    }
    
    func readNoteFile(noteId: String) async throws -> String {
        // TODO: Implement in Week 2
        print("📖 Reading note file: \(noteId)")
        return "# Mock Note\n\nContent..."
    }
    
    func updateNoteFile(_ note: Note) async throws {
        // TODO: Implement in Week 2
        print("💾 Updating note file: \(note.fileName)")
    }
    
    func deleteNoteFile(noteId: String) async throws {
        // TODO: Implement in Week 2
        print("🗑️ Deleting note file: \(noteId)")
    }
}

struct ImageManager: ImageManagerProtocol {
    static let live = ImageManager()
    static let mock = ImageManager()
    
    func copyImage(from sourceURL: URL, to noteId: String) async throws -> String {
        // TODO: Implement in Week 2
        print("🖼️ Copying image to note: \(noteId)")
        return "img_001.png"
    }
    
    func deleteImages(forNote noteId: String) async throws {
        // TODO: Implement in Week 2
        print("🗑️ Deleting images for note: \(noteId)")
    }
    
    func getImageURL(noteId: String, imageId: String) -> URL {
        // TODO: Implement in Week 2
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL
            .appendingPathComponent("NotaLibrary")
            .appendingPathComponent("attachments")
            .appendingPathComponent(noteId)
            .appendingPathComponent(imageId)
    }
}


import Foundation
import AppKit

/// 图片管理器实现
struct ImageManagerImpl: ImageManagerProtocol {
    // MARK: - Properties
    
    private let attachmentsDirectory: URL
    
    // MARK: - Initialization
    
    init(attachmentsDirectory: URL) throws {
        self.attachmentsDirectory = attachmentsDirectory
        try FileManager.default.createDirectory(at: attachmentsDirectory, withIntermediateDirectories: true)
    }
    
    static func `default`() throws -> ImageManagerImpl {
        let libraryURL = try FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let attachmentsDirectory = libraryURL
            .appendingPathComponent("Containers")
            .appendingPathComponent("com.nota4.Nota4")
            .appendingPathComponent("Data")
            .appendingPathComponent("Documents")
            .appendingPathComponent("NotaLibrary")
            .appendingPathComponent("attachments")
        
        return try ImageManagerImpl(attachmentsDirectory: attachmentsDirectory)
    }
    
    // MARK: - Image Operations
    
    func copyImage(from sourceURL: URL, to noteId: String) async throws -> String {
        // 创建笔记的附件目录
        let noteAttachmentsDir = attachmentsDirectory.appendingPathComponent(noteId)
        try FileManager.default.createDirectory(at: noteAttachmentsDir, withIntermediateDirectories: true)
        
        // 生成图片 ID
        let fileExtension = sourceURL.pathExtension
        let imageId = generateImageId(in: noteAttachmentsDir, extension: fileExtension)
        
        // 复制图片
        let destinationURL = noteAttachmentsDir.appendingPathComponent(imageId)
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        
        return imageId
    }
    
    func deleteImages(forNote noteId: String) async throws {
        let noteAttachmentsDir = attachmentsDirectory.appendingPathComponent(noteId)
        
        guard FileManager.default.fileExists(atPath: noteAttachmentsDir.path) else {
            return
        }
        
        try FileManager.default.removeItem(at: noteAttachmentsDir)
    }
    
    func getImageURL(noteId: String, imageId: String) -> URL {
        attachmentsDirectory
            .appendingPathComponent(noteId)
            .appendingPathComponent(imageId)
    }
    
    // MARK: - Helper Methods
    
    /// 生成图片 ID（格式：img_001.png）
    private func generateImageId(in directory: URL, extension ext: String) -> String {
        var counter = 1
        var imageId: String
        var imageURL: URL
        
        repeat {
            imageId = String(format: "img_%03d.%@", counter, ext)
            imageURL = directory.appendingPathComponent(imageId)
            counter += 1
        } while FileManager.default.fileExists(atPath: imageURL.path)
        
        return imageId
    }
    
    /// 生成缩略图（可选功能，v1.1 实现）
    func generateThumbnail(for imageURL: URL, size: CGSize = CGSize(width: 200, height: 200)) async throws -> URL {
        guard let image = NSImage(contentsOf: imageURL) else {
            throw ImageManagerError.invalidImage
        }
        
        let thumbnail = resizeImage(image, to: size)
        let thumbnailURL = imageURL.deletingLastPathComponent()
            .appendingPathComponent("thumbnail_\(imageURL.lastPathComponent)")
        
        guard let tiffData = thumbnail.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            throw ImageManagerError.thumbnailGenerationFailed
        }
        
        try pngData.write(to: thumbnailURL)
        return thumbnailURL
    }
    
    private func resizeImage(_ image: NSImage, to size: CGSize) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: size),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}

// MARK: - Image Manager Error

enum ImageManagerError: Error {
    case invalidImage
    case thumbnailGenerationFailed
    case imageNotFound
}

// MARK: - Namespace

enum ImageManager {
    static var live: ImageManagerProtocol {
        get throws {
            try ImageManagerImpl.default()
        }
    }
    
    static var mock: ImageManagerProtocol {
        ImageManagerMock()
    }
}

// MARK: - Mock Implementation

struct ImageManagerMock: ImageManagerProtocol {
    func copyImage(from sourceURL: URL, to noteId: String) async throws -> String {
        print("🖼️ Mock: Copied image to note: \(noteId)")
        return "img_001.png"
    }
    
    func deleteImages(forNote noteId: String) async throws {
        print("🗑️ Mock: Deleted images for note: \(noteId)")
    }
    
    func getImageURL(noteId: String, imageId: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsURL
            .appendingPathComponent("NotaLibrary")
            .appendingPathComponent("attachments")
            .appendingPathComponent(noteId)
            .appendingPathComponent(imageId)
    }
}


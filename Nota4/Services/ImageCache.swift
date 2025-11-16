import Foundation
import AppKit

// MARK: - Image Cache

/// 图片缓存管理器
/// 用于缓存外部图片链接，提升加载速度
actor ImageCache {
    static let shared = ImageCache()
    
    private var memoryCache: [URL: NSImage] = [:]
    private let diskCacheDir: URL
    private let maxMemoryCacheSize = 50 // 最多缓存 50 张图片
    
    // MARK: - Initialization
    
    private init() {
        let cacheDir = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("Nota4/ImageCache")
        
        try? FileManager.default.createDirectory(
            at: cacheDir,
            withIntermediateDirectories: true
        )
        
        self.diskCacheDir = cacheDir
        
        print("📷 [IMAGE CACHE] Initialized at: \(cacheDir.path)")
    }
    
    // MARK: - Public Methods
    
    /// 获取图片（先查内存，再查磁盘，最后下载）
    func image(for url: URL) async throws -> NSImage {
        // 1. 检查内存缓存
        if let cached = memoryCache[url] {
            print("📷 [IMAGE] Memory cache hit: \(url.lastPathComponent)")
            return cached
        }
        
        // 2. 检查磁盘缓存
        let cacheKey = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? url.lastPathComponent
        let diskPath = diskCacheDir.appendingPathComponent(cacheKey)
        
        if FileManager.default.fileExists(atPath: diskPath.path),
           let image = NSImage(contentsOf: diskPath) {
            print("📷 [IMAGE] Disk cache hit: \(url.lastPathComponent)")
            // 存入内存缓存
            await cacheInMemory(url: url, image: image)
            return image
        }
        
        // 3. 下载图片
        print("📷 [IMAGE] Downloading: \(url.absoluteString)")
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = NSImage(data: data) else {
            throw ImageCacheError.invalidImageData
        }
        
        // 4. 缓存到内存和磁盘
        await cacheInMemory(url: url, image: image)
        try? data.write(to: diskPath)
        
        print("📷 [IMAGE] Downloaded and cached: \(url.lastPathComponent)")
        
        return image
    }
    
    /// 存入内存缓存
    private func cacheInMemory(url: URL, image: NSImage) async {
        // 如果缓存已满，移除最旧的（简单的 FIFO 策略）
        if memoryCache.count >= maxMemoryCacheSize {
            if let firstKey = memoryCache.keys.first {
                memoryCache.removeValue(forKey: firstKey)
            }
        }
        
        memoryCache[url] = image
    }
    
    /// 清空缓存
    func clearCache() async {
        memoryCache.removeAll()
        try? FileManager.default.removeItem(at: diskCacheDir)
        try? FileManager.default.createDirectory(
            at: diskCacheDir,
            withIntermediateDirectories: true
        )
        print("🧹 [IMAGE CACHE] Cache cleared")
    }
    
    /// 获取缓存大小
    func getCacheSize() async -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: diskCacheDir,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
}

// MARK: - Image Cache Error

enum ImageCacheError: LocalizedError {
    case invalidImageData
    case downloadFailed(URL)
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "无效的图片数据"
        case .downloadFailed(let url):
            return "图片下载失败: \(url.absoluteString)"
        }
    }
}


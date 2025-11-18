import Foundation

/// Bundle 资源访问辅助扩展
/// 提供安全的资源访问方式，支持 SPM 开发和打包后的应用
extension Bundle {
    /// 检查是否在打包后的应用中运行
    private static var isPackagedApp: Bool {
        // 检查 Bundle.main 的路径是否包含 .app
        let bundlePath = Bundle.main.bundlePath
        return bundlePath.hasSuffix(".app") || bundlePath.contains(".app/")
    }
    
    /// 安全地获取资源 URL
    /// - Parameters:
    ///   - name: 资源名称
    ///   - ext: 扩展名（可选）
    ///   - subdirectory: 子目录（可选）
    /// - Returns: 资源 URL，如果找不到则返回 nil
    static func safeResourceURL(
        name: String,
        withExtension ext: String? = nil,
        subdirectory: String? = nil
    ) -> URL? {
        // 在打包后的应用中，Bundle.module 会导致断言失败
        // 所以如果检测到是打包后的应用，只使用 Bundle.main
        if isPackagedApp {
            // 只从 Bundle.main 查找资源（打包后的应用）
            if let resourcePath = Bundle.main.resourcePath {
                var path = URL(fileURLWithPath: resourcePath)
                
                // 尝试在 Nota4_Nota4.bundle 中
                path = path.appendingPathComponent("Nota4_Nota4.bundle")
                if let subdirectory = subdirectory {
                    path = path.appendingPathComponent(subdirectory)
                }
                if let ext = ext {
                    path = path.appendingPathComponent("\(name).\(ext)")
                } else {
                    path = path.appendingPathComponent(name)
                }
                
                if FileManager.default.fileExists(atPath: path.path) {
                    return path
                }
                
                // 尝试直接路径（不在 bundle 中）
                path = URL(fileURLWithPath: resourcePath)
                if let subdirectory = subdirectory {
                    path = path.appendingPathComponent(subdirectory)
                }
                if let ext = ext {
                    path = path.appendingPathComponent("\(name).\(ext)")
                } else {
                    path = path.appendingPathComponent(name)
                }
                
                if FileManager.default.fileExists(atPath: path.path) {
                    return path
                }
            }
            return nil
        } else {
            // 在开发环境中，先尝试 Bundle.module（SPM）
            if let url = Bundle.module.url(
                forResource: name,
                withExtension: ext,
                subdirectory: subdirectory
            ) {
                return url
            }
            
            // 如果 Bundle.module 找不到，尝试 Bundle.main（作为降级）
            if let resourcePath = Bundle.main.resourcePath {
                var path = URL(fileURLWithPath: resourcePath)
                if let subdirectory = subdirectory {
                    path = path.appendingPathComponent(subdirectory)
                }
                if let ext = ext {
                    path = path.appendingPathComponent("\(name).\(ext)")
                } else {
                    path = path.appendingPathComponent(name)
                }
                
                if FileManager.default.fileExists(atPath: path.path) {
                    return path
                }
            }
            
            return nil
        }
    }
}


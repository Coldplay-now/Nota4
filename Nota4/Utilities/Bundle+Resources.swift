import Foundation

/// Bundle 资源访问辅助扩展
/// 提供安全的资源访问方式，支持 SPM 开发和打包后的应用
/// 
/// **安全策略**: 完全避免访问 `Bundle.module`，统一使用 `Bundle.main` 进行资源访问
/// 这样可以避免在打包后的应用中触发 `Bundle.module` 初始化失败导致的断言失败
extension Bundle {
    /// 检查是否在打包后的应用中运行
    private static var isPackagedApp: Bool {
        // 检查 Bundle.main 的路径是否包含 .app
        let bundlePath = Bundle.main.bundlePath
        return bundlePath.hasSuffix(".app") || bundlePath.contains(".app/")
    }
    
    /// 安全地获取资源 URL
    /// 
    /// **重要**: 此方法完全避免访问 `Bundle.module`，统一使用 `Bundle.main` 进行资源访问
    /// 这样可以避免在打包后的应用中触发 `Bundle.module` 初始化失败导致的断言失败
    /// 
    /// - Parameters:
    ///   - name: 资源名称
    ///   - ext: 扩展名（可选）
    ///   - subdirectory: 子目录（可选），如果包含 "Resources/" 前缀，会自动处理
    /// - Returns: 资源 URL，如果找不到则返回 nil
    static func safeResourceURL(
        name: String,
        withExtension ext: String? = nil,
        subdirectory: String? = nil
    ) -> URL? {
        guard let resourcePath = Bundle.main.resourcePath else {
            print("⚠️ [BUNDLE] Bundle.main.resourcePath is nil")
            return nil
        }
        
        // 处理 subdirectory：如果包含 "Resources/"，需要去掉这个前缀
        // 因为在打包后的应用中，资源直接在 bundle 根目录下
        var actualSubdirectory = subdirectory
        if let subdir = actualSubdirectory, subdir.hasPrefix("Resources/") {
            actualSubdirectory = String(subdir.dropFirst("Resources/".count))
        }
        
        // 尝试多个可能的路径（按优先级排序）
        let searchPaths: [URL] = {
            var paths: [URL] = []
            let basePath = URL(fileURLWithPath: resourcePath)
            
            // 路径 1: Nota4_Nota4.bundle/InitialDocuments/（打包后的应用）
            if isPackagedApp {
                var path = basePath.appendingPathComponent("Nota4_Nota4.bundle")
                if let actualSubdirectory = actualSubdirectory {
                    path = path.appendingPathComponent(actualSubdirectory)
                }
                paths.append(path)
            }
            
            // 路径 2: Resources/InitialDocuments/（开发环境，SPM 构建产物）
            var path = basePath
            if let actualSubdirectory = actualSubdirectory {
                path = path.appendingPathComponent(actualSubdirectory)
            }
            paths.append(path)
            
            // 路径 3: 保留原始 subdirectory（如果与处理后的不同）
            if let originalSubdirectory = subdirectory, originalSubdirectory != actualSubdirectory {
                path = basePath.appendingPathComponent(originalSubdirectory)
                paths.append(path)
            }
            
            return paths
        }()
        
        // 尝试每个路径
        for basePath in searchPaths {
            var path = basePath
            if let ext = ext {
                path = path.appendingPathComponent("\(name).\(ext)")
            } else {
                path = path.appendingPathComponent(name)
            }
            
            if FileManager.default.fileExists(atPath: path.path) {
                print("✅ [BUNDLE] 找到资源: \(path.path)")
                return path
            }
        }
        
        // 所有路径都找不到，记录日志
        let fileName = ext != nil ? "\(name).\(ext!)" : name
        let subdirStr = subdirectory ?? "根目录"
        print("⚠️ [BUNDLE] 找不到资源文件: \(fileName) (subdirectory: \(subdirStr))")
        print("   [BUNDLE] 已尝试的路径:")
        for (index, basePath) in searchPaths.enumerated() {
            let fullPath = basePath.appendingPathComponent(fileName)
            print("   [BUNDLE]   \(index + 1). \(fullPath.path)")
        }
        
        return nil
    }
}


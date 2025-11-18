import Foundation
import WebKit
import AppKit

// MARK: - PNG Generator

/// PNG 生成服务
/// 负责将 HTML 转换为 PNG 图片
actor PNGGenerator {
    
    // MARK: - Public Methods
    
    /// 从 HTML 生成 PNG
    func generateFromHTML(
        html: String,
        options: PNGExportOptions
    ) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    // 创建 WKWebView
                    let webView = WKWebView(frame: .init(x: 0, y: 0, width: Int(options.width), height: 1000))
                    
                    // 配置 WebView
                    let config = webView.configuration
                    config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
                    
                    // 设置背景色（如果有）
                    if let backgroundColor = options.backgroundColor {
                        webView.setValue(NSColor(hex: backgroundColor), forKey: "backgroundColor")
                    }
                    
                    // 加载 HTML
                    webView.loadHTMLString(html, baseURL: nil)
                    
                    // 等待页面加载完成（包括 Mermaid、KaTeX 等异步内容）
                    try await waitForPageLoad(webView)
                    
                    // 获取内容高度
                    let contentHeight = try await getContentHeight(webView)
                    
                    // 调整 WebView 高度
                    webView.frame = CGRect(x: 0, y: 0, width: Int(options.width), height: Int(contentHeight))
                    
                    // 等待布局完成
                    try await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
                    
                    // 生成 PNG
                    let pngData = try await generatePNG(from: webView, options: options)
                    
                    continuation.resume(returning: pngData)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 等待页面加载完成（包括异步内容）
    @MainActor
    private func waitForPageLoad(_ webView: WKWebView) async throws {
        // 等待初始加载完成
        try await waitForNavigation(webView)
        
        // 等待 Mermaid 图表渲染完成
        try await waitForMermaidRendering(webView)
        
        // 等待 KaTeX 公式渲染完成
        try await waitForKaTeXRendering(webView)
        
        // 额外等待时间，确保所有内容完全渲染
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
    }
    
    /// 等待导航完成
    @MainActor
    private func waitForNavigation(_ webView: WKWebView) async throws {
        var isLoaded = false
        
        let navigationDelegate = PNGNavigationDelegate { isLoaded = true }
        webView.navigationDelegate = navigationDelegate
        
        // 等待最多 5 秒
        let timeout: TimeInterval = 5.0
        let startTime = Date()
        
        while !isLoaded && Date().timeIntervalSince(startTime) < timeout {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
        }
        
        if !isLoaded {
            throw PNGGeneratorError.timeout
        }
    }
    
    /// 等待 Mermaid 图表渲染完成
    @MainActor
    private func waitForMermaidRendering(_ webView: WKWebView) async throws {
        let script = """
        (function() {
            const mermaidElements = document.querySelectorAll('.mermaid');
            if (mermaidElements.length === 0) {
                return true;
            }
            
            // 检查所有 Mermaid 图表是否已渲染
            for (let element of mermaidElements) {
                if (!element.querySelector('svg')) {
                    return false;
                }
            }
            return true;
        })();
        """
        
        let maxAttempts = 30 // 最多等待 3 秒（30 * 0.1秒）
        var attempts = 0
        
        while attempts < maxAttempts {
            let result = try await webView.evaluateJavaScript(script) as? Bool ?? false
            if result {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
            attempts += 1
        }
    }
    
    /// 等待 KaTeX 公式渲染完成
    @MainActor
    private func waitForKaTeXRendering(_ webView: WKWebView) async throws {
        let script = """
        (function() {
            const katexElements = document.querySelectorAll('.katex');
            if (katexElements.length === 0) {
                return true;
            }
            
            // 检查所有 KaTeX 元素是否已渲染
            for (let element of katexElements) {
                if (element.offsetHeight === 0 && element.offsetWidth === 0) {
                    return false;
                }
            }
            return true;
        })();
        """
        
        let maxAttempts = 20 // 最多等待 2 秒（20 * 0.1秒）
        var attempts = 0
        
        while attempts < maxAttempts {
            let result = try await webView.evaluateJavaScript(script) as? Bool ?? false
            if result {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
            attempts += 1
        }
    }
    
    /// 获取内容高度
    @MainActor
    private func getContentHeight(_ webView: WKWebView) async throws -> CGFloat {
        let script = """
        (function() {
            const body = document.body;
            const html = document.documentElement;
            return Math.max(
                body.scrollHeight, body.offsetHeight,
                html.clientHeight, html.scrollHeight, html.offsetHeight
            );
        })();
        """
        
        guard let height = try await webView.evaluateJavaScript(script) as? Double else {
            throw PNGGeneratorError.heightCalculationFailed
        }
        
        return CGFloat(height)
    }
    
    /// 生成 PNG
    @MainActor
    private func generatePNG(from webView: WKWebView, options: PNGExportOptions) async throws -> Data {
        // 使用 WKWebView 的 takeSnapshot 方法
        let configuration = WKSnapshotConfiguration()
        configuration.rect = webView.bounds
        
        // 支持 Retina 分辨率
        configuration.snapshotWidth = NSNumber(value: Int(options.width * 2)) // Retina
        
        return try await withCheckedThrowingContinuation { continuation in
            webView.takeSnapshot(with: configuration) { image, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let nsImage = image else {
                    continuation.resume(throwing: PNGGeneratorError.pngGenerationFailed)
                    return
                }
                
                // 转换为 PNG 数据
                guard let tiffData = nsImage.tiffRepresentation,
                      let bitmapImage = NSBitmapImageRep(data: tiffData),
                      let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
                    continuation.resume(throwing: PNGGeneratorError.pngGenerationFailed)
                    return
                }
                
                continuation.resume(returning: pngData)
            }
        }
    }
}

// MARK: - PNG Generator Error

enum PNGGeneratorError: LocalizedError {
    case timeout
    case heightCalculationFailed
    case pngGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .timeout:
            return "PNG 生成超时"
        case .heightCalculationFailed:
            return "无法计算内容高度"
        case .pngGenerationFailed:
            return "PNG 生成失败"
        }
    }
}

// MARK: - Navigation Delegate Helper

@MainActor
private class PNGNavigationDelegate: NSObject, WKNavigationDelegate {
    var onLoad: () -> Void
    
    init(onLoad: @escaping () -> Void) {
        self.onLoad = onLoad
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoad()
    }
}

// MARK: - NSColor Extension

extension NSColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}


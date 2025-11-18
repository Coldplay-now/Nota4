import Foundation
import WebKit
import AppKit
import PDFKit

// MARK: - PDF Generator

/// PDF 生成服务
/// 负责将 HTML 转换为 PDF 文档
actor PDFGenerator {
    
    // MARK: - Public Methods
    
    /// 从 HTML 生成 PDF
    func generateFromHTML(
        html: String,
        options: PDFExportOptions
    ) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    // 创建 WKWebView（初始高度设为较大值以容纳所有内容）
                    let webView = WKWebView(frame: .init(x: 0, y: 0, width: 800, height: 10000))
                    
                    // 配置 WebView
                    let config = webView.configuration
                    config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
                    
                    // 加载 HTML
                    webView.loadHTMLString(html, baseURL: nil)
                    
                    // 等待页面加载完成（包括 Mermaid、KaTeX 等异步内容）
                    try await waitForPageLoad(webView)
                    
                    // 获取内容的实际高度
                    let contentHeight = try await getContentHeight(webView)
                    
                    // 调整 webView 的 frame 以匹配内容高度
                    webView.frame = CGRect(x: 0, y: 0, width: 800, height: max(contentHeight, 1000))
                    
                    // 等待布局更新
                    try await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
                    
                    // 生成 PDF
                    let pdfData = try await generatePDF(from: webView, options: options)
                    
                    continuation.resume(returning: pdfData)
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
        
        let navigationDelegate = NavigationDelegate { isLoaded = true }
        webView.navigationDelegate = navigationDelegate
        
        // 等待最多 5 秒
        let timeout: TimeInterval = 5.0
        let startTime = Date()
        
        while !isLoaded && Date().timeIntervalSince(startTime) < timeout {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
        }
        
        if !isLoaded {
            throw PDFGeneratorError.timeout
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
            return Math.max(
                document.body.scrollHeight,
                document.body.offsetHeight,
                document.documentElement.clientHeight,
                document.documentElement.scrollHeight,
                document.documentElement.offsetHeight
            );
        })();
        """
        
        let height = try await webView.evaluateJavaScript(script) as? Double ?? 1000.0
        return CGFloat(height)
    }
    
    /// 生成 PDF
    @MainActor
    private func generatePDF(from webView: WKWebView, options: PDFExportOptions) async throws -> Data {
        // 使用 WKWebView 的 createPDF 方法
        let pdfConfiguration = WKPDFConfiguration()
        // 使用整个 webView 的 bounds，确保包含所有内容
        pdfConfiguration.rect = webView.bounds
        
        return try await withCheckedThrowingContinuation { continuation in
            webView.createPDF(configuration: pdfConfiguration) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Navigation Delegate Helper

@MainActor
private class NavigationDelegate: NSObject, WKNavigationDelegate {
    var onLoad: () -> Void
    
    init(onLoad: @escaping () -> Void) {
        self.onLoad = onLoad
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoad()
    }
}

// MARK: - PDF Generator Error

enum PDFGeneratorError: LocalizedError {
    case timeout
    case pdfGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .timeout:
            return "PDF 生成超时"
        case .pdfGenerationFailed:
            return "PDF 生成失败"
        }
    }
}


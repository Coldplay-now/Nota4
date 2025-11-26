import SwiftUI
import WebKit

// MARK: - WebView Wrapper

/// WKWebView 的 SwiftUI 包装器
/// 用于在 SwiftUI 中显示 HTML 内容
struct WebViewWrapper: NSViewRepresentable {
    let html: String
    let htmlFileURL: URL?  // 临时 HTML 文件 URL（用于 loadFileURL）
    let baseURL: URL?     // 笔记目录 URL（用于授予访问权限）
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // 优先使用 loadFileURL 方案（如果 htmlFileURL 和 baseURL 都存在）
        if let htmlFile = htmlFileURL, let baseURL = baseURL {
            // 检查文件是否存在
            if FileManager.default.fileExists(atPath: htmlFile.path) {
                // 检查是否已经加载过这个文件（避免重复加载）
                if context.coordinator.lastHTMLFileURL != htmlFile {
                    // 使用 loadFileURL 授予 Sandbox 权限
                    webView.loadFileURL(htmlFile, allowingReadAccessTo: baseURL)
                    context.coordinator.lastHTMLFileURL = htmlFile
                    context.coordinator.lastHTML = html  // 同时更新 lastHTML 以保持同步
                }
                return
            }
        }
        
        // 降级方案：使用 loadHTMLString（如果临时文件不存在或参数不完整）
        if context.coordinator.lastHTML != html {
            context.coordinator.lastHTML = html
            context.coordinator.lastHTMLFileURL = nil  // 清除文件 URL 跟踪
            webView.loadHTMLString(html, baseURL: baseURL)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var lastHTML: String = ""
        var lastHTMLFileURL: URL? = nil  // 跟踪临时 HTML 文件（用于避免重复加载）
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // 允许初始加载
            if navigationAction.navigationType == .other {
                decisionHandler(.allow)
                return
            }
            
            // 处理链接点击
            if let url = navigationAction.request.url {
                let urlString = url.absoluteString
                
                // 检查是否为内部锚点链接
                // 1. 以 # 开头（纯锚点）
                // 2. about:blank# 开头（WebView 中的锚点）
                // 3. 只有 fragment，没有有效 scheme
                let isInternalAnchor = urlString.hasPrefix("#") || 
                                      urlString.hasPrefix("about:blank#") ||
                                      (url.fragment != nil && (url.scheme == nil || url.scheme == "about" || url.scheme == "file"))
                
                // 如果是内部锚点链接，让 WebView 使用原生的锚点导航
                if isInternalAnchor {
                    decisionHandler(.allow)
                    return
                }
                
                // 外部链接（http/https）在外部浏览器打开
                if url.scheme == "http" || url.scheme == "https" {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
                }
            }
            
            // 其他情况允许导航
            decisionHandler(.allow)
        }
    }
}

// MARK: - Preview

#Preview {
    WebViewWrapper(
        html: """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body {
                    font-family: -apple-system;
                    padding: 2rem;
                }
                h1 {
                    color: #333;
                }
            </style>
        </head>
        <body>
            <h1>预览测试</h1>
            <p>这是一个简单的 HTML 预览。</p>
        </body>
        </html>
        """,
        htmlFileURL: nil,
        baseURL: nil
    )
    .frame(width: 600, height: 400)
}


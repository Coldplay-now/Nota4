import SwiftUI
import WebKit

// MARK: - WebView Wrapper

/// WKWebView 的 SwiftUI 包装器
/// 用于在 SwiftUI 中显示 HTML 内容
struct WebViewWrapper: NSViewRepresentable {
    let html: String
    let baseURL: URL?  // 新增参数，用于解析相对路径
    
    func makeNSView(context: Context) -> WKWebView {
        // 配置 WKWebView 允许本地文件访问
        let configuration = WKWebViewConfiguration()
        
        // 允许从文件 URL 访问本地文件
        // 这对于加载本地图片资源是必需的
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // 只在内容或 baseURL 变化时才更新
        if context.coordinator.lastHTML != html || 
           context.coordinator.lastBaseURL != baseURL {
            context.coordinator.lastHTML = html
            context.coordinator.lastBaseURL = baseURL
            
            // 关键修复：使用 loadFileURL 而不是 loadHTMLString
            // 这样可以正确授予 WebView 访问本地文件的 Sandbox 权限
            if let baseURL = baseURL {
                // 将临时 HTML 文件放在 noteDirectory 中
                // 这样 HTML 和图片在同一个目录结构下，避免跨目录访问问题
                let htmlFile = baseURL.appendingPathComponent(".preview_\(UUID().uuidString).html")
                
                do {
                    // 写入 HTML 到临时文件
                    try html.write(to: htmlFile, atomically: true, encoding: .utf8)
                    
                    // 使用 loadFileURL 加载，并授予访问整个 noteDirectory 的权限
                    // allowingReadAccessTo 必须是目录，不能是文件
                    webView.loadFileURL(htmlFile, allowingReadAccessTo: baseURL)
                    
                    // 清理之前的临时文件
                    if let oldFile = context.coordinator.lastTempFile {
                        try? FileManager.default.removeItem(at: oldFile)
                    }
                    context.coordinator.lastTempFile = htmlFile
                } catch {
                    print("❌ [WebView] 创建临时文件失败: \(error.localizedDescription)")
                    // 降级到 loadHTMLString
                    webView.loadHTMLString(html, baseURL: baseURL)
                }
            } else {
                // 无 baseURL，使用标准 loadHTMLString
                webView.loadHTMLString(html, baseURL: nil)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var lastHTML: String = ""
        var lastBaseURL: URL? = nil
        var lastTempFile: URL? = nil
        
        deinit {
            // 清理临时文件
            if let tempFile = lastTempFile {
                try? FileManager.default.removeItem(at: tempFile)
            }
        }
        
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
                
                // 如果是内部锚点链接，允许 WebView 自己处理
                // 修复：让 WebView 使用原生的锚点导航，而不是用 JavaScript 模拟
                // 这样更可靠，与 Safari 行为一致
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
        baseURL: nil
    )
    .frame(width: 600, height: 400)
}


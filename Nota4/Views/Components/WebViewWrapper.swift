import SwiftUI
import WebKit

// MARK: - WebView Wrapper

/// WKWebView 的 SwiftUI 包装器
/// 用于在 SwiftUI 中显示 HTML 内容
struct WebViewWrapper: NSViewRepresentable {
    let html: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // 只在内容变化时才更新
        if context.coordinator.lastHTML != html {
            context.coordinator.lastHTML = html
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var lastHTML: String = ""
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // 允许初始加载
            if navigationAction.navigationType == .other {
                decisionHandler(.allow)
                return
            }
            
            // 对于链接点击，在外部浏览器打开
            if let url = navigationAction.request.url {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
    }
}

// MARK: - Preview

#Preview {
    WebViewWrapper(html: """
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
    """)
    .frame(width: 600, height: 400)
}


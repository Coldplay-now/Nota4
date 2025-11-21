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
                
                // 如果是内部锚点链接，允许在 WebView 内导航
                if isInternalAnchor {
                    // 使用 JavaScript 处理锚点跳转，确保平滑滚动
                    if let fragment = url.fragment {
                        // 转义 fragment 中的特殊字符，防止 JavaScript 注入
                        let escapedFragment = fragment
                            .replacingOccurrences(of: "\\", with: "\\\\")
                            .replacingOccurrences(of: "'", with: "\\'")
                            .replacingOccurrences(of: "\"", with: "\\\"")
                        
                        let script = """
                        (function() {
                            const fragment = '\(escapedFragment)';
                            const element = document.getElementById(fragment);
                            
                            if (element) {
                                // 计算偏移量，确保标题不被工具栏遮挡
                                const offset = 20;
                                const elementPosition = element.getBoundingClientRect().top + window.pageYOffset;
                                const offsetPosition = elementPosition - offset;
                                
                                // 平滑滚动到目标位置
                                window.scrollTo({
                                    top: offsetPosition,
                                    behavior: 'smooth'
                                });
                                
                                // 更新 URL hash，但不触发导航
                                if (window.history && window.history.replaceState) {
                                    window.history.replaceState(null, null, '#' + fragment);
                                }
                                
                                // 高亮目标元素（可选，提供视觉反馈）
                                const originalBg = element.style.backgroundColor;
                                element.style.backgroundColor = 'rgba(0, 122, 255, 0.1)';
                                element.style.transition = 'background-color 0.3s';
                                
                                setTimeout(() => {
                                    element.style.backgroundColor = originalBg || '';
                                }, 2000);
                            } else {
                                // 元素不存在，记录警告（开发时有用）
                                console.warn('Anchor link target not found: #' + fragment);
                            }
                        })();
                        """
                        webView.evaluateJavaScript(script, completionHandler: { result, error in
                            if let error = error {
                                print("⚠️ [WebView] Failed to scroll to anchor: \(error.localizedDescription)")
                            }
                        })
                    }
                    // 取消导航，因为我们用 JavaScript 处理了
                    decisionHandler(.cancel)
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


import SwiftUI
import ComposableArchitecture

// MARK: - Markdown Preview

/// Markdown 预览组件
/// 使用 WKWebView 渲染 HTML 内容
struct MarkdownPreview: View {
    @Bindable var store: StoreOf<EditorFeature>
    
    var body: some View {
        ZStack {
                if store.preview.isRendering {
                    VStack {
                        ProgressView()
                        Text("渲染中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if let error = store.preview.renderError {
                    ErrorView(
                        error: error,
                        retry: {
                            store.send(.preview(.render))
                        }
                    )
                } else if store.preview.renderedHTML.isEmpty {
                    ContentUnavailableView(
                        "无预览内容",
                        systemImage: "doc.text",
                        description: Text("在编辑器中输入 Markdown 文本以查看预览")
                    )
                } else {
                    WebViewWrapper(
                        html: store.preview.renderedHTML,
                        htmlFileURL: store.preview.previewHTMLFileURL,
                        baseURL: store.noteDirectory
                    )
                }
            }
            .onAppear {
                store.send(.preview(.onAppear))
            }
            .onReceive(NotificationCenter.default.publisher(for: .themeDidChange)) { notification in
                if let theme = notification.object as? ThemeConfig {
                    store.send(.preview(.themeChanged(theme.id)))
                }
            }
    }
}

// MARK: - Error View

private struct ErrorView: View {
    let error: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("渲染失败")
                .font(.headline)
            
            Text(error)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("重试") {
                retry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    MarkdownPreview(
        store: Store(
            initialState: EditorFeature.State()
        ) {
            EditorFeature()
        }
    )
}

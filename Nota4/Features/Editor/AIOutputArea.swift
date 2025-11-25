import SwiftUI
import ComposableArchitecture

// MARK: - AI Output Area Component

struct AIOutputArea: View {
    @Bindable var store: StoreOf<EditorFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("生成内容")
                .font(.headline)
                .padding(.horizontal, 4)
            
            // 预览区域
            previewContent
        }
        .padding(16)  // 固定内边距
        .frame(width: 350, height: 400)  // 固定尺寸
    }
    
    // MARK: - Preview Content
    
    @ViewBuilder
    private var previewContent: some View {
        if store.aiEditor.showContentPreview {
            contentPreview
        } else {
            emptyPlaceholder
        }
    }
    
    // MARK: - Content Preview
    
    private var contentPreview: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    // 生成的内容
                    Text(store.aiEditor.generatedContent)
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)  // 允许选择文本
                        .id("content")
                    
                    // 生成中指示器
                    if store.aiEditor.isGenerating {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("正在生成...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(12)
            }
            .background(Color(nsColor: .textBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .accessibilityLabel("AI 生成内容预览")
            .accessibilityValue(store.aiEditor.isGenerating 
                ? "正在生成内容" 
                : "已生成 \(store.aiEditor.generatedContent.count) 个字符")
            .onChange(of: store.aiEditor.generatedContent) { oldValue, newValue in
                // 流式输出时自动滚动到底部
                if store.aiEditor.isGenerating {
                    withAnimation(.easeOut(duration: 0.1)) {
                        proxy.scrollTo("content", anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty Placeholder
    
    private var emptyPlaceholder: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary.opacity(0.5))
                Text("生成的内容将显示在这里")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
        .accessibilityLabel("AI 生成内容预览")
        .accessibilityValue("等待生成内容")
    }
}


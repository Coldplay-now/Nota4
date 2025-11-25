import SwiftUI
import ComposableArchitecture

// MARK: - AI Editor Dialog

struct AIEditorDialog: View {
    @Bindable var store: StoreOf<EditorFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("AI 编辑助手")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 使用分屏布局：左侧输入，右侧输出
            HSplitView {
                // 左侧：输入区域
                AIInputArea(store: store)
                
                Divider()
                
                // 右侧：输出区域
                AIOutputArea(store: store)
            }
            .frame(height: 400)
            
            // 错误消息和操作按钮
            VStack(spacing: 8) {
                // 错误消息
                if let errorMessage = store.aiEditor.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                }
                
                // 操作按钮
                HStack {
                    Button("取消") {
                        store.send(.dismissAIEditorDialog)
                    }
                    .keyboardShortcut(.escape)
                    
                    if store.aiEditor.showContentPreview && !store.aiEditor.generatedContent.isEmpty {
                        Button("清除") {
                            store.send(.aiEditorPromptChanged(""))
                        }
                    }
                    
                    Spacer()
                    
                    if store.aiEditor.showContentPreview && !store.aiEditor.generatedContent.isEmpty && !store.aiEditor.isGenerating {
                        Button("确认插入") {
                            store.send(.confirmInsertAIContent)
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("生成") {
                            store.send(.generateAIContent)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!store.aiEditor.isPromptValid || store.aiEditor.isGenerating)
                        .keyboardShortcut(.return, modifiers: .command)
                        .overlay(
                            Group {
                                if store.aiEditor.isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        )
                    }
                    
                    if store.aiEditor.errorMessage != nil {
                        Button("重试") {
                            store.send(.retryGenerateContent)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 800, height: 550)
    }
}


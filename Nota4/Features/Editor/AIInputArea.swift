import SwiftUI
import ComposableArchitecture

// MARK: - AI Input Area Component

struct AIInputArea: View {
    @Bindable var store: StoreOf<EditorFeature>
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标签
            Text("请输入您的需求")
                .font(.headline)
                .padding(.horizontal, 4)
            
            // 输入框（包含占位符）
            ZStack(alignment: .topLeading) {
                // 占位符
                if store.aiEditor.userPrompt.isEmpty {
                    Text("描述您希望 AI 生成的内容")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
                
                // 输入框
                TextEditor(text: Binding(
                    get: { store.aiEditor.userPrompt },
                    set: { store.send(.aiEditorPromptChanged($0)) }
                ))
                .font(.system(size: 14))
                .scrollContentBackground(.hidden)
                .frame(height: 150)  // 固定高度
                .focused($isInputFocused)
                .accessibilityLabel("AI 提示词输入框")
                .accessibilityHint("请输入您希望 AI 生成的内容，最多 500 字符")
                .accessibilityValue("\(store.aiEditor.characterCount) 字符")
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        store.aiEditor.characterCountColorState == .danger
                            ? Color.red.opacity(0.5)
                            : Color.secondary.opacity(0.3),
                        lineWidth: 1
                    )
                    .animation(.easeInOut(duration: 0.2), value: store.aiEditor.characterCountColorState)
            )
            .onAppear {
                // 对话框打开时自动获得焦点
                isInputFocused = true
            }
            
            // 字符计数
            if store.aiEditor.shouldShowCharacterCount {
                HStack {
                    Spacer()
                    Text("\(store.aiEditor.characterCount)/\(store.aiEditor.maxCharacters)")
                        .font(.caption)
                        .foregroundColor(characterCountColor)
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
                .transition(.opacity)
                .accessibilityLabel("字符计数")
                .accessibilityValue("\(store.aiEditor.characterCount) 个字符，最多 \(store.aiEditor.maxCharacters) 个字符")
            }
            
            // 上下文开关
            Toggle("包含当前笔记内容作为上下文", isOn: Binding(
                get: { store.aiEditor.includeContext },
                set: { store.send(.aiEditorIncludeContextChanged($0)) }
            ))
            .padding(.horizontal, 4)
            .accessibilityHint("开启后将当前笔记的前 1000 字符作为上下文发送给 AI")
            
            Spacer()
        }
        .padding(16)  // 固定内边距
        .frame(width: 350, height: 400)  // 固定尺寸
    }
    
    // MARK: - Helper
    
    /// 字符计数颜色（根据状态转换）
    private var characterCountColor: Color {
        switch store.aiEditor.characterCountColorState {
        case .danger:
            return .red
        case .warning:
            return .orange
        case .normal:
            return .secondary
        }
    }
}


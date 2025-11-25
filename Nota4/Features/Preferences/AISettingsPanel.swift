import SwiftUI
import ComposableArchitecture

// MARK: - AI Settings Panel

struct AISettingsPanel: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI 助手")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("配置 LLM API 和系统提示词")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Divider()
            
            // API 配置分组
            VStack(alignment: .leading, spacing: 12) {
                Text("API 配置")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 16) {
                    // API 端点
                    VStack(alignment: .leading, spacing: 4) {
                        Text("API 端点")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        TextField("API 端点", text: Binding(
                            get: { store.aiConfig.endpoint },
                            set: { store.send(.aiEndpointChanged($0)) }
                        ))
                        .textFieldStyle(.roundedBorder)
                        
                        Text("DeepSeek API 端点地址")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // API Key
                    VStack(alignment: .leading, spacing: 4) {
                        Text("API Key")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        SecureField("API Key", text: Binding(
                            get: { store.aiConfig.apiKey },
                            set: { store.send(.aiApiKeyChanged($0)) }
                        ))
                        .textFieldStyle(.roundedBorder)
                        
                        Text("请输入您的 DeepSeek API Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // 模型名称
                    VStack(alignment: .leading, spacing: 4) {
                        Text("模型名称")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        TextField("模型名称", text: Binding(
                            get: { store.aiConfig.model },
                            set: { store.send(.aiModelChanged($0)) }
                        ))
                        .textFieldStyle(.roundedBorder)
                        
                        Text("DeepSeek 模型名称")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            
            Divider()
            
            // 系统提示词分组
            VStack(alignment: .leading, spacing: 12) {
                Text("系统提示词")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    TextEditor(text: Binding(
                        get: { store.aiConfig.systemPrompt },
                        set: { store.send(.aiSystemPromptChanged($0)) }
                    ))
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    
                    Text("用于指导 AI 生成内容的系统提示词，可以自定义修改")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            
            Spacer(minLength: 24)
        }
    }
}


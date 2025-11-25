import Foundation

// MARK: - LLMService Protocol

@preconcurrency protocol LLMServiceProtocol {
    /// 生成内容（流式响应）
    /// - Returns: AsyncThrowingStream<String, Error>，每个元素是增量内容
    func generateContentStream(
        systemPrompt: String,
        userPrompt: String,
        context: String?,
        config: EditorPreferences.AIConfig
    ) -> AsyncThrowingStream<String, Error>
    
    /// 生成内容（非流式，用于兼容或测试）
    func generateContent(
        systemPrompt: String,
        userPrompt: String,
        context: String?,
        config: EditorPreferences.AIConfig
    ) async throws -> String
}

// MARK: - LLMService Error

enum LLMServiceError: LocalizedError, Equatable {
    case invalidEndpoint
    case missingApiKey
    case networkError(String)
    case invalidResponse
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "无效的 API 端点"
        case .missingApiKey:
            return "API Key 未配置"
        case .networkError(let message):
            return "网络错误: \(message)"
        case .invalidResponse:
            return "无效的 API 响应"
        case .decodingError(let message):
            return "响应解析错误: \(message)"
        }
    }
}

// MARK: - LLMService Implementation

actor LLMServiceImpl: LLMServiceProtocol {
    static let shared = LLMServiceImpl()
    
    private init() {}
    
    nonisolated func generateContentStream(
        systemPrompt: String,
        userPrompt: String,
        context: String?,
        config: EditorPreferences.AIConfig
    ) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    // 验证配置
                    guard !config.apiKey.isEmpty else {
                        continuation.finish(throwing: LLMServiceError.missingApiKey)
                        return
                    }
                    
                    guard let endpointURL = URL(string: config.endpoint) else {
                        continuation.finish(throwing: LLMServiceError.invalidEndpoint)
                        return
                    }
                    
                    // 构建消息
                    var messages: [[String: Any]] = [
                        ["role": "system", "content": systemPrompt]
                    ]
                    
                    // 添加上下文（如果需要）
                    if let context = context, !context.isEmpty {
                        messages.append([
                            "role": "user",
                            "content": "当前笔记内容：\n\(context)\n\n请根据以下需求处理：\(userPrompt)"
                        ])
                    } else {
                        messages.append(["role": "user", "content": userPrompt])
                    }
                    
                    // 构建请求体
                    let requestBody: [String: Any] = [
                        "model": config.model,
                        "messages": messages,
                        "stream": true
                    ]
                    
                    // 创建请求
                    var request = URLRequest(url: endpointURL)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
                    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                    
                    // 发送请求并处理流式响应
                    let (asyncBytes, _) = try await URLSession.shared.bytes(for: request)
                    
                    // 解析流式响应
                    for try await line in asyncBytes.lines {
                        if line.hasPrefix("data: ") {
                            let jsonString = String(line.dropFirst(6))
                            
                            // 检查结束标记
                            if jsonString == "[DONE]" {
                                continuation.finish()
                                break
                            }
                            
                            // 解析 JSON
                            if let data = jsonString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                               let choices = json["choices"] as? [[String: Any]],
                               let firstChoice = choices.first,
                               let delta = firstChoice["delta"] as? [String: Any],
                               let content = delta["content"] as? String {
                                continuation.yield(content)
                            }
                        }
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    func generateContent(
        systemPrompt: String,
        userPrompt: String,
        context: String?,
        config: EditorPreferences.AIConfig
    ) async throws -> String {
        // 使用流式方法，收集所有内容
        var fullContent = ""
        let stream = generateContentStream(
            systemPrompt: systemPrompt,
            userPrompt: userPrompt,
            context: context,
            config: config
        )
        
        for try await chunk in stream {
            fullContent += chunk
        }
        
        return fullContent
    }
}

// MARK: - LLMService Namespace

enum LLMService {
    static let shared: LLMServiceProtocol = LLMServiceImpl.shared
    static let mock: LLMServiceProtocol = LLMServiceMock()
}

// MARK: - Mock Implementation

@preconcurrency actor LLMServiceMock: LLMServiceProtocol {
    nonisolated func generateContentStream(
        systemPrompt: String,
        userPrompt: String,
        context: String?,
        config: EditorPreferences.AIConfig
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                // 模拟流式输出
                let mockContent = "# 测试内容\n\n这是 AI 生成的测试内容。\n\n- 列表项 1\n- 列表项 2"
                for char in mockContent {
                    continuation.yield(String(char))
                    try? await Task.sleep(nanoseconds: 10_000_000) // 10ms 延迟
                }
                continuation.finish()
            }
        }
    }
    
    nonisolated func generateContent(
        systemPrompt: String,
        userPrompt: String,
        context: String?,
        config: EditorPreferences.AIConfig
    ) async throws -> String {
        return "# 测试内容\n\n这是 AI 生成的测试内容。"
    }
}


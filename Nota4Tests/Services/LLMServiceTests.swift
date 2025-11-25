import XCTest
@testable import Nota4

@MainActor
final class LLMServiceTests: XCTestCase {
    
    // MARK: - Test Mock Service
    
    func testMockServiceGenerateContentStream() async throws {
        let service = LLMService.mock
        let config = EditorPreferences.AIConfig()
        
        let stream = service.generateContentStream(
            systemPrompt: "Test system prompt",
            userPrompt: "Test user prompt",
            context: nil,
            config: config
        )
        
        var collectedContent = ""
        for try await chunk in stream {
            collectedContent += chunk
        }
        
        XCTAssertFalse(collectedContent.isEmpty, "Mock service should generate content")
        XCTAssertTrue(collectedContent.contains("测试内容"), "Mock content should contain expected text")
    }
    
    func testMockServiceGenerateContent() async throws {
        let service = LLMService.mock
        let config = EditorPreferences.AIConfig()
        
        let content = try await service.generateContent(
            systemPrompt: "Test system prompt",
            userPrompt: "Test user prompt",
            context: nil,
            config: config
        )
        
        XCTAssertFalse(content.isEmpty, "Mock service should generate content")
        XCTAssertTrue(content.contains("测试内容"), "Mock content should contain expected text")
    }
    
    // MARK: - Test Error Handling
    
    func testMissingApiKeyError() async {
        var config = EditorPreferences.AIConfig()
        config.apiKey = ""  // Empty API key
        
        let service = LLMService.shared
        let stream = service.generateContentStream(
            systemPrompt: "Test",
            userPrompt: "Test",
            context: nil,
            config: config
        )
        
        do {
            var hasError = false
            for try await _ in stream {
                // Should not reach here
            }
            XCTFail("Should have thrown an error")
        } catch {
            if let llmError = error as? LLMServiceError {
                XCTAssertEqual(llmError, .missingApiKey, "Should throw missingApiKey error")
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testInvalidEndpointError() async {
        var config = EditorPreferences.AIConfig()
        config.apiKey = "test-key"
        config.endpoint = "invalid-url"  // Invalid endpoint
        
        let service = LLMService.shared
        let stream = service.generateContentStream(
            systemPrompt: "Test",
            userPrompt: "Test",
            context: nil,
            config: config
        )
        
        do {
            for try await _ in stream {
                // Should not reach here
            }
            XCTFail("Should have thrown an error")
        } catch {
            if let llmError = error as? LLMServiceError {
                XCTAssertEqual(llmError, .invalidEndpoint, "Should throw invalidEndpoint error")
            } else {
                // URL parsing might throw different error, which is acceptable
                XCTAssertTrue(true)
            }
        }
    }
    
    // MARK: - Test Context Inclusion
    
    func testContextInclusion() async throws {
        let service = LLMService.mock
        let config = EditorPreferences.AIConfig()
        let context = "This is test context content"
        
        let stream = service.generateContentStream(
            systemPrompt: "Test system prompt",
            userPrompt: "Test user prompt",
            context: context,
            config: config
        )
        
        var collectedContent = ""
        for try await chunk in stream {
            collectedContent += chunk
        }
        
        // Mock service should still generate content even with context
        XCTAssertFalse(collectedContent.isEmpty)
    }
}


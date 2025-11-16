import SwiftUI

extension String {
    /// 为搜索关键词添加高亮
    /// - Parameter keywords: 要高亮的关键词数组
    /// - Returns: 带高亮的 AttributedString
    func highlightingOccurrences(of keywords: [String]) -> AttributedString {
        guard !keywords.isEmpty else {
            return AttributedString(self)
        }
        
        var attributedString = AttributedString(self)
        let lowercaseText = self.lowercased()
        
        for keyword in keywords where !keyword.isEmpty {
            let lowercaseKeyword = keyword.lowercased()
            var searchRange = lowercaseText.startIndex..<lowercaseText.endIndex
            
            while let range = lowercaseText.range(of: lowercaseKeyword, range: searchRange) {
                // 转换为 AttributedString 的范围
                if let attributedRange = Range(range, in: attributedString) {
                    // 设置高亮样式
                    attributedString[attributedRange].backgroundColor = .yellow.opacity(0.4)
                    attributedString[attributedRange].foregroundColor = .primary
                }
                
                // 移动搜索范围
                searchRange = range.upperBound..<lowercaseText.endIndex
                if searchRange.isEmpty { break }
            }
        }
        
        return attributedString
    }
}


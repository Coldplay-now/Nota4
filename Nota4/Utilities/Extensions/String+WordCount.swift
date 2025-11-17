import Foundation

// MARK: - String Word Count Extension

extension String {
    /// 统计字数（中文字符数 + 英文单词数）
    var wordCount: Int {
        // 统计中文字符（CJK统一表意文字）
        let chineseCharacters = self.filter { character in
            guard let scalar = character.unicodeScalars.first else { return false }
            let value = scalar.value
            // CJK 统一表意文字范围：0x4E00-0x9FFF
            // CJK 扩展 A: 0x3400-0x4DBF
            // CJK 扩展 B-F: 0x20000-0x2EBF0
            return (value >= 0x4E00 && value <= 0x9FFF) ||
                   (value >= 0x3400 && value <= 0x4DBF) ||
                   (value >= 0x20000 && value <= 0x2EBF0)
        }.count
        
        // 统计英文单词数
        let words = self.components(separatedBy: .whitespacesAndNewlines)
            .filter { word in
                !word.isEmpty && word.rangeOfCharacter(from: .letters) != nil
            }
        let englishWords = words.count
        
        return chineseCharacters + englishWords
    }
    
    /// 统计行数
    var lineCount: Int {
        if self.isEmpty {
            return 0
        }
        return self.components(separatedBy: .newlines).count
    }
}


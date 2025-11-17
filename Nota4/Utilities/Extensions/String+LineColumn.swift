import Foundation

// MARK: - String Line & Column Extension

extension String {
    /// 从字符位置计算行号和列号（基于1的索引）
    /// - Parameter position: 字符串中的位置（从0开始）
    /// - Returns: (行号, 列号)，从1开始计数
    func lineAndColumn(at position: Int) -> (line: Int, column: Int) {
        // 如果位置无效，返回 (1, 1)
        guard position >= 0 && position <= self.count else {
            return (1, 1)
        }
        
        // 如果字符串为空或位置为0，返回 (1, 1)
        if self.isEmpty || position == 0 {
            return (1, 1)
        }
        
        var currentLine = 1
        var currentColumn = 1
        var currentPosition = 0
        
        for character in self {
            if currentPosition == position {
                break
            }
            
            if character == "\n" {
                currentLine += 1
                currentColumn = 1
            } else {
                currentColumn += 1
            }
            
            currentPosition += 1
        }
        
        return (currentLine, currentColumn)
    }
}


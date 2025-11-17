import Foundation

// MARK: - Date Time Ago Extension

extension Date {
    /// 返回相对时间字符串（刚刚、X分钟前、X小时前等）
    var timeAgoString: String {
        let interval = Date().timeIntervalSince(self)
        
        // 刚刚（60秒内）
        if interval < 60 {
            return "刚刚"
        }
        
        // X分钟前（60分钟内）
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) 分钟前"
        }
        
        // X小时前（24小时内）
        if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) 小时前"
        }
        
        // X天前（7天内）
        if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days) 天前"
        }
        
        // 超过7天，显示日期
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}


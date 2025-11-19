import SwiftUI

// MARK: - Column Width Preference Key

/// PreferenceKey 用于监听侧边栏和列表的实际宽度
struct ColumnWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


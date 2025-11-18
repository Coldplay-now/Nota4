import SwiftUI

/// 标签组件
/// 用于显示标签，支持删除操作
struct TagChip: View {
    let tag: String
    var showDelete: Bool = false
    var onRemove: (() -> Void)? = nil
    var onClick: (() -> Void)? = nil
    var disableTapGesture: Bool = false  // 禁用点击手势（用于在Button中使用时）
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption2)
                .foregroundStyle(Color(nsColor: .labelColor))
            
            if showDelete, let onRemove = onRemove {
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("删除标签")
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.accentColor.opacity(0.2))
        .cornerRadius(4)
        .contentShape(Rectangle())  // 确保整个区域可点击
        .modifier(TapGestureModifier(disableTapGesture: disableTapGesture, onClick: onClick))
    }
}

// 辅助修饰符，用于条件应用点击手势
struct TapGestureModifier: ViewModifier {
    let disableTapGesture: Bool
    let onClick: (() -> Void)?
    
    func body(content: Content) -> some View {
        if !disableTapGesture, let onClick = onClick {
            content.onTapGesture {
                onClick()
            }
        } else {
            content
        }
    }
}

#Preview {
    HStack {
        TagChip(tag: "工作")
        TagChip(tag: "学习", showDelete: true, onRemove: {})
        TagChip(tag: "重要", onClick: { print("Clicked") })
    }
    .padding()
}


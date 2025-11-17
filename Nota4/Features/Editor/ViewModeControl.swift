import SwiftUI
import ComposableArchitecture

// MARK: - 视图模式切换控件

/// 紧凑的视图模式切换组件
/// 使用 Toggle 按钮在编辑和预览模式之间切换
struct ViewModeControl: View {
    let store: StoreOf<EditorFeature>
    @State private var isHovered = false
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                // 立即更新状态，不等待预览渲染
                let newMode: EditorFeature.State.ViewMode = store.viewMode == .editOnly ? .previewOnly : .editOnly
                store.send(.viewModeChanged(newMode))
            } label: {
                // 图标表示"点击后会切换到什么模式"
                // 编辑模式下显示眼睛（切换到预览），预览模式下显示笔（切换到编辑）
                Image(systemName: store.viewMode == .editOnly ? "eye" : "pencil")
                    .font(.system(size: 14))
                    .frame(width: 32, height: 28)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color(nsColor: .controlAccentColor).opacity(0.15) : Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )
            .foregroundColor(Color.primary)
            .contentShape(Rectangle())  // 确保整个区域可点击
            .help(store.viewMode == .editOnly ? "切换到预览模式" : "切换到编辑模式")
            .onHover { hovering in
                isHovered = hovering
            }
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
    }
}


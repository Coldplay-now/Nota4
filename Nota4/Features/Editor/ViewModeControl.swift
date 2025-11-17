import SwiftUI
import ComposableArchitecture

// MARK: - 视图模式切换控件

/// 紧凑的视图模式切换组件
/// 使用 Toggle 按钮在编辑和预览模式之间切换
struct ViewModeControl: View {
    let store: StoreOf<EditorFeature>
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                // 在编辑和预览之间切换
                let newMode: EditorFeature.State.ViewMode = store.viewMode == .editOnly ? .previewOnly : .editOnly
                store.send(.viewModeChanged(newMode))
            } label: {
                Image(systemName: store.viewMode == .editOnly ? "pencil" : "eye")
                    .font(.system(size: 14))
                    .frame(width: 32, height: 28)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )
            .foregroundColor(Color.primary)
            .help(store.viewMode == .editOnly ? "切换到预览模式" : "切换到编辑模式")
        }
    }
}


import SwiftUI
import ComposableArchitecture

// MARK: - 视图模式切换控件

/// 紧凑的视图模式切换组件
/// 使用 Toggle 按钮在编辑和预览模式之间切换
struct ViewModeControl: View {
    let store: StoreOf<EditorFeature>
    @State private var isHovered = false
    
    // 计算属性：根据当前模式计算下一个模式
    // 避免在按钮点击时读取旧状态
    private var nextMode: EditorFeature.State.ViewMode {
        store.viewMode == .editOnly ? .previewOnly : .editOnly
    }
    
    var body: some View {
        WithPerceptionTracking {
            Button {
                // 如果正在渲染，不处理点击（防止重复点击）
                guard !store.preview.isRendering else { return }
                
                // 使用计算属性，避免读取旧状态
                store.send(.viewModeChanged(nextMode))
            } label: {
                // 使用 ZStack 将背景、边框和图标都放在 label 内部
                // 这样可以确保整个 44x44 区域都可以点击
                ZStack {
                    // 背景
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovered ? Color(nsColor: .controlAccentColor).opacity(0.15) : Color(nsColor: .controlBackgroundColor))
                    
                    // 边框
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                    
                    // 图标表示"点击后会切换到什么模式"
                    // 编辑模式下显示眼睛（切换到预览），预览模式下显示笔（切换到编辑）
                    Image(systemName: store.viewMode == .editOnly ? "eye" : "pencil")
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)  // 图标本身的大小
                }
                .frame(width: 44, height: 44)  // 固定 44x44 点击区域（macOS 推荐）
            }
            .buttonStyle(.plain)
            .disabled(store.preview.isRendering)  // 从 Store 读取状态，符合 TCA 原则
            .foregroundColor(Color.primary)
            .contentShape(Rectangle())  // 确保整个区域可点击，必须在所有修饰符之后
            .help(store.viewMode == .editOnly ? "切换到预览模式" : "切换到编辑模式")
            .onHover { hovering in
                isHovered = hovering
            }
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
    }
}


import SwiftUI
import ComposableArchitecture

/// 可展开的搜索框组件
/// 在工具栏下方展开显示
struct ExpandableSearchField: View {
    let store: StoreOf<NoteListFeature>
    @FocusState private var isFocused: Bool
    @State private var isClearButtonHovered = false
    
    var body: some View {
        HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
                
                TextField("搜索笔记...", text: Binding(
                    get: { store.searchText },
                    set: { store.send(.binding(.set(\.searchText, $0))) }
                ))
                .textFieldStyle(.plain)
                .focused($isFocused)
                
                if !store.searchText.isEmpty {
                    Button {
                        store.send(.binding(.set(\.searchText, "")))
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                    .background(
                        Circle()
                            .fill(isClearButtonHovered ? Color(nsColor: .controlAccentColor).opacity(0.15) : Color.clear)
                            .frame(width: 20, height: 20)
                    )
                    .contentShape(Circle())
                    .onHover { hovering in
                        isClearButtonHovered = hovering
                    }
                    .animation(.easeInOut(duration: 0.15), value: isClearButtonHovered)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(nsColor: .separatorColor)),
                alignment: .bottom
            )
            .onAppear {
                // 展开时自动聚焦
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            }
    }
}


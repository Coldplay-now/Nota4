import SwiftUI
import ComposableArchitecture

/// 可展开的搜索框组件
/// 在工具栏下方展开显示
struct ExpandableSearchField: View {
    let store: StoreOf<NoteListFeature>
    @FocusState private var isFocused: Bool
    
    var body: some View {
        WithPerceptionTracking {
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
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
}


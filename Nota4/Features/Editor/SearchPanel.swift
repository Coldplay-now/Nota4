import SwiftUI
import ComposableArchitecture

// MARK: - 搜索面板组件

/// 编辑区搜索替换面板
/// 提供搜索、替换、导航等功能
struct SearchPanel: View {
    @Bindable var store: StoreOf<EditorFeature>
    @FocusState private var isSearchFieldFocused: Bool
    @FocusState private var isReplaceFieldFocused: Bool
    @State private var isReplaceButtonHovered = false
    @State private var isReplaceAllButtonHovered = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
                // 搜索框
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                    
                    TextField("搜索...", text: Binding(
                        get: { store.search.searchText },
                        set: { store.send(.search(.searchTextChanged($0))) }
                    ))
                    .textFieldStyle(.plain)
                    .focused($isSearchFieldFocused)
                    .onSubmit {
                        store.send(.search(.findNext))
                    }
                    
                    if !store.search.searchText.isEmpty && store.search.hasMatches {
                        // 显示匹配数量
                        Text("\(store.search.currentMatchIndex + 1)/\(store.search.matchCount)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: 200)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .textBackgroundColor))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                        )
                )
                
                // 替换模式切换按钮
                Button {
                    store.send(.search(.toggleReplaceMode))
                } label: {
                    Image(systemName: store.search.isReplaceMode ? "arrow.left.arrow.right.circle.fill" : "arrow.left.arrow.right")
                        .font(.system(size: 12))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .help(store.search.isReplaceMode ? "关闭替换模式" : "开启替换模式")
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(store.search.isReplaceMode ? Color.accentColor.opacity(0.15) : Color.clear)
                )
                .foregroundColor(store.search.isReplaceMode ? .accentColor : .primary)
                
                // 替换框（条件显示）
                if store.search.isReplaceMode {
                    TextField("替换为...", text: Binding(
                        get: { store.search.replaceText },
                        set: { store.send(.search(.replaceTextChanged($0))) }
                    ))
                    .textFieldStyle(.plain)
                    .focused($isReplaceFieldFocused)
                    .frame(maxWidth: 120)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(nsColor: .textBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                            )
                    )
                }
                
                // 导航按钮
                Button {
                    store.send(.search(.findPrevious))
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .disabled(!store.search.hasMatches)
                .help("上一个 (⌘⇧G)")
                
                Button {
                    store.send(.search(.findNext))
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .disabled(!store.search.hasMatches)
                .help("下一个 (⌘G)")
                
                // 替换按钮（仅在替换模式显示）
                if store.search.isReplaceMode {
                    Button {
                        store.send(.search(.replaceCurrent))
                    } label: {
                        Text("替换")
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.search.hasMatches || store.search.replaceText.isEmpty)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isReplaceButtonHovered && store.search.hasMatches && !store.search.replaceText.isEmpty ? Color(nsColor: .controlAccentColor).opacity(0.2) : Color(nsColor: .controlAccentColor).opacity(0.15))
                    )
                    .foregroundColor(.primary)
                    .onHover { hovering in
                        isReplaceButtonHovered = hovering
                    }
                    .animation(.easeInOut(duration: 0.15), value: isReplaceButtonHovered)
                    
                    Button {
                        store.send(.search(.replaceAll))
                    } label: {
                        Text("全部替换")
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.search.hasMatches || store.search.replaceText.isEmpty)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isReplaceAllButtonHovered && store.search.hasMatches && !store.search.replaceText.isEmpty ? Color(nsColor: .controlAccentColor).opacity(0.2) : Color(nsColor: .controlAccentColor).opacity(0.15))
                    )
                    .foregroundColor(.primary)
                    .onHover { hovering in
                        isReplaceAllButtonHovered = hovering
                    }
                    .animation(.easeInOut(duration: 0.15), value: isReplaceAllButtonHovered)
                }
                
                // 关闭按钮
                Button {
                    store.send(.search(.hideSearchPanel))
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .help("关闭 (ESC)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)  // 占据可用宽度，内容左对齐
            .padding(.horizontal, 16)  // 与工具栏的 padding 一致，确保左对齐
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(nsColor: .separatorColor)),
                alignment: .bottom
            )
            .onAppear {
                // 面板显示时自动聚焦搜索框
                isSearchFieldFocused = true
            }
    }
}


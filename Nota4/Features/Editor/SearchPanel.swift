import SwiftUI
import ComposableArchitecture

// MARK: - 搜索面板组件

/// 编辑区搜索替换面板
/// 提供搜索、替换、导航等功能
struct SearchPanel: View {
    @Bindable var store: StoreOf<EditorFeature>
    @FocusState private var isSearchFieldFocused: Bool
    @FocusState private var isReplaceFieldFocused: Bool
    
    var body: some View {
        WithPerceptionTracking {
            HStack(spacing: 12) {
                // 搜索框
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                    
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
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
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
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .help(store.search.isReplaceMode ? "关闭替换" : "开启替换")
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
                    .frame(width: 150)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(nsColor: .textBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                            )
                    )
                }
                
                // 选项菜单
                Menu {
                    Toggle("区分大小写", isOn: Binding(
                        get: { store.search.matchCase },
                        set: { _ in store.send(.search(.matchCaseToggled)) }
                    ))
                    
                    Toggle("全词匹配", isOn: Binding(
                        get: { store.search.wholeWords },
                        set: { _ in store.send(.search(.wholeWordsToggled)) }
                    ))
                    
                    Toggle("正则表达式", isOn: Binding(
                        get: { store.search.useRegex },
                        set: { _ in store.send(.search(.useRegexToggled)) }
                    ))
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .help("搜索选项")
                
                // 导航按钮
                Button {
                    store.send(.search(.findPrevious))
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .disabled(!store.search.hasMatches)
                .help("上一个 (⌘⇧G)")
                
                Button {
                    store.send(.search(.findNext))
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)
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
                            .font(.system(size: 12))
                            .frame(width: 50, height: 28)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!store.search.hasMatches || store.search.replaceText.isEmpty)
                    
                    Button {
                        store.send(.search(.replaceAll))
                    } label: {
                        Text("全部替换")
                            .font(.system(size: 12))
                            .frame(width: 70, height: 28)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!store.search.hasMatches || store.search.replaceText.isEmpty)
                }
                
                // 关闭按钮
                Button {
                    store.send(.search(.hideSearchPanel))
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .help("关闭 (ESC)")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
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
}


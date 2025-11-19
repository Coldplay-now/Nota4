import SwiftUI
import ComposableArchitecture
import AppKit

struct SidebarView: View {
    let store: StoreOf<SidebarFeature>
    @State private var hoveredTag: String? = nil
    @State private var hoveredAllTags: Bool = false
    @State private var hoveredNoTags: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // 分类部分：固定位置，不滚动
                VStack(spacing: 0) {
                    // 分类标题
                    HStack {
                        Text("分类")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    
                    // 分类列表：固定高度，禁用滚动
                    List(selection: Binding(
                        get: { store.selectedCategory },
                        set: { store.send(.categorySelected($0)) }
                    )) {
                        ForEach(SidebarFeature.State.Category.allCases) { category in
                            let count = store.categoryCounts[category] ?? 0
                            
                            HStack {
                                Label {
                                    Text(category.rawValue)
                                } icon: {
                                    Image(systemName: category.icon)
                                }
                                Spacer()
                                Text("\(count)")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                            .tag(category)
                        }
                    }
                    .listStyle(.sidebar)
                    .scrollDisabled(true) // 禁用滚动
                    .frame(height: CGFloat(SidebarFeature.State.Category.allCases.count) * 32 + 40) // 固定高度：每个分类项32pt，额外内边距40pt
                }
                
                Divider()
                
                // 标签部分：可滚动，占用剩余空间
                VStack(spacing: 0) {
                    // 标签标题
                    HStack(spacing: 4) {
                        Text("标签")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Button {
                            store.send(.toggleTagsSection)
                        } label: {
                            Image(systemName: store.isTagsSectionExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    
                    // 标签列表：可滚动，占用剩余空间
                    if store.isTagsSectionExpanded {
                        ScrollView {
                            VStack(spacing: 4) {
                                // 全部标签选项
                                HStack {
                                    Label {
                                        Text("全部标签")
                                    } icon: {
                                        Image(systemName: "tag.fill")
                                    }
                                    Spacer()
                                    if store.selectedTags.isEmpty && !store.isNoTagsSelected {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                            .font(.caption)
                                    }
                                }
                                .contentShape(Rectangle())
                                .background(
                                    Group {
                                        if store.selectedTags.isEmpty && !store.isNoTagsSelected {
                                            Color.accentColor.opacity(0.15)
                                        } else if hoveredAllTags {
                                            Color.accentColor.opacity(0.08)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                                .cornerRadius(4)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .onTapGesture {
                                    store.send(.allTagsSelected)
                                }
                                .onHover { isHovering in
                                    hoveredAllTags = isHovering
                                }
                                
                                // 无标签选项
                                HStack {
                                    Label {
                                        Text("无标签")
                                    } icon: {
                                        Image(systemName: "tag.slash")
                                    }
                                    Spacer()
                                    if store.isNoTagsSelected {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                            .font(.caption)
                                    }
                                }
                                .contentShape(Rectangle())
                                .background(
                                    Group {
                                        if store.isNoTagsSelected {
                                            Color.accentColor.opacity(0.15)
                                        } else if hoveredNoTags {
                                            Color.accentColor.opacity(0.08)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                                .cornerRadius(4)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .onTapGesture {
                                    store.send(.noTagsSelected)
                                }
                                .onHover { isHovering in
                                    hoveredNoTags = isHovering
                                }
                                
                                // 标签列表
                                if !store.tags.isEmpty {
                                    ForEach(store.tags) { tag in
                                        let isSelected = store.selectedTags.contains(tag.name)
                                        let isHovered = hoveredTag == tag.name
                                        
                                        HStack(spacing: 0) {
                                            Label {
                                                Text(tag.name)
                                            } icon: {
                                                Image(systemName: "tag")
                                            }
                                            Spacer(minLength: 2)
                                            HStack(spacing: 4) {
                                                Text("\(tag.count)")
                                                    .foregroundColor(.secondary)
                                                    .font(.subheadline)
                                                    .frame(width: 30, alignment: .trailing)
                                                if isSelected {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.accentColor)
                                                        .font(.caption)
                                                }
                                            }
                                            .padding(.trailing, 12)
                                        }
                                        .contentShape(Rectangle())
                                        .background(
                                            Group {
                                                if isSelected {
                                                    Color.accentColor.opacity(0.15)
                                                } else if isHovered {
                                                    Color.accentColor.opacity(0.08)
                                                } else {
                                                    Color.clear
                                                }
                                            }
                                        )
                                        .cornerRadius(4)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .onTapGesture {
                                            // 检测是否按下了 Shift 键
                                            let isShiftPressed = NSEvent.modifierFlags.contains(.shift)
                                            if isShiftPressed {
                                                // Shift + 点击：复选（切换选中状态）
                                                store.send(.tagToggled(tag.name))
                                            } else {
                                                // 普通点击：单选（只选中当前标签）
                                                store.send(.tagSelected(tag.name))
                                            }
                                        }
                                        .onHover { isHovering in
                                            hoveredTag = isHovering ? tag.name : nil
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 占用剩余空间
            }
            .onAppear {
                store.send(.loadTags)
                store.send(.loadCounts)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SidebarView(
            store: Store(initialState: SidebarFeature.State()) {
                SidebarFeature()
            }
        )
    }
}







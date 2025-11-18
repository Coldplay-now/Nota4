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
            List(selection: Binding(
                get: { store.selectedCategory },
                set: { store.send(.categorySelected($0)) }
            )) {
                // 分类
                Section("分类") {
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
                
                // 标签
                Section("标签") {
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
                            
                            HStack {
                                Label {
                                    Text(tag.name)
                                } icon: {
                                    Image(systemName: "tag")
                                }
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("\(tag.count)")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                    if isSelected {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                            .font(.caption)
                                    }
                                }
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
            }
            .listStyle(.sidebar)
            .navigationTitle("Nota4")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        // 新建笔记
                    } label: {
                        Label("新建", systemImage: "plus")
                    }
                }
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







import SwiftUI
import ComposableArchitecture

struct SidebarView: View {
    let store: StoreOf<SidebarFeature>
    
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
                if !store.tags.isEmpty {
                    Section("标签") {
                        ForEach(store.tags) { tag in
                            Label {
                                Text(tag.name)
                            } icon: {
                                Image(systemName: "tag")
                            }
                            .badge(tag.count)
                            .onTapGesture {
                                store.send(.tagToggled(tag.name))
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







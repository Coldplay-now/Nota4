import SwiftUI
import ComposableArchitecture

/// 标签编辑面板
/// 提供标签的添加、删除和管理功能
struct TagEditPanel: View {
    @Bindable var store: StoreOf<EditorFeature>
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题栏
            HStack {
                Text("管理标签")
                    .font(.headline)
                Spacer()
                Button {
                    store.send(.tagEdit(.hideTagEditPanel))
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // 当前标签区域
            VStack(alignment: .leading, spacing: 8) {
                Text("当前标签：")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if store.tagEdit.currentTags.isEmpty {
                    Text("暂无标签")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    FlowLayout(spacing: 6) {
                        ForEach(Array(store.tagEdit.currentTags.sorted()), id: \.self) { tag in
                            TagChip(
                                tag: tag,
                                showDelete: true,
                                onRemove: {
                                    store.send(.tagEdit(.removeTag(tag)))
                                }
                            )
                        }
                    }
                }
            }
            
            Divider()
            
            // 添加标签区域
            VStack(alignment: .leading, spacing: 8) {
                Text("添加标签：")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("输入标签名称", text: Binding(
                        get: { store.tagEdit.newTagInput },
                        set: { store.send(.tagEdit(.newTagInputChanged($0))) }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .focused($isInputFocused)
                    .onSubmit {
                        if !store.tagEdit.newTagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            store.send(.tagEdit(.addTag(store.tagEdit.newTagInput)))
                        }
                    }
                    
                    Button("添加") {
                        if !store.tagEdit.newTagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            store.send(.tagEdit(.addTag(store.tagEdit.newTagInput)))
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(store.tagEdit.newTagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            
            // 建议标签区域
            if !store.tagEdit.filteredSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("建议标签：")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 6) {
                        ForEach(store.tagEdit.filteredSuggestions.prefix(10), id: \.self) { tag in
                            Button {
                                store.send(.tagEdit(.addTag(tag)))
                            } label: {
                                TagChip(tag: tag, disableTapGesture: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            Spacer()
            
            Divider()
            
            // 操作按钮
            HStack {
                Spacer()
                Button("取消") {
                    store.send(.tagEdit(.hideTagEditPanel))
                }
                .keyboardShortcut(.escape)
                
                Button("保存") {
                    store.send(.tagEdit(.saveTags))
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(20)
        .frame(width: 400, height: 500)
        .onAppear {
            isInputFocused = true
        }
    }
}

/// 流式布局组件（用于标签排列）
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var frames: [CGRect] = []
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // 换行
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                let frame = CGRect(x: currentX, y: currentY, width: size.width, height: size.height)
                frames.append(frame)
                
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            self.frames = frames
            self.size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}

#Preview {
    TagEditPanel(
        store: Store(initialState: EditorFeature.State()) {
            EditorFeature()
        }
    )
}


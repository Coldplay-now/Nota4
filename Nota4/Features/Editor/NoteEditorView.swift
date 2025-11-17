import SwiftUI
import ComposableArchitecture
import AppKit

struct NoteEditorView: View {
    @Bindable var store: StoreOf<EditorFeature>
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        WithPerceptionTracking {
            Group {
                if let note = store.note {
                    VStack(spacing: 0) {
                        // 标题栏
                        HStack {
                            TextField(
                                "标题",
                                text: $store.title
                            )
                            .font(.title)
                            .textFieldStyle(.plain)
                            .focused($isTitleFocused)
                            .onChange(of: isTitleFocused) { oldValue, newValue in
                                // 失去焦点时保存
                                if !newValue {
                                    store.send(.manualSave)
                                }
                            }
                            
                            Spacer()
                            
                            // 星标按钮
                            Button {
                                store.send(.toggleStar)
                            } label: {
                                Image(systemName: note.isStarred ? "star.fill" : "star")
                                    .foregroundColor(note.isStarred ? .yellow : .gray)
                            }
                            .buttonStyle(.plain)
                            
                            // 删除按钮
                            Button(role: .destructive) {
                                store.send(.requestDeleteNote)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        
                        Divider()
                        
                        // 独立工具栏
                        IndependentToolbar(store: store)
                        
                        Divider()
                        
                        // 编辑器/预览区域
                        Group {
                            if store.viewMode == .editOnly {
                                MarkdownTextEditor(
                                    text: $store.content,
                                    selection: $store.selectionRange,
                                    font: NSFont(
                                        name: store.editorStyle.fontName ?? "System",
                                        size: store.editorStyle.fontSize
                                    ) ?? NSFont.systemFont(ofSize: store.editorStyle.fontSize),
                                    textColor: .labelColor,
                                    backgroundColor: .textBackgroundColor,
                                    lineSpacing: store.editorStyle.lineSpacing,
                                    paragraphSpacing: store.editorStyle.paragraphSpacing,
                                    horizontalPadding: store.editorStyle.horizontalPadding,
                                    verticalPadding: store.editorStyle.verticalPadding,
                                    onSelectionChange: { range in
                                        store.send(.selectionChanged(range))
                                    },
                                    onFocusChange: { isFocused in
                                        store.send(.focusChanged(isFocused))
                                    }
                                )
                                // 编辑模式：占满整个可用空间，不限制宽度
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contextMenu {
                                    EditorContextMenu(store: store)
                                }
                            } else {
                                // 预览模式：占满整个可用空间
                                MarkdownPreview(store: store)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "选择一篇笔记开始编辑",
                        systemImage: "arrow.left",
                        description: Text("从左侧列表选择或创建新笔记")
                    )
                }
            }
            .confirmationDialog(
                "确认删除",
                isPresented: $store.showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("删除", role: .destructive) {
                    store.send(.confirmDeleteNote)
                }
                Button("取消", role: .cancel) {
                    store.send(.cancelDeleteNote)
                }
            } message: {
                Text("确定要删除这篇笔记吗？此操作可以在回收站中恢复。")
            }
            .onChange(of: store.showImagePicker) { oldValue, newValue in
                if newValue {
                    showImagePicker()
                }
            }
            .onChange(of: store.showAttachmentPicker) { oldValue, newValue in
                if newValue {
                    showAttachmentPicker()
                }
            }
        }
    }
    
    // MARK: - File Picker Helpers
    
    private func showImagePicker() {
        let panel = NSOpenPanel()
        panel.title = "选择图片"
        panel.message = "请选择要插入的图片文件"
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                store.send(.insertImage(url))
            } else {
                store.send(.dismissImagePicker)
            }
        }
    }
    
    private func showAttachmentPicker() {
        let panel = NSOpenPanel()
        panel.title = "选择附件"
        panel.message = "请选择要插入的附件文件"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                store.send(.insertAttachment(url))
            } else {
                store.send(.dismissAttachmentPicker)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NoteEditorView(
            store: Store(initialState: EditorFeature.State()) {
                EditorFeature()
            }
        )
    }
}


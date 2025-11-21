import SwiftUI
import ComposableArchitecture
import AppKit

struct NoteEditorView: View {
    @Bindable var store: StoreOf<EditorFeature>
    @FocusState private var isTitleFocused: Bool
    
    private var titleField: some View {
        HighlightedTitleField(
            text: $store.title,
            searchKeywords: store.listSearchKeywords,
            fontName: store.editorStyle.titleFontName,
            fontSize: store.editorStyle.titleFontSize,
            onFocusChange: { isFocused in
                if !isFocused {
                    store.send(.manualSave)
                }
            },
            isFocused: Binding(
                get: { isTitleFocused },
                set: { isTitleFocused = $0 }
            ),
            onReturnKey: {
                // 标题编辑时按回车，将焦点移到正文文首
                isTitleFocused = false
                
                // 通过 NotificationCenter 通知 MarkdownTextEditor 设置焦点
                // 这样可以直接访问 textView，不需要递归查找
                NotificationCenter.default.post(
                    name: NSNotification.Name("MoveFocusToContentStart"),
                    object: nil
                )
            }
        )
    }
    
    var body: some View {
        Group {
            if let note = store.note {
                VStack(spacing: 0) {
                    // 标题栏
                        HStack {
                            titleField
                            
                            Spacer()
                            
                            // 星标按钮
                            Button {
                                store.send(.toggleStar)
                            } label: {
                                Image(systemName: note.isStarred ? "star.fill" : "star")
                                    .foregroundColor(note.isStarred ? .yellow : .gray)
                            }
                            .buttonStyle(.plain)
                            
                            // 置顶按钮
                            Button {
                                store.send(.togglePin)
                            } label: {
                                Image(systemName: note.isPinned ? "pin.fill" : "pin")
                                    .foregroundColor(note.isPinned ? .orange : .gray)
                            }
                            .buttonStyle(.plain)
                            
                            // 标签编辑按钮
                            Button {
                                store.send(.tagEdit(.showTagEditPanel))
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "tag")
                                    if !note.tags.isEmpty {
                                        Text("\(note.tags.count)")
                                            .font(.caption2)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .help("编辑标签")
                            
                            // 删除按钮
                            Button(role: .destructive) {
                                store.send(.requestDeleteNote)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(height: 60)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(Color(nsColor: .separatorColor)),
                            alignment: .bottom
                        )
                        
                        // 独立工具栏
                        IndependentToolbar(store: store)
                        
                        // 搜索面板（条件显示）
                        if store.search.isSearchPanelVisible {
                            SearchPanel(store: store)
                        }
                        
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
                                    },
                                    searchMatches: store.search.matches,
                                    currentSearchIndex: store.search.currentMatchIndex
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
            .sheet(isPresented: Binding(
                get: { store.tagEdit.isTagEditPanelVisible },
                set: { if !$0 { store.send(.tagEdit(.hideTagEditPanel)) } }
            )) {
                TagEditPanel(store: store)
            }
            .onChange(of: store.showImagePicker) { oldValue, newValue in
                if newValue {
                    showImagePicker(store: store)
                }
            }
            .onChange(of: store.showAttachmentPicker) { oldValue, newValue in
                if newValue {
                    showAttachmentPicker(store: store)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// 递归查找视图层次结构中的 NSTextView（正文编辑器）
    /// 排除标题输入框（NSTextField），只查找正文编辑器（NSTextView）
    private func findTextView(in view: NSView) -> NSTextView? {
        // 跳过 NSTextField（标题输入框）
        if view is NSTextField {
            return nil
        }
        
        // 如果是 NSScrollView，检查其 documentView 是否是 NSTextView
        if let scrollView = view as? NSScrollView,
           let textView = scrollView.documentView as? NSTextView,
           textView.isEditable {
            return textView
        }
        
        // 如果是 NSTextView，检查是否在 NSScrollView 中（正文编辑器）
        if let textView = view as? NSTextView,
           textView.isEditable,
           textView.superview is NSScrollView {
            return textView
        }
        
        // 递归查找子视图
        for subview in view.subviews {
            if let textView = findTextView(in: subview) {
                return textView
            }
        }
        
        return nil
    }
    
    // MARK: - File Picker Helpers
    
    private func showImagePicker(store: StoreOf<EditorFeature>) {
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
    
    private func showAttachmentPicker(store: StoreOf<EditorFeature>) {
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

#Preview {
    NavigationStack {
        NoteEditorView(
            store: Store(initialState: EditorFeature.State()) {
                EditorFeature()
            }
        )
    }
}


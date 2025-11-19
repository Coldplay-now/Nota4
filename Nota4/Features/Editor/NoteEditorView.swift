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
            )
        )
    }
    
    private var editorContentArea: some View {
        HStack(spacing: 0) {
            // 左对齐时不需要左侧 Spacer
            if store.editorStyle.alignment == .center {
                Spacer()
            }
            
            Group {
                if store.viewMode == .editOnly {
                    editorView
                } else {
                    previewView
                }
            }
            
            // 右对齐时不需要右侧 Spacer，居中时需要
            if store.editorStyle.alignment == .center {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var editorView: some View {
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
            maxWidth: store.editorStyle.maxWidth,
            alignment: store.editorStyle.alignment == .center ? .center : .leading,
            onSelectionChange: { range in
                store.send(.selectionChanged(range))
            },
            onFocusChange: { isFocused in
                store.send(.focusChanged(isFocused))
            },
            searchMatches: store.search.matches,
            currentSearchIndex: store.search.currentMatchIndex
        )
        // 不再限制 MarkdownTextEditor 的宽度，让它占满可用空间
        // 内容宽度限制在 NSTextView 的 textContainer 中设置
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contextMenu {
            EditorContextMenu(store: store)
        }
    }
    
    private var previewView: some View {
        MarkdownPreview(store: store)
            // 预览模式：WebViewWrapper 占满空间，内容宽度在 HTML/CSS 中限制
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var body: some View {
        WithPerceptionTracking {
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
                            
                            // 标签按钮
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
                            
                            // 删除按钮
                            Button(role: .destructive) {
                                store.send(.requestDeleteNote)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        
                        // 标签显示区域（在标题栏下方）
                        if !note.tags.isEmpty {
                            HStack(spacing: 6) {
                                Text("标签:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // 标签列表
                                ForEach(Array(note.tags.sorted()), id: \.self) { tag in
                                    TagChip(tag: tag, onClick: {
                                        store.send(.tagEdit(.showTagEditPanel))
                                    })
                                }
                                
                                // 添加标签按钮
                                Button {
                                    store.send(.tagEdit(.showTagEditPanel))
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .font(.caption)
                                }
                                .buttonStyle(.plain)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                        }
                        
                        Divider()
                        
                        // 独立工具栏
                        IndependentToolbar(store: store)
                        
                        // 搜索面板（条件显示）
                        if store.search.isSearchPanelVisible {
                            SearchPanel(store: store)
                                .frame(maxWidth: .infinity, alignment: .leading)  // 左对齐，与工具栏一致
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.2), value: store.search.isSearchPanelVisible)
                        }
                        
                        Divider()
                        
                        // 编辑器/预览区域
                        editorContentArea
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
                    showImagePicker()
                }
            }
            .onChange(of: store.showAttachmentPicker) { oldValue, newValue in
                if newValue {
                    showAttachmentPicker()
                }
            }
            .onChange(of: store.note) { oldNote, newNote in
                // 当笔记加载后，如果是新创建的笔记（标题为"无标题"且内容为空），自动设置焦点到标题栏
                if let note = newNote, note.title == "无标题" && note.content.isEmpty {
                    // 使用 Task 延迟一点时间，确保视图已经更新
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(100))
                        isTitleFocused = true
                    }
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


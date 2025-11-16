import SwiftUI
import ComposableArchitecture

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
                                store.send(.deleteNote)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        
                        Divider()
                        
                        // 编辑器/预览区域
                        Group {
                            switch store.viewMode {
                            case .editOnly:
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
                                .frame(maxWidth: store.editorStyle.maxWidth)
                                .frame(maxWidth: .infinity, alignment: store.editorStyle.alignment)
                                .toolbar {
                                    ToolbarItemGroup(placement: .automatic) {
                                        MarkdownToolbar(store: store)
                                    }
                                }
                                .contextMenu {
                                    EditorContextMenu(store: store)
                                }
                                
                            case .previewOnly:
                                MarkdownPreview(content: store.content)
                                
                            case .split:
                                HSplitView {
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
                                    .frame(maxWidth: store.editorStyle.maxWidth)
                                    .frame(maxWidth: .infinity, alignment: store.editorStyle.alignment)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .automatic) {
                                            MarkdownToolbar(store: store)
                                        }
                                    }
                                    .contextMenu {
                                        EditorContextMenu(store: store)
                                    }
                                    
                                    MarkdownPreview(content: store.content)
                                }
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
            .toolbar {
                // 视图模式切换
                ToolbarItem {
                    Picker("视图模式", selection: Binding(
                        get: { store.viewMode },
                        set: { store.send(.viewModeChanged($0)) }
                    )) {
                        ForEach(EditorFeature.State.ViewMode.allCases, id: \.self) { mode in
                            Label(mode.rawValue, systemImage: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                // 保存状态
                ToolbarItem {
                    Group {
                        if store.isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else if store.hasUnsavedChanges {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.orange)
                                .help("有未保存的更改")
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .help("已保存")
                        }
                    }
                    .animation(.spring(), value: store.isSaving)
                    .animation(.spring(), value: store.hasUnsavedChanges)
                }
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


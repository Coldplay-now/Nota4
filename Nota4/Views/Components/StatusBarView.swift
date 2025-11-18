import SwiftUI
import ComposableArchitecture

// MARK: - Status Bar View

/// 全局底部状态栏
/// 左侧：全局统计（共 X 篇笔记）
/// 右侧：编辑器信息（光标位置 | 总行数 | 总字数 | 保存状态 | 更新时间）
struct StatusBarView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithPerceptionTracking {
            HStack(spacing: 12) {
                // 左侧：全局统计
                HStack(spacing: 4) {
                    Image(systemName: "folder")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Text("共 \(store.sidebar.categoryCounts[.all] ?? 0) 篇笔记")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                // 布局模式指示器（中间）
                Button {
                    // 循环切换布局模式
                    let nextMode: LayoutMode
                    switch store.layoutMode {
                    case .threeColumn:
                        nextMode = .twoColumn
                    case .twoColumn:
                        nextMode = .oneColumn
                    case .oneColumn:
                        nextMode = .threeColumn
                    }
                    store.send(.layoutModeChanged(nextMode))
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: store.layoutMode.icon)
                            .font(.system(size: 10))
                        Text(store.layoutMode.rawValue)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("点击切换布局模式")
                
                Spacer()
                
                // 右侧：编辑器信息（仅当有打开的笔记时显示）
                if store.editor.note != nil {
                    let lineCount = store.editor.content.lineCount
                    let wordCount = store.editor.content.wordCount
                    let (cursorLine, cursorColumn) = store.editor.content.lineAndColumn(at: store.editor.selectionRange.location)
                    
                    HStack(spacing: 12) {
                        // 光标位置
                        if cursorLine > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.and.down.text.horizontal")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                
                                Text("第 \(cursorLine) 行: \(cursorColumn) 列")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("·")
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        
                        // 总行数
                        if lineCount > 0 {
                            HStack(spacing: 4) {
                                Text("\(lineCount) 行")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("·")
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        
                        // 总字数
                        if wordCount > 0 {
                            HStack(spacing: 4) {
                                Text("总字数")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                
                                Text("\(wordCount)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("·")
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        
                        // 保存状态
                        HStack(spacing: 4) {
                            if store.editor.isSaving {
                                Image(systemName: "arrow.clockwise.circle")
                                    .font(.system(size: 10))
                                    .foregroundColor(.blue)
                                
                                Text("保存中")
                                    .font(.system(size: 11))
                                    .foregroundColor(.blue)
                            } else if store.editor.hasUnsavedChanges {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.orange)
                                
                                Text("未保存")
                                    .font(.system(size: 11))
                                    .foregroundColor(.orange)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green)
                                
                                Text("已保存")
                                    .font(.system(size: 11))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // 更新时间
                        if let note = store.editor.note {
                            Text("·")
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                
                                Text(note.updated.timeAgoString)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 22)
            .background(Color(nsColor: .windowBackgroundColor))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(nsColor: .separatorColor)),
                alignment: .top
            )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 400)
        
        StatusBarView(
            store: Store(initialState: AppFeature.State()) {
                AppFeature()
            }
        )
    }
    .frame(width: 800, height: 422)
}


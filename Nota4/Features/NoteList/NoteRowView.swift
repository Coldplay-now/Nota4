import SwiftUI

struct NoteRowView: View {
    let note: Note
    var searchKeywords: [String] = []
    var isSelected: Bool = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // 标题（带高亮）
                Group {
                if searchKeywords.isEmpty {
                    Text(note.title.isEmpty ? "无标题" : note.title)
                        .font(.headline)
                            .foregroundStyle(Color(nsColor: .labelColor))
                        .lineLimit(2)
                } else {
                    Text(note.title.isEmpty ? "无标题" : note.title.highlightingOccurrences(of: searchKeywords))
                        .font(.headline)
                            .foregroundStyle(Color(nsColor: .labelColor))
                        .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            .padding(.bottom, 6)
            
            // 预览（带高亮）
            Group {
            if searchKeywords.isEmpty {
                Text(note.preview)
                    .font(.subheadline)
                        .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    .lineLimit(3)
            } else {
                Text(note.preview.highlightingOccurrences(of: searchKeywords))
                    .font(.subheadline)
                        .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    .lineLimit(3)
                }
            }
            .padding(.bottom, 8)
            
            // 底部信息
            HStack(alignment: .center, spacing: 8) {
                // 左侧：置顶图标 + 星标图标 + 标签
                HStack(spacing: 6) {
                    // 置顶图标（移至左下角，与星标一行）
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    
                    // 星标图标（左下角）
                    if note.isStarred {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                    
                    // 标签
                    if !note.tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(Array(note.tags.prefix(2)), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .foregroundStyle(Color(nsColor: .labelColor))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.2))
                                    .cornerRadius(4)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            if note.tags.count > 2 {
                                Text("+\(note.tags.count - 2)")
                                    .font(.caption2)
                                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                        .fixedSize(horizontal: true, vertical: false)
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
                
                Spacer(minLength: 8)
                
                // 右侧：时间
                Text(note.updated, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(12)
        .background(
            ZStack(alignment: .leading) {
                // 卡片背景：使用系统颜色，根据主题自动调整
                // 使用 controlBackgroundColor 而不是 textBackgroundColor，避免选中时系统自动变深
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor))
                
                // Hover背景（只在未选中时显示）
                if !isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isHovered ? Color(nsColor: .controlAccentColor).opacity(0.08) : Color.clear)
                }
                
                // 选中状态：显示灰色背景（与 hover 一致）+ 橙色左边框
                if isSelected {
                    // 选中时的灰色背景（与 hover 一致）
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .controlAccentColor).opacity(0.08))
                    
                    // 橙色左边框
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 3)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle()) // 确保点击区域正确
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    List {
        NoteRowView(note: Note.mock)
        NoteRowView(note: Note.mockData[0])
        NoteRowView(note: Note.mockData[1])
    }
}







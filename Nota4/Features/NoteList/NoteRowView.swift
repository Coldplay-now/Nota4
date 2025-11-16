import SwiftUI

struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // 置顶图标
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
                
                // 标题
                Text(note.title.isEmpty ? "无标题" : note.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                // 星标图标
                if note.isStarred {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            // 预览
            Text(note.preview)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // 底部信息
            HStack {
                // 标签
                if !note.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(note.tags.prefix(2)), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(4)
                        }
                        if note.tags.count > 2 {
                            Text("+\(note.tags.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // 时间
                Text(note.updated, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        NoteRowView(note: Note.mock)
        NoteRowView(note: Note.mockData[0])
        NoteRowView(note: Note.mockData[1])
    }
}







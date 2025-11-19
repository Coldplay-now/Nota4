import SwiftUI
import ComposableArchitecture

struct ImportView: View {
    let store: StoreOf<ImportFeature>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 20) {
                if store.isImporting {
                    VStack(spacing: 12) {
                        ProgressView(value: store.importProgress) {
                            Text("正在导入...")
                                .font(.headline)
                        }
                        .progressViewStyle(.linear)
                        
                        Text("\(Int(store.importProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if !store.importedNotes.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("成功导入 \(store.importedNotes.count) 篇笔记")
                            .font(.headline)
                        
                        Button("完成") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if let errorMessage = store.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        
                        Text("导入失败")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            Button("关闭") {
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("重试") {
                                store.send(.dismissError)
                                // 这里需要重新触发文件选择
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("导入笔记")
                            .font(.title)
                        
                        Text("支持 .nota 和 .md 文件")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("导入 .nota 文件保留所有元数据", systemImage: "checkmark")
                            Label("导入 .md 文件自动转换为笔记", systemImage: "checkmark")
                            Label("支持批量导入多个文件", systemImage: "checkmark")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Button {
                            selectFilesToImport()
                        } label: {
                            Label("选择文件", systemImage: "folder")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                }
            }
            .frame(width: 400, height: 300)
        }
    }
    
    private func selectFilesToImport() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.init(filenameExtension: "nota")!, .init(filenameExtension: "md")!]
        panel.message = "选择要导入的笔记文件"
        
        panel.begin { response in
            if response == .OK {
                store.send(.importFiles(panel.urls))
            }
        }
    }
}

#Preview {
    ImportView(
        store: Store(initialState: ImportFeature.State()) {
            ImportFeature()
        }
    )
}














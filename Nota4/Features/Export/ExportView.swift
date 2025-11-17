import SwiftUI
import ComposableArchitecture

struct ExportView: View {
    let store: StoreOf<ExportFeature>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            if store.isExporting {
                VStack(spacing: 12) {
                    ProgressView(value: store.exportProgress) {
                        Text("正在导出...")
                            .font(.headline)
                    }
                    .progressViewStyle(.linear)
                    
                    Text("\(Int(store.exportProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if store.exportCompleted {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("成功导出 \(store.notesToExport.count) 篇笔记")
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
                    
                    Text("导出失败")
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
                            store.send(.selectExportLocation)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("导出笔记")
                        .font(.title)
                    
                    Text("导出 \(store.notesToExport.count) 篇笔记")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    // 导出格式选择
                    VStack(alignment: .leading, spacing: 12) {
                        Text("导出格式")
                            .font(.headline)
                        
                        Picker("", selection: Binding(
                            get: { store.exportFormat },
                            set: { store.send(.binding(.set(\.exportFormat, $0))) }
                        )) {
                            Text(".nota (保留所有元数据)").tag(ExportFeature.ExportFormat.nota)
                            Text(".md (Markdown)").tag(ExportFeature.ExportFormat.markdown)
                        }
                        .pickerStyle(.radioGroup)
                        
                        if store.exportFormat == .markdown {
                            Toggle(
                                "包含元数据 (YAML Front Matter)",
                                isOn: Binding(
                                    get: { store.includeMetadata },
                                    set: { store.send(.binding(.set(\.includeMetadata, $0))) }
                                )
                            )
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    
                    Button {
                        selectExportDirectory()
                    } label: {
                        Label("选择导出位置", systemImage: "folder")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
            }
        }
        .frame(width: 450, height: 400)
    }
    
    private func selectExportDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.message = "选择导出位置"
        panel.prompt = "导出"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                store.send(.exportToDirectory(url))
            }
        }
    }
}

#Preview {
    ExportView(
        store: Store(
            initialState: ExportFeature.State(
                notesToExport: Note.mockData
            )
        ) {
            ExportFeature()
        }
    )
}










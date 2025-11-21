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
                VStack(spacing: 0) {
                    // 标题区域（固定）
                    VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 50))
                        .foregroundColor(.accentColor)
                    
                    Text("导出笔记")
                            .font(.title2)
                    
                    Text("导出 \(store.notesToExport.count) 篇笔记")
                            .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    Divider()
                    
                    // 可滚动的内容区域
                    ScrollView {
                        VStack(spacing: 16) {
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
                                    Text(".html (HTML 网页)").tag(ExportFeature.ExportFormat.html)
                                    Text(".pdf (PDF 文档)").tag(ExportFeature.ExportFormat.pdf)
                                    Text(".png (PNG 图片)").tag(ExportFeature.ExportFormat.png)
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
                                
                                if store.exportFormat == .html {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Toggle(
                                            "包含目录 (TOC)",
                                            isOn: Binding(
                                                get: { store.htmlOptions.includeTOC },
                                                set: { newValue in
                                                    var options = store.htmlOptions
                                                    options.includeTOC = newValue
                                                    store.send(.updateHTMLOptions(options))
                                                }
                                            )
                                        )
                                        
                                        Picker("图片处理方式", selection: Binding(
                                            get: { store.htmlOptions.imageHandling },
                                            set: { newValue in
                                                var options = store.htmlOptions
                                                options.imageHandling = newValue
                                                store.send(.updateHTMLOptions(options))
                                            }
                                        )) {
                                            Text("Base64 内嵌（自包含）").tag(ImageHandling.base64)
                                            Text("相对路径").tag(ImageHandling.relativePath)
                                            Text("绝对路径").tag(ImageHandling.absolutePath)
                                        }
                                        .pickerStyle(.menu)
                                    }
                                }
                                
                                if store.exportFormat == .pdf {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Toggle(
                                            "包含目录 (TOC)",
                                            isOn: Binding(
                                                get: { store.pdfOptions.includeTOC },
                                                set: { newValue in
                                                    var options = store.pdfOptions
                                                    options.includeTOC = newValue
                                                    store.send(.updatePDFOptions(options))
                                                }
                                            )
                                        )
                                        
                                        Picker("页面大小", selection: Binding(
                                            get: { store.pdfOptions.paperSizeEnum },
                                            set: { newValue in
                                                var options = store.pdfOptions
                                                options.setPaperSize(newValue)
                                                store.send(.updatePDFOptions(options))
                                            }
                                        )) {
                                            Text("A4").tag(PaperSize.a4)
                                            Text("Letter").tag(PaperSize.letter)
                                        }
                                        .pickerStyle(.menu)
                                        
                                        HStack {
                                            Text("页边距:")
                                            TextField("", value: Binding(
                                                get: { store.pdfOptions.margin },
                                                set: { newValue in
                                                    var options = store.pdfOptions
                                                    options.margin = newValue ?? 72.0
                                                    store.send(.updatePDFOptions(options))
                                                }
                                            ), format: .number)
                                            .frame(width: 60)
                                            Text("点")
                                        }
                                    }
                                }
                                
                                if store.exportFormat == .png {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Toggle(
                                            "包含目录 (TOC)",
                                            isOn: Binding(
                                                get: { store.pngOptions.includeTOC },
                                                set: { newValue in
                                                    var options = store.pngOptions
                                                    options.includeTOC = newValue
                                                    store.send(.updatePNGOptions(options))
                                                }
                                            )
                                        )
                                        
                                        HStack {
                                            Text("图片宽度:")
                                            TextField("", value: Binding(
                                                get: { store.pngOptions.width },
                                                set: { newValue in
                                                    var options = store.pngOptions
                                                    options.width = newValue ?? 1200
                                                    store.send(.updatePNGOptions(options))
                                                }
                                            ), format: .number)
                                            .frame(width: 80)
                                            Text("像素")
                                        }
                                        
                                        HStack {
                                            Text("背景色:")
                                            TextField("", text: Binding(
                                                get: { store.pngOptions.backgroundColor ?? "" },
                                                set: { newValue in
                                                    var options = store.pngOptions
                                                    options.backgroundColor = newValue.isEmpty ? nil : newValue
                                                    store.send(.updatePNGOptions(options))
                                                }
                                            ))
                                            .frame(width: 100)
                                            Text("(可选，如 #FFFFFF)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    Divider()
                    
                    // 底部按钮区域（固定）
                    HStack {
                        Button("取消") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                    
                    Button {
                        selectExportDirectory()
                    } label: {
                        Label("选择导出位置", systemImage: "folder")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(nsColor: .controlBackgroundColor))
                }
            }
        }
        .frame(width: 520, height: 600)
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











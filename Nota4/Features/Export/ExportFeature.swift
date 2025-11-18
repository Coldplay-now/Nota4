import ComposableArchitecture
import Foundation

@Reducer
struct ExportFeature {
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable {
        var notesToExport: [Note]
        var isExporting = false
        var exportFormat: ExportFormat = .nota
        var includeMetadata = true
        var errorMessage: String?
        var exportProgress: Double = 0.0
        var exportCompleted = false
        
        // 新增：导出选项
        var htmlOptions: HTMLExportOptions = .default
        var pdfOptions: PDFExportOptions = .default
        var pngOptions: PNGExportOptions = .default
        
        // 新增：导出模式（单文件 vs 批量）
        var exportMode: ExportMode = .multiple
        
        init(notesToExport: [Note], exportFormat: ExportFormat = .nota) {
            self.notesToExport = notesToExport
            self.exportFormat = exportFormat
            // 如果只有一篇笔记，默认单文件导出
            if notesToExport.count == 1 {
                self.exportMode = .single
            }
        }
    }
    
    enum ExportMode: Equatable {
        case single    // 单文件导出（选择保存位置）
        case multiple  // 批量导出（选择目录）
    }
    
    enum ExportFormat: Equatable {
        case nota
        case markdown
        case html      // 新增
        case pdf       // 新增
        case png       // 新增
    }
    
    // MARK: - Action
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case selectExportLocation
        case exportToDirectory(URL)
        case exportStarted
        case exportProgress(Double)
        case exportCompleted
        case exportFailed(Error)
        case dismissError
        case dismiss
        
        // 新增：单文件导出
        case exportToFile(URL, ExportFormat)
        
        // 新增：选项更新
        case updateHTMLOptions(HTMLExportOptions)
        case updatePDFOptions(PDFExportOptions)
        case updatePNGOptions(PNGExportOptions)
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.exportService) var exportService
    @Dependency(\.mainQueue) var mainQueue
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .selectExportLocation:
                // 这个动作由 View 处理，显示文件选择器
                return .none
                
            case .exportToFile(let url, let format):
                state.isExporting = true
                state.errorMessage = nil
                state.exportProgress = 0.0
                state.exportCompleted = false
                
                guard let note = state.notesToExport.first else {
                    return .send(.exportFailed(ExportServiceError.invalidURL))
                }
                
                let htmlOptions = state.htmlOptions
                let pdfOptions = state.pdfOptions
                let pngOptions = state.pngOptions
                let includeMetadata = state.includeMetadata
                
                return .run { send in
                    await send(.exportStarted)
                    
                    do {
                        // 根据格式调用不同的导出方法
                        switch format {
                        case .html:
                            try await exportService.exportAsHTML(
                                note: note,
                                to: url,
                                options: htmlOptions
                            )
                        case .nota:
                            try await exportService.exportAsNota(note: note, to: url)
                        case .markdown:
                            try await exportService.exportAsMarkdown(
                                note: note,
                                to: url,
                                includeMetadata: includeMetadata
                            )
                        case .pdf:
                            // 更新进度（PDF 生成较慢）
                            await send(.exportProgress(0.3))
                            try await exportService.exportAsPDF(
                                note: note,
                                to: url,
                                options: pdfOptions
                            )
                        case .png:
                            // 更新进度（PNG 生成较慢）
                            await send(.exportProgress(0.3))
                            try await exportService.exportAsPNG(
                                note: note,
                                to: url,
                                options: pngOptions
                            )
                        }
                        
                        await send(.exportProgress(1.0))
                        await send(.exportCompleted)
                    } catch {
                        await send(.exportFailed(error))
                    }
                }
                
            case .exportToDirectory(let url):
                state.isExporting = true
                state.errorMessage = nil
                state.exportProgress = 0.0
                state.exportCompleted = false
                
                let notes = state.notesToExport
                let exportFormat = state.exportFormat
                let htmlOptions = state.htmlOptions
                let pdfOptions = state.pdfOptions
                let pngOptions = state.pngOptions
                let includeMetadata = state.includeMetadata
                
                let format: Services.ExportFormat
                switch exportFormat {
                case .nota:
                    format = .nota
                case .markdown:
                    format = .markdown(includeMetadata: includeMetadata)
                case .html:
                    format = .html(options: htmlOptions)
                case .pdf:
                    format = .pdf(options: pdfOptions)
                case .png:
                    format = .png(options: pngOptions)
                }
                
                return .run { send in
                    await send(.exportStarted)
                    
                    do {
                        let totalNotes = notes.count
                        for (index, note) in notes.enumerated() {
                            // 更新进度
                            let progress = Double(index) / Double(totalNotes)
                            await send(.exportProgress(progress))
                            
                            // 导出单个笔记
                            let fileName = generateFileName(note: note, format: exportFormat)
                            let fileURL = url.appendingPathComponent(fileName)
                            
                            switch format {
                            case .nota:
                                try await exportService.exportAsNota(note: note, to: fileURL)
                            case .markdown(let includeMetadata):
                                try await exportService.exportAsMarkdown(
                                    note: note,
                                    to: fileURL,
                                    includeMetadata: includeMetadata
                                )
                            case .html(let options):
                                try await exportService.exportAsHTML(
                                    note: note,
                                    to: fileURL,
                                    options: options
                                )
                            case .pdf(let options):
                                // 更新进度（PDF 生成较慢）
                                let currentProgress = Double(index) / Double(totalNotes)
                                await send(.exportProgress(currentProgress + 0.1))
                                try await exportService.exportAsPDF(
                                    note: note,
                                    to: fileURL,
                                    options: options
                                )
                            case .png(let options):
                                // 更新进度（PNG 生成较慢）
                                let currentProgress = Double(index) / Double(totalNotes)
                                await send(.exportProgress(currentProgress + 0.1))
                                try await exportService.exportAsPNG(
                                    note: note,
                                    to: fileURL,
                                    options: options
                                )
                            }
                        }
                        
                        await send(.exportProgress(1.0))
                        await send(.exportCompleted)
                    } catch {
                        await send(.exportFailed(error))
                    }
                }
                
            case .exportStarted:
                return .none
                
            case .exportProgress(let progress):
                state.exportProgress = progress
                return .none
                
            case .exportCompleted:
                state.isExporting = false
                state.exportCompleted = true
                state.exportProgress = 1.0
                return .none
                
            case .exportFailed(let error):
                state.isExporting = false
                state.errorMessage = error.localizedDescription
                state.exportProgress = 0.0
                return .none
                
            case .dismissError:
                state.errorMessage = nil
                return .none
                
            case .dismiss:
                return .none
                
            case .updateHTMLOptions(let options):
                state.htmlOptions = options
                return .none
                
            case .updatePDFOptions(let options):
                state.pdfOptions = options
                return .none
                
            case .updatePNGOptions(let options):
                state.pngOptions = options
                return .none
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func generateFileName(note: Note, format: ExportFormat) -> String {
        let sanitizedTitle = sanitizeFileName(note.title.isEmpty ? note.noteId : note.title)
        let fileExtension: String
        
        switch format {
        case .nota:
            fileExtension = "nota"
        case .markdown:
            fileExtension = "md"
        case .html:
            fileExtension = "html"
        case .pdf:
            fileExtension = "pdf"
        case .png:
            fileExtension = "png"
        }
        
        return "\(sanitizedTitle).\(fileExtension)"
    }
    
    private func sanitizeFileName(_ name: String) -> String {
        // 移除不安全的文件名字符
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
}

// MARK: - Dependency Key

private enum ExportServiceKey: DependencyKey {
    static let liveValue: ExportServiceProtocol = ExportServiceImpl.shared
    static let testValue: ExportServiceProtocol = ExportServiceImpl.mock
}

extension DependencyValues {
    var exportService: ExportServiceProtocol {
        get { self[ExportServiceKey.self] }
        set { self[ExportServiceKey.self] = newValue }
    }
}







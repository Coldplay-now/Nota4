import SwiftUI
import MarkdownUI

struct MarkdownPreview: View {
    let content: String
    
    var body: some View {
        ScrollView {
            Markdown(content)
                .markdownTheme(.gitHub)
                .padding()
        }
    }
}

#Preview {
    MarkdownPreview(content: """
    # Nota4 预览示例
    
    ## 功能特性
    
    - **加粗文本**
    - *斜体文本*
    - `代码`
    
    ### 代码块
    
    ```swift
    struct Note {
        let id: String
        let title: String
    }
    ```
    
    ### 列表
    
    1. 第一项
    2. 第二项
    3. 第三项
    """)
}


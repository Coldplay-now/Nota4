# Markdown 内部链接跳转修复总结

**日期**: 2024-11-21  
**版本**: 1.1.19  
**问题类型**: Bug 修复  
**优先级**: 高

## 问题描述

用户报告在预览模式下，点击 Markdown 文档中的目录内链（如 `[时序图](#82-时序图)`）无法跳转到对应的标题位置，但系统自动生成的 TOC 链接可以正常工作。

## 问题诊断

### 1. 初步分析
- **现象**: 手动编写的内链无法跳转，系统生成的 TOC 链接正常
- **环境**: macOS WKWebView，file:// 协议
- **影响范围**: 所有预打包的初始文档（`Markdown示例.nota`、`技术.nota`、`运动.nota`、`使用说明.nota`）

### 2. 根本原因定位

通过添加 `WKUIDelegate` 和 JavaScript Alert 调试，发现了两个关键问题：

#### 问题 1: 链接格式不一致
**文档中的链接格式**:
```markdown
[时序图](#82-时序图)
[运动类型](#2-运动类型)
```

**实际生成的 ID**:
```html
<h3 id="8.2.-时序图">时序图</h3>
<h2 id="2.-运动类型">运动类型</h2>
```

**差异**: 文档链接缺少了点号（`.`），导致 ID 无法匹配。

#### 问题 2: WKWebView Alert 支持缺失
- JavaScript 的 `alert()` 在 WKWebView 中默认不显示
- 需要实现 `WKUIDelegate` 的 `runJavaScriptAlertPanelWithMessage` 方法

## 解决方案

### 1. 修正文档链接格式

**修改文件**:
- `Nota4/Resources/InitialDocuments/Markdown示例.nota`
- `Nota4/Resources/InitialDocuments/技术.nota`
- `Nota4/Resources/InitialDocuments/运动.nota`

**修改规则**:
将所有带序号的标题链接从 `#数字-标题` 改为 `#数字.-标题`

**示例**:
```markdown
# 修改前
1. [编程语言](#1-编程语言)
   1.1. [Swift](#11-swift)
   1.2. [Python](#12-python)

# 修改后
1. [编程语言](#1.-编程语言)
   1.1. [Swift](#1.1.-swift)
   1.2. [Python](#1.2.-python)
```

### 2. 增强 WebView 导航逻辑

**修改文件**: `Nota4/Views/Components/WebViewWrapper.swift`

**改进内容**:
1. **添加 WKUIDelegate 支持**:
   ```swift
   class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
       func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, 
                    initiatedByFrame frame: WKFrameInfo, 
                    completionHandler: @escaping () -> Void) {
           let alert = NSAlert()
           alert.messageText = "Debug Info"
           alert.informativeText = message
           alert.addButton(withTitle: "OK")
           alert.runModal()
           completionHandler()
       }
   }
   ```

2. **使用 JavaScript scrollIntoView 替代原生锚点跳转**:
   - file:// 协议下 WKWebView 的原生锚点跳转不可靠
   - 使用 JavaScript 的 `scrollIntoView()` 提供更稳定的滚动体验

3. **添加模糊匹配逻辑**:
   - 精确匹配 ID
   - 尝试 URL 解码
   - 忽略连字符进行模糊匹配

### 3. ID 生成规则说明

`MarkdownRenderer.swift` 中的 `generateHeadingID` 方法规则：

```swift
// 输入: "1.1. Swift"
// 处理流程:
// 1. 转小写: "1.1. swift"
// 2. 空格转连字符: "1.1.-swift"
// 3. 移除特殊字符（保留字母、数字、连字符、中文）: "1.1.-swift"
// 4. 移除连续连字符: "1.1.-swift"
// 5. 移除首尾连字符: "1.1.-swift"
// 输出: "1.1.-swift"
```

**关键点**: 标题中的点号（`.`）会被保留，并在后面的空格转换为连字符后形成 `.-` 模式。

## 修改文件清单

### 代码文件
1. `Nota4/Views/Components/WebViewWrapper.swift`
   - 添加 `import AppKit`
   - 添加 `WKUIDelegate` 支持
   - 实现 `runJavaScriptAlertPanelWithMessage`
   - 设置 `webView.uiDelegate`

### 文档文件
1. `Nota4/Resources/InitialDocuments/Markdown示例.nota`
   - 修正目录中所有带序号的链接（1-8 及子级）

2. `Nota4/Resources/InitialDocuments/技术.nota`
   - 修正目录中所有带序号的链接（1-6 及子级）

3. `Nota4/Resources/InitialDocuments/运动.nota`
   - 修正目录中所有带序号的链接（1-5 及子级）

## 测试验证

### 测试步骤
1. 运行 `swift build` 构建应用
2. 使用 `make run` 启动应用
3. 打开 `Markdown示例.nota`、`技术.nota`、`运动.nota`
4. 点击目录中的各级链接
5. 验证能否正确跳转到对应标题

### 测试结果
✅ 所有内部链接均可正确跳转  
✅ 系统生成的 TOC 链接正常工作  
✅ 手动编写的目录链接正常工作  
✅ 跳转平滑，用户体验良好  

## 经验总结

### 1. 文档规范的重要性
- 手动编写的链接必须与自动生成的 ID 格式保持一致
- 需要明确文档化 ID 生成规则，供内容创建者参考

### 2. 调试技巧
- WKWebView 的 JavaScript 调试需要实现 `WKUIDelegate`
- 使用 Alert 弹窗可以直观地展示调试信息
- `OSLog` 配合 `log stream` 可以捕获系统日志

### 3. WebView 锚点跳转的坑
- file:// 协议下的原生锚点跳转不可靠
- JavaScript `scrollIntoView` 是更好的替代方案
- 需要处理 URL 编码和特殊字符

### 4. 开发流程优化
- `make run` 会自动增量编译，确保运行最新代码
- 使用 `log stream` 或 `make logs` 可以实时查看日志
- Alert 弹窗比纯日志更直观，适合快速定位问题

## 后续建议

### 1. 文档模板
为新建笔记提供标准的目录模板，确保链接格式正确：
```markdown
## 目录

1. [一级标题](#1.-一级标题)
   1.1. [二级标题](#1.1.-二级标题)
   1.2. [二级标题](#1.2.-二级标题)
```

### 2. 自动化检查
考虑添加链接格式验证工具，在保存时检查内链格式是否与 ID 生成规则一致。

### 3. 用户文档
在帮助文档中说明内部链接的正确写法，避免用户手动编写时出错。

## 相关资源

- [WKWebView 文档](https://developer.apple.com/documentation/webkit/wkwebview)
- [WKUIDelegate 文档](https://developer.apple.com/documentation/webkit/wkuidelegate)
- [Markdown 锚点规范](https://www.markdownguide.org/extended-syntax/#heading-ids)

---

**修复完成时间**: 2024-11-21  
**修复验证**: 通过  
**影响版本**: v1.1.19+


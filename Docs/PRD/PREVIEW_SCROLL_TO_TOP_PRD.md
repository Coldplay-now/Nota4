# 预览模式"回到页顶"功能 PRD

**创建日期**: 2025-11-21  
**版本**: v1.0  
**状态**: 待实现  
**优先级**: 中

---

## 1. 产品概述

### 1.1 功能描述

在预览模式的工具栏上添加一个"回到页顶"按钮，无论用户在文档的什么位置，始终可以通过这个按钮快速回到预览内容的顶部。

### 1.2 用户价值

- **提升用户体验**：长文档阅读时，快速返回顶部，无需手动滚动
- **提高操作效率**：一键操作，比手动滚动更快捷
- **符合用户习惯**：符合常见应用的交互模式

### 1.3 使用场景

1. 用户在预览模式下阅读长文档
2. 用户已滚动到文档中间或底部
3. 用户需要快速返回文档顶部查看标题或目录
4. 用户希望快速定位到文档开头

---

## 2. 功能需求

### 2.1 功能特性

#### 2.1.1 按钮显示

- **显示位置**：预览模式工具栏，视图模式切换按钮左侧
- **显示条件**：
  - 仅在预览模式下显示（`viewMode == .previewOnly`）
  - 仅在编辑模式下隐藏（`viewMode == .editOnly` 或 `.split`）
- **按钮样式**：
  - 图标：`arrow.up.to.line`（系统图标）
  - 文本：`回到页顶`
  - 快捷键提示：`⌘↑`（可选）

#### 2.1.2 按钮状态

- **启用条件**：
  - 有当前笔记（`note != nil`）
  - 预览内容不为空（`renderedHTML.isEmpty == false`）
- **禁用条件**：
  - 无当前笔记
  - 预览内容为空
  - 文档无需滚动（可选，需要检测滚动位置）

#### 2.1.3 滚动行为

- **滚动方式**：平滑滚动（`behavior: 'smooth'`）
- **目标位置**：页面顶部（`top: 0`）
- **执行方式**：通过 JavaScript 控制 WebView 滚动

### 2.2 交互设计

#### 2.2.1 按钮点击

1. 用户点击"回到页顶"按钮
2. 触发 TCA Action：`preview(.scrollToTop)`
3. 发送 NotificationCenter 通知
4. WebView 监听通知，执行 JavaScript 滚动
5. 页面平滑滚动到顶部

#### 2.2.2 视觉反馈

- 按钮点击时有标准按钮反馈（高亮效果）
- 滚动过程有平滑动画（约 300-500ms）
- 无额外的加载指示器（滚动是即时操作）

### 2.3 边界情况处理

1. **文档很短**：即使文档无需滚动，点击按钮也不应有错误
2. **快速连续点击**：多次点击应正常处理，不会产生冲突
3. **滚动过程中点击**：应取消当前滚动，立即开始新的滚动到顶部
4. **预览内容为空**：按钮禁用，不可点击

---

## 3. 技术设计

### 3.1 架构设计

#### 3.1.1 TCA 状态管理

**Action 设计**：
```swift
enum PreviewAction: Equatable {
    // ... 现有 Action ...
    case scrollToTop  // 新增：滚动到顶部
}
```

**State 设计**：
- 不需要新增 State
- 滚动操作是一次性副作用，不需要持久化状态

**Reducer 处理**：
```swift
case .preview(.scrollToTop):
    // 发送通知，触发 WebView 滚动
    NotificationCenter.default.post(name: .scrollPreviewToTop, object: nil)
    return .none
```

#### 3.1.2 通信机制

**方案：NotificationCenter（方案 A）**

- **优点**：
  - 解耦：WebViewWrapper 不需要知道 TCA
  - 通用：WebViewWrapper 是通用组件，不应依赖特定 Feature
  - 标准：NotificationCenter 是标准的解耦方式
- **实现**：
  - 定义通知名称：`scrollPreviewToTop`
  - WebViewWrapper.Coordinator 监听通知
  - 收到通知后执行 JavaScript 滚动

#### 3.1.3 JavaScript 实现

```javascript
window.scrollTo({ top: 0, behavior: 'smooth' });
```

- `top: 0`：滚动到顶部
- `behavior: 'smooth'`：平滑滚动动画

### 3.2 文件修改清单

1. **Nota4/Nota4/Features/Editor/IndependentToolbar.swift**
   - 在预览模式下添加"回到页顶"按钮
   - 位置：视图模式切换按钮左侧

2. **Nota4/Nota4/Features/Editor/EditorFeature.swift**
   - 在 `PreviewAction` 中添加 `case scrollToTop`
   - 在 Reducer 中处理该 Action，发送通知

3. **Nota4/Nota4/Views/Components/WebViewWrapper.swift**
   - 定义通知名称 `scrollPreviewToTop`
   - 在 `Coordinator` 中监听通知
   - 实现 `scrollToTop()` 方法，执行 JavaScript 滚动
   - 保存 `WKWebView` 引用以便执行 JavaScript

### 3.3 实现细节

#### 3.3.1 WebView 引用管理

```swift
class Coordinator: NSObject, WKNavigationDelegate {
    weak var webView: WKWebView?  // 弱引用，避免循环引用
    
    init() {
        super.init()
        // 监听滚动到顶部通知
        scrollToTopObserver = NotificationCenter.default.addObserver(
            forName: .scrollPreviewToTop,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scrollToTop()
        }
    }
    
    private func scrollToTop() {
        guard let webView = webView else { return }
        let js = "window.scrollTo({ top: 0, behavior: 'smooth' });"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}
```

#### 3.3.2 内存管理

- 使用 `weak` 引用避免循环引用
- 在 `deinit` 中移除通知观察者
- 确保 JavaScript 执行在主线程

---

## 4. UI/UX 设计

### 4.1 按钮设计

**位置**：
```
[回到页顶] [视图模式切换]
```

**样式**：
- 使用 `NoteListToolbarButton` 组件保持一致性
- 图标：`arrow.up.to.line`
- 文本：`回到页顶`
- 快捷键：`⌘↑`（可选）

### 4.2 交互反馈

- **点击反馈**：标准按钮高亮效果
- **滚动动画**：平滑滚动，约 300-500ms
- **禁用状态**：按钮灰色，不可点击

### 4.3 响应式设计

- 工具栏宽度变化时，按钮位置自适应
- 按钮大小与其他工具栏按钮一致

---

## 5. 测试计划

### 5.1 功能测试

1. **基本功能**
   - [ ] 在预览模式下，按钮正确显示
   - [ ] 在编辑模式下，按钮正确隐藏
   - [ ] 点击按钮，页面滚动到顶部
   - [ ] 滚动过程平滑，有动画效果

2. **按钮状态**
   - [ ] 有笔记且预览不为空时，按钮启用
   - [ ] 无笔记时，按钮禁用
   - [ ] 预览为空时，按钮禁用

3. **边界情况**
   - [ ] 文档很短（无需滚动）时点击按钮，无错误
   - [ ] 快速连续点击按钮，正常处理
   - [ ] 滚动过程中点击按钮，正常处理

### 5.2 集成测试

1. **与其他功能兼容**
   - [ ] 与视图模式切换功能兼容
   - [ ] 与预览渲染功能兼容
   - [ ] 与内部链接跳转功能兼容

2. **性能测试**
   - [ ] 滚动操作不影响预览性能
   - [ ] 多次点击无性能问题

### 5.3 用户体验测试

1. **易用性**
   - [ ] 按钮位置易于找到
   - [ ] 按钮图标直观易懂
   - [ ] 滚动动画流畅自然

2. **一致性**
   - [ ] 按钮样式与其他工具栏按钮一致
   - [ ] 交互反馈符合系统标准

---

## 6. 验收标准

### 6.1 功能完整性

- ✅ 按钮在预览模式下正确显示
- ✅ 按钮在编辑模式下正确隐藏
- ✅ 点击按钮后页面滚动到顶部
- ✅ 滚动过程平滑，有动画效果
- ✅ 按钮状态正确（启用/禁用）

### 6.2 代码质量

- ✅ 遵循 TCA 状态管理机制
- ✅ 代码结构清晰，易于维护
- ✅ 无内存泄漏（正确管理引用和观察者）
- ✅ 无线程安全问题

### 6.3 用户体验

- ✅ 操作流畅，无卡顿
- ✅ 视觉反馈及时
- ✅ 符合用户习惯

---

## 7. 后续优化（可选）

### 7.1 功能扩展

1. **滚动位置指示器**
   - 显示当前滚动百分比
   - 显示滚动进度条

2. **回到页底按钮**
   - 添加"回到页底"按钮
   - 快速跳转到文档末尾

3. **滚动位置记忆**
   - 记住用户上次滚动位置
   - 重新打开文档时恢复位置

### 7.2 性能优化

1. **滚动检测**
   - 检测是否需要滚动
   - 如果已在顶部，按钮禁用或显示不同状态

2. **动画优化**
   - 根据滚动距离调整动画时长
   - 提供"即时滚动"选项（无动画）

### 7.3 快捷键支持

1. **全局快捷键**
   - 支持 `⌘↑` 快捷键
   - 在预览模式下全局生效

2. **自定义快捷键**
   - 允许用户自定义快捷键
   - 在设置中配置

---

## 8. 风险评估

### 8.1 技术风险

- **风险**：WebView JavaScript 执行失败
- **影响**：滚动功能不工作
- **缓解**：添加错误处理，降级到即时滚动

### 8.2 用户体验风险

- **风险**：按钮位置不明显
- **影响**：用户找不到功能
- **缓解**：使用直观的图标和文本

### 8.3 兼容性风险

- **风险**：与现有功能冲突
- **影响**：功能异常
- **缓解**：充分测试，确保兼容性

---

## 9. 参考资料

- [WKWebView JavaScript 执行文档](https://developer.apple.com/documentation/webkit/wkwebview)
- [TCA 状态管理最佳实践](https://pointfreeco.github.io/swift-composable-architecture/)
- [SwiftUI 工具栏设计指南](https://developer.apple.com/design/human-interface-guidelines/components/menus-and-commands/toolbars/)

---

**文档维护者**: Nota4 开发团队  
**最后更新**: 2025-11-21  
**状态**: ✅ 待实现


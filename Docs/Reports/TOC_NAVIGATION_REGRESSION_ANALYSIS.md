# TOC 导航功能回归分析

**分析日期**: 2025-11-26  
**问题**: 预览模式下 TOC 目录导航又不好使了  
**状态**: 已定位问题，待修复

---

## 问题描述

用户反馈：预览模式下 TOC（目录）的导航又不好使了，之前处理过这个需求。

**症状**：
- TOC 正常渲染
- 链接可以点击
- 但页面不滚动，无法跳转到对应标题

---

## 历史修复记录

### 第一次修复（2025-11-19）

**提交**: `76e5245 fix(preview): 修复 TOC 锚点跳转问题`

**问题原因**：
- WebView 拦截了锚点导航
- 试图用 JavaScript 模拟滚动行为
- JavaScript 执行失败
- 导航已被取消，无法回退到原生行为

**修复方案**：
- 删除复杂的 JavaScript 模拟逻辑（50+ 行代码）
- 使用 WebView 原生锚点导航（3 行代码）
- 修改：`decisionHandler(.cancel)` → `decisionHandler(.allow)`

**修复效果**：
- ✅ 所有场景均通过测试
- ✅ 与 Safari 行为完全一致
- ✅ 代码更简洁、更可靠

**相关文档**: `Docs/Features/Preview/TOC_JUMP_FIX_SUMMARY.md`

### 第二次修改（2025-11-21）

**提交**: `5419e58 修复 Markdown 内部链接跳转问题`

**修改理由**：
- "修复 file:// 协议下 WKWebView 的原生锚点跳转有时会失效或导致刷新"
- "使用 JavaScript scrollIntoView 替代原生跳转"
- "添加模糊匹配支持（精确匹配、URL解码、忽略连字符）"

**修改内容**：
- 将 `decisionHandler(.allow)` 改回 `decisionHandler(.cancel)`
- 重新引入 JavaScript 处理锚点跳转
- 使用 `scrollIntoView` 替代原生跳转
- 添加模糊匹配逻辑

**代码变更**：
```swift
// 修复前（76e5245）
if isInternalAnchor {
    decisionHandler(.allow)  // ✅ 使用原生导航
    return
}

// 修复后（5419e58）
if isInternalAnchor, let fragment = url.fragment {
    // 使用 JavaScript 滚动
    let js = """
    function findTarget(id) {
        // ... 模糊匹配逻辑 ...
    }
    var target = findTarget('\(safeFragment)');
    if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
    """
    webView.evaluateJavaScript(js, completionHandler: nil)
    decisionHandler(.cancel)  // ❌ 取消原生导航
    return
}
```

---

## 问题分析

### 根本原因

**代码回归**：提交 `5419e58` 将修复方案改回了之前有问题的实现方式。

**当前代码问题**：
1. **使用 `decisionHandler(.cancel)`**：取消了 WebView 的原生锚点导航
2. **依赖 JavaScript 执行**：如果 JavaScript 执行失败，没有任何回退机制
3. **时序问题**：JavaScript 执行时机可能不正确
4. **权限问题**：在 Sandbox 环境下，JavaScript 可能受到限制

### 对比分析

| 方案 | 代码行数 | 可靠性 | 维护性 | 问题 |
|------|---------|--------|--------|------|
| **原生导航**（76e5245） | 3 行 | ✅ 高 | ✅ 简单 | 无 |
| **JavaScript 模拟**（5419e58） | 50+ 行 | ❌ 低 | ❌ 复杂 | 执行失败、时序问题 |

### 为什么 JavaScript 方案会失败？

1. **Sandbox 限制**：
   - 在 App Sandbox 环境下，JavaScript 执行可能受到限制
   - `file://` 协议下的 JavaScript 权限可能不同

2. **时序问题**：
   - JavaScript 执行是异步的
   - 在页面完全加载前执行可能失败
   - `evaluateJavaScript` 的 completionHandler 可能不会触发

3. **编码问题**：
   - 中文锚点的编码/解码可能不一致
   - URL fragment 的编码规则可能不同

4. **元素查找失败**：
   - 如果 `findTarget` 找不到元素，不会滚动
   - 模糊匹配可能匹配到错误的元素

---

## 当前代码状态

**文件**: `Nota4/Nota4/Views/Components/WebViewWrapper.swift`

**当前实现**（第 71-124 行）：
```swift
if isInternalAnchor {
    // 使用 JavaScript 处理锚点跳转，确保平滑滚动
    if let fragment = url.fragment {
        // ... 50+ 行 JavaScript 代码 ...
        webView.evaluateJavaScript(script, completionHandler: { result, error in
            if let error = error {
                print("⚠️ [WebView] Failed to scroll to anchor: \(error.localizedDescription)")
            }
        })
    }
    // 取消导航，因为我们用 JavaScript 处理了
    decisionHandler(.cancel)  // ❌ 问题所在
    return
}
```

**问题**：
- 与修复文档中描述的"错误实现"完全一致
- 使用 `decisionHandler(.cancel)` 取消原生导航
- 依赖 JavaScript 执行，没有回退机制

---

## 解决方案建议

### 方案 1：恢复原生导航（推荐）

**理由**：
- 修复文档已经证明原生导航是可靠的
- 代码更简洁（3 行 vs 50+ 行）
- 与 Safari 行为一致
- 不依赖 JavaScript，避免各种问题

**实现**：
```swift
if isInternalAnchor {
    // 让 WebView 使用原生的锚点导航
    decisionHandler(.allow)
    return
}
```

**如果遇到 `file://` 协议问题**：
- 检查是否是 Sandbox 权限问题
- 考虑使用 `loadFileURL` 而不是 `loadHTMLString`
- 确保 `baseURL` 正确设置

### 方案 2：改进 JavaScript 方案（不推荐）

**如果必须使用 JavaScript**：
1. 添加错误处理和回退机制
2. 确保 JavaScript 执行时机正确
3. 添加调试日志
4. 处理各种边界情况

**缺点**：
- 代码复杂
- 维护成本高
- 仍然可能失败

---

## 验证方法

### 1. 导出 HTML 测试

```bash
# 在应用中导出 HTML
# 在 Safari 中打开测试
# 如果 Safari 中能正常跳转，说明 HTML 生成正确
```

### 2. 检查 JavaScript 执行

```swift
webView.evaluateJavaScript(script, completionHandler: { result, error in
    if let error = error {
        print("❌ JavaScript 执行失败: \(error)")
    } else {
        print("✅ JavaScript 执行成功")
    }
})
```

### 3. 检查导航拦截

```swift
if isInternalAnchor {
    print("🔍 检测到内部锚点: \(url.fragment ?? "nil")")
    // 检查 decisionHandler 的调用
}
```

---

## 相关文档

- **修复总结**: `Docs/Features/Preview/TOC_JUMP_FIX_SUMMARY.md`
- **问题分析**: `Docs/Features/Preview/TOC_ANCHOR_LINK_ANALYSIS.md`
- **修复提交**: `76e5245 fix(preview): 修复 TOC 锚点跳转问题`
- **回归提交**: `5419e58 修复 Markdown 内部链接跳转问题`

---

## 结论

**问题根源**：提交 `5419e58` 将之前修复的代码改回了有问题的实现方式。

**建议**：恢复使用原生锚点导航（方案 1），这是经过验证的、可靠的解决方案。

**如果 `file://` 协议确实有问题**：
- 应该先诊断 `file://` 协议的具体问题
- 而不是直接改回 JavaScript 方案
- 可能需要调整 Sandbox 权限或加载方式

---

## 下一步行动

1. ✅ **已完成**：问题分析和定位
2. ⏳ **待执行**：恢复原生导航实现
3. ⏳ **待测试**：验证修复效果
4. ⏳ **待文档**：更新修复文档


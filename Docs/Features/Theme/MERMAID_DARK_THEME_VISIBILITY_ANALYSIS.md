# 深色主题下 Mermaid 图表可视性问题分析

## 问题描述

在预览模式下，当用户选择深色主题时，Mermaid 图表存在以下可视性问题：

1. **流程图线条颜色问题**：部分流程图线条显示为黑色，在深色背景（`#1e1e1e`）下几乎不可见
2. **文字颜色问题**：部分文字显示为黑色，在深色背景下难以识别
3. **对比度不足**：整体图表元素与深色背景的对比度不足，影响可读性

## 问题根源分析

### 1. Mermaid 主题硬编码问题（核心问题）

**位置**：`Nota4/Nota4/Services/MarkdownRenderer.swift` 第 592 行

**当前实现**：
```swift
mermaid.initialize({ 
    startOnLoad: true,
    theme: 'default',  // ❌ 硬编码为 'default'，未使用主题配置
    securityLevel: 'loose',
    // ... 其他配置
});
```

**问题**：
- Mermaid 主题被硬编码为 `'default'`，无论用户选择什么预览主题，都使用默认主题
- `ThemeConfig` 中已经配置了 `mermaidTheme` 属性：
  - 浅色主题：`mermaidTheme: "default"`
  - 深色主题：`mermaidTheme: "dark"` ✅ 已配置但未使用
  - GitHub 主题：`mermaidTheme: "neutral"`
- 导致深色主题下仍然使用 `'default'` 主题，该主题是为浅色背景设计的

### 2. Mermaid 主题特性分析

**Mermaid 内置主题**：
- `default`：为浅色背景设计，使用深色线条和文字
- `dark`：为深色背景设计，使用浅色线条和文字
- `forest`：绿色系主题
- `neutral`：中性主题，适合多种背景

**`default` 主题在深色背景下的问题**：
- 流程图线条：使用深色（接近黑色），在深色背景（`#1e1e1e`）下对比度极低
- 文字颜色：使用深色文字，在深色背景下不可见
- 节点填充：可能使用深色填充，与背景色接近

### 3. 主题配置未被使用

**位置**：`Nota4/Nota4/Models/ThemeConfig+Presets.swift`

**深色主题配置**：
```swift
static let defaultDark = ThemeConfig(
    id: "builtin-dark",
    name: "dark",
    displayName: "深色",
    // ...
    mermaidTheme: "dark",  // ✅ 已配置
    // ...
)
```

**问题**：
- `mermaidTheme` 属性已正确配置为 `"dark"`
- 但在 `MarkdownRenderer.buildFullHTML` 中未读取和使用该配置
- 需要从当前主题的 `ThemeConfig` 中获取 `mermaidTheme` 值

### 4. CSS 样式覆盖不足

**位置**：`Nota4/Nota4/Services/CSSStyles.swift` 第 285-300 行

**当前实现**：
```css
/* Mermaid 图表 */
.mermaid {
    background: #fff;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    padding: 1rem;
    margin: 1rem 0;
    text-align: center;
}

@media (prefers-color-scheme: dark) {
    .mermaid {
        background: #2d2d2d;
        border-color: #404040;
    }
}
```

**问题**：
- CSS 只设置了容器的背景色和边框色
- **没有覆盖 Mermaid SVG 内部的线条和文字颜色**
- Mermaid 图表是通过 SVG 渲染的，线条和文字颜色由 Mermaid 主题控制，CSS 无法直接覆盖
- `@media (prefers-color-scheme: dark)` 只能检测系统主题，不能检测 Nota4 的预览主题

### 5. 主题获取逻辑缺失

**位置**：`Nota4/Nota4/Services/MarkdownRenderer.swift` 的 `buildFullHTML` 方法

**当前实现**：
```swift
private func buildFullHTML(
    content: String,
    toc: String?,
    options: RenderOptions
) async -> String {
    let css = await getCSS(for: options.themeId)
    let codeHighlightCSS = await getCodeHighlightCSS(for: options.themeId)
    // ... 其他 CSS
    
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <!-- CSS -->
    </head>
    <body>
        <!-- 内容 -->
    </body>
    <script>
        mermaid.initialize({ 
            theme: 'default',  // ❌ 硬编码，未获取主题配置
            // ...
        });
    </script>
    </html>
    """
}
```

**问题**：
- 方法中已经获取了主题 CSS（`getCSS`），但没有获取 `ThemeConfig` 对象
- 无法访问 `ThemeConfig.mermaidTheme` 属性
- 需要在方法中获取当前主题的 `ThemeConfig`，然后读取 `mermaidTheme`

## 问题影响范围

### 受影响的图表类型

1. **流程图（Flowchart）**
   - 线条颜色：黑色，在深色背景下不可见
   - 节点文字：黑色，在深色背景下不可见
   - 节点填充：可能使用深色，与背景对比度低

2. **序列图（Sequence Diagram）**
   - 生命线：可能使用深色，在深色背景下不可见
   - 消息箭头：可能使用深色，在深色背景下不可见
   - 参与者标签：可能使用深色文字

3. **甘特图（Gantt Chart）**
   - 时间轴线条：可能使用深色
   - 任务条：可能使用深色填充
   - 文字标签：可能使用深色文字

4. **类图（Class Diagram）**
   - 类框线条：可能使用深色
   - 类名和属性文字：可能使用深色

5. **状态图（State Diagram）**
   - 状态框线条：可能使用深色
   - 状态名称文字：可能使用深色
   - 转换箭头：可能使用深色

6. **其他图表类型**
   - 所有使用 `default` 主题的图表类型都会受到影响

### 受影响的用户场景

1. **深色主题用户**：选择深色预览主题时，所有 Mermaid 图表可视性差
2. **主题切换用户**：从浅色切换到深色主题时，图表不会自动适配
3. **自定义主题用户**：如果自定义主题使用深色背景，也会遇到同样的问题

## 解决方案设计

### 方案1：使用主题配置的 Mermaid 主题（推荐）

**实施步骤**：

1. **在 `buildFullHTML` 方法中获取当前主题的 `ThemeConfig`**：
   ```swift
   private func buildFullHTML(
       content: String,
       toc: String?,
       options: RenderOptions
   ) async -> String {
       // 获取当前主题配置
       let theme: ThemeConfig
       if let themeId = options.themeId {
           let availableThemes = await themeManager.availableThemes
           theme = availableThemes.first(where: { $0.id == themeId }) 
               ?? await themeManager.currentTheme
       } else {
           theme = await themeManager.currentTheme
       }
       
       // 使用主题的 mermaidTheme
       let mermaidTheme = theme.mermaidTheme
       
       // ...
   }
   ```

2. **在 Mermaid 初始化中使用主题配置**：
   ```javascript
   mermaid.initialize({ 
       startOnLoad: true,
       theme: '\(mermaidTheme)',  // ✅ 使用主题配置
       // ...
   });
   ```

**优点**：
- ✅ 完全解决深色主题下的可视性问题
- ✅ 利用现有的主题配置系统
- ✅ 支持所有主题（浅色、深色、GitHub、Notion 等）
- ✅ 实现简单，只需修改一处代码

**缺点**：
- 无

### 方案2：动态检测背景色并切换主题

**实施步骤**：

1. **在 JavaScript 中检测页面背景色**：
   ```javascript
   function getMermaidTheme() {
       const body = document.body;
       const bgColor = window.getComputedStyle(body).backgroundColor;
       // 解析 RGB 值，判断是否为深色背景
       const isDark = isDarkBackground(bgColor);
       return isDark ? 'dark' : 'default';
   }
   
   mermaid.initialize({ 
       theme: getMermaidTheme(),
       // ...
   });
   ```

**优点**：
- ✅ 自动适配背景色
- ✅ 不依赖主题配置

**缺点**：
- ❌ 实现复杂，需要解析 CSS 颜色
- ❌ 可能误判（如果背景色不是纯黑/纯白）
- ❌ 与现有的主题系统不一致

### 方案3：使用 CSS 变量覆盖 Mermaid 样式

**实施步骤**：

1. **在主题 CSS 中定义 Mermaid 颜色变量**：
   ```css
   :root {
       --mermaid-line-color: #333;
       --mermaid-text-color: #333;
   }
   
   [data-theme="builtin-dark"] {
       --mermaid-line-color: #e0e0e0;
       --mermaid-text-color: #e0e0e0;
   }
   ```

2. **使用 CSS 覆盖 Mermaid SVG 样式**：
   ```css
   .mermaid svg path {
       stroke: var(--mermaid-line-color) !important;
   }
   
   .mermaid svg text {
       fill: var(--mermaid-text-color) !important;
   }
   ```

**优点**：
- ✅ 可以精确控制颜色
- ✅ 与主题系统集成

**缺点**：
- ❌ Mermaid 使用 SVG，CSS 覆盖可能不完整
- ❌ 需要覆盖大量选择器（路径、文字、填充等）
- ❌ 维护成本高，Mermaid 更新可能破坏样式
- ❌ 可能与其他 Mermaid 配置冲突

## 推荐方案

**采用方案1**：使用主题配置的 Mermaid 主题

**理由**：
1. **最简单有效**：只需修改一处代码，使用现有的主题配置
2. **完全解决问题**：深色主题使用 `dark` 主题，浅色主题使用 `default` 主题
3. **符合现有架构**：与主题系统一致，易于维护
4. **支持所有主题**：GitHub 主题使用 `neutral`，Notion 主题使用 `default`，都能正确显示

## 实施细节

### 需要修改的文件

1. **`Nota4/Nota4/Services/MarkdownRenderer.swift`**
   - 修改 `buildFullHTML` 方法
   - 获取当前主题的 `ThemeConfig`
   - 在 Mermaid 初始化中使用 `theme.mermaidTheme`

### 代码修改示例

```swift
private func buildFullHTML(
    content: String,
    toc: String?,
    options: RenderOptions
) async -> String {
    let css = await getCSS(for: options.themeId)
    let codeHighlightCSS = await getCodeHighlightCSS(for: options.themeId)
    let imageErrorCSS = getImageErrorCSS()
    
    // 获取当前主题配置
    let theme: ThemeConfig
    if let themeId = options.themeId {
        let availableThemes = await themeManager.availableThemes
        theme = availableThemes.first(where: { $0.id == themeId }) 
            ?? await themeManager.currentTheme
    } else {
        theme = await themeManager.currentTheme
    }
    
    // 使用主题的 Mermaid 主题配置
    let mermaidTheme = theme.mermaidTheme
    
    return """
    <!DOCTYPE html>
    <html lang="zh-CN">
    <head>
        <!-- ... -->
    </head>
    <body>
        <!-- ... -->
    </body>
    <script>
        // 初始化 Mermaid - 使用主题配置
        mermaid.initialize({ 
            startOnLoad: true,
            theme: '\(mermaidTheme)',  // ✅ 使用主题配置
            securityLevel: 'loose',
            // ... 其他配置保持不变
        });
        
        // ... 其他脚本
    </script>
    </html>
    """
}
```

## 测试建议

### 测试场景

1. **深色主题测试**：
   - 选择深色预览主题
   - 创建包含流程图的笔记
   - 验证流程图线条和文字在深色背景下清晰可见

2. **浅色主题测试**：
   - 选择浅色预览主题
   - 验证流程图在浅色背景下正常显示

3. **主题切换测试**：
   - 在预览模式下切换主题
   - 验证 Mermaid 图表自动适配新主题

4. **多种图表类型测试**：
   - 流程图（Flowchart）
   - 序列图（Sequence Diagram）
   - 甘特图（Gantt Chart）
   - 类图（Class Diagram）
   - 状态图（State Diagram）

5. **自定义主题测试**：
   - 如果用户创建了自定义主题，验证 Mermaid 主题配置是否正确应用

## 预期效果

实施后，深色主题下的 Mermaid 图表将：

1. **流程图线条**：使用浅色线条（白色/浅灰色），在深色背景下清晰可见
2. **文字颜色**：使用浅色文字（白色/浅灰色），在深色背景下清晰可读
3. **节点填充**：使用适合深色背景的填充色，与背景对比度足够
4. **整体可视性**：所有图表元素在深色背景下都有足够的对比度，符合 WCAG AA 级标准（≥4.5:1）

## 总结

**问题根源**：Mermaid 主题被硬编码为 `'default'`，未使用 `ThemeConfig` 中的 `mermaidTheme` 配置，导致深色主题下图表可视性差。

**解决方案**：在 `buildFullHTML` 方法中获取当前主题的 `ThemeConfig`，使用 `theme.mermaidTheme` 配置 Mermaid 主题。

**实施难度**：低（只需修改一处代码）

**预期效果**：完全解决深色主题下 Mermaid 图表的可视性问题




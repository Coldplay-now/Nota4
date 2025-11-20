# 任务列表交互式复选框功能需求分析

**文档创建时间**: 2025-11-20T09:31:01Z  
**需求类型**: 编辑器交互功能增强  
**优先级**: 中高  
**状态**: 需求分析阶段

---

## 一、需求概述

### 1.1 功能描述

在 Markdown 编辑器的编辑模式下，为任务列表项（Task List Items）添加交互式复选框功能，允许用户通过鼠标点击来切换任务项的完成/未完成状态，而无需手动编辑 Markdown 文本。

### 1.2 用户场景

**场景 1：快速标记任务完成**
- 用户在编辑器中创建了一个任务列表：
  ```markdown
  - [ ] 完成项目文档
  - [ ] 代码审查
  - [ ] 部署到生产环境
  ```
- 用户完成第一个任务后，希望快速标记为已完成
- **当前方式**：需要手动将 `[ ]` 改为 `[x]`
- **期望方式**：点击复选框，自动切换状态

**场景 2：批量管理任务**
- 用户在编辑一个包含多个任务列表的文档
- 需要频繁切换任务状态
- **期望**：通过点击复选框快速切换，提高编辑效率

**场景 3：视觉反馈**
- 用户希望看到任务列表的视觉状态（已完成/未完成）
- **期望**：在编辑模式下也能看到复选框的视觉状态

---

## 二、技术实现分析

### 2.1 当前架构

**编辑器实现**：
- `MarkdownTextEditor`: 基于 `NSTextView` 的 SwiftUI 包装器
- 使用 `NSViewRepresentable` 桥接 SwiftUI 和 AppKit
- 支持文本编辑、选择、搜索高亮等功能
- 已有任务列表插入功能（`insertTaskList`）

**任务列表格式**：
- 未完成：`- [ ] 任务内容` 或 `* [ ] 任务内容`
- 已完成：`- [x] 任务内容` 或 `* [x] 任务内容`
- 支持空格和 `x`（不区分大小写）

### 2.2 实现方案分析

#### 方案 A：文本属性 + 点击检测（推荐）

**核心思路**：
1. 使用 `NSTextView` 的 `textStorage` 为任务列表项添加自定义属性
2. 在文本渲染时，为 `[ ]` 和 `[x]` 区域添加可点击的附件（Attachment）
3. 检测鼠标点击位置，判断是否点击在复选框区域
4. 切换文本内容（`[ ]` ↔ `[x]`）

**优点**：
- ✅ 与现有架构兼容性好
- ✅ 可以精确控制点击区域
- ✅ 支持视觉反馈（复选框样式）
- ✅ 不影响文本编辑功能

**缺点**：
- ⚠️ 需要处理文本更新和属性同步
- ⚠️ 需要处理光标位置和选择范围

**技术要点**：
- 使用 `NSTextAttachment` 或自定义 `NSLayoutManager` 绘制复选框
- 重写 `mouseDown` 或使用 `NSTextView` 的点击检测
- 使用正则表达式匹配任务列表项

#### 方案 B：覆盖层（Overlay）方案

**核心思路**：
1. 在 `NSTextView` 上方添加一个透明的覆盖层（Overlay View）
2. 计算任务列表项的位置，在覆盖层上绘制复选框
3. 检测覆盖层的点击事件，切换任务状态

**优点**：
- ✅ 实现相对简单
- ✅ 不影响文本编辑逻辑

**缺点**：
- ❌ 需要精确计算文本位置（滚动、换行等）
- ❌ 文本更新时需要同步更新覆盖层
- ❌ 可能影响文本选择和高亮
- ❌ 性能开销较大（需要实时计算位置）

#### 方案 C：自定义 NSTextView 子类

**核心思路**：
1. 创建 `TaskListTextView` 继承自 `NSTextView`
2. 重写 `mouseDown`、`draw` 等方法
3. 在文本渲染时直接绘制复选框

**优点**：
- ✅ 完全控制渲染和交互
- ✅ 性能最优

**缺点**：
- ❌ 需要大量自定义代码
- ❌ 维护成本高
- ❌ 可能与现有功能冲突

---

## 三、推荐实现方案（方案 A）

### 3.1 架构设计

```
MarkdownTextEditor
├── NSTextView
│   ├── NSTextStorage (文本存储)
│   │   └── 任务列表属性标记
│   ├── NSLayoutManager (布局管理)
│   │   └── 复选框绘制逻辑
│   └── NSTextContainer (文本容器)
└── Coordinator
    ├── 任务列表检测
    ├── 点击事件处理
    └── 文本更新逻辑
```

### 3.2 实现步骤

#### 步骤 1：任务列表检测

**功能**：识别文本中的任务列表项

**实现**：
- 使用正则表达式匹配任务列表项
- 模式：`^(\s*)([-*])\s+\[([ xX])\]\s+(.+)$`
- 捕获组：
  1. 缩进空格
  2. 列表标记（`-` 或 `*`）
  3. 复选框状态（` ` 或 `x`/`X`）
  4. 任务内容

**代码示例**：
```swift
private func detectTaskListItems(in text: String) -> [TaskListItem] {
    let pattern = #"^(\s*)([-*])\s+\[([ xX])\]\s+(.+)$"#
    let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
    // ... 匹配逻辑
}
```

#### 步骤 2：添加文本属性

**功能**：为任务列表项添加自定义属性，标记复选框位置

**实现**：
- 使用 `NSTextStorage` 的 `addAttribute(_:value:range:)` 方法
- 自定义属性：`.taskListCheckbox`（类型：`TaskListCheckboxAttribute`）
- 属性值包含：复选框位置、状态、行号等信息

**代码示例**：
```swift
struct TaskListCheckboxAttribute {
    let range: NSRange
    let isChecked: Bool
    let lineNumber: Int
    let checkboxRange: NSRange  // [ ] 或 [x] 的范围
}

// 在 textStorage 中添加属性
textStorage.addAttribute(
    .taskListCheckbox,
    value: checkboxAttribute,
    range: checkboxRange
)
```

#### 步骤 3：复选框渲染

**功能**：在文本中绘制可交互的复选框

**实现方式 A：使用 NSTextAttachment**
- 创建自定义 `NSTextAttachment` 子类
- 重写 `attachmentCell` 返回自定义 `NSCell`
- 在 `NSCell` 中绘制复选框

**实现方式 B：使用 NSLayoutManager 自定义绘制**
- 重写 `NSLayoutManager` 的 `drawGlyphs(forGlyphRange:at:)` 方法
- 检测任务列表属性，在相应位置绘制复选框
- 使用 `NSBezierPath` 或系统图标绘制

**推荐**：方式 B（更灵活，性能更好）

**代码示例**：
```swift
class TaskListLayoutManager: NSLayoutManager {
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint) {
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        
        // 检测任务列表属性并绘制复选框
        enumerateTaskListCheckboxes(in: glyphsToShow) { checkbox, rect in
            drawCheckbox(at: rect, isChecked: checkbox.isChecked)
        }
    }
    
    private func drawCheckbox(at rect: NSRect, isChecked: Bool) {
        // 绘制复选框
        let checkboxRect = NSRect(x: rect.minX, y: rect.minY, width: 16, height: 16)
        // ... 绘制逻辑
    }
}
```

#### 步骤 4：点击检测

**功能**：检测用户是否点击了复选框区域

**实现**：
- 重写 `NSTextView` 的 `mouseDown(with:)` 方法
- 将点击位置转换为文本位置（glyph index）
- 检查该位置是否有任务列表属性
- 计算复选框的精确位置（考虑文本对齐、缩进等）
- 判断点击是否在复选框区域内

**代码示例**：
```swift
override func mouseDown(with event: NSEvent) {
    let location = convert(event.locationInWindow, from: nil)
    let textLocation = locationOfText(at: location)
    
    // 检查是否有任务列表属性
    if let checkboxAttribute = textStorage.attribute(
        .taskListCheckbox,
        at: textLocation,
        effectiveRange: nil
    ) as? TaskListCheckboxAttribute {
        
        // 计算复选框的精确位置
        let checkboxRect = rectForCheckbox(at: checkboxAttribute.checkboxRange)
        
        // 判断点击是否在复选框区域内
        if checkboxRect.contains(location) {
            toggleTaskListCheckbox(at: checkboxAttribute.checkboxRange)
            return
        }
    }
    
    // 不在复选框区域，执行默认行为
    super.mouseDown(with: event)
}
```

#### 步骤 5：状态切换

**功能**：切换任务列表项的完成状态

**实现**：
- 找到复选框文本范围（`[ ]` 或 `[x]`）
- 切换文本内容：
  - `[ ]` → `[x]`
  - `[x]` → `[ ]`
- 更新文本存储
- 触发文本变化通知（更新绑定）

**代码示例**：
```swift
private func toggleTaskListCheckbox(at range: NSRange) {
    guard let textStorage = textView.textStorage else { return }
    
    let currentText = (textStorage.string as NSString).substring(with: range)
    let newText: String
    
    if currentText.contains("[ ]") {
        newText = currentText.replacingOccurrences(of: "[ ]", with: "[x]")
    } else if currentText.contains("[x]") || currentText.contains("[X]") {
        newText = currentText.replacingOccurrences(of: "[xX]", with: " ", options: .regularExpression)
        newText = newText.replacingOccurrences(of: "[", with: "[")
        newText = newText.replacingOccurrences(of: "]", with: "]")
        // 简化为：
        newText = currentText.replacingOccurrences(of: "[x]", with: "[ ]")
            .replacingOccurrences(of: "[X]", with: "[ ]")
    } else {
        return
    }
    
    // 执行文本替换（支持撤销）
    textStorage.beginEditing()
    textStorage.replaceCharacters(in: range, with: newText)
    textStorage.endEditing()
    
    // 通知文本变化
    textDidChange(Notification(name: .init("TextDidChange")))
}
```

### 3.3 关键技术点

#### 3.3.1 文本位置计算

**问题**：如何将点击位置转换为文本中的字符位置？

**解决方案**：
```swift
func locationOfText(at point: NSPoint) -> Int {
    guard let layoutManager = textView.layoutManager,
          let textContainer = textView.textContainer else {
        return NSNotFound
    }
    
    // 考虑文本容器的偏移
    let containerOrigin = textView.textContainerOrigin
    let locationInContainer = NSPoint(
        x: point.x - containerOrigin.x,
        y: point.y - containerOrigin.y
    )
    
    // 转换为字符索引
    let fractionOfDistance: CGFloat = 0
    let characterIndex = layoutManager.characterIndex(
        for: locationInContainer,
        in: textContainer,
        fractionOfDistanceThroughGlyph: &fractionOfDistance
    )
    
    return characterIndex
}
```

#### 3.3.2 复选框位置计算

**问题**：如何计算复选框在视图中的精确位置？

**解决方案**：
```swift
func rectForCheckbox(at range: NSRange) -> NSRect {
    guard let layoutManager = textView.layoutManager,
          let textContainer = textView.textContainer else {
        return .zero
    }
    
    // 获取复选框文本的 glyph range
    let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
    
    // 获取第一个 glyph 的位置
    var glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    
    // 考虑文本容器的偏移
    let containerOrigin = textView.textContainerOrigin
    glyphRect.origin.x += containerOrigin.x
    glyphRect.origin.y += containerOrigin.y
    
    // 复选框通常位于行的开始位置，需要调整
    // 考虑缩进、字体大小等
    
    return glyphRect
}
```

#### 3.3.3 文本更新与撤销支持

**问题**：如何确保文本更新支持撤销（Undo）功能？

**解决方案**：
- 使用 `NSTextView` 的 `shouldChangeText(in:replacementString:)` 方法
- 或者使用 `NSUndoManager` 手动注册撤销操作

```swift
private func toggleTaskListCheckbox(at range: NSRange) {
    guard let textView = self.textView,
          let textStorage = textView.textStorage else { return }
    
    let currentText = (textStorage.string as NSString).substring(with: range)
    let newText = currentText.contains("[ ]") ? "[x]" : "[ ]"
    
    // 使用 shouldChangeText 确保支持撤销
    if textView.shouldChangeText(in: range, replacementString: newText) {
        textStorage.replaceCharacters(in: range, with: newText)
        textView.didChangeText()
    }
}
```

#### 3.3.4 多行任务列表处理

**问题**：如何处理跨行的任务列表项？

**解决方案**：
- 任务列表项通常以换行符结束
- 使用正则表达式的 `anchorsMatchLines` 选项
- 只匹配单行内的任务列表项

```swift
let pattern = #"^(\s*)([-*])\s+\[([ xX])\]\s+(.+)$"#
let regex = try? NSRegularExpression(
    pattern: pattern,
    options: [.anchorsMatchLines]  // 每行独立匹配
)
```

---

## 四、用户交互设计

### 4.1 视觉设计

#### 复选框样式

**未完成状态**：
- 显示为空的方框：`☐` 或使用系统绘制
- 颜色：与文本颜色一致或稍浅
- 大小：与行高匹配（建议 16x16 或 18x18 点）

**已完成状态**：
- 显示为带勾选的方框：`☑` 或使用系统绘制
- 颜色：可以使用主题色或与文本颜色一致
- 可以添加删除线效果（可选）

**悬停效果**：
- 鼠标悬停时，复选框可以高亮显示
- 可以使用背景色或边框高亮

#### 点击区域

**推荐尺寸**：
- 复选框本身：16x16 或 18x18 点
- 点击热区：20x20 或 22x22 点（增加容错性）

**对齐方式**：
- 与文本基线对齐
- 考虑缩进和列表标记的位置

### 4.2 交互行为

#### 点击行为

1. **单击复选框**：
   - 切换完成状态
   - 保持光标位置不变（如果光标在任务项内）
   - 支持撤销（⌘Z）

2. **点击任务内容**：
   - 正常文本编辑行为
   - 不影响复选框状态

3. **拖拽选择**：
   - 如果选择范围包含复选框，正常文本选择
   - 不影响复选框状态

#### 键盘支持（可选增强）

- `Space` 键：如果光标在任务列表项内，切换复选框状态
- `Tab` 键：缩进任务列表项（保持现有行为）

### 4.3 边界情况处理

#### 情况 1：任务列表格式不标准

**问题**：用户手动输入了不标准的格式，如 `- [ x ]`（有空格）

**处理**：
- 只处理标准格式：`- [ ]` 和 `- [x]`
- 非标准格式不显示交互式复选框
- 或者尝试规范化格式（需要谨慎）

#### 情况 2：嵌套任务列表

**问题**：任务列表项内部包含子列表

**处理**：
- 只处理最外层的任务列表项
- 或者支持多层嵌套（复杂度较高）

#### 情况 3：任务列表在代码块中

**问题**：代码块中包含任务列表格式的文本

**处理**：
- 使用现有的代码块检测逻辑
- 排除代码块内的任务列表项

#### 情况 4：快速连续点击

**问题**：用户快速连续点击复选框

**处理**：
- 添加防抖（Debounce）机制
- 或者使用状态锁，防止重复切换

---

## 五、实现难点与风险

### 5.1 技术难点

#### 难点 1：文本位置精确计算

**问题**：
- `NSTextView` 的文本布局受多种因素影响（字体、行高、缩进等）
- 需要精确计算复选框的位置和大小

**解决方案**：
- 使用 `NSLayoutManager` 的 `boundingRect(forGlyphRange:in:)` 方法
- 考虑文本容器的偏移和滚动位置
- 进行充分的测试，覆盖各种字体和字号

#### 难点 2：文本更新与属性同步

**问题**：
- 文本更新后，需要重新检测任务列表项
- 需要更新文本属性，保持复选框状态

**解决方案**：
- 在 `textDidChange` 中重新检测任务列表项
- 使用增量更新，只更新变化的部分
- 考虑性能优化（大量文本时）

#### 难点 3：与现有功能兼容

**问题**：
- 需要与搜索高亮、文本选择等功能兼容
- 不能影响正常的文本编辑

**解决方案**：
- 仔细设计点击检测逻辑，避免误触发
- 确保复选框区域不影响文本选择
- 充分测试各种编辑场景

### 5.2 性能考虑

#### 性能优化点

1. **任务列表检测**：
   - 使用正则表达式缓存
   - 增量检测（只检测变化的部分）
   - 异步处理（如果文本很大）

2. **属性更新**：
   - 批量更新属性，减少 `beginEditing`/`endEditing` 调用
   - 只在可见区域更新属性

3. **渲染优化**：
   - 只在可见区域绘制复选框
   - 使用缓存避免重复计算位置

### 5.3 风险点

#### 风险 1：文本同步问题

**风险**：文本更新后，复选框状态不同步

**缓解措施**：
- 在 `textDidChange` 中重新检测
- 添加单元测试验证同步逻辑

#### 风险 2：用户体验问题

**风险**：点击区域太小，用户难以点击

**缓解措施**：
- 增加点击热区大小
- 添加视觉反馈（悬停效果）
- 用户测试验证

#### 风险 3：兼容性问题

**风险**：与现有功能冲突

**缓解措施**：
- 充分测试各种场景
- 提供开关选项（可选功能）
- 渐进式实现，先实现基础功能

---

## 六、实现计划

### 6.1 阶段划分

#### 阶段 1：基础功能（MVP）

**目标**：实现基本的复选框切换功能

**任务**：
1. 实现任务列表检测逻辑
2. 实现点击检测和状态切换
3. 基础视觉反馈（简单的复选框绘制）

**预计时间**：2-3 天

#### 阶段 2：视觉优化

**目标**：优化复选框的视觉效果

**任务**：
1. 优化复选框绘制（使用系统样式）
2. 添加悬停效果
3. 优化对齐和间距

**预计时间**：1-2 天

#### 阶段 3：边界情况处理

**目标**：处理各种边界情况

**任务**：
1. 处理嵌套列表
2. 处理代码块中的任务列表
3. 处理格式不标准的情况
4. 性能优化

**预计时间**：2-3 天

#### 阶段 4：测试与优化

**目标**：充分测试和优化

**任务**：
1. 单元测试
2. 集成测试
3. 用户测试
4. 性能测试

**预计时间**：1-2 天

### 6.2 文件结构

```
Nota4/Nota4/Features/Editor/
├── MarkdownTextEditor.swift (现有)
│   └── 添加任务列表相关逻辑
├── TaskListDetector.swift (新建)
│   └── 任务列表检测逻辑
├── TaskListLayoutManager.swift (新建)
│   └── 复选框绘制逻辑
└── TaskListCheckboxAttribute.swift (新建)
    └── 自定义文本属性定义
```

---

## 七、测试计划

### 7.1 功能测试

#### 测试用例 1：基本切换功能

**步骤**：
1. 创建包含任务列表的文档
2. 点击未完成的复选框
3. 验证状态切换为已完成
4. 再次点击，验证切换回未完成

**预期结果**：
- 复选框状态正确切换
- 文本内容正确更新（`[ ]` ↔ `[x]`）
- 支持撤销操作

#### 测试用例 2：多种格式支持

**测试内容**：
- `- [ ]` 格式
- `* [ ]` 格式
- `- [x]` 格式
- `- [X]` 格式（大写 X）

**预期结果**：
- 所有格式都能正确识别和切换

#### 测试用例 3：边界情况

**测试内容**：
- 嵌套任务列表
- 代码块中的任务列表格式
- 格式不标准的任务列表
- 空任务列表项
- 超长任务列表项

**预期结果**：
- 正确处理各种边界情况
- 不出现崩溃或异常行为

### 7.2 性能测试

#### 测试场景

1. **大量任务列表**：
   - 创建包含 100+ 任务列表项的文档
   - 测试检测和渲染性能

2. **频繁切换**：
   - 快速连续点击复选框
   - 测试响应速度和稳定性

3. **大文档**：
   - 在包含大量文本的文档中测试
   - 验证不影响整体性能

### 7.3 兼容性测试

#### 测试内容

1. **与搜索功能兼容**：
   - 搜索任务列表项
   - 高亮显示不影响复选框

2. **与文本选择兼容**：
   - 选择包含任务列表的文本
   - 复制粘贴任务列表

3. **与撤销功能兼容**：
   - 切换复选框后撤销
   - 多次撤销和重做

---

## 八、可选增强功能

### 8.1 键盘快捷键

- `Space` 键：切换当前行的任务列表状态
- `⌘K`：切换选中行的任务列表状态

### 8.2 批量操作

- 选择多个任务列表项，批量切换状态
- 右键菜单：全部完成/全部未完成

### 8.3 视觉增强

- 已完成任务添加删除线效果
- 使用主题色高亮已完成任务
- 动画效果（切换时的过渡动画）

### 8.4 统计功能

- 显示任务完成进度（如：3/5 已完成）
- 在状态栏显示任务统计

---

## 九、总结

### 9.1 核心价值

1. **提升用户体验**：无需手动编辑 Markdown 文本，提高编辑效率
2. **视觉反馈**：在编辑模式下也能看到任务状态
3. **符合直觉**：符合用户对复选框的交互预期

### 9.2 技术可行性

✅ **可行性高**：
- 基于现有的 `NSTextView` 架构
- 使用标准的 AppKit API
- 不需要大幅修改现有代码

### 9.3 实现建议

1. **采用方案 A**（文本属性 + 点击检测）
2. **分阶段实现**：先实现 MVP，再逐步优化
3. **充分测试**：覆盖各种边界情况
4. **性能优化**：注意大量文本时的性能

### 9.4 后续优化方向

1. 支持键盘快捷键
2. 支持批量操作
3. 添加视觉增强效果
4. 支持任务统计功能

---

**文档状态**: ✅ 需求分析完成  
**下一步**: 等待开发团队评估和确认  
**预计开始时间**: 待定


# 有序列表层级缩进功能设计

> **设计日期**: 2025-11-19 16:23:56  
> **功能**: 有序列表 Tab 键缩进和层级序号自动转换  
> **状态**: 设计阶段

---

## 📋 需求概述

在编辑模式下，当用户在有序列表项中按 Tab 键时，应该：
1. 增加列表项的缩进层级
2. 自动将序号从数字转换为对应层级的格式（如 a. b. c.）
3. 支持 Shift+Tab 减少缩进层级
4. 保持 TCA 状态管理机制

---

## 🎯 设计目标

### 功能目标
- ✅ 支持 Tab 键增加缩进
- ✅ 支持 Shift+Tab 减少缩进
- ✅ 自动转换序号格式（1. → a. → i. → A. → I.）
- ✅ 保持列表项的连续性
- ✅ 支持多行列表项的批量缩进

### 技术目标
- ✅ 遵循 TCA 状态管理规范
- ✅ 支持 undo/redo
- ✅ 不影响其他编辑功能
- ✅ 性能优化，响应迅速

---

## 🔍 设计思路分析

### 方案1：标准 Markdown 层级序号（推荐）

**序号规则**：
- **第1层（0个缩进）**: `1. 2. 3. ...` (阿拉伯数字)
- **第2层（2个空格）**: `a. b. c. ...` (小写字母)
- **第3层（4个空格）**: `i. ii. iii. ...` (小写罗马数字)
- **第4层（6个空格）**: `A. B. C. ...` (大写字母)
- **第5层（8个空格）**: `I. II. III. ...` (大写罗马数字)

**优点**：
- 符合 Markdown 规范
- 层级清晰，易于识别
- 与大多数 Markdown 渲染器兼容

**缺点**：
- 需要实现罗马数字转换
- 层级较深时序号可能较长

**示例**：
```markdown
1. 第一项
2. 第二项
   a. 子项 2.1
   b. 子项 2.2
      i. 子项 2.2.1
      ii. 子项 2.2.2
   c. 子项 2.3
3. 第三项
```

---

### 方案2：简化层级序号

**序号规则**：
- **第1层**: `1. 2. 3. ...` (阿拉伯数字)
- **第2层**: `a. b. c. ...` (小写字母)
- **第3层**: `i. ii. iii. ...` (小写罗马数字)
- **第4层及以上**: 循环使用小写字母

**优点**：
- 实现简单
- 层级不会过深

**缺点**：
- 第4层及以上可能混淆

---

### 方案3：嵌套序号（如 1.1, 1.2）

**序号规则**：
- **第1层**: `1. 2. 3. ...`
- **第2层**: `1.1 1.2 1.3 ...` 或 `2.1 2.2 2.3 ...`
- **第3层**: `1.1.1 1.1.2 ...`

**优点**：
- 序号有明确的层级关系
- 易于理解

**缺点**：
- 不符合标准 Markdown 规范
- 序号可能很长
- 缩进时序号需要重新计算

---

## ✅ 推荐方案：方案1（标准 Markdown 层级序号）

### 理由
1. **符合标准**：遵循 Markdown 规范，兼容性好
2. **层级清晰**：不同格式的序号易于区分层级
3. **用户体验**：符合用户对 Markdown 编辑器的预期

---

## 🏗️ 技术实现设计

### 1. 缩进检测和计算

#### 1.1 检测当前行的缩进层级

```swift
/// 检测行的缩进层级
func detectIndentLevel(line: String) -> Int {
    var indentCount = 0
    var index = line.startIndex
    
    while index < line.endIndex {
        if line[index] == " " {
            indentCount += 1
            index = line.index(after: index)
        } else if line[index] == "\t" {
            // Tab 键通常等于 4 个空格
            indentCount += 4
            index = line.index(after: index)
        } else {
            break
        }
    }
    
    // 每 2 个空格为一个层级（Markdown 标准）
    return indentCount / 2
}
```

#### 1.2 计算目标层级

```swift
/// 计算 Tab/Shift+Tab 后的目标层级
func calculateTargetLevel(currentLevel: Int, isShiftPressed: Bool) -> Int {
    if isShiftPressed {
        // Shift+Tab: 减少缩进
        return max(0, currentLevel - 1)
    } else {
        // Tab: 增加缩进
        return min(5, currentLevel + 1)  // 最多5层
    }
}
```

---

### 2. 序号格式转换

#### 2.1 序号格式枚举

```swift
enum ListNumberStyle {
    case arabic(Int)        // 1, 2, 3, ...
    case lowercaseLetter(Int) // a, b, c, ... (1-based: a=1, b=2, ...)
    case lowercaseRoman(Int)  // i, ii, iii, ... (1-based)
    case uppercaseLetter(Int) // A, B, C, ... (1-based)
    case uppercaseRoman(Int)  // I, II, III, ... (1-based)
    
    /// 根据层级获取序号样式
    static func style(for level: Int) -> ListNumberStyle.Type {
        switch level {
        case 0: return arabic
        case 1: return lowercaseLetter
        case 2: return lowercaseRoman
        case 3: return uppercaseLetter
        case 4: return uppercaseRoman
        default: return lowercaseLetter  // 超过5层，循环使用小写字母
        }
    }
    
    /// 转换为字符串格式
    func toString() -> String {
        switch self {
        case .arabic(let n):
            return "\(n)."
        case .lowercaseLetter(let n):
            return "\(Character(UnicodeScalar(96 + n)!))."  // a=97, b=98, ...
        case .lowercaseRoman(let n):
            return "\(romanNumeral(n, uppercase: false))."
        case .uppercaseLetter(let n):
            return "\(Character(UnicodeScalar(64 + n)!))."  // A=65, B=66, ...
        case .uppercaseRoman(let n):
            return "\(romanNumeral(n, uppercase: true))."
        }
    }
}
```

#### 2.2 罗马数字转换

```swift
/// 将数字转换为罗马数字
func romanNumeral(_ number: Int, uppercase: Bool) -> String {
    guard number > 0 && number < 4000 else {
        return "\(number)"  // 超出范围，返回原数字
    }
    
    let values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
    let symbols = uppercase 
        ? ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        : ["m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i"]
    
    var result = ""
    var remaining = number
    
    for (index, value) in values.enumerated() {
        let count = remaining / value
        if count > 0 {
            result += String(repeating: symbols[index], count: count)
            remaining -= value * count
        }
    }
    
    return result
}
```

---

### 3. 列表项序号计算

#### 3.1 检测同级列表项

```swift
/// 检测当前列表项在同级中的序号
func detectListNumber(
    text: String,
    currentLineIndex: Int,
    indentLevel: Int
) -> Int {
    let lines = text.components(separatedBy: .newlines)
    var number = 1
    
    // 向前查找，找到第一个同级或更高级的列表项
    for i in stride(from: currentLineIndex - 1, through: 0, by: -1) {
        let line = lines[i]
        let lineIndent = detectIndentLevel(line: line)
        
        if lineIndent < indentLevel {
            // 找到了更高级的列表项，停止查找
            break
        } else if lineIndent == indentLevel {
            // 找到了同级列表项，提取序号并递增
            if let listNumber = extractListNumber(from: line) {
                number = listNumber + 1
                break
            }
        }
    }
    
    return number
}
```

#### 3.2 提取列表序号

```swift
/// 从列表行中提取序号
func extractListNumber(from line: String) -> Int? {
    // 移除前导空格
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    
    // 匹配有序列表：数字. 或 字母. 或 罗马数字.
    if let match = trimmed.range(of: #"^(\d+|[a-z]|[A-Z]|[ivxlcdm]+)\.\s"#, options: .regularExpression) {
        let numberStr = String(trimmed[..<match.upperBound].dropLast(2))
        
        // 尝试解析为数字
        if let number = Int(numberStr) {
            return number
        }
        
        // 尝试解析为字母
        if numberStr.count == 1, let char = numberStr.first {
            if char.isLowercase {
                return Int(char.asciiValue! - 96)  // a=1, b=2, ...
            } else if char.isUppercase {
                return Int(char.asciiValue! - 64)  // A=1, B=2, ...
            }
        }
        
        // 尝试解析为罗马数字
        if let roman = parseRomanNumeral(numberStr) {
            return roman
        }
    }
    
    return nil
}
```

---

### 4. Tab 键处理逻辑

#### 4.1 拦截 Tab 键

```swift
func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    // 拦截 Tab 键
    if commandSelector == #selector(NSTextView.insertTab(_:)) {
        return handleTabKey(textView: textView, isShiftPressed: false)
    }
    // 拦截 Shift+Tab 键
    if commandSelector == #selector(NSTextView.insertBacktab(_:)) {
        return handleTabKey(textView: textView, isShiftPressed: true)
    }
    // 拦截回车键（已有实现）
    if commandSelector == #selector(NSTextView.insertNewline(_:)) {
        return handleEnterKey(textView: textView)
    }
    return false
}
```

#### 4.2 处理 Tab 键

```swift
private func handleTabKey(textView: NSTextView, isShiftPressed: Bool) -> Bool {
    let text = textView.string
    let selection = textView.selectedRange()
    
    // 获取当前行
    let nsText = text as NSString
    let lineRange = nsText.lineRange(for: selection)
    let lineText = nsText.substring(with: lineRange)
    
    // 检测是否是列表项
    guard let listInfo = detectListType(line: lineText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
        // 不是列表项，执行默认 Tab 行为（插入制表符或空格）
        return false
    }
    
    // 只处理有序列表
    guard case .ordered(let currentNumber) = listInfo else {
        // 无序列表或任务列表，执行默认 Tab 行为
        return false
    }
    
    // 检测当前缩进层级
    let currentIndentLevel = detectIndentLevel(line: lineText)
    let targetIndentLevel = calculateTargetLevel(
        currentLevel: currentIndentLevel,
        isShiftPressed: isShiftPressed
    )
    
    // 如果层级没有变化，不处理
    if currentIndentLevel == targetIndentLevel {
        return false
    }
    
    // 计算新的缩进和序号
    let newIndent = String(repeating: " ", count: targetIndentLevel * 2)
    let listNumber = detectListNumber(
        text: text,
        currentLineIndex: nsText.lineNumber(for: selection.location),
        indentLevel: targetIndentLevel
    )
    let newMarker = generateListMarker(level: targetIndentLevel, number: listNumber)
    
    // 移除旧的列表标记和缩进，添加新的
    let content = extractListContent(from: lineText)
    let newLine = "\(newIndent)\(newMarker) \(content)"
    
    // 替换当前行
    let replacementRange = lineRange
    guard textView.shouldChangeText(in: replacementRange, replacementString: newLine) else {
        return false
    }
    
    if let textStorage = textView.textStorage {
        textStorage.replaceCharacters(in: replacementRange, with: newLine)
        textView.didChangeText()
        
        // 更新选中范围
        let newSelection = NSRange(
            location: replacementRange.location + newIndent.count + newMarker.count + 1,
            length: 0
        )
        textView.setSelectedRange(newSelection)
        textView.scrollRangeToVisible(newSelection)
        
        // 通知父组件内容已改变
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.parent.text = textView.string
            self.parent.onSelectionChange(newSelection)
        }
    }
    
    return true
}
```

---

### 5. 辅助函数

#### 5.1 生成列表标记

```swift
/// 根据层级和序号生成列表标记
func generateListMarker(level: Int, number: Int) -> String {
    switch level {
    case 0:
        return "\(number)."
    case 1:
        // a, b, c, ...
        let char = Character(UnicodeScalar(96 + number)!)
        return "\(char)."
    case 2:
        // i, ii, iii, ...
        return "\(romanNumeral(number, uppercase: false))."
    case 3:
        // A, B, C, ...
        let char = Character(UnicodeScalar(64 + number)!)
        return "\(char)."
    case 4:
        // I, II, III, ...
        return "\(romanNumeral(number, uppercase: true))."
    default:
        // 超过5层，循环使用小写字母
        let char = Character(UnicodeScalar(96 + number)!)
        return "\(char)."
    }
}
```

#### 5.2 提取列表内容

```swift
/// 从列表行中提取内容（去除缩进和标记）
func extractListContent(from line: String) -> String {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // 匹配并移除列表标记
    if let match = trimmed.range(of: #"^(\d+|[a-z]|[A-Z]|[ivxlcdmIVXLCDM]+)\.\s*"#, options: .regularExpression) {
        return String(trimmed[match.upperBound...])
    }
    
    return trimmed
}
```

---

## 📐 缩进规则

### Markdown 标准缩进

- **每层级缩进**: 2 个空格（Markdown 标准）
- **最大层级**: 5 层（超过后循环使用小写字母）
- **Tab 键行为**: 增加 1 个层级（2 个空格）
- **Shift+Tab 行为**: 减少 1 个层级（减少 2 个空格）

### 缩进示例

```markdown
1. 第一层
2. 第一层
   a. 第二层
   b. 第二层
      i. 第三层
      ii. 第三层
         A. 第四层
         B. 第四层
            I. 第五层
            II. 第五层
```

---

## 🔄 交互流程

### Tab 键增加缩进

```
用户在有序列表项中按 Tab
  ↓
检测当前行是否为有序列表项
  ↓
检测当前缩进层级（如：第1层，序号 2.）
  ↓
计算目标层级（第2层）
  ↓
查找同级列表项，计算序号（如：第2层的第1项）
  ↓
生成新的列表标记（a.）
  ↓
替换当前行的缩进和标记
  ↓
更新 TCA 状态
  ↓
光标移动到新标记后
```

### Shift+Tab 减少缩进

```
用户在有序列表项中按 Shift+Tab
  ↓
检测当前行是否为有序列表项
  ↓
检测当前缩进层级（如：第2层，序号 a.）
  ↓
计算目标层级（第1层）
  ↓
查找同级列表项，计算序号（如：第1层的第3项）
  ↓
生成新的列表标记（3.）
  ↓
替换当前行的缩进和标记
  ↓
更新 TCA 状态
  ↓
光标移动到新标记后
```

---

## 🎨 边界情况处理

### 1. 空列表项

**场景**: 用户在有内容的列表项中按 Tab

**处理**: 正常处理，保持内容不变，只改变缩进和标记

### 2. 列表项中间按 Tab

**场景**: 光标在列表项内容中间按 Tab

**处理**: 
- 如果光标在列表标记之后，执行缩进操作
- 如果光标在列表标记之前，执行默认 Tab 行为（插入空格）

### 3. 多行选中

**场景**: 用户选中多行列表项按 Tab

**处理**: 
- 批量处理所有选中的列表项
- 每行独立计算缩进和序号
- 保持相对层级关系

### 4. 混合列表

**场景**: 选中的行包含有序列表、无序列表和普通文本

**处理**: 
- 只处理有序列表项
- 其他行保持不变或执行默认 Tab 行为

### 5. 层级边界

**场景**: 第1层按 Shift+Tab 或第5层按 Tab

**处理**: 
- 第1层按 Shift+Tab：不处理（已经是顶层）
- 第5层按 Tab：可以继续增加，但序号循环使用小写字母

---

## 🔧 TCA 状态管理

### 状态更新流程

```
用户按 Tab/Shift+Tab
  ↓
MarkdownTextEditor.Coordinator.handleTabKey
  ↓
检测列表类型和缩进层级
  ↓
计算新的缩进和标记
  ↓
替换文本（使用 shouldChangeText 和 didChangeText）
  ↓
更新 textView.string
  ↓
通过 parent.text 和 parent.onSelectionChange 更新 TCA 状态
  ↓
触发自动保存（如果需要）
```

### 状态更新原则

1. **原子性**: 一次 Tab 操作只更新一次状态
2. **同步性**: 状态更新在主线程异步执行
3. **一致性**: textView 的内容和 TCA state.content 保持一致
4. **Undo/Redo**: 通过 shouldChangeText 和 didChangeText 自动支持

---

## 📊 序号计算算法

### 同级列表项检测

```swift
/// 检测当前列表项在同级中的序号
func detectListNumber(
    text: String,
    currentLineIndex: Int,
    indentLevel: Int
) -> Int {
    let lines = text.components(separatedBy: .newlines)
    var number = 1
    
    // 向前查找同级列表项
    for i in stride(from: currentLineIndex - 1, through: 0, by: -1) {
        let line = lines[i]
        let lineIndent = detectIndentLevel(line: line)
        
        if lineIndent < indentLevel {
            // 找到更高级的列表项，停止
            break
        } else if lineIndent == indentLevel {
            // 找到同级列表项
            if let listNumber = extractListNumber(from: line) {
                number = listNumber + 1
                break
            }
        } else if lineIndent > indentLevel {
            // 子级列表项，继续查找
            continue
        }
    }
    
    return number
}
```

### 序号重置逻辑

当缩进层级改变时，序号需要重新计算：
- **增加缩进**: 从 1 开始计数（新层级的第一项）
- **减少缩进**: 查找同级列表项，计算下一个序号

---

## 🧪 测试用例

### 测试用例 1: 基本 Tab 缩进

**输入**:
```markdown
1. 第一项
2. 第二项
```

**操作**: 在 "2. 第二项" 行按 Tab

**预期输出**:
```markdown
1. 第一项
   a. 第二项
```

### 测试用例 2: Shift+Tab 减少缩进

**输入**:
```markdown
1. 第一项
   a. 第二项
```

**操作**: 在 "a. 第二项" 行按 Shift+Tab

**预期输出**:
```markdown
1. 第一项
2. 第二项
```

### 测试用例 3: 多层级缩进

**输入**:
```markdown
1. 第一项
2. 第二项
```

**操作**: 
1. 在 "2. 第二项" 行按 Tab → 变成 "a. 第二项"
2. 再按 Tab → 变成 "i. 第二项"
3. 再按 Tab → 变成 "A. 第二项"
4. 再按 Tab → 变成 "I. 第二项"

**预期输出**:
```markdown
1. 第一项
         I. 第二项
```

### 测试用例 4: 序号连续性

**输入**:
```markdown
1. 第一项
2. 第二项
3. 第三项
```

**操作**: 在 "2. 第二项" 行按 Tab

**预期输出**:
```markdown
1. 第一项
   a. 第二项
2. 第三项
```

注意：原来的 "3. 第三项" 变成 "2. 第三项"（因为前面少了一项）

### 测试用例 5: 多行选中

**输入**:
```markdown
1. 第一项
2. 第二项
3. 第三项
```

**操作**: 选中 "2. 第二项" 和 "3. 第三项" 两行，按 Tab

**预期输出**:
```markdown
1. 第一项
   a. 第二项
   b. 第三项
```

---

## 🚀 实现优先级

### Phase 1: 基础功能（必须实现）
1. ✅ Tab 键增加缩进（单行）
2. ✅ Shift+Tab 减少缩进（单行）
3. ✅ 序号格式转换（1. → a. → i.）
4. ✅ 同级序号计算

### Phase 2: 增强功能（优先实现）
1. ⚠️ 多行选中批量缩进
2. ⚠️ 序号连续性维护（缩进后重新编号）
3. ⚠️ 光标位置智能处理

### Phase 3: 优化功能（可选实现）
1. ⚠️ 罗马数字转换优化
2. ⚠️ 性能优化（大量列表项）
3. ⚠️ 动画效果

---

## 💡 设计考虑

### 1. 序号重置策略

**选项A**: 缩进后序号从 1 开始（推荐）
- 优点：简单直观
- 缺点：可能与用户预期不符

**选项B**: 保持原序号（如果可能）
- 优点：保持连续性
- 缺点：实现复杂，可能不符合 Markdown 规范

**推荐**: 选项A，因为符合 Markdown 规范

### 2. 缩进单位

**选项A**: 2 个空格（Markdown 标准）
- 优点：符合规范
- 缺点：与 Tab 键的默认行为不一致

**选项B**: 4 个空格（Tab 键默认）
- 优点：与 Tab 键行为一致
- 缺点：不符合 Markdown 规范

**推荐**: 选项A，使用 2 个空格，符合 Markdown 规范

### 3. 序号格式选择

**标准方案**（推荐）:
- 1. → a. → i. → A. → I.

**简化方案**:
- 1. → a. → i. → a. (循环)

**推荐**: 标准方案，更符合用户预期

---

## 📝 实现注意事项

### 1. 与现有功能的兼容性

- ✅ 不影响列表自动续行功能
- ✅ 不影响其他编辑功能
- ✅ 支持 undo/redo

### 2. 性能考虑

- 大量列表项时，序号计算可能需要优化
- 多行选中批量处理时，避免频繁的状态更新

### 3. 用户体验

- 操作响应要迅速
- 光标位置要合理
- 视觉反馈要清晰

---

## 🔗 相关文件

### 需要修改的文件
1. `Nota4/Nota4/Features/Editor/MarkdownTextEditor.swift`
   - 添加 Tab 键拦截
   - 实现缩进逻辑
   - 实现序号转换

### 可能需要创建的文件
1. `Nota4/Nota4/Features/Editor/ListIndentHelper.swift`（可选）
   - 列表缩进工具函数
   - 序号格式转换
   - 罗马数字转换

---

## 📚 参考资料

1. [Markdown 列表规范](https://daringfireball.net/projects/markdown/syntax#list)
2. [CSS 列表样式](https://developer.mozilla.org/en-US/docs/Web/CSS/list-style-type)
3. [CommonMark 规范](https://spec.commonmark.org/0.30/#lists)

---

**设计完成日期**: 2025-11-19 16:23:56  
**设计人员**: AI Assistant  
**状态**: ✅ 设计完成，等待实现


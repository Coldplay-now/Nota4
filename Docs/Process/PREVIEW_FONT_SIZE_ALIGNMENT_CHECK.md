# 预览模式字体字号对齐检查报告

**检查时间**: 2025-11-20  
**检查范围**: EditorPreferences → RenderOptions → MarkdownRenderer CSS 生成 → 实际渲染

---

## 一、执行摘要

### ✅ 正确对齐的部分
1. **字号参数传递**：从 EditorPreferences → RenderOptions → CSS 生成，参数传递完整
2. **正文字号应用**：直接映射，单位一致（pt）
3. **代码字号应用**：直接映射，单位一致（pt）

### ⚠️ 发现的问题
1. **行高计算不准确**：使用硬编码的基础字体大小（17.0），未考虑用户实际设置的 bodyFontSize
2. **标题字号比例可能过大**：h1 = titleFontSize * 2.0，可能导致标题过大
3. **单位转换问题**：CSS 使用 pt，但浏览器渲染时 pt 和 px 的转换可能不一致

---

## 二、详细检查结果

### 2.1 数据流检查

#### 数据源：EditorPreferences.previewFonts

**文件**: `Nota4/Nota4/Models/EditorPreferences.swift` (第50-57行)

| 字段 | 类型 | 默认值 | 单位 | 状态 |
|------|------|--------|------|------|
| `bodyFontSize` | `CGFloat` | 17 | pt | ✅ 正确 |
| `titleFontSize` | `CGFloat` | 24 | pt | ✅ 正确 |
| `codeFontSize` | `CGFloat` | 14 | pt | ✅ 正确 |

**结论**: ✅ 数据源定义正确，单位统一为 pt。

---

#### 参数传递：EditorFeature.applyPreferences

**文件**: `Nota4/Nota4/Features/Editor/EditorFeature.swift` (第858, 860, 862行)

| EditorPreferences 字段 | RenderOptions 字段 | 传递方式 | 状态 |
|----------------------|------------------|---------|------|
| `previewFonts.bodyFontSize` | `renderOptions.bodyFontSize` | 直接赋值 | ✅ 正确 |
| `previewFonts.titleFontSize` | `renderOptions.titleFontSize` | 直接赋值 | ✅ 正确 |
| `previewFonts.codeFontSize` | `renderOptions.codeFontSize` | 直接赋值 | ✅ 正确 |

**结论**: ✅ 参数传递完整，无数据丢失。

---

#### CSS 生成：MarkdownRenderer.generateFontCSS

**文件**: `Nota4/Nota4/Services/MarkdownRenderer.swift` (第877-940行)

| RenderOptions 字段 | CSS 应用 | 单位 | 状态 |
|------------------|---------|------|------|
| `bodyFontSize` | `body, .content { font-size: Xpt }` | pt | ✅ 正确 |
| `titleFontSize` | `h1-h6 { font-size: Xpt }` (按比例计算) | pt | ⚠️ **需验证比例** |
| `codeFontSize` | `code, pre, .code-block { font-size: Xpt }` | pt | ✅ 正确 |

**结论**: ✅ 字号正确应用到 CSS，但标题字号计算需要验证。

---

### 2.2 字号应用检查

#### ✅ 正文字号（bodyFontSize）

**数据流**:
```
EditorPreferences.previewFonts.bodyFontSize (17pt)
  ↓ 直接传递
RenderOptions.bodyFontSize (17pt)
  ↓ 直接应用
CSS: body, .content { font-size: 17pt !important; }
```

**检查结果**: ✅ **完全对齐**
- 参数传递：✅ 正确
- 单位一致：✅ pt → pt
- CSS 应用：✅ 正确

**示例**:
- 用户设置：17pt → CSS: `font-size: 17pt`
- 用户设置：18pt → CSS: `font-size: 18pt`
- 用户设置：20pt → CSS: `font-size: 20pt`

---

#### ⚠️ 标题字号（titleFontSize）

**数据流**:
```
EditorPreferences.previewFonts.titleFontSize (24pt)
  ↓ 直接传递
RenderOptions.titleFontSize (24pt)
  ↓ 按比例计算
CSS: 
  h1 { font-size: 48pt !important; }  (24 * 2.0)
  h2 { font-size: 36pt !important; }  (24 * 1.5)
  h3 { font-size: 30pt !important; }  (24 * 1.25)
  h4 { font-size: 26.4pt !important; } (24 * 1.1)
  h5 { font-size: 24pt !important; }  (24 * 1.0)
  h6 { font-size: 21.6pt !important; } (24 * 0.9)
```

**检查结果**: ⚠️ **比例可能过大**

**问题分析**:
1. **h1 字号过大**：
   - 如果 `titleFontSize = 24pt`，h1 = 48pt
   - 如果 `titleFontSize = 28pt`，h1 = 56pt
   - 这可能超出常见设计规范（通常 h1 在 32-40pt 之间）

2. **比例设计**：
   - 当前比例：h1 = 2x, h2 = 1.5x, h3 = 1.25x, h4 = 1.1x, h5 = 1.0x, h6 = 0.9x
   - 需要验证是否符合设计预期

3. **与正文字号对比**：
   - 如果 bodyFontSize = 17pt, titleFontSize = 24pt
   - h1 = 48pt，是正文的 2.82 倍
   - 这个比例可能过大（通常 h1 是正文的 1.5-2.0 倍）

**建议**:
- 考虑调整比例，例如：h1 = 1.75x, h2 = 1.5x, h3 = 1.25x, h4 = 1.1x, h5 = 1.0x, h6 = 0.9x
- 或者将 titleFontSize 理解为 h1 的大小，其他级别按比例缩小

---

#### ✅ 代码字号（codeFontSize）

**数据流**:
```
EditorPreferences.previewFonts.codeFontSize (14pt)
  ↓ 直接传递
RenderOptions.codeFontSize (14pt)
  ↓ 直接应用
CSS: code, pre, .code-block { font-size: 14pt !important; }
```

**检查结果**: ✅ **完全对齐**
- 参数传递：✅ 正确
- 单位一致：✅ pt → pt
- CSS 应用：✅ 正确

---

### 2.3 行高计算检查

**文件**: `Nota4/Nota4/Services/MarkdownRenderer.swift` (第605-608行)

**当前实现**:
```swift
// 计算行高（line-height）：行间距是绝对值（pt），需要转换为相对值
// 假设基础字体大小为 17pt（与 EditorPreferences 默认值一致）
let baseFontSize: CGFloat = 17.0
let lineHeight = 1.0 + (lineSpacing / baseFontSize)
```

**问题分析**: ⚠️ **硬编码基础字体大小**

**场景示例**:

| 用户设置 bodyFontSize | 行间距 | 硬编码 baseFontSize | 计算的行高 | 实际应该的行高 | 偏差 |
|---------------------|--------|-------------------|-----------|--------------|------|
| 17pt | 6pt | 17.0 | 1.353 | 1.353 | ✅ 正确 |
| 18pt | 6pt | 17.0 | 1.353 | 1.333 | ❌ **偏差** |
| 20pt | 6pt | 17.0 | 1.353 | 1.300 | ❌ **偏差** |
| 14pt | 6pt | 17.0 | 1.353 | 1.429 | ❌ **偏差** |

**影响**:
- 当用户设置的 `bodyFontSize` 与默认值（17pt）不同时，行高计算不准确
- 字体越大，行高相对越小（视觉上更紧凑）
- 字体越小，行高相对越大（视觉上更宽松）

**修复建议**:
- 使用实际的 `options.bodyFontSize ?? 17.0` 作为基础字体大小
- 确保行高计算基于用户实际设置的字体大小

---

### 2.4 单位转换检查

#### CSS 单位：pt

**当前实现**: 所有字号使用 `pt` 单位

**浏览器渲染**:
- CSS `pt` 单位：1pt = 1/72 英寸
- 标准屏幕（96 DPI）：1pt ≈ 1.33px
- 高分辨率屏幕（144 DPI）：1pt ≈ 2px
- Retina 屏幕（192 DPI）：1pt ≈ 2.67px

**问题分析**:
1. **跨设备一致性**：
   - 不同 DPI 的屏幕，pt 的实际显示大小不同
   - 可能导致在不同设备上显示不一致

2. **与编辑器对比**：
   - 编辑器使用 `NSFont`，字号单位是 pt
   - 预览使用 CSS pt，理论上应该一致
   - 但浏览器渲染可能略有差异

**建议**:
- 保持使用 pt 单位（与编辑器一致）
- 但需要在实际测试中验证跨设备一致性
- 如果发现问题，可以考虑使用 `px` 或 `rem` 单位

---

## 三、问题总结

### 3.1 严重问题

#### 问题 1: 行高计算不准确 ⚠️

**位置**: `MarkdownRenderer.swift` 第607行

**问题**:
- 使用硬编码的 `baseFontSize = 17.0`
- 未考虑用户实际设置的 `bodyFontSize`
- 导致行高计算不准确

**影响**:
- 当用户设置不同的正文字号时，行高比例不正确
- 字体越大，行高相对越小（视觉上更紧凑）
- 字体越小，行高相对越大（视觉上更宽松）

**修复建议**:
```swift
// 使用实际的 bodyFontSize，如果没有则使用默认值
let baseFontSize = options.bodyFontSize ?? 17.0
let lineHeight = 1.0 + (lineSpacing / baseFontSize)
```

---

### 3.2 潜在问题

#### 问题 2: 标题字号比例可能过大 ⚠️

**位置**: `MarkdownRenderer.swift` 第909-919行

**问题**:
- h1 = titleFontSize * 2.0，可能导致标题过大
- 如果 titleFontSize = 24pt，h1 = 48pt
- 如果 titleFontSize = 28pt，h1 = 56pt

**影响**:
- 标题可能显得过大，不符合常见设计规范
- 与正文字号的对比可能不协调

**建议验证**:
- 测试不同 titleFontSize 值的实际显示效果
- 考虑调整比例或重新定义 titleFontSize 的含义

#### 问题 3: 单位转换可能不一致 ⚠️

**位置**: CSS 生成（所有字号使用 pt）

**问题**:
- CSS pt 在不同 DPI 屏幕上的实际显示大小不同
- 可能与编辑器显示略有差异

**影响**:
- 跨设备显示可能不一致
- 编辑器与预览的字号可能略有差异

**建议**:
- 在实际设备上测试验证
- 如果发现问题，考虑使用 `px` 或 `rem` 单位

---

## 四、对齐情况总结

### 4.1 参数传递对齐

| 参数 | EditorPreferences | RenderOptions | CSS 生成 | 状态 |
|------|------------------|---------------|---------|------|
| **正文字号** | ✅ 17pt | ✅ 17pt | ✅ 17pt | ✅ **完全对齐** |
| **标题字号** | ✅ 24pt | ✅ 24pt | ⚠️ 按比例计算 | ⚠️ **需验证比例** |
| **代码字号** | ✅ 14pt | ✅ 14pt | ✅ 14pt | ✅ **完全对齐** |

### 4.2 单位一致性

| 参数 | EditorPreferences | RenderOptions | CSS | 状态 |
|------|------------------|---------------|-----|------|
| **正文字号** | pt | pt | pt | ✅ **一致** |
| **标题字号** | pt | pt | pt | ✅ **一致** |
| **代码字号** | pt | pt | pt | ✅ **一致** |

### 4.3 计算逻辑对齐

| 计算项 | 当前实现 | 问题 | 状态 |
|--------|---------|------|------|
| **行高计算** | 硬编码 17.0 | ⚠️ 未考虑用户设置 | ⚠️ **需修复** |
| **标题字号计算** | 按比例（h1=2x） | ⚠️ 比例可能过大 | ⚠️ **需验证** |
| **字体栈构建** | 正确 | ✅ 无问题 | ✅ **正确** |

---

## 五、修复建议

### 5.1 高优先级修复

#### 修复 1: 行高计算使用实际字体大小

**文件**: `Nota4/Nota4/Services/MarkdownRenderer.swift`

**位置**: 第605-608行

**当前代码**:
```swift
// 计算行高（line-height）：行间距是绝对值（pt），需要转换为相对值
// 假设基础字体大小为 17pt（与 EditorPreferences 默认值一致）
let baseFontSize: CGFloat = 17.0
let lineHeight = 1.0 + (lineSpacing / baseFontSize)
```

**修复后**:
```swift
// 计算行高（line-height）：行间距是绝对值（pt），需要转换为相对值
// 使用用户实际设置的正文字号，如果没有则使用默认值
let baseFontSize = options.bodyFontSize ?? 17.0
let lineHeight = 1.0 + (lineSpacing / baseFontSize)
```

**影响**: 确保行高计算基于用户实际设置的字体大小，提高准确性。

---

### 5.2 中优先级验证

#### 验证 1: 标题字号比例

**建议**:
1. 测试不同 titleFontSize 值的实际显示效果
2. 验证 h1-h6 的视觉层次是否合理
3. 考虑调整比例或重新定义 titleFontSize 的含义

**可能的调整**:
- 方案 A：调整比例（h1 = 1.75x, h2 = 1.5x, ...）
- 方案 B：将 titleFontSize 理解为 h1 的大小，其他级别按比例缩小
- 方案 C：保持当前比例，但添加配置选项

#### 验证 2: 单位转换一致性

**建议**:
1. 在不同 DPI 的屏幕上测试
2. 对比编辑器与预览的字号显示
3. 如果发现问题，考虑使用 `px` 或 `rem` 单位

---

## 六、测试建议

### 6.1 行高计算测试

**测试步骤**:
1. 设置预览正文字号为 17pt，行间距 6pt
2. 检查预览，记录行高视觉效果
3. 将正文字号改为 20pt，行间距保持 6pt
4. **预期**: 行高应该相对减小（视觉上更紧凑）
5. **当前问题**: 行高可能不变（因为使用硬编码 17.0）

### 6.2 标题字号测试

**测试步骤**:
1. 设置预览标题字号为 24pt
2. 在预览中查看 h1-h6 的显示效果
3. **验证**:
   - h1 是否过大（48pt）？
   - 标题层次是否清晰？
   - 与正文字号的对比是否协调？

### 6.3 字号单位测试

**测试步骤**:
1. 设置预览正文字号为 17pt
2. 在编辑器中设置相同字号 17pt
3. 对比编辑器与预览的字体大小
4. **预期**: 两者应该基本一致
5. **验证**: 是否存在明显差异？

---

## 七、总结

### 7.1 当前状态

| 功能 | 参数传递 | 单位一致性 | 计算逻辑 | 总体状态 |
|------|---------|-----------|---------|---------|
| **正文字号** | ✅ | ✅ | ⚠️ 行高计算 | ⚠️ **需修复行高** |
| **标题字号** | ✅ | ✅ | ⚠️ 比例需验证 | ⚠️ **需验证比例** |
| **代码字号** | ✅ | ✅ | ✅ | ✅ **完整** |

### 7.2 关键发现

1. ✅ **参数传递完整**：所有字号参数都正确传递
2. ✅ **单位一致**：所有字号都使用 pt 单位
3. ⚠️ **行高计算不准确**：使用硬编码基础字体大小
4. ⚠️ **标题比例需验证**：h1 = 2x 可能过大

### 7.3 修复优先级

- 🔴 **高优先级**：修复行高计算（影响所有用户）
- 🟡 **中优先级**：验证标题字号比例（影响视觉效果）
- 🟢 **低优先级**：验证单位转换一致性（跨设备测试）

---

**报告生成时间**: 2025-11-20  
**检查人员**: AI Assistant  
**报告状态**: 待修复验证




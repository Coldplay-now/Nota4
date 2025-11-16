# Nota4 编辑器偏好设置 PRD

**文档版本**: v1.0  
**创建日期**: 2025年11月16日  
**作者**: AI Assistant  
**状态**: 待评审

---

## 一、需求背景

### 1.1 用户痛点

- 当前编辑器样式固定，无法根据个人喜好调整
- 不同使用场景（写作、编程、阅读）需要不同的排版设置
- 缺乏对字体、间距、边距等细粒度控制
- 用户期望类似 Bear、Ulysses 等应用的设置体验

### 1.2 目标用户

- **主力用户**: 需要长时间使用笔记应用的用户
- **专业写作者**: 对排版有较高要求
- **程序员**: 需要代码编辑环境
- **阅读爱好者**: 对阅读体验敏感

### 1.3 业务目标

- 提升用户满意度和使用时长
- 增强产品竞争力
- 满足不同用户群体的个性化需求

---

## 二、功能概述

### 2.1 核心功能

实现一个完整的编辑器偏好设置系统，支持：

1. **字体管理**
   - 标题字体选择
   - 正文字体选择
   - 代码字体选择

2. **排版控制**
   - 字体大小（12-28pt）
   - 行高（1.0-2.5em）
   - 字间距（-0.2-1.0em）
   - 段落间距（0-2.0em）
   - 段落缩进（0-4.0em）
   - 最大行宽（500-1200pt）

3. **布局设置**
   - 左右边距（8-64pt）
   - 上下边距（8-64pt）
   - 内容对齐方式

4. **预设方案**
   - 舒适阅读（默认）
   - 专业写作
   - 代码编辑
   - 自定义

5. **配置管理**
   - 实时预览
   - 恢复默认
   - 导入/导出配置

---

## 三、详细需求

### 3.1 功能需求

#### 3.1.1 字体设置

| 项目 | 说明 | 默认值 | 可选范围 |
|------|------|--------|----------|
| 标题字体 | 笔记标题栏字体 | 系统默认 | 系统字体列表 |
| 正文字体 | 编辑器正文字体 | 系统默认 | 系统字体列表 |
| 代码字体 | 代码块字体 | Menlo | 等宽字体列表 |
| 标题字号 | 标题文字大小 | 24pt | 18-32pt |
| 正文字号 | 正文文字大小 | 17pt | 12-24pt |
| 代码字号 | 代码文字大小 | 14pt | 10-20pt |

**可选字体列表：**
- **系统字体**: 
  - 默认（San Francisco）
  - 宋体（Songti）
  - 黑体（Heiti）
  - 楷体（Kaiti）
  
- **等宽字体**:
  - Menlo
  - Monaco
  - Courier New
  - SF Mono
  - Fira Code (如果用户安装)

#### 3.1.2 排版设置

| 项目 | 说明 | 默认值 | 可选范围 | 单位 |
|------|------|--------|----------|------|
| 行高 | 行与行之间的高度 | 1.6em | 1.0-2.5em | em |
| 行间距 | 额外的行间距 | 6pt | 0-20pt | pt |
| 字间距 | 字符间距 | 0em | -0.2-1.0em | em |
| 段落间距 | 段落之间的间距 | 0.8em | 0-2.0em | em |
| 段落缩进 | 段落首行缩进 | 0em | 0-4.0em | em |
| 最大行宽 | 内容区最大宽度 | 800pt | 500-1200pt | pt |

#### 3.1.3 布局设置

| 项目 | 说明 | 默认值 | 可选范围 |
|------|------|--------|----------|
| 左边距 | 内容左侧留白 | 24pt | 8-64pt |
| 右边距 | 内容右侧留白 | 24pt | 8-64pt |
| 上边距 | 内容顶部留白 | 20pt | 8-64pt |
| 下边距 | 内容底部留白 | 20pt | 8-64pt |
| 对齐方式 | 内容对齐 | 居中 | 左对齐/居中 |

#### 3.1.4 预设方案

**舒适阅读（默认）**
```yaml
name: "舒适阅读"
description: "适合长时间阅读和写作"
settings:
  fontSize: 17pt
  lineHeight: 1.6em
  lineSpacing: 6pt
  letterSpacing: 0em
  paragraphSpacing: 0.8em
  paragraphIndent: 0em
  maxWidth: 800pt
  horizontalPadding: 24pt
  verticalPadding: 20pt
  fontDesign: .default
```

**专业写作**
```yaml
name: "专业写作"
description: "适合专注写作和创作"
settings:
  fontSize: 18pt
  lineHeight: 1.8em
  lineSpacing: 8pt
  letterSpacing: 0.05em
  paragraphSpacing: 1.0em
  paragraphIndent: 0em
  maxWidth: 750pt
  horizontalPadding: 32pt
  verticalPadding: 24pt
  fontDesign: .serif
```

**代码编辑**
```yaml
name: "代码编辑"
description: "适合代码和技术文档"
settings:
  fontSize: 15pt
  lineHeight: 1.5em
  lineSpacing: 4pt
  letterSpacing: 0em
  paragraphSpacing: 0.5em
  paragraphIndent: 0em
  maxWidth: 900pt
  horizontalPadding: 20pt
  verticalPadding: 16pt
  fontDesign: .monospaced
```

**自定义**
```yaml
name: "自定义"
description: "完全自定义的配置"
settings:
  # 用户可自由调整所有参数
```

#### 3.1.5 配置管理

**功能：**
1. **实时预览**: 调整参数时立即在编辑器中反映
2. **恢复默认**: 一键恢复到预设值
3. **导入配置**: 从 JSON 文件导入配置
4. **导出配置**: 导出当前配置为 JSON 文件
5. **快速切换**: 在不同预设间快速切换

---

### 3.2 界面需求

#### 3.2.1 设置窗口布局

```
┌──────────────────────────────────────────────────────┐
│  编辑器偏好设置                            - □ ✕      │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌─ 预设方案 ────────────────────────────────────┐  │
│  │  ◉ 舒适阅读  ○ 专业写作  ○ 代码编辑  ○ 自定义 │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│  ┌─ 字体设置 ────────────────────────────────────┐  │
│  │  标题字体     [系统默认 ▼]           24 pt     │  │
│  │  正文字体     [系统默认 ▼]           17 pt     │  │
│  │  代码字体     [Menlo    ▼]           14 pt     │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│  ┌─ 排版设置 ────────────────────────────────────┐  │
│  │  行高         [━━━━━●━━━━]  1.6 em             │  │
│  │  行间距       [━━━●━━━━━━]    6 pt             │  │
│  │  字间距       [●━━━━━━━━━━]    0 em             │  │
│  │  段落间距     [━━━━●━━━━━━]  0.8 em             │  │
│  │  段落缩进     [●━━━━━━━━━━]    0 em             │  │
│  │  最大行宽     [━━━━━●━━━━━]  800 pt             │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│  ┌─ 布局设置 ────────────────────────────────────┐  │
│  │  左右边距     [━━━━●━━━━━━]   24 pt             │  │
│  │  上下边距     [━━━━●━━━━━━]   20 pt             │  │
│  │  对齐方式     ○ 左对齐  ◉ 居中                  │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│  ┌─ 配置管理 ────────────────────────────────────┐  │
│  │  [导入配置]  [导出配置]  [恢复默认]            │  │
│  └───────────────────────────────────────────────┘  │
│                                                      │
│                          [取消]  [应用]  [确定]     │
│                                                      │
└──────────────────────────────────────────────────────┘
```

#### 3.2.2 菜单集成

**位置：** 菜单栏 → Nota4 → 偏好设置...

**快捷键：** `Cmd + ,`

---

### 3.3 交互需求

#### 3.3.1 用户操作流程

```mermaid
graph TD
    A[打开偏好设置] --> B{选择预设方案?}
    B -->|是| C[应用预设]
    B -->|否| D[自定义调整]
    C --> E[查看实时预览]
    D --> E
    E --> F{满意?}
    F -->|是| G[点击确定]
    F -->|否| E
    G --> H[保存配置]
    H --> I[关闭窗口]
```

#### 3.3.2 实时预览

- 用户调整任何参数时，编辑器立即反映变化
- 无需点击"应用"即可预览效果
- 支持撤销操作（点击"取消"恢复原设置）

#### 3.3.3 响应式调整

- 滑块拖动时，实时显示数值
- 下拉菜单选择后立即应用
- 预设方案切换时平滑过渡

---

### 3.4 非功能需求

#### 3.4.1 性能要求

- 设置窗口打开时间：< 200ms
- 参数调整响应时间：< 50ms
- 配置保存时间：< 100ms
- 内存占用：< 10MB

#### 3.4.2 兼容性

- macOS 14.0+
- 支持亮色/暗色主题
- 支持多显示器
- 支持不同分辨率

#### 3.4.3 可用性

- 界面清晰，分组明确
- 滑块支持键盘操作（方向键）
- 支持 Tab 键导航
- 提供工具提示（Tooltip）

#### 3.4.4 可维护性

- 配置参数集中管理
- 易于添加新参数
- 配置文件格式可扩展
- 代码结构清晰

---

## 四、技术方案

### 4.1 技术架构

```
Nota4/
├─ Features/
│  └─ Preferences/
│     ├─ PreferencesFeature.swift       # TCA Feature
│     ├─ PreferencesView.swift          # 设置界面
│     ├─ PresetPickerView.swift         # 预设选择器
│     ├─ FontSettingsView.swift         # 字体设置
│     ├─ TypographySettingsView.swift   # 排版设置
│     ├─ LayoutSettingsView.swift       # 布局设置
│     └─ ConfigManagementView.swift     # 配置管理
├─ Models/
│  └─ EditorPreferences.swift           # 配置模型
├─ Services/
│  └─ PreferencesStorage.swift          # 持久化存储
└─ Utilities/
   ├─ EditorStyle.swift                 # 样式配置
   └─ EditorStyleApplicator.swift       # 样式应用器
```

### 4.2 数据模型

```swift
struct EditorPreferences: Codable, Equatable {
    // 预设方案
    var preset: PresetType = .comfortable
    
    // 字体设置
    var titleFontName: String = "System"
    var titleFontSize: CGFloat = 24
    var bodyFontName: String = "System"
    var bodyFontSize: CGFloat = 17
    var codeFontName: String = "Menlo"
    var codeFontSize: CGFloat = 14
    
    // 排版设置
    var lineHeight: CGFloat = 1.6        // em
    var lineSpacing: CGFloat = 6         // pt
    var letterSpacing: CGFloat = 0       // em
    var paragraphSpacing: CGFloat = 0.8  // em
    var paragraphIndent: CGFloat = 0     // em
    var maxWidth: CGFloat = 800          // pt
    
    // 布局设置
    var horizontalPadding: CGFloat = 24  // pt
    var verticalPadding: CGFloat = 20    // pt
    var alignment: Alignment = .center
    
    enum PresetType: String, Codable, CaseIterable {
        case comfortable = "舒适阅读"
        case professional = "专业写作"
        case code = "代码编辑"
        case custom = "自定义"
    }
    
    enum Alignment: String, Codable {
        case leading = "左对齐"
        case center = "居中"
    }
}
```

### 4.3 存储方案

**使用 UserDefaults + JSON：**
```swift
actor PreferencesStorage {
    static let shared = PreferencesStorage()
    
    private let key = "editorPreferences"
    private let defaults = UserDefaults.standard
    
    func load() -> EditorPreferences {
        guard let data = defaults.data(forKey: key),
              let preferences = try? JSONDecoder().decode(EditorPreferences.self, from: data) else {
            return EditorPreferences() // 默认值
        }
        return preferences
    }
    
    func save(_ preferences: EditorPreferences) throws {
        let data = try JSONEncoder().encode(preferences)
        defaults.set(data, forKey: key)
    }
}
```

### 4.4 样式应用

```swift
extension EditorPreferences {
    func toEditorStyle() -> EditorStyle {
        EditorStyle(
            fontSize: bodyFontSize,
            lineSpacing: lineSpacing,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            maxWidth: maxWidth,
            fontDesign: fontDesign,
            fontWeight: .regular,
            lineHeight: lineHeight,
            letterSpacing: letterSpacing,
            paragraphSpacing: paragraphSpacing
        )
    }
}
```

---

## 五、开发计划

### 5.1 阶段划分

#### 阶段 1：基础架构（1-2天）
- [ ] 创建数据模型
- [ ] 实现持久化存储
- [ ] 集成到 AppFeature
- [ ] 基础测试

#### 阶段 2：设置界面（2-3天）
- [ ] 创建设置窗口布局
- [ ] 实现预设选择器
- [ ] 实现字体设置面板
- [ ] 实现排版设置面板
- [ ] 实现布局设置面板
- [ ] 实现配置管理功能

#### 阶段 3：样式应用（1-2天）
- [ ] 扩展 EditorStyle 支持新参数
- [ ] 实现样式应用器
- [ ] 集成到编辑器
- [ ] 实现实时预览

#### 阶段 4：集成测试（1天）
- [ ] 功能测试
- [ ] 性能测试
- [ ] 兼容性测试
- [ ] Bug 修复

#### 阶段 5：优化完善（1天）
- [ ] UI 细节优化
- [ ] 交互优化
- [ ] 文档编写
- [ ] 发布准备

**总计：6-9 天**

### 5.2 里程碑

| 里程碑 | 时间 | 交付物 |
|--------|------|--------|
| M1：数据模型完成 | Day 1 | `EditorPreferences.swift` 完成并测试 |
| M2：设置界面完成 | Day 4 | 完整的设置窗口可用 |
| M3：功能集成完成 | Day 6 | 所有功能可用并测试通过 |
| M4：发布就绪 | Day 8 | 文档完成，代码审查通过 |

---

## 六、验收标准

### 6.1 功能验收

- [ ] 所有预设方案可以正常切换
- [ ] 所有参数可以正常调整
- [ ] 配置可以正确保存和加载
- [ ] 实时预览功能正常
- [ ] 导入/导出功能正常
- [ ] 恢复默认功能正常

### 6.2 性能验收

- [ ] 设置窗口打开时间 < 200ms
- [ ] 参数调整响应时间 < 50ms
- [ ] 无明显卡顿或延迟
- [ ] 内存占用在合理范围

### 6.3 用户体验验收

- [ ] 界面布局合理，易于理解
- [ ] 交互流畅，反馈及时
- [ ] 支持键盘操作
- [ ] 工具提示清晰有用

---

## 七、风险与挑战

### 7.1 技术风险

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| TextEditor 限制 | 高 | 部分参数可能无法完全生效，需要降级处理 |
| 性能问题 | 中 | 实时预览可能影响性能，考虑防抖 |
| 兼容性问题 | 低 | 在不同系统版本测试 |

### 7.2 用户体验风险

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 参数过多 | 中 | 提供预设方案，降低学习成本 |
| 默认值不合理 | 中 | 充分测试，参考同类产品 |
| 配置丢失 | 高 | 实现配置备份和恢复机制 |

---

## 八、后续优化方向

### 8.1 短期优化（1-3个月）

1. 支持更多字体（用户自定义字体）
2. 主题系统（亮色/暗色/自定义）
3. 快捷键自定义
4. 导出格式优化（支持主题包）

### 8.2 长期规划（3-6个月）

1. Markdown 渲染样式自定义
2. 代码高亮主题
3. 多配置文件管理
4. 云同步配置

---

## 九、附录

### 9.1 参考资料

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- Bear 应用偏好设置
- Ulysses 应用偏好设置
- Typora 应用偏好设置

### 9.2 相关文档

- `EditorStyle.swift` - 当前样式实现
- `EDITOR_PREFERENCES_IMPLEMENTATION.md` - 实施计划
- `EDITOR_PREFERENCES_API.md` - API 文档

---

**文档结束**


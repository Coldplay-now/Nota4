# 🎨 UI/工具栏/布局功能文档

本目录存放 UI 组件、工具栏和布局系统相关的分析、设计和实现文档。

---

## 📂 文档列表

### 布局系统

| 文档 | 描述 | 更新日期 |
|------|------|---------|
| [LAYOUT_DESIGN_PROPOSAL.md](./LAYOUT_DESIGN_PROPOSAL.md) | 整体布局设计方案（推荐） | 2025-11-19 |
| [LAYOUT_OPTIMIZATION_PLAN.md](./LAYOUT_OPTIMIZATION_PLAN.md) | 布局系统优化方案 | 2025-11-19 |
| [THREE_COLUMN_LAYOUT_ANALYSIS.md](./THREE_COLUMN_LAYOUT_ANALYSIS.md) | 三栏布局机制分析 | 2025-11-19 |
| [LAYOUT_SETTINGS_VALIDATION.md](./LAYOUT_SETTINGS_VALIDATION.md) | 布局设置有效性检查 | 2025-11-18 |
| [MAX_WIDTH_DESIGN_ANALYSIS.md](./MAX_WIDTH_DESIGN_ANALYSIS.md) | 最大行宽设计分析 | 2025-11-18 |
| [SCROLLBAR_POSITION_ANALYSIS.md](./SCROLLBAR_POSITION_ANALYSIS.md) | 滚动条位置问题分析 | 2025-11-18 |
| [LAYOUT_MODE_SWITCH_DESIGN.md](./LAYOUT_MODE_SWITCH_DESIGN.md) | 布局模式切换设计 | 2025-11-18 |

### UI 组件

| 文档 | 描述 | 更新日期 |
|------|------|---------|
| [STATUSBAR_HEIGHT_ISSUE_ANALYSIS.md](./STATUSBAR_HEIGHT_ISSUE_ANALYSIS.md) | 状态栏高度突然增加问题分析 | 2025-11-19 |
| [SIDEBAR_SCROLL_OPTIMIZATION.md](./SIDEBAR_SCROLL_OPTIMIZATION.md) | 侧边栏滚动优化 | 2025-11-19 |
| [SIDEBAR_BORDER_ANALYSIS.md](./SIDEBAR_BORDER_ANALYSIS.md) | 分类栏边框上缘过高问题分析 | 2025-11-19 |
| [TITLE_BAR_ANALYSIS.md](./TITLE_BAR_ANALYSIS.md) | 窗口标题栏分析 | 2025-11-19 |
| [SELECTED_CARD_BACKGROUND_ANALYSIS.md](./SELECTED_CARD_BACKGROUND_ANALYSIS.md) | 选中卡片背景颜色分析 | 2025-11-19 |
| [NOTE_LIST_TOOLBAR_DESIGN.md](./NOTE_LIST_TOOLBAR_DESIGN.md) | 笔记列表工具栏设计 | 2025-11-16 |
| [STATUS_BAR_DESIGN_EVALUATION.md](./STATUS_BAR_DESIGN_EVALUATION.md) | 状态栏设计评估 | 2025-11-16 |
| [STATUS_BAR_IMPLEMENTATION_SUMMARY.md](./STATUS_BAR_IMPLEMENTATION_SUMMARY.md) | 状态栏实现总结 | 2025-11-16 |
| [UI_IMPROVEMENTS.md](./UI_IMPROVEMENTS.md) | UI 改进 | 2025-11-16 |
| [ANALYSIS_SELECTED_CARD_BACKGROUND.md](./ANALYSIS_SELECTED_CARD_BACKGROUND.md) | 选中卡片背景分析（旧版） | 2025-11-17 |

---

## 📝 文档说明

### 布局系统文档

#### LAYOUT_DESIGN_PROPOSAL.md - 整体布局设计方案

**内容包含**：
- 当前布局问题分析（留白过大、间距不统一）
- 三种设计方案对比（紧凑型、标准型、极简型）
- 推荐方案：紧凑型布局
- 详细尺寸规范（工具栏、标题栏、状态栏）
- 视觉层次设计
- 实施检查清单

**适用场景**：
- 整体布局优化设计
- 间距系统规范
- 视觉层次设计参考

#### LAYOUT_OPTIMIZATION_PLAN.md - 布局系统优化方案

**内容包含**：
- 问题分析（一栏模式不生效、状态管理冲突等）
- TCA 状态管理优化方案
- 交互优化方案（快捷键、下拉菜单）
- 整体实施方案（5 个阶段）

**适用场景**：
- 布局系统优化实施
- 状态管理优化参考
- 交互设计参考

#### THREE_COLUMN_LAYOUT_ANALYSIS.md - 三栏布局机制分析

**内容包含**：
- 布局结构分析（NavigationSplitView）
- 控制机制分析（LayoutMode、columnVisibility）
- 宽度控制机制
- 状态管理机制
- 优化空间分析

**适用场景**：
- 理解布局系统架构
- 布局优化参考
- 问题排查

#### LAYOUT_SETTINGS_VALIDATION.md - 布局设置有效性检查

**内容包含**：
- 布局设置列表（左右边距、上下边距、对齐方式等）
- 编辑模式检查
- 预览模式检查
- 问题总结和修复建议

**适用场景**：
- 布局设置功能验证
- Bug 排查
- 功能测试

#### MAX_WIDTH_DESIGN_ANALYSIS.md - 最大行宽设计分析

**内容包含**：
- 当前实现分析
- 用户思路评估
- 优化方案（编辑模式自动适应、预览模式限制行宽）
- 实现建议

**适用场景**：
- 编辑器宽度设计
- 用户体验优化

#### SCROLLBAR_POSITION_ANALYSIS.md - 滚动条位置问题分析

**内容包含**：
- 问题分析（TCA 状态流）
- 解决方案（让 NSScrollView 占满空间）
- TCA 合规性验证

**适用场景**：
- 滚动条位置问题排查
- TCA 布局实现参考

#### LAYOUT_MODE_SWITCH_DESIGN.md - 布局模式切换设计

**内容包含**：
- 布局模式定义
- 交互入口设计（菜单栏、工具栏、快捷键）
- 实现细节（Reducer 处理、视图更新）
- 用户体验考虑

**适用场景**：
- 布局切换功能开发
- 交互设计参考

### UI 组件文档

#### TITLE_BAR_ANALYSIS.md - 窗口标题栏分析

**内容包含**：
- 窗口标题栏问题分析（窗口控制按钮与侧边栏融合）
- 根本原因分析（`.hiddenTitleBar` + `NavigationSplitView` 的组合）
- macOS 窗口标题栏机制说明（标准标题栏 vs 隐藏标题栏）
- 四种解决方案对比分析
- 推荐方案：使用标准标题栏（`.automatic`）

**适用场景**：
- 窗口标题栏设计优化
- 理解 macOS 窗口标题栏机制
- 解决窗口控制按钮视觉融合问题

#### NOTE_LIST_TOOLBAR_DESIGN.md - 笔记列表工具栏设计

**内容包含**：
- 工具栏功能设计
- SwiftUI 4.0 实现方案
- 交互设计

#### STATUS_BAR_DESIGN_EVALUATION.md - 状态栏设计评估

**内容包含**：
- 状态栏设计方案评估
- 实现方案对比
- 推荐方案

#### STATUS_BAR_IMPLEMENTATION_SUMMARY.md - 状态栏实现总结

**内容包含**：
- 状态栏实现总结
- 技术要点
- 测试验证

#### UI_IMPROVEMENTS.md - UI 改进

**内容包含**：
- UI 改进建议
- 优化方案

#### SELECTED_CARD_BACKGROUND_ANALYSIS.md - 选中卡片背景颜色分析

**内容包含**：
- 选中卡片背景问题分析（深灰色背景、深色主题反白）
- 解决方案（使用系统颜色、添加灰色背景）
- 代码实现和测试建议

#### ANALYSIS_SELECTED_CARD_BACKGROUND.md - 选中卡片背景分析（旧版）

**内容包含**：
- 选中卡片背景问题分析
- 解决方案

---

## 🎯 核心功能

### 布局系统

- **三栏布局**：侧边栏 + 笔记列表 + 编辑器
- **两栏布局**：笔记列表 + 编辑器
- **一栏布局**：仅编辑器
- **布局切换**：支持快捷键（⇧⌘1/2/3）和菜单切换
- **宽度记忆**：记住用户调整的栏宽度

### UI 组件

- **状态栏**：显示全局统计和编辑器信息
- **工具栏**：笔记列表工具栏、编辑器工具栏
- **笔记列表**：卡片式布局、多选支持

---

## 🔗 相关文档

- [系统架构](../../Architecture/SYSTEM_ARCHITECTURE.md) - 了解整体架构
- [产品需求](../../PRD/) - 查看 UI 相关 PRD
- [功能文档](../README.md) - 返回功能文档目录

---

**最后更新**: 2025-11-19 09:30:49  
**维护者**: Nota4 开发团队  
返回 [功能文档](../README.md) | [文档中心](../../README.md)


# 🎯 功能文档

本目录存放 Nota4 各功能模块的分析、设计、实现和优化文档。

---

## 📂 子目录结构

| 子目录 | 功能模块 | 文档数量 |
|--------|---------|---------|
| [Search/](./Search/) | 搜索功能 | 5 |
| [UI/](./UI/) | UI/工具栏/布局 | 11 |
| [Theme/](./Theme/) | 主题系统 | 8 |
| [Preview/](./Preview/) | 预览渲染 | 6 |
| [Mermaid/](./Mermaid/) | Mermaid 图表 | 4 |
| [Editor/](./Editor/) | 编辑器功能 | 2 |
| [Export/](./Export/) | 导出功能 | 1 |
| [Tags/](./Tags/) | 标签系统 | 1 |

---

## 📝 文档分类说明

### Search/ - 搜索功能

**功能范围**：
- 全文搜索（FTS5）
- 笔记列表搜索
- 编辑器内搜索
- 搜索优化和问题诊断

**相关文档**：
- `FTS5_USAGE_ANALYSIS.md` - FTS5 使用分析
- `SEARCH_OPTIMIZATION_PLAN.md` - 搜索优化计划
- `SEARCH_ISSUE_DIAGNOSIS.md` - 搜索问题诊断
- `NOTE_LIST_SEARCH_ANALYSIS.md` - 笔记列表搜索分析
- `EDITOR_SEARCH_ANALYSIS.md` - 编辑器搜索分析

### UI/ - UI/工具栏/布局

**功能范围**：
- 布局系统（三栏布局、布局切换）
- UI 组件（工具栏、状态栏、笔记列表）
- 布局设置和验证
- UI 优化和改进

**相关文档**：
- **布局相关**：
  - `LAYOUT_OPTIMIZATION_PLAN.md` - 布局优化方案
  - `THREE_COLUMN_LAYOUT_ANALYSIS.md` - 三栏布局分析
  - `LAYOUT_SETTINGS_VALIDATION.md` - 布局设置验证
  - `MAX_WIDTH_DESIGN_ANALYSIS.md` - 最大宽度设计分析
  - `SCROLLBAR_POSITION_ANALYSIS.md` - 滚动条位置分析
  - `LAYOUT_MODE_SWITCH_DESIGN.md` - 布局模式切换设计
- **UI组件**：
  - `NOTE_LIST_TOOLBAR_DESIGN.md` - 笔记列表工具栏设计
  - `STATUS_BAR_DESIGN_EVALUATION.md` - 状态栏设计评估
  - `STATUS_BAR_IMPLEMENTATION_SUMMARY.md` - 状态栏实现总结
  - `UI_IMPROVEMENTS.md` - UI 改进
  - `ANALYSIS_SELECTED_CARD_BACKGROUND.md` - 选中卡片背景分析

### Theme/ - 主题系统

**功能范围**：
- 主题系统架构
- 代码高亮主题
- Mermaid 主题
- 主题优化和故障排除

**相关文档**：
- **主题系统**：
  - `THEME_SYSTEM_ACCEPTANCE_TEST.md` - 主题系统验收测试
  - `THEME_TROUBLESHOOTING.md` - 主题故障排除
  - `THEME_SYSTEM_FIX.md` - 主题系统修复
  - `THEME_OPTIMIZATION_IMPLEMENTATION.md` - 主题优化实现
  - `ANALYSIS_MACOS_THEME_INTEGRATION.md` - macOS 主题集成分析
- **代码高亮**：
  - `CODE_HIGHLIGHT_THEME_SELECTION_ANALYSIS.md` - 代码高亮主题选择分析
  - `INK_SPLASH_HIGHLIGHTJS_COMPARISON.md` - Ink/Splash/Highlight.js 比较
- **Mermaid主题**：
  - `MERMAID_DARK_THEME_VISIBILITY_ANALYSIS.md` - Mermaid 暗色主题可见性分析

### Preview/ - 预览渲染

**功能范围**：
- Markdown 预览渲染引擎
- 代码块和数学公式渲染
- TOC 锚点链接
- 预览测试用例

**相关文档**：
- `PREVIEW_RENDERING_ENGINE_TECHNICAL_SUMMARY.md` - 预览渲染引擎技术总结
- `PREVIEW_RENDERING_IMPLEMENTATION_SUMMARY.md` - 预览渲染实现总结
- `PREVIEW_RENDERING_TEST_CASES.md` - 预览渲染测试用例
- `PREVIEW_TEST_EXAMPLE.md` - 预览测试示例
- `TOC_ANCHOR_LINK_ANALYSIS.md` - TOC 锚点链接分析
- `MARKDOWN_CODE_BLOCK_MATH_RENDERING_ANALYSIS.md` - Markdown 代码块数学渲染分析

### Mermaid/ - Mermaid 图表

**功能范围**：
- Mermaid 图表渲染
- Mermaid 调试和测试
- TOC 与 Mermaid 的兼容性

**相关文档**：
- `MERMAID_TEST.md` - Mermaid 测试
- `MERMAID_DEBUG_GUIDE.md` - Mermaid 调试指南
- `REVERT_MERMAID_V2.md` - 回退 Mermaid v2
- `BUGFIX_TOC_MERMAID.md` - TOC Mermaid Bug 修复

### Editor/ - 编辑器功能

**功能范围**：
- 编辑器设置
- 视图模式切换
- 编辑器优化

**相关文档**：
- `EDITOR_SETTINGS_SIMPLIFICATION_20251116.md` - 编辑器设置简化
- `VIEW_MODE_TOGGLE_ISSUE_ANALYSIS.md` - 视图模式切换问题分析

### Export/ - 导出功能

**功能范围**：
- HTML/PDF/PNG 导出
- 导出格式分析

**相关文档**：
- `EXPORT_HTML_PDF_PNG_ANALYSIS.md` - HTML/PDF/PNG 导出分析

### Tags/ - 标签系统

**功能范围**：
- 标签系统架构
- 标签功能文档

**相关文档**：
- `TAG_SYSTEM_DOCUMENTATION.md` - 标签系统文档

---

## 📐 文档命名规范

### 分析文档
- `{FEATURE}_ANALYSIS.md` - 功能分析
- `{FEATURE}_ISSUE_ANALYSIS.md` - 问题分析
- `{FEATURE}_ROOT_CAUSE.md` - 根本原因分析

### 设计文档
- `{FEATURE}_DESIGN.md` - 功能设计
- `{FEATURE}_PLAN.md` - 实施计划
- `{FEATURE}_EVALUATION.md` - 设计评估

### 实现文档
- `{FEATURE}_IMPLEMENTATION.md` - 实现总结
- `{FEATURE}_TECHNICAL_SUMMARY.md` - 技术总结
- `{FEATURE}_FIX.md` - 修复文档

### 测试文档
- `{FEATURE}_TEST.md` - 测试文档
- `{FEATURE}_TEST_CASES.md` - 测试用例
- `{FEATURE}_ACCEPTANCE_TEST.md` - 验收测试

---

## 🎯 文档使用指南

### 开发新功能时

1. **设计阶段**：查看相关功能的 `*_DESIGN.md` 或 `*_PLAN.md`
2. **实现阶段**：参考 `*_IMPLEMENTATION.md` 了解实现细节
3. **测试阶段**：查看 `*_TEST.md` 或 `*_TEST_CASES.md`
4. **问题排查**：参考 `*_ANALYSIS.md` 或 `*_ISSUE_ANALYSIS.md`

### 优化现有功能时

1. **分析问题**：查看 `*_ANALYSIS.md` 了解当前实现
2. **制定方案**：参考 `*_PLAN.md` 或 `*_OPTIMIZATION.md`
3. **实施优化**：遵循 `*_IMPLEMENTATION.md` 中的最佳实践

### 排查 Bug 时

1. **问题分析**：查看 `*_ISSUE_ANALYSIS.md` 或 `*_ROOT_CAUSE.md`
2. **修复方案**：参考 `*_FIX.md` 了解修复方法
3. **验证修复**：使用 `*_TEST.md` 中的测试用例

---

## 🔗 相关文档

- [系统架构](../Architecture/SYSTEM_ARCHITECTURE.md) - 了解整体架构
- [产品需求](../PRD/) - 查看功能需求
- [开发指南](../Development/) - 开发流程和规范
- [总结报告](../Reports/) - 功能实现总结

---

**最后更新**: 2025-11-19 08:19:41  
**维护者**: Nota4 开发团队  
返回 [文档中心](../README.md)


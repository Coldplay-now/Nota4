# 📋 产品需求文档

本目录存放 Nota4 的产品需求文档、功能规格和产品规划。

---

## 📂 文档列表

| 文档 | 描述 | 更新日期 |
|------|------|---------|
| [NOTA4_PRD.md](./NOTA4_PRD.md) | 产品需求文档 (主文档) | 2025-11-16 |
| [EDITOR_PREFERENCES_PRD.md](./EDITOR_PREFERENCES_PRD.md) | 编辑器偏好设置 PRD | 2025-11-16 |
| [EDITOR_CONTEXT_MENU_PRD.md](./EDITOR_CONTEXT_MENU_PRD.md) | 编辑器右键菜单 PRD | 2025-11-16 |
| [EDITOR_TOOLBAR_PRD.md](./EDITOR_TOOLBAR_PRD.md) | 编辑器格式工具栏 PRD | 2025-11-16 |
| [PREVIEW_RENDERING_ENHANCEMENT_PRD.md](./PREVIEW_RENDERING_ENHANCEMENT_PRD.md) | Markdown 预览渲染增强 PRD | 2025-11-16 |
| [IMPORT_EXPORT_ENHANCEMENT_PRD.md](./IMPORT_EXPORT_ENHANCEMENT_PRD.md) | 导入导出功能完善 PRD | 2025-11-16 |

---

## 📝 文档说明

### NOTA4_PRD.md - 产品需求文档

**内容包含**:
- 📋 产品概述和愿景
- 🎯 目标用户和需求分析
- ✨ 核心功能清单 (v1.0.0 MVP)
- 🗺️ 开发路线图 (v1.0 - v1.2)
- 🏗️ 技术架构简述
- 🔍 竞品分析
- 📊 成功指标

**适用人员**:
- 产品经理
- 开发团队
- 设计师
- 用户研究人员

### EDITOR_PREFERENCES_PRD.md - 编辑器偏好设置 PRD

**内容包含**:
- 📐 编辑器布局配置（字体、行距、边距、宽度等）
- 🎨 预设方案（舒适阅读、专业写作、代码编辑）
- ⚙️ macOS 系统设置风格的交互设计
- 💾 偏好设置的持久化与同步
- 🔧 高级自定义选项

**适用人员**:
- 前端开发
- UI/UX 设计师
- 产品经理

### EDITOR_CONTEXT_MENU_PRD.md - 编辑器右键菜单 PRD

**内容包含**:
- 📋 右键菜单功能清单和优先级
- 🎯 扁平化菜单结构设计（参考 Nota2 优化）
- ⌨️ 快捷键映射和冲突检查
- 🔄 Markdown 格式化操作（加粗、斜体、标题、列表等）
- 🏗️ TCA 架构实现方案
- 🧪 测试计划和验收标准

**状态**: ⚠️ 受限于 SwiftUI TextEditor 限制，转为工具栏方案

**适用人员**:
- 前端开发
- 产品经理
- QA 测试

### EDITOR_TOOLBAR_PRD.md - 编辑器格式工具栏 PRD

**内容包含**:
- 🎨 SwiftUI 4.0 现代化设计原则（Toolbar API、ViewThatFits、ControlGroup）
- 🏗️ TCA 架构最佳实践（State 复用、Action 转发、Reducer 组合）
- 📐 完整的交互设计（按钮状态、工具提示、键盘导航、辅助功能）
- 📱 响应式布局方案（4 种布局模式，自动适配窗口大小）
- 🎯 12 个 Markdown 格式化功能（格式、标题、列表、插入、笔记操作）
- 🧪 详细的测试计划（单元测试、UI 测试、手动测试、性能测试）
- 📊 成功指标和风险评估

**适用人员**:
- 前端开发（SwiftUI + TCA）
- UI/UX 设计师
- 产品经理
- QA 测试

### IMPORT_EXPORT_ENHANCEMENT_PRD.md - 导入导出功能完善 PRD

**内容包含**:
- 📊 现状评估（已实现功能清单）
- 🎯 功能规划（TXT/HTML/PDF 导入导出）
- 🔧 技术方案（Markdown 渲染、PDF 生成、编码处理）
- 📅 实施计划（三阶段开发计划）
- 🧪 测试计划（功能测试、性能测试、兼容性测试）
- ⚠️ 风险评估（技术风险、性能风险）
- 📈 成功标准

**功能优先级**:
- **P0（必须）**: TXT 导入、TXT 导出、HTML 导出
- **P1（重要）**: PDF 导出、改进 MD 导入
- **P2（可选）**: HTML 样式定制、批量压缩导出

**适用人员**:
- 后端开发（Service 层）
- 前端开发（Feature/UI 层）
- 产品经理
- QA 测试

---

## 🎯 产品定位

**Nota4 = macOS 原生 + 本地优先 + Markdown + 开源免费**

- ✨ SwiftUI 4.0 原生体验
- 🏗️ TCA 架构，可测试
- 💾 数据完全本地存储
- 🚀 GRDB + FTS5 高性能
- 📝 `.nota` 专有格式 (YAML + Markdown)

---

## 📌 当前版本

**v1.0.0 MVP** - ✅ 已完成

- ✅ 笔记编辑和实时预览
- ✅ 笔记列表和侧边栏
- ✅ 标签系统
- ✅ 全文搜索
- ✅ 导入导出
- ✅ 回收站

**下一版本**: v1.1.0 功能增强（计划中）

---

返回 [文档中心](../README.md)


# Nota4 文档中心

> 📚 **最后更新**: 2025-11-19 08:26:02  
> 🏗️ **项目**: Nota4 - 基于 SwiftUI 4.0 + TCA 1.11 的现代化 macOS Markdown 笔记应用
> 📦 **当前版本**: v1.1.1

---

## 📂 目录结构

```
Docs/
├── README.md                    # 本文档
│
├── Features/                    # 🎯 功能文档
│   ├── Search/                  # 搜索功能
│   ├── UI/                      # UI/工具栏/布局
│   ├── Theme/                   # 主题系统
│   ├── Preview/                 # 预览渲染
│   ├── Mermaid/                 # Mermaid 图表
│   ├── Editor/                  # 编辑器功能
│   ├── Export/                  # 导出功能
│   └── Tags/                    # 标签系统
│
├── Reports/                     # 📊 总结报告
│   ├── PHASE1_COMPLETION_SUMMARY.md
│   ├── PHASE1_FINAL_REPORT.md
│   ├── PROJECT_MILESTONE_SUMMARY.md
│   ├── GIT_PUSH_SUMMARY.md
│   ├── REFACTORING_SUMMARY.md
│   ├── BUG_FIXES_20251116.md
│   ├── IMPORT_FEATURE_FIX.md
│   ├── CODE_BLOCK_ENHANCEMENT.md
│   ├── WINDOW_NOT_SHOWING_FIX.md
│   ├── FINAL_IMPLEMENTATION_REPORT.md
│   └── DOCUMENTATION_ORGANIZATION_SUMMARY.md
│
├── Guides/                      # 📖 开发指南
│   ├── TEST_DRIVEN_OPTIMIZATION_GUIDE.md
│   ├── CI_CD_PLAN_A_GUIDE.md
│   ├── COMPREHENSIVE_TEST_DOCUMENT.md
│   ├── MANUAL_TEST_CHECKLIST.md
│   └── QUICK_START_TESTING.md
│
├── Reviews/                     # 🔍 代码审查
│   └── EXHAUSTIVITY_REVIEW.md
│
├── Setup/                       # ⚙️ 配置设置
│   └── CI_CD_PLAN_A_SETUP_REPORT.md
│
├── Architecture/                # 🏛️ 架构设计
│   ├── SYSTEM_ARCHITECTURE.md
│   ├── SYSTEM_ARCHITECTURE_SPEC.md
│   ├── NOTE_STATE_UPDATE_ANALYSIS.md
│   ├── SIDEBAR_COUNT_TCA_FIX.md
│   └── SIDEBAR_COUNT_FIX.md
│
├── Design/                      # 🎨 功能设计
│   └── ORDERED_LIST_INDENT_DESIGN.md
│
├── API/                         # 🔌 API 文档
│   ├── API_REFERENCE.md
│   └── FILE_FORMAT_SPEC.md
│
├── Development/                 # 💻 开发文档
│   ├── GIT_WORKFLOW.md
│   ├── SWIFT_STYLE_GUIDE.md
│   ├── XCODE_DEBUG_GUIDE.md
│   ├── XCODE_DEVELOPMENT_WORKFLOW.md
│   ├── DEBUG_MONITORING_GUIDE.md
│   └── DEBUG_TOOLS_SUMMARY.md
│
├── PRD/                         # 📋 产品需求
│   ├── NOTA4_PRD.md
│   └── (其他功能 PRD)
│
└── Process/                     # 🔄 开发过程
    ├── DECISIONS/               # 决策记录
    ├── ITERATIONS/              # 迭代记录
    └── MEETING_NOTES/           # 会议纪要
```

---

## 📝 文档分类规则

### 1. 📊 Reports/ - 总结报告

**用途**: 存放项目阶段性总结、里程碑报告、重构总结等

**命名规范**:
- 阶段报告: `PHASE{N}_{TYPE}_REPORT.md` 或 `PHASE{N}_{TYPE}_SUMMARY.md`
- 里程碑: `PROJECT_MILESTONE_SUMMARY.md`
- 专项总结: `{TOPIC}_SUMMARY.md` (如 `REFACTORING_SUMMARY.md`, `GIT_PUSH_SUMMARY.md`)

**文档模板**:
```markdown
# {标题}

**完成日期**: YYYY-MM-DD HH:MM:SS  
**项目**: Nota4

---

## 概述
...

## 完成的工作
...

## 统计数据
...

## 下一步
...
```

**当前文档**:
- `PHASE1_COMPLETION_SUMMARY.md` - Phase 1 完成总结
- `PHASE1_FINAL_REPORT.md` - Phase 1 最终报告
- `PROJECT_MILESTONE_SUMMARY.md` - 项目里程碑总结
- `GIT_PUSH_SUMMARY.md` - Git 推送记录
- `REFACTORING_SUMMARY.md` - 重构总结报告
- `BUG_FIXES_20251116.md` - Bug 修复报告
- `IMPORT_FEATURE_FIX.md` - 导入功能修复
- `CODE_BLOCK_ENHANCEMENT.md` - 代码块增强
- `WINDOW_NOT_SHOWING_FIX.md` - 窗口显示修复
- `FINAL_IMPLEMENTATION_REPORT.md` - 最终实现报告
- `DOCUMENTATION_ORGANIZATION_SUMMARY.md` - 文档组织总结
- `CRASH_ANALYSIS_NSUNDOMANAGER.md` - NSUndoManager 崩溃分析
- `RELEASE_V1.1_SUMMARY.md` - v1.1 版本发布总结
- `RELEASE_V1.1.1_SUMMARY.md` - v1.1.1 版本发布总结
- `CODE_QUALITY_FIXES_SUMMARY.md` - 代码质量修复总结
- `IMAGE_RENDERING_*` - 图片渲染相关分析报告（多个文件）
- `TITLE_EDIT_FOCUS_*` - 标题编辑焦点问题分析（多个文件）
- `EDITOR_CONTEXT_MENU_ANALYSIS.md` - 编辑器上下文菜单分析
- `PIN_FEATURE_ANALYSIS.md` - 置顶功能分析
- `DELETE_COUNT_UPDATE_ISSUE_ANALYSIS.md` - 删除计数更新问题分析

---

### 2. 📖 Guides/ - 开发指南

**用途**: 存放操作指南、最佳实践、开发流程文档

**命名规范**:
- `{TOPIC}_GUIDE.md` - 主题指南
- `{TOPIC}_TUTORIAL.md` - 教程类
- `{TOPIC}_BEST_PRACTICES.md` - 最佳实践

**文档模板**:
```markdown
# {主题}指南

**创建日期**: YYYY-MM-DD  
**适用范围**: ...

---

## 目标
...

## 前置条件
...

## 步骤
...

## 最佳实践
...

## 常见问题
...
```

**当前文档**:
- `TEST_DRIVEN_OPTIMIZATION_GUIDE.md` - 测试驱动优化指南
- `CI_CD_PLAN_A_GUIDE.md` - CI/CD 配置指南
- `COMPREHENSIVE_TEST_DOCUMENT.md` - 综合测试文档
- `MANUAL_TEST_CHECKLIST.md` - 手动测试清单
- `QUICK_START_TESTING.md` - 快速开始测试

---

### 3. 🔍 Reviews/ - 代码审查

**用途**: 存放代码审查报告、质量检查报告

**命名规范**:
- `{TOPIC}_REVIEW.md` - 审查报告
- `CODE_REVIEW_{DATE}.md` - 定期代码审查
- `{FEATURE}_AUDIT.md` - 功能审计

**文档模板**:
```markdown
# {主题}审查报告

**审查日期**: YYYY-MM-DD  
**审查人**: ...  
**审查范围**: ...

---

## 审查目标
...

## 发现的问题
...

## 改进建议
...

## 优先级
...
```

**当前文档**:
- `EXHAUSTIVITY_REVIEW.md` - 穷尽性审查报告

---

### 4. ⚙️ Setup/ - 配置设置

**用途**: 存放环境配置、工具设置、部署配置等文档

**命名规范**:
- `{TOOL}_SETUP.md` - 工具设置
- `{ENVIRONMENT}_CONFIG.md` - 环境配置
- `{TOPIC}_SETUP_REPORT.md` - 设置报告

**文档模板**:
```markdown
# {工具/环境}设置

**更新日期**: YYYY-MM-DD  
**适用版本**: ...

---

## 系统要求
...

## 安装步骤
...

## 配置说明
...

## 验证
...

## 故障排除
...
```

**当前文档**:
- `CI_CD_PLAN_A_SETUP_REPORT.md` - CI/CD 设置报告

---

### 5. 🎯 Features/ - 功能文档

**用途**: 存放各功能模块的分析、设计、实现和优化文档

**子目录结构**:
- `Search/` - 搜索功能相关文档
- `UI/` - UI/工具栏/布局相关文档
- `Theme/` - 主题系统相关文档
- `Preview/` - 预览渲染相关文档
- `Mermaid/` - Mermaid 图表相关文档
- `Editor/` - 编辑器功能相关文档
- `Export/` - 导出功能相关文档
- `Tags/` - 标签系统相关文档

**命名规范**:
- `{FEATURE}_{TYPE}_{QUALIFIER}.md` - 功能文档
- `{FEATURE}_ANALYSIS.md` - 功能分析
- `{FEATURE}_DESIGN.md` - 功能设计
- `{FEATURE}_IMPLEMENTATION.md` - 实现文档
- `{FEATURE}_FIX.md` - 修复文档

**当前文档**:
- **Search/**: `FTS5_USAGE_ANALYSIS.md`, `SEARCH_OPTIMIZATION_PLAN.md`, `SEARCH_ISSUE_DIAGNOSIS.md`, `NOTE_LIST_SEARCH_ANALYSIS.md`, `EDITOR_SEARCH_ANALYSIS.md`
- **UI/**: 
  - 布局相关: `LAYOUT_OPTIMIZATION_PLAN.md`, `THREE_COLUMN_LAYOUT_ANALYSIS.md`, `LAYOUT_SETTINGS_VALIDATION.md`, `MAX_WIDTH_DESIGN_ANALYSIS.md`, `SCROLLBAR_POSITION_ANALYSIS.md`, `LAYOUT_MODE_SWITCH_DESIGN.md`
  - UI组件: `NOTE_LIST_TOOLBAR_DESIGN.md`, `STATUS_BAR_DESIGN_EVALUATION.md`, `STATUS_BAR_IMPLEMENTATION_SUMMARY.md`, `UI_IMPROVEMENTS.md`, `ANALYSIS_SELECTED_CARD_BACKGROUND.md`
- **Theme/**: 
  - 主题系统: `THEME_SYSTEM_ACCEPTANCE_TEST.md`, `THEME_TROUBLESHOOTING.md`, `THEME_SYSTEM_FIX.md`, `THEME_OPTIMIZATION_IMPLEMENTATION.md`, `ANALYSIS_MACOS_THEME_INTEGRATION.md`
  - 代码高亮: `CODE_HIGHLIGHT_THEME_SELECTION_ANALYSIS.md`, `INK_SPLASH_HIGHLIGHTJS_COMPARISON.md`
  - Mermaid主题: `MERMAID_DARK_THEME_VISIBILITY_ANALYSIS.md`
- **Preview/**: `PREVIEW_RENDERING_ENGINE_TECHNICAL_SUMMARY.md`, `PREVIEW_RENDERING_IMPLEMENTATION_SUMMARY.md`, `PREVIEW_RENDERING_TEST_CASES.md`, `PREVIEW_TEST_EXAMPLE.md`, `TOC_ANCHOR_LINK_ANALYSIS.md`, `MARKDOWN_CODE_BLOCK_MATH_RENDERING_ANALYSIS.md`
- **Mermaid/**: `MERMAID_TEST.md`, `MERMAID_DEBUG_GUIDE.md`, `REVERT_MERMAID_V2.md`, `BUGFIX_TOC_MERMAID.md`
- **Editor/**: `EDITOR_SETTINGS_SIMPLIFICATION_20251116.md`, `VIEW_MODE_TOGGLE_ISSUE_ANALYSIS.md`
- **Export/**: `EXPORT_HTML_PDF_PNG_ANALYSIS.md`
- **Tags/**: `TAG_SYSTEM_DOCUMENTATION.md`

---

### 6. 🏛️ Architecture/ - 架构设计

**用途**: 存放系统架构、设计决策、技术选型等文档

**命名规范**:
- `SYSTEM_ARCHITECTURE.md` - 系统架构
- `{MODULE}_DESIGN.md` - 模块设计
- `TECH_STACK.md` - 技术栈
- `ADR_{NUMBER}_{TITLE}.md` - 架构决策记录 (Architecture Decision Record)

**当前文档**:
- `SYSTEM_ARCHITECTURE.md` - 系统架构文档（主文档）
- `SYSTEM_ARCHITECTURE_SPEC.md` - 系统架构设计规范（Spec）
- `NOTE_STATE_UPDATE_ANALYSIS.md` - 笔记状态更新分析
- `SIDEBAR_COUNT_TCA_FIX.md` - 侧边栏计数 TCA 修复
- `SIDEBAR_COUNT_FIX.md` - 侧边栏计数修复
- `TCA_COMPLIANCE_ANALYSIS_LAYOUT_PREFERENCES.md` - TCA 合规性分析（布局偏好）
- `TCA_UNDO_REDO_OPTIMIZATION_ANALYSIS.md` - TCA 撤销重做优化分析
- `BUNDLE_MODULE_SAFETY_ANALYSIS.md` - Bundle 模块安全分析
- `BUNDLE_MODULE_SAFETY_IMPLEMENTATION.md` - Bundle 模块安全实现

---

### 7. 🎨 Design/ - 功能设计

**用途**: 存放功能设计文档、交互设计、UI/UX 设计等

**命名规范**:
- `{FEATURE}_DESIGN.md` - 功能设计文档
- `{FEATURE}_INTERACTION_DESIGN.md` - 交互设计
- `{FEATURE}_UI_DESIGN.md` - UI 设计

**文档模板**:
```markdown
# {功能}设计

> **设计日期**: YYYY-MM-DD HH:MM:SS  
> **功能**: {功能描述}  
> **状态**: 设计阶段/实现中/已完成

---

## 📋 需求概述
...

## 🎯 设计目标
...

## 🔍 设计思路分析
...

## ✅ 推荐方案
...

## 🏗️ 技术实现设计
...

## 🧪 测试用例
...

## 🚀 实现优先级
...
```

**当前文档**:
- `ORDERED_LIST_INDENT_DESIGN.md` - 有序列表层级缩进功能设计

---

### 8. 🔌 API/ - API 文档

**用途**: 存放 API 接口文档、服务接口说明、文件格式规范

**命名规范**:
- `{SERVICE}_API.md` - 服务 API
- `API_REFERENCE.md` - API 参考
- `FILE_FORMAT_SPEC.md` - 文件格式规范

**当前文档**:
- `API_REFERENCE.md` - API 参考文档（数据结构和接口）
  - 数据结构：Note, EditorPreferences, ThemeConfig, ExportOptions
  - 服务接口：NoteRepository, NotaFileManager, ImportService, ExportService, ImageManager, ThemeManager
  - 错误处理和使用示例
- `FILE_FORMAT_SPEC.md` - 文件格式规范 (.nota)
  - .nota 文件格式规范
  - YAML Front Matter 元数据规范
  - Markdown 内容规范
  - 解析和生成规则
  - 兼容性说明

---

### 9. 💻 Development/ - 开发文档

**用途**: 存放开发流程、编码规范、工作流程等

**命名规范**:
- `CODING_STANDARDS.md` - 编码规范
- `WORKFLOW.md` - 工作流程
- `CONTRIBUTING.md` - 贡献指南
- `TESTING_STRATEGY.md` - 测试策略

**当前文档**:
- `SWIFT_STYLE_GUIDE.md` - Swift 编码风格
- `GIT_WORKFLOW.md` - Git 工作流
- `XCODE_DEBUG_GUIDE.md` - Xcode 调试指南
- `XCODE_DEVELOPMENT_WORKFLOW.md` - Xcode 开发工作流
- `DEBUG_MONITORING_GUIDE.md` - 调试监控指南
- `DEBUG_TOOLS_SUMMARY.md` - 调试工具总结
- `BRANCH_STRATEGY_ANALYSIS.md` - 分支策略分析

---

### 10. 📋 PRD/ - 产品需求

**用途**: 存放产品需求文档、功能规格说明

**命名规范**:
- `NOTA4_PRD.md` - 产品需求文档
- `{FEATURE}_SPEC.md` - 功能规格
- `ROADMAP.md` - 产品路线图
- `USER_STORIES.md` - 用户故事

**当前文档**:
- `NOTA4_PRD.md` - 产品需求文档（主文档，v1.1.1）
  - 产品概述和愿景
  - 核心功能清单（v1.1.1 已实现功能）
  - 开发路线图
  - 竞品分析和成功指标
- `EDITOR_PREFERENCES_PRD.md` - 编辑器偏好设置 PRD
- `EDITOR_TOOLBAR_PRD.md` - 编辑器格式工具栏 PRD
- `IMPORT_EXPORT_ENHANCEMENT_PRD.md` - 导入导出功能完善 PRD
- `PREVIEW_RENDERING_ENHANCEMENT_PRD.md` - Markdown 预览渲染增强 PRD
- `EDITOR_CONTEXT_MENU_PRD.md` - 编辑器右键菜单 PRD
- `NOTE_LIST_VISUAL_OPTIMIZATION_PRD.md` - 笔记列表视觉优化 PRD
- `INDEPENDENT_TOOLBAR_PRD.md` - 独立工具栏 PRD
- `TOOLBAR_EXTENSION_PRD.md` - 工具栏扩展 PRD
- `NOTE_LIST_TOOLBAR_DESIGN.md` - 笔记列表工具栏设计（已移至 Features/UI/）

---

### 11. 🔄 Process/ - 开发过程

**用途**: 存放开发过程中的决策、迭代记录、会议纪要

**子目录结构**:

#### 📌 DECISIONS/ - 决策记录
存放重要的技术决策、架构决策

**命名**: `DECISION_{DATE}_{TITLE}.md`

#### 🔁 ITERATIONS/ - 迭代记录
存放每个迭代的计划和总结

**命名**: `ITERATION_{NUMBER}_{TITLE}.md`

#### 📝 MEETING_NOTES/ - 会议纪要
存放会议记录、讨论纪要

**命名**: `MEETING_{DATE}_{TOPIC}.md`

---

## 🎯 文档编写原则

### 1. **一致性原则**
- 使用统一的文档模板
- 遵循命名规范
- 保持格式一致

### 2. **时效性原则**
- 文档必须包含创建/更新日期
- 及时更新过期内容
- 定期审查文档准确性

### 3. **可读性原则**
- 使用清晰的标题结构
- 添加目录和导航
- 使用表格、列表、代码块等格式化元素
- 适当使用 emoji 增强可读性

### 4. **完整性原则**
- 包含必要的上下文信息
- 提供示例和参考
- 说明前置条件和后续步骤

### 5. **可维护性原则**
- 模块化文档内容
- 避免重复，使用链接引用
- 保持文档粒度适中

---

## 📐 文档命名规范

### 文件名格式

```
{TYPE}_{SUBJECT}_{QUALIFIER}.md
```

**示例**:
- `GUIDE_CI_CD_SETUP.md` ✅
- `REPORT_PHASE1_FINAL.md` ✅
- `REVIEW_CODE_QUALITY.md` ✅
- `guide-ci-cd.md` ❌ (使用下划线而非连字符)
- `phase1report.md` ❌ (缺少类型前缀)

### 特殊情况

- README: 每个目录的说明文档
- CHANGELOG: 变更日志
- TODO: 待办事项清单
- FAQ: 常见问题

---

## 🔧 文档维护流程

### 创建新文档

1. **确定分类**: 根据文档类型选择合适的目录
2. **命名文件**: 遵循命名规范
3. **使用模板**: 根据文档类型使用相应模板
4. **添加元信息**: 日期、作者、版本等
5. **更新索引**: 在相关目录的 README 中添加链接

### 更新现有文档

1. **更新日期**: 修改"最后更新"时间戳
2. **版本控制**: 重大更新时增加版本号
3. **变更说明**: 在文档顶部或底部说明变更
4. **通知相关人**: 通过 Git commit message 说明

### 归档过时文档

1. 创建 `Archive/` 目录
2. 移动过时文档到归档目录
3. 在原目录添加链接指向新文档
4. 保留历史记录

---

## 🔗 文档链接规范

### 内部链接

```markdown
# 相对路径引用
详见 [CI/CD 指南](./Guides/CI_CD_PLAN_A_GUIDE.md)

# 跨目录引用
参考 [架构设计](../Architecture/SYSTEM_ARCHITECTURE.md)

# 锚点链接
跳转到 [配置章节](#配置设置)
```

### 外部链接

```markdown
# GitHub 仓库
[Nota4 GitHub](https://github.com/Coldplay-now/Nota4)

# 技术文档
[TCA Documentation](https://pointfreeco.github.io/swift-composable-architecture/)

# 相关资源
[SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
```

---

## 📊 文档质量检查清单

创建或更新文档时，请检查以下项：

- [ ] 文件名符合命名规范
- [ ] 文档放在正确的目录
- [ ] 包含创建/更新日期
- [ ] 有清晰的标题和目录结构
- [ ] 代码示例格式正确
- [ ] 链接有效（内部和外部）
- [ ] 拼写和语法正确
- [ ] 格式一致（标题层级、列表样式等）
- [ ] 包含必要的示例和说明
- [ ] 更新了相关的索引和 README

---

## 🚀 快速导航

### 新手入门
1. 📋 [产品需求文档](./PRD/) - 了解 Nota4 是什么
2. 🏛️ [系统架构](./Architecture/) - 理解技术架构
3. 🎨 [功能设计](./Design/) - 查看功能设计文档
4. 💻 [开发指南](./Development/) - 开始开发

### 日常开发
- 🎯 [功能文档](./Features/) - 功能模块文档
- 📖 [开发指南](./Guides/) - 查找操作指南
- ⚙️ [配置设置](./Setup/) - 环境配置
- 🔌 [API 文档](./API/) - 接口参考

### 质量保证
- 🔍 [代码审查](./Reviews/) - 审查报告
- 📊 [总结报告](./Reports/) - 项目进展

### 项目管理
- 🔄 [开发过程](./Process/) - 决策和迭代记录
- 📊 [里程碑](./Reports/PROJECT_MILESTONE_SUMMARY.md) - 项目进度

---

## 📞 联系方式

如有文档相关问题，请：
- 📮 提交 Issue: https://github.com/Coldplay-now/Nota4/issues
- 💬 Pull Request: 欢迎改进文档
- 📧 邮件联系项目维护者

---

## 📄 文档版本

| 版本 | 日期 | 变更说明 |
|------|------|---------|
| v1.0.0 | 2025-11-16 | 初始版本，建立文档分类体系 |
| v1.1.0 | 2025-11-17 | 添加 Features/ 目录，重新组织功能文档 |
| v1.2.0 | 2025-11-19 | 文档归类优化，将根目录文档移动到对应子目录，新增 Export/ 和 Tags/ 子目录 |
| v1.3.0 | 2025-11-19 | 更新 PRD 至 v1.1.1，创建系统架构设计 Spec 和 API 文档 |
| v1.4.0 | 2025-11-19 | 新增 Design/ 目录，添加有序列表层级缩进功能设计文档 |

---

**维护者**: Nota4 开发团队  
**最后审查**: 2025-11-19 08:26:02  
**状态**: ✅ 活跃维护中


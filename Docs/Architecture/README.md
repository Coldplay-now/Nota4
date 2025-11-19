# 🏛️ 架构设计

本目录存放 Nota4 的系统架构文档、设计决策和技术选型文档。

---

## 📂 文档列表

### 架构设计规范

| 文档 | 描述 | 更新日期 |
|------|------|---------|
| [SYSTEM_ARCHITECTURE.md](./SYSTEM_ARCHITECTURE.md) | 系统架构文档 (主文档) | 2025-11-16 |
| [SYSTEM_ARCHITECTURE_SPEC.md](./SYSTEM_ARCHITECTURE_SPEC.md) | 系统架构设计规范 (Spec) | 2025-11-19 |

### 架构分析文档

| 文档 | 描述 | 更新日期 |
|------|------|---------|
| [NOTE_STATE_UPDATE_ANALYSIS.md](./NOTE_STATE_UPDATE_ANALYSIS.md) | 笔记状态更新分析 | 2025-11-17 |
| [SIDEBAR_COUNT_TCA_FIX.md](./SIDEBAR_COUNT_TCA_FIX.md) | 侧边栏计数 TCA 修复 | 2025-11-16 |
| [SIDEBAR_COUNT_FIX.md](./SIDEBAR_COUNT_FIX.md) | 侧边栏计数修复 | 2025-11-16 |
| [TCA_COMPLIANCE_ANALYSIS_LAYOUT_PREFERENCES.md](./TCA_COMPLIANCE_ANALYSIS_LAYOUT_PREFERENCES.md) | TCA 合规性分析（布局偏好） | 2025-11-18 |
| [TCA_UNDO_REDO_OPTIMIZATION_ANALYSIS.md](./TCA_UNDO_REDO_OPTIMIZATION_ANALYSIS.md) | TCA 撤销重做优化分析 | 2025-11-18 |
| [BUNDLE_MODULE_SAFETY_ANALYSIS.md](./BUNDLE_MODULE_SAFETY_ANALYSIS.md) | Bundle 模块安全分析 | 2025-11-18 |
| [BUNDLE_MODULE_SAFETY_IMPLEMENTATION.md](./BUNDLE_MODULE_SAFETY_IMPLEMENTATION.md) | Bundle 模块安全实现 | 2025-11-18 |

---

## 📝 文档说明

### SYSTEM_ARCHITECTURE_SPEC.md - 系统架构设计规范

**内容包含**:
- 🎯 架构概述和设计原则
- 🏗️ 系统分层架构
- 📦 核心模块设计
- 🔄 数据流设计
- 💾 数据模型设计
- ⚡ 并发模型设计
- 🚀 性能设计
- 🔒 安全设计
- 🔧 扩展性设计

**适用人员**:
- 架构师
- 高级开发者
- 技术评审

### SYSTEM_ARCHITECTURE.md - 系统架构

**内容包含**:
- 🎯 架构概述和设计原则
- 📚 技术栈详解
- 🏗️ 系统分层架构
- 🔄 数据流和状态管理
- 💾 数据模型和数据库设计
- ⚡ 并发模型（Actor/async-await）
- 🚀 性能优化策略
- 🔒 安全性设计

**适用人员**:
- 架构师
- 高级开发者
- 技术面试官

---

## 🏗️ 核心架构

### TCA 单向数据流

```
View → Action → Reducer → State → View
              ↓
           Effect (Side Effects)
```

### 系统分层

```
Presentation Layer (SwiftUI)
      ↓
Business Logic Layer (TCA Reducers)
      ↓
Service Layer (Repositories)
      ↓
Data Layer (GRDB + FileSystem)
```

---

## 🎯 设计原则

- **SOLID 原则** - 单一职责、开闭原则等
- **单向数据流** - 状态可预测
- **不可变状态** - 易于调试
- **副作用隔离** - 易于测试
- **模块化** - 高内聚低耦合

---

## 📊 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| SwiftUI | 4.0+ | UI 框架 |
| TCA | 1.11+ | 状态管理 |
| GRDB | 6.0+ | 数据库 |
| MarkdownUI | 2.0+ | Markdown 渲染 |
| Yams | 5.0+ | YAML 解析 |

---

返回 [文档中心](../README.md)


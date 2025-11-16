# 🏛️ 架构设计

本目录存放 Nota4 的系统架构文档、设计决策和技术选型文档。

---

## 📂 文档列表

| 文档 | 描述 | 更新日期 |
|------|------|---------|
| [SYSTEM_ARCHITECTURE.md](./SYSTEM_ARCHITECTURE.md) | 系统架构文档 (主文档) | 2025-11-16 |

---

## 📝 文档说明

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


# 💻 开发文档

本目录存放开发流程、编码规范、工作流程等文档。

---

## 📂 文档列表

| 文档 | 描述 | 更新日期 |
|------|------|---------|
| [SWIFT_STYLE_GUIDE.md](./SWIFT_STYLE_GUIDE.md) | Swift 编码规范 | 2025-11-16 |
| [GIT_WORKFLOW.md](./GIT_WORKFLOW.md) | Git 工作流程 | 2025-11-16 |

---

## 📝 文档说明

### SWIFT_STYLE_GUIDE.md - Swift 编码规范

**内容包含**:
- 📐 命名规范（类型、变量、函数）
- 🏗️ TCA 特定规范
- 💾 代码组织和文件结构
- ✨ Swift 最佳实践
- 🔒 访问控制
- 📏 代码格式
- 🧪 测试代码规范

**适用场景**:
- 编写新代码时参考
- 代码审查时检查
- 新成员学习规范

### GIT_WORKFLOW.md - Git 工作流

**内容包含**:
- 🌳 分支策略
- 📝 提交规范 (Conventional Commits)
- 🔄 标准工作流程
- 🏷️ 版本标签规范
- 🔍 代码审查清单
- 📦 发布流程

**适用场景**:
- 创建新分支
- 提交代码
- 发布版本

---

## 🎯 核心规范

### 命名规范

- **类型**: UpperCamelCase (`struct Note`)
- **变量**: lowerCamelCase (`var noteTitle`)
- **Bool**: is/has 前缀 (`var isLoading`)
- **函数**: 动词开头 (`func loadNote()`)

### 提交规范

```bash
<type>(<scope>): <subject>

类型：
- feat: 新功能
- fix: Bug 修复
- docs: 文档更新
- refactor: 代码重构
- test: 测试相关
- chore: 构建/工具
```

### 分支命名

```
feature/功能名
fix/bug描述
docs/文档主题
refactor/模块名
```

---

## 🛠️ 开发工具

### SwiftLint

项目使用 SwiftLint 自动检查代码风格。

```bash
# 运行 linter
swiftlint

# 自动修复
swiftlint --fix
```

配置文件：`.swiftlint.yml`

---

## 📚 新手入门

### 第一步：设置环境

```bash
# 1. 克隆仓库
git clone https://github.com/Coldplay-now/Nota4.git

# 2. 安装依赖
cd Nota4
swift package resolve

# 3. 打开项目
open Package.swift
```

### 第二步：熟悉架构

1. 阅读 [系统架构文档](../Architecture/SYSTEM_ARCHITECTURE.md)
2. 了解 TCA 基础概念
3. 查看示例代码 (EditorFeature)

### 第三步：开始开发

1. 遵循 [编码规范](./SWIFT_STYLE_GUIDE.md)
2. 遵循 [Git 工作流](./GIT_WORKFLOW.md)
3. 编写测试
4. 提交代码

---

## 🧪 测试指南

```bash
# 运行所有测试
swift test

# 运行特定测试
swift test --filter EditorFeatureTests

# 生成覆盖率报告
swift test --enable-code-coverage
```

**测试目标**: ≥ 80% 覆盖率  
**当前状态**: 100% 通过率 (94/94)

---

## 📞 获取帮助

- 📮 提交 Issue: https://github.com/Coldplay-now/Nota4/issues
- 💬 查看 Discussions: https://github.com/Coldplay-now/Nota4/discussions
- 📖 阅读文档: [文档中心](../README.md)

---

返回 [文档中心](../README.md)


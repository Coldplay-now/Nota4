# Nota4

> 基于 SwiftUI 4.0 + TCA 1.11 的现代化 macOS 原生 Markdown 笔记应用

## 📋 项目概述

Nota4 是 Nota 系列的第四代产品，采用完全重构的架构，解决了前代版本的状态管理问题，并提供更现代化的用户体验。

### 核心特点

- ✨ **SwiftUI 原生**: 充分利用 Apple 最新 UI 框架
- 🏗️ **TCA 架构**: 可预测的状态管理，易于测试
- 🎨 **流畅体验**: Liquid 动画、暗色主题、响应式设计
- 💾 **本地优先**: 数据完全本地存储，支持 `.nota` 专有格式
- 🚀 **性能优异**: 即时保存、快速检索、丝滑操作

## 🛠️ 技术栈

| 技术 | 版本 | 用途 |
|-----|------|------|
| SwiftUI | 4.0+ | UI 框架 |
| TCA | 1.11+ | 状态管理 |
| GRDB | 6.0+ | 数据库 |
| MarkdownUI | 2.0+ | Markdown 渲染 |
| Yams | 5.0+ | YAML 解析 |

## 📦 系统要求

- **macOS**: 15.0+ (Sequoia)
- **Xcode**: 15.0+
- **Swift**: 5.9+

## 🚀 快速开始

### 环境准备

```bash
# 1. 克隆仓库
git clone https://github.com/Coldplay-now/Nota4.git
cd Nota4

# 2. 运行设置脚本
./Scripts/utils/setup_dev_env.sh

# 3. 构建项目
swift build
```

### 运行应用

```bash
# 调试模式
./Scripts/build/build_debug.sh

# 发布模式
./Scripts/build/build_release.sh
```

## 📂 项目结构

```
Nota4/
├── Nota4/                   # 主应用代码
│   ├── App/                 # 应用入口
│   ├── Features/            # 功能模块（TCA Feature）
│   ├── Models/              # 数据模型
│   ├── Services/            # 业务服务
│   ├── Views/               # 通用视图组件
│   └── Utilities/           # 工具类
├── Nota4Tests/              # 单元测试
├── Nota4UITests/            # UI 测试
├── Scripts/                 # 自动化脚本
├── Docs/                    # 项目文档
└── Package.swift            # SPM 配置
```

## 📝 开发路线图

### v1.0.0 MVP（当前开发中）

- [x] Week 1: 项目初始化与架构搭建
- [ ] Week 2: 数据层实现
- [ ] Week 3: 笔记列表与侧边栏
- [ ] Week 4: 编辑器与预览
- [ ] Week 5: 导入导出与测试

### v1.1.0 功能增强

- [ ] 标签系统
- [ ] 导出功能增强
- [ ] 性能优化
- [ ] UI 优化

### v1.2.0 高级功能

- [ ] Spotlight 集成
- [ ] 版本历史
- [ ] iCloud 同步（可选）

## 📚 文档

- [产品需求文档 (PRD)](Docs/PRD/NOTA4_PRD.md)
- [技术规格文档](Docs/PRD/TECHNICAL_SPEC.md)
- [开发计划](/nota4-v1-0.plan.md)

## 🧪 测试

```bash
# 运行单元测试
./Scripts/test/run_unit_tests.sh

# 运行 UI 测试
./Scripts/test/run_ui_tests.sh

# 生成测试覆盖率报告
./Scripts/test/test_coverage.sh
```

**测试覆盖率目标**: 80%+

## 🤝 贡献

欢迎贡献！请参阅 [开发指南](Docs/Development/SETUP_GUIDE.md)。

## 📄 许可证

MIT License

## 🔗 相关链接

- **GitHub 仓库**: https://github.com/Coldplay-now/Nota4
- **问题反馈**: https://github.com/Coldplay-now/Nota4/issues

---

**版本**: v1.0.0-dev  
**最后更新**: 2025-11-15  
**状态**: 🚧 开发中







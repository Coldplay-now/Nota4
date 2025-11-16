# Nota4 脚本工具集

**最后更新**: 2025-11-16

本目录包含 Nota4 项目的各种自动化脚本，用于构建、测试、调试和部署。

---

## 📁 目录结构

```
Scripts/
├── build/              # 构建相关脚本
├── db/                 # 数据库相关脚本
├── deploy/             # 部署相关脚本
├── test/               # 测试相关脚本
├── utils/              # 通用工具脚本
├── monitor_xcode_debug.sh      # 全功能调试监控 ⭐
├── watch_app_logs.sh           # 实时日志监控 ⭐
└── build_app_with_icon.sh      # 带图标的应用构建
```

---

## 🆕 新增：调试监控脚本

### 1. `watch_app_logs.sh` - 实时日志监控（推荐）

**用途**: 在 Xcode 中运行应用时实时查看日志

**功能**:
- ✅ 实时显示应用日志
- ✅ 自动分类（错误/警告/信息）
- ✅ 彩色输出，易于阅读
- ✅ 自动统计和保存

**使用方法**:

```bash
# 启动监控（然后在 Xcode 中运行应用）
./Scripts/watch_app_logs.sh

# 按 Ctrl+C 停止监控
```

**适用场景**: 
- 🎯 交互式测试
- 🐛 快速诊断问题
- 📝 实时查看应用行为

---

### 2. `monitor_xcode_debug.sh` - 全功能调试监控

**用途**: 自动化构建、测试和日志分析

**功能**:
- ✅ 自动构建项目
- ✅ 运行测试套件
- ✅ 监控运行时日志
- ✅ 生成分析报告
- ✅ 持续监控模式

**使用方法**:

```bash
# 默认模式：构建 + 测试 + 分析
./Scripts/monitor_xcode_debug.sh

# 仅构建
./Scripts/monitor_xcode_debug.sh --build

# 持续监控
./Scripts/monitor_xcode_debug.sh --continuous

# 查看所有选项
./Scripts/monitor_xcode_debug.sh --help
```

**适用场景**:
- 🏗️ 完整构建流程
- 📊 需要详细报告
- 🔄 CI/CD 集成

---

## 📖 详细文档

完整的调试监控指南请参阅: [DEBUG_MONITORING_GUIDE.md](../Docs/DEBUG_MONITORING_GUIDE.md)

---

## 🏗️ 构建脚本

### `build_app_with_icon.sh` - 带图标的应用构建

**用途**: 构建包含应用图标的 Nota4.app

**功能**:
- 清理旧构建
- 编译 Release 版本
- 复制应用图标
- 设置应用权限

**使用方法**:

```bash
./Scripts/build_app_with_icon.sh
```

**输出**: `/Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app`

---

### `build/` 目录

包含各种构建脚本：

- `build_app.sh` - 基础应用构建
- `build_debug.sh` - Debug 版本构建
- `build_release.sh` - Release 版本构建
- `build_release_dmg.sh` - 创建 DMG 安装包
- `create_dmg.sh` - DMG 创建工具

**使用示例**:

```bash
# 构建 Debug 版本
./Scripts/build/build_debug.sh

# 构建 Release 版本
./Scripts/build/build_release.sh

# 创建 DMG 安装包
./Scripts/build/build_release_dmg.sh
```

---

## 🧪 测试脚本

### `test/` 目录

包含测试相关脚本：

- 单元测试运行
- 集成测试
- UI 测试
- 测试覆盖率报告

**使用示例**:

```bash
# 运行所有测试
swift test

# 结合监控运行测试
./Scripts/monitor_xcode_debug.sh --build
```

---

## 🗄️ 数据库脚本

### `db/` 目录

包含数据库相关脚本：

- 数据库迁移
- 数据清理
- 数据备份
- 数据恢复

---

## 🚀 部署脚本

### `deploy/` 目录

包含部署相关脚本：

- 版本发布
- 代码签名
- 公证处理
- 分发准备

---

## 🛠️ 工具脚本

### `utils/` 目录

- `setup_dev_env.sh` - 开发环境设置

**使用示例**:

```bash
./Scripts/utils/setup_dev_env.sh
```

---

## 📊 日志和输出

所有脚本的日志输出保存在 `Logs/` 目录：

```
Logs/
├── app_console_*.log       # 应用控制台日志
├── debug_session_*.log     # 调试会话日志
├── issues_*.log            # 问题汇总
├── console_*.log           # 系统控制台
├── summary_*.md            # 分析报告
├── build_*.log             # 构建日志
└── test_*.log              # 测试日志
```

---

## 🎯 常用工作流

### 开发测试流程

```bash
# 1. 启动日志监控
./Scripts/watch_app_logs.sh

# 2. 在 Xcode 中运行应用 (⌘R)

# 3. 进行交互测试

# 4. 按 Ctrl+C 查看统计
```

### 完整构建流程

```bash
# 1. 运行测试
swift test

# 2. 构建应用
./Scripts/build_app_with_icon.sh

# 3. 验证应用
open /Users/xt/LXT/code/trae/1107-model-eval/Nota4/Build/Nota4.app

# 4. 创建 DMG
./Scripts/build/build_release_dmg.sh
```

### CI/CD 流程

```bash
# 完整的构建、测试、分析流程
./Scripts/monitor_xcode_debug.sh --build

# 查看报告
cat Logs/summary_*.md
```

---

## ⚙️ 脚本权限

确保所有脚本都有执行权限：

```bash
chmod +x Scripts/*.sh
chmod +x Scripts/*/*.sh
```

---

## 🐛 故障排除

### 问题 1: Permission denied

```bash
chmod +x Scripts/xxx.sh
```

### 问题 2: 找不到命令

确保脚本使用绝对路径或相对于项目根目录的路径：

```bash
cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
./Scripts/xxx.sh
```

### 问题 3: 构建失败

```bash
# 清理构建缓存
swift package clean

# 重新构建
swift build
```

---

## 📚 相关文档

- [调试监控指南](../Docs/DEBUG_MONITORING_GUIDE.md) - 详细的调试脚本使用说明
- [手动测试清单](../Docs/MANUAL_TEST_CHECKLIST.md) - 交互测试指南
- [构建和发布指南](../Docs/BUILD_AND_RELEASE.md) - 发布流程（待创建）

---

## 💡 贡献

添加新脚本时，请：

1. 放在合适的子目录
2. 添加详细的注释
3. 更新本 README
4. 添加使用示例

---

## 📝 脚本模板

创建新脚本时可以使用以下模板：

```bash
#!/bin/bash

# 脚本名称和用途
# 作者：
# 日期：YYYY-MM-DD

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 函数
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 主逻辑
main() {
    print_info "开始执行..."
    
    # TODO: 添加你的逻辑
    
    print_info "完成"
}

main "$@"
```

---

**维护者**: Nota4 Team  
**最后更新**: 2025-11-16


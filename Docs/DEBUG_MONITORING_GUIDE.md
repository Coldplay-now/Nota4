# Nota4 调试监控指南

**创建时间**: 2025-11-16  
**版本**: 1.0

---

## 📋 概述

本指南介绍如何使用自动化脚本监控 Xcode 的 console log 和 issues，方便诊断和调试问题。

---

## 🛠️ 可用工具

我们提供了两个强大的调试脚本：

### 1. `monitor_xcode_debug.sh` - 全功能调试监控

**功能**：
- ✅ 自动构建项目并捕获日志
- ✅ 运行测试并收集结果
- ✅ 监控运行时日志
- ✅ 分析日志并生成报告
- ✅ 持续监控模式

**适用场景**：
- 完整的构建和测试流程
- 需要详细报告和分析
- CI/CD 集成

### 2. `watch_app_logs.sh` - 实时日志监控（推荐用于交互测试）

**功能**：
- ✅ 实时显示应用日志
- ✅ 自动分类（错误/警告/信息）
- ✅ 彩色输出，易于阅读
- ✅ 自动统计和保存

**适用场景**：
- 在 Xcode 中运行应用时实时监控
- 交互式测试
- 快速诊断问题

---

## 🚀 快速开始

### 准备工作

1. **赋予脚本执行权限**：

```bash
cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
chmod +x Scripts/*.sh
```

2. **确保 Xcode 已安装**

3. **了解日志位置**：所有日志都保存在 `Nota4/Logs/` 目录

---

## 📖 使用方法

### 方法 1: 实时监控（推荐用于交互测试）

**最常用的方式！**

#### 步骤：

1. **启动监控脚本**：

```bash
cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
./Scripts/watch_app_logs.sh
```

2. **在 Xcode 中运行应用**：
   - 打开 Xcode
   - 点击 Run 按钮 (⌘R)
   - 应用启动后开始交互测试

3. **观察输出**：
   - 🟢 绿色：正常信息
   - 🟡 黄色：警告
   - 🔴 红色：错误和崩溃

4. **停止监控**：
   - 按 `Ctrl+C`
   - 查看统计摘要
   - 日志自动保存到 `Logs/` 目录

#### 示例输出：

```
╔════════════════════════════════════════╗
║   Nota4 实时日志监控                  ║
╔════════════════════════════════════════╗

📝 现在请在 Xcode 中点击 Run 按钮
🔍 我会自动捕获所有日志...

⏸  按 Ctrl+C 停止监控

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[10:30:15] [INFO] Application did finish launching
[10:30:16] [INFO] DatabaseManager initialized
[10:30:20] [WARN] Slow database query detected
[10:30:25] [ERROR] Failed to load note: File not found
```

---

### 方法 2: 完整构建和分析

#### 基本用法：

```bash
# 默认模式：构建 -> 测试 -> 分析
./Scripts/monitor_xcode_debug.sh

# 仅构建
./Scripts/monitor_xcode_debug.sh --build

# 仅监控运行时
./Scripts/monitor_xcode_debug.sh --run

# 持续监控模式
./Scripts/monitor_xcode_debug.sh --continuous
```

#### 查看帮助：

```bash
./Scripts/monitor_xcode_debug.sh --help
```

#### 所有选项：

| 选项 | 说明 |
|------|------|
| `-h, --help` | 显示帮助信息 |
| `-b, --build` | 构建项目并捕获日志 |
| `-r, --run` | 运行项目并监控 console |
| `-c, --continuous` | 持续监控模式 |
| `-a, --analyze` | 分析现有日志 |
| `-l, --live` | 实时显示日志 |
| `--clean` | 清理旧日志 |

---

## 🎯 实际工作流

### 场景 1: 日常开发测试（推荐）

```bash
# 终端 1：启动日志监控
./Scripts/watch_app_logs.sh

# 终端 2 或 Xcode：运行应用
# 在 Xcode 中点击 Run 按钮

# 在终端 1 中观察日志
# 进行交互测试（创建笔记、搜索、导入等）
# 按 Ctrl+C 停止并查看统计
```

### 场景 2: 构建和测试验证

```bash
# 完整流程：构建 + 测试 + 分析
./Scripts/monitor_xcode_debug.sh

# 查看生成的报告
cat Logs/summary_*.md
```

### 场景 3: 持续监控（长时间测试）

```bash
# 启动持续监控
./Scripts/monitor_xcode_debug.sh --continuous

# 在 Xcode 中运行应用
# 进行长时间的交互测试
# 脚本会实时更新统计信息

# 按 Ctrl+C 停止并生成最终报告
```

### 场景 4: 分析历史日志

```bash
# 查看最近的日志
ls -lht Logs/

# 分析最近的日志
./Scripts/monitor_xcode_debug.sh --analyze

# 手动查看特定日志
cat Logs/console_20251116_103045.log
grep ERROR Logs/console_20251116_103045.log
```

---

## 📁 日志文件说明

所有日志保存在 `Nota4/Logs/` 目录：

| 文件名 | 内容 | 说明 |
|--------|------|------|
| `app_console_*.log` | 应用控制台输出 | 运行时的所有日志 |
| `debug_session_*.log` | 调试会话记录 | 完整的调试过程 |
| `issues_*.log` | 问题汇总 | 错误、警告、崩溃 |
| `console_*.log` | 系统控制台 | 系统级日志 |
| `summary_*.md` | 摘要报告 | Markdown 格式的分析报告 |
| `build_*.log` | 构建日志 | 编译过程的输出 |
| `test_*.log` | 测试日志 | 测试运行结果 |

### 日志命名规则

格式：`类型_YYYYMMDD_HHMMSS.log`

示例：`app_console_20251116_103045.log`
- 类型：`app_console`
- 日期：2025年11月16日
- 时间：10:30:45

---

## 🔍 日志分析技巧

### 1. 快速查找错误

```bash
# 查找所有错误
grep -i error Logs/app_console_*.log

# 查找崩溃
grep -iE "crash|fatal|exception" Logs/app_console_*.log

# 查找特定功能的日志
grep -i "database" Logs/app_console_*.log
grep -i "import" Logs/app_console_*.log
```

### 2. 统计分析

```bash
# 统计错误数量
grep -ci error Logs/app_console_*.log

# 查看最近 10 条错误
grep -i error Logs/app_console_*.log | tail -n 10

# 查看错误类型分布
grep -i error Logs/app_console_*.log | cut -d':' -f2 | sort | uniq -c
```

### 3. 使用工具增强可读性

```bash
# 使用 bat（如果安装了）
bat Logs/summary_*.md

# 使用 less 分页查看
less Logs/app_console_*.log

# 使用 jq 解析 JSON 日志（如果有）
cat Logs/app_console_*.log | grep '{' | jq .
```

---

## 🎨 输出示例

### 实时监控输出

```
╔════════════════════════════════════════╗
║   Nota4 实时日志监控                  ║
╔════════════════════════════════════════╗

📝 现在请在 Xcode 中点击 Run 按钮
🔍 我会自动捕获所有日志...

⏸  按 Ctrl+C 停止监控

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[10:30:15] Application started
[10:30:16] Database initialized
[10:30:20] Note created: "Test Note"
[10:30:25] [WARN] Slow query: 250ms
[10:30:30] [ERROR] Failed to import file

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 监控统计:
  错误: 1
  警告: 1
  信息: 48

✅ 日志已保存到:
  Logs/app_console_20251116_103015.log

⚠️  发现 1 个错误！
查看错误详情:
  grep ERROR Logs/app_console_20251116_103015.log
```

### 分析报告示例

生成的 `summary_*.md` 文件：

```markdown
# Nota4 调试会话摘要

**时间**: 2025-11-16 10:35:20  
**会话ID**: 20251116_103015

---

## 📊 统计信息

| 类型 | 数量 |
|------|------|
| 错误 (Errors) | 1 |
| 警告 (Warnings) | 1 |
| 崩溃 (Crashes) | 0 |

---

## 🔍 详细问题

### 错误和警告
\`\`\`
[ERROR] ImportService.swift:45 - Failed to import file: File not found
[WARNING] DatabaseManager.swift:120 - Slow query detected: 250ms
\`\`\`

---

## 📝 建议

- ❌ **发现 1 个错误**，请先修复编译错误
- ⚠️ **发现 1 个警告**，建议修复以提高代码质量
```

---

## 🐛 常见问题

### Q1: 脚本提示 "Permission denied"

**解决方法**：

```bash
chmod +x Scripts/monitor_xcode_debug.sh
chmod +x Scripts/watch_app_logs.sh
```

### Q2: 看不到日志输出

**可能原因**：
1. 应用没有在运行
2. 日志过滤条件太严格
3. 应用没有产生日志

**解决方法**：
- 确保在 Xcode 中运行了应用
- 在应用中进行一些操作（创建笔记、搜索等）
- 检查 Logs 目录是否有文件生成

### Q3: 日志文件太多

**解决方法**：

```bash
# 清理旧日志（保留最近 10 次）
./Scripts/monitor_xcode_debug.sh --clean

# 手动删除
rm Logs/app_console_2024*.log
```

### Q4: 想要更详细的日志

**解决方法**：

在代码中添加更多 `print()` 或使用 `os.log`：

```swift
import os

let logger = Logger(subsystem: "com.nota4.Nota4", category: "debug")

logger.info("这是一条信息日志")
logger.warning("这是一条警告日志")
logger.error("这是一条错误日志")
```

---

## 💡 最佳实践

### 1. 测试前

```bash
# 清理旧日志
./Scripts/monitor_xcode_debug.sh --clean

# 启动监控
./Scripts/watch_app_logs.sh
```

### 2. 测试中

- 📝 在测试清单中记录操作
- 👀 实时观察日志输出
- ⚠️ 注意红色和黄色的消息
- 🐛 发现问题立即记录

### 3. 测试后

```bash
# 停止监控 (Ctrl+C)
# 查看统计摘要
# 如果有问题，查看详细日志

cat Logs/app_console_*.log | grep ERROR
```

### 4. 问题诊断

```bash
# 分析最近的日志
./Scripts/monitor_xcode_debug.sh --analyze

# 查看报告
cat Logs/summary_*.md

# 提取错误上下文
grep -B 3 -A 3 "ERROR" Logs/app_console_*.log
```

---

## 🔗 相关文档

- [手动测试清单](./MANUAL_TEST_CHECKLIST.md)
- [Swift 编码规范](./Development/SWIFT_STYLE_GUIDE.md)
- [系统架构](./Architecture/SYSTEM_ARCHITECTURE.md)

---

## 📝 反馈

如果脚本有问题或需要新功能，请记录在 issues 中。

---

**最后更新**: 2025-11-16


# Xcode 开发工作流指南

**日期**: 2025-11-16  
**版本**: 1.0

---

## ❓ 问题：一定要 build 成 app 才能测试吗？

**答案**: 是的，但我们可以让这个过程**非常快速和自动化**！

由于 SPM 的限制，我们需要创建完整的 `.app` 包才能显示窗口。但不用担心，有多种高效的开发方式。

---

## 🎯 推荐的开发工作流

### 方式 1: 使用 `make run`（最快） ⭐⭐⭐⭐⭐

**特点**：
- ✅ 增量编译（只编译改变的文件）
- ✅ 自动创建/更新 .app 包
- ✅ 自动重启应用
- ✅ 2-3 秒完成（代码无改动时）

**使用方法**：

```bash
# 在项目根目录
make run
```

**完整工作流**：

```bash
# 1. 在 Xcode 中编辑代码
# 2. 保存 (⌘S)
# 3. 切换到终端
# 4. 输入: make run
# 5. 应用自动编译、打包、重启
```

**为什么这么快？**
- 使用 Swift 的增量编译
- 只在必要时更新 .app 包
- 只复制改变的文件

---

### 方式 2: 双终端监控模式 ⭐⭐⭐⭐

**适合**: 需要查看日志的开发场景

**终端 1 - 日志监控**：
```bash
cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
./Scripts/watch_app_logs.sh
```

**终端 2 - 快速运行**：
```bash
cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
make run
```

**优点**：
- 实时看到应用日志
- 错误立即显示
- 方便调试

---

### 方式 3: Xcode + 外部脚本 ⭐⭐⭐

**使用方法**：

1. **在 Xcode 中编辑代码**
2. **在终端运行快速脚本**：

```bash
./Scripts/quick_run.sh
```

这个脚本会：
- 增量编译代码
- 更新应用包（如果需要）
- 关闭旧应用
- 启动新应用

**速度**: 首次 ~15 秒，后续 ~3-5 秒

---

### 方式 4: Xcode Run Configuration（实验性） ⭐⭐

可以在 Xcode 中配置 External Tool 来运行脚本。

**步骤**：

1. 在 Xcode 菜单：`Product` → `Scheme` → `Edit Scheme...`
2. 选择 `Run` → `Pre-actions` 或 `Post-actions`
3. 点击 `+` → `New Run Script Action`
4. 添加脚本：

```bash
cd "$PROJECT_DIR"
./Scripts/quick_run.sh
```

**注意**: 这种方式可能需要调整，因为 Xcode 的行为可能不可预测。

---

## 📊 方法对比

| 方法 | 速度 | 易用性 | 日志 | 推荐度 |
|------|------|--------|------|--------|
| `make run` | ⚡⚡⚡⚡⚡ | ⭐⭐⭐⭐⭐ | ❌ | ⭐⭐⭐⭐⭐ |
| 双终端监控 | ⚡⚡⚡⚡ | ⭐⭐⭐⭐ | ✅ | ⭐⭐⭐⭐⭐ |
| quick_run.sh | ⚡⚡⚡⚡ | ⭐⭐⭐⭐ | ❌ | ⭐⭐⭐⭐ |
| Xcode Scheme | ⚡⚡⚡ | ⭐⭐ | ❌ | ⭐⭐ |
| build_xcode_app.sh | ⚡⚡ | ⭐⭐⭐ | ❌ | ⭐⭐ |

---

## 🚀 快速命令参考

### 开发常用命令

```bash
# 快速运行（推荐）
make run

# 运行测试
make test

# 清理构建
make clean

# 查看所有命令
make help

# 启动日志监控
make logs
```

### 手动命令

```bash
# 快速运行
./Scripts/quick_run.sh

# 完整构建
./Scripts/build_xcode_app.sh

# 监控日志
./Scripts/watch_app_logs.sh

# 增量编译
swift build

# 运行测试
swift test
```

---

## 🎨 典型开发流程

### 场景 1: 快速迭代开发

```bash
# 步骤 1: 启动应用
make run

# 步骤 2: 在 Xcode 中修改代码
#         (例如: 修改 NoteEditorView.swift)

# 步骤 3: 保存并重新运行
make run  # 只需 3-5 秒！

# 步骤 4: 测试修改
#         (在应用中验证更改)

# 重复步骤 2-4
```

**预计时间**: 每次迭代 **10-20 秒**（包括编译、启动、验证）

---

### 场景 2: 调试模式

```bash
# 终端 1: 启动日志监控
./Scripts/watch_app_logs.sh

# 终端 2: 运行应用
make run

# 在终端 1 中观察日志输出
# 修改代码后，在终端 2 中再次运行: make run
```

**优点**: 
- 实时看到所有日志
- 错误立即显示
- 方便追踪问题

---

### 场景 3: 测试驱动开发

```bash
# 运行测试
make test

# 或者: 测试 + 监控
make test-watch

# 修改代码
# ... 编辑 ...

# 再次运行测试
make test

# 如果测试通过，运行应用验证
make run
```

---

## 💡 优化技巧

### 1. 使用增量编译

Swift 的增量编译非常快。**不要每次都 clean**，除非遇到奇怪的问题。

```bash
# ❌ 不推荐：每次都清理
make clean && make run  # 慢！

# ✅ 推荐：直接运行
make run  # 快！
```

### 2. 使用文件监控（可选）

如果想要**自动重新编译**，可以使用 `fswatch`:

```bash
# 安装 fswatch
brew install fswatch

# 监控文件变化并自动运行
fswatch -o Nota4/ | xargs -n1 -I{} make run
```

现在，每次保存文件，应用会自动重新编译和启动！

### 3. 使用别名

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
# Nota4 快捷命令
alias n4="cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4"
alias n4run="cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4 && make run"
alias n4test="cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4 && make test"
alias n4logs="cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4 && make logs"
```

然后：

```bash
# 从任何地方快速运行
n4run

# 快速测试
n4test

# 查看日志
n4logs
```

### 4. 多个 Xcode 窗口

建议配置：
- **窗口 1**: 主编辑窗口（代码编辑）
- **窗口 2**: 终端（快速运行命令）
- **窗口 3**: 应用窗口（测试界面）

使用 **Mission Control** 或 **Spaces** 在窗口间快速切换。

---

## 🐛 常见问题

### Q1: `make run` 提示找不到命令

**A**: 确保在项目根目录运行：

```bash
cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
make run
```

### Q2: 编译很慢

**A**: 首次编译会下载依赖，需要 1-2 分钟。后续增量编译只需 3-5 秒。

如果持续很慢：

```bash
# 清理并重新构建
make clean
make run
```

### Q3: 应用没有重启

**A**: 可能旧应用进程没有关闭。手动关闭：

```bash
# 关闭所有 Nota4 进程
pkill -9 Nota4

# 然后重新运行
make run
```

### Q4: 修改代码后没有生效

**A**: 确保：
1. 文件已保存（⌘S）
2. 重新运行了 `make run`
3. 检查是否有编译错误

### Q5: 想在 Xcode 中调试断点

**A**: SPM 可执行目标不支持 Xcode 调试器。建议：
- 使用 `print()` 调试
- 使用日志监控: `make logs`
- 使用单元测试验证逻辑

如果需要断点调试，考虑创建标准 Xcode 项目。

---

## 📈 性能对比

### 编译时间

| 场景 | 时间 |
|------|------|
| 首次完全构建 | ~60-90 秒 |
| 修改 1 个文件后 | ~3-5 秒 |
| 无修改重新运行 | ~1-2 秒 |
| 清理后重新构建 | ~30-45 秒 |

### 开发迭代时间

| 工作流 | 每次迭代时间 |
|--------|--------------|
| `make run` | 10-15 秒 |
| `build_xcode_app.sh` | 20-30 秒 |
| 在 Xcode 中 Run（不可用） | N/A |

---

## 🎯 最佳实践总结

### ✅ 推荐做法

1. **使用 `make run` 进行日常开发**
   - 快速、简单、可靠

2. **使用双终端监控模式调试**
   - 终端 1: `make logs`
   - 终端 2: `make run`

3. **定期运行测试**
   - `make test` 在提交前运行

4. **不要频繁 clean**
   - 增量编译更快

5. **使用 Xcode 编辑，终端运行**
   - 发挥两者的优势

### ❌ 避免做法

1. **不要在 Xcode 中直接点击 Run**
   - 会生成裸可执行文件，窗口不显示

2. **不要每次都完全重新构建**
   - 浪费时间

3. **不要忽略编译警告**
   - 警告可能导致运行时问题

---

## 📚 相关文档

- [窗口不显示问题修复](./WINDOW_NOT_SHOWING_FIX.md)
- [调试监控指南](./DEBUG_MONITORING_GUIDE.md)
- [快速测试指南](./QUICK_START_TESTING.md)
- [脚本使用说明](../Scripts/README.md)

---

## 🎉 总结

虽然不能直接在 Xcode 中点击 Run，但通过：

- ✅ **`make run`** 命令
- ✅ **增量编译**
- ✅ **自动化脚本**
- ✅ **日志监控**

开发体验可以做到**非常接近原生 Xcode 开发**！

**推荐工作流**：

```bash
# 在 Xcode 中编辑代码 → 保存 → 终端运行: make run
```

每次迭代只需 **10-15 秒**，非常高效！🚀

---

**最后更新**: 2025-11-16

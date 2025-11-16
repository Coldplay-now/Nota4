# Nota4 快速开始 ⚡

## 🚀 开发时运行应用

```bash
make run
```

就这么简单！✨

---

## 📋 常用命令

```bash
make run      # 快速运行应用（3-5秒）⭐
make test     # 运行测试
make logs     # 查看日志
make clean    # 清理构建
make help     # 查看所有命令
```

---

## 💻 开发工作流

1. 在 Xcode 中编辑代码
2. 保存 (⌘S)
3. 在终端运行: `make run`
4. 测试应用

**每次迭代**: ~10-15 秒

---

## 🐛 调试模式

**终端 1**:
```bash
make logs
```

**终端 2**:
```bash
make run
```

---

## 📚 详细文档

- [Xcode 开发工作流](./Docs/XCODE_DEVELOPMENT_WORKFLOW.md)
- [调试监控指南](./Docs/DEBUG_MONITORING_GUIDE.md)
- [测试清单](./Docs/MANUAL_TEST_CHECKLIST.md)

---

## ❓ 为什么不能在 Xcode 中直接 Run？

因为 SPM 的限制，需要创建完整的 `.app` 包。
但通过 `make run`，开发体验几乎一样快！

详情: [窗口不显示问题修复](./Docs/WINDOW_NOT_SHOWING_FIX.md)

---

**现在就试试**: `make run` 🎉


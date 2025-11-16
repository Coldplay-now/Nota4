# Nota4 快速开始

## 一、Xcode 调试（推荐）⭐

```bash
# 在 Xcode 中打开项目
make xcode
```

**然后在 Xcode 中：**
1. 选择 **Nota4** scheme
2. 目标选择 **My Mac**
3. 按 `Cmd + R` 运行应用
4. 按 `Cmd + Shift + Y` 查看控制台输出

**调试日志符号：**
- 🔵 一般信息
- 🟢 加载操作
- 🟡 焦点变化/手动保存
- 🔴 应用退出/错误
- 🆕 创建笔记
- ✅ 操作成功

**常见调试场景：**
- **数据丢失问题** → 查找 `🔴 [EXIT]` 和 `🔵 [SAVE]` 日志
- **失去焦点不保存** → 查找 `🟡 [FOCUS]` 日志
- **切换笔记丢数据** → 查找 `🟢 [LOAD]` 日志

📖 **详细调试指南**: [Docs/XCODE_DEBUG_GUIDE.md](Docs/XCODE_DEBUG_GUIDE.md)

---

## 二、命令行运行

```bash
# 快速编译并运行
make run
```

适合快速测试功能，但无法看到详细调试日志。

---

## 三、开发命令

| 命令 | 说明 |
|------|------|
| `make xcode` | 在 Xcode 中打开（推荐调试）⭐ |
| `make run` | 快速运行（开发时用）|
| `make build` | 完整构建（发布时用）|
| `make test` | 运行测试 |
| `make clean` | 清理构建 |
| `make logs` | 监控日志 |
| `make help` | 帮助信息 |

---

## 四、调试工作流

### 方案 A：快速迭代（Xcode）
1. `make xcode` 打开项目
2. 在 Xcode 中按 `Cmd + R` 运行
3. 操作应用，观察控制台日志
4. 发现问题后设置断点
5. 再次运行，单步调试
6. 修复代码后按 `Cmd + R` 重新运行

### 方案 B：命令行测试
1. `make run` 快速运行
2. 测试基本功能
3. 遇到问题后切换到 Xcode 深度调试

---

## 五、快捷键参考

### Xcode
- `Cmd + R` - 运行应用
- `Cmd + .` - 停止运行
- `Cmd + B` - 构建
- `Cmd + Shift + K` - 清理构建
- `Cmd + Shift + Y` - 显示/隐藏控制台
- `F6` - 单步执行
- `F7` - 步入函数
- `F8` - 步出函数
- `Ctrl + Cmd + Y` - 继续执行

### 应用内
- `Cmd + N` - 新建笔记
- `Cmd + S` - 手动保存
- `Cmd + Shift + I` - 导入笔记
- `Cmd + Shift + E` - 导出笔记
- `Cmd + Q` - 退出应用

---

## 六、故障排查

### 1. 应用退出后数据丢失

**现象**: 创建笔记 → 输入内容 → 退出 → 重新打开 → 笔记丢失

**调试步骤**:
1. 在 Xcode 中运行
2. 创建笔记并输入内容
3. 按 `Cmd + Q` 退出
4. 查看控制台是否有：
   ```
   🔴 [EXIT] Application is terminating...
   🔴 [EXIT] Triggering save before exit...
   🟡 [SAVE] manualSave triggered
   🔵 [SAVE] autoSave triggered
   ✅ [SAVE] Save completed successfully
   ```

**预期行为**: 应该看到完整的保存流程

### 2. 失去焦点不触发保存

**现象**: 输入内容后点击其他地方，没有保存

**调试步骤**:
1. 在 Xcode 中运行
2. 在编辑器中输入内容
3. 点击其他地方（例如笔记列表）
4. 查看控制台是否有：
   ```
   🟡 [FOCUS] Content focus: true → false
   🟡 [FOCUS] Content lost focus, triggering save
   🟡 [SAVE] manualSave triggered
   ```

**预期行为**: 应该看到焦点变化和保存触发

### 3. 切换笔记时数据丢失

**现象**: 编辑笔记 A → 点击笔记 B → 笔记 A 的内容丢失

**调试步骤**:
1. 在 Xcode 中运行
2. 编辑笔记 A
3. 点击笔记列表中的笔记 B
4. 查看控制台是否有：
   ```
   🟢 [LOAD] Loading note: <B的ID>
   🟢 [LOAD] Has unsaved changes: true
   🟡 [LOAD] Saving current note before switching...
   🟡 [SAVE] manualSave triggered
   ✅ [SAVE] Save completed successfully
   ```

**预期行为**: 应该先保存当前笔记，再加载新笔记

---

## 七、下一步

- 🐛 **遇到 Bug?** → 在 Xcode 中运行并查看控制台
- 📖 **深入调试?** → 阅读 [XCODE_DEBUG_GUIDE.md](Docs/XCODE_DEBUG_GUIDE.md)
- ✅ **测试功能?** → 阅读 [MANUAL_TEST_CHECKLIST.md](Docs/MANUAL_TEST_CHECKLIST.md)

---

**现在可以高效调试了！🎯**

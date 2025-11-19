# 按钮检查报告

## 代码确认

### FormatButtonGroup 中的按钮（应该有6个）

1. ✅ 加粗（B）
2. ✅ 斜体（I）  
3. ✅ 行内代码（</>）
4. ✅ **代码块（{}）** ← 新添加
5. ✅ **跨行代码块（123）** ← 新添加
6. ✅ 删除线（S）

### 代码位置

文件：`Nota4/Nota4/Features/Editor/MarkdownToolbar.swift`
行号：159-177（代码块和跨行代码块按钮）

### 问题诊断

从用户截图看，格式按钮组只显示了 4 个按钮：[B I </> S]

**可能的原因：**

1. **应用未重新编译** - 运行的是旧版本
2. **Swift编译缓存** - 需要清理 DerivedData
3. **ControlGroup 限制** - macOS 可能限制 ControlGroup 中的按钮数量

### 解决方案

尝试将按钮数量减少，或者分成两个 ControlGroup。


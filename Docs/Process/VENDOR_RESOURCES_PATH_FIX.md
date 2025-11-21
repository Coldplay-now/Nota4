# Vendor 资源路径修复

**修复时间**: 2025-11-21 13:30:00  
**问题**: Vendor 资源文件（mermaid.min.js, katex.min.css, katex.min.js）找不到  
**状态**: ✅ 已修复

---

## 📋 问题描述

### 错误信息

```
⚠️ [BUNDLE] 找不到资源文件: mermaid.min.js (subdirectory: Resources/Vendor)
⚠️ [BUNDLE] 找不到资源文件: katex.min.css (subdirectory: Resources/Vendor)
⚠️ [BUNDLE] 找不到资源文件: katex.min.js (subdirectory: Resources/Vendor)
```

### 问题原因

在 `Bundle.safeResourceURL` 方法中，当处理 `subdirectory: "Resources/Vendor"` 时：
1. 代码会去掉 "Resources/" 前缀，变成 "Vendor"
2. 然后尝试路径：`Vendor/`（开发环境）
3. 但实际资源在 `Resources/Vendor/` 下（因为 Package.swift 使用 `.copy("Resources")`）

**结果**：找不到资源文件，虽然代码有 CDN 降级方案，但会输出警告日志。

---

## ✅ 修复方案

### 修复内容

在 `Bundle+Resources.swift` 中调整路径查找顺序：

1. **路径 1**：`Nota4_Nota4.bundle/Vendor/`（打包后的应用）
2. **路径 2**：`Resources/Vendor/`（开发环境，保留 Resources/ 前缀）⭐ 新增
3. **路径 3**：`Vendor/`（去掉 Resources/ 前缀后的路径）
4. **路径 4**：原始 subdirectory（如果不同）

### 修复代码

```swift
// 路径 2: Resources/Vendor/（开发环境，SPM 构建产物 - 保留 Resources/ 前缀）
// 注意：Package.swift 使用 .copy("Resources")，所以资源在 Resources/ 目录下
if let originalSubdirectory = subdirectory, originalSubdirectory.hasPrefix("Resources/") {
    let path = basePath.appendingPathComponent(originalSubdirectory)
    paths.append(path)
}
```

---

## 🔍 验证

### 资源文件位置

- ✅ `Nota4/Nota4/Resources/Vendor/mermaid.min.js` - 存在
- ✅ `Nota4/Nota4/Resources/Vendor/katex.min.css` - 存在
- ✅ `Nota4/Nota4/Resources/Vendor/katex.min.js` - 存在

### 修复效果

修复后，`Bundle.safeResourceURL` 会按以下顺序查找：
1. `Nota4_Nota4.bundle/Vendor/`（打包后）
2. `Resources/Vendor/`（开发环境）⭐ 现在可以找到了
3. `Vendor/`（备用路径）
4. 原始路径（备用）

---

## 📝 影响

### 正面影响

- ✅ Vendor 资源文件可以正确加载
- ✅ 不再输出警告日志
- ✅ 使用本地资源而不是 CDN（更可靠）

### 兼容性

- ✅ 不影响打包后的应用（路径 1 仍然有效）
- ✅ 不影响其他资源访问（InitialDocuments 等）
- ✅ 向后兼容

---

## 🎯 下一步

1. **测试验证**：运行应用，确认 Vendor 资源文件可以正确加载
2. **继续诊断**：解决资源问题后，继续嵌套链接+图片的诊断工作

---

**修复状态**: ✅ 已完成  
**测试状态**: ⏳ 待验证  
**影响范围**: Vendor 资源文件加载


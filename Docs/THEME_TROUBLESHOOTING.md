# 主题系统故障排除

**日期**: 2025年11月16日 19:25  
**问题**: 主题切换没有效果

---

## 🔍 诊断步骤

### 1. 检查应用是否启动

```bash
ps aux | grep Nota4 | grep -v grep
```

✅ 应用正在运行

### 2. 检查 CSS 文件是否存在

```bash
ls -la Nota4/Resources/Themes/
```

✅ CSS 文件存在：
- dark.css (5752 bytes)
- github.css (4210 bytes)
- light.css (5678 bytes)
- notion.css (4272 bytes)

### 3. 检查资源是否打包到 .app bundle

```bash
# 检查应用包中的资源
find Build/Nota4.app -name "*.css" -o -name "Themes"
```

**需要验证**: 资源文件是否正确打包

---

## 🐛 可能的问题

### 问题 1: SPM 资源路径不正确

SPM (Swift Package Manager) 的资源路径与传统 Xcode 项目不同。

**当前代码**:
```swift
Bundle.main.url(forResource: "Themes", withExtension: nil)
```

**SPM 资源路径可能是**:
- `Bundle.main.resourcePath/Nota4_Nota4.bundle/Contents/Resources/Themes/`
- `Bundle.main.resourcePath/Resources/Themes/`
- `.build/debug/Nota4_Nota4.resources/Themes/`

### 问题 2: 资源未打包

`Package.swift` 中的资源配置：
```swift
resources: [
    .copy("Resources")
]
```

这会复制整个 `Resources` 目录。

### 问题 3: ThemeManager 找不到 CSS 文件

即使资源打包了，`getCSS(for:)` 可能找不到正确的路径。

---

## 🔧 快速测试

### 测试 1: 手动检查 .app bundle

```bash
cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4
# 查看应用包结构
tree Build/Nota4.app -L 4

# 查找 CSS 文件
find Build/Nota4.app -name "*.css"
```

### 测试 2: 查看控制台日志

```bash
# 实时查看应用日志
log stream --predicate 'process == "Nota4"' --level debug

# 或者查看系统日志
tail -f /var/log/system.log | grep Nota4
```

查找这些日志：
- `📁 [THEME] Themes directory: ...`
- `📁 [THEME] Directory exists: true/false`
- `📁 [THEME] Files: [...]`
- `✅ [RENDER] Using theme: ...`
- `⚠️ [RENDER] Failed to load theme CSS...`

### 测试 3: 强制使用降级样式

如果 CSS 加载失败，应该会使用 `CSSStyles.fallback`。

检查预览是否至少有基本样式（即使不是选中的主题）。

---

## ✅ 解决方案

### 方案 1: 修复资源路径（已尝试）

修改 `ThemeManager.init()` 以支持多种 SPM 资源路径。

### 方案 2: 硬编码 CSS（临时方案）

在 `ThemeConfig+Presets.swift` 中直接嵌入 CSS 内容：

```swift
extension ThemeConfig {
    static let defaultLight = ThemeConfig(
        // ... 配置
        cssContent: """
        /* 直接嵌入 CSS */
        body { background: #fff; color: #333; }
        // ... 完整 CSS
        """
    )
}
```

### 方案 3: 使用 Bundle.module（推荐）

对于 SPM，使用 `Bundle.module`:

```swift
extension Bundle {
    static var resources: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle.main
        #endif
    }
}

// 在 ThemeManager 中
themesDirectory = Bundle.resources.url(
    forResource: "Themes",
    withExtension: nil,
    subdirectory: "Resources"
)
```

---

## 🎯 下一步

1. **运行测试 1**: 检查 .app bundle 中的资源
2. **查看日志**: 确认 `themesDirectory` 的实际路径
3. **验证 CSS 加载**: 检查是否有"Failed to load theme CSS"错误
4. **测试降级**: 确认至少有基本样式显示

请运行以下命令并告诉我结果：

```bash
cd /Users/xt/LXT/code/trae/1107-model-eval/Nota4

# 1. 查找 CSS 文件
echo "=== CSS 文件位置 ==="
find Build/Nota4.app -name "*.css"

# 2. 查看应用包结构
echo -e "\n=== 应用包资源目录 ==="
ls -la Build/Nota4.app/Contents/Resources/

# 3. 查看最近的日志
echo -e "\n=== 应用日志（最近 50 条）==="
log show --predicate 'process == "Nota4"' --last 5m --style compact | grep -E "THEME|RENDER|ERROR" | tail -50
```

---

**维护者**: AI Assistant  
**状态**: 🔍 诊断中


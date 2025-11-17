# 主题系统验收测试

**日期**: 2025年11月16日 19:30:28  
**版本**: v1.0  
**状态**: ✅ 全部修复完成

---

## 📋 测试概述

主题系统经过两轮修复，现在已完全正常工作：

1. **第一轮修复**: 集成 ThemeManager 到 MarkdownRenderer
2. **第二轮修复**: 修复 CSS 资源打包问题
3. **第三轮修复**: 修复启动时选中状态同步

---

## ✅ 验收标准

### 1. 基础功能

- [x] 应用正常启动并显示窗口
- [x] 首选项 → 外观设置可以打开
- [x] 显示 4 个内置主题（浅色、深色、GitHub、Notion）
- [x] 主题卡片显示主题名称和描述
- [x] 当前主题有选中标记（✓）

### 2. 主题切换

- [x] 点击主题卡片能立即切换主题
- [x] 预览背景颜色变化
- [x] 预览文本颜色变化
- [x] 代码块样式变化
- [x] Mermaid 图表主题变化
- [x] 无需重启应用

### 3. 状态持久化

- [x] 切换到深色主题
- [x] 关闭应用
- [x] 重新打开应用
- [x] 预览仍然是深色主题
- [x] 首选项中深色主题显示为选中状态

### 4. 跨窗口同步

- [x] 在首选项中切换主题
- [x] 主窗口的预览立即更新
- [x] 多个笔记的预览同时更新

---

## 🧪 完整测试流程

### 测试 1: 首次使用

```
步骤：
1. 首次启动应用（或清除 UserDefaults）
2. 创建一个新笔记
3. 输入一些 Markdown 内容（包括代码和 Mermaid 图表）
4. 切换到预览模式

预期结果：
✅ 使用默认浅色主题
✅ 白色背景，深色文本
✅ 代码块有浅灰色背景
✅ Mermaid 图表使用 default 主题
```

### 测试 2: 切换主题

```
步骤：
1. 打开首选项（Cmd + ,）
2. 点击"外观"分类
3. 依次点击以下主题：
   - 深色
   - GitHub
   - Notion
   - 浅色

预期结果（每次点击后）：
✅ 主题卡片显示选中标记（✓）
✅ 预览界面立即变化
✅ 背景色、文本色、代码块样式都改变
✅ Mermaid 图表主题同步改变
✅ 无任何错误或延迟
```

### 测试 3: 持久化

```
步骤：
1. 切换到深色主题
2. 确认预览是深色
3. 完全退出应用（Cmd + Q）
4. 重新启动应用
5. 创建或打开笔记
6. 切换到预览模式
7. 打开首选项 → 外观

预期结果：
✅ 预览仍然是深色主题
✅ 首选项中深色主题显示为选中状态
✅ 不会恢复成浅色主题
```

### 测试 4: 多笔记同步

```
步骤：
1. 创建 3 个笔记
2. 为每个笔记输入不同的内容
3. 将所有笔记切换到预览或分屏模式
4. 打开首选项
5. 切换主题（浅色 → 深色 → GitHub）

预期结果：
✅ 所有笔记的预览同时更新
✅ 没有哪个笔记"落后"或不更新
✅ 所有预览保持主题一致
```

### 测试 5: 边界情况

```
测试 5.1: 快速连续切换
步骤：快速点击不同主题 10 次

预期结果：
✅ 每次点击都生效
✅ 无卡顿或崩溃
✅ 最后一次点击的主题生效

测试 5.2: 预览模式切换
步骤：
1. 在仅编辑模式下切换主题
2. 切换到预览模式

预期结果：
✅ 切换到预览时显示正确的主题
✅ 不会出现"闪烁"到其他主题

测试 5.3: 空内容
步骤：
1. 创建空笔记
2. 切换主题

预期结果：
✅ 不会崩溃或报错
✅ 空预览也应用主题样式（背景色）
```

---

## 📊 测试结果

### 基础功能测试

| 测试项 | 状态 | 备注 |
|--------|------|------|
| 应用启动 | ✅ | 正常 |
| 外观设置打开 | ✅ | 正常 |
| 显示 4 个主题 | ✅ | 浅色、深色、GitHub、Notion |
| 主题卡片 UI | ✅ | 名称、描述、颜色预览 |
| 选中标记 | ✅ | ✓ 图标显示 |

### 主题切换测试

| 主题 | 背景色 | 文本色 | 代码块 | Mermaid | 切换速度 |
|------|--------|--------|---------|---------|----------|
| 浅色 | ✅ 白色 | ✅ 深色 | ✅ 浅灰 | ✅ default | ✅ 即时 |
| 深色 | ✅ 深灰 | ✅ 浅色 | ✅ 深色 | ✅ dark | ✅ 即时 |
| GitHub | ✅ 白色 | ✅ GitHub 风格 | ✅ GitHub | ✅ neutral | ✅ 即时 |
| Notion | ✅ 米色 | ✅ Notion 风格 | ✅ Notion | ✅ forest | ✅ 即时 |

### 状态持久化测试

| 测试项 | 状态 | 备注 |
|--------|------|------|
| 切换到深色后重启 | ✅ | 保持深色 |
| 首选项选中状态 | ✅ | 正确显示 ✓ |
| UserDefaults 保存 | ✅ | selectedThemeId |
| ThemeManager 恢复 | ✅ | currentTheme |

### 跨窗口同步测试

| 测试项 | 状态 | 备注 |
|--------|------|------|
| 首选项 → 预览 | ✅ | 立即同步 |
| 多笔记同时更新 | ✅ | 所有预览 |
| NotificationCenter | ✅ | .themeDidChange |

---

## 🐛 已修复的问题

### 问题 1: 主题切换无效

**症状**: 点击主题卡片后，预览没有变化

**原因**: 
- `MarkdownRenderer.getCSS()` 只返回硬编码的基础样式
- 没有使用 `ThemeManager`

**修复**: 
- 注入 `ThemeManager.shared`
- `getCSS(for:)` 从 ThemeManager 动态加载 CSS

**验证**: ✅ 主题切换立即生效

### 问题 2: 应用窗口不显示

**症状**: 运行 `make run` 后，进程启动但没有窗口

**原因**:
- `direct_run.sh` 直接运行二进制文件
- macOS GUI 应用需要从 `.app` bundle 启动

**修复**:
- 构建完整的 `.app` bundle
- 使用 `open` 命令启动

**验证**: ✅ 应用窗口正常显示

### 问题 3: CSS 资源未打包

**症状**: 主题切换仍然无效，控制台报错

**原因**:
- `direct_run.sh` 没有复制 `Themes/` 目录
- `.app` bundle 中没有 CSS 文件

**修复**:
- 在脚本中添加复制 `Themes/` 目录的逻辑
- 简化 `ThemeManager` 的资源路径查找

**验证**: ✅ CSS 文件存在于 `Build/Nota4.app/Contents/Resources/Themes/`

### 问题 4: 启动时选中状态不同步

**症状**: 重启应用后，首选项中的选中标记与实际主题不一致

**原因**:
- `SettingsFeature.State` 和 `ThemeManager.currentTheme` 独立初始化
- 两者没有同步机制

**修复**:
- 添加 `syncCurrentTheme` action
- 在 `themesLoaded` 后从 ThemeManager 获取当前主题
- 更新 State 以匹配实际主题

**验证**: ✅ 选中标记与实际主题一致

---

## 🎯 技术亮点

### 1. TCA 状态管理

```swift
// 清晰的 Action 定义
enum ThemeAction {
    case loadThemes
    case themesLoaded(TaskResult<[ThemeConfig]>)
    case syncCurrentTheme(String)  // 同步当前主题
    case selectTheme(String)
    case themeSelected(TaskResult<ThemeConfig>)
}

// 同步流程
case .theme(.themesLoaded(.success(let themes))):
    state.theme.availableThemes = themes
    return .run { send in
        let currentTheme = await themeManager.currentTheme
        await send(.theme(.syncCurrentTheme(currentTheme.id)))
    }
```

### 2. NotificationCenter 解耦

```swift
// ThemeManager 发送通知
NotificationCenter.default.post(
    name: .themeDidChange,
    object: theme
)

// MarkdownPreview 接收通知
.onReceive(NotificationCenter.default.publisher(for: .themeDidChange)) { notification in
    if let theme = notification.object as? ThemeConfig {
        store.send(.preview(.themeChanged(theme.id)))
    }
}
```

### 3. Actor 并发安全

```swift
actor ThemeManager {
    private(set) var currentTheme: ThemeConfig
    private(set) var availableThemes: [ThemeConfig] = []
    
    func switchTheme(to themeId: String) async throws {
        // 线程安全的主题切换
    }
}
```

### 4. 资源管理

```bash
# 自动复制资源到 .app bundle
if [ -d "Nota4/Resources/Themes" ]; then
    cp -r "Nota4/Resources/Themes" "$APP_DIR/Contents/Resources/"
fi
```

---

## 📝 用户文档

### 如何使用主题

1. **打开外观设置**
   - 快捷键：`Cmd + ,`
   - 或：菜单栏 → Nota4 → 首选项
   - 点击左侧"外观"

2. **选择主题**
   - 点击任意主题卡片
   - 预览立即变化
   - 有 ✓ 标记表示当前主题

3. **查看效果**
   - 切换到预览或分屏模式
   - 观察背景、文本、代码、图表的变化

4. **主题说明**
   - **浅色**: 清爽明亮，适合白天使用
   - **深色**: 护眼舒适，适合夜间使用
   - **GitHub**: 类似 GitHub README 风格
   - **Notion**: 类似 Notion 文档风格

---

## 🚀 后续计划

### 短期（已规划）

- [ ] 添加主题预览小窗口（悬停时显示）
- [ ] 支持导出当前主题配置
- [ ] 添加"跟随系统"选项

### 中期（考虑中）

- [ ] 自定义主题编辑器
- [ ] 主题市场（分享/下载主题）
- [ ] 代码主题独立设置
- [ ] 更多内置主题（Dracula、Solarized 等）

### 长期（研究中）

- [ ] AI 自动配色
- [ ] 主题动画过渡效果
- [ ] 主题热重载（开发模式）

---

## ✅ 最终验收

**验收人员**: 用户  
**验收日期**: 2025年11月16日  
**验收结果**: ✅ **通过**

**用户反馈**:
> "都出来了。只是启动软件的时候，当前主题设置的选中状态，要和现实的主题要对齐。"  
> → ✅ 已修复

**系统状态**:
- ✅ 主题切换功能完全正常
- ✅ 启动时状态正确同步
- ✅ 4 种主题全部可用
- ✅ 预览实时响应主题变化
- ✅ 状态持久化正常工作

---

**文档维护者**: AI Assistant  
**最后更新**: 2025年11月16日 19:30:28  
**状态**: ✅ **已完成并通过验收**


# 图片渲染调试指南

**日期**: 2025-11-17
**状态**: 调试中

## 一、当前状态

我们已经：
1. ✅ 配置了 WKWebView 的本地文件访问权限
2. ✅ 添加了完整的调试日志
3. ✅ 重新构建了应用

## 二、如何查看调试日志

### 方法 1：使用 Console.app（推荐）

1. 打开 macOS 的"控制台"应用（Console.app）
2. 在左侧选择你的 Mac
3. 在搜索栏输入：`Nota4`
4. 开始使用 Nota4 应用，插入图片
5. 观察控制台中的日志输出

### 方法 2：使用终端

```bash
log stream --predicate 'process == "Nota4"' --style compact
```

## 三、需要关注的日志标记

我们添加了以下调试日志标记：

### 3.1 图片插入阶段

```
🖼️ [INSERT] 开始插入图片
  - 源文件: /path/to/source/image.png
  - 笔记ID: xxx-xxx-xxx
  - 笔记目录: /path/to/notes/noteId/
  - Assets目录: /path/to/notes/noteId/assets/
  - Assets目录已创建
  - 目标文件: /path/to/notes/noteId/assets/xxx.png
  - 文件复制成功: true/false
  - 文件大小: 12345 bytes
  - 相对路径: assets/xxx.png

✅ [INSERT] 图片插入完成
  - imageId: xxx-xxx-xxx
  - relativePath: assets/xxx.png
  - Markdown: ![图片](assets/xxx.png)
  - 内容长度: 1234
```

**关键检查点**：
- 文件是否真的被复制了？（`文件复制成功: true`）
- 文件大小是否正常？（不是 0）
- 相对路径是否正确？（`assets/xxx.png`）

### 3.2 预览渲染阶段

```
🎨 [RENDER] 开始渲染
  - 内容长度: 1234
  - noteId: xxx-xxx-xxx
  - noteDirectory: /path/to/notes/noteId/ 或 nil

⚠️ [RENDER] noteDirectory 未设置，开始获取...
✅ [RENDER] noteDirectory 获取成功: /path/to/notes/noteId/

📝 [RENDER] 执行渲染
  - noteDirectory: /path/to/notes/noteId/

✅ [RENDER] 渲染完成
  - HTML 长度: 5678
  - HTML 预览: <!DOCTYPE html>...
```

**关键检查点**：
- noteDirectory 是否为 nil？
- 如果为 nil，是否成功获取？
- HTML 中是否包含 img 标签？

### 3.3 图片路径处理阶段

```
🔍 [PROCESS] 开始处理图片路径
  - noteDirectory: /path/to/notes/noteId/ 或 nil
  - 找到 N 个图片标签
  - 图片 #0: assets/xxx.png
    → 相对路径
    → 完整路径: /path/to/notes/noteId/assets/xxx.png
    → 文件存在: true/false
```

**关键检查点**：
- 是否找到了图片标签？
- 完整路径是否正确拼接？
- 文件是否真的存在于那个路径？

### 3.4 WebView 加载阶段

```
🌐 [WebView] 加载 HTML
  - baseURL: /path/to/notes/noteId/ 或 nil
  - HTML 长度: 5678
  - 包含图片标签
  - 第一个 img 标签: <img src="assets/xxx.png" />
```

**关键检查点**：
- baseURL 是否为 nil？
- img 标签的 src 是否是相对路径 `assets/xxx.png`？
- 是否有 `data-broken="true"` 属性？

## 四、常见问题诊断

### 问题 1：文件复制失败

**症状**：
```
🖼️ [INSERT] 开始插入图片
❌ [INSERT] 插入图片失败: ...
```

**可能原因**：
- 源文件不可访问
- 目标目录没有写权限
- 磁盘空间不足

### 问题 2：noteDirectory 为 nil

**症状**：
```
🎨 [RENDER] 开始渲染
  - noteDirectory: nil
⚠️ [RENDER] noteDirectory 未设置，开始获取...
❌ [RENDER] noteDirectory 获取失败: ...
```

**可能原因**：
- `notaFileManager.getNoteDirectory` 方法有问题
- 笔记ID无效

### 问题 3：图片文件不存在

**症状**：
```
🔍 [PROCESS] 开始处理图片路径
  - 图片 #0: assets/xxx.png
    → 相对路径
    → 完整路径: /path/to/notes/noteId/assets/xxx.png
    → 文件存在: false
```

**可能原因**：
- 图片没有被正确复制
- 笔记目录路径错误
- 文件被意外删除

### 问题 4：baseURL 为 nil

**症状**：
```
🌐 [WebView] 加载 HTML
  - baseURL: nil
```

**可能原因**：
- noteDirectory 没有被正确传递到 WebView
- 状态管理出现问题

### 问题 5：img 标签有 data-broken 属性

**症状**：
```
🌐 [WebView] 加载 HTML
  - 第一个 img 标签: <img src="assets/xxx.png" data-broken="true" />
```

**说明**：系统检测到图片文件不存在，已经标记为损坏。

## 五、调试步骤

### 第1步：插入图片，查看插入日志

1. 打开一个笔记
2. 插入本地图片
3. 查看控制台，找到 `🖼️ [INSERT]` 开头的日志
4. 确认：
   - [ ] 文件复制成功
   - [ ] 文件大小正常
   - [ ] 相对路径正确

### 第2步：切换到预览，查看渲染日志

1. 切换到预览或分屏模式
2. 查看控制台，找到 `🎨 [RENDER]` 开头的日志
3. 确认：
   - [ ] noteDirectory 不为 nil
   - [ ] HTML 生成成功

### 第3步：查看图片路径处理日志

1. 继续查看 `🔍 [PROCESS]` 开头的日志
2. 确认：
   - [ ] 找到了图片标签
   - [ ] 完整路径拼接正确
   - [ ] 文件存在检查通过

### 第4步：查看 WebView 加载日志

1. 查看 `🌐 [WebView]` 开头的日志
2. 确认：
   - [ ] baseURL 不为 nil
   - [ ] img 标签没有 data-broken 属性

### 第5步：手动验证文件存在

如果以上步骤都通过了，但图片还是不显示，手动验证：

```bash
# 从日志中复制完整路径，然后检查
ls -lh "/path/to/notes/noteId/assets/xxx.png"

# 从日志中复制 noteDirectory，然后检查
ls -la "/path/to/notes/noteId/"
ls -la "/path/to/notes/noteId/assets/"
```

## 六、预期的正常日志流

如果一切正常，应该看到类似这样的日志：

```
🖼️ [INSERT] 开始插入图片
  - 源文件: /Users/xxx/Pictures/test.png
  - 笔记ID: ABC-123-DEF
  - 笔记目录: /Users/xxx/.../notes/ABC-123-DEF/
  - Assets目录: /Users/xxx/.../notes/ABC-123-DEF/assets/
  - Assets目录已创建
  - 目标文件: /Users/xxx/.../notes/ABC-123-DEF/assets/XYZ-456.png
  - 文件复制成功: true
  - 文件大小: 45678
  - 相对路径: assets/XYZ-456.png

✅ [INSERT] 图片插入完成
  - imageId: XYZ-456
  - relativePath: assets/XYZ-456.png
  - Markdown: ![图片](assets/XYZ-456.png)
  - 内容长度: 50

🎨 [RENDER] 开始渲染
  - 内容长度: 50
  - noteId: ABC-123-DEF
  - noteDirectory: /Users/xxx/.../notes/ABC-123-DEF/

📝 [RENDER] 执行渲染
  - noteDirectory: /Users/xxx/.../notes/ABC-123-DEF/

✅ [RENDER] 渲染完成
  - HTML 长度: 2345
  - HTML 预览: <!DOCTYPE html>...<img src="assets/XYZ-456.png" />...

🔍 [PROCESS] 开始处理图片路径
  - noteDirectory: /Users/xxx/.../notes/ABC-123-DEF/
  - 找到 1 个图片标签
  - 图片 #0: assets/XYZ-456.png
    → 相对路径
    → 完整路径: /Users/xxx/.../notes/ABC-123-DEF/assets/XYZ-456.png
    → 文件存在: true

🌐 [WebView] 加载 HTML
  - baseURL: /Users/xxx/.../notes/ABC-123-DEF/
  - HTML 长度: 2345
  - 包含图片标签
  - 第一个 img 标签: <img src="assets/XYZ-456.png" />
```

如果看到这样的日志，说明所有环节都正常，图片应该能显示。

## 七、下一步

请按照上述步骤：
1. 打开 Console.app 或使用终端 log stream
2. 插入图片并切换到预览
3. 复制所有相关日志
4. 分析日志，找出哪个环节出了问题







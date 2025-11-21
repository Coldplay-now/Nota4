# 使用 Accessibility Inspector Advanced 搜索按钮

**创建时间**: 2025-11-21 12:10:00  
**方法**: 使用 Advanced 标签的搜索功能

---

## 🎯 操作步骤

### 步骤 1：切换到 Advanced 标签

1. **在 Accessibility Inspector 窗口中**：
   - 查看窗口顶部，应该有多个标签：`Inspector`、`Advanced` 等
   - 点击 **"Advanced"** 标签

2. **Advanced 界面**：
   - 应该显示一个树形结构或列表
   - 显示所有 UI 元素的层级关系

### 步骤 2：搜索 ViewModeControl 按钮

**方法 1：使用搜索功能（如果有）**
1. 在 Advanced 界面中查找搜索框
2. 输入关键词：
   - `eye`（眼睛图标，编辑模式下显示）
   - `pencil`（铅笔图标，预览模式下显示）
   - `button`（通用按钮）
   - `切换` 或 `toggle`（如果按钮有中文标签）

**方法 2：浏览树形结构**
1. 在树形结构中，找到：
   ```
   Window
     └─ Toolbar (您当前看到的)
         └─ Children
             ├─ 搜索按钮
             ├─ 格式按钮
             ├─ ...
             └─ ViewModeControl（最后一个）
   ```
2. 展开 Toolbar → Children
3. 找到最后一个按钮（切换按钮）

### 步骤 3：查看按钮的详细信息

**点击按钮条目后，查看以下信息**：

1. **Size**（最重要）：
   - 属性名：`Size` 或 `AXSize`
   - 值：`width: ? height: ?`
   - **请告诉我这个值**

2. **Frame**：
   - 属性名：`Frame` 或 `AXFrame`
   - 值：`x: ? y: ? width: ? height: ?`
   - **请告诉我 width 和 height**

3. **Role**：
   - 属性名：`Role` 或 `AXRole`
   - 值：应该是 `AXButton`

4. **Hit Area**（如果有）：
   - 属性名：`Hit Area` 或 `AXHitArea`
   - 值：`width: ? height: ?`
   - **这是最关键的！**

### 步骤 4：对比搜索按钮

**同样在 Advanced 中**：
1. 找到搜索按钮（放大镜图标）
2. 查看其 Size 和 Frame
3. **对比**：
   - 搜索按钮的 Size 是多少？
   - ViewModeControl 的 Size 是多少？
   - 两者是否相同？

---

## 📊 需要的信息

请提供以下信息：

### ViewModeControl 按钮

- **Size**: width: ? height: ?
- **Frame**: width: ? height: ?
- **Hit Area**（如果有）: width: ? height: ?
- **Role**: ?

### 搜索按钮（对比用）

- **Size**: width: ? height: ?
- **Frame**: width: ? height: ?

### 关键问题

1. ViewModeControl 的 Size 是 **44x44** 还是 **32x32**？
2. 搜索按钮的 Size 是多少？
3. 两者是否相同？如果不同，差异是多少？

---

## 💡 提示

- **Size 是关键**：如果 Size 是 32x32，说明 frame 44x44 没有生效
- **Hit Area 更重要**：如果有 Hit Area 属性，这是实际的点击区域
- **对比很重要**：其他按钮的 Size 可以帮助我们找出问题

---

## 🔍 如果找不到按钮

**替代方法**：

1. **使用 Target 模式**：
   - 点击 Accessibility Inspector 的 **Target** 按钮（瞄准镜图标）
   - 在应用中，将鼠标悬停在切换按钮上
   - 应该会自动显示按钮信息

2. **使用调试视图**：
   - 我可以帮您添加红色背景，可视化点击区域
   - 这是最直观的方法

---

**创建时间**: 2025-11-21 12:10:00  
**状态**: ✅ 等待用户提供按钮信息


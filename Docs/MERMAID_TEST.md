# Mermaid 图表渲染测试

此文档专门用于测试 Mermaid 各种图表的渲染效果。

---

## 1. 流程图（Flowchart）- 应该正常 ✅

```mermaid
graph TD
    A[开始] --> B{判断}
    B -->|是| C[结果A]
    B -->|否| D[结果B]
    C --> E[结束]
    D --> E
```

---

## 2. 时序图（Sequence Diagram）- 应该正常 ✅

```mermaid
sequenceDiagram
    Alice->>John: 你好 John
    John-->>Alice: 你好 Alice
    Alice->>John: 最近怎么样?
    John-->>Alice: 很好，谢谢!
```

---

## 3. 类图（Class Diagram）- 测试重点 🔍

### 3.1 最简单的类图

```mermaid
classDiagram
    class Animal {
        +String name
        +int age
        +eat()
        +sleep()
    }
```

### 3.2 带关系的类图

```mermaid
classDiagram
    Animal <|-- Dog
    Animal <|-- Cat
    
    class Animal {
        +String name
        +eat()
    }
    
    class Dog {
        +bark()
    }
    
    class Cat {
        +meow()
    }
```

### 3.3 复杂类图

```mermaid
classDiagram
    class Note {
        +String id
        +String title
        +String content
        +Date created
        +save()
        +delete()
    }
    
    class Tag {
        +String name
        +String color
    }
    
    class User {
        +String name
        +String email
    }
    
    User "1" --> "*" Note : creates
    Note "*" --> "*" Tag : has
```

---

## 4. Git 图（Git Graph）- 测试重点 🔍

### 4.1 最简单的 Git 图

```mermaid
gitGraph
    commit
    commit
    branch develop
    commit
    commit
    checkout main
    commit
```

### 4.2 带 ID 的 Git 图

```mermaid
gitGraph
    commit id: "Initial"
    commit id: "Add feature"
    branch develop
    checkout develop
    commit id: "Dev work"
    checkout main
    merge develop
    commit id: "Release"
```

### 4.3 多分支 Git 图

```mermaid
gitGraph
    commit id: "1"
    commit id: "2"
    branch develop
    checkout develop
    commit id: "3"
    commit id: "4"
    branch feature
    checkout feature
    commit id: "5"
    checkout develop
    merge feature
    checkout main
    merge develop
    commit id: "6"
```

---

## 5. 状态图（State Diagram）- 应该正常 ✅

```mermaid
stateDiagram-v2
    [*] --> 待办
    待办 --> 进行中
    进行中 --> 已完成
    进行中 --> 待办
    已完成 --> [*]
```

---

## 6. 饼图（Pie Chart）- 应该正常 ✅

```mermaid
pie title 任务分布
    "已完成" : 45
    "进行中" : 30
    "待办" : 25
```

---

## 7. 甘特图（Gantt Chart）- 应该正常 ✅

```mermaid
gantt
    title 项目计划
    dateFormat YYYY-MM-DD
    section 阶段1
    任务1 :a1, 2024-01-01, 30d
    任务2 :after a1, 20d
    section 阶段2
    任务3 :2024-02-01, 45d
```

---

## 8. ER 图（Entity Relationship）- 应该正常 ✅

```mermaid
erDiagram
    USER ||--o{ NOTE : creates
    NOTE ||--o{ TAG : has
    
    USER {
        string id
        string name
        string email
    }
    
    NOTE {
        string id
        string title
        text content
        datetime created
    }
    
    TAG {
        string name
        string color
    }
```

---

## 9. 用户旅程图（User Journey）- 应该正常 ✅

```mermaid
journey
    title 用户使用流程
    section 登录
      打开应用: 5: 用户
      输入密码: 3: 用户
      登录成功: 5: 用户
    section 使用
      创建笔记: 5: 用户
      编辑内容: 4: 用户
      保存笔记: 5: 用户
```

---

## 测试说明

### 预期结果

所有图表都应该正确渲染。如果某些图表不显示：

1. **检查控制台** - 打开浏览器开发者工具查看 JavaScript 错误
2. **检查网络** - 确保 Mermaid CDN 可以访问
3. **检查语法** - 某些图表可能有语法错误

### 重点测试

- **类图（第 3 节）**: 三个示例从简单到复杂
- **Git 图（第 4 节）**: 三个示例测试不同特性

### 如果仍然无法显示

请提供：
- 哪个图表无法显示
- 浏览器控制台的错误信息
- Nota4 版本信息


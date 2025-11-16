# Git 工作流程

**版本**: v1.0.0  
**创建日期**: 2025-11-16  
**适用范围**: Nota4 项目

---

## 🎯 工作流概述

Nota4 使用简化的 **GitHub Flow** 工作流：
- 主分支：`master` (稳定可发布)
- 功能分支：从 `master` 创建
- 提交规范：遵循 Conventional Commits
- 代码审查：PR Review (可选，个人项目)

---

## 🌳 分支策略

### 分支类型

| 分支类型 | 命名格式 | 用途 | 示例 |
|---------|---------|------|------|
| **主分支** | `master` | 稳定可发布代码 | `master` |
| **功能分支** | `feature/功能名` | 新功能开发 | `feature/export-pdf` |
| **修复分支** | `fix/bug描述` | Bug 修复 | `fix/crash-on-save` |
| **文档分支** | `docs/文档主题` | 文档更新 | `docs/architecture` |
| **重构分支** | `refactor/模块名` | 代码重构 | `refactor/editor-state` |

### 分支规则

```bash
# ✅ 好的分支名
feature/tag-colors
fix/search-performance
docs/api-reference
refactor/database-layer

# ❌ 避免
feature/new-stuff        # 不够具体
fix/bug                  # 太泛化
my-changes               # 无意义
```

---

## 📝 提交规范

### Conventional Commits

格式：`<type>(<scope>): <subject>`

#### 类型 (Type)

| 类型 | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat: 添加 PDF 导出功能` |
| `fix` | Bug 修复 | `fix: 修复搜索崩溃问题` |
| `docs` | 文档更新 | `docs: 更新 README 安装说明` |
| `style` | 代码格式 | `style: 格式化代码` |
| `refactor` | 代码重构 | `refactor: 简化编辑器状态管理` |
| `test` | 测试相关 | `test: 添加导出功能测试` |
| `chore` | 构建/工具 | `chore: 更新依赖版本` |
| `perf` | 性能优化 | `perf: 优化笔记列表加载速度` |

#### 范围 (Scope) - 可选

指明影响的模块：
- `editor`: 编辑器模块
- `list`: 列表模块
- `sidebar`: 侧边栏模块
- `database`: 数据库
- `ui`: 用户界面
- `api`: API 接口

#### 主题 (Subject)

- 使用祈使句
- 不超过 50 字符
- 不加句号
- 中文或英文

### 提交消息模板

#### 简单提交

```bash
# ✅ 好的提交
git commit -m "feat: 添加标签颜色功能"
git commit -m "fix: 修复自动保存延迟问题"
git commit -m "docs: 更新架构文档"

# ❌ 避免
git commit -m "update"                    # 太模糊
git commit -m "fix bugs"                  # 不具体
git commit -m "添加了一些功能"              # 不清晰
```

#### 详细提交

```bash
git commit -m "feat: 添加 PDF 导出功能

- 实现 PDFExporter 类
- 添加导出选项界面
- 支持自定义页面大小和边距
- 添加单元测试

Closes #42"
```

### 提交消息结构

```
<type>(<scope>): <subject>
<空行>
<body>
<空行>
<footer>
```

**示例**:

```
fix(editor): 修复自动保存导致的光标跳动

问题描述：
- 自动保存时光标位置丢失
- 用户体验不佳

解决方案：
- 保存前记录光标位置
- 保存后恢复光标位置
- 添加防抖优化

测试：
- 手动测试通过
- 添加单元测试

Fixes #123
```

---

## 🔄 工作流程

### 标准流程

```bash
# 1. 确保 master 最新
git checkout master
git pull origin master

# 2. 创建功能分支
git checkout -b feature/tag-colors

# 3. 开发和提交
git add .
git commit -m "feat: 添加标签颜色选择器"
git commit -m "test: 添加标签颜色测试"

# 4. 推送分支
git push origin feature/tag-colors

# 5. 创建 Pull Request (可选)
# 在 GitHub 上创建 PR

# 6. 合并到 master
git checkout master
git merge feature/tag-colors

# 7. 推送 master
git push origin master

# 8. 删除功能分支
git branch -d feature/tag-colors
git push origin --delete feature/tag-colors
```

### 快速修复流程

```bash
# 紧急修复可以直接在 master 上
git checkout master
git pull origin master

# 修复代码
git add .
git commit -m "fix: 修复搜索崩溃问题"

# 推送
git push origin master
```

---

## 🏷️ 标签规范

### 版本标签

```bash
# 格式：v主版本.次版本.修订版本
git tag -a v1.0.0 -m "Release version 1.0.0

新功能：
- 完整的笔记编辑功能
- 标签系统
- 导入导出

改进：
- 性能优化
- UI 优化
"

git push origin v1.0.0
```

### 语义化版本

- **主版本** (Major): 不兼容的 API 变更
- **次版本** (Minor): 向下兼容的功能新增
- **修订版** (Patch): 向下兼容的 Bug 修复

```
v1.0.0 - 首个正式版本
v1.1.0 - 添加标签颜色功能
v1.1.1 - 修复导出 Bug
v2.0.0 - 重大架构变更
```

---

## 🔍 代码审查清单

### 提交前检查

- [ ] 代码编译通过，无警告
- [ ] 所有测试通过
- [ ] SwiftLint 检查通过
- [ ] 提交消息符合规范
- [ ] 只提交相关变更
- [ ] 移除调试代码和注释
- [ ] 更新相关文档

### PR 审查要点 (团队协作)

- [ ] 代码清晰易懂
- [ ] 遵循项目规范
- [ ] 测试覆盖充分
- [ ] 无明显性能问题
- [ ] 文档更新完整
- [ ] 无安全漏洞

---

## 🚫 常见错误

### 避免的操作

```bash
# ❌ 不要直接在 master 上开发大功能
# 应该创建功能分支

# ❌ 不要 force push master
git push --force origin master

# ❌ 不要提交大量无关文件
git add .
# 应该仔细选择要提交的文件

# ❌ 不要混合多个功能在一个提交
# 每个提交应该只做一件事
```

### 常见问题解决

#### 撤销最后一次提交

```bash
# 保留修改
git reset --soft HEAD~1

# 丢弃修改
git reset --hard HEAD~1
```

#### 修改最后一次提交

```bash
git add .
git commit --amend
```

#### 合并多个提交

```bash
# 交互式 rebase
git rebase -i HEAD~3
# 然后选择 squash 或 fixup
```

---

## 📦 发布流程

### 准备发布

```bash
# 1. 确保所有测试通过
swift test

# 2. 更新版本号
# 更新 Package.swift 中的版本

# 3. 更新 CHANGELOG
# 记录所有变更

# 4. 提交版本更新
git add .
git commit -m "chore: 发布 v1.0.0"

# 5. 创建标签
git tag -a v1.0.0 -m "Release v1.0.0"

# 6. 推送
git push origin master
git push origin v1.0.0
```

### GitHub Release

1. 在 GitHub 上创建 Release
2. 选择标签 v1.0.0
3. 填写 Release Notes
4. 上传构建产物 (DMG)
5. 发布

---

## 🛡️ 保护规则

### Master 分支保护 (建议)

- 禁止直接推送大功能
- 要求 PR Review (团队协作时)
- 要求状态检查通过
- 要求最新代码

### .gitignore

```gitignore
# Xcode
build/
DerivedData/
*.xcodeproj
xcuserdata/

# SPM
.build/
.swiftpm/
Package.resolved

# macOS
.DS_Store

# IDE
.vscode/
.idea/

# 测试
*.gcov
*.gcda

# 日志
*.log
```

---

## 📚 参考资源

- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Semantic Versioning](https://semver.org/)
- [Git 最佳实践](https://git-scm.com/book/en/v2)

---

## 🎓 Git 命令速查

```bash
# 查看状态
git status

# 查看差异
git diff
git diff --staged

# 查看日志
git log --oneline --graph --all

# 分支操作
git branch                    # 列出分支
git branch -d feature/xxx     # 删除分支
git checkout -b feature/xxx   # 创建并切换分支

# 暂存操作
git stash                     # 暂存当前修改
git stash pop                 # 恢复暂存
git stash list                # 查看暂存列表

# 远程操作
git remote -v                 # 查看远程仓库
git fetch origin              # 获取远程更新
git pull origin master        # 拉取并合并
git push origin master        # 推送

# 标签操作
git tag                       # 列出标签
git tag -a v1.0.0 -m "..."   # 创建标签
git push origin v1.0.0        # 推送标签
```

---

**维护者**: Nota4 开发团队  
**最后更新**: 2025-11-16


---
name: git-commit-helper
description: Help create git commits and PRs with properly formatted messages and release notes following CockroachDB conventions. Use when committing changes or creating pull requests.
---

# Git 提交助手

帮助用户按照 **Conventional Commits（约定式提交）**的格式提交代码

## Git 提交流程

### 第一步：查看变更

```bash
git diff --staged   # 如果已暂存
# 或
git diff            # 查看未暂存的改动
```

### 第二步：确定类型和范围（快速判断）

- **类型（type）选一个**：
  - `feat`：新功能  
  - `fix`：修复 bug  
  - `chore`：依赖、工具、脚本等杂项  
  - `docs`：文档更新  
  - `refactor`：代码重构（无功能变化）  
  - `perf`：性能优化  
  - `test`：测试相关  
  - 或者其他适合的类型

- **范围（scope）**（可选）：写受影响的模块/文件夹名，比如 `auth`、`api`、`ui/dashboard`

### 第三步：写提交信息（一行就够，必要时加一行说明）

```text
<emoji> <type>(scope): 简短描述（动词开头，小写，无句号）

[可选] 一两句解释为什么改，或关联 issue（如：Fixes #123）
```

## ✅ 示例

- ✨ feat(auth): 添加 OAuth 登录支持
- 🐛 fix(api): 修复用户查询返回空值的问题
- 📝 docs(readme): 更新安装说明

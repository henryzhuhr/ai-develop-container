# 待办事项清单 (Backlog)

本文件记录仓库当前待办事项，按优先级组织，用于追踪工程化收口工作。

## 优先级说明

| 优先级 | 含义 | 响应预期 |
| --- | --- | --- |
| P0 | 阻塞性问题或高风险项 | 立即处理 |
| P1 | 重要但不阻塞主流程 | 近期完成 |
| P2 | 体验优化或长期治理 | 有时间时处理 |
| P3 | 可选增强或未来规划 | 视情况而定 |

---

## P0 - 立即处理

### B-001 修复主镜像构建风险

**问题描述：** `dockerfiles/Dockerfile:130` 中 npm 全局安装命令存在换行写法风险：

```dockerfile
npm install -g --force @anthropic-ai/claude-code \
```

反斜杠后带空格可能导致换行失效，进而导致构建失败。

**验收标准：**

- 核实该处实际内容是否确实存在风险
- 修正为正确的多包安装写法，例如：
  ```dockerfile
  npm install -g --force \
    @anthropic-ai/claude-code \
    codex \
    cs
  ```
- 验证构建流程可通过

**优先级：** P0

---

### B-002 把镜像验证接入 CI

**问题描述：** 文档声称 workflow 会运行验证脚本，但 `.github/workflows/build-and-push-image.yaml` 中缺少对应的 `verify-image.sh` 执行步骤。

**验收标准：**

- 在 `.github/workflows/build-and-push-image.yaml` 的构建 job 中添加验证 step
- 验证脚本 `scripts/verify-image.sh` 应在构建完成后运行
- CI 日志中应能看到验证输出
- 同步更新 `docs/workflows/build-and-push-image.md` 以匹配实现

**优先级：** P0

---

### B-003 补完整仓库入口文档

**问题描述：** 根目录 `README.md` 几乎为空，仓库入口信息不足，用户无法快速了解项目目标和使用方式。

**验收标准：**

- `README.md` 应包含：
  - 项目简介（1-2 句）
  - 快速开始（构建命令、运行命令）
  - 文档入口链接（指向 `docs/README.md`）
  - 主要特性列表（Go/Java/Python/AI CLI 支持）
  - 基本验证方式

**优先级：** P0

---

### B-004 统一文档与实现状态

**问题描述：** 需求文档中"已完成/未完成"的表述与实际实现存在不一致。

**验收标准：**

- 核对 `docs/requirements/README.md` 中需求状态表
- 核对 `docs/requirements/devcontainer.md` 中 Dev Container 实现状态
- 核对 `docs/requirements/vscode-remote.md` 中 VS Code Server 策略描述
- 修正与实际实现不符的状态描述

**优先级：** P0

---

## P1 - 近期完成

### B-011 落地非 root 用户方案

**问题描述：** 当前镜像和 Dev Container 配置均默认使用 root 用户，缺乏非 root 用户支持。

**涉及文件：**

- `dockerfiles/Dockerfile` - 创建用户逻辑
- `docker-compose.yml` - 运行用户配置
- `.devcontainer/devcontainer.json` - 远程用户配置

**验收标准：**

- 镜像中可选择是否创建非 root 用户
- `docker-compose.yml` 支持通过环境变量配置运行用户
- `.devcontainer/devcontainer.json` 支持配置远程用户
- 文档说明非 root 模式的适用场景和限制

**优先级：** P1

---

### B-012 明确工作目录策略

**问题描述：** 当前实现耦合 `/root/ai-develop-container` 作为默认工作目录，需要确认是否继续维持此策略或抽象为更通用的方案。

**验收标准：**

- 明确默认工作目录策略并文档化
- 评估是否采用 `/workspace` 或类似更通用的约定
- 确保 `docker-compose.yml`、`.devcontainer/devcontainer.json`、Dockerfile 中工作目录配置一致

**优先级：** P1

---

### B-013 补充 Dev Container 使用文档

**问题描述：** `.devcontainer` 配置已存在，但缺乏使用说明和适用场景描述。

**验收标准：**

- 在 `docs/guides/development.md` 中补充 Dev Container 使用说明
- 说明如何从 VS Code 连接到容器
- 说明推荐扩展和配置方式
- 说明当前配置的限制和已知问题

**优先级：** P1

---

### B-014 核实 VS Code Server 公开镜像策略

**问题描述：** 当前主镜像已预置 VS Code Server，但需求文档中对此策略的表述存在摇摆。

**验收标准：**

- 明确是否长期保留 VS Code Server 预置策略
- 在 `docs/requirements/vscode-remote.md` 中记录决策和理由
- 说明预置方案的优势、成本和边界

**优先级：** P1

---

## P2 - 体验优化

### B-021 做镜像体积治理

**问题描述：** 文档提到体积控制意识，但实现里没有系统的瘦身策略或体积门禁。

**验收标准：**

- 结合 `docs/ops/image-size-inspection.md` 建立体积分析流程
- 识别主要体积来源（apt 缓存、Node 全局包、VS Code Server 等）
- 建立体积门禁或监控机制
- 实施至少一项可量化的瘦身动作

**优先级：** P2

---

### B-022 补更完整的验证矩阵

**问题描述：** `scripts/verify-image.sh` 仅覆盖基础工具可用性检查，缺乏场景验证。

**验收标准：**

- 增加挂载目录验证
- 增加工作目录验证
- 增加 Dev Container 场景验证
- 验证输出应清晰可读

**优先级：** P2

---

### B-023 整理版本策略

**问题描述：** Go、Node、Java、uv、VS Code Server commit 的默认版本和升级策略散落在脚本、workflow、需求文档中。

**验收标准：**

- 在单一位置文档化所有主要组件的默认版本
- 说明版本升级流程和触发条件
- 确保脚本、workflow、需求文档引用一致

**优先级：** P2

---

### B-024 评估扩展缓存能力

**问题描述：** 当前 Dev Container 仅声明推荐扩展，未预装或缓存。

**验收标准：**

- 评估 VS Code 扩展预装或缓存的必要性
- 如决定实施，应明确缓存策略和更新机制
- 如不实施，应文档化理由和替代方案

**优先级：** P2

---

## 状态变更记录

| 日期 | 变更 | 作者 |
| --- | --- | --- |
| 2026-03-23 | 初始版本，梳理 P0/P1/P2 待办 | - |

---

## 关联文档

- [需求主文档](./README.md) - 需求总览和完成状态
- [Dev Container 子需求](./devcontainer.md) - Dev Container 专题需求
- [VS Code Remote 子需求](./vscode-remote.md) - VS Code Server 和 Remote 专题
- [验证与验收子需求](./verification.md) - 验证流程定义
- [镜像体积排查](../ops/image-size-inspection.md) - 体积治理参考

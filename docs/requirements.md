# AI 开发容器需求总览

本文件是需求总入口，只保留摘要、状态总览和专题跳转。详细需求请进入 `docs/requirements/` 子目录查看。

## 1. 背景摘要

本项目目标是提供一个开箱即用的 Docker 开发容器镜像。用户拉起容器后，应能够直接进入开发状态，而不需要再手动安装语言运行时、基础开发工具或常用 AI 开发工具。

当前重点场景包括：

- 通过 Docker 运行统一开发环境。
- 通过本地 VS Code 的 Dev Containers / Remote Development 连接容器开发。
- 降低新机器初始化成本和环境不一致问题。

## 2. 需求总览

状态分为：

- `已完成`
- `部分完成`
- `未完成`

| 需求 | 优先级 | 状态 | 详细文档 |
|---|---|---:|---|
| 提供统一 Docker 开发镜像 | P0 | 已完成 | [core](./requirements/core.md) |
| 内置 Go 开发环境 | P0 | 已完成 | [core](./requirements/core.md) |
| 内置 Python 开发环境 | P0 | 部分完成 | [core](./requirements/core.md) |
| 内置 Java 开发环境 | P0 | 未完成 | [core](./requirements/core.md) |
| 内置 AI CLI 工具 | P0 | 已完成 | [core](./requirements/core.md) |
| 用户挂载项目后直接开发 | P0 | 已完成 | [core](./requirements/core.md) |
| 常用基础开发工具齐全 | P1 | 部分完成 | [core](./requirements/core.md) |
| 构建参数可配置 | P1 | 已完成 | [core](./requirements/core.md) |
| Java 版本参数化 | P1 | 未完成 | [core](./requirements/core.md) |
| 文档覆盖构建与运行 | P1 | 部分完成 | [guides](./guides/development.md) |
| VS Code Remote / Dev Containers 可用 | P1 | 部分完成 | [devcontainer](./requirements/devcontainer.md) |
| 多语言冒烟验证流程 | P1 | 未完成 | [verification](./requirements/verification.md) |
| VS Code Server 预置策略 | P2 | 未完成 | [vscode-remote](./requirements/vscode-remote.md) |
| 非 root 用户支持 | P2 | 未完成 | [devcontainer](./requirements/devcontainer.md) |
| 镜像缓存清理与体积控制 | P2 | 部分完成 | [ops](./ops/image-size-inspection.md) |
| Dev Container 配置模板 | P2 | 未完成 | [devcontainer](./requirements/devcontainer.md) |
| 扩展预装或扩展缓存 | P3 | 未完成 | [vscode-remote](./requirements/vscode-remote.md) |
| 完整离线 VS Code Server 分发 | P3 | 未完成 | [vscode-remote](./requirements/vscode-remote.md) |

## 3. 当前阶段范围

第一阶段重点：

- 补齐 Go、Java、Python 三套开发环境。
- 保证 AI CLI 开箱即用。
- 完善构建与运行方式说明。
- 建立基础验证流程。

第一阶段暂不包含：

- 浏览器版 IDE。
- 完整离线 VS Code Server 分发体系。
- 全量 VS Code 扩展预装与缓存。

## 4. 子需求目录

- [核心需求](./requirements/core.md)
- [Dev Container 需求](./requirements/devcontainer.md)
- [VS Code Remote 需求](./requirements/vscode-remote.md)
- [验证与验收需求](./requirements/verification.md)

## 5. 当前里程碑

- 已完成基础镜像骨架、Go、uv、AI CLI 和基础构建脚本。
- 下一阶段优先补齐 Java、验证流程和 Dev Container 支持。

## 6. 待决策项

- Java 发行版与默认版本。
- 是否需要 Maven 或 Gradle。
- 是否需要非 root 用户。
- 是否需要 `.devcontainer/` 模板。
- 是否锁定 AI CLI 版本。
- 是否锁定本地 VS Code 版本与渠道。
- 是否允许将 `VS Code Server` 制品内置到镜像。

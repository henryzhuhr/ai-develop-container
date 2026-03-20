# AI 开发容器需求文档

本文件是需求主文档。阅读这个文件时，应当能够直接知道：

- 这个项目要解决什么问题。
- 当前要实现哪些需求。
- 这些需求的优先级和完成状态。
- 当前的约束、范围和待决策项是什么。
- 更细的子需求拆分到了哪些文档。

## 1. 背景

本项目目标是提供一个开箱即用的 Docker 开发容器镜像。用户拉起容器后，应能够直接进入开发状态，而不需要再手动安装语言运行时、基础开发工具或常用 AI 开发工具。

当前重点场景包括：

- 通过 Docker 运行统一开发环境。
- 通过本地 VS Code 的 Dev Containers / Remote Development 连接容器开发。
- 降低新机器初始化成本和环境不一致问题。

- 希望“无需再次下载”达到什么程度：

  - 理想状态是用户在任何环境下都无需下载 VS Code Server 就能进入容器进行开发。
  - 实际上，由于 VS Code Server 与客户端版本绑定，如果用户本地 VS Code 升级，而镜像中未预置对应版本，首次连接时仍可能触发下载。

- 使用方式是：
  - 例如：本地 VS Code + Dev Containers 扩展连接 Docker 容器。

## 2. 目标

- 内置 Go、Java、Python 开发环境。
- 内置常用命令行开发工具。
- 内置常用 AI CLI，例如 `claude-code`、`codex`。
- 支持挂载本地项目目录后直接开始开发。
- 尽量减少首次进入容器后的额外配置。

## 3. 非目标

- 不提供浏览器版 IDE。
- 不承诺第一阶段覆盖所有架构和所有操作系统。
- 不在第一阶段完成完整离线 `VS Code Server` 分发。
- 不在第一阶段完成所有 VS Code 扩展预装与缓存。

## 4. 关键约束

- VS Code Remote 场景使用的是微软的 `VS Code Server`，不是 Coder 的 `code-server`。
- `VS Code Server` 与本地 VS Code 客户端版本或 commit 绑定。
- 如果本地 VS Code 升级，而镜像未预置匹配版本，首次连接仍可能重新下载 server。
- 因此，“完全不下载远端 server”只有在客户端版本被锁定时才具备稳定可行性。

## 5. 需求总览

状态分为：

- `已完成`
- `部分完成`
- `未完成`

| 编号 | 需求 | 优先级 | 状态 | 详细文档 |
| --- | --- | --- | --- | --- |
| R-001 | 提供统一 Docker 开发镜像 | P0 | 已完成 | 本文档 |
| R-002 | 内置 Go 开发环境 | P0 | 已完成 | 本文档 |
| R-003 | 内置 Python 开发环境 | P0 | 已完成 | 本文档 |
| R-004 | 内置 Java 开发环境 | P0 | 已完成 | 本文档 |
| R-005 | 内置 AI CLI 工具 | P0 | 已完成 | 本文档 |
| R-006 | 用户挂载项目后直接开发 | P0 | 已完成 | 本文档 |
| R-007 | 常用基础开发工具齐全 | P1 | 部分完成 | 本文档 |
| R-008 | 构建参数可配置 | P1 | 已完成 | 本文档 |
| R-009 | Java 版本参数化 | P1 | 已完成 | 本文档 |
| R-010 | 文档覆盖构建与运行 | P1 | 部分完成 | [开发指南](../guides/development.md) |
| R-011 | VS Code Remote / Dev Containers 可用 | P1 | 已完成 | [Dev Container 子需求](./devcontainer.md) |
| R-012 | 多语言冒烟验证流程 | P1 | 已完成 | [验证与验收子需求](./verification.md) |
| R-013 | VS Code Server 预置策略 | P2 | 已完成 | [VS Code Remote 子需求](./vscode-remote.md) |
| R-014 | 非 root 用户支持 | P2 | 未完成 | [Dev Container 子需求](./devcontainer.md) |
| R-015 | 镜像缓存清理与体积控制 | P2 | 部分完成 | [镜像体积排查](../ops/image-size-inspection.md) |
| R-016 | Dev Container 配置模板 | P2 | 已完成 | [Dev Container 子需求](./devcontainer.md) |
| R-017 | 扩展预装或扩展缓存 | P3 | 未完成 | [VS Code Remote 子需求](./vscode-remote.md) |
| R-018 | 完整离线 VS Code Server 分发 | P3 | 未完成 | [VS Code Remote 子需求](./vscode-remote.md) |

## 6. 当前要实现的核心需求

### 6.1 语言运行时

- `R-002.1` 必须内置 Go。
- `R-004.1` 必须内置 Java。
- `R-003.1` 必须内置 Python。
- `R-003.2` Python 继续以 `uv` 作为主要包管理与虚拟环境工具。
- `R-002.2` Go 应支持版本参数化。
- `R-009.1` Java 应支持版本参数化。

### 6.2 AI CLI

- `R-005.1` 第一阶段至少内置 `claude-code`。
- `R-005.2` 第一阶段至少内置 `codex`。
- `R-005.3` 当前的 `cs` 可保留，但需在使用文档中说明定位。

### 6.3 基础开发工具

- `R-007.1` 必须提供 `git`。
- `R-007.2` 必须提供 `ssh`。
- `R-007.3` 必须提供编译工具链和基础 shell 能力。
- `R-007.4` 可逐步补齐 `curl`、`wget`、`zip`、`unzip`、`make`、`zsh`、`sudo`。

### 6.4 项目挂载与工作目录

- `R-006.1` 应支持通过 `docker run` 挂载本地项目目录。
- `R-006.2` 应支持通过 `docker compose` 挂载本地项目目录。
- `R-006.3` 应明确默认工作目录及推荐挂载方式。

### 6.5 构建配置能力

- `R-008.1` 第一阶段至少支持 `GO_TAG`。
- `R-008.2` 第一阶段至少支持 `NODE_TAG`。
- `R-008.3` 第一阶段至少支持 `UV_TAG`。
- `R-008.4` 第一阶段至少支持 `MIRRORS_URL`。
- `R-008.5` 第一阶段至少支持 `NPM_CONFIG_REGISTRY`。
- `R-008.6` 第一阶段至少支持 `UV_DEFAULT_INDEX`。
- `R-009.2` 引入 Java 后应补充等价的 Java 版本参数。

## 7. 当前阶段范围

第一阶段重点：

- 补齐 Go、Java、Python 三套开发环境。
- 保证 AI CLI 开箱即用。
- 完善构建与运行方式说明。
- 建立基础验证流程。

第一阶段暂不包含：

- 浏览器版 IDE。
- 完整离线 `VS Code Server` 分发体系。
- 全量 VS Code 扩展预装与缓存。

## 8. 当前状态

- 基础镜像骨架：已完成。
- Go：已完成。
- Python / uv：已完成。
- Java：已完成。
- AI CLI：已完成。
- Dev Container 支持：已完成。
- VS Code Server 预置：已完成。
- 多语言验证：已完成。

## 9. 子需求拆分

更细的专题需求拆分如下：

- [Dev Container 子需求](./devcontainer.md)
- [VS Code Remote 子需求](./vscode-remote.md)
- [验证与验收子需求](./verification.md)

后续如果新增 Java、AI 工具、镜像体积治理等长期维护主题，也继续在本目录下新增专题文档，而不是把细节堆回本文件。

## 10. 待决策项

- Java 采用哪个发行版。
- Java 默认版本。
- 是否需要 Maven 或 Gradle。
- 是否需要非 root 用户。
- 是否需要 `.devcontainer/` 模板。
- 是否锁定 AI CLI 版本。
- 是否锁定本地 VS Code 版本与渠道。
- 是否允许将 `VS Code Server` 制品内置到镜像。

## 11. 验收基线

- 能成功执行 `bash scripts/docker-build.sh` 并构建镜像。
- 容器启动后可直接运行 Go、Java、Python、uv。
- 容器启动后可直接运行主要 AI CLI。
- 用户挂载项目目录后可直接开展开发工作。
- 文档能够指导用户完成构建、启动、进入容器和基础验证。

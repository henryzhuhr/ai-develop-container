# 核心需求

总入口见 [requirements.md](../requirements.md)。

## 1. 背景

本项目希望从基础开发镜像升级为统一的多语言 AI 开发容器镜像，降低环境初始化成本，并让用户在容器启动后直接进入开发状态。

## 2. 目标

- 内置 Go、Java、Python 开发环境。
- 内置常用命令行开发工具。
- 内置常用 AI CLI，例如 `claude-code`、`codex`。
- 支持挂载本地项目目录后直接开始开发。
- 尽量减少首次进入容器后的额外配置。

## 3. 非目标

- 不提供浏览器版 IDE。
- 不承诺第一阶段覆盖所有架构和所有操作系统。
- 不在第一阶段完成完整离线 VS Code Server 分发。

## 4. 需求项

### 4.1 语言运行时

- 必须内置 Go。
- 必须内置 Java。
- 必须内置 Python。
- Python 继续以 `uv` 作为主要包管理与虚拟环境工具。
- Go 与 Java 应支持版本参数化。

### 4.2 AI CLI

- 第一阶段至少内置：
  - `claude-code`
  - `codex`
- 当前的 `cs` 可保留，但需在使用文档中说明定位。

### 4.3 基础开发工具

- 必须提供 `git`、`ssh`、编译工具链和基础 shell 能力。
- 可逐步补齐 `curl`、`wget`、`zip`、`unzip`、`make`、`zsh`、`sudo`。

### 4.4 项目挂载与工作目录

- 应支持通过 `docker run` 和 `docker compose` 挂载本地项目目录。
- 应明确默认工作目录及推荐挂载方式。

### 4.5 构建配置能力

- 第一阶段至少支持以下构建参数：
  - `GO_TAG`
  - `NODE_TAG`
  - `UV_TAG`
  - `MIRRORS_URL`
  - `NPM_CONFIG_REGISTRY`
  - `UV_DEFAULT_INDEX`
- 引入 Java 后应补充等价的 Java 版本参数。

## 5. 验收标准

- 能成功执行 `bash scripts/docker-build.sh` 并构建镜像。
- 容器启动后可直接运行 Go、Java、Python、uv。
- 容器启动后可直接运行主要 AI CLI。
- 用户挂载项目目录后可直接开展开发工作。

## 6. 当前状态

- `Go`：已完成。
- `Python/uv`：部分完成，尚缺统一验证。
- `Java`：未完成。
- `AI CLI`：已完成。
- `基础开发工具`：部分完成。
- `构建参数`：部分完成，Java 参数待补。

## 7. 待决策项

- Java 采用哪个发行版。
- Java 默认版本。
- 是否需要 Maven 或 Gradle。
- 是否锁定 AI CLI 版本。

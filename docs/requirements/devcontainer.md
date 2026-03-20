# Dev Container 需求

总入口见 [requirements.md](../requirements.md)。

## 1. 背景

本项目需要支持用户通过本地 VS Code 的 Dev Containers / Remote Development 连接运行中的容器，在容器中直接完成代码编辑、命令执行和调试。

## 2. 目标

- 让容器成为可直接用于远程开发的目标环境。
- 让用户连接容器后无需再安装 Go、Java、Python、AI CLI 等核心依赖。
- 为后续 `.devcontainer/` 模板和远程开发体验优化预留结构。

## 3. 非目标

- 第一阶段不保证完全不下载 `VS Code Server`。
- 第一阶段不处理浏览器版 IDE。
- 第一阶段不处理完整扩展离线分发。

## 4. 需求项

### 4.1 容器开发体验

- 容器必须具备远程开发所需的核心工具链。
- 应明确推荐的工作目录和挂载方式。
- 应保证 `docker run` 和 `docker compose` 场景都能作为远程开发基础环境。

### 4.2 Dev Container 配置

- 第二阶段建议补充 `.devcontainer/` 模板。
- 模板中应定义基础工作目录、推荐用户和必要扩展。

### 4.3 用户模型

- 第一阶段默认覆盖 `root` 用户场景。
- 后续评估是否补充非 `root` 用户方案。

## 5. 验收标准

- 用户可使用本地 VS Code 连接正在运行的容器。
- 用户连接容器后无需再安装 Go、Java、Python、AI CLI。
- 文档中明确当前远程开发使用方式和限制。

## 6. 当前状态

- 基础容器可被连接：部分完成。
- Dev Container 模板：未完成。
- 非 root 用户：未完成。

## 7. 待决策项

- 是否需要在第一阶段提供 `.devcontainer/` 模板。
- 是否需要非 `root` 用户。
- 默认工作目录最终如何统一。

# 仓库指南

## 项目结构与模块组织

本仓库是一个基于 Docker 的开发容器配置项目。

- `dockerfiles/Dockerfile`：基础镜像定义（Ubuntu + Node.js + Go + uv）。
- `docker-compose.yml`：本地服务定义（`ai-develop-container`）与挂载配置。
- `scripts/docker-build.sh`：预构建脚本，用于拉取依赖镜像并构建项目镜像。
- `README.md`：项目入口说明（当前内容较精简）。

新增自动化脚本建议放在 `scripts/`；环境与容器定义建议放在 `dockerfiles/` 或 compose 文件中。

## 构建、测试与开发命令

- `bash scripts/docker-build.sh`：拉取依赖镜像并构建 `ai-develop-container:1.0.0`。
- `docker compose up -d`：后台启动开发容器服务。
- `docker compose exec ai-develop-container bash`：进入容器交互式 Shell。
- `docker compose down`：停止并移除服务。

若修改构建参数（例如 `NODE_TAG`、`GO_TAG`），请同步更新 `scripts/docker-build.sh` 并重新构建。

## 代码风格与命名规范

- Shell 脚本：使用 `bash`；缩进保持 2-4 空格并与周边代码一致；构建配置变量使用大写命名（如 `IMAGE_TAG`、`UV_TAG`）。
- YAML/Compose：使用 2 空格缩进；服务名、镜像名使用小写加连字符风格。
- 文件命名：脚本与配置优先使用 kebab-case。
- 注释要求：简短且可操作，重点说明“做什么/为什么做”（尤其是镜像源与仓库切换逻辑）。

## 测试指南

当前仓库尚未建立正式自动化测试套件。

- 变更验证：至少确保 `bash scripts/docker-build.sh` 可成功执行。
- 运行冒烟测试：
  - `docker compose up -d`
  - `docker compose exec ai-develop-container bash -lc "node -v && go version && uv --version"`

新增测试时，请将测试放在相关脚本/配置附近，并将执行命令补充到本文件。

## 提交与合并请求规范

当前仓库暂无提交历史，建议从现在开始使用 Conventional Commits：

- `feat: add configurable image tag`
- `fix: correct mirror replacement logic`
- `docs: update container startup steps`

提交 PR 时请包含：

- 变更目的与行为影响摘要。
- 已执行的验证命令。
- 构建/启动行为变更对应的日志或截图。
- 关联 issue/任务链接（如适用）。

## 配置与安全建议

- 不要提交密钥、私有仓库凭据或令牌。
- 优先通过 build args / 环境变量做镜像源与 registry 定制。
- 修改镜像来源（如 `GHCR_MIRROR`、apt mirrors）时需评估供应链风险。

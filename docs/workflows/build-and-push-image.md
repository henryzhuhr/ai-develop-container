# Build and Push Image 流水线维护说明

本文档对应文件：`.github/workflows/build-and-push-image.yaml`

## 目标

该流水线用于验证并构建多架构镜像，同时区分不同分支的推送策略：

1. 所有触发分支先执行单架构自动构建和镜像内容验证。
2. `feature/*`：验证通过后继续构建多架构镜像，但不推送 GHCR。
3. `main`：验证通过后继续构建多架构镜像；仅 `go1.25` 推送 `latest`。
4. `v*` tag：验证通过后推送正式版本标签（`vX.Y.Z` 和 `vX.Y.Z-goX.Y`）。

## 触发条件

触发入口：

1. `push` 到 `main`
2. `push` 到 `feature/*`
3. `push` 标签 `v*`
4. 手动触发 `workflow_dispatch`

## 构建策略

矩阵维度：

1. Go 版本：`1.20`、`1.21`、`1.22`、`1.23`、`1.24`、`1.25`

每个 Go 版本都构建双架构：

1. `linux/amd64`
2. `linux/arm64`

构建参数：

1. `GO_TAG=${{ matrix.go_version }}`
2. `JAVA_VERSION=21`
3. `VSCODE_SERVER_COMMITS=07ff9d6178ede9a1bd12ad3399074d726ebe6e43,cb1933bbc38d329b3595673a600fab5c7368f0a7`
4. `VSCODE_SERVER_CHANNEL=stable`
5. `UV_TAG=0.10.0`
6. `NODE_TAG=24`

说明：`dockerfiles/Dockerfile` 使用的是 `ARG GO_TAG`，不要改成 `GO_VERSION`，否则矩阵版本不会生效。

自动验证步骤：

1. 先构建单架构镜像 `ai-develop-container:ci-verify`
2. 再运行 `bash scripts/verify-image.sh ai-develop-container:ci-verify`
3. 验证 Node、Go、Python、uv、Java、AI CLI，以及预置的微软 `VS Code Server` commit 目录

## 标签与推送规则

标签由 `Determine image tags` 步骤动态生成。

`feature/*` 分支：

1. 使用本地测试标签 `ai-develop-container:ci-goX.Y`
2. `push=false`，不登录 GHCR，不推送远端

`main` 分支：

1. 仅 `go1.25` 生成 `ghcr.io/<repo>:latest`
2. 仅该任务 `push=true`
3. 其他 Go 版本仍构建，但不推送

`v*` 标签：

1. 所有 Go 版本推送 `ghcr.io/<repo>:vX.Y.Z-goX.Y`
2. `go1.25` 额外推送 `ghcr.io/<repo>:vX.Y.Z`

## 关键条件表达式

是否允许推送与登录 GHCR：

```yaml
${{ startsWith(github.ref, 'refs/tags/v') || (github.ref == 'refs/heads/main' && matrix.go_version == '1.25') }}
```

这保证只有 `main/go1.25` 和 `v*` tag 会推送。

## 本地测试

在推送代码前，可以先在本地测试构建：

```bash
# 使用脚本构建（单架构）
GO_TAG=1.25 IMAGE_TAG=test bash scripts/docker-build.sh

# 查看构建结果
docker images | grep ai-develop-container

# 运行镜像内容验证
bash scripts/verify-image.sh ai-develop-container:test
```

## 常见维护操作

调整 Go 版本矩阵：

1. 修改 `strategy.matrix.go_version`
2. 确认 Dockerfile 仍接受 `GO_TAG`
3. 如需调整默认稳定版本，同时更新 `main` 分支的推送版本条件（当前是 `1.25`）

新增推送标签（如 `edge`）：

1. 在 `Determine image tags` 的 `main` 分支逻辑中追加
2. 保持只在单一 Go 版本上推送滚动标签，避免并发覆盖

## 验证建议

`feature/*` 验证（构建不推送）：

```bash
git checkout -b feature/test-workflow
git commit --allow-empty -m "ci: trigger workflow"
git push origin feature/test-workflow
```

`main` 验证（仅 latest 推送）：

```bash
git checkout main
git commit --allow-empty -m "ci: trigger main workflow"
git push origin main
```

`tag` 验证（正式版本推送）：

```bash
git tag v1.0.0
git push origin v1.0.0
```

## 故障排查

如果发现 Go 版本不对：

1. 检查 workflow 是否仍传递 `GO_TAG`
2. 检查 Dockerfile 的 `ARG GO_TAG`

如果发现 `latest` 被覆盖异常：

1. 检查推送条件是否仍限制在 `main + go1.25`
2. 检查是否新增了其它任务也在推 `latest`

如果 `feature/*` 意外推送：

1. 检查 `push` 条件表达式
2. 检查 `Log in to GHCR` 是否加了同样条件

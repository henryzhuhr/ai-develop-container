#!/bin/bash
#
# VS Code Server 镜像构建与推送脚本
#
# 用途：构建 vscode-server 多 commit 预置镜像并推送到 GHCR
#
# 依赖：
#   - Docker (支持 BuildKit)
#   - GITHUB_TOKEN (GHCR 认证)
#
# 环境变量：
#   GITHUB_TOKEN        GHCR 认证令牌（必需）
#   GITHUB_USERNAME     GHCR 用户名（可选，默认为 henryzhuhr）
#   IMAGE_TAG           镜像标签（可选，默认为 latest）
#   VSCODE_SERVER_COMMITS 要预置的 VS Code Server commit 列表，逗号分隔
#   VSCODE_SERVER_CHANNEL 下载通道（可选，默认为 stable）
#   BUILDKIT_PROGRESS   构建进度显示模式（可选，默认为 auto）
#   PLATFORM            目标平台（可选，如 linux/amd64,linux/arm64）
#
# 使用示例：
#   export GITHUB_TOKEN=ghp_xxx
#   ./scripts/docker-build-vscode-server-ghcr.sh
#
#   # 指定多个 commit
#   VSCODE_SERVER_COMMITS="abc123,def456" ./scripts/docker-build-vscode-server-ghcr.sh
#
#   # 多平台构建
#   PLATFORM=linux/amd64,linux/arm64 ./scripts/docker-build-vscode-server-ghcr.sh
#

set -euo pipefail

# =============================================================================
# 基础配置
# =============================================================================

# 项目根目录（固定路径）
PROJECT_ROOT="/Users/henryzhuhr/project/ai-develop-container"

# Dockerfile 路径（vscode-server 专用）
DOCKERFILE_PATH="${DOCKERFILE_PATH:-dockerfiles/vscode-server.dockerfile}"

# 镜像标签
IMAGE_TAG="${IMAGE_TAG:-latest}"

# VS Code Server 配置
VSCODE_SERVER_COMMITS="${VSCODE_SERVER_COMMITS:-07ff9d6178ede9a1bd12ad3399074d726ebe6e43,cb1933bbc38d329b3595673a600fab5c7368f0a7}"
VSCODE_SERVER_CHANNEL="${VSCODE_SERVER_CHANNEL:-stable}"

# 构建进度显示
BUILDKIT_PROGRESS="${BUILDKIT_PROGRESS:-auto}"

# 目标平台（留空表示当前架构）
PLATFORM="${PLATFORM:-}"

# =============================================================================
# GHCR 认证
# =============================================================================

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "GITHUB_TOKEN is required." >&2
  exit 1
fi

# GHCR 配置
GITHUB_USERNAME="${GITHUB_USERNAME:-henryzhuhr}"
GHCR_IMAGE_NAME="${GHCR_IMAGE_NAME:-ai-develop-container}"
GHCR_IMAGE_TAG="${GHCR_IMAGE_TAG:-vscode-server-latest}"
GHCR_IMAGE="ghcr.io/${GITHUB_USERNAME}/${GHCR_IMAGE_NAME}:${GHCR_IMAGE_TAG}"
LOCAL_IMAGE="${GHCR_IMAGE_NAME}:${GHCR_IMAGE_TAG}"

# 登录 GHCR
echo "Logging in to ghcr.io as ${GITHUB_USERNAME}"
if ! printf '%s' "${GITHUB_TOKEN}" | docker login ghcr.io -u "${GITHUB_USERNAME}" --password-stdin; then
  echo "GHCR authentication failed." >&2
  exit 1
fi

# =============================================================================
# 构建镜像
# =============================================================================

echo "Building ${LOCAL_IMAGE} from ${DOCKERFILE_PATH}"
docker build \
  --progress "${BUILDKIT_PROGRESS}" \
  -t "${LOCAL_IMAGE}" \
  -t "${GHCR_IMAGE}" \
  -f "${DOCKERFILE_PATH}" \
  --build-arg "VSCODE_SERVER_COMMITS=${VSCODE_SERVER_COMMITS}" \
  --build-arg "VSCODE_SERVER_CHANNEL=${VSCODE_SERVER_CHANNEL}" \
  ${PLATFORM:+--platform "${PLATFORM}"} \
  "${PROJECT_ROOT}"

# =============================================================================
# 推送到 GHCR
# =============================================================================

echo "Pushing ${GHCR_IMAGE}"
docker push "${GHCR_IMAGE}"

echo "Pushed ${GHCR_IMAGE}"

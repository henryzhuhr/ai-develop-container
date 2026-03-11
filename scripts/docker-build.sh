#!/bin/bash
# 构建项目镜像的脚本
# 用法:
#   本地单架构测试：bash scripts/docker-build.sh
#   指定 Go 版本：GO_TAG=1.22 bash scripts/docker-build.sh
#   指定镜像标签：IMAGE_TAG=latest bash scripts/docker-build.sh
#   CI 多架构构建：在 GitHub Actions 中使用 docker/build-push-action

set -e

# ============================================================
#   是否启用全局镜像加速，1 内网，0 外网 (可通过环境变量覆盖)
# ============================================================
ENABLE_GLOBAL_MIRROR=${ENABLE_GLOBAL_MIRROR:-0}

# ============================================================
#   构建的镜像配置 (可通过环境变量覆盖)
# ============================================================
IMAGE_NAME=${IMAGE_NAME:-"ai-develop-container"}
IMAGE_TAG=${IMAGE_TAG:-"0.0.1-dev"}

# ============================================================
#   基础镜像版本配置 (可通过环境变量覆盖)
# ============================================================
UV_TAG=${UV_TAG:-"0.10.0"}
NODE_TAG=${NODE_TAG:-"24"}
GO_TAG=${GO_TAG:-"1.25"}

# ============================================================
#   构建配置 (可通过环境变量覆盖)
# ============================================================
CLEAN_APT_CACHE=${CLEAN_APT_CACHE:-1}
PLATFORMS=${PLATFORMS:-""}

# BuildKit 日志输出模式:
#   auto: 自动选择，交互终端通常显示为动态进度条
#   none: 不输出构建进度
#   plain: 纯文本日志，便于查看 RUN 步骤的标准输出
#   quiet: 仅输出最终镜像 ID
#   rawjson: 输出原始 JSON 事件，适合程序消费
#   tty: 强制使用交互式 TTY 进度界面
BUILDKIT_PROGRESS=${BUILDKIT_PROGRESS:-auto}

# ============================================================
#   镜像源配置 (本地使用国内镜像，CI 使用官方源)
# ============================================================
if [ "${ENABLE_GLOBAL_MIRROR}" -eq 1 ]; then
  echo "暂不支持，联系开发者添加内网镜像加速功能"
  exit 1
else
  # 本地构建使用国内镜像源加速
  MIRRORS_URL="mirrors.ustc.edu.cn"
  GHCR_MIRROR="ghcr.io"
  NPM_CONFIG_REGISTRY="https://registry.npmjs.org"
  UV_DEFAULT_INDEX="https://pypi.tuna.tsinghua.edu.cn/simple"
fi

# ============================================================
#   预拉取基础镜像 (可选，加快构建速度)
# ============================================================
IMAGES=(
  "ubuntu:24.04"
  "ghcr.io/astral-sh/uv:${UV_TAG}"
  "golang:${GO_TAG}"
  "node:${NODE_TAG}"
)

for IMAGE in "${IMAGES[@]}"; do
  if ! docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${IMAGE}$"; then
    echo "Pull image: ${IMAGE}"
    docker pull "${IMAGE}" || {
      echo "Failed to pull image ${IMAGE}, aborting!"
      exit 1
    }
  else
    echo "Found ${IMAGE}, skip pulling."
  fi
done

# ============================================================
#   构建镜像
# ============================================================
echo "Building image ${IMAGE_NAME}:${IMAGE_TAG}..."

BUILD_ARGS=(
  "--build-arg" "UV_TAG=${UV_TAG}"
  "--build-arg" "GHCR_MIRROR=${GHCR_MIRROR}"
  "--build-arg" "GO_TAG=${GO_TAG}"
  "--build-arg" "NODE_TAG=${NODE_TAG}"
  "--build-arg" "MIRRORS_URL=${MIRRORS_URL}"
  "--build-arg" "NPM_CONFIG_REGISTRY=${NPM_CONFIG_REGISTRY}"
  "--build-arg" "CLEAN_APT_CACHE=${CLEAN_APT_CACHE}"
  "--build-arg" "UV_DEFAULT_INDEX=${UV_DEFAULT_INDEX}"
)

# 如果指定了平台，使用 buildx 进行多架构构建
if [ -n "${PLATFORMS}" ]; then
  echo "Building for platforms: ${PLATFORMS}"
  docker buildx build --platform "${PLATFORMS}" \
    --progress "${BUILDKIT_PROGRESS}" \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    -f dockerfiles/Dockerfile \
    --no-cache \
    "${BUILD_ARGS[@]}" \
    .
else
  echo "Building for local platform..."
  docker build --progress "${BUILDKIT_PROGRESS}" \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    -f dockerfiles/Dockerfile \
    --no-cache \
    "${BUILD_ARGS[@]}" \
    .
fi

# ============================================================
#   打印构建结果
# ============================================================
echo ""
echo "Built images:"
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}" | grep "${IMAGE_NAME}" || true

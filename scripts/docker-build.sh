#!/bin/bash
# 预先构建项目镜像的脚本，加快 docker compose up 的速度

# ============================================================
#   是否启用全局镜像加速，1 内网，0 外网
#   内网会替换一些镜像前缀
# ============================================================
ENABLE_GLOBAL_MIRROR=0

# ============================================================
#   构建的镜像配置
# =============================================================
IMAGE_NAME=ai-develop-container
IMAGE_TAG=0.0.1-dev
# IMAGE_TAG=$(date +%Y%m%d%H%M%S)

# ============================================================
#   其他镜像配置
# ============================================================
# uv: https://github.com/astral-sh/uv/pkgs/container/uv
UV_TAG=0.10.0
NODE_TAG=24
GO_TAG=1.25


if [ "${ENABLE_GLOBAL_MIRROR}" -eq 1 ]; then
  echo "暂不支持，联系开发者添加内网镜像加速功能"
  exit
else
  MIRRORS_URL="mirrors.ustc.edu.cn"
  GHCR_MIRROR="ghcr.io"
  NPM_CONFIG_REGISTRY="https://registry.npmjs.org"
fi

# 是否在构建过程中清理 apt 缓存
CLEAN_APT_CACHE=1


# 镜像列表（格式：镜像名:标签）
IMAGES=(
  "ubuntu:24.04"
  "ghcr.io/astral-sh/uv:${UV_TAG}"
  "golang:${GO_TAG}"
  "node:${NODE_TAG}"
)

for IMAGE in "${IMAGES[@]}"; do
  # 内网将 ghcr.io 替换为 GHCR_MIRROR
  if [ "${ENABLE_GLOBAL_MIRROR}" -eq 1 ]; then
    IMAGE="${IMAGE//ghcr.io/${GHCR_MIRROR}}"
  fi

  NAME=$(echo "${IMAGE}" | cut -d: -f1)
  TAG=$(echo "${IMAGE}" | cut -d: -f2-)

  if ! docker images | grep -q "^${NAME}[[:space:]]\+${TAG}[[:space:]]"; then
    echo "pull image: ${IMAGE}"
    docker pull "${IMAGE}" || {
      echo "failed to pull image ${IMAGE}, aborting!";
      exit 1;
    }
  else
    echo "found ${IMAGE}, skip docker pull."
  fi
done

docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f dockerfiles/Dockerfile \
  --build-arg UV_TAG=${UV_TAG} \
  --build-arg GHCR_MIRROR=${GHCR_MIRROR} \
  --build-arg GO_TAG=${GO_TAG} \
  --build-arg NODE_TAG=${NODE_TAG} \
  --build-arg MIRRORS_URL=${MIRRORS_URL} \
  --build-arg NPM_CONFIG_REGISTRY=${NPM_CONFIG_REGISTRY} \
  --build-arg CLEAN_APT_CACHE=${CLEAN_APT_CACHE} \
  --no-cache .

# 打印构建完成的镜像列表
echo "Built images:"
docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}\t{{.CreatedAt}}" | grep "${IMAGE_NAME}:${IMAGE_TAG}"
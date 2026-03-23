# Get the base image
ARG UV_TAG=latest
ARG GO_TAG=latest
ARG NODE_TAG=latest
ARG GHCR_MIRROR="ghcr.io"
ARG VSCODE_SERVER_COMMITS="07ff9d6178ede9a1bd12ad3399074d726ebe6e43"
ARG VSCODE_SERVER_CHANNEL="stable"

FROM ${GHCR_MIRROR}/astral-sh/uv:${UV_TAG} AS uv-builder
FROM golang:${GO_TAG} AS golang-builder
FROM node:${NODE_TAG} AS node-builder
FROM ubuntu:24.04 AS vscode-server-builder

ARG VSCODE_SERVER_COMMITS
ARG VSCODE_SERVER_CHANNEL
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl tar && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    arch="${TARGETARCH:-}"; \
    if [ -z "${arch}" ]; then \
      case "$(uname -m)" in \
        x86_64) arch="amd64" ;; \
        aarch64|arm64) arch="arm64" ;; \
        *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;; \
      esac; \
    fi; \
    case "${arch}" in \
      amd64) vscode_arch="x64" ;; \
      arm64) vscode_arch="arm64" ;; \
      *) echo "Unsupported TARGETARCH: ${arch}" >&2; exit 1 ;; \
    esac; \
    old_ifs="$IFS"; \
    IFS=','; \
    for commit in ${VSCODE_SERVER_COMMITS}; do \
      target_dir="/out/${commit}"; \
      extract_dir="/tmp/vscode-server-extract-${commit}"; \
      mkdir -p "${target_dir}" "${extract_dir}"; \
      curl --fail --show-error --silent --location \
        --retry 5 --retry-all-errors --retry-delay 2 \
        --connect-timeout 10 --max-time 300 \
        "https://update.code.visualstudio.com/commit:${commit}/server-linux-${vscode_arch}/${VSCODE_SERVER_CHANNEL}" \
        -o "/tmp/vscode-server-${commit}.tar.gz"; \
      tar -xzf "/tmp/vscode-server-${commit}.tar.gz" -C "${extract_dir}"; \
      entry_count="$(find "${extract_dir}" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')"; \
      if [ "${entry_count}" = "1" ] && [ -d "$(find "${extract_dir}" -mindepth 1 -maxdepth 1)" ]; then \
        top_dir="$(find "${extract_dir}" -mindepth 1 -maxdepth 1)"; \
        cp -a "${top_dir}/." "${target_dir}/"; \
      else \
        cp -a "${extract_dir}/." "${target_dir}/"; \
      fi; \
      touch "${target_dir}/0"; \
      rm -rf "/tmp/vscode-server-${commit}.tar.gz" "${extract_dir}"; \
    done; \
    IFS="$old_ifs"

FROM ubuntu:24.04

WORKDIR /root
USER root

# ============================================================
#   系统软件安装列表
# ============================================================
ARG JAVA_VERSION="21"
ARG INSTALL_LIST=""
# ARG INSTALL_LIST="$INSTALL_LIST ubuntu-server"
ARG INSTALL_LIST="$INSTALL_LIST ca-certificates locales"
ARG INSTALL_LIST="$INSTALL_LIST vim nano tree pciutils iputils-ping"
ARG INSTALL_LIST="$INSTALL_LIST git openssh-client"
ARG INSTALL_LIST="$INSTALL_LIST build-essential"
ARG INSTALL_LIST="$INSTALL_LIST python3-dev"
ARG INSTALL_LIST="$INSTALL_LIST openjdk-${JAVA_VERSION}-jdk-headless"
ARG INSTALL_LIST="$INSTALL_LIST postgresql-client"
ARG INSTALL_LIST="$INSTALL_LIST redis-tools"

# 自定义镜像源 (本地构建可传入，如 MIRRORS_URL=mirrors.ustc.edu.cn)
# CI 环境不传此参数，使用官方源
ARG MIRRORS_URL=""

# ============================================================
#   系统环境配置
# ============================================================
# 安装软件
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8
RUN set -x && \
    # Enable bash color prompt
    sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' ${HOME}/.bashrc && \
    if [ -n "${MIRRORS_URL}" ]; then \
      # 24.04+ DEB822 format
      sed -i -e "s#//.*archive.ubuntu.com#//${MIRRORS_URL}#g" -e "s#//ports.ubuntu.com#//${MIRRORS_URL}#g" /etc/apt/sources.list.d/ubuntu.sources; \
    fi && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends ${INSTALL_LIST} && \
    # Generate locale
    locale-gen zh_CN.UTF-8 && \
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# 系统时间错误可能导致: `tls: failed to verify certificate: x509: certificate signed by unknown authority`
# 修改时区 (date -R 检查当前时间)
# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# ============================================================
#   Node.js 环境
# ============================================================
COPY --from=node-builder /usr/local/bin/node          /usr/local/bin/
COPY --from=node-builder /usr/local/lib/node_modules  /usr/local/lib/node_modules
ENV PATH="/usr/local/bin:$PATH"
ARG NPM_CONFIG_REGISTRY="https://registry.npmjs.org"
ENV NPM_CONFIG_REGISTRY=${NPM_CONFIG_REGISTRY}

RUN set -x && \
    # Create symlinks for npm and npx
    ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    # Install Global npm packages
    npm install -g \
      @costrict/cs \
      @anthropic-ai/claude-code \ 
      @openai/codex && \
    npm cache clean --force && \
    rm -rf /tmp/* /var/tmp/* /root/.npm


# ============================================================
#   Golang 环境
# ============================================================
COPY --from=golang-builder /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:/root/go/bin:$PATH"
ENV GOPROXY=https://goproxy.cn,direct


# ============================================================
#   Python 环境
# ============================================================
COPY --from=uv-builder /uv /uvx /bin/
ARG UV_DEFAULT_INDEX="https://pypi.org/simple"
ENV UV_DEFAULT_INDEX=${UV_DEFAULT_INDEX}
ENV VIRTUAL_ENV_DISABLE_PROMPT=1


# ============================================================
#   VS Code Server 环境
# ============================================================
COPY --from=vscode-server-builder /out/ /root/.vscode-server/bin/

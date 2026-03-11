# Get the base image
ARG UV_TAG=latest
ARG GO_TAG=latest
ARG NODE_TAG=latest
ARG GHCR_MIRROR="ghcr.io"

FROM ${GHCR_MIRROR}/astral-sh/uv:${UV_TAG} AS uv-builder
FROM golang:${GO_TAG} AS golang-builder
FROM node:${NODE_TAG} AS node-builder

FROM ubuntu:24.04

WORKDIR /root
USER root

# ============================================================
#   系统软件安装列表
# ============================================================
ARG INSTALL_LIST=""
# ARG INSTALL_LIST="$INSTALL_LIST ubuntu-server"
ARG INSTALL_LIST="$INSTALL_LIST ca-certificates locales"
ARG INSTALL_LIST="$INSTALL_LIST vim nano tree pciutils iputils-ping"
ARG INSTALL_LIST="$INSTALL_LIST git openssh-client"
ARG INSTALL_LIST="$INSTALL_LIST build-essential"
ARG INSTALL_LIST="$INSTALL_LIST python3-dev"
ARG INSTALL_LIST="$INSTALL_LIST postgresql-client"
ARG INSTALL_LIST="$INSTALL_LIST redis-tools"

# 自定义镜像源 (本地构建可传入，如 MIRRORS_URL=mirrors.ustc.edu.cn)
# CI 环境不传此参数，使用官方源
ARG MIRRORS_URL=""

# 安装软件
ENV DEBIAN_FRONTEND=noninteractive
RUN set -x && \
    sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' ${HOME}/.bashrc && \
    if [ -n "${MIRRORS_URL}" ]; then \
      sed -i -e "s#//.*archive.ubuntu.com#//${MIRRORS_URL}#g" -e "s#//ports.ubuntu.com#//${MIRRORS_URL}#g" /etc/apt/sources.list.d/ubuntu.sources; \
    fi && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends ${INSTALL_LIST} && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# 系统时间错误可能导致: `tls: failed to verify certificate: x509: certificate signed by unknown authority`
# 修改时区 (date -R 检查当前时间)
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 启用 bash 补全
# RUN sed -i.bak '/^#if ! shopt -oq posix; then$/,/^#fi$/s/^#//' /etc/bash.bashrc

ARG USER_NAME="root"
ARG USER_HOME="/${USER_NAME}"

# ============================================================
#   Node.js 环境
# ============================================================
ARG NPM_CONFIG_REGISTRY="https://registry.npmjs.org"
# npm 原生识别 NPM_CONFIG_* 前缀的环境变量，无需显式调用 npm config set
ENV NPM_CONFIG_REGISTRY=${NPM_CONFIG_REGISTRY}
COPY --from=node-builder /usr/local/ /usr/local/

RUN set -x && \
  # 全局安装一些常用的 AI 相关工具包
  npm install -g \
  @anthropic-ai/claude-code \
  @costrict/cs \
  @openai/codex && \
  npm cache clean --force && rm -rf /root/.npm

# ============================================================
#   Python 环境
# ============================================================
# 使用 uv
COPY --from=uv-builder /uv /uvx /bin/

# UV 的环境变量 (本地构建可传入国内镜像，CI 使用官方源)
ARG UV_DEFAULT_INDEX="https://pypi.org/simple"
ENV UV_DEFAULT_INDEX=${UV_DEFAULT_INDEX}

# ============================================================
#   Golang 环境
# ============================================================
COPY --from=golang-builder /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:$PATH"
ENV PATH="$USER_HOME/go/bin:$PATH"

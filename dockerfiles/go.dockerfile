# Get the base image
ARG GO_TAG=latest

# 第一阶段：构建 Golang 环境
FROM golang:${GO_TAG} AS golang-builder

# 第二阶段：构建最终镜像
FROM ubuntu:24.04

WORKDIR /root
USER root

# ============================================================
#   Golang 环境
# ============================================================
# 从第一阶段复制 Golang 环境到最终镜像
COPY --from=golang-builder /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:$PATH"
ENV PATH="/root/go/bin:$PATH"

RUN set -eux; && \
    go version; && \
    # go env -w GO111MODULE=on
    go env -w GOPROXY=https://goproxy.cn,direct && \
    # for Go latest
    go install golang.org/x/tools/gopls@latest && \
    go install github.com/cweill/gotests/...@latest && \
    go install github.com/fatih/gomodifytags@latest && \
    go install github.com/josharian/impl@latest && \
    go install github.com/haya14busa/goplay/cmd/goplay@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest && \
    go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
#!/bin/bash
# 自动使用当前用户 UID/GID 启动容器，解决挂载目录权限问题

set -e

export CURRENT_UID=$(id -u)
export CURRENT_GID=$(id -g)

echo "启动容器，使用 UID:GID = ${CURRENT_UID}:${CURRENT_GID}"

docker compose "$@"

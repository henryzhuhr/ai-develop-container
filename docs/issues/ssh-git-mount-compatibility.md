# SSH / Git 挂载兼容性问题

总入口见 [docs/README.md](../README.md)，Issue 索引见 [docs/issues/README.md](./README.md)。

## 1. 基本信息

- `ISS-001`
- 状态：Resolved
- 优先级：P1
- 相关文档：
  - [Dev Container 子需求](../requirements/devcontainer.md)
  - [开发指南](../guides/development.md)

## 2. 背景

问题发现时，仓库默认以 `root` 用户运行容器，`docker-compose.yml` 里也使用了把宿主机 SSH 目录直接挂载到 `/root/.ssh` 的写法。

```yaml
volumes:
  - .:/root/ai-develop-container
  - ~/.ssh:/root/.ssh
```

这个写法在宿主机和容器都使用 `root` 时通常可用，但在异地部署或宿主机使用普通用户的场景下存在兼容性问题。

## 3. 问题描述

当宿主机 `~/.ssh` 目录 owner 为普通用户，例如 `ubuntu:ubuntu`，而容器内仍然由 `root` 读取 `/root/.ssh` 时，OpenSSH 会对目录、私钥和配置文件执行严格的 owner / 权限检查。

结果是容器内 Git over SSH 可能直接不可用，典型报错包括：

```text
Bad owner or permissions on /root/.ssh/config
Permissions 0644 for '/root/.ssh/id_rsa' are too open
```

受影响的典型操作包括：

- `git clone`
- `git pull`
- `git push`
- `ssh -T git@github.com`

## 4. 影响范围

- 修复前 `docker compose` 配置中直接使用 `~/.ssh:/root/.ssh` 的场景
- 修复前文档如果继续推广 `docker run ... -v ~/.ssh:/root/.ssh` 的场景
- 继续使用 `root` 作为容器用户的远程开发场景

不在本 issue 范围内的内容：

- 全量切换到非 `root` 用户模型
- 强制改为 `ssh-agent` 转发方案
- Git HTTPS 凭据方案

## 5. 根因分析

- OpenSSH 不只检查文件权限，也检查 owner 是否符合预期。
- 直接 bind mount 会把宿主机 owner 原样暴露到容器内。
- 当前容器模型以 `root` 为中心，工作目录、Dev Container 和挂载路径都围绕 `/root/...` 设计。
- 因此，这个问题的根因不是缺少 `ssh` 或 `git`，而是当前凭据挂载方式与 `root` 用户模型不兼容。

## 6. 目标修复方向

已按“中转挂载 + 运行时复制”的方式修复，并保持当前 `root` 用户模型不变。

目标方案：

- 宿主机 `~/.ssh` 挂载到容器内中转路径 `/data/.ssh`
- 宿主机 `~/.gitconfig` 挂载到容器内中转路径 `/data/.gitconfig`
- 对于本仓库 `docker-compose.yml`，启动命令会在容器启动时将凭据复制到 `/root/.ssh` 和 `/root/.gitconfig`
- 对于直接使用发布镜像的 `docker run` 场景，用户进入容器后执行一次同步命令即可
- 复制后统一修正 owner 和权限，满足 OpenSSH 的严格检查要求
- 不修改发布镜像的 Dockerfile 和默认启动方式

目标权限：

- `/root/.ssh` 目录为 `700`
- 私钥、`config`、`known_hosts`、`authorized_keys` 为 `600`
- `*.pub` 为 `644`

文档策略：

- 开发指南现在记录已支持的挂载方式和运行示例
- issue 文档保留问题背景、根因和修复结论

## 7. 验收标准

- 宿主机 `.ssh` owner 为普通用户时，容器启动后仍可正常执行 Git over SSH
- `docker compose` 场景下可完成 `git pull` 或等价的 `git ls-remote`
- `docker run` 场景下可完成 `git pull` 或等价的 `git ls-remote`
- 未挂载宿主机 SSH / Git 凭据时，容器仍可正常启动
- 开发指南只在实现完成后更新，不提前承诺未支持能力

## 8. 当前状态

- 当前状态：已修复
- 当前记录位置：`docs/issues/`
- 当前实现：
  - `docker-compose.yml` 启动时会调用运行时同步脚本
  - 运行时同步脚本会把 `/data/.ssh` 复制到 `/root/.ssh`
  - 运行时同步脚本会把 `/data/.gitconfig` 复制到 `/root/.gitconfig`
  - `docker-compose.yml` 已改为挂载 `/data/.ssh` 和 `/data/.gitconfig`
  - 开发指南已更新为最终用法

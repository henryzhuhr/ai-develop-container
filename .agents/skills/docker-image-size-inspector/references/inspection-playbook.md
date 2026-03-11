# 排查手册

## 目录

- 快速排查顺序
- 手工命令
- 如何解读结果
- 常见根因

## 快速排查顺序

除非有明确理由，否则按这个顺序执行：

1. 查看最终镜像大小。
2. 检查 `docker history`，找出最大的镜像层。
3. 检查容器内顶层目录占用。
4. 继续下钻到被大层指向的运行时、工具链或依赖树。
5. 检查常见缓存目录。

这样做的好处是流程始终收敛：先找到大层，再找到大目录，最后判断这是有意负载还是可移除的浪费。

## 手工命令

当附带脚本输出不够、或者你需要继续深挖时，运行下面这些命令。

### 最终镜像大小

```bash
docker image ls --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}" <image>
```

### 镜像层历史

```bash
docker history --no-trunc <image>
```

### 顶层目录占用

```bash
docker run --rm --entrypoint sh <image> -c 'du -sh /* 2>/dev/null | sort -hr | head -20'
```

### `/usr/local` 目录拆解

```bash
docker run --rm --entrypoint sh <image> -c 'du -sh /usr/local/* 2>/dev/null | sort -hr | head -20'
```

### 全局 Node 包占用

```bash
docker run --rm --entrypoint sh <image> -c 'du -sh /usr/local/lib/node_modules/* 2>/dev/null | sort -hr'
```

### 常见缓存目录

```bash
docker run --rm --entrypoint sh <image> -c "du -sh /var/lib/apt/lists /var/cache/apt /root/.npm /root/.cache /root/.cargo /root/go 2>/dev/null"
```

## 如何解读结果

### `docker history`

- 超大的 `RUN apt-get ...` 层通常意味着系统包本体、升级操作，或者清理缺失。
- 超大的 `RUN npm install -g ...` 层通常意味着包本体很重，也可能同时夹带 npm 缓存。
- 超大的 `COPY --from=... /usr/local/ /usr/local/` 层通常意味着复制了完整运行时，而不是只复制需要的二进制。
- 超大的 `COPY --from=... /usr/local/go /usr/local/go` 层通常意味着最终镜像里带上了整套 Go 工具链。

### 目录检查

- 很大的 `/usr/local/lib` 往往意味着语言包或本地库占主导。
- 很大的 `/usr/local/go` 说明最终镜像里包含了完整 Go 工具链。
- 很大的 `/usr/local/lib/node_modules` 说明全局 npm 包是主要体积来源。
- 很大的 `/root/.cache` 可能表示 Python、uv、pip 或其他工具缓存残留。

### 缓存检查

- 非零的 `/var/lib/apt/lists` 说明 apt 索引文件被留在了镜像里。
- 非零的 `/var/cache/apt` 说明包归档文件被留在了镜像里。
- 非零的 `/root/.npm` 说明 npm 清理没有在最终层里生效。
- 非零的 `/root/.cargo` 或 `/root/go` 往往表示构建期工具或下载内容被带进了最终镜像。

## 常见根因

- 在最终阶段安装了构建依赖，而不是放在构建阶段。
- 在开发容器里执行了 `apt-get upgrade -y`，但没有足够强的理由。
- 从 builder 镜像里复制了类似 `/usr/local` 这样的宽泛目录。
- 在最终镜像里安装了多个很重的全局 CLI。
- 清理命令写在了错误的条件分支里，或者写在了错误的镜像层里。

输出结论时，要把“有意负载”和“意外膨胀”分开说。完整语言运行时或工具链有时是必要的，但残留缓存通常不是。

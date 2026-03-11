# 镜像体积排查文档

本文档记录本仓库排查 Docker 镜像体积的常用方法，以及一次针对 `ai-develop-container:0.0.1-dev` 的实际分析过程。

## 适用场景

当你遇到下面这些情况时，可以按本文步骤检查：

- 构建完成后，镜像体积明显超出预期
- 想知道是哪个 Dockerfile 步骤把镜像撑大了
- 想区分是基础镜像、系统包、语言运行时，还是缓存导致的膨胀

## 1. 先看最终镜像大小

先确认目标镜像的总体体积：

```bash
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" ai-develop-container
```

如果只想看某一个标签：

```bash
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" ai-develop-container:0.0.1-dev
```

输出示例：

```text
REPOSITORY             TAG         SIZE
ai-develop-container   0.0.1-dev   1.93GB
```

这个步骤只能告诉你“有多大”，还不能告诉你“为什么大”。

## 2. 用 `docker history` 看层大小

查看镜像每一层是谁创建的、每层新增了多少内容：

```bash
docker history --no-trunc ai-develop-container:0.0.1-dev
```

重点看两列：

- `CREATED BY`：这一层对应的 Dockerfile 指令
- `SIZE`：这一层引入了多少新内容

排查时通常优先关注最大的几层，例如：

```text
RUN ... apt-get update && apt-get upgrade -y && apt-get install ...   599MB
COPY /usr/local/ /usr/local/                                          200MB
RUN ... npm install -g @anthropic-ai/claude-code ...                  781MB
COPY /usr/local/go /usr/local/go                                      203MB
COPY /uv /uvx /bin/                                                   45.3MB
```

看到这里，已经能快速判断体积主要来自：

- Ubuntu 系统包安装
- Node.js 运行时
- 全局 npm CLI
- Go 工具链
- uv 二进制

## 3. 在临时容器里看目录占用

`docker history` 能定位“哪一层大”，但不能直接告诉你“层里面哪个目录最大”。这时用一次性容器配合 `du` 排查。

查看 `/usr/local` 下的大目录：

```bash
docker run --rm ai-develop-container:0.0.1-dev \
  bash -lc 'du -sh /usr/local/* 2>/dev/null | sort -hr | head -20'
```

输出示例：

```text
566M    /usr/local/lib
233M    /usr/local/go
121M    /usr/local/bin
64M     /usr/local/include
```

这说明大头集中在：

- `/usr/local/lib`
- `/usr/local/go`

## 4. 继续细分语言生态目录

如果你怀疑是 Node.js 全局工具导致镜像变大，可以继续拆：

```bash
docker run --rm ai-develop-container:0.0.1-dev \
  bash -lc 'du -sh /usr/local/lib/node_modules/* 2>/dev/null | sort -hr'
```

输出示例：

```text
370M    /usr/local/lib/node_modules/@costrict
109M    /usr/local/lib/node_modules/@openai
71M     /usr/local/lib/node_modules/@anthropic-ai
17M     /usr/local/lib/node_modules/npm
```

到这里就能确认：全局安装的 AI CLI 是镜像体积的重要来源。

## 5. 检查缓存目录有没有被清理

镜像变大时，除了正式安装内容，另一个常见原因是缓存没清理干净。常看这几个目录：

```bash
docker run --rm ai-develop-container:0.0.1-dev \
  bash -lc 'du -sh /var/lib/apt/lists /var/cache/apt /root/.npm 2>/dev/null'
```

输出示例：

```text
61M     /var/lib/apt/lists
0       /var/cache/apt
197M    /root/.npm
```

这类结果通常表示：

- apt 索引文件还留在镜像里
- npm 下载缓存没有清掉

## 6. 这次排查的结论

对 `ai-develop-container:0.0.1-dev` 的一次实际检查里，主要体积来源如下：

| 来源 | 大致体积 |
| --- | --- |
| Ubuntu 基础层 | 101MB |
| apt 安装层 | 599MB |
| Node.js `/usr/local` | 200MB |
| 全局 npm CLI | 781MB |
| Go 工具链 | 203MB |
| uv | 45MB |

补充观察：

- `/usr/local/lib/node_modules/@costrict` 约 `370MB`
- `/usr/local/lib/node_modules/@openai` 约 `109MB`
- `/usr/local/lib/node_modules/@anthropic-ai` 约 `71MB`
- `/root/.npm` 约 `197MB`
- `/var/lib/apt/lists` 约 `61MB`

因此，这个镜像大不是单点问题，而是多个开发工具叠加后的结果。

## 7. 推荐排查顺序

实际排查时，建议固定按下面顺序走，信息密度最高：

1. `docker images` 看总体大小
2. `docker history --no-trunc` 看是哪几层大
3. `docker run ... du -sh /usr/local/*` 看大目录
4. 针对可疑目录继续细分，例如 `node_modules`
5. 单独检查 apt、npm、pip、cargo 等缓存目录

这个顺序的好处是：

- 先用层信息快速定位问题范围
- 再进容器看目录，避免无目标地乱查

## 8. 常见优化方向

如果排查后确认体积来自下面这些位置，通常可以这样优化：

- `apt` 层过大：减少开发包、避免不必要的 `apt-get upgrade -y`、清理 `/var/lib/apt/lists`
- npm 全局工具过大：减少全局 CLI 数量，安装后清理 `/root/.npm`
- Go 体积过大：确认最终镜像是否真的需要完整 Go 工具链
- 构建依赖过多：把编译依赖留在构建阶段，不带入最终阶段

## 9. 本仓库常用命令清单

下面是可直接复用的排查命令：

```bash
# 看镜像总大小
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" ai-develop-container

# 看镜像层
docker history --no-trunc ai-develop-container:0.0.1-dev

# 看 /usr/local 目录占用
docker run --rm ai-develop-container:0.0.1-dev \
  bash -lc 'du -sh /usr/local/* 2>/dev/null | sort -hr | head -20'

# 看全局 node_modules 占用
docker run --rm ai-develop-container:0.0.1-dev \
  bash -lc 'du -sh /usr/local/lib/node_modules/* 2>/dev/null | sort -hr'

# 看常见缓存目录
docker run --rm ai-develop-container:0.0.1-dev \
  bash -lc 'du -sh /var/lib/apt/lists /var/cache/apt /root/.npm 2>/dev/null'
```

如果后续要排查 Python、Go、Cargo 相关缓存，也可以按相同思路继续看：

```bash
docker run --rm ai-develop-container:0.0.1-dev \
  bash -lc 'du -sh /root/.cache /root/.cargo /root/go 2>/dev/null'
```

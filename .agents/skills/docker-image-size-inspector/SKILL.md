---
name: docker-image-size-inspector
description: 通过检查 Docker 镜像大小、镜像层历史、容器内目录占用和常见缓存目录，诊断镜像为什么过大，并给出基于证据的瘦身建议。适用于用户询问为什么镜像这么大、想定位哪个 Dockerfile 步骤或依赖让镜像膨胀、需要一套可重复执行的镜像体积分析流程、想获得具体的镜像瘦身方案，或想验证 apt、npm、pip、cargo、Go 等缓存清理是否生效的场景。
---

# Docker 镜像体积排查

## 概述

使用这个 skill 将一个超大的 Docker 镜像拆解为“镜像层级原因”和“目录级原因”，再把这些原因映射回具体的 Dockerfile 指令，并最终输出按收益和风险排序的瘦身方案。优先运行附带脚本拿到快速报告，只有在需要更深入解读或落地修改时，再阅读参考文档。

## 快速开始

先运行附带脚本：

```bash
scripts/inspect_image_size.sh <image>
```

示例：

```bash
scripts/inspect_image_size.sh ai-develop-container:0.0.1-dev
```

脚本会输出：

- 镜像总体大小和基础元数据
- 完整的 `docker history`
- 镜像内顶层目录占用情况（前提是镜像里有 shell）
- `/usr/local` 目录拆解
- 全局 `node_modules` 占用情况（如果存在）
- apt、npm、cargo、Go 等常见缓存目录占用情况

## 工作流

1. 确认用户关心的具体镜像标签。
2. 运行 `scripts/inspect_image_size.sh <image>`。
3. 按这个顺序阅读报告：
   - `Image Summary`：确认目标镜像和平台
   - `Layer History`：找出最大的镜像层，以及创建这些层的 Dockerfile 指令
   - `Top-Level Directories` 和 `/usr/local Breakdown`：判断是哪个运行时、工具链或依赖树主导了文件系统体积
   - `Common Cache Directories`：确认清理逻辑是否真的执行了
4. 将最大的镜像层映射回 Dockerfile。
5. 基于证据生成瘦身建议：
   - 删除不必要的包或工具链
   - 将构建期依赖与运行期依赖拆开
   - 在同一个 `RUN` 层里清理缓存
   - 避免过于宽泛的 `COPY`，例如直接复制整个 `/usr/local`
6. 对建议进行分级：
   - `High impact, low risk`：清缓存、移除明显无用的包、收窄 `COPY`
   - `High impact, medium risk`：移除全局 CLI、去掉 `apt-get upgrade -y`、从开发镜像中裁剪部分开发工具
   - `High impact, high risk`：在未确认镜像用途前移除整套运行时或工具链
7. 如果用户要你直接改代码，就检查相关 Dockerfile 或构建脚本，并实现最小且合理的修复。

## 解读规则

- 将超大的 `RUN apt-get ...` 层视为一个信号：需要回看包选择、`apt-get upgrade -y` 是否必要，以及 apt 索引清理是否正确。
- 将超大的 `COPY --from=node ... /usr/local/ /usr/local/` 或 `COPY --from=golang ...` 层优先视为运行时或工具链本身的体积，而不是缓存泄漏。
- 将超大的 `npm install -g` 层优先视为包本体负载，再确认 `/root/.npm` 是否被清理。
- 将非零的 `/var/lib/apt/lists`、`/var/cache/apt`、`/root/.npm`、`/root/.cache`、`/root/.cargo`、`/root/go` 视为清理不完整的证据。
- 如果镜像里没有 `sh` 或 `bash`，就依赖 `docker history` 和手工检查 Dockerfile，不要臆测镜像内目录结构。
- 不要盲目建议移除工具链；先判断这是开发容器、CI 镜像，还是运行时镜像。

## 建议生成规则

- 即使镜像体积有一部分是“有意为之”，也要在结论后给出瘦身建议。
- 每一条建议都要绑定到已观察到的证据，例如大层、大目录或非零缓存路径。
- 区分 `意外膨胀` 和 `有意负载`。
- 优先推荐“不改变行为却能减小体积”的修改，再考虑架构级调整。
- 如果镜像明显是开发容器，将“移除工具链”表述成一个带权衡的选项，而不是默认修复方案。
- 如果镜像明显是运行时镜像，优先推荐多阶段构建，以及把构建依赖排除在最终镜像之外。

## 输出结构

分析结束时，按这个结构输出：

1. `Findings`：最大的层或目录，以及它们分别对应什么内容。
2. `Shrink options`：3-5 条具体修改建议，每条都要绑定证据。
3. `Tradeoffs`：可能损失什么能力，或还需要确认哪些前提。
4. `Next fix to implement`：如果用户现在就要动手，第一步最值得做什么。

## 常见后续动作

- 如果需要手工命令或更深入的结果解读，读取 [references/inspection-playbook.md](references/inspection-playbook.md)。
- 如果需要把发现映射成瘦身建议，读取 [references/optimization-playbook.md](references/optimization-playbook.md)。
- 如果镜像使用了非标准目录布局，就针对 `docker history` 指向的目录补充执行 `du -sh` 检查。
- 如果存在多个大层，分别解释，不要把所有体积都归因于同一个包管理器。

## 触发示例

以下请求都应触发这个 skill：

- “为什么这个 Docker 镜像快 2 GB 了？”
- “是 Dockerfile 里的哪一步把镜像撑大了？”
- “帮我检查 apt 清理到底有没有生效。”
- “给我一套可重复执行的镜像层和缓存排查方法。”
- “分析这个镜像，并告诉我最值得做的瘦身方案。”

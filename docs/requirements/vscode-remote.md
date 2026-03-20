# VS Code Remote 需求

总入口见 [requirements.md](../requirements.md)。

## 1. 背景

项目希望在用户使用本地 VS Code 连接容器时，尽量减少首次连接准备时间，并为后续“预置 `VS Code Server`”能力预留空间。

## 2. 目标

- 明确 VS Code Remote 场景的技术边界。
- 明确哪些能力属于第一阶段，哪些属于后续增强。
- 为预置 `VS Code Server` 的实现预留需求基础。

## 3. 非目标

- 不使用 Coder 的 `code-server` 代替微软的 `VS Code Server`。
- 不保证任意版本本地 VS Code 都无需下载远端 server。
- 不在第一阶段完成完整离线分发。

## 4. 已知约束

- 本场景使用的是微软的 `VS Code Server`，不是 Coder 的 `code-server`。
- `VS Code Server` 与本地 VS Code 客户端版本或 commit 绑定。
- 如果本地 VS Code 升级，而镜像未预置匹配版本，首次连接仍可能重新下载 server。

## 5. 需求项

### 5.1 第一阶段

- `VR-001` 优先保证容器本身开发依赖齐全。
- `VR-002` 明确 Remote Development 的使用方式和限制。
- `VR-003` 第一阶段不强制实现 `VS Code Server` 预置。

### 5.2 后续阶段

- `VR-004` 可预置与特定 VS Code 版本匹配的 `VS Code Server`。
- `VR-005` 可增加扩展预装或扩展缓存。
- `VR-006` 可支持更严格的离线或弱网场景。

## 6. 默认决策

- 默认使用 VS Code `Stable` 渠道。
- 默认锁定 1 个明确的 VS Code 版本或 commit。
- 默认先覆盖 `amd64` 和容器内 `root` 用户。
- 默认允许构建阶段联网获取制品。
- 当本地 VS Code 版本与镜像预置版本一致时，目标是不再下载 server。
- 当版本不一致时，允许按需重新下载。

## 7. 验收标准

- 第一阶段文档中明确说明技术边界与限制。
- 如后续实现预置 server，则需能验证目标 commit 已落到约定目录。

## 8. 当前状态

- 技术边界：已明确。
- `VS Code Server` 预置：未完成。
- 扩展缓存：未完成。

## 9. 待决策项

- 是否锁定本地 VS Code 版本与渠道。
- 是否允许将 `VS Code Server` 制品内置到镜像。
- 网络环境目标是公网、代理、内网还是离线。

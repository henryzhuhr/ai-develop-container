# Agents 仓库指南

## 项目说明

## ⚠️ 注意事项

- 当你在查看项目文档的时候，始终读取 [docs/README.md](./docs/README.md) 以了解文档结构（不同文档的入口）和维护原则。
- 如果一个目录里有 `README.md`，优先阅读它以了解该目录的内容和结构。

## 配置与安全建议

- 不要提交密钥、私有仓库凭据或令牌。
- 优先通过 build args / 环境变量做镜像源与 registry 定制。
- 修改镜像来源（如 `GHCR_MIRROR`、apt mirrors）时需评估供应链风险。

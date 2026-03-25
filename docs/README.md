# 文档索引

本目录按“总览、需求、Issue、指南、运维、工作流”拆分，避免单个文档持续膨胀。

## 结构

- `requirements/`
  - 放“要做什么、为什么做、验收是什么”。
- `issues/`
  - 放“当前已知问题、影响范围、修复方向、验收与状态”。
- `guides/`
  - 放“开发者怎么使用、怎么构建、怎么运行”。
- `ops/`
  - 放“排障、体积分析、运行维护”。
- `workflows/`
  - 放“CI/CD 与仓库维护流程”。

## 入口文档

- [需求主文档](./requirements/README.md)
- [需求入口](./requirements.md)
- [Issue 索引](./issues/README.md)
- [开发指南](./guides/development.md)
- [镜像体积排查](./ops/image-size-inspection.md)
- [文档规范](./documentation-rules.md)

## 维护原则

- `docs/requirements/README.md` 是需求主文档。
- `docs/requirements.md` 只是轻量入口，不承载完整需求正文。
- 具体专题需求必须拆到 `docs/requirements/` 下。
- 已知问题、缺陷和待修复项应放到 `docs/issues/`。
- 使用说明不得写入需求文档，应放到 `docs/guides/`。
- 运维排障文档不得写入需求文档，应放到 `docs/ops/`。

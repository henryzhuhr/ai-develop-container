# 文档拆分与编排规则

本规则用于约束后续文档新增、重构和维护方式。后续新增文档时，必须遵守本文件。

## 1. 文档分类

只允许以下四类业务文档：

- `docs/requirements/`
  - 需求文档，只回答“要做什么、为什么做、如何验收”。
- `docs/guides/`
  - 使用文档，只回答“如何使用、如何操作”。
- `docs/ops/`
  - 运维文档，只回答“如何排障、如何分析、如何维护”。
- `docs/workflows/`
  - 流程文档，只回答“CI/CD 或团队流程如何执行”。

项目级入口文档允许放在：

- `docs/README.md`
- `docs/requirements.md`

需求主文档固定为：

- `docs/requirements/README.md`

## 2. 命名规则

- 优先使用目录分类，不再新增 `requirements.xxx.md` 这类平铺命名。
- 文件名统一使用 kebab-case。
- 需求专题文件统一放在 `docs/requirements/` 下，例如：
  - `core.md`
  - `devcontainer.md`
  - `vscode-remote.md`
  - `verification.md`

## 3. 拆分规则

当满足以下任一条件时，必须拆分子文档：

- 单个文档同时包含总体需求、专项需求、操作说明三类内容。
- 单个文档超过 200 行且仍在持续增长。
- 某个子主题已经出现独立背景、约束、验收标准或待决策项。
- 某个小节未来会被单独维护，例如 Dev Container、VS Code Remote、Java 运行时。

## 4. 总入口规则

`docs/requirements/README.md` 必须始终保持为“需求主文档”，至少包含：

- 背景
- 目标
- 非目标
- 关键约束
- 需求总览表
- 当前阶段范围
- 当前状态
- 子需求目录
- 关键待决策项

`docs/requirements.md` 必须始终保持为“轻量入口”，只允许包含：

- 主文档链接
- 子需求链接
- 极少量说明文字

以下内容不得长期保留在 `docs/requirements.md`：

- 完整需求正文
- 某个专题的详细技术约束
- 长篇方案比较
- 详细使用说明
- 运维排障步骤

## 5. 子需求文档模板

`docs/requirements/` 下的每个需求专题，默认按以下结构编写：

1. 背景
2. 目标
3. 非目标
4. 需求项
5. 验收标准
6. 当前状态
7. 待决策项

如果专题较复杂，可增加：

- 已知约束
- 方案比较
- 默认决策

## 6. 内容边界

- 需求文档不写具体运行命令，命令放到 `guides/`。
- 设计取舍较多时，单独放 `design/` 或继续放在需求文档的“方案比较”中，但不能污染总入口。
- 使用文档不重复解释需求背景，只链接回需求文档。
- 运维文档不重复解释产品目标，只聚焦问题处理。

## 7. 链接规则

- 所有总入口文档都必须链接到子文档。
- 子文档应尽量反向链接回总入口。
- 同一个主题如果存在“需求”和“使用说明”，两者必须互相引用。

## 8. 维护要求

- 新增需求前，先判断是否属于已有专题。
- 若属于已有专题，直接更新对应子文档，不要继续膨胀总入口。
- 若属于全局需求背景、目标、约束、范围或待决策项，应更新 `docs/requirements/README.md`。
- 若不属于已有专题，再新增新的专题文件。
- 修改目录结构时，必须同步更新：
  - `docs/README.md`
  - `docs/requirements.md`
  - `docs/requirements/README.md`
  - 相关交叉链接

## 9. 当前约定

本仓库当前按以下结构维护：

```text
docs/
  README.md
  documentation-rules.md
  requirements.md
  requirements/
    README.md
    devcontainer.md
    vscode-remote.md
    verification.md
  guides/
    development.md
  ops/
    image-size-inspection.md
  workflows/
    build-and-push-image.md
```

后续新增文档时，默认延续该结构，不再回退到平铺模式。

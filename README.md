# AI 开发容器

## 项目简介

本项目是系统构建一个标准的开发容器，内置：

- AI 编程工具：[costrict-cli](https://docs.costrict.ai/plugin/guide/installation)
- Go 语言环境：用于微服务开发
- Python 语言环境：用于自动化测试

## 项目使用说明

拉起容器，将指定的目录（你的项目目录）挂载到容器内，设置工作目录为 `/workspace`，并默认启动 `costrict-cli`：

```bash
docker run -it --rm -v /path/to/your/project:/workspace -w /workspace ai-dev-container costrict-cli
```

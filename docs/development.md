# 开发文档

## CI 文档

- [Build and Push Image 流水线维护说明](./build-and-push-image-workflow.md)

## 构建镜像

```bash
bash scripts/docker-build.sh
```

查看构建的镜像：

```bash
docker images ai-develop-container:1.0.0
```

## 容器操作

### 拉起容器并且进入容器根目录

```bash
docker run -it --rm \
    --name ai-dev-container \
    -v $(pwd):"/root/$(basename $(pwd))" \
    -v ~/.claude:/root/.claude \
    -w "/root/$(basename $(pwd))" \
    ai-develop-container:1.0.0 cs
```

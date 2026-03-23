# 开发文档

## CI 文档

- [Build and Push Image 流水线维护说明](../workflows/build-and-push-image.md)

## 构建镜像

### 本地构建（使用国内镜像源加速）

```bash
bash scripts/docker-build.sh
```

### 指定 Java 版本构建

```bash
JAVA_VERSION=17 IMAGE_TAG=test bash scripts/docker-build.sh
```

### 指定 Java 与 VS Code Server 版本构建

```bash
JAVA_VERSION=21 \
VSCODE_SERVER_COMMITS=07ff9d6178ede9a1bd12ad3399074d726ebe6e43,cb1933bbc38d329b3595673a600fab5c7368f0a7 \
VSCODE_SERVER_CHANNEL=stable \
IMAGE_TAG=test \
bash scripts/docker-build.sh
```

### 手动使用 docker build 构建

```bash
# 国内环境（使用镜像源加速）
docker build -t ai-develop-container:0.0.1-dev -f dockerfiles/Dockerfile \
  --build-arg MIRRORS_URL=mirrors.ustc.edu.cn \
  --build-arg UV_DEFAULT_INDEX=https://pypi.tuna.tsinghua.edu.cn/simple \
  .

# CI 环境（使用官方源）
docker build -t ai-develop-container:0.0.1-dev -f dockerfiles/Dockerfile .

docker images ai-develop-container:0.0.1-dev
```

### 构建后验证

```bash
bash scripts/verify-image.sh ai-develop-container:0.0.1-dev
```

如果只想检查预置的微软 `VS Code Server` commit 目录：

```bash
docker run --rm ai-develop-container:0.0.1-dev bash -lc 'ls -1 /root/.vscode-server/bin'
```

## 容器操作

### 使用 .env 文件管理环境变量（推荐）

项目提供了 `.env.example` 模板文件，复制为 `.env` 后根据需要修改：

```bash
cp .env.example .env
```

启动容器时加载环境变量：

```bash
docker run -it --rm \
    --name ai-dev-container \
    --env-file .env \
    -v $(pwd):"/root/$(basename $(pwd))" \
    -v ~/.claude:/root/.claude \
    -w "/root/$(basename $(pwd))" \
    ai-develop-container:0.0.1-dev cs
```

### 拉起容器并且进入容器根目录（不使用 .env）

```bash
docker run -it --rm \
    --name ai-dev-container \
    -v $(pwd):"/root/$(basename $(pwd))" \
    -v ~/.claude:/root/.claude \
    -w "/root/$(basename $(pwd))" \
    ai-develop-container:0.0.1-dev cs
```

### 运行时传入单个环境变量

```bash
# 使用国内 PyPI 镜像
docker run -it --rm \
    --name ai-dev-container \
    -e UV_DEFAULT_INDEX=https://pypi.tuna.tsinghua.edu.cn/simple \
    -v $(pwd):"/root/$(basename $(pwd))" \
    -v ~/.claude:/root/.claude \
    -w "/root/$(basename $(pwd))" \
    ai-develop-container:0.0.1-dev cs

# 使用国内 npm 镜像
docker run -it --rm \
    --name ai-dev-container \
    -e NPM_CONFIG_REGISTRY=https://registry.npmmirror.com \
    -v $(pwd):"/root/$(basename $(pwd))" \
    -v ~/.claude:/root/.claude \
    -w "/root/$(basename $(pwd))" \
    ai-develop-container:0.0.1-dev cs
```

### 自定义镜像标签

如果构建了自定义标签的镜像，使用时替换标签即可：

```bash
docker run -it --rm \
    --name ai-dev-container \
    -v $(pwd):"/root/$(basename $(pwd))" \
    -v ~/.claude:/root/.claude \
    -w "/root/$(basename $(pwd))" \
    ai-develop-container:<your-tag> cs
```

#!/bin/bash

# MemOS 镜像构建脚本
# 用于 1Panel 部署

set -e

# 配置变量
IMAGE_NAME="memos"
IMAGE_TAG="latest"
DOCKERFILE_PATH="$(dirname "$0")/Dockerfile"
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "=========================================="
echo "MemOS 镜像构建脚本"
echo "=========================================="
echo "项目根目录: $PROJECT_ROOT"
echo "Dockerfile 路径: $DOCKERFILE_PATH"
echo "镜像名称: $IMAGE_NAME:$IMAGE_TAG"
echo "=========================================="

# 检查 Dockerfile 是否存在
if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo "错误: Dockerfile 不存在: $DOCKERFILE_PATH"
    exit 1
fi

# 检查项目目录是否存在
if [ ! -d "$PROJECT_ROOT/project/MemOS" ]; then
    echo "错误: MemOS 项目目录不存在: $PROJECT_ROOT/project/MemOS"
    exit 1
fi

# 构建镜像
echo "开始构建镜像..."
cd "$PROJECT_ROOT"

docker build \
    -f "$DOCKERFILE_PATH" \
    -t "$IMAGE_NAME:$IMAGE_TAG" \
    .

if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "镜像构建成功!"
    echo "镜像名称: $IMAGE_NAME:$IMAGE_TAG"
    echo "=========================================="
    echo ""
    echo "可以使用以下命令查看镜像:"
    echo "  docker images | grep $IMAGE_NAME"
    echo ""
    echo "可以使用以下命令运行容器:"
    echo "  docker run -d --name memos-test -p 8000:8000 $IMAGE_NAME:$IMAGE_TAG"
    echo ""
    echo "或者使用 docker-compose 启动:"
    echo "  cd deployment/1panel"
    echo "  docker-compose up -d"
else
    echo "=========================================="
    echo "镜像构建失败!"
    echo "=========================================="
    exit 1
fi


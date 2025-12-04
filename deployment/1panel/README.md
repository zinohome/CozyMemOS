# MemOS 1Panel 部署指南

## 概述

本文档介绍如何在 1Panel 环境中部署 MemOS 项目。

## 前置要求

1. **1Panel 环境**: 已安装并配置 1Panel
2. **Docker**: 已安装 Docker 和 Docker Compose
3. **网络**: 确保 `1panel-network` 网络已创建
4. **数据目录**: 确保 `/data/MemOS` 目录存在且有写权限

## 目录结构

```
deployment/1panel/
├── docker-compose.yml    # Docker Compose 配置文件
├── Dockerfile            # MemOS 应用镜像构建文件
├── build-image.sh       # 镜像构建脚本
└── README.md            # 本文件
```

## 部署步骤

### 1. 创建数据目录

在 1Panel 服务器上创建必要的数据目录：

```bash
sudo mkdir -p /data/MemOS/{memos,qdrant,neo4j}/{data,logs}
sudo mkdir -p /data/MemOS/neo4j/{import,plugins}
sudo chmod -R 755 /data/MemOS
```

### 2. 创建 1Panel 网络（如果不存在）

```bash
docker network create 1panel-network
```

### 3. 构建 MemOS 镜像

在项目根目录执行：

```bash
cd deployment/1panel
./build-image.sh
```

或者手动构建：

```bash
cd /path/to/CozyMemOS
docker build -f deployment/1panel/Dockerfile -t memos:latest .
```

### 4. 配置环境变量（必需）

**重要**: MemOS 需要配置 OpenAI API Key 才能正常启动。

有两种方式配置环境变量：

#### 方式 1: 使用环境变量（推荐）

在启动前设置环境变量：

```bash
export OPENAI_API_KEY="your-actual-api-key"
export OPENAI_API_BASE="https://api.openai.com/v1"
export MEMRADER_API_KEY="your-actual-api-key"
export MEMRADER_API_BASE="https://api.openai.com/v1"
```

然后启动服务，docker-compose 会自动读取这些环境变量。

#### 方式 2: 直接修改 docker-compose.yml

编辑 `docker-compose.yml` 文件，找到以下行并替换默认值：

```yaml
- OPENAI_API_KEY=${OPENAI_API_KEY:-your-api-key-here}
- MEMRADER_API_KEY=${MEMRADER_API_KEY:-${OPENAI_API_KEY:-your-api-key-here}}
```

将 `your-api-key-here` 替换为你的实际 API Key。

**必需的环境变量**:
- `OPENAI_API_KEY`: OpenAI API 密钥（必需）
- `OPENAI_API_BASE`: OpenAI API 基础 URL（默认: https://api.openai.com/v1）
- `MEMRADER_API_KEY`: MemReader 使用的 API 密钥（默认与 OPENAI_API_KEY 相同）
- `MEMRADER_API_BASE`: MemReader 使用的 API 基础 URL（默认与 OPENAI_API_BASE 相同）

**注意**: `MEMRADER_API_BASE` 是必需的，如果未设置会导致启动失败。

### 5. 启动服务

```bash
cd deployment/1panel
docker-compose up -d
```

### 6. 验证部署

检查服务状态：

```bash
docker-compose ps
```

查看日志：

```bash
# MemOS 应用日志
docker-compose logs memos

# Qdrant 日志
docker-compose logs qdrant

# Neo4j 日志
docker-compose logs neo4j
```

测试 API：

```bash
curl http://localhost:8000/docs
```

## 服务说明

### MemOS API 服务

- **容器名**: `memos`
- **端口**: `8000`
- **数据目录**: `/data/MemOS/memos/`
- **环境变量**:
  - `PYTHONPATH=/app/src`
  - `HF_ENDPOINT`: HuggingFace 镜像地址
  - `QDRANT_HOST`: Qdrant 服务地址
  - `QDRANT_PORT`: Qdrant 服务端口
  - `NEO4J_URI`: Neo4j 连接 URI
  - `NEO4J_AUTH`: Neo4j 认证信息

### Qdrant 向量数据库

- **容器名**: `qdrant`
- **端口**: `6333` (HTTP), `6334` (gRPC)
- **数据目录**: `/data/MemOS/qdrant/data`
- **镜像**: `qdrant/qdrant:v1.15.3`

### Neo4j 图数据库

- **容器名**: `neo4j`
- **端口**: `7474` (HTTP), `7687` (Bolt)
- **数据目录**: `/data/MemOS/neo4j/`
- **镜像**: `neo4j:5.26.4`
- **默认认证**: `neo4j/12345678` (生产环境请修改)

## 数据持久化

所有数据存储在 `/data/MemOS/` 目录下：

```
/data/MemOS/
├── memos/          # MemOS 应用数据
│   ├── data/       # 应用数据
│   └── logs/       # 应用日志
├── qdrant/         # Qdrant 数据
│   └── data/       # 向量数据库数据
└── neo4j/          # Neo4j 数据
    ├── data/       # 图数据库数据
    ├── logs/       # 日志
    ├── import/     # 导入数据
    └── plugins/    # 插件
```

## 常用操作

### 停止服务

```bash
docker-compose down
```

### 重启服务

```bash
docker-compose restart
```

### 更新镜像

```bash
# 1. 重新构建镜像
./build-image.sh

# 2. 停止并删除旧容器
docker-compose down

# 3. 启动新容器
docker-compose up -d
```

### 查看服务状态

```bash
docker-compose ps
```

### 查看日志

```bash
# 所有服务日志
docker-compose logs -f

# 特定服务日志
docker-compose logs -f memos
docker-compose logs -f qdrant
docker-compose logs -f neo4j
```

### 进入容器

```bash
# MemOS 容器
docker exec -it memos bash

# Qdrant 容器
docker exec -it qdrant bash

# Neo4j 容器
docker exec -it neo4j bash
```

## 配置说明

### 修改 Neo4j 密码

1. 停止服务：
```bash
docker-compose down
```

2. 修改 `docker-compose.yml` 中的 `NEO4J_AUTH` 环境变量

3. 删除旧数据（如果需要）：
```bash
sudo rm -rf /data/MemOS/neo4j/data/*
```

4. 重启服务：
```bash
docker-compose up -d
```

### 修改端口

编辑 `docker-compose.yml` 文件中的 `ports` 配置。

### 添加环境变量

在 `docker-compose.yml` 的 `memos` 服务的 `environment` 部分添加。

## 故障排查

### 服务无法启动

1. 检查日志：
```bash
docker-compose logs
```

2. 检查网络：
```bash
docker network inspect 1panel-network
```

3. 检查数据目录权限：
```bash
ls -la /data/MemOS
```

### 连接数据库失败

1. 检查服务是否运行：
```bash
docker-compose ps
```

2. 检查网络连接：
```bash
docker exec memos ping qdrant
docker exec memos ping neo4j
```

3. 检查环境变量：
```bash
docker exec memos env | grep -E "QDRANT|NEO4J"
```

### 数据丢失

数据存储在 `/data/MemOS/` 目录，确保该目录有正确的权限和足够的空间。

## 安全建议

1. **修改默认密码**: 生产环境请修改 Neo4j 的默认密码
2. **限制端口访问**: 使用防火墙限制外部访问
3. **使用 HTTPS**: 生产环境建议使用反向代理配置 HTTPS
4. **定期备份**: 定期备份 `/data/MemOS/` 目录
5. **监控日志**: 定期检查日志文件

## 性能优化

1. **调整工作进程数**: 修改 `docker-compose.yml` 中 MemOS 的 `--workers` 参数
2. **资源限制**: 在 `docker-compose.yml` 中添加 `deploy.resources` 配置
3. **数据目录**: 将数据目录挂载到高性能存储

## 备份和恢复

### 备份

```bash
# 备份所有数据
tar -czf memos-backup-$(date +%Y%m%d).tar.gz /data/MemOS
```

### 恢复

```bash
# 停止服务
docker-compose down

# 恢复数据
tar -xzf memos-backup-YYYYMMDD.tar.gz -C /

# 启动服务
docker-compose up -d
```

## 支持

如有问题，请参考：
- [MemOS 官方文档](https://memos-docs.openmem.net/)
- [项目分析文档](../../docs/MemOS项目分析文档.md)


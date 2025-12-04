# CozyMemOS

MemOS 项目的 1Panel 本地部署改造方案。

## 项目简介

本项目包含 MemOS (Memory Operating System) 的 1Panel 本地部署配置和相关文档。

MemOS 是一个开源的 AI Agent 记忆框架，为 AI 智能体提供长期记忆、个性一致性和上下文回忆能力。

## 项目结构

```
CozyMemOS/
├── docs/                          # 项目文档
│   ├── MemOS项目分析文档.md       # MemOS 详细分析文档
│   └── 1Panel部署总结.md         # 1Panel 部署总结
├── deployment/                    # 部署配置
│   └── 1panel/                    # 1Panel 部署文件
│       ├── docker-compose.yml     # Docker Compose 配置
│       ├── Dockerfile             # MemOS 镜像构建文件
│       ├── build-image.sh         # 镜像构建脚本
│       └── README.md              # 部署指南
└── project/                       # MemOS 项目源码（已忽略）

```

## 快速开始

### 前置要求

- Docker 和 Docker Compose
- 1Panel 环境（可选）
- `/data/MemOS` 目录的写权限

### 部署步骤

1. **创建数据目录**
```bash
sudo mkdir -p /data/MemOS/{memos,qdrant,neo4j}/{data,logs}
sudo mkdir -p /data/MemOS/neo4j/{import,plugins}
```

2. **创建 Docker 网络**
```bash
docker network create 1panel-network
```

3. **构建镜像**
```bash
cd deployment/1panel
./build-image.sh
```

4. **启动服务**
```bash
docker-compose up -d
```

详细部署说明请参考 [部署指南](deployment/1panel/README.md)

## 文档

- [MemOS 项目分析文档](docs/MemOS项目分析文档.md) - 详细的项目架构和技术分析
- [1Panel 部署总结](docs/1Panel部署总结.md) - 部署方案总结
- [部署指南](deployment/1panel/README.md) - 详细的部署步骤和配置说明

## 特性

- ✅ 符合 1Panel 部署规范
- ✅ 数据目录统一管理（`/data/MemOS/`）
- ✅ 独立的镜像构建脚本
- ✅ 完整的服务配置（MemOS API、Qdrant、Neo4j）
- ✅ 详细的文档和部署指南

## 服务说明

- **MemOS API**: 主应用服务，端口 8000
- **Qdrant**: 向量数据库，端口 6333/6334
- **Neo4j**: 图数据库，端口 7474/7687

## 许可证

本项目遵循 Apache 2.0 许可证。

## 相关链接

- [MemOS 官方网站](https://memos.openmem.net/)
- [MemOS 文档](https://memos-docs.openmem.net/)
- [MemOS GitHub](https://github.com/MemTensor/MemOS)


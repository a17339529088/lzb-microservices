# Nacos配置中心部署指南

## 概述

本指南说明如何将微服务配置迁移到Nacos配置中心，并修复服务unhealthy状态。

## 架构变更

### 配置管理方式

**之前**: 配置硬编码在application.yml和docker-compose.yml中
**现在**: 配置集中管理在Nacos配置中心

### 配置文件结构

```
lzb-microservices/
├── lzb-gateway/src/main/resources/
│   ├── bootstrap.yml          # Nacos连接配置（新增）
│   └── application.yml         # 本地开发配置（简化）
├── lzb-uaa/src/main/resources/
│   ├── bootstrap.yml          # Nacos连接配置（新增）
│   ├── application.yml         # 本地开发配置（简化）
│   └── nacos-config.yml       # Nacos配置文档（新增）
└── lzb-product/src/main/resources/
    ├── bootstrap.yml          # Nacos连接配置（新增）
    └── application.yml         # 本地开发配置（简化）
```

## 部署步骤

### 1. 准备工作

确保以下服务已启动并健康：
- MySQL (端口3306)
- Redis (端口6379)
- OpenLDAP (端口389)
- Nacos (端口8848)

```bash
# 检查基础设施状态
docker-compose ps
```

### 2. 导入Nacos配置

#### 方式1: 使用自动化脚本（推荐）

```bash
cd /root/liuzhibin/lzb-microservices
bash scripts/import-nacos-config.sh
```

#### 方式2: 手动通过Nacos控制台

1. 访问 http://localhost:8848/nacos
2. 登录 (用户名/密码: nacos/nacos)
3. 进入"配置管理" -> "配置列表"
4. 创建以下配置：

**配置1: common-config.yml**
- Data ID: `common-config.yml`
- Group: `DEFAULT_GROUP`
- 配置格式: `YAML`
- 配置内容: 参考 `lzb-uaa/src/main/resources/nacos-config.yml`

**配置2: lzb-uaa-docker.yml**
- Data ID: `lzb-uaa-docker.yml`
- Group: `DEFAULT_GROUP`
- 配置格式: `YAML`
- 配置内容: 参考 `lzb-uaa/src/main/resources/nacos-config.yml`
- **重要**: 设置正确的 `GITHUB_CLIENT_ID` 和 `GITHUB_CLIENT_SECRET`

**配置3: lzb-product-docker.yml**
- Data ID: `lzb-product-docker.yml`
- Group: `DEFAULT_GROUP`
- 配置格式: `YAML`
- 配置内容: 参考 `lzb-uaa/src/main/resources/nacos-config.yml`

**配置4: lzb-gateway-docker.yml**
- Data ID: `lzb-gateway-docker.yml`
- Group: `DEFAULT_GROUP`
- 配置格式: `YAML`
- 配置内容: 参考 `lzb-uaa/src/main/resources/nacos-config.yml`

### 3. 设置GitHub OAuth环境变量

在服务器上设置环境变量或创建 `.env` 文件：

```bash
# 创建.env文件
cat > .env << EOF
GITHUB_CLIENT_ID=your-actual-github-client-id
GITHUB_CLIENT_SECRET=your-actual-github-client-secret
EOF
```

### 4. 编译和部署服务

#### 方式1: 使用自动化脚本（推荐）

```bash
cd /root/liuzhibin/lzb-microservices
bash scripts/build-and-deploy.sh
```

#### 方式2: 手动部署

```bash
# 1. 清理和编译
mvn clean package -DskipTests

# 2. 停止旧容器
docker-compose stop lzb-gateway lzb-uaa lzb-product
docker-compose rm -f lzb-gateway lzb-uaa lzb-product

# 3. 构建新镜像
docker-compose build lzb-gateway lzb-uaa lzb-product

# 4. 启动服务
docker-compose up -d

# 5. 查看日志
docker-compose logs -f lzb-gateway lzb-uaa lzb-product
```

### 5. 验证服务健康状态

等待1-2分钟让服务完全启动，然后检查健康状态：

```bash
# 检查所有容器状态
docker-compose ps

# 检查Gateway健康状态
curl http://localhost:7573/actuator/health

# 检查UAA健康状态
docker exec lzb-uaa curl -f http://localhost:9999/actuator/health

# 检查Product健康状态
docker exec lzb-product curl -f http://localhost:8081/actuator/health

# 检查Nacos服务注册
curl http://localhost:8848/nacos/v1/ns/instance/list?serviceName=lzb-gateway
curl http://localhost:8848/nacos/v1/ns/instance/list?serviceName=lzb-uaa
curl http://localhost:8848/nacos/v1/ns/instance/list?serviceName=lzb-product
```

### 6. 测试API接口

使用提供的测试脚本：

```bash
bash API_EXAMPLES.sh
```

或手动测试5个核心API：

```bash
# 1. 用户名密码登录
curl -X POST http://localhost:7573/uaa/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# 2. LDAP登录
curl -X POST http://localhost:7573/uaa/ldap/login \
  -H "Content-Type: application/json" \
  -d '{"username":"zhangsan","password":"password123"}'

# 3. GitHub OAuth登录（需要浏览器）
# 访问: http://localhost:7573/uaa/oauth2/authorization/github

# 4. 获取产品列表（需要token）
curl -X GET http://localhost:7573/api/products \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# 5. 创建产品（需要ADMIN角色）
curl -X POST http://localhost:7573/api/products \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"New Product","price":99.99,"stock":100}'
```

## 故障排查

### 服务unhealthy

**症状**: 容器状态显示unhealthy

**可能原因**:
1. Nacos配置未导入或配置错误
2. 服务无法连接到Nacos
3. 数据库连接失败
4. Redis连接失败

**解决方法**:

```bash
# 1. 检查服务日志
docker-compose logs lzb-gateway
docker-compose logs lzb-uaa
docker-compose logs lzb-product

# 2. 检查Nacos配置
# 访问 http://localhost:8848/nacos 确认配置已导入

# 3. 检查网络连接
docker exec lzb-uaa ping -c 3 nacos
docker exec lzb-uaa ping -c 3 mysql
docker exec lzb-uaa ping -c 3 redis

# 4. 重启服务
docker-compose restart lzb-gateway lzb-uaa lzb-product
```

### GitHub OAuth不工作

**症状**: GitHub登录失败或返回错误

**可能原因**:
1. GitHub OAuth配置未在Nacos中设置
2. GITHUB_CLIENT_ID或GITHUB_CLIENT_SECRET错误
3. GitHub OAuth应用回调URL配置错误

**解决方法**:

```bash
# 1. 检查Nacos配置
# 访问 http://localhost:8848/nacos
# 查看 lzb-uaa-docker.yml 配置中的GitHub OAuth设置

# 2. 更新Nacos配置
# 在Nacos控制台编辑 lzb-uaa-docker.yml
# 确保 GITHUB_CLIENT_ID 和 GITHUB_CLIENT_SECRET 正确

# 3. 重启UAA服务
docker-compose restart lzb-uaa

# 4. 检查GitHub OAuth应用设置
# 回调URL应该是: http://localhost:7573/uaa/login/oauth2/code/github
```

### 服务无法注册到Nacos

**症状**: Nacos控制台看不到服务实例

**可能原因**:
1. bootstrap.yml配置错误
2. Nacos服务地址不可达
3. 服务启动失败

**解决方法**:

```bash
# 1. 检查bootstrap.yml配置
cat lzb-uaa/src/main/resources/bootstrap.yml

# 2. 检查Nacos连接
docker exec lzb-uaa curl -f http://nacos:8848/nacos/v1/console/health/readiness

# 3. 检查服务日志中的Nacos注册信息
docker-compose logs lzb-uaa | grep -i nacos
```

## 配置热更新

Nacos支持配置热更新，无需重启服务：

1. 在Nacos控制台修改配置
2. 点击"发布"
3. 服务会自动刷新配置（refresh-enabled: true）

## 回滚方案

如果新配置有问题，可以快速回滚：

```bash
# 1. 停止新服务
docker-compose stop lzb-gateway lzb-uaa lzb-product

# 2. 恢复旧的docker-compose.yml（如果有备份）
# 或在Nacos中恢复旧配置

# 3. 重启服务
docker-compose up -d
```

## 监控和维护

### 查看服务状态

```bash
# 查看所有容器状态
docker-compose ps

# 查看服务日志
docker-compose logs -f lzb-gateway
docker-compose logs -f lzb-uaa
docker-compose logs -f lzb-product

# 查看Nacos服务列表
curl http://localhost:8848/nacos/v1/ns/service/list?pageNo=1&pageSize=10
```

### 配置备份

定期备份Nacos配置：

```bash
# 导出所有配置
curl "http://localhost:8848/nacos/v1/cs/configs?export=true&group=DEFAULT_GROUP" > nacos-config-backup.zip
```

## 总结

通过本次配置迁移：

1. ✅ 所有配置集中管理在Nacos配置中心
2. ✅ GitHub OAuth配置从docker-compose迁移到Nacos
3. ✅ 支持配置热更新，无需重启服务
4. ✅ 配置版本化管理，支持回滚
5. ✅ 环境隔离（通过profile和namespace）
6. ✅ 服务健康状态正常
7. ✅ 所有API接口正常工作

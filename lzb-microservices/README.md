# LZB Microservices - Spring Cloud 微服务DEMO

基于Spring Cloud的微服务架构示例项目，实现了完整的认证授权、服务注册发现、API网关等功能。

## 快速开始

### 前置要求
- Docker & Docker Compose
- Maven 3.5+
- JDK 17

### 三步部署

```bash
# 1. 克隆并构建
git clone https://github.com/a17339529088/lzb-microservices.git
cd lzb-microservices
mvn clean package -DskipTests

# 2. 启动所有服务
docker-compose up -d

# 3. 测试接口（等待约 1 分钟服务启动完成）
curl -X POST "http://localhost:7573/uaa/token?grant_type=password&username=admin&password=admin123"
```

**注意：** 如需使用 GitHub 登录，请参考下面"步骤4: 配置 Nacos 配置中心（可选）"。

### ⚠️ 重要提示

**项目已包含完整默认配置，可直接启动！**

**配置说明：**
- **所有配置**：已在项目 `application.yml` 中（数据库、Redis、LDAP、JWT 等）
- **Nacos 配置**：仅用于可选覆盖（如 GitHub OAuth Client ID/Secret）
- **开箱即用**：`mvn clean install && docker-compose up` 即可运行

详细配置步骤请参考下面的"部署方式一"中的"步骤4: 配置 Nacos 配置中心（可选）"。

---

## 项目简介

本项目是一个完整的Spring Cloud微服务DEMO，包含以下核心功能：

- **多种认证方式**：支持数据库、LDAP、GitHub OAuth2三种登录方式
- **基于角色的权限控制**：USER、EDITOR、PRODUCT_ADMIN三级角色体系
- **服务注册发现**：使用Nacos作为注册中心和配置中心
- **API网关**：统一入口，Token验证，路由转发
- **JWT Token**：基于Redis的Token存储，3小时过期
- **DDD架构**：领域驱动设计，清晰的分层结构

## 技术栈

- **Java**: 17
- **Spring Boot**: 3.2.3
- **Spring Cloud**: 2023.0.3
- **Spring Cloud Alibaba**: 2023.0.1.0
- **MyBatis-Flex**: 1.9.7
- **MySQL**: 8.0
- **Redis**: 7
- **OpenLDAP**: 1.5.0
- **Nacos**: 2.3.0

## 系统架构

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │ :7573 (唯一对外端口)
       ▼
┌─────────────────────────────────────────┐
│          lzb-gateway (网关)              │
│  - Token验证                             │
│  - 路由转发                              │
│  - Header传递 (X-User-Id, X-User-Roles) │
└────┬─────────────────────────┬──────────┘
     │                         │
     ▼                         ▼
┌──────────────┐        ┌──────────────┐
│  lzb-uaa     │        │ lzb-product  │
│  (认证服务)   │        │  (产品服务)   │
│  :9999       │        │  :8081       │
└──────────────┘        └──────────────┘
     │                         │
     └────────┬────────────────┘
              ▼
     ┌────────────────┐
     │     Nacos      │
     │  (注册/配置)    │
     │    :8848       │
     └────────────────┘
```

## 服务说明

### 1. lzb-gateway (API网关)
- **端口**: 7573 (对外唯一端口)
- **功能**: 
  - Token验证（检查Redis）
  - 路由转发（/uaa/** → UAA服务，/api/products/** → Product服务）
  - 用户信息传递（通过Header）

### 2. lzb-uaa (认证服务)
- **端口**: 9999 (内部)
- **功能**:
  - 数据库登录（用户名/密码）
  - LDAP登录（企业目录集成）
  - GitHub OAuth2登录（社交登录）
  - JWT Token生成和管理
  - Thymeleaf登录页面

### 3. lzb-product (产品服务)
- **端口**: 8081 (内部)
- **功能**:
  - 产品CRUD操作
  - 基于角色的权限控制
  - 软删除支持

## 角色权限体系

| 角色 | 权限 | 说明 |
|------|------|------|
| USER | 查询产品列表、查询产品详情 | 普通用户 |
| EDITOR | USER权限 + 创建、修改、删除产品 | 编辑者 |
| PRODUCT_ADMIN | EDITOR所有权限 | 产品管理员 |

**角色继承**: PRODUCT_ADMIN > EDITOR > USER

## 快速开始

### 前置要求

- JDK 17
- Maven 3.8+
- Docker & Docker Compose

### 部署方式一：Docker Compose 部署（推荐）

#### 1. 克隆代码

```bash
# 克隆仓库
git clone https://github.com/a17339529088/lzb-microservices.git
cd lzb-microservices
```

#### 2. 构建项目

```bash
# 构建项目
mvn clean package -DskipTests
```

#### 3. 启动基础设施服务

```bash
# 启动所有服务（包括MySQL、Redis、Nacos、LDAP等基础设施）
docker-compose up -d

# 等待 Nacos 启动完成（约30秒）
docker-compose logs -f nacos
# 看到 "Nacos started successfully" 后按 Ctrl+C 退出日志查看
```

#### 4. 配置 Nacos 配置中心（可选）

**说明：**
- 项目已包含完整的默认配置，可以直接启动
- Nacos 配置中心仅用于覆盖默认配置（如 GitHub OAuth）
- 如果不使用 GitHub 登录，可以跳过此步骤

##### 步骤 4.1: 访问 Nacos 控制台（可选）

```bash
# 浏览器访问
http://localhost:8848/nacos

# 如果是远程服务器，替换为服务器IP
http://your-server-ip:8848/nacos

# 登录凭证
用户名: nacos
密码: nacos
```

##### 步骤 4.2: 配置 GitHub OAuth（可选）

**仅在需要使用 GitHub 登录时配置**

1. 点击左侧菜单 **"配置管理"** → **"配置列表"**
2. 点击右上角 **"+"** 按钮（创建配置）
3. 填写以下信息：

| 字段 | 值 |
|------|-----|
| **Data ID** | `lzb-uaa-docker.yml` |
| **Group** | `DEFAULT_GROUP` |
| **配置格式** | `YAML` |

4. **配置内容**（仅需配置 GitHub OAuth 部分）:

```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          github:
            client-id: your-real-github-client-id
            client-secret: your-real-github-client-secret
```

5. 点击 **"发布"** 按钮

##### 步骤 4.3: GitHub OAuth 申请步骤（可选）

如果需要使用 GitHub 登录功能，需要申请 GitHub OAuth App：

**申请步骤：**

1. 访问 GitHub 开发者设置: https://github.com/settings/developers
2. 点击 **"New OAuth App"**
3. 填写应用信息：
   - **Application name**: `LZB Microservices`（随意填写）
   - **Homepage URL**: `http://localhost:7573`（或你的服务器地址）
   - **Authorization callback URL**: `http://localhost:7573/uaa/login/oauth2/code/github`
     - ⚠️ 如果是远程服务器，替换为: `http://your-server-ip:7573/uaa/login/oauth2/code/github`
4. 点击 **"Register application"**
5. 复制 **Client ID** 和 **Client Secret**
6. 回到 Nacos 控制台，按照步骤 4.2 创建配置
7. 重启 UAA 服务: `docker-compose restart lzb-uaa`

**注意事项：**

- 如果**不使用 GitHub 登录**，无需配置，数据库和 LDAP 登录仍然可用
- GitHub OAuth 配置可以随时修改，修改后会自动刷新（无需重启服务）

---

#### 5. 启动应用服务

配置完成后，重启应用服务使配置生效：

```bash
# 重启应用服务
docker-compose restart lzb-gateway lzb-uaa lzb-product

# 或者如果是首次启动，直接启动即可
# docker-compose up -d lzb-gateway lzb-uaa lzb-product
```

#### 6. 验证服务状态

等待所有服务启动完成（约2-3分钟），可以查看日志：

```bash
# 查看所有服务状态
docker-compose ps

# 查看应用服务日志
docker-compose logs -f lzb-gateway
docker-compose logs -f lzb-uaa
docker-compose logs -f lzb-product
```

#### 7. 测试 API

使用提供的测试脚本：

```bash
# Linux/Mac
bash test-api.sh http://localhost:7573

# Windows PowerShell
.\test-api.ps1 http://localhost:7573

# Windows CMD
test-api.bat http://localhost:7573
```

或手动测试登录接口：

```bash
# 数据库登录
curl -X POST "http://localhost:7573/uaa/token?grant_type=password&username=admin&password=admin123"

# LDAP 登录
curl -X POST "http://localhost:7573/uaa/token?grant_type=ldap&username=ldap_editor_1&password=ldap_editor_1"
```

#### 8. 访问服务

- **API Gateway**: http://localhost:7573
- **Nacos控制台**: http://localhost:8848/nacos (用户名/密码: nacos/nacos)

### 部署方式二：本地 JAR 部署

#### 1. 克隆代码并构建

```bash
git clone https://github.com/a17339529088/lzb-microservices.git
cd lzb-microservices
mvn clean package -DskipTests
```

#### 2. 启动基础设施

```bash
# 只启动基础设施服务（MySQL、Redis、Nacos、LDAP）
docker-compose up -d mysql redis nacos openldap
```

#### 3. 等待基础设施就绪

```bash
# 等待约30秒，确保Nacos完全启动
sleep 30
```

#### 4. 启动应用服务

```bash
# 启动Gateway（后台运行）
nohup java -jar lzb-gateway/target/lzb-gateway-1.0-SNAPSHOT.jar > gateway.log 2>&1 &

# 启动UAA服务（后台运行）
nohup java -jar lzb-uaa/target/lzb-uaa-1.0-SNAPSHOT.jar > uaa.log 2>&1 &

# 启动Product服务（后台运行）
nohup java -jar lzb-product/target/lzb-product-1.0-SNAPSHOT.jar > product.log 2>&1 &
```

#### 5. 查看日志

```bash
# 实时查看日志
tail -f gateway.log
tail -f uaa.log
tail -f product.log
```

#### 6. 停止服务

```bash
# 查找进程ID
ps aux | grep lzb

# 停止服务
kill <PID>

# 或使用pkill
pkill -f lzb-gateway
pkill -f lzb-uaa
pkill -f lzb-product
```

### 部署方式三：生产环境部署

#### 1. 服务器环境准备

```bash
# 安装JDK 17
sudo yum install java-17-openjdk-devel -y

# 安装Docker
curl -fsSL https://get.docker.com | bash -s docker
sudo systemctl start docker
sudo systemctl enable docker

# 安装Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 2. 克隆代码并部署

```bash
# 创建部署目录
sudo mkdir -p /opt/lzb-microservices
cd /opt/lzb-microservices

# 克隆代码
git clone https://github.com/a17339529088/lzb-microservices.git .

# 构建项目
mvn clean package -DskipTests

# 启动服务
docker-compose up -d

# 查看服务状态
docker-compose ps
```

#### 3. 配置防火墙

```bash
# 开放Gateway端口（对外唯一端口）
sudo firewall-cmd --permanent --add-port=7573/tcp

# 开放Nacos控制台端口（可选）
sudo firewall-cmd --permanent --add-port=8848/tcp

# 重载防火墙
sudo firewall-cmd --reload
```

#### 4. 配置开机自启

创建systemd服务文件：

```bash
sudo vim /etc/systemd/system/lzb-microservices.service
```

内容如下：

```ini
[Unit]
Description=LZB Microservices
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/lzb-microservices
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

启用服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable lzb-microservices
sudo systemctl start lzb-microservices
```


## API测试

### 题目要求的API接口

本项目实现了题目要求的5个核心API接口：

1. **POST /uaa/token** - 获取访问令牌（支持数据库、LDAP、GitHub三种登录方式）
2. **GET /api/products** - 浏览产品列表（需要USER角色）
3. **POST /api/products** - 添加产品（需要EDITOR角色）
4. **PUT /api/products/{id}** - 修改产品（需要EDITOR角色）
5. **DELETE /api/products/{id}** - 删除产品（需要EDITOR角色）

### 1. 获取ACCESS TOKEN

#### 数据库登录

```bash
curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin&password=admin123"
```

**实际输出**:
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "accessToken": "eyJhbGciOiJIUzM4NCJ9.eyJqdGkiOiJhMTlhNzNiYi0yOGU4LTRhNTYtYmQxNi1jZWJkZDc1ZGE2ZmIiLCJzdWIiOiJhZG1pbiIsInVzZXJfaWQiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJyb2xlcyI6WyJQUk9EVUNUX0FETUlOIl0sInNvdXJjZSI6IkRBVEFCQVNFIiwiaWF0IjoxNzcwODYwNzQ2LCJleHAiOjE3NzA4NzE1NDZ9.QDJ_LDgecZ1jn1vyvEMDW8TFpxCJPrjq4vTbqLrA1Ltml57SIdMRglhsp_HunVZs",
    "tokenType": "Bearer",
    "expiresIn": 10800
  }
}
```

#### LDAP登录

```bash
# LDAP USER用户（USER角色）
curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=ldap_user_1&password=ldap_user_1&auth_type=ldap"

# LDAP EDITOR用户（EDITOR角色）
curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=ldap_editor_1&password=ldap_editor_1&auth_type=ldap"

# LDAP ADMIN用户（PRODUCT_ADMIN角色）
curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=ldap_adm_1&password=ldap_adm_1&auth_type=ldap"
```

**实际输出（ldap_editor_1）**:
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "accessToken": "eyJhbGciOiJIUzM4NCJ9.eyJqdGkiOiJkNzdhZjZlMy05NjE1LTQ0ZWYtYThiZC1mMDE1NjExNWJlMjciLCJzdWIiOiJsZGFwX2VkaXRvcl8xIiwidXNlcl9pZCI6NiwidXNlcm5hbWUiOiJsZGFwX2VkaXRvcl8xIiwicm9sZXMiOlsiRURJVE9SIl0sInNvdXJjZSI6IkxEQVAiLCJpYXQiOjE3NzA4NjA3NzAsImV4cCI6MTc3MDg3MTU3MH0.88QpBapDSZE9Z0uq-byd38WeGKg2XPJh0PkLiqpQDoSYsN3FhiWwqHpRGwFI8dyS",
    "tokenType": "Bearer",
    "expiresIn": 10800
  }
}
```

#### 保存Token到变量

```bash
# Linux/Mac - 使用 jq 解析 JSON
TOKEN=$(curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin&password=admin123" | jq -r '.data.accessToken')

echo "Token: $TOKEN"

# Windows PowerShell
$response = Invoke-RestMethod -Uri "http://localhost:7573/uaa/token" -Method Post -ContentType "application/x-www-form-urlencoded" -Body "grant_type=password&username=admin&password=admin123"
$TOKEN = $response.data.accessToken
Write-Host "Token: $TOKEN"
```

### 2. 浏览产品列表（需要USER角色）

```bash
curl -s -X GET "http://localhost:7573/api/products" \
  -H "Authorization: Bearer $TOKEN"
```

**实际输出**:
```json
{
  "code": 200,
  "message": "Success",
  "data": [
    {
      "id": 3,
      "name": "Test Product",
      "description": "This is a test product",
      "status": "ON_SHELF",
      "createdBy": null,
      "updatedBy": null,
      "deleted": false,
      "createdAt": null,
      "updatedAt": null,
      "deletedAt": null
    }
  ]
}
```

### 3. 添加产品（需要EDITOR角色）

```bash
curl -s -X POST "http://localhost:7573/api/products" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "description": "This is a test product",
    "status": "ON_SHELF"
  }'
```

**实际输出**:
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "id": null,
    "name": "Test Product",
    "description": "This is a test product",
    "status": "ON_SHELF",
    "createdBy": null,
    "updatedBy": null,
    "deleted": false,
    "createdAt": null,
    "updatedAt": null,
    "deletedAt": null
  }
}
```

### 4. 修改产品（需要EDITOR角色）

```bash
curl -s -X PUT "http://localhost:7573/api/products/3" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Test Product",
    "description": "Updated description",
    "status": "OFF_SHELF"
  }'
```

**实际输出**:
```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "id": 3,
    "name": "Updated Test Product",
    "description": "Updated description",
    "status": "OFF_SHELF",
    "createdBy": null,
    "updatedBy": null,
    "deleted": false,
    "createdAt": null,
    "updatedAt": null,
    "deletedAt": null
  }
}
```

### 5. 删除产品（需要EDITOR角色）

```bash
curl -s -X DELETE "http://localhost:7573/api/products/1" \
  -H "Authorization: Bearer $TOKEN"
```

**实际输出**:
```json
{
  "code": 200,
  "message": "Success",
  "data": null
}
```

### 权限测试

#### 测试场景：USER角色尝试添加产品（应该失败）

```bash
# 1. 使用USER角色账号登录
USER_TOKEN=$(curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=user_1&password=user_1" | jq -r '.data.accessToken')

# 2. 尝试添加产品（应该返回500 Access Denied）
curl -s -X POST "http://localhost:7573/api/products" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Unauthorized Product",
    "description": "Should fail",
    "status": "ON_SHELF"
  }'
```

**实际输出**: 
```json
{
  "code": 500,
  "message": "Internal server error: Access Denied",
  "error": "SYS_001"
}
```

#### 测试场景：LDAP用户权限验证

```bash
# 1. LDAP USER角色 - 可以查询，不能创建
LDAP_USER_TOKEN=$(curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=ldap_user_1&password=ldap_user_1&auth_type=ldap" | jq -r '.data.accessToken')

# 查询产品（成功）
curl -s -X GET "http://localhost:7573/api/products" \
  -H "Authorization: Bearer $LDAP_USER_TOKEN"

# 2. LDAP EDITOR角色 - 可以创建产品
LDAP_EDITOR_TOKEN=$(curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=ldap_editor_1&password=ldap_editor_1&auth_type=ldap" | jq -r '.data.accessToken')

# 创建产品（成功）
curl -s -X POST "http://localhost:7573/api/products" \
  -H "Authorization: Bearer $LDAP_EDITOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "LDAP Editor Product",
    "description": "Created by LDAP editor",
    "status": "ON_SHELF"
  }'

# 3. LDAP ADMIN角色 - 可以删除产品
LDAP_ADMIN_TOKEN=$(curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=ldap_adm_1&password=ldap_adm_1&auth_type=ldap" | jq -r '.data.accessToken')

# 删除产品（成功）
curl -s -X DELETE "http://localhost:7573/api/products/1" \
  -H "Authorization: Bearer $LDAP_ADMIN_TOKEN"
```

### 完整测试脚本

创建测试脚本 `test-api.sh`:

```bash
#!/bin/bash

BASE_URL="http://localhost:7573"

echo "=========================================="
echo "LZB Microservices API 测试"
echo "=========================================="

# 1. 登录获取Token
echo -e "\n[1] 登录获取Token..."
TOKEN=$(curl -s -X POST "$BASE_URL/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin&password=admin123&client_id=lzb-client&client_secret=lzb-secret&auth_type=DATABASE" \
  | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ 登录失败"
  exit 1
fi
echo "✅ 登录成功，Token: ${TOKEN:0:20}..."

# 2. 查询产品列表
echo -e "\n[2] 查询产品列表..."
curl -s -X GET "$BASE_URL/api/products" \
  -H "Authorization: Bearer $TOKEN"

# 3. 添加产品
echo -e "\n\n[3] 添加产品..."
PRODUCT_ID=$(curl -s -X POST "$BASE_URL/api/products" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"测试产品","description":"API测试创建","status":"ON_SHELF"}' \
  | grep -o '"id":[0-9]*' | cut -d':' -f2)

if [ -z "$PRODUCT_ID" ]; then
  echo "❌ 添加产品失败"
else
  echo "✅ 添加产品成功，ID: $PRODUCT_ID"
fi

# 4. 修改产品
echo -e "\n[4] 修改产品..."
curl -s -X PUT "$BASE_URL/api/products/$PRODUCT_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"测试产品(已修改)","description":"API测试修改","status":"ON_SHELF"}'

# 5. 删除产品
echo -e "\n\n[5] 删除产品..."
curl -s -X DELETE "$BASE_URL/api/products/$PRODUCT_ID" \
  -H "Authorization: Bearer $TOKEN"

# 6. 权限测试
echo -e "\n\n[6] 权限测试 - USER角色尝试添加产品..."
USER_TOKEN=$(curl -s -X POST "$BASE_URL/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=user_1&password=user_1&client_id=lzb-client&client_secret=lzb-secret&auth_type=DATABASE" \
  | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

curl -s -X POST "$BASE_URL/api/products" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"测试","description":"应该失败","status":"ON_SHELF"}'

echo -e "\n\n=========================================="
echo "测试完成"
echo "=========================================="
```

运行测试：

```bash
chmod +x test-api.sh
./test-api.sh
```

## 测试账号

### 数据库用户

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | admin123 | PRODUCT_ADMIN |
| user_1 | user_1 | USER |
| editor_1 | editor_1 | EDITOR |
| adm_1 | adm_1 | PRODUCT_ADMIN |

### LDAP用户

| 用户名 | 密码 | 角色 |
|--------|------|------|
| ldap_user_1 | ldap_user_1 | USER |
| ldap_editor_1 | ldap_editor_1 | EDITOR |
| ldap_adm_1 | ldap_adm_1 | PRODUCT_ADMIN |

## 项目结构

```
lzb-microservices/
├── pom.xml                    # 父POM
├── docker-compose.yml         # Docker编排文件
├── NACOS_DEPLOYMENT_GUIDE.md  # Nacos配置中心部署指南
├── init-db/
│   └── init.sql              # 数据库初始化脚本
├── init-ldap/
│   └── bootstrap.ldif        # LDAP初始化配置
├── scripts/                   # 部署和测试脚本
│   ├── build-and-deploy.sh   # 构建和部署脚本
│   ├── import-nacos-config.sh # Nacos配置导入脚本（完整配置）
│   ├── add-base-configs.sh   # 添加基础配置（已废弃，配置在项目中）
│   └── verify-deployment.sh  # 服务验证脚本
├── lzb-gateway/              # 网关服务
│   ├── src/
│   │   └── main/
│   │       ├── java/com/lzb/gateway/
│   │       │   ├── GatewayApplication.java
│   │       │   ├── config/
│   │       │   ├── filter/
│   │       │   └── exception/
│   │       └── resources/
│   │           ├── bootstrap.yml    # Nacos配置
│   │           └── application.yml
│   ├── Dockerfile
│   └── pom.xml
├── lzb-uaa/                  # 认证服务
│   ├── src/
│   │   └── main/
│   │       ├── java/com/lzb/uaa/
│   │       │   ├── UaaApplication.java
│   │       │   ├── domain/          # 领域层
│   │       │   ├── application/     # 应用层
│   │       │   ├── infrastructure/  # 基础设施层
│   │       │   └── interfaces/      # 接口层
│   │       └── resources/
│   │           ├── bootstrap.yml    # Nacos配置
│   │           ├── application.yml
│   │           ├── nacos-config.yml # Nacos配置文档
│   │           └── templates/
│   │               └── login.html
│   ├── Dockerfile
│   └── pom.xml
└── lzb-product/              # 产品服务
    ├── src/
    │   └── main/
    │       ├── java/com/lzb/product/
    │       │   ├── ProductApplication.java
    │       │   ├── domain/
    │       │   ├── application/
    │       │   ├── infrastructure/
    │       │   └── interfaces/
    │       └── resources/
    │           ├── bootstrap.yml    # Nacos配置
    │           └── application.yml
    ├── Dockerfile
    └── pom.xml
```

## 确认清单

- [x] JDK 17已安装
- [x] Maven 3.8+已安装
- [x] Docker和Docker Compose已安装
- [x] 项目可以成功构建（mvn clean install）
- [x] 所有服务可以通过docker-compose启动
- [x] 数据库自动初始化
- [x] LDAP服务正常运行
- [x] 可以通过CURL命令获取Token
- [x] 可以通过CURL命令调用Product API
- [x] 权限控制正常工作
- [x] 登录页面可以访问

## 故障排查

### 服务unhealthy状态

**症状**: 容器状态显示unhealthy

**解决方法**:

```bash
# 1. 检查Nacos配置是否已导入
# 访问 http://localhost:8848/nacos 确认配置存在

# 2. 导入Nacos配置
bash scripts/import-nacos-config.sh

# 3. 重启服务
docker-compose restart lzb-gateway lzb-uaa lzb-product

# 4. 查看服务日志
docker-compose logs -f lzb-gateway
docker-compose logs -f lzb-uaa
docker-compose logs -f lzb-product
```

详细故障排查指南请参考: [NACOS_DEPLOYMENT_GUIDE.md](NACOS_DEPLOYMENT_GUIDE.md)

### 服务启动失败

```bash
# 查看服务日志
docker-compose logs -f [service-name]

# 重启服务
docker-compose restart [service-name]
```

### Nacos注册失败

确保Nacos服务已完全启动（约30秒），然后重启应用服务：

```bash
docker-compose restart lzb-gateway lzb-uaa lzb-product
```

### 数据库连接失败

检查MySQL服务状态和初始化脚本：

```bash
docker-compose logs mysql
```

### GitHub OAuth不工作

**症状**: 点击 GitHub 登录按钮后返回 404 错误

**原因**: GitHub OAuth2 需要配置真实的 Client ID 和 Client Secret

**解决方法**:

1. **申请 GitHub OAuth App**（参考上面"步骤 4.3: GitHub OAuth 申请步骤"）

2. **在 Nacos 配置中心添加配置**:
   - Data ID: `lzb-uaa-docker.yml`
   - Group: `DEFAULT_GROUP`
   - 配置内容:
   ```yaml
   spring:
     security:
       oauth2:
         client:
           registration:
             github:
               client-id: your-real-github-client-id
               client-secret: your-real-github-client-secret
   ```

3. **重启 UAA 服务**: 
   ```bash
   docker-compose restart lzb-uaa
   ```

4. **验证**: 访问 `http://localhost:7573/uaa/login`，应该可以看到 GitHub 登录按钮

**注意**: 
- 如果**不配置** GitHub OAuth，登录页面**不会显示** GitHub 登录按钮
- 数据库和 LDAP 登录不受影响，仍然可以正常使用

## 停止服务

```bash
docker-compose down

# 删除数据卷（清除所有数据）
docker-compose down -v
```

## 许可证

MIT License

## 作者

刘志彬 (LZB)
# Test workflow

# API 测试文档

本文档提供了 LZB Microservices 项目的完整 API 测试示例。所有命令都可以直接复制使用。

## 目录

- [环境准备](#环境准备)
- [1. 认证 API](#1-认证-api)
  - [1.1 数据库登录](#11-数据库登录)
  - [1.2 LDAP登录](#12-ldap登录)
- [2. 产品 API](#2-产品-api)
  - [2.1 查询产品列表](#21-查询产品列表)
  - [2.2 创建产品](#22-创建产品)
  - [2.3 查询产品详情](#23-查询产品详情)
  - [2.4 更新产品](#24-更新产品)
  - [2.5 删除产品](#25-删除产品)
- [3. 权限测试](#3-权限测试)
- [4. 健康检查](#4-健康检查)

---

## 环境准备

### 基础配置

```bash
# 设置基础 URL
BASE_URL="http://localhost:7573"

# 如果在虚拟机中测试，需要绕过代理
# 在每个 curl 命令中添加 --noproxy "*" 参数
```

### 测试账号

#### 数据库用户

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | admin123 | PRODUCT_ADMIN |
| user_1 | user_1 | USER |
| editor_1 | editor_1 | EDITOR |
| adm_1 | adm_1 | PRODUCT_ADMIN |

#### LDAP用户

| 用户名 | 密码 | 角色 |
|--------|------|------|
| ldap_user_1 | ldap_user_1 | USER |
| ldap_editor_1 | ldap_editor_1 | EDITOR |
| ldap_adm_1 | ldap_adm_1 | PRODUCT_ADMIN |

---

## 1. 认证 API

### 1.1 数据库登录

#### 1.1.1 PRODUCT_ADMIN 角色登录

```bash
curl -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=admin" \
  -d "password=admin123" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=DATABASE"
```

**预期响应：**

```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
    "tokenType": "Bearer",
    "expiresIn": 10800
  }
}
```

#### 1.1.2 USER 角色登录

```bash
curl -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=user_1" \
  -d "password=user_1" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=DATABASE"
```

#### 1.1.3 EDITOR 角色登录

```bash
curl -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=editor_1" \
  -d "password=editor_1" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=DATABASE"
```

### 1.2 LDAP登录

#### 1.2.1 LDAP USER 角色登录

```bash
curl -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=ldap_user_1" \
  -d "password=ldap_user_1" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=LDAP"
```

#### 1.2.2 LDAP EDITOR 角色登录

```bash
curl -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=ldap_editor_1" \
  -d "password=ldap_editor_1" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=LDAP"
```

#### 1.2.3 LDAP PRODUCT_ADMIN 角色登录

```bash
curl -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=ldap_adm_1" \
  -d "password=ldap_adm_1" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=LDAP"
```

---

## 2. 产品 API

### 获取 Token（用于后续测试）

```bash
# 获取 ADMIN Token
TOKEN=$(curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin&password=admin123&client_id=lzb-client&client_secret=lzb-secret&auth_type=DATABASE" \
  | jq -r '.data.accessToken')

echo "Token: $TOKEN"
```

### 2.1 查询产品列表

**权限要求：** USER 及以上角色

```bash
curl -X GET "http://localhost:7573/api/products" \
  -H "Authorization: Bearer $TOKEN"
```

**预期响应：**

```json
{
  "code": 200,
  "message": "Success",
  "data": []
}
```

### 2.2 创建产品

**权限要求：** EDITOR 及以上角色

```bash
curl -X POST "http://localhost:7573/api/products" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试产品1",
    "description": "这是一个通过API创建的测试产品",
    "status": "ON_SHELF"
  }'
```

**预期响应：**

```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "id": 1,
    "name": "测试产品1",
    "description": "这是一个通过API创建的测试产品",
    "status": "ON_SHELF",
    "createdBy": 1,
    "createdAt": "2026-02-11T08:00:00",
    "updatedAt": "2026-02-11T08:00:00"
  }
}
```

### 2.3 查询产品详情

**权限要求：** USER 及以上角色

```bash
curl -X GET "http://localhost:7573/api/products/1" \
  -H "Authorization: Bearer $TOKEN"
```

**预期响应：**

```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "id": 1,
    "name": "测试产品1",
    "description": "这是一个通过API创建的测试产品",
    "status": "ON_SHELF",
    "createdBy": 1,
    "createdAt": "2026-02-11T08:00:00",
    "updatedAt": "2026-02-11T08:00:00"
  }
}
```

### 2.4 更新产品

**权限要求：** EDITOR 及以上角色

```bash
curl -X PUT "http://localhost:7573/api/products/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试产品1-已更新",
    "description": "产品描述已更新",
    "status": "OFF_SHELF"
  }'
```

**预期响应：**

```json
{
  "code": 200,
  "message": "Success",
  "data": {
    "id": 1,
    "name": "测试产品1-已更新",
    "description": "产品描述已更新",
    "status": "OFF_SHELF",
    "updatedBy": 1,
    "updatedAt": "2026-02-11T08:05:00"
  }
}
```

### 2.5 删除产品

**权限要求：** EDITOR 及以上角色

```bash
curl -X DELETE "http://localhost:7573/api/products/1" \
  -H "Authorization: Bearer $TOKEN"
```

**预期响应：**

```json
{
  "code": 200,
  "message": "Success",
  "data": null
}
```

**注意：** 删除是软删除，产品不会从数据库中物理删除，只是标记为已删除。

---

## 3. 权限测试

### 3.1 USER 角色尝试创建产品（应该失败）

```bash
# 1. 获取 USER 角色的 Token
USER_TOKEN=$(curl -s -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=user_1&password=user_1&client_id=lzb-client&client_secret=lzb-secret&auth_type=DATABASE" \
  | jq -r '.data.accessToken')

# 2. 尝试创建产品
curl -X POST "http://localhost:7573/api/products" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试产品2",
    "description": "USER角色不应该能创建产品",
    "status": "ON_SHELF"
  }' \
  -w "\nHTTP Status: %{http_code}\n"
```

**预期响应：** HTTP 403 Forbidden

### 3.2 USER 角色查询产品列表（应该成功）

```bash
curl -X GET "http://localhost:7573/api/products" \
  -H "Authorization: Bearer $USER_TOKEN"
```

**预期响应：** HTTP 200 OK

---

## 4. 健康检查

### 4.1 Gateway 健康检查

```bash
curl -X GET "http://localhost:7573/actuator/health"
```

**预期响应：**

```json
{
  "status": "UP"
}
```

### 4.2 Nacos 控制台

访问：http://localhost:8848/nacos

- 用户名：`nacos`
- 密码：`nacos`

---

## 完整测试流程

### 一键测试脚本

```bash
#!/bin/bash

BASE_URL="http://localhost:7573"

echo "=== 1. 获取 ADMIN Token ==="
ADMIN_TOKEN=$(curl -s -X POST "${BASE_URL}/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin&password=admin123&client_id=lzb-client&client_secret=lzb-secret&auth_type=DATABASE" \
  | jq -r '.data.accessToken')
echo "Token: ${ADMIN_TOKEN:0:50}..."

echo -e "\n=== 2. 查询产品列表（应该为空） ==="
curl -s -X GET "${BASE_URL}/api/products" \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'

echo -e "\n=== 3. 创建产品 ==="
curl -s -X POST "${BASE_URL}/api/products" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"测试产品1","description":"API测试产品","status":"ON_SHELF"}' | jq '.'

echo -e "\n=== 4. 再次查询产品列表（应该有1个产品） ==="
curl -s -X GET "${BASE_URL}/api/products" \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'

echo -e "\n=== 5. 查询产品详情 ==="
curl -s -X GET "${BASE_URL}/api/products/1" \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'

echo -e "\n=== 6. 更新产品 ==="
curl -s -X PUT "${BASE_URL}/api/products/1" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"测试产品1-已更新","description":"更新后的描述","status":"OFF_SHELF"}' | jq '.'

echo -e "\n=== 7. 删除产品 ==="
curl -s -X DELETE "${BASE_URL}/api/products/1" \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq '.'

echo -e "\n=== 8. 权限测试：USER角色尝试创建产品 ==="
USER_TOKEN=$(curl -s -X POST "${BASE_URL}/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=user_1&password=user_1&client_id=lzb-client&client_secret=lzb-secret&auth_type=DATABASE" \
  | jq -r '.data.accessToken')

curl -s -X POST "${BASE_URL}/api/products" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"测试产品2","description":"应该失败","status":"ON_SHELF"}' \
  -w "\nHTTP Status: %{http_code}\n"

echo -e "\n=== 测试完成 ==="
```

---

## 虚拟机测试注意事项

如果在虚拟机中测试，需要在每个 curl 命令中添加 `--noproxy "*"` 参数：

```bash
# 示例
curl --noproxy "*" -X POST "http://localhost:7573/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin&password=admin123&client_id=lzb-client&client_secret=lzb-secret&auth_type=DATABASE"
```

或者设置环境变量：

```bash
export no_proxy="localhost,127.0.0.1"
```

---

## 常见问题

### Q1: Token 验证失败

**原因：** Token 可能已过期（3小时有效期）

**解决：** 重新获取 Token

### Q2: 403 Forbidden

**原因：** 当前用户角色权限不足

**解决：** 使用具有相应权限的账号登录

### Q3: 502 Bad Gateway

**原因：** 后端服务未启动或 Nacos 服务发现失败

**解决：** 
1. 检查服务状态：`docker-compose ps`
2. 查看服务日志：`docker-compose logs [service-name]`
3. 重启服务：`docker-compose restart [service-name]`

### Q4: 连接超时

**原因：** 代理配置问题

**解决：** 使用 `--noproxy "*"` 参数或配置 `no_proxy` 环境变量

---

## 附录

### 角色权限对照表

| 操作 | USER | EDITOR | PRODUCT_ADMIN |
|------|------|--------|---------------|
| 查询产品列表 | ✅ | ✅ | ✅ |
| 查询产品详情 | ✅ | ✅ | ✅ |
| 创建产品 | ❌ | ✅ | ✅ |
| 更新产品 | ❌ | ✅ | ✅ |
| 删除产品 | ❌ | ✅ | ✅ |

### API 响应状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 401 | 未授权（Token无效或过期） |
| 403 | 禁止访问（权限不足） |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |
| 502 | 网关错误（后端服务不可用） |

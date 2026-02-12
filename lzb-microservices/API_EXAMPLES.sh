#!/bin/bash

# ============================================
# LZB Microservices API 测试示例
# ============================================
# 
# 使用说明：
# 1. 确保所有服务已启动：docker-compose ps
# 2. 如果在虚拟机中测试，使用 --noproxy "*" 参数
# 3. 替换 BASE_URL 为实际的服务地址
#
# ============================================

# 基础配置
BASE_URL="http://localhost:7573"
# 如果在虚拟机中测试，取消下面这行的注释
# PROXY_OPTS="--noproxy *"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 打印分隔线
print_separator() {
    echo -e "${YELLOW}============================================${NC}"
}

# 打印标题
print_title() {
    echo -e "${GREEN}$1${NC}"
}

# 打印错误
print_error() {
    echo -e "${RED}错误: $1${NC}"
}

# ============================================
# 1. 认证相关 API
# ============================================

print_separator
print_title "1. 数据库登录 - 获取Token (PRODUCT_ADMIN角色)"
print_separator

curl $PROXY_OPTS -X POST "${BASE_URL}/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=admin" \
  -d "password=admin123" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=DATABASE" \
  -s | jq '.'

echo ""
print_separator
print_title "2. 数据库登录 - USER角色"
print_separator

curl $PROXY_OPTS -X POST "${BASE_URL}/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=user_1" \
  -d "password=user_1" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=DATABASE" \
  -s | jq '.'

echo ""
print_separator
print_title "3. 数据库登录 - EDITOR角色"
print_separator

curl $PROXY_OPTS -X POST "${BASE_URL}/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=editor_1" \
  -d "password=editor_1" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=DATABASE" \
  -s | jq '.'

echo ""
print_separator
print_title "4. LDAP登录 - USER角色"
print_separator

curl $PROXY_OPTS -X POST "${BASE_URL}/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=ldap_user_1" \
  -d "password=ldap_user_1" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=LDAP" \
  -s | jq '.'

echo ""
print_separator
print_title "5. LDAP登录 - EDITOR角色"
print_separator

curl $PROXY_OPTS -X POST "${BASE_URL}/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=ldap_editor_1" \
  -d "password=ldap_editor_1" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=LDAP" \
  -s | jq '.'

echo ""
print_separator
print_title "6. LDAP登录 - PRODUCT_ADMIN角色"
print_separator

curl $PROXY_OPTS -X POST "${BASE_URL}/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=ldap_adm_1" \
  -d "password=ldap_adm_1" \
  -d "client_id=lzb-client" \
  -d "client_secret=lzb-secret" \
  -d "auth_type=LDAP" \
  -s | jq '.'

# ============================================
# 2. 产品相关 API (需要先获取Token)
# ============================================

echo ""
print_separator
print_title "获取ADMIN Token用于后续测试"
print_separator

# 获取ADMIN Token
ADMIN_TOKEN=$(curl $PROXY_OPTS -s -X POST "${BASE_URL}/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=admin&password=admin123&client_id=lzb-client&client_secret=lzb-secret&auth_type=DATABASE" \
  | jq -r '.data.accessToken')

if [ "$ADMIN_TOKEN" == "null" ] || [ -z "$ADMIN_TOKEN" ]; then
    print_error "获取Token失败，请检查服务是否正常运行"
    exit 1
fi

echo "Token: ${ADMIN_TOKEN:0:50}..."

echo ""
print_separator
print_title "7. 查询产品列表 (需要USER角色)"
print_separator

curl $PROXY_OPTS -X GET "${BASE_URL}/api/products" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -s | jq '.'

echo ""
print_separator
print_title "8. 创建产品 (需要EDITOR角色)"
print_separator

curl $PROXY_OPTS -X POST "${BASE_URL}/api/products" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试产品1",
    "description": "这是一个通过API创建的测试产品",
    "status": "ON_SHELF"
  }' \
  -s | jq '.'

echo ""
print_separator
print_title "9. 再次查询产品列表 (应该有1个产品)"
print_separator

curl $PROXY_OPTS -X GET "${BASE_URL}/api/products" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -s | jq '.'

echo ""
print_separator
print_title "10. 查询产品详情 (ID=1)"
print_separator

curl $PROXY_OPTS -X GET "${BASE_URL}/api/products/1" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -s | jq '.'

echo ""
print_separator
print_title "11. 更新产品 (需要EDITOR角色)"
print_separator

curl $PROXY_OPTS -X PUT "${BASE_URL}/api/products/1" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试产品1-已更新",
    "description": "产品描述已更新",
    "status": "OFF_SHELF"
  }' \
  -s | jq '.'

echo ""
print_separator
print_title "12. 删除产品 (需要EDITOR角色)"
print_separator

curl $PROXY_OPTS -X DELETE "${BASE_URL}/api/products/1" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -s | jq '.'

echo ""
print_separator
print_title "13. 再次查询产品列表 (应该为空，因为产品被软删除)"
print_separator

curl $PROXY_OPTS -X GET "${BASE_URL}/api/products" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -s | jq '.'

# ============================================
# 3. 权限测试
# ============================================

echo ""
print_separator
print_title "获取USER角色Token用于权限测试"
print_separator

# 获取USER Token
USER_TOKEN=$(curl $PROXY_OPTS -s -X POST "${BASE_URL}/uaa/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&username=user_1&password=user_1&client_id=lzb-client&client_secret=lzb-secret&auth_type=DATABASE" \
  | jq -r '.data.accessToken')

echo "USER Token: ${USER_TOKEN:0:50}..."

echo ""
print_separator
print_title "14. USER角色查询产品列表 (应该成功)"
print_separator

curl $PROXY_OPTS -X GET "${BASE_URL}/api/products" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -s | jq '.'

echo ""
print_separator
print_title "15. USER角色尝试创建产品 (应该失败 - 403 Forbidden)"
print_separator

curl $PROXY_OPTS -X POST "${BASE_URL}/api/products" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试产品2",
    "description": "USER角色不应该能创建产品",
    "status": "ON_SHELF"
  }' \
  -s -w "\nHTTP Status: %{http_code}\n" | head -20

# ============================================
# 4. 健康检查
# ============================================

echo ""
print_separator
print_title "16. Gateway健康检查"
print_separator

curl $PROXY_OPTS -s "${BASE_URL}/actuator/health" | jq '.'

echo ""
print_separator
print_title "测试完成！"
print_separator

echo ""
echo "测试账号信息："
echo "  数据库用户："
echo "    - admin/admin123 (PRODUCT_ADMIN)"
echo "    - user_1/user_1 (USER)"
echo "    - editor_1/editor_1 (EDITOR)"
echo "    - adm_1/adm_1 (PRODUCT_ADMIN)"
echo ""
echo "  LDAP用户："
echo "    - ldap_user_1/ldap_user_1 (USER)"
echo "    - ldap_editor_1/ldap_editor_1 (EDITOR)"
echo "    - ldap_adm_1/ldap_adm_1 (PRODUCT_ADMIN)"
echo ""

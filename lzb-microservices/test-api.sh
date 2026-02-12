#!/bin/bash

# API测试脚本
# 使用方法: ./test-api.sh [服务器地址]
# 示例: ./test-api.sh http://124.222.11.237:7573

BASE_URL=${1:-http://localhost:7573}

echo "=========================================="
echo "LZB 微服务 API 测试"
echo "服务器地址: $BASE_URL"
echo "=========================================="
echo ""

# 测试1: 数据库登录
echo "【测试1】数据库登录 (grant_type=password)"
echo "请求: POST $BASE_URL/uaa/token?grant_type=password&username=admin&password=admin123"
RESPONSE=$(curl -s -X POST "$BASE_URL/uaa/token?grant_type=password&username=admin&password=admin123")
echo "响应: $RESPONSE"
echo ""

# 提取token
TOKEN=$(echo $RESPONSE | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)
if [ -z "$TOKEN" ]; then
    echo "❌ 登录失败，无法获取token"
    exit 1
fi
echo "✅ 登录成功，Token: ${TOKEN:0:50}..."
echo ""

# 测试2: LDAP登录
echo "【测试2】LDAP登录 (grant_type=ldap)"
echo "请求: POST $BASE_URL/uaa/token?grant_type=ldap&username=ldap_editor_1&password=ldap_editor_1"
LDAP_RESPONSE=$(curl -s -X POST "$BASE_URL/uaa/token?grant_type=ldap&username=ldap_editor_1&password=ldap_editor_1")
echo "响应: $LDAP_RESPONSE"
echo ""

LDAP_TOKEN=$(echo $LDAP_RESPONSE | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)
if [ -z "$LDAP_TOKEN" ]; then
    echo "⚠️  LDAP登录失败（可能LDAP服务未启动）"
else
    echo "✅ LDAP登录成功"
fi
echo ""

# 测试3: 获取产品列表
echo "【测试3】获取产品列表 (需要USER角色)"
echo "请求: GET $BASE_URL/api/products"
PRODUCTS=$(curl -s -X GET "$BASE_URL/api/products" -H "Authorization: Bearer $TOKEN")
echo "响应: $PRODUCTS"
echo ""

# 测试4: 创建产品
echo "【测试4】创建产品 (需要EDITOR角色)"
echo "请求: POST $BASE_URL/api/products"
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/products" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试产品",
    "description": "这是一个测试产品",
    "status": "ON_SHELF"
  }')
echo "响应: $CREATE_RESPONSE"
echo ""

# 提取产品ID
PRODUCT_ID=$(echo $CREATE_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
if [ -z "$PRODUCT_ID" ]; then
    echo "⚠️  无法提取产品ID，使用默认ID=1"
    PRODUCT_ID=1
else
    echo "✅ 产品创建成功，ID: $PRODUCT_ID"
fi
echo ""

# 测试5: 更新产品
echo "【测试5】更新产品 (需要EDITOR角色)"
echo "请求: PUT $BASE_URL/api/products/$PRODUCT_ID"
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/products/$PRODUCT_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试产品（已更新）",
    "description": "这是一个更新后的测试产品",
    "status": "ON_SHELF"
  }')
echo "响应: $UPDATE_RESPONSE"
echo ""

# 测试6: 再次获取产品列表
echo "【测试6】再次获取产品列表"
echo "请求: GET $BASE_URL/api/products"
PRODUCTS_AFTER=$(curl -s -X GET "$BASE_URL/api/products" -H "Authorization: Bearer $TOKEN")
echo "响应: $PRODUCTS_AFTER"
echo ""

# 测试7: 删除产品
echo "【测试7】删除产品 (需要EDITOR角色)"
echo "请求: DELETE $BASE_URL/api/products/$PRODUCT_ID"
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/products/$PRODUCT_ID" \
  -H "Authorization: Bearer $TOKEN")
echo "响应: $DELETE_RESPONSE"
echo ""

# 测试8: 验证删除
echo "【测试8】验证产品已删除"
echo "请求: GET $BASE_URL/api/products"
PRODUCTS_FINAL=$(curl -s -X GET "$BASE_URL/api/products" -H "Authorization: Bearer $TOKEN")
echo "响应: $PRODUCTS_FINAL"
echo ""

echo "=========================================="
echo "测试完成！"
echo "=========================================="

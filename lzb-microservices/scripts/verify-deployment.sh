#!/bin/bash

# 服务健康检查和API测试脚本

set -e

echo "=========================================="
echo "LZB微服务健康检查和API测试"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_service() {
    local service_name=$1
    local health_url=$2
    local container_name=$3
    
    echo -n "检查 ${service_name}... "
    
    if [ -n "$container_name" ]; then
        # 容器内部检查
        if docker exec $container_name curl -sf $health_url > /dev/null 2>&1; then
            echo -e "${GREEN}✓ 健康${NC}"
            return 0
        else
            echo -e "${RED}✗ 不健康${NC}"
            return 1
        fi
    else
        # 外部检查
        if curl -sf $health_url > /dev/null 2>&1; then
            echo -e "${GREEN}✓ 健康${NC}"
            return 0
        else
            echo -e "${RED}✗ 不健康${NC}"
            return 1
        fi
    fi
}

# 步骤1: 检查基础设施
echo "步骤1: 检查基础设施服务"
echo "----------------------------------------"
check_service "MySQL" "http://localhost:3306" "" || echo "  提示: 检查 docker-compose logs mysql"
check_service "Redis" "http://localhost:6379" "" || echo "  提示: 检查 docker-compose logs redis"
check_service "Nacos" "http://localhost:8848/nacos/v1/console/health/readiness" "" || echo "  提示: 检查 docker-compose logs nacos"
check_service "OpenLDAP" "ldap://localhost:389" "" || echo "  提示: 检查 docker-compose logs openldap"
echo ""

# 步骤2: 检查应用服务
echo "步骤2: 检查应用服务"
echo "----------------------------------------"
check_service "Gateway" "http://localhost:7573/actuator/health" "" || echo "  提示: 检查 docker-compose logs lzb-gateway"
check_service "UAA" "http://localhost:9999/actuator/health" "lzb-uaa" || echo "  提示: 检查 docker-compose logs lzb-uaa"
check_service "Product" "http://localhost:8081/actuator/health" "lzb-product" || echo "  提示: 检查 docker-compose logs lzb-product"
echo ""

# 步骤3: 检查Nacos服务注册
echo "步骤3: 检查Nacos服务注册"
echo "----------------------------------------"
check_nacos_service() {
    local service_name=$1
    echo -n "检查 ${service_name} 注册状态... "
    
    local response=$(curl -s "http://localhost:8848/nacos/v1/ns/instance/list?serviceName=${service_name}")
    local count=$(echo $response | grep -o '"hosts":\[' | wc -l)
    
    if [ $count -gt 0 ]; then
        echo -e "${GREEN}✓ 已注册${NC}"
        return 0
    else
        echo -e "${RED}✗ 未注册${NC}"
        return 1
    fi
}

check_nacos_service "lzb-gateway" || echo "  提示: 服务可能未启动或注册失败"
check_nacos_service "lzb-uaa" || echo "  提示: 服务可能未启动或注册失败"
check_nacos_service "lzb-product" || echo "  提示: 服务可能未启动或注册失败"
echo ""

# 步骤4: 检查Nacos配置
echo "步骤4: 检查Nacos配置"
echo "----------------------------------------"
check_nacos_config() {
    local data_id=$1
    echo -n "检查配置 ${data_id}... "
    
    local response=$(curl -s "http://localhost:8848/nacos/v1/cs/configs?dataId=${data_id}&group=DEFAULT_GROUP")
    
    if [ -n "$response" ] && [ "$response" != "config data not exist" ]; then
        echo -e "${GREEN}✓ 已配置${NC}"
        return 0
    else
        echo -e "${RED}✗ 未配置${NC}"
        return 1
    fi
}

check_nacos_config "common-config.yml" || echo "  提示: 运行 bash scripts/import-nacos-config.sh"
check_nacos_config "lzb-gateway-docker.yml" || echo "  提示: 运行 bash scripts/import-nacos-config.sh"
check_nacos_config "lzb-uaa-docker.yml" || echo "  提示: 运行 bash scripts/import-nacos-config.sh"
check_nacos_config "lzb-product-docker.yml" || echo "  提示: 运行 bash scripts/import-nacos-config.sh"
echo ""

# 步骤5: 测试API接口
echo "步骤5: 测试API接口"
echo "----------------------------------------"

# API 1: 用户名密码登录
echo -n "测试 API 1 - 用户名密码登录... "
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:7573/uaa/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✓ 成功${NC}"
    TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    echo "  Token: ${TOKEN:0:50}..."
else
    echo -e "${RED}✗ 失败${NC}"
    echo "  响应: $LOGIN_RESPONSE"
    TOKEN=""
fi
echo ""

# API 2: LDAP登录
echo -n "测试 API 2 - LDAP登录... "
LDAP_RESPONSE=$(curl -s -X POST http://localhost:7573/uaa/ldap/login \
  -H "Content-Type: application/json" \
  -d '{"username":"zhangsan","password":"password123"}')

if echo "$LDAP_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✓ 成功${NC}"
else
    echo -e "${YELLOW}⚠ 失败${NC}"
    echo "  响应: $LDAP_RESPONSE"
    echo "  提示: 检查OpenLDAP配置和用户数据"
fi
echo ""

# API 3: GitHub OAuth登录
echo "测试 API 3 - GitHub OAuth登录"
echo "  提示: 这需要在浏览器中测试"
echo "  访问: http://localhost:7573/uaa/oauth2/authorization/github"
echo ""

# API 4: 获取产品列表
if [ -n "$TOKEN" ]; then
    echo -n "测试 API 4 - 获取产品列表... "
    PRODUCTS_RESPONSE=$(curl -s -X GET http://localhost:7573/api/products \
      -H "Authorization: Bearer $TOKEN")
    
    if echo "$PRODUCTS_RESPONSE" | grep -q -E '\[|\{'; then
        echo -e "${GREEN}✓ 成功${NC}"
        echo "  响应: ${PRODUCTS_RESPONSE:0:100}..."
    else
        echo -e "${RED}✗ 失败${NC}"
        echo "  响应: $PRODUCTS_RESPONSE"
    fi
    echo ""
    
    # API 5: 创建产品
    echo -n "测试 API 5 - 创建产品... "
    CREATE_RESPONSE=$(curl -s -X POST http://localhost:7573/api/products \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"name":"Test Product","price":99.99,"stock":100}')
    
    if echo "$CREATE_RESPONSE" | grep -q -E '"id"|"success"'; then
        echo -e "${GREEN}✓ 成功${NC}"
        echo "  响应: ${CREATE_RESPONSE:0:100}..."
    else
        echo -e "${YELLOW}⚠ 失败${NC}"
        echo "  响应: $CREATE_RESPONSE"
        echo "  提示: 需要ADMIN角色权限"
    fi
    echo ""
else
    echo -e "${YELLOW}⚠ 跳过 API 4 和 API 5 测试（需要有效token）${NC}"
    echo ""
fi

# 总结
echo "=========================================="
echo "健康检查和测试完成"
echo "=========================================="
echo ""
echo "详细信息:"
echo "  - Nacos控制台: http://localhost:8848/nacos (nacos/nacos)"
echo "  - API Gateway: http://localhost:7573"
echo "  - 查看日志: docker-compose logs -f [service-name]"
echo ""

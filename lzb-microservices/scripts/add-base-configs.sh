#!/bin/bash

# 添加基础配置到 Nacos
# Spring Boot 3.x 要求必须有 spring.config.import 对应的配置文件

NACOS_SERVER="http://localhost:8848"
NACOS_NAMESPACE=""
NACOS_GROUP="DEFAULT_GROUP"

echo "=========================================="
echo "添加基础配置到 Nacos"
echo "=========================================="

# 1. 添加 lzb-uaa.yml
echo ""
echo "[1] 添加 lzb-uaa.yml..."
curl -X POST "${NACOS_SERVER}/nacos/v1/cs/configs" \
  -d "dataId=lzb-uaa.yml" \
  -d "group=${NACOS_GROUP}" \
  -d "type=yaml" \
  --data-urlencode "content=# UAA 服务基础配置（所有环境共享）
# 环境特定配置在 lzb-uaa-docker.yml 中

server:
  port: 9999

management:
  endpoints:
    web:
      exposure:
        include: health,info"

echo ""

# 2. 添加 lzb-product.yml
echo "[2] 添加 lzb-product.yml..."
curl -X POST "${NACOS_SERVER}/nacos/v1/cs/configs" \
  -d "dataId=lzb-product.yml" \
  -d "group=${NACOS_GROUP}" \
  -d "type=yaml" \
  --data-urlencode "content=# Product 服务基础配置（所有环境共享）
# 环境特定配置在 lzb-product-docker.yml 中

server:
  port: 8081

management:
  endpoints:
    web:
      exposure:
        include: health,info"

echo ""

# 3. 添加 lzb-gateway.yml
echo "[3] 添加 lzb-gateway.yml..."
curl -X POST "${NACOS_SERVER}/nacos/v1/cs/configs" \
  -d "dataId=lzb-gateway.yml" \
  -d "group=${NACOS_GROUP}" \
  -d "type=yaml" \
  --data-urlencode "content=# Gateway 服务基础配置（所有环境共享）
# 环境特定配置在 lzb-gateway-docker.yml 中

server:
  port: 7573

management:
  endpoints:
    web:
      exposure:
        include: health,info,gateway"

echo ""
echo "=========================================="
echo "配置添加完成！"
echo "=========================================="
echo ""
echo "验证配置："
echo "curl -s \"http://localhost:8848/nacos/v1/cs/configs?dataId=lzb-uaa.yml&group=DEFAULT_GROUP\""
echo "curl -s \"http://localhost:8848/nacos/v1/cs/configs?dataId=lzb-product.yml&group=DEFAULT_GROUP\""
echo "curl -s \"http://localhost:8848/nacos/v1/cs/configs?dataId=lzb-gateway.yml&group=DEFAULT_GROUP\""
echo ""
echo "重启服务："
echo "docker-compose restart lzb-gateway lzb-uaa lzb-product"

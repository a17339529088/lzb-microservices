#!/bin/bash

echo "=========================================="
echo "LZB Microservices 诊断脚本"
echo "=========================================="

echo ""
echo "[1] 检查 Nacos 容器状态..."
docker ps | grep nacos

echo ""
echo "[2] 检查 Nacos 健康状态..."
curl -s http://localhost:8848/nacos/v1/console/health/readiness

echo ""
echo "[3] 检查 UAA 配置是否存在..."
curl -s "http://localhost:8848/nacos/v1/cs/configs?dataId=lzb-uaa-docker.yml&group=DEFAULT_GROUP" | head -20

echo ""
echo "[4] 检查 Product 配置是否存在..."
curl -s "http://localhost:8848/nacos/v1/cs/configs?dataId=lzb-product-docker.yml&group=DEFAULT_GROUP" | head -20

echo ""
echo "[5] 检查 Gateway 配置是否存在..."
curl -s "http://localhost:8848/nacos/v1/cs/configs?dataId=lzb-gateway-docker.yml&group=DEFAULT_GROUP" | head -20

echo ""
echo "[6] 检查所有容器状态..."
docker ps --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "[7] 查看 UAA 服务最近日志（Nacos 相关）..."
docker logs lzb-uaa 2>&1 | grep -i "nacos\|config" | tail -20

echo ""
echo "=========================================="
echo "诊断完成"
echo "=========================================="

#!/bin/bash

# 微服务构建和部署脚本
# 用于编译、打包和部署所有微服务

set -e

echo "=========================================="
echo "LZB微服务构建和部署脚本"
echo "=========================================="
echo ""

# 检查是否在项目根目录
if [ ! -f "pom.xml" ]; then
    echo "错误: 请在项目根目录运行此脚本"
    exit 1
fi

# 步骤1: 清理旧的构建
echo "步骤1: 清理旧的构建..."
mvn clean
echo "✓ 清理完成"
echo ""

# 步骤2: 编译和打包
echo "步骤2: 编译和打包所有服务..."
mvn package -DskipTests
echo "✓ 编译打包完成"
echo ""

# 步骤3: 检查Nacos配置
echo "步骤3: 检查Nacos配置中心..."
NACOS_URL="http://localhost:8848/nacos"
if curl -s -f "${NACOS_URL}/v1/console/health/readiness" > /dev/null 2>&1; then
    echo "✓ Nacos服务运行正常"
else
    echo "⚠ 警告: Nacos服务未运行或不可访问"
    echo "请确保Nacos已启动: docker-compose up -d nacos"
fi
echo ""

# 步骤4: 导入Nacos配置
echo "步骤4: 导入Nacos配置..."
if [ -f "scripts/import-nacos-config.sh" ]; then
    bash scripts/import-nacos-config.sh
    echo "✓ Nacos配置导入完成"
else
    echo "⚠ 警告: 未找到Nacos配置导入脚本"
    echo "请手动导入配置或运行: bash scripts/import-nacos-config.sh"
fi
echo ""

# 步骤5: 停止旧容器
echo "步骤5: 停止旧的服务容器..."
docker-compose stop lzb-gateway lzb-uaa lzb-product 2>/dev/null || true
docker-compose rm -f lzb-gateway lzb-uaa lzb-product 2>/dev/null || true
echo "✓ 旧容器已停止"
echo ""

# 步骤6: 构建Docker镜像
echo "步骤6: 构建Docker镜像..."
docker-compose build lzb-gateway lzb-uaa lzb-product
echo "✓ Docker镜像构建完成"
echo ""

# 步骤7: 启动服务
echo "步骤7: 启动所有服务..."
docker-compose up -d
echo "✓ 服务启动完成"
echo ""

# 步骤8: 等待服务健康检查
echo "步骤8: 等待服务健康检查..."
echo "这可能需要1-2分钟..."
sleep 30

# 检查服务状态
echo ""
echo "检查服务状态:"
docker-compose ps

echo ""
echo "=========================================="
echo "部署完成！"
echo "=========================================="
echo ""
echo "服务访问地址:"
echo "  - API Gateway: http://localhost:7573"
echo "  - Nacos控制台: http://localhost:8848/nacos (nacos/nacos)"
echo ""
echo "健康检查:"
echo "  - Gateway: curl http://localhost:7573/actuator/health"
echo "  - UAA: docker exec lzb-uaa curl -f http://localhost:9999/actuator/health"
echo "  - Product: docker exec lzb-product curl -f http://localhost:8081/actuator/health"
echo ""
echo "查看日志:"
echo "  - docker-compose logs -f lzb-gateway"
echo "  - docker-compose logs -f lzb-uaa"
echo "  - docker-compose logs -f lzb-product"
echo ""

#!/bin/bash

# Nacos配置导入脚本
# 用于将配置导入到Nacos配置中心

NACOS_SERVER="http://localhost:8848"
NACOS_NAMESPACE=""
NACOS_GROUP="DEFAULT_GROUP"

echo "开始导入Nacos配置..."

# 1. 导入公共配置 (common-config.yml)
echo "导入 common-config.yml..."
curl -X POST "${NACOS_SERVER}/nacos/v1/cs/configs" \
  -d "dataId=common-config.yml" \
  -d "group=${NACOS_GROUP}" \
  -d "type=yaml" \
  --data-urlencode "content=# JWT配置
jwt:
  secret: lzb-jwt-secret-key-2024
  expiration: 86400000  # 24小时

# 日志配置
logging:
  level:
    com.lzb: INFO
    org.springframework: INFO

# Actuator配置
management:
  endpoints:
    web:
      exposure:
        include: health,info"

echo ""

# 2. 导入UAA服务配置 (lzb-uaa-docker.yml)
echo "导入 lzb-uaa-docker.yml..."
curl -X POST "${NACOS_SERVER}/nacos/v1/cs/configs" \
  -d "dataId=lzb-uaa-docker.yml" \
  -d "group=${NACOS_GROUP}" \
  -d "type=yaml" \
  --data-urlencode "content=spring:
  datasource:
    url: jdbc:mysql://mysql:3306/lzb_microservices?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: root123
    driver-class-name: com.mysql.cj.jdbc.Driver
  data:
    redis:
      host: redis
      port: 6379
      database: 0
  security:
    oauth2:
      client:
        registration:
          github:
            client-id: \${GITHUB_CLIENT_ID}
            client-secret: \${GITHUB_CLIENT_SECRET}
            scope: read:user,user:email
        provider:
          github:
            authorization-uri: https://github.com/login/oauth/authorize
            token-uri: https://github.com/login/oauth/access_token
            user-info-uri: https://api.github.com/user
            user-name-attribute: login

server:
  port: 9999

mybatis-flex:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
  global-config:
    logic-delete-column: deleted
    logic-delete-value: 1
    logic-normal-value: 0"

echo ""

# 3. 导入Product服务配置 (lzb-product-docker.yml)
echo "导入 lzb-product-docker.yml..."
curl -X POST "${NACOS_SERVER}/nacos/v1/cs/configs" \
  -d "dataId=lzb-product-docker.yml" \
  -d "group=${NACOS_GROUP}" \
  -d "type=yaml" \
  --data-urlencode "content=spring:
  datasource:
    url: jdbc:mysql://mysql:3306/lzb_microservices?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: root123
    driver-class-name: com.mysql.cj.jdbc.Driver

server:
  port: 8081

mybatis-flex:
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
  global-config:
    logic-delete-column: deleted
    logic-delete-value: 1
    logic-normal-value: 0"

echo ""

# 4. 导入Gateway服务配置 (lzb-gateway-docker.yml)
echo "导入 lzb-gateway-docker.yml..."
curl -X POST "${NACOS_SERVER}/nacos/v1/cs/configs" \
  -d "dataId=lzb-gateway-docker.yml" \
  -d "group=${NACOS_GROUP}" \
  -d "type=yaml" \
  --data-urlencode "content=spring:
  cloud:
    gateway:
      routes:
        - id: uaa-service
          uri: lb://lzb-uaa
          predicates:
            - Path=/uaa/**
        - id: product-service
          uri: lb://lzb-product
          predicates:
            - Path=/api/products/**
  data:
    redis:
      host: redis
      port: 6379
      database: 0

server:
  port: 7573

jwt:
  secret: lzb-jwt-secret-key-2024"

echo ""
echo "配置导入完成！"
echo ""
echo "请访问 ${NACOS_SERVER}/nacos 查看配置"
echo "默认用户名/密码: nacos/nacos"

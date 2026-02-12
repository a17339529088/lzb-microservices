package com.lzb.gateway.config;

import org.springframework.context.annotation.Configuration;

/**
 * Security配置
 * 角色继承关系：PRODUCT_ADMIN > EDITOR > USER
 * 实际的权限验证在下游服务中进行
 */
@Configuration
public class SecurityConfig {
    // Gateway主要负责Token验证和传递用户信息
    // 具体的角色权限控制在各个微服务中实现
}

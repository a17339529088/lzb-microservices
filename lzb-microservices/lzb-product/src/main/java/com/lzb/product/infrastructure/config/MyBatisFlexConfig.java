package com.lzb.product.infrastructure.config;

import com.mybatisflex.core.FlexGlobalConfig;
import com.mybatisflex.spring.boot.ConfigurationCustomizer;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis-Flex 配置
 * 使用 Spring Boot 自动配置 + ConfigurationCustomizer 自定义
 */
@Configuration
@MapperScan("com.lzb.product.infrastructure.mapper")
public class MyBatisFlexConfig {

    /**
     * 自定义 MyBatis-Flex 配置
     * 通过 ConfigurationCustomizer 而不是手动创建 SqlSessionFactory
     */
    @Bean
    public ConfigurationCustomizer configurationCustomizer() {
        return configuration -> {
            // 下划线转驼峰（已在 application.yml 配置，这里显式设置确保生效）
            configuration.setMapUnderscoreToCamelCase(true);
            
            // 启用自增主键回填
            configuration.setUseGeneratedKeys(true);
            
            // 获取全局配置
            FlexGlobalConfig globalConfig = FlexGlobalConfig.getDefaultConfig();
        };
    }
}

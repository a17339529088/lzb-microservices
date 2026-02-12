package com.lzb.uaa.infrastructure.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.ldap.core.LdapTemplate;
import org.springframework.ldap.core.support.LdapContextSource;

@Configuration
public class LdapConfig {
    
    @Value("${ldap.url}")
    private String ldapUrl;
    
    @Value("${ldap.base}")
    private String ldapBase;
    
    @Value("${ldap.userDn}")
    private String ldapUserDn;
    
    @Value("${ldap.password}")
    private String ldapPassword;
    
    @Bean
    public LdapContextSource contextSource() {
        LdapContextSource contextSource = new LdapContextSource();
        contextSource.setUrl(ldapUrl);
        contextSource.setBase(ldapBase);
        contextSource.setUserDn(ldapUserDn);
        contextSource.setPassword(ldapPassword);
        contextSource.afterPropertiesSet(); // 必须调用以初始化连接
        return contextSource;
    }
    
    @Bean
    public LdapTemplate ldapTemplate() {
        return new LdapTemplate(contextSource());
    }
}

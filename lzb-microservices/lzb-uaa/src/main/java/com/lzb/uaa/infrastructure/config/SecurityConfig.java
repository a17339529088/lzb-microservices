package com.lzb.uaa.infrastructure.config;

import com.lzb.uaa.domain.service.AuthenticationService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {
    
    private final AuthenticationService authenticationService;
    
    @Value("${spring.security.oauth2.client.registration.github.client-id:your-github-client-id}")
    private String githubClientId;
    
    @Bean
    @SuppressWarnings("deprecation")
    public PasswordEncoder passwordEncoder() {
        return NoOpPasswordEncoder.getInstance();
    }
    
    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(authenticationService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }
    
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
    
    private boolean isGithubOAuth2Enabled() {
        return githubClientId != null 
            && !githubClientId.isEmpty() 
            && !"your-github-client-id".equals(githubClientId);
    }
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/uaa/token", "/uaa/login", "/actuator/**", 
                                       "/uaa/login/oauth2/**", "/uaa/oauth2/**",
                                       "/oauth2/**", "/login/oauth2/**").permitAll()
                        .anyRequest().authenticated()
                );
        
        if (isGithubOAuth2Enabled()) {
            http.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED));
            http.oauth2Login(oauth2 -> oauth2
                    .loginPage("/uaa/login")
                    .defaultSuccessUrl("/uaa/login?success=true", true)
            );
        } else {
            http.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
        }
        
        return http.build();
    }
}

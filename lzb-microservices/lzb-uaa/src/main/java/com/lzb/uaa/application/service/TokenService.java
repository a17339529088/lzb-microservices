package com.lzb.uaa.application.service;

import com.lzb.uaa.application.dto.TokenResponse;
import com.lzb.uaa.domain.entity.Role;
import com.lzb.uaa.domain.entity.User;
import com.lzb.uaa.domain.repository.UserRepository;
import com.lzb.uaa.domain.service.LdapAuthenticationService;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TokenService {
    
    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final RedisTemplate<String, String> redisTemplate;
    private final LdapAuthenticationService ldapAuthenticationService;
    
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    @Value("${jwt.expiration}")
    private long expirationSeconds;
    
    public TokenResponse generateToken(String username, String password) {
        return generateToken(username, password, "DATABASE");
    }
    
    public TokenResponse generateToken(String username, String password, String authType) {
        User user;
        List<String> roleNames;
        
        if ("LDAP".equalsIgnoreCase(authType)) {
            // LDAP authentication
            user = ldapAuthenticationService.authenticateAndGetUser(username, password);
            List<Role> roles = userRepository.findRolesByUserId(user.getId());
            roleNames = roles.stream()
                    .map(Role::getName)
                    .collect(Collectors.toList());
        } else {
            // Database authentication
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(username, password)
            );
            
            user = userRepository.findByUsernameAndSource(username, "DATABASE")
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            List<Role> roles = userRepository.findRolesByUserId(user.getId());
            roleNames = roles.stream()
                    .map(Role::getName)
                    .collect(Collectors.toList());
        }
        
        String jti = UUID.randomUUID().toString();
        Date now = new Date();
        long expirationMillis = expirationSeconds * 1000;
        Date expiryDate = new Date(now.getTime() + expirationMillis);
        
        SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
        
        String token = Jwts.builder()
                .setId(jti)
                .setSubject(username)
                .claim("user_id", user.getId())
                .claim("username", username)
                .claim("roles", roleNames)
                .claim("source", user.getSource())
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(key)
                .compact();
        
        // Store token in Redis
        String redisKey = "token:" + jti;
        redisTemplate.opsForValue().set(redisKey, token, expirationMillis, TimeUnit.MILLISECONDS);
        
        return TokenResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .expiresIn(expirationSeconds)
                .build();
    }
}

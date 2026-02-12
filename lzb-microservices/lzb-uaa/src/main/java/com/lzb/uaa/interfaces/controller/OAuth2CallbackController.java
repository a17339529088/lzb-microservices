package com.lzb.uaa.interfaces.controller;

import com.lzb.uaa.application.dto.TokenResponse;
import com.lzb.uaa.application.service.TokenService;
import com.lzb.uaa.domain.entity.Role;
import com.lzb.uaa.domain.entity.User;
import com.lzb.uaa.domain.repository.UserRepository;
import com.lzb.uaa.domain.service.GitHubAuthenticationService;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/login/oauth2")
@RequiredArgsConstructor
@ConditionalOnProperty(
    prefix = "spring.security.oauth2.client.registration.github",
    name = "client-id"
)
public class OAuth2CallbackController {
    private final GitHubAuthenticationService githubAuthenticationService;
    private final UserRepository userRepository;
    private final RedisTemplate<String, String> redisTemplate;
    private final OAuth2AuthorizedClientService authorizedClientService;
    
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    @Value("${jwt.expiration}")
    private long jwtExpiration;
    
    @GetMapping("/code/github")
    public ResponseEntity<Map<String, Object>> githubCallback(OAuth2AuthenticationToken authentication) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Get OAuth2 authorized client
            OAuth2AuthorizedClient client = authorizedClientService.loadAuthorizedClient(
                    authentication.getAuthorizedClientRegistrationId(),
                    authentication.getName()
            );
            
            // Get access token
            String accessToken = client.getAccessToken().getTokenValue();
            
            // Fetch user info from GitHub API
            RestTemplate restTemplate = new RestTemplate();
            String userInfoUrl = "https://api.github.com/user";
            
            org.springframework.http.HttpHeaders headers = new org.springframework.http.HttpHeaders();
            headers.setBearerAuth(accessToken);
            org.springframework.http.HttpEntity<String> entity = new org.springframework.http.HttpEntity<>(headers);
            
            ResponseEntity<Map> githubResponse = restTemplate.exchange(
                    userInfoUrl,
                    org.springframework.http.HttpMethod.GET,
                    entity,
                    Map.class
            );
            
            Map<String, Object> githubUserInfo = githubResponse.getBody();
            
            // Authenticate and get/create user
            User user = githubAuthenticationService.authenticateAndGetUser(githubUserInfo);
            
            // Get user roles (default EDITOR for GitHub users)
            List<Role> roles = userRepository.findRolesByUserId(user.getId());
            List<String> roleNames = roles.stream()
                    .map(Role::getName)
                    .collect(Collectors.toList());
            
            // If no roles, assign EDITOR
            if (roleNames.isEmpty()) {
                roleNames.add("EDITOR");
            }
            
            // Generate JWT token
            SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
            String jti = UUID.randomUUID().toString();
            Date now = new Date();
            Date expiryDate = new Date(now.getTime() + (jwtExpiration * 1000));
            
            String token = Jwts.builder()
                    .setId(jti)
                    .setSubject(user.getUsername())
                    .claim("user_id", user.getId())
                    .claim("username", user.getUsername())
                    .claim("roles", roleNames)
                    .claim("source", user.getSource())
                    .setIssuedAt(now)
                    .setExpiration(expiryDate)
                    .signWith(key)
                    .compact();
            
            // Store token in Redis
            String redisKey = "token:" + jti;
            redisTemplate.opsForValue().set(redisKey, token, jwtExpiration, TimeUnit.SECONDS);
            
            TokenResponse tokenResponse = TokenResponse.builder()
                    .accessToken(token)
                    .tokenType("Bearer")
                    .expiresIn(jwtExpiration)
                    .build();
            
            response.put("code", 200);
            response.put("message", "GitHub authentication successful");
            response.put("data", tokenResponse);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("code", 401);
            response.put("message", "GitHub authentication failed: " + e.getMessage());
            response.put("error", "AUTH_004");
            return ResponseEntity.ok(response);
        }
    }
}

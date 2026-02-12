package com.lzb.uaa.interfaces.controller;

import com.lzb.uaa.application.dto.TokenResponse;
import com.lzb.uaa.application.service.TokenService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/uaa")
@RequiredArgsConstructor
public class TokenController {
    private final TokenService tokenService;
    
    @PostMapping("/token")
    public ResponseEntity<Map<String, Object>> token(
            @RequestParam("grant_type") String grantType,
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            @RequestParam(value = "auth_type", required = false) String authType) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Determine auth type
            String finalAuthType;
            if (authType != null && !authType.isEmpty()) {
                // Use explicit auth_type parameter if provided
                finalAuthType = authType.toUpperCase();
            } else if ("ldap".equalsIgnoreCase(grantType)) {
                // Support grant_type=ldap for backward compatibility
                finalAuthType = "LDAP";
            } else {
                // Default to DATABASE for grant_type=password
                finalAuthType = "DATABASE";
            }
            
            // Generate token
            TokenResponse tokenResponse = tokenService.generateToken(username, password, finalAuthType);
            
            response.put("code", 200);
            response.put("message", "Success");
            response.put("data", tokenResponse);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("code", 401);
            response.put("message", "Authentication failed: " + e.getMessage());
            response.put("error", "AUTH_003");
            return ResponseEntity.ok(response);
        }
    }
}

package com.lzb.uaa.domain.service;

import com.lzb.uaa.domain.entity.User;
import com.lzb.uaa.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class GitHubAuthenticationService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    public User authenticateAndGetUser(Map<String, Object> githubUserInfo) {
        // Extract GitHub user information
        String githubId = String.valueOf(githubUserInfo.get("id"));
        String username = (String) githubUserInfo.get("login");
        String email = (String) githubUserInfo.get("email");
        
        // Check if user exists by GitHub ID
        User user = userRepository.findByUsernameAndSource(username, "GITHUB")
                .orElse(null);
        
        if (user == null) {
            // Create new user
            user = new User();
            user.setUsername(username);
            user.setPassword(passwordEncoder.encode(githubId)); // Use GitHub ID as password
            user.setEmail(email);
            user.setSource("GITHUB");
            user.setGithubId(githubId);
            user.setEnabled(true);
            user.setDeleted(false);
            user.setCreatedAt(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());
            
            // Save user with default EDITOR role
            user = userRepository.save(user);
            userRepository.assignRoleToUser(user.getId(), "EDITOR");
            log.info("Created new GitHub user: {} (GitHub ID: {}) with EDITOR role", username, githubId);
        } else {
            // Update GitHub ID if changed
            if (!githubId.equals(user.getGithubId())) {
                user.setGithubId(githubId);
                user.setUpdatedAt(LocalDateTime.now());
                userRepository.update(user);
                log.info("Updated GitHub user: {} (GitHub ID: {})", username, githubId);
            }
        }
        
        return user;
    }
}

package com.lzb.uaa.domain.service;

import com.lzb.uaa.domain.entity.User;
import com.lzb.uaa.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ldap.core.LdapTemplate;
import org.springframework.ldap.query.LdapQueryBuilder;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class LdapAuthenticationService {
    private final LdapTemplate ldapTemplate;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    public User authenticateAndGetUser(String username, String password) {
        try {
            // Authenticate against LDAP
            ldapTemplate.authenticate(
                    LdapQueryBuilder.query().base("ou=users").where("cn").is(username),
                    password
            );
            
            // Determine roles by checking group membership
            List<String> roles = determineRolesFromGroups(username);
            log.info("LDAP user {} has roles: {}", username, roles);
            
            // Check if user exists in database
            User user = userRepository.findByUsernameAndSource(username, "LDAP")
                    .orElse(null);
            
            if (user == null) {
                // Create new user
                user = new User();
                user.setUsername(username);
                user.setPassword(passwordEncoder.encode(password));
                user.setSource("LDAP");
                user.setEnabled(true);
                user.setDeleted(false);
                user.setCreatedAt(LocalDateTime.now());
                user.setUpdatedAt(LocalDateTime.now());
                
                // Save user with roles
                user = saveUserWithRoles(user, roles);
                log.info("Created new LDAP user: {} with roles: {}", username, roles);
            } else {
                // User exists, update roles (LDAP group membership may have changed)
                log.info("LDAP user {} already exists, updating roles", username);
                updateUserRoles(user, roles);
            }
            
            return user;
            
        } catch (Exception e) {
            log.error("LDAP authentication failed for user: {}", username, e);
            throw new BadCredentialsException("LDAP authentication failed", e);
        }
    }
    
    private List<String> determineRolesFromGroups(String username) {
        List<String> roles = new ArrayList<>();
        try {
            // 构造完整的用户 DN（包含 base DN）
            String userDn = "cn=" + username + ",ou=users,dc=lzb,dc=com";
            
            // Check if user is in admins group (使用相对 DN，相对于 base: dc=lzb,dc=com)
            if (isMemberOfGroup(userDn, "cn=admins,ou=groups")) {
                roles.add("PRODUCT_ADMIN");
            }
            // Check if user is in editors group
            if (isMemberOfGroup(userDn, "cn=editors,ou=groups")) {
                roles.add("EDITOR");
            }
            // Check if user is in users group
            if (isMemberOfGroup(userDn, "cn=users,ou=groups")) {
                roles.add("USER");
            }
            
            // Default role if no group found
            if (roles.isEmpty()) {
                log.warn("No roles found for user {}, assigning default USER role", username);
                roles.add("USER");
            }
        } catch (Exception e) {
            log.error("Failed to determine roles from LDAP groups for user {}, using default USER role", username, e);
            roles.add("USER");
        }
        return roles;
    }
    
    private boolean isMemberOfGroup(String userDn, String groupDn) {
        try {
            log.debug("Checking if {} is member of {}", userDn, groupDn);
            Object group = ldapTemplate.lookup(groupDn);
            log.debug("Group lookup result: {}", group);
            if (group instanceof javax.naming.directory.DirContext) {
                javax.naming.directory.Attributes attrs = ((javax.naming.directory.DirContext) group).getAttributes("");
                javax.naming.directory.Attribute members = attrs.get("member");
                log.debug("Members attribute: {}", members);
                if (members != null) {
                    for (int i = 0; i < members.size(); i++) {
                        String member = (String) members.get(i);
                        log.debug("Comparing member {} with userDn {}", member, userDn);
                        if (member.equalsIgnoreCase(userDn)) {
                            log.info("User {} is member of group {}", userDn, groupDn);
                            return true;
                        }
                    }
                }
            }
            log.debug("User {} is NOT member of group {}", userDn, groupDn);
        } catch (Exception e) {
            log.error("Error checking group membership for {} in {}", userDn, groupDn, e);
        }
        return false;
    }
    private User saveUserWithRoles(User user, List<String> roleNames) {
        // Save user first
        user = userRepository.save(user);
        
        // Assign roles to user
        for (String roleName : roleNames) {
            userRepository.assignRoleToUser(user.getId(), roleName);
        }
        
        log.info("Saved user {} with roles: {}", user.getUsername(), roleNames);
        return user;
    }
    
    private void updateUserRoles(User user, List<String> roleNames) {
        // Clear existing roles (简化实现：直接重新分配)
        // 注意：这里假设 assignRoleToUser 会处理重复分配的情况
        // 如果需要完全清除旧角色，需要添加 clearUserRoles 方法
        
        for (String roleName : roleNames) {
            try {
                userRepository.assignRoleToUser(user.getId(), roleName);
            } catch (Exception e) {
                log.debug("Role {} may already be assigned to user {}", roleName, user.getUsername());
            }
        }
        
        log.info("Updated roles for user {} to: {}", user.getUsername(), roleNames);
    }
}

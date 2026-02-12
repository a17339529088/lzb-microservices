package com.lzb.uaa.domain.repository;

import com.lzb.uaa.domain.entity.Role;
import com.lzb.uaa.domain.entity.User;

import java.util.List;
import java.util.Optional;

public interface UserRepository {
    Optional<User> findByUsernameAndSource(String username, String source);
    
    List<Role> findRolesByUserId(Long userId);
    
    Optional<User> findById(Long id);
    
    User save(User user);
    
    void update(User user);
    
    void assignRoleToUser(Long userId, String roleName);
}

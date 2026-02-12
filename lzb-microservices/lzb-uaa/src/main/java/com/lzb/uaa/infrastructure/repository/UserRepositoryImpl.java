package com.lzb.uaa.infrastructure.repository;

import com.lzb.uaa.domain.entity.Role;
import com.lzb.uaa.domain.entity.User;
import com.lzb.uaa.domain.repository.UserRepository;
import com.lzb.uaa.infrastructure.mapper.RoleMapper;
import com.lzb.uaa.infrastructure.mapper.UserMapper;
import com.lzb.uaa.infrastructure.mapper.UserRoleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class UserRepositoryImpl implements UserRepository {
    
    private final UserMapper userMapper;
    private final RoleMapper roleMapper;
    private final UserRoleMapper userRoleMapper;
    
    @Override
    public Optional<User> findByUsernameAndSource(String username, String source) {
        return userMapper.findByUsernameAndSource(username, source);
    }
    
    @Override
    public List<Role> findRolesByUserId(Long userId) {
        return userMapper.findRolesByUserId(userId);
    }
    
    @Override
    public Optional<User> findById(Long id) {
        return userMapper.findById(id);
    }
    
    @Override
    @Transactional
    public User save(User user) {
        userMapper.insert(user);
        return user;
    }
    
    @Override
    @Transactional
    public void update(User user) {
        userMapper.update(user);
    }
    
    @Override
    @Transactional
    public void assignRoleToUser(Long userId, String roleName) {
        Optional<Role> roleOpt = roleMapper.findByName(roleName);
        if (roleOpt.isPresent()) {
            userRoleMapper.insertUserRole(userId, roleOpt.get().getId());
        }
    }
}

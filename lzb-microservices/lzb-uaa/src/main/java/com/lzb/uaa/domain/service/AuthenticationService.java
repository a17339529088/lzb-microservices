package com.lzb.uaa.domain.service;

import com.lzb.uaa.domain.entity.Role;
import com.lzb.uaa.domain.entity.User;
import com.lzb.uaa.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AuthenticationService implements UserDetailsService {
    
    private final UserRepository userRepository;
    
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsernameAndSource(username, "DATABASE")
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));
        
        if (!user.getEnabled() || user.getDeleted()) {
            throw new UsernameNotFoundException("User is disabled or deleted: " + username);
        }
        
        List<Role> roles = userRepository.findRolesByUserId(user.getId());
        Collection<? extends GrantedAuthority> authorities = roles.stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.getName()))
                .collect(Collectors.toList());
        
        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getUsername())
                .password(user.getPassword())
                .authorities(authorities)
                .build();
    }
}

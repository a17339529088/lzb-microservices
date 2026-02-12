package com.lzb.uaa.infrastructure.mapper;

import com.lzb.uaa.domain.entity.Role;
import com.lzb.uaa.domain.entity.User;
import com.mybatisflex.core.BaseMapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Optional;

public interface UserMapper extends BaseMapper<User> {
    
    @Select("SELECT * FROM users WHERE username = #{username} AND source = #{source} AND deleted = false")
    Optional<User> findByUsernameAndSource(@Param("username") String username, @Param("source") String source);
    
    @Select("SELECT r.* FROM roles r " +
            "INNER JOIN user_roles ur ON r.id = ur.role_id " +
            "WHERE ur.user_id = #{userId}")
    List<Role> findRolesByUserId(@Param("userId") Long userId);
    
    @Select("SELECT * FROM users WHERE id = #{id} AND deleted = false")
    Optional<User> findById(@Param("id") Long id);
}

package com.lzb.uaa.infrastructure.mapper;

import com.lzb.uaa.domain.entity.UserRole;
import com.mybatisflex.core.BaseMapper;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;

public interface UserRoleMapper extends BaseMapper<UserRole> {
    
    @Insert("INSERT INTO user_roles (user_id, role_id, created_at) VALUES (#{userId}, #{roleId}, NOW())")
    void insertUserRole(@Param("userId") Long userId, @Param("roleId") Long roleId);
}

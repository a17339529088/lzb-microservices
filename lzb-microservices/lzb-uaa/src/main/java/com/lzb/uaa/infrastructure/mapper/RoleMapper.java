package com.lzb.uaa.infrastructure.mapper;

import com.lzb.uaa.domain.entity.Role;
import com.mybatisflex.core.BaseMapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Optional;

public interface RoleMapper extends BaseMapper<Role> {
    
    @Select("SELECT * FROM roles WHERE name = #{name}")
    Optional<Role> findByName(@Param("name") String name);
}

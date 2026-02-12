package com.lzb.uaa.domain.entity;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Table("user_roles")
public class UserRole {
    @Id(keyType = KeyType.Auto)
    private Long id;
    
    private Long userId;
    private Long roleId;
    private LocalDateTime createdAt;
}

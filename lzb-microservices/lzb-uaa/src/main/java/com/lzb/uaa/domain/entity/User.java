package com.lzb.uaa.domain.entity;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Table("users")
public class User {
    @Id(keyType = KeyType.Auto)
    private Long id;
    
    private String username;
    private String password;
    private String email;
    private String source;
    private String githubId;
    private Boolean enabled;
    private Boolean deleted;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime deletedAt;
}

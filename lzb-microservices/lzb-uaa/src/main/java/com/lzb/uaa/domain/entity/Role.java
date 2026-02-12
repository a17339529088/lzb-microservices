package com.lzb.uaa.domain.entity;

import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;
import lombok.Data;

@Data
@Table("roles")
public class Role {
    @Id(keyType = KeyType.Auto)
    private Long id;
    
    private String name;
    private String description;
}

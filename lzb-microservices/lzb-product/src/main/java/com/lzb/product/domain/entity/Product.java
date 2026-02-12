package com.lzb.product.domain.entity;

import com.mybatisflex.annotation.Column;
import com.mybatisflex.annotation.Id;
import com.mybatisflex.annotation.KeyType;
import com.mybatisflex.annotation.Table;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Table("products")
public class Product {
    @Id(keyType = KeyType.Auto)
    private Long id;
    
    private String name;
    
    private String description;
    
    private String status; // ON_SHELF, OFF_SHELF
    
    @Column("created_by")
    private Long createdBy;
    
    @Column("updated_by")
    private Long updatedBy;
    
    @Column(isLogicDelete = true)
    private Boolean deleted;
    
    @Column("created_at")
    private LocalDateTime createdAt;
    
    @Column("updated_at")
    private LocalDateTime updatedAt;
    
    @Column("deleted_at")
    private LocalDateTime deletedAt;
}

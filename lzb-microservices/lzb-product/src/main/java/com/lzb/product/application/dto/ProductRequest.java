package com.lzb.product.application.dto;

import lombok.Data;

@Data
public class ProductRequest {
    private String name;
    private String description;
    private String status;
}

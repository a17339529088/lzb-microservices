package com.lzb.product.domain.repository;

import com.lzb.product.domain.entity.Product;

import java.util.List;
import java.util.Optional;

public interface ProductRepository {
    List<Product> findAll();
    
    Optional<Product> findById(Long id);
    
    Product save(Product product);
    
    void deleteById(Long id);
}

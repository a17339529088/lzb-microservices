package com.lzb.product.infrastructure.repository;

import com.lzb.product.domain.entity.Product;
import com.lzb.product.domain.repository.ProductRepository;
import com.lzb.product.infrastructure.mapper.ProductMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ProductRepositoryImpl implements ProductRepository {
    private final ProductMapper productMapper;
    
    @Override
    public List<Product> findAll() {
        return productMapper.selectAll();
    }
    
    @Override
    public Optional<Product> findById(Long id) {
        return Optional.ofNullable(productMapper.selectOneById(id));
    }
    
    @Override
    public Product save(Product product) {
        if (product.getId() == null) {
            productMapper.insert(product);
        } else {
            productMapper.update(product);
        }
        return product;
    }
    
    @Override
    public void deleteById(Long id) {
        productMapper.deleteById(id);
    }
}

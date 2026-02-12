package com.lzb.product.interfaces.controller;

import com.lzb.product.application.dto.ProductRequest;
import com.lzb.product.domain.entity.Product;
import com.lzb.product.domain.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {
    private final ProductService productService;
    
    @GetMapping
    @PreAuthorize("hasRole('USER')")
    public ResponseEntity<Map<String, Object>> getAllProducts() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Product> products = productService.getAllProducts();
            response.put("code", 200);
            response.put("message", "Success");
            response.put("data", products);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("code", 500);
            response.put("message", "Internal server error");
            response.put("error", "SYS_001");
            return ResponseEntity.ok(response);
        }
    }
    
    @PostMapping
    @PreAuthorize("hasRole('EDITOR')")
    public ResponseEntity<Map<String, Object>> createProduct(@RequestBody ProductRequest request) {
        Map<String, Object> response = new HashMap<>();
        try {
            Product product = new Product();
            product.setName(request.getName());
            product.setDescription(request.getDescription());
            product.setStatus(request.getStatus());
            
            Product created = productService.createProduct(product);
            response.put("code", 200);
            response.put("message", "Success");
            response.put("data", created);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("code", 500);
            response.put("message", "Failed to create product");
            response.put("error", "PROD_002");
            return ResponseEntity.ok(response);
        }
    }
    
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('EDITOR')")
    public ResponseEntity<Map<String, Object>> updateProduct(
            @PathVariable Long id,
            @RequestBody ProductRequest request) {
        Map<String, Object> response = new HashMap<>();
        try {
            Product product = new Product();
            product.setName(request.getName());
            product.setDescription(request.getDescription());
            product.setStatus(request.getStatus());
            
            Product updated = productService.updateProduct(id, product);
            response.put("code", 200);
            response.put("message", "Success");
            response.put("data", updated);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("code", 404);
            response.put("message", "Product not found");
            response.put("error", "PROD_001");
            return ResponseEntity.ok(response);
        }
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('EDITOR')")
    public ResponseEntity<Map<String, Object>> deleteProduct(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        try {
            productService.deleteProduct(id);
            response.put("code", 200);
            response.put("message", "Success");
            response.put("data", null);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("code", 404);
            response.put("message", "Product not found");
            response.put("error", "PROD_001");
            return ResponseEntity.ok(response);
        }
    }
}

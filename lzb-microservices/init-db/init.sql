-- ============================================
-- 1. 创建 Nacos 数据库
-- ============================================
CREATE DATABASE IF NOT EXISTS nacos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================
-- 2. 创建业务数据库
-- ============================================
CREATE DATABASE IF NOT EXISTS lzb_microservices CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE lzb_microservices;

-- 创建角色表
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL COMMENT '角色名称',
    description VARCHAR(200) COMMENT '角色描述'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    password VARCHAR(100) COMMENT '密码(明文存储-仅用于演示)',
    email VARCHAR(100) COMMENT '邮箱',
    source VARCHAR(20) NOT NULL COMMENT '用户来源: DATABASE/LDAP/GITHUB',
    github_id VARCHAR(50) COMMENT 'GitHub用户ID',
    enabled BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    deleted BOOLEAN DEFAULT FALSE COMMENT '软删除标记',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at TIMESTAMP NULL COMMENT '删除时间',
    UNIQUE KEY uk_username_source (username, source, deleted),
    UNIQUE KEY uk_github_id (github_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 创建用户角色关联表
CREATE TABLE IF NOT EXISTS user_roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_user_role (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- 创建产品表
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '产品名称',
    description TEXT COMMENT '产品描述',
    status VARCHAR(20) NOT NULL DEFAULT 'ON_SHELF' COMMENT '产品状态: ON_SHELF/OFF_SHELF',
    created_by BIGINT COMMENT '创建人ID',
    updated_by BIGINT COMMENT '修改人ID',
    deleted BOOLEAN DEFAULT FALSE COMMENT '软删除标记',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted_at TIMESTAMP NULL COMMENT '删除时间',
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品表';

-- 插入角色数据
INSERT INTO roles (name, description) VALUES 
('USER', '普通用户'),
('EDITOR', '编辑者'),
('PRODUCT_ADMIN', '产品管理员');

-- 插入用户数据 (密码明文存储-仅用于演示环境)
-- 警告：生产环境必须使用BCrypt等加密算法
INSERT INTO users (username, password, source, enabled) VALUES
('admin', 'admin123', 'DATABASE', TRUE),
('user_1', 'user_1', 'DATABASE', TRUE),
('editor_1', 'editor_1', 'DATABASE', TRUE),
('adm_1', 'adm_1', 'DATABASE', TRUE);

-- 插入用户角色关联数据
INSERT INTO user_roles (user_id, role_id, created_at) VALUES
(1, 3, NOW()),  -- admin -> PRODUCT_ADMIN
(2, 1, NOW()),  -- user_1 -> USER
(3, 2, NOW()),  -- editor_1 -> EDITOR
(4, 3, NOW());  -- adm_1 -> PRODUCT_ADMIN

-- 产品表初始为空（按题目要求）

-- ============================================
-- 3. Nacos 数据库初始化说明
-- ============================================
-- Nacos数据库表结构由nacos-schema.sql文件初始化
-- Docker会自动执行/docker-entrypoint-initdb.d/目录下的所有.sql文件
-- 执行顺序：按文件名字母顺序
-- 本文件(init.sql)会先执行，创建nacos数据库
-- nacos-schema.sql会后执行，创建nacos的表结构

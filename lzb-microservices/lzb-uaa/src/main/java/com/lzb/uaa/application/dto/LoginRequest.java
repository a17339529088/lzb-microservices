package com.lzb.uaa.application.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String grantType;
    private String username;
    private String password;
    private String clientId;
    private String clientSecret;
}

package com.lzb.uaa.interfaces.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/uaa")
@RefreshScope
public class LoginController {
    
    @Value("${spring.security.oauth2.client.registration.github.client-id:your-github-client-id}")
    private String githubClientId;
    
    @GetMapping("/login")
    public String login(Model model) {
        boolean githubEnabled = githubClientId != null 
            && !githubClientId.isEmpty() 
            && !"your-github-client-id".equals(githubClientId);
        model.addAttribute("githubEnabled", githubEnabled);
        return "login";
    }
}

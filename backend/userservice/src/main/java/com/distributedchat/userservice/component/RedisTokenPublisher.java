package com.distributedchat.userservice.component;

import java.util.HashMap;
import java.util.Map;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import com.distributedchat.userservice.service.JWTService;

import io.jsonwebtoken.Claims;

@Component
public class RedisTokenPublisher {
	
	private RedisTemplate<String, Object> redisTemplate;
	private JWTService jwtService;
	
	public RedisTokenPublisher(
			RedisTemplate<String, Object> redisTemplate,
			JWTService jwtService) {
		// TODO Auto-generated constructor stub
		this.redisTemplate= redisTemplate;
		this.jwtService= jwtService;
	}
	
	public void publishBlackListedTokens(String token) {
		Claims claims= jwtService.extractClaims(token);
		
		Map<String, Object> map= new HashMap<>();
		map.put(claims.getId(), claims.getExpiration());
		
		redisTemplate.convertAndSend("user:blackListedTokens", map);
	}
}

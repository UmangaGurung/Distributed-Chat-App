package com.distributedchat.userservice.component;

import java.util.Date;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Component;

import com.distributedchat.userservice.service.JWTService;

import io.jsonwebtoken.Claims;

@Component
public class RedisTokenBlackList {
	
	private RedisTemplate<String, Object> template;
	private JWTService jwtService;
	
	private ValueOperations<String, Object> valueOperations;
	
	public RedisTokenBlackList(
			RedisTemplate<String, Object> template, 
			JWTService jwtService) {
		this.template= template;
		this.jwtService= jwtService;
		this.valueOperations= template.opsForValue();
	}
	
	public void blackListToken(String token) {
		Claims claims= jwtService.extractClaims(token);
		
		String tokenId= claims.getId();
		Date expire= claims.getExpiration();
		
		String key= "userservice:blacklist:"+tokenId; 
		
		valueOperations.set(key, expire);
		template.expireAt(key, expire);
	}
	
	public boolean isTokenBlackListed(String token) {
		Claims claims= jwtService.extractClaims(token);
		String tokenId= claims.getId();
		
		String key= "userservice:blacklist:"+tokenId; 
		
		return template.hasKey(key);
	}
}

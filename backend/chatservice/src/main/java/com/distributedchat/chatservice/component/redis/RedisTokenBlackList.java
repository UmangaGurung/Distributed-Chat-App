package com.distributedchat.chatservice.component.redis;

import java.util.Date;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Component;

@Component
public class RedisTokenBlackList {
	
	private RedisTemplate<String, Object> redisTemplate;
	private ValueOperations<String, Object> operations;
	
	public RedisTokenBlackList(RedisTemplate<String, Object> redisTemplate) {
		// TODO Auto-generated constructor stub
		this.redisTemplate= redisTemplate;
		this.operations= redisTemplate.opsForValue();
	}
	
	public void blackListToken(String tokenId, Date expire) {
		System.out.println("MESSAGE SEVICE"+tokenId+"...."+expire);
		String key= "chatservice:blacklist:"+tokenId; 
		
		operations.set(key, expire);
		redisTemplate.expireAt(key, expire);
	}
	
	public boolean isTokenBlackListed(String tokenId) {
		System.out.println("MessageSEVICE BLACKLIST");
		String key= "chatservice:blacklist:"+tokenId; 
		
		return redisTemplate.hasKey(key);
	}
}

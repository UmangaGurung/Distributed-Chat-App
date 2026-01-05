package com.distributedchat.userservice.service;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Component;

@Component
public class RedisService{

	private final RedisTemplate<String, String> redistemplate;
	
	public RedisService(RedisTemplate<String, String> redistemplate) {
		this.redistemplate= redistemplate;
	}
	
	public void saveState(String state, String appid) {
		ValueOperations<String, String> ops= redistemplate.opsForValue();
		ops.set(state, appid, 300, java.util.concurrent.TimeUnit.SECONDS);
	}
	
	public boolean isValid(String state, String appid) {
		if (redistemplate.hasKey(state)) {
			if (redistemplate.opsForValue().get(state).equals(appid)) {
				redistemplate.delete(state);
				return true;
			}
			return false;
		}
		return false;
	}
}

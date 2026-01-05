package com.distributedchat.chatservice.component.redis;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

@Component
public class RedisEventPublisher {
	
	private RedisTemplate<String, String> redisTemplate;

	public RedisEventPublisher(
			@Qualifier("simpleRedisTemplate") RedisTemplate<String, String> redisTemplate) {
		// TODO Auto-generated constructor stub
		this.redisTemplate= redisTemplate;
	}
	
	public void publishTypingEvent(String userId, String scriptResult, String conversationId) {
		String payload= conversationId+":"+userId+":"+scriptResult;
		
		redisTemplate.convertAndSend("chat:typing", payload);
	}
}

package com.distributedchat.chatservice.component.redis;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

@Component
public class RedisEventPublisher {
	
	private RedisTemplate<String, String> redisTemplate;
	private static final String seperator= "\u2021";

	public RedisEventPublisher(
			@Qualifier("simpleRedisTemplate") RedisTemplate<String, String> redisTemplate) {
		// TODO Auto-generated constructor stub
		this.redisTemplate= redisTemplate;
	}
	
	public void publishTypingEvent(String userId, String scriptResult, String conversationId, String userImage) {
		String payload= conversationId+seperator+userId+seperator+userImage+seperator+scriptResult;
		
		redisTemplate.convertAndSend("chat:typing", payload);
	}
}

package com.distributedchat.chatservice.component.redis;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import com.distributedchat.chatservice.model.dto.Message.MessageRedisPayloadDTO;

@Component
public class RedisMessagePublisher {
	
	RedisTemplate<String, Object> redisTemplate;
	
	public RedisMessagePublisher(RedisTemplate<String, Object> redisTemplate) {
		// TODO Auto-generated constructor stub
		this.redisTemplate= redisTemplate;
	}
	
	public void publishMessage(MessageRedisPayloadDTO payloadDTO) {	
		System.out.println("Messagepayload to publish=======");
		
		redisTemplate.convertAndSend("chat:messages", payloadDTO);
		
	}
}

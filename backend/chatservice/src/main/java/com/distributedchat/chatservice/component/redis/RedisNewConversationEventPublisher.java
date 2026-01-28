package com.distributedchat.chatservice.component.redis;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import com.distributedchat.chatservice.model.dto.Conversation.ConversationDetailsListDTO;

@Component
public class RedisNewConversationEventPublisher {
	
	RedisTemplate<String, Object> redisTemplate;
	
	public RedisNewConversationEventPublisher(RedisTemplate<String, Object> redisTemplate) {
		// TODO Auto-generated constructor stub
		this.redisTemplate= redisTemplate;
	}
	
	public void publishNewConversation(ConversationDetailsListDTO conversationDetailsListDTO) {
		System.out.println("Sending new conversation Event");
		
		redisTemplate.convertAndSend("chat:conversation", conversationDetailsListDTO);
	}
}

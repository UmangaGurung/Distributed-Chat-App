package com.distributedchat.chatservice.service;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.distributedchat.chatservice.component.JWTService;
import com.distributedchat.chatservice.component.MessageEncryption;
import com.distributedchat.chatservice.component.redis.RedisCaching;
import com.distributedchat.chatservice.component.redis.RedisEventPublisher;
import com.distributedchat.chatservice.component.redis.RedisLua;
import com.distributedchat.chatservice.component.redis.RedisMessagePublisher;
import com.distributedchat.chatservice.model.dto.Message.MessageDTO;
import com.distributedchat.chatservice.model.dto.Message.MessageRedisPayloadDTO;
import com.distributedchat.chatservice.model.dto.Message.TypingEventDTO;
import com.distributedchat.chatservice.repository.MessageDAO;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class MessageServiceImpl implements MessageService{
	
	MessageDAO messageDAO;
	JWTService jwtService;
	RedisMessagePublisher messagePublisher;
	MessageEncryption messageEncryption;
	
	RedisCaching redisCaching;
	RedisLua redisLua;
	RedisEventPublisher redisEventPublisher;
	
	public MessageServiceImpl(
			MessageDAO messageDAO, 
			JWTService jwtService, 
			RedisMessagePublisher messagePublisher,
			MessageEncryption messageEncryption,
			RedisCaching redisCaching,
			RedisLua redisLua,
			RedisEventPublisher redisEventPublisher) {
		// TODO Auto-generated constructor stub
		this.messageDAO= messageDAO;
		this.jwtService= jwtService;
		this.messagePublisher= messagePublisher;
		this.messageEncryption= messageEncryption;
		this.redisCaching= redisCaching;
		this.redisLua= redisLua;
		this.redisEventPublisher= redisEventPublisher;
	}
	
	@Override
	public void saveMessage(MessageDTO messageDTO, String userId) {
		// TODO Auto-generated method stub
		try {
			UUID uid= UUID.fromString(userId);
			String plainMessage= messageDTO.getMessage();
		
			String cipheredMessage= messageEncryption.encryptMessage(plainMessage);
			if (cipheredMessage.isEmpty() || cipheredMessage==null) {
				throw new IllegalArgumentException();
			}
			messageDTO.setMessage(cipheredMessage);
		
			MessageRedisPayloadDTO payloadDTO= messageDAO.saveMessage(messageDTO, uid);
			
			messagePublisher.onMessageSuccess(payloadDTO, userId);
			messagePublisher.publishMessage(payloadDTO);
		} catch (Exception e) {
			e.printStackTrace();
			throw e;  // Re-throw so behavior doesn't change
		}
	}

	@Override
	public void typingEvent(TypingEventDTO eventDTO, String userId) {
		// TODO Auto-generated method stub
		String conversationId= eventDTO.getConversationId();
		String event= eventDTO.getEvent();
		
		String scriptResult= redisLua.onTyped(conversationId, event, userId);
		
		redisEventPublisher.publishTypingEvent(userId, scriptResult, conversationId);
	}
}

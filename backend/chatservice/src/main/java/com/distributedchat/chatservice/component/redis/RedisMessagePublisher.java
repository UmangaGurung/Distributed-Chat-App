package com.distributedchat.chatservice.component.redis;

import java.util.HashMap;
import java.util.Map;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import com.distributedchat.chatservice.component.MessageEncryption;
import com.distributedchat.chatservice.model.dto.Message.MessageRedisPayloadDTO;
import com.distributedchat.chatservice.model.dto.Message.MessageResponseDTO;

@Component
public class RedisMessagePublisher {
	
	RedisTemplate<String, Object> redisTemplate;
	SimpMessagingTemplate simpMessagingTemplate;
	MessageEncryption messageEncryption;
	
	public RedisMessagePublisher(
			RedisTemplate<String, Object> redisTemplate,
			SimpMessagingTemplate simpMessagingTemplate,
			MessageEncryption messageEncryption) {
		// TODO Auto-generated constructor stub
		this.redisTemplate= redisTemplate;
		this.simpMessagingTemplate= simpMessagingTemplate;
		this.messageEncryption= messageEncryption;
	}
	
	public void publishMessage(MessageRedisPayloadDTO payloadDTO, String token) {	
		System.out.println("Messagepayload to publish=======");
		Map<String, Object> payload= new HashMap<>();
		payload.put("payloadDTO", payloadDTO);
		payload.put("token", token);
		
		redisTemplate.convertAndSend("chat:messages", payload);
	}
	
	public void onMessageSuccess(MessageRedisPayloadDTO payloadDTO, String userId) {
		System.out.println("Entered onMessageSuccess");
		String decryptedMessage= messageEncryption.decryptMessage(payloadDTO.getMessage().getMessage());
		
		MessageResponseDTO responseDTO= new MessageResponseDTO(
				payloadDTO.getMessage().getConversation().getConversationId(),
				payloadDTO.getMessage().getMessageId(),
				decryptedMessage,
				payloadDTO.getMessage().getType(),
				payloadDTO.getMessage().getSenderId(),
				payloadDTO.getMessage().getCreatedAt()
				);
		
		simpMessagingTemplate.convertAndSend(
				"/queue/ack/"+userId,
				responseDTO
				);
	}
}

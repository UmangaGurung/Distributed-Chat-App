package com.distributedchat.chatservice.component.redis;

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
	
	public void publishMessage(MessageRedisPayloadDTO payloadDTO) {	
		System.out.println("Messagepayload to publish=======");
		
		redisTemplate.convertAndSend("chat:messages", payloadDTO);
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

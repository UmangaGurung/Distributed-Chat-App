package com.distributedchat.chatservice.component.redis;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.UUID;

import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import com.distributedchat.chatservice.component.MessageEncryption;
import com.distributedchat.chatservice.model.dto.UserDetailGrpcDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConvoMessageDTO;
import com.distributedchat.chatservice.model.dto.Message.MessageRedisPayloadDTO;
import com.distributedchat.chatservice.model.dto.Message.MessageResponseDTO;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class RedisMessageSubscriber implements MessageListener{
	
	ObjectMapper objectMapper;
	SimpMessagingTemplate messagingTemplate;
	MessageEncryption messageEncryption;
	RedisCaching redisCaching;
	
	public RedisMessageSubscriber(
			ObjectMapper objectMapper, 
			SimpMessagingTemplate messagingTemplate,
			MessageEncryption messageEncryption,
			RedisCaching redisCaching) {
		// TODO Auto-generated constructor stub
		this.objectMapper= objectMapper;
		this.messagingTemplate= messagingTemplate;
		this.messageEncryption= messageEncryption;
		this.redisCaching= redisCaching;
	}
	
	@Override
	public void onMessage(Message message, byte[] pattern) {
		// TODO Auto-generated method stub
		String channel= new String(message.getChannel(), StandardCharsets.UTF_8);
		String body= new String(message.getBody(), StandardCharsets.UTF_8);
		String patternStr= new String(pattern, StandardCharsets.UTF_8);
		
		System.out.println(channel);
		System.out.println(body);
		System.out.println(patternStr);
		
		try {
			Map<String, Object> broadcastedPayload= 
					objectMapper.readValue(message.getBody(), new TypeReference<Map<String, Object>>() {});
			
			MessageRedisPayloadDTO payloadDTO= objectMapper.convertValue(broadcastedPayload.get("payloadDTO"), MessageRedisPayloadDTO.class);
			String token= broadcastedPayload.get("token").toString();
			
			String encryptedMessage= payloadDTO.getMessage().getMessage();
			System.out.println("Encrypted Message:=="+encryptedMessage);
		
			String decryptedMessage= messageEncryption.decryptMessage(encryptedMessage);
			System.out.println(decryptedMessage);
			
			UserDetailGrpcDTO userDetails= redisCaching.cacheUserInfo(payloadDTO.getMessage().getSenderId(), token);
			
			MessageResponseDTO responseDTO= new MessageResponseDTO();
			responseDTO.setConversationId(payloadDTO.getMessage().getConversation().getConversationId());
			responseDTO.setMessageId(payloadDTO.getMessage().getMessageId());
			responseDTO.setMessage(decryptedMessage);
			responseDTO.setMessageType(payloadDTO.getMessage().getType());
			responseDTO.setCreatedAt(payloadDTO.getMessage().getCreatedAt());
			responseDTO.setSenderId(payloadDTO.getMessage().getSenderId());
			
			ConvoMessageDTO payload= new ConvoMessageDTO(responseDTO, userDetails);
			
			for (UUID uid: payloadDTO.getReceiverId()) {
				String topic = "/topic/user/" + uid;
			    System.out.println("Sending message......" + payloadDTO.getMessage().getMessageId() + " to " + topic);
				messagingTemplate.convertAndSend(
						topic,
						payload
				);
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}

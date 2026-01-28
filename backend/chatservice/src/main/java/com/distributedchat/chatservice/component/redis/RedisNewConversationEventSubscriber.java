package com.distributedchat.chatservice.component.redis;

import java.nio.charset.StandardCharsets;
import java.util.UUID;

import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import com.distributedchat.chatservice.model.dto.Conversation.ConversationDetailsListDTO;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class RedisNewConversationEventSubscriber implements MessageListener{
	
	private SimpMessagingTemplate messagingTemplate;
	private ObjectMapper mapper;
	
	public RedisNewConversationEventSubscriber(
			SimpMessagingTemplate messagingTemplate,
			ObjectMapper mapper) {
		// TODO Auto-generated constructor stub
		this.messagingTemplate= messagingTemplate;
		this.mapper= mapper;
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
			ConversationDetailsListDTO conversationDetailsListDTO= mapper.readValue(
					message.getBody(), 
					ConversationDetailsListDTO.class);

			String participantId= conversationDetailsListDTO.getConversationResponseDTO()
					.getParticipantID().stream()
					.filter(id -> !id.equals(conversationDetailsListDTO.getDetailGrpcDTO().getUserId()))
					.findFirst()
					.orElse(null).toString();
			
			if (conversationDetailsListDTO.getConversationResponseDTO().getType().equals("BINARY")) {
			String destination= "/topic/event/"+participantId;
			
			messagingTemplate.convertAndSend(
					destination,
					conversationDetailsListDTO
					);
			}else {
				for (UUID userId: conversationDetailsListDTO.getConversationResponseDTO().getParticipantID()) {
					String destination= "/topic/event/"+userId;
					
					messagingTemplate.convertAndSend(
							destination,
							conversationDetailsListDTO
							);
				}
			}
		}catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
	}
}

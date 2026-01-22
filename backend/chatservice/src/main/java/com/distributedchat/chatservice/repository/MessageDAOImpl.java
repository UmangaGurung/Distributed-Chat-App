package com.distributedchat.chatservice.repository;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Repository;

import com.distributedchat.chatservice.model.dto.Message.MessageDTO;
import com.distributedchat.chatservice.model.dto.Message.MessageRedisPayloadDTO;
import com.distributedchat.chatservice.model.entity.Conversation;
import com.distributedchat.chatservice.model.entity.ConversationParticipants;
import com.distributedchat.chatservice.model.entity.Message;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

@Repository
public class MessageDAOImpl implements MessageDAO{
	
	EntityManager entityManager;
	
	public MessageDAOImpl(EntityManager entityManager) {
		// TODO Auto-generated constructor stub
		this.entityManager= entityManager;
	}

	@Override
	public MessageRedisPayloadDTO saveMessage(MessageDTO messageDTO, UUID uid) {
		// TODO Auto-generated method stub
		UUID convoID= messageDTO.getConversationId();
		try {
			TypedQuery<Conversation> query= entityManager.createQuery(
					"SELECT c FROM Conversation c "
					+ "WHERE c.conversationId=:conversationId", Conversation.class)
					.setParameter("conversationId", convoID);
			System.out.println("Convo found for user: "+ uid + " convo: "+messageDTO.getConversationId());
			Conversation conversation= query.getSingleResult();
			
			boolean exists= conversation.getParticipants()
					.stream()
					.anyMatch(p -> p.getUserId().equals(uid));
			
			if (!exists) {
				throw new SecurityException();
			}
			
			Message message= new Message();
			message.setConversation(conversation);
			message.setType(messageDTO.getType());
			message.setMessage(messageDTO.getMessage());
			message.setSenderId(uid);
			
			entityManager.persist(message);
		
			conversation.setLastMessage(message.getMessage());
			conversation.setLastMessageId(message.getMessageId());
			conversation.setUpdatedAt(LocalDateTime.now());
			entityManager.merge(conversation);
			
			List<ConversationParticipants> participants= conversation.getParticipants()
					.stream()
					.filter(user -> !user.getUserId().equals(uid))
					.collect(Collectors.toList());
			
			List<UUID> participantsId= new ArrayList<>();
			
			for (ConversationParticipants participant: participants) {
				participantsId.add(participant.getUserId());
			}
			
			MessageRedisPayloadDTO payloadDTO= new MessageRedisPayloadDTO();
			payloadDTO.setMessage(message);
			payloadDTO.setReceiverId(participantsId);
			
			return payloadDTO;
			
		}catch(Exception e) {
			e.printStackTrace();
			return null;
		}
	}
}

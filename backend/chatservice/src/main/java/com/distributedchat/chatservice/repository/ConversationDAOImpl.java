package com.distributedchat.chatservice.repository;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Repository;

import com.distributedchat.chatservice.model.dto.Conversation.ConversationResponseDTO;
import com.distributedchat.chatservice.model.dto.Message.LatestMessageDTO;
import com.distributedchat.chatservice.model.dto.Message.MessagePaginationDTO;
import com.distributedchat.chatservice.model.dto.Message.MessageResponseDTO;
import com.distributedchat.chatservice.model.entity.Conversation;
import com.distributedchat.chatservice.model.entity.ConversationParticipants;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;

@Repository
public class ConversationDAOImpl implements ConversationDAO{
	
	private EntityManager entityManager;
	
	public ConversationDAOImpl(EntityManager entityManager) {
		// TODO Auto-generated constructor stub
		this.entityManager= entityManager;
	}

	@Override
	public ConversationResponseDTO createGroupConversation(String convoType, String convoName, 
			List<UUID> participants, UUID senderID) {
		// TODO Auto-generated method stub
		try {
			Conversation conversation= new Conversation();
			conversation.setType(convoType);
			conversation.setName(convoName);
			
			entityManager.persist(conversation);
			for (UUID uid: participants) {
				ConversationParticipants convoParticipants= new ConversationParticipants();
				convoParticipants.setConversation(conversation);
				convoParticipants.setUserId(uid);
				if (uid.equals(senderID)) {
					convoParticipants.setRole("ADMIN");
				}else {
					convoParticipants.setRole("USER");
				}
				conversation.getParticipants().add(convoParticipants);
			}
			entityManager.flush();
			
			return conversationDetails(conversation, participants, senderID);
		}catch(Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	@Override
	public Map<ConversationResponseDTO, Boolean> createOrFindConversation(UUID userId, UUID participantId, String type) {
		// TODO Auto-generated method stub
		try {
			TypedQuery<Conversation> query= entityManager.createQuery(
					"SELECT c FROM Conversation c "
					+ "JOIN c.participants p1 "
					+ "JOIN c.participants p2 "
					+ "WHERE p1.userId=:userA AND p2.userId=:userB AND c.type=:type", Conversation.class)
					.setParameter("userA", userId)
					.setParameter("userB", participantId)
					.setParameter("type", type);
			
			Conversation conversation= query.getSingleResult();
			
			System.out.println("Convo found");
			
			List<UUID> partiList= new ArrayList<>();
			partiList.add(participantId);
			partiList.add(userId);
			
			Map<ConversationResponseDTO, Boolean> result= new HashMap<>();
			result.put(conversationDetails(conversation, partiList, null), false);
			
			return result;
		}catch(NoResultException e) {
			System.out.println("Convo not found,so creating one");
			Conversation conversation= new Conversation();
			conversation.setType(type);
			entityManager.persist(conversation);
			
			ConversationParticipants participant1= new ConversationParticipants();
			participant1.setUserId(userId);
			participant1.setRole("USER");
			participant1.setConversation(conversation);
			
			ConversationParticipants participant2= new ConversationParticipants();
			participant2.setUserId(participantId);
			participant2.setRole("USER");
			participant2.setConversation(conversation);
			
			conversation.getParticipants().add(participant1);
			conversation.getParticipants().add(participant2);
			entityManager.flush();
			
			List<UUID> partiList= new ArrayList<>();
			partiList.add(participantId);
			partiList.add(userId);
			
			Map<ConversationResponseDTO, Boolean> result= new HashMap<>();
			result.put(conversationDetails(conversation, partiList, null), true);
			
			return result;
		}catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	@Override
	public List<ConversationResponseDTO> getConversation(UUID uid) {
		// TODO Auto-generated method stub
		try {
			TypedQuery<ConversationParticipants> query= entityManager.createQuery(
					"SELECT c FROM ConversationParticipants c "
					+ "WHERE c.userId=:userId", ConversationParticipants.class)
					.setParameter("userId", uid);
			
			List<ConversationParticipants> participant= query.getResultList();
			List<ConversationResponseDTO> alluserConvos= new ArrayList<>();
			
			for (ConversationParticipants conversationParticipants: participant) {
				Conversation conversation= conversationParticipants.getConversation();	
			
				 List<UUID> conversationParticipantsUUID= conversation.getParticipants()
						.stream()
						.map(ConversationParticipants::getUserId)
						.collect(Collectors.toList());
				
				 UUID adminId= getConversationAdminId(conversation);
				 
				ConversationResponseDTO responseDTO= conversationDetails(
						conversation, conversationParticipantsUUID, adminId);
				
				alluserConvos.add(responseDTO);
			}
			
			return alluserConvos;
		}catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
			return null;
		}
	}

	@Override
	public ConversationResponseDTO editConversationDetails(UUID userId, UUID conversationId, String conversationName) {
		// TODO Auto-generated method stub
		try {
			Conversation conversation= entityManager.find(Conversation.class, conversationId);
			
			boolean exists= conversation.getParticipants()
					.stream()
					.anyMatch(p -> p.getUserId().equals(userId));
			
			if (!exists) {
				throw new SecurityException("Invalid User");
			}
			
			conversation.setName(conversationName);
			conversation.setUpdatedAt(LocalDateTime.now());
			
			List<UUID> participants= conversation.getParticipants()
					.stream()
					.map(p -> p.getUserId())
					.collect(Collectors.toList());
			
			UUID adminId= getConversationAdminId(conversation);
			
			return conversationDetails(conversation, participants, adminId);
		}catch(Exception e) {
			return null;
		}
	}

	@Override
	public ConversationResponseDTO addParticipants(UUID userId, UUID conversationId, List<UUID> userIds) {
		// TODO Auto-generated method stub
		try {
			Conversation conversation= entityManager.find(Conversation.class, conversationId);
			
			boolean exists= conversation.getParticipants()
					.stream()
					.anyMatch(p -> p.getUserId().equals(userId)
							&& p.getRole().equals("ADMIN"));
			
			if (!exists) {
				throw new SecurityException("Invalid User");
			}
			
			List<UUID> participantIds= new ArrayList<>();
			participantIds.addAll(conversation.getParticipants()
					.stream()
					.map(id->id.getUserId())
					.collect(Collectors.toList()));
			
			for (UUID uid: userIds) {
				boolean exist= participantIds.contains(uid);
				
				if (exist) {
					System.out.println("Cant add existing participant");
					continue;
				}
				
				ConversationParticipants participant= new ConversationParticipants();
				participant.setConversation(conversation);
				participant.setRole("USER");
				participant.setUserId(uid);
				
				participantIds.add(uid);
				conversation.getParticipants().add(participant);
				conversation.setUpdatedAt(LocalDateTime.now());
			}
			
			entityManager.flush();
			UUID adminId= getConversationAdminId(conversation);
			
			return conversationDetails(conversation, participantIds, adminId);
		}catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	@Override
	public List<MessageResponseDTO> getAllConversationMessages(
			UUID convoId, UUID userId, MessagePaginationDTO messagePaginationDTO) {
		// TODO Auto-generated method stub
		try {
			Conversation conversation= entityManager.find(Conversation.class, convoId);
			
			boolean exists= conversation.getParticipants()
					.stream()
					.anyMatch(p -> p.getUserId().equals(userId));
			
			if (!exists) {
				throw new SecurityException();
			}
			
			if (messagePaginationDTO.isFirstFetch()) {
				
				TypedQuery<MessageResponseDTO> query= entityManager.createQuery(
						"SELECT new com.distributedchat.chatservice.model.dto.Message.MessageResponseDTO("
						+ "m.conversation.conversationId, "
						+ "m.messageId, m.message, "
						+ "m.type, m.senderId, m.createdAt) "
						+ "FROM Message m WHERE m.conversation.conversationId=:convoId "
						+ "ORDER BY m.createdAt DESC", MessageResponseDTO.class)
						.setParameter("convoId", convoId)
						.setMaxResults(messagePaginationDTO.getLimit());
						
				List<MessageResponseDTO> allMessages= query.getResultList();
				
				return allMessages;
			}
			
			TypedQuery<MessageResponseDTO> query= entityManager.createQuery(
					"SELECT new com.distributedchat.chatservice.model.dto.Message.MessageResponseDTO("
					+ "m.conversation.conversationId, m.messageId, "
					+ "m.message, m.type, m.senderId, m.createdAt) "
					+ "FROM Message m WHERE m.conversation.conversationId=:convoId "
					+ "AND (m.createdAt < :timeStamp OR (m.createdAt=:timeStamp AND m.messageId < :messageId)) "
					+ "ORDER BY m.createdAt DESC", MessageResponseDTO.class)
					.setParameter("convoId", convoId)
					.setParameter("messageId", messagePaginationDTO.getMessageId())
					.setParameter("timeStamp", messagePaginationDTO.getTimeStamp())
					.setMaxResults(messagePaginationDTO.getLimit());
			
			return query.getResultList();
		}catch(Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	@Override
	public List<MessageResponseDTO> getLatestMessages(UUID convoId, UUID userId, LatestMessageDTO latestMessageDTO) {
		// TODO Auto-generated method stub
		System.out.println("Inside dao");
		try {
			Conversation conversation= entityManager.find(Conversation.class, convoId);
			
			boolean exists= conversation.getParticipants().stream()
					.anyMatch(p -> p.getUserId().equals(userId));
			
			if (!exists) {
				throw new SecurityException();
			}
			
			TypedQuery<MessageResponseDTO> query= entityManager.createQuery(
					"SELECT new com.distributedchat.chatservice.model.dto.Message.MessageResponseDTO("
					+ "m.conversation.conversationId, m.messageId, "
					+ "m.message, m.type, "
					+ "m.senderId, m.createdAt) "
					+ "FROM Message m WHERE m.conversation.conversationId=:convoId "
					+ "AND (m.createdAt > :timeStamp OR (m.createdAt=:timeStamp AND m.messageId > :messageId)) "
					+ "ORDER BY m.createdAt DESC", MessageResponseDTO.class)
					.setParameter("convoId", convoId)
					.setParameter("timeStamp", latestMessageDTO.getTimeStamp())
					.setParameter("messageId", latestMessageDTO.getMessageId());
			
			System.out.println("Inside dao");
			System.out.println(query.getResultList());
			
			return query.getResultList();
		}catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		}
		return null;
	}
	
	private ConversationResponseDTO conversationDetails(
			Conversation conversation,
			List<UUID> participants, UUID adminId) {
		return new ConversationResponseDTO(
				conversation.getConversationId(), 
				conversation.getName(), 
				conversation.getLastMessage(),
				conversation.getLastMessageId(),
				participants, 
				conversation.getUpdatedAt(),
				conversation.getType(),
				adminId
				);
	}
	
	private UUID getConversationAdminId(Conversation conversation) {
		if (conversation.getType().equals("BINARY")) {
			return null;
		}
		
		UUID adminId= conversation.getParticipants().stream()
				.filter(p -> "ADMIN".equals(p.getRole()))
				.findAny()
				.map(i -> i.getUserId())
				.orElse(null);
		
		return adminId;
	}
}


package com.distributedchat.chatservice.repository;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.distributedchat.chatservice.model.dto.Conversation.ConversationResponseDTO;
import com.distributedchat.chatservice.model.dto.Message.MessagePaginationDTO;
import com.distributedchat.chatservice.model.dto.Message.MessageResponseDTO;

public interface ConversationDAO {
	
	public ConversationResponseDTO createGroupConversation(String convoType, String convoName, List<UUID> participants, UUID senderId);
	
	public Map<ConversationResponseDTO, Boolean> createOrFindConversation(UUID userId, UUID participantId, String type);
	
	public List<ConversationResponseDTO> getConversation(UUID uid);

	public ConversationResponseDTO editConversationDetails(UUID userId, UUID conversationId, String conversationName);

	public ConversationResponseDTO addParticipants(UUID userId, UUID conversationId, List<UUID> userIds);

	public List<MessageResponseDTO> getAllConversationMessages(UUID convoId, UUID userId, MessagePaginationDTO messagePaginationDTO);
}
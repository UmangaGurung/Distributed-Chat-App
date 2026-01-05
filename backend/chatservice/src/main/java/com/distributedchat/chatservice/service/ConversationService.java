package com.distributedchat.chatservice.service;

import java.util.List;

import com.distributedchat.chatservice.model.dto.Conversation.ConversationDetailsListDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConversationGroupDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConversationResponseDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConversationUpdateDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConvoMessageDTO;
import com.distributedchat.chatservice.model.dto.Conversation.CreateOrFindDTO;

public interface ConversationService {
	public ConversationResponseDTO createGroupConversation(ConversationGroupDTO conversationGroupDTO, String uid);
	
	public ConversationDetailsListDTO createOrFindConversation(CreateOrFindDTO createOrFindDTO, String uid);

	public List<ConversationDetailsListDTO> getConversation(String uid);

	//public void addUserToConversation(String userId, String convoId, ConversationUpdateDTO conversationUpdateDTO);
	public ConversationResponseDTO editConversationDetails(ConversationUpdateDTO conversationUpdateDTO, String convoId, String userId);
	
	public ConversationResponseDTO addParticipants(ConversationUpdateDTO conversationUpdateDTO, String convoId, String userId);
	
	public List<ConvoMessageDTO> getAllConversationMessages(String convoId, String userId);
}

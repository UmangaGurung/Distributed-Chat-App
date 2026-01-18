package com.distributedchat.chatservice.model.dto.Conversation;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class ConversationResponseDTO {
	
	private UUID conversationID;
	private String conversationName;
	private String lastMessage;
	private List<UUID> participantID= new ArrayList<>();
	private LocalDateTime updatedAt;
	private String type;
	private UUID adminId;
	
	public ConversationResponseDTO() {
		// TODO Auto-generated constructor stub
	}
	
	public ConversationResponseDTO(UUID conversationID, String conversationName, String lastMessage,
			List<UUID> participantID, LocalDateTime updatedAt, String type, UUID adminId) {
		super();
		this.conversationID = conversationID;
		this.conversationName = conversationName;
		this.lastMessage = lastMessage;
		this.participantID = participantID;
		this.updatedAt = updatedAt;
		this.type= type;
		this.adminId= adminId;
	}
	
	
	public UUID getAdminId() {
		return adminId;
	}
	public void setAdminId(UUID adminId) {
		this.adminId = adminId;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public List<UUID> getParticipantID() {
		return participantID;
	}
	public void setParticipantID(List<UUID> participantID) {
		this.participantID = participantID;
	}
	public UUID getConversationID() {
		return conversationID;
	}
	public void setConversationID(UUID conversationID) {
		this.conversationID = conversationID;
	}
	public String getConversationName() {
		return conversationName;
	}
	public void setConversationName(String conversationName) {
		this.conversationName = conversationName;
	}
	public String getLastMessage() {
		return lastMessage;
	}
	public void setLastMessage(String lastMessage) {
		this.lastMessage = lastMessage;
	}
	public LocalDateTime getUpdatedAt() {
		return updatedAt;
	}
	public void setUpdatedAt(LocalDateTime updatedAt) {
		this.updatedAt = updatedAt;
	}
}

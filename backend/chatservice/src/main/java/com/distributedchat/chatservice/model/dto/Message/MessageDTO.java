package com.distributedchat.chatservice.model.dto.Message;

import java.util.UUID;

public class MessageDTO {
	
	private UUID conversationId;
	private String type;
	private String message;
	
	public MessageDTO() {
		// TODO Auto-generated constructor stub
	}

	public UUID getConversationId() {
		return conversationId;
	}
	public void setConversationId(UUID conversationId) {
		this.conversationId = conversationId;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
}

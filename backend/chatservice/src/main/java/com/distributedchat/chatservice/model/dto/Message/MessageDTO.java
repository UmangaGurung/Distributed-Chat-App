package com.distributedchat.chatservice.model.dto.Message;

import java.util.UUID;

public class MessageDTO {
	
	private UUID conversationId;
	private MessageType type;
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
	public MessageType getType() {
		return type;
	}
	public void setType(MessageType type) {
		this.type = type;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
}

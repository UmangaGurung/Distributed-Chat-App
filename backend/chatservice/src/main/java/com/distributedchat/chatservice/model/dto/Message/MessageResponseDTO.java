package com.distributedchat.chatservice.model.dto.Message;

import java.time.LocalDateTime;
import java.util.UUID;

public class MessageResponseDTO {
	
	private UUID conversationId;
	private UUID messageId;
	private String message;
	private String messageType;
	private LocalDateTime createdAt;
	private UUID senderId;
	
	public MessageResponseDTO() {
		// TODO Auto-generated constructor stub
	}

	public MessageResponseDTO(UUID conversationId, UUID messageId, String message, String messageType,
			UUID senderId, LocalDateTime createdAt) {
		super();
		this.conversationId = conversationId;
		this.messageId = messageId;
		this.message = message;
		this.messageType = messageType;
		this.senderId= senderId;
		this.createdAt = createdAt;
	}

	public UUID getSenderId() {
		return senderId;
	}

	public void setSenderId(UUID senderId) {
		this.senderId = senderId;
	}

	public UUID getConversationId() {
		return conversationId;
	}

	public void setConversationId(UUID conversationId) {
		this.conversationId = conversationId;
	}

	public UUID getMessageId() {
		return messageId;
	}

	public void setMessageId(UUID messageId) {
		this.messageId = messageId;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getMessageType() {
		return messageType;
	}

	public void setMessageType(String messageType) {
		this.messageType = messageType;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}
}

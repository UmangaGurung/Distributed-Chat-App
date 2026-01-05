package com.distributedchat.chatservice.model.entity;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.data.annotation.CreatedDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.validation.constraints.Pattern;

@Entity
public class Message {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	@Column(updatable = false, nullable = false)
	private UUID messageId;
	
	@Column
	private String message;
	
	@Pattern(regexp = "TEXT|MEDIA|URL")
	@Column(nullable = false)
	private String type;
	
	@ManyToOne
	@JoinColumn(name="conversationId", nullable = false, updatable = false)
	private Conversation conversation;
	
	@Column(nullable = false, updatable = false)
	private UUID senderId;
	
	@CreatedDate
	@Column(nullable = false, updatable = false)
	private LocalDateTime createdAt;
	
	public Message() {
		this.createdAt = LocalDateTime.now();
	}
	
	public Message(String message, @Pattern(regexp = "TEXT|MEDIA|URL") String type, Conversation conversation,
			UUID senderId) {
		super();
		this.message = message;
		this.type = type;
		this.conversation = conversation;
		this.senderId = senderId;
		this.createdAt = LocalDateTime.now();
	}

	public UUID getSenderId() {
		return senderId;
	}

	public void setSenderId(UUID senderId) {
		this.senderId = senderId;
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

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public Conversation getConversation() {
		return conversation;
	}

	public void setConversation(Conversation conversation) {
		this.conversation = conversation;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}
}

package com.distributedchat.chatservice.model.entity;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.validation.constraints.Pattern;

@Entity
public class Conversation {
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	@Column(updatable = false, nullable = false)
	private UUID conversationId;
	
	@Column
	private String name;
	
	@Pattern(regexp = "GROUP|BINARY")
	@Column(nullable = false)
	private String type;
	
	@OneToMany(mappedBy = "conversation", cascade = CascadeType.ALL, 
			orphanRemoval = true, fetch = FetchType.LAZY)
	@JsonIgnore
	private List<Message> messages= new ArrayList<>();
	
	@Column
	private String lastMessage;
	
	@Column
	private UUID lastMessageId;
	
	@OneToMany(mappedBy = "conversation", cascade = CascadeType.ALL, 
			orphanRemoval = true, fetch = FetchType.LAZY)
	@JsonIgnore
	private List<ConversationParticipants> participants= new ArrayList<>();
	
	@CreatedDate
	@Column(nullable = false, updatable = false)
	private LocalDateTime createdAt;
	
	@LastModifiedDate
	private LocalDateTime updatedAt;

	public Conversation() {
		this.createdAt = LocalDateTime.now();
		this.updatedAt = LocalDateTime.now();
	}
	
	public Conversation(String name, @Pattern(regexp = "GROUP|BINARY") String type, List<Message> messages,
			String lastMessage, UUID lastMessageId, List<ConversationParticipants> participants, LocalDateTime createdAt,
			LocalDateTime updatedAt) {
		super();
		this.name = name;
		this.type = type;
		this.messages = messages;
		this.lastMessage = lastMessage;
		this.lastMessageId= lastMessageId;
		this.participants = participants;
		this.createdAt = LocalDateTime.now();
		this.updatedAt = LocalDateTime.now();
	}
	
	public UUID getLastMessageId() {
		return lastMessageId;
	}

	public void setLastMessageId(UUID lastMessageId) {
		this.lastMessageId = lastMessageId;
	}

	public UUID getConversationId() {
		return conversationId;
	}

	public void setConversationId(UUID conversationId) {
		this.conversationId = conversationId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public List<Message> getMessages() {
		return messages;
	}

	public void setMessages(List<Message> messages) {
		this.messages = messages;
	}

	public String getLastMessage() {
		return lastMessage;
	}

	public void setLastMessage(String lastMessage) {
		this.lastMessage = lastMessage;
	}

	public List<ConversationParticipants> getParticipants() {
		return participants;
	}

	public void setParticipants(List<ConversationParticipants> participants) {
		this.participants = participants;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}

	public LocalDateTime getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(LocalDateTime updatedAt) {
		this.updatedAt = updatedAt;
	}
}	


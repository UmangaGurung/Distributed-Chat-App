package com.distributedchat.chatservice.model.entity;

import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.validation.constraints.Pattern;

@Entity
public class ConversationParticipants {
	
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	private UUID bridgeId;
	
	@ManyToOne
	@JoinColumn(name = "conversationId")
	private Conversation conversation;
	
	@Column(nullable = false)
	private UUID userId;
	
	@Pattern(regexp = "ADMIN|USER")
	@Column(name= "user_role", updatable = true)
	private String role;
	
	public ConversationParticipants() {
		
	}
	
	public ConversationParticipants(Conversation conversation, UUID userId, String role) {
		super();
		this.conversation = conversation;
		this.userId = userId;
		this.role= role;
	}
	
	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public UUID getBridgeId() {
		return bridgeId;
	}

	public void setBridgeId(UUID bridgeId) {
		this.bridgeId = bridgeId;
	}

	public Conversation getConversation() {
		return conversation;
	}

	public void setConversation(Conversation conversation) {
		this.conversation = conversation;
	}

	public UUID getUserId() {
		return userId;
	}

	public void setUserId(UUID userId) {
		this.userId = userId;
	}
}

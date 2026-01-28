package com.distributedchat.chatservice.model.dto.Conversation;

import java.util.List;
import java.util.UUID;

import jakarta.validation.constraints.NotBlank;

public class ConversationUpdateDTO {
	
	private String conversationName;
	private List<UUID> userIds;
	
	@NotBlank
	private UpdateType type;
	
	public ConversationUpdateDTO() {
		// TODO Auto-generated constructor stub
	}

	public String getConversationName() {
		return conversationName;
	}

	public void setConversationName(String conversationName) {
		this.conversationName = conversationName;
	}

	public List<UUID> getUserIds() {
		return userIds;
	}

	public void setUserIds(List<UUID> userIds) {
		this.userIds = userIds;
	}

	public UpdateType getType() {
		return type;
	}

	public void setType(UpdateType type) {
		this.type = type;
	}
}

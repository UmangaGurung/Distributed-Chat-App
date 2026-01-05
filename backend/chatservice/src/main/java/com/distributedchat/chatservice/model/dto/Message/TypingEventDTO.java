package com.distributedchat.chatservice.model.dto.Message;

public class TypingEventDTO {
	private String conversationId;
	private String event;
	
	public TypingEventDTO() {
		// TODO Auto-generated constructor stub
	}

	public String getConversationId() {
		return conversationId;
	}

	public void setConversationId(String conversationId) {
		this.conversationId = conversationId;
	}

	public String getEvent() {
		return event;
	}

	public void setEvent(String event) {
		this.event = event;
	}
}

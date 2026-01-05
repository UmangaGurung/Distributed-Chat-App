package com.distributedchat.chatservice.model.dto.Conversation;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class ConversationDTO {
	private String name;
	private String type;
	private List<UUID> participants= new ArrayList<>();
	
	public ConversationDTO() {
		// TODO Auto-generated constructor stub
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

	public List<UUID> getParticipants() {
		return participants;
	}

	public void setParticipants(List<UUID> participants) {
		this.participants = participants;
	}
}

package com.distributedchat.chatservice.model.dto.Conversation;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

public class ConversationGroupDTO {
	
	@NotBlank
	private String name;
	
	@NotBlank
	private String type;
	
	@NotEmpty
	private List<UUID> participants= new ArrayList<>();
	
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

package com.distributedchat.chatservice.model.dto.Conversation;

import java.util.UUID;

public class CreateOrFindDTO {
	private UUID participantId;
	private String type;
	
	public CreateOrFindDTO() {
		// TODO Auto-generated constructor stub
	}
	
	public CreateOrFindDTO(UUID participantId, String type) {
		// TODO Auto-generated constructor stub
		this.participantId= participantId;
		this.type= type;
	}

	public UUID getParticipantId() {
		return participantId;
	}

	public void setParticipantId(UUID participantId) {
		this.participantId = participantId;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

}

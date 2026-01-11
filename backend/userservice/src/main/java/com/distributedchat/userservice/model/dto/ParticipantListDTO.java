package com.distributedchat.userservice.model.dto;

import java.util.Set;
import java.util.UUID;

public class ParticipantListDTO {

	private Set<UUID> userIdList;
	
	public ParticipantListDTO() {
		// TODO Auto-generated constructor stub
	}

	public Set<UUID> getUserIdList() {
		return userIdList;
	}

	public void setUserIdList(Set<UUID> userIdList) {
		this.userIdList = userIdList;
	}
}

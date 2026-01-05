package com.distributedchat.chatservice.model.dto.Message;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.distributedchat.chatservice.model.entity.Message;

public class MessageRedisPayloadDTO {
	
	private List<UUID> receiverId= new ArrayList<>();
	private Message message;
	
	public MessageRedisPayloadDTO() {
		// TODO Auto-generated constructor stub
	}

	public MessageRedisPayloadDTO(List<UUID> receiverId, Message message) {
		super();
		this.receiverId = receiverId;
		this.message = message;
	}
	
	public List<UUID> getReceiverId() {
		return receiverId;
	}

	public void setReceiverId(List<UUID> receiverId) {
		this.receiverId = receiverId;
	}

	public Message getMessage() {
		return message;
	}

	public void setMessage(Message message) {
		this.message = message;
	}
}


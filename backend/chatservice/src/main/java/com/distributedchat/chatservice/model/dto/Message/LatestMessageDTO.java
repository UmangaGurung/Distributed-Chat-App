package com.distributedchat.chatservice.model.dto.Message;

import java.time.LocalDateTime;
import java.util.UUID;

public class LatestMessageDTO {
	
	private UUID messageId;
	private LocalDateTime timeStamp;
	
	public LatestMessageDTO() {
		// TODO Auto-generated constructor stub
	}

	public UUID getMessageId() {
		return messageId;
	}

	public void setMessageId(UUID messageId) {
		this.messageId = messageId;
	}

	public LocalDateTime getTimeStamp() {
		return timeStamp;
	}

	public void setTimeStamp(LocalDateTime timeStamp) {
		this.timeStamp = timeStamp;
	}
}

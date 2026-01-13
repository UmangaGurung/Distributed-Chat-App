package com.distributedchat.chatservice.model.dto.Message;

import java.time.LocalDateTime;
import java.util.UUID;

public class MessagePaginationDTO {
	
	private UUID messageId;
	private LocalDateTime timeStamp;
	private int limit;
	private boolean firstFetch;
	
	public MessagePaginationDTO() {
		// TODO Auto-generated constructor stub
	}

	public boolean isFirstFetch() {
		return firstFetch;
	}

	public void setFirstFetch(boolean firstFetch) {
		this.firstFetch = firstFetch;
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

	public int getLimit() {
		return limit;
	}

	public void setLimit(int limit) {
		this.limit = limit;
	}
}



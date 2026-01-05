package com.distributedchat.chatservice.service;

import com.distributedchat.chatservice.model.dto.Message.MessageDTO;
import com.distributedchat.chatservice.model.dto.Message.TypingEventDTO;

public interface MessageService {
	public void saveMessage(MessageDTO messageDTO, String userId);

	public void typingEvent(TypingEventDTO eventDTO, String userId);
}

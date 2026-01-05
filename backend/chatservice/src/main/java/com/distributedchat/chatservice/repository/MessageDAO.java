package com.distributedchat.chatservice.repository;

import java.util.UUID;

import com.distributedchat.chatservice.model.dto.Message.MessageDTO;
import com.distributedchat.chatservice.model.dto.Message.MessageRedisPayloadDTO;

public interface MessageDAO {
	public MessageRedisPayloadDTO saveMessage(MessageDTO messageDTO, UUID uid);
}

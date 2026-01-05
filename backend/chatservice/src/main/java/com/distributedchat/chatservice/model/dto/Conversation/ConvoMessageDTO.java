package com.distributedchat.chatservice.model.dto.Conversation;

import com.distributedchat.chatservice.model.dto.UserDetailGrpcDTO;
import com.distributedchat.chatservice.model.dto.Message.MessageResponseDTO;

public class ConvoMessageDTO {
	
	private MessageResponseDTO messageResponse;
	private UserDetailGrpcDTO senderDetails;
	
	public ConvoMessageDTO() {
		// TODO Auto-generated constructor stub
	}
	
	
	public ConvoMessageDTO(MessageResponseDTO messageResponse, UserDetailGrpcDTO senderDetails) {
		super();
		this.messageResponse = messageResponse;
		this.senderDetails = senderDetails;
	}

	public MessageResponseDTO getMessageResponse() {
		return messageResponse;
	}

	public void setMessageResponse(MessageResponseDTO messageResponse) {
		this.messageResponse = messageResponse;
	}

	public UserDetailGrpcDTO getSenderDetails() {
		return senderDetails;
	}
	
	public void setSenderDetails(UserDetailGrpcDTO senderDetails) {
		this.senderDetails = senderDetails;
	}
}

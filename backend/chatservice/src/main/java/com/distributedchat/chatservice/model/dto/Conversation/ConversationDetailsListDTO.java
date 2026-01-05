package com.distributedchat.chatservice.model.dto.Conversation;

import com.distributedchat.chatservice.model.dto.UserDetailGrpcDTO;

public class ConversationDetailsListDTO {
	private ConversationResponseDTO conversationResponseDTO;
	private UserDetailGrpcDTO detailGrpcDTO;
	
	public ConversationDetailsListDTO(ConversationResponseDTO conversationResponseDTO,
			UserDetailGrpcDTO detailGrpcDTO) {
		super();
		this.conversationResponseDTO = conversationResponseDTO;
		this.detailGrpcDTO = detailGrpcDTO;
	}

	public ConversationResponseDTO getConversationResponseDTO() {
		return conversationResponseDTO;
	}

	public void setConversationResponseDTO(ConversationResponseDTO conversationResponseDTO) {
		this.conversationResponseDTO = conversationResponseDTO;
	}

	public UserDetailGrpcDTO getDetailGrpcDTO() {
		return detailGrpcDTO;
	}

	public void setDetailGrpcDTO(UserDetailGrpcDTO detailGrpcDTO) {
		this.detailGrpcDTO = detailGrpcDTO;
	}
}

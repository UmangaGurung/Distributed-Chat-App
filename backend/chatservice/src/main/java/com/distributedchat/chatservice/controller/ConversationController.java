package com.distributedchat.chatservice.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.distributedchat.chatservice.model.dto.Conversation.ConversationDetailsListDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConversationGroupDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConversationResponseDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConversationUpdateDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConvoMessageDTO;
import com.distributedchat.chatservice.model.dto.Conversation.CreateOrFindDTO;
import com.distributedchat.chatservice.model.dto.Conversation.UpdateType;
import com.distributedchat.chatservice.model.dto.Message.LatestMessageDTO;
import com.distributedchat.chatservice.model.dto.Message.MessagePaginationDTO;
import com.distributedchat.chatservice.service.ConversationService;

@RestController
@RequestMapping("/chat")
public class ConversationController {
	
	ConversationService conversationService;
	
	public ConversationController(ConversationService conversationService) {
		// TODO Auto-generated constructor stub
		this.conversationService= conversationService;
	}
	
	@PostMapping("/conversations/groups")
	public ResponseEntity<ConversationDetailsListDTO> createGroupConversation(
			@RequestBody ConversationGroupDTO conversationGroupDTO,
			@AuthenticationPrincipal Map<String, String> userDetails){
		String uid= userDetails.get("userId");
		String userName= userDetails.get("userName");
		String phone= userDetails.get("phone");
		String photo= userDetails.get("photo");
		
		ConversationDetailsListDTO conversation=
				conversationService.createGroupConversation(conversationGroupDTO, uid, userName, phone, photo);
	
		return ResponseEntity.status(HttpStatus.OK).body(conversation);
	}
	
	@PostMapping("/conversations/direct-messages")
	public ResponseEntity<ConversationDetailsListDTO> createOrFindConversation(
			@RequestBody CreateOrFindDTO createOrFindDTO,
			@AuthenticationPrincipal Map<String, String> userDetail){
		String userId= userDetail.get("userId");
		String userName= userDetail.get("userName");
		String phone= userDetail.get("phone");
		String photo= userDetail.get("photo");
		
		ConversationDetailsListDTO response= conversationService.createOrFindConversation(
				createOrFindDTO, userId, userName, phone, photo);
		
		return ResponseEntity.status(HttpStatus.OK).body(response);
	}
	
	@GetMapping("/conversations")
	public ResponseEntity<List<ConversationDetailsListDTO>> getConversations(
			@AuthenticationPrincipal Map<String, String> userDetails){
		String uid= userDetails.get("userId");
		
		List<ConversationDetailsListDTO> allConversations= conversationService.getConversation(uid);
		
		return ResponseEntity.status(HttpStatus.OK).body(allConversations);
	}
	
	@PatchMapping("/conversations/{conversationId}")
	private ResponseEntity<ConversationResponseDTO> updateConversation(
			@PathVariable("conversationId") String convoId,
			@RequestBody ConversationUpdateDTO conversationUpdateDTO,
			@AuthenticationPrincipal Map<String, String> userDetails){
		String userId= userDetails.get("userId");
		
		if (conversationUpdateDTO.getType()==UpdateType.EDIT_CHAT_NAME) {
			ConversationResponseDTO responseDTO= conversationService.editConversationDetails(conversationUpdateDTO, convoId, userId);
			
			return ResponseEntity.status(HttpStatus.OK).body(responseDTO);
		}else if (conversationUpdateDTO.getType()==UpdateType.ADD_PARTICIPANTS) {
			ConversationResponseDTO responseDTO= conversationService.addParticipants(conversationUpdateDTO, convoId, userId);
			
			return ResponseEntity.status(HttpStatus.OK).body(responseDTO);
		}
		 return ResponseEntity.badRequest().build();
	}
	
	@PostMapping("/conversations/{conversationId}/messages")
	public ResponseEntity<List<ConvoMessageDTO>> getConversationMessages(
			@PathVariable("conversationId") String convoId,
			@RequestBody MessagePaginationDTO messagePaginationDTO,
			@AuthenticationPrincipal Map<String, String> userDetails){
		String userId= userDetails.get("userId");
				
		List<ConvoMessageDTO> allMessages= conversationService.getAllConversationMessages(convoId, userId, messagePaginationDTO);
		
		return ResponseEntity.status(HttpStatus.OK).body(allMessages);
	}
	
	@PostMapping("/conversations/{conversationId}/messages/latest")
	public ResponseEntity<List<ConvoMessageDTO>> getLatestMessages(
			@PathVariable("conversationId") String conversationId,
			@RequestBody LatestMessageDTO latestMessageDTO,
			@AuthenticationPrincipal Map<String, String> userDetails){
		String userId= userDetails.get("userId");
		
		List<ConvoMessageDTO> latestMessages= conversationService.getLatestMessages(conversationId, userId, latestMessageDTO);
		
		return ResponseEntity.status(HttpStatus.OK).body(latestMessages);
	}
}

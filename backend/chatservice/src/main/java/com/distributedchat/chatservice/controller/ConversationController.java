package com.distributedchat.chatservice.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
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
	public ResponseEntity<Map<String, Object>> createGroupConversation(
			@RequestBody ConversationGroupDTO conversationGroupDTO){
		String uid= SecurityContextHolder.getContext()
						.getAuthentication()
						.getPrincipal()
						.toString();
		
		ConversationResponseDTO conversation= conversationService.createGroupConversation(conversationGroupDTO, uid);
		Map<String, Object> response= new HashMap<>();
		response.put("response", conversation);
		
		return ResponseEntity.status(HttpStatus.OK).body(response);
	}
	
	@PostMapping("/conversations/direct-messages")
	public ResponseEntity<ConversationDetailsListDTO> createOrFindConversation(
			@RequestBody CreateOrFindDTO createOrFindDTO){
		String uid= SecurityContextHolder.getContext()
				.getAuthentication()
				.getPrincipal()
				.toString();
		
		ConversationDetailsListDTO response= conversationService.createOrFindConversation(createOrFindDTO, uid);
		
		return ResponseEntity.status(HttpStatus.OK).body(response);
	}
	
	@GetMapping("/conversations")
	public ResponseEntity<List<ConversationDetailsListDTO>> getConversations(){
		String uid= SecurityContextHolder.getContext()
						.getAuthentication()
						.getPrincipal()
						.toString();
		
		List<ConversationDetailsListDTO> allConversations= conversationService.getConversation(uid);
		
		return ResponseEntity.status(HttpStatus.OK).body(allConversations);
	}
	
	@PatchMapping("/conversations/{conversationId}")
	private ResponseEntity<ConversationResponseDTO> updateConversation(
			@PathVariable("conversationId") String convoId,
			@RequestBody ConversationUpdateDTO conversationUpdateDTO){
		String userId= SecurityContextHolder.getContext()
				.getAuthentication()
				.getPrincipal()
				.toString();
		
		if (conversationUpdateDTO.getType()==UpdateType.EDIT_CHAT_NAME) {
			ConversationResponseDTO responseDTO= conversationService.editConversationDetails(conversationUpdateDTO, convoId, userId);
			
			return ResponseEntity.status(HttpStatus.OK).body(responseDTO);
		}else if (conversationUpdateDTO.getType()==UpdateType.ADD_PARTCIPANTS) {
			ConversationResponseDTO responseDTO= conversationService.addParticipants(conversationUpdateDTO, convoId, userId);
			
			return ResponseEntity.status(HttpStatus.OK).body(responseDTO);
		}
		 return ResponseEntity.badRequest().build();
	}
	
	@GetMapping("/conversations/{conversationId}/messages")
	public ResponseEntity<List<ConvoMessageDTO>> getConversationMessages(
			@PathVariable("conversationId") String convoId){
		String userId= SecurityContextHolder.getContext()
				.getAuthentication()
				.getPrincipal()
				.toString();
		
		List<ConvoMessageDTO> allMessages= conversationService.getAllConversationMessages(convoId, userId);
//		Map<String, Object> response= new HashMap<>();
//		response.put("messages", allMessages);
		
		return ResponseEntity.status(HttpStatus.OK).body(allMessages);
	}
}

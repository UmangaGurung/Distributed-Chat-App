package com.distributedchat.chatservice.controller;

import java.util.Map;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.stereotype.Controller;

import com.distributedchat.chatservice.model.dto.Message.MessageDTO;
import com.distributedchat.chatservice.model.dto.Message.TypingEventDTO;
import com.distributedchat.chatservice.service.MessageService;

@Controller
public class MessageController {
	
	MessageService messageService;
	
	public MessageController(MessageService messageService) {
		// TODO Auto-generated constructor stub
		this.messageService= messageService;
	}
	
	@MessageMapping("/chat.sendMessage")
	public void sendMessage(MessageDTO message, SimpMessageHeaderAccessor headerAccessor) {
		System.out.println(message.getMessage());
	
		Map<String, Object> sessionAttributes= headerAccessor.getSessionAttributes();
		System.out.println(sessionAttributes.get("userId"));
		
		String userId= String.valueOf(sessionAttributes.get("userId"));
		
		messageService.saveMessage(message, userId);	
	}
	
	@MessageMapping("/chat.typingEvent")
	public void typingEvent(TypingEventDTO eventDTO, SimpMessageHeaderAccessor headerAccessor) {
		Map<String, Object> sessionAttributes= headerAccessor.getSessionAttributes();
		System.out.println(sessionAttributes.get("userId"));
		
		String userId= String.valueOf(sessionAttributes.get("userId"));
		String userImage= String.valueOf(sessionAttributes.get("imagePath"));
		
		messageService.typingEvent(eventDTO, userId, userImage);
	}
}

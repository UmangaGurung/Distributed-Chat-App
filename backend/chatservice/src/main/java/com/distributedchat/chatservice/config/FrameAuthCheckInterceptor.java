package com.distributedchat.chatservice.config;

import java.util.Map;

import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;

import com.distributedchat.chatservice.component.redis.RedisTokenBlackList;

import io.jsonwebtoken.MalformedJwtException;

public class FrameAuthCheckInterceptor implements ChannelInterceptor{

	private RedisTokenBlackList blackList;
	
	public FrameAuthCheckInterceptor(RedisTokenBlackList blackList) {
		// TODO Auto-generated constructor stub
		this.blackList= blackList;
	}
	
	public Message<?> preSend(Message<?> message, MessageChannel channel) {
		StompHeaderAccessor accessor= StompHeaderAccessor.wrap(message);
		
		if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())
				|| StompCommand.SEND.equals(accessor.getCommand())) {
			
			StompHeaderAccessor headerAccessor= StompHeaderAccessor.wrap(message);
			Map<String, Object> sessionAttributes= headerAccessor.getSessionAttributes();
			
			if (sessionAttributes.isEmpty()) {
				throw new SecurityException("Connection access without any session details");
			}
			
			//add classcastexception later
			String tokenId= (String) sessionAttributes.get("tokenId");
			Long exp= (Long) sessionAttributes.get("exp");

			if (tokenId == null || exp == null) {
			    throw new SecurityException("Session attributes missing values");
			}
			
			if (blackList.isTokenBlackListed(tokenId)) {
				throw new MalformedJwtException("Invalid Token");
			}
			
			if (System.currentTimeMillis() > exp) {
				throw new MalformedJwtException("Invalid Token");
			}
		}
		return message;
	}
}

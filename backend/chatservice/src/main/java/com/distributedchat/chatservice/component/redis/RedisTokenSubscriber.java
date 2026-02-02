package com.distributedchat.chatservice.component.redis;

import java.util.Date;
import java.util.Map;

import java.nio.charset.StandardCharsets;

import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class RedisTokenSubscriber implements MessageListener{
	
	private final ObjectMapper objectMapper = new ObjectMapper();
	private RedisTokenBlackList blackList;
	private SimpMessageHeaderAccessor accessor;
	
	public RedisTokenSubscriber(RedisTokenBlackList blackList) {
		// TODO Auto-generated constructor stub
		this.blackList= blackList;
	}
	
	@Override
	public void onMessage(Message message, byte[] pattern) {
		// TODO Auto-generated method stub
		try {
			String body= new String(message.getBody(), StandardCharsets.UTF_8);
			
			Map<String, Date> tokenMap= objectMapper.readValue(
					body, new TypeReference<Map<String, Date>>() {
			});
					
			System.out.println("Message Service recieved Expired Token: "+ body);
			System.out.println(tokenMap);
			
			tokenMap.forEach((tokenId, expire) -> {
				System.out.println(tokenId);
				System.out.println(expire);
				if (blackList.isTokenBlackListed(tokenId)) {
					return;
				}
				accessor.setSessionAttributes(null);
				blackList.blackListToken(tokenId, expire);
			});
		}catch(Exception e) {
			e.printStackTrace();
		}
	}
}

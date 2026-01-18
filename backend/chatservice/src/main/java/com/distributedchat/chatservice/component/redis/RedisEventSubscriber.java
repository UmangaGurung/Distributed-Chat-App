package com.distributedchat.chatservice.component.redis;

import java.nio.charset.StandardCharsets;

import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

@Component
public class RedisEventSubscriber implements MessageListener{
	
	private SimpMessagingTemplate messagingTemplate;
	private static final String seperator= "\u2021";
	
	public RedisEventSubscriber(SimpMessagingTemplate messagingTemplate) {
		// TODO Auto-generated constructor stub
		this.messagingTemplate= messagingTemplate;
	}
	
	@Override
	public void onMessage(Message message, byte[] pattern) {
		// TODO Auto-generated method stub
		try {
			String channelEvent= new String(message.getBody(), StandardCharsets.UTF_8);
			
			System.out.println("On Severs:"+channelEvent);
			String[] list= channelEvent.split(seperator, 4);
			System.out.println(list[0]);
			
			String destination= "/topic/event/"+ list[0];
			String payload= channelEvent;
		
			messagingTemplate.convertAndSend(
					destination,
					payload);
			
		}catch(Exception e) {
			e.printStackTrace();
		}
	}

}

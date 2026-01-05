package com.distributedchat.chatservice.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

import com.distributedchat.chatservice.component.JWTService;
import com.distributedchat.chatservice.component.redis.RedisTokenBlackList;

@Configuration
@EnableWebSocketMessageBroker
public class SocketConfig implements WebSocketMessageBrokerConfigurer{
	
	@Autowired
	JWTService jwtService;
	@Autowired
	RedisTokenBlackList blackList;
	
	public void registerStompEndpoints(StompEndpointRegistry stompRegistery) {
		stompRegistery.addEndpoint("/ws/")
		.setAllowedOriginPatterns("*")
		.addInterceptors(new HandShakeInterceptor(jwtService, blackList));
	}
	
	public void configureMessageBroker(MessageBrokerRegistry brokerRegistry) {
		brokerRegistry.setApplicationDestinationPrefixes("/app");
		brokerRegistry.enableSimpleBroker("/topic");
	}
}

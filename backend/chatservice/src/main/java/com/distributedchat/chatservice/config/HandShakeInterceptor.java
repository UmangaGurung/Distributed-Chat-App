package com.distributedchat.chatservice.config;

import java.util.Date;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

import com.distributedchat.chatservice.component.JWTService;
import com.distributedchat.chatservice.component.redis.RedisTokenBlackList;

import io.jsonwebtoken.Claims;

public class HandShakeInterceptor implements HandshakeInterceptor {
	
	private JWTService jwtService;
	private RedisTokenBlackList blackList;
	
	public HandShakeInterceptor(JWTService jwtService, RedisTokenBlackList blackList) {
		// TODO Auto-generated constructor stub
		this.jwtService= jwtService;
		this.blackList= blackList;
	}

	@Override
	public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler,
			Map<String, Object> attributes) throws Exception {
		// TODO Auto-generated method stub
		
		String token= extractTokenFromHeader(request);
		if (token != null) {
            System.out.println("Received token: " + token);
            
            Claims claims= jwtService.extractClaims(token); 
            
            String tokenId= claims.getId();
            
            if (blackList.isTokenBlackListed(tokenId)) {
            	response.setStatusCode(HttpStatus.UNAUTHORIZED);
            	return false;
            }
            
            if (!jwtService.ValidateToken(token)) {
            	response.setStatusCode(HttpStatus.UNAUTHORIZED);
            	return false;
            }           
            
            String userId= claims.getSubject();
            Date jwtExp= claims.getExpiration();
            
            attributes.put("userId", userId);
            attributes.put("exp", jwtExp.getTime());
            attributes.put("tokenId", tokenId);
        } else {
            System.out.println("No token received");
            attributes.put("userId", null);
            return false;
        }
        return true;
	}

	@Override
	public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler,
			Exception exception) {
		// TODO Auto-generated method stub
		System.out.println("WebSocket connection established");
		
		String ip = null;
		
		if (request instanceof ServletServerHttpRequest servletRequest) {
			ip= servletRequest.getServletRequest().getRemoteAddr();
		}
		
		System.out.println("Address: " + ip);
	}
	
	private String extractTokenFromHeader(ServerHttpRequest request) {
		List<String> authHeaders= request.getHeaders().get("Authorization");
		System.out.println(request.getHeaders());
		System.out.println(authHeaders);
		
	    if (authHeaders == null || authHeaders.isEmpty()) {
            return null;
        }
	    
	    String authHeader= authHeaders.get(0);
	    
	    return authHeader.substring(7);
	}
}

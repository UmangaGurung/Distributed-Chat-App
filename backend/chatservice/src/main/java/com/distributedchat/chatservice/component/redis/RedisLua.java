package com.distributedchat.chatservice.component.redis;

import java.util.List;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.RedisScript;
import org.springframework.stereotype.Component;


@Component
public class RedisLua {
	
	private RedisTemplate<String, String> redisTemplate;
	private RedisScript<String> redisScript;
	
	public RedisLua(
			@Qualifier("simpleRedisTemplate") RedisTemplate<String, String> redisTemplate,
			RedisScript<String> redisScript,
			RedisEventPublisher eventPublisher) {
		// TODO Auto-generated constructor stub
		this.redisTemplate= redisTemplate;
		this.redisScript= redisScript;
	}
	
	public String onTyped(String conversationId, String event, String userId) {
		System.out.println(conversationId+event+userId);
		
		String key= "typing:"+conversationId+":"+userId;
		
		List<String> keys= List.of(key);
	
 		String scriptResult=(String) redisTemplate.execute(redisScript, keys, event);
 		System.out.println(scriptResult);
 		
 		return scriptResult;
	}
}

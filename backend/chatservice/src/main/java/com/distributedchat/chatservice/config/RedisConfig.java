package com.distributedchat.chatservice.config;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.data.redis.core.script.RedisScript;
import org.springframework.data.redis.listener.ChannelTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import com.distributedchat.chatservice.component.redis.RedisEventSubscriber;
import com.distributedchat.chatservice.component.redis.RedisMessageSubscriber;
import com.distributedchat.chatservice.component.redis.RedisNewConversationEventSubscriber;
import com.distributedchat.chatservice.component.redis.RedisTokenSubscriber;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

@Configuration
public class RedisConfig {
	
		@Bean
		RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory){
			RedisTemplate<String, Object> template= new RedisTemplate<>();
			template.setConnectionFactory(connectionFactory);
			
			ObjectMapper mapper= new ObjectMapper();
			mapper.registerModule(new JavaTimeModule());
			mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
			
			GenericJackson2JsonRedisSerializer serializer= new GenericJackson2JsonRedisSerializer(mapper);
	        
	        template.setKeySerializer(new StringRedisSerializer());
	        template.setValueSerializer(serializer);
	        template.setHashKeySerializer(new StringRedisSerializer());
	        template.setHashValueSerializer(serializer);
			
			template.afterPropertiesSet();
			return template;
		}
		
		@Bean
		RedisMessageListenerContainer redisListenerContainer(
				RedisConnectionFactory connectionFactory,
				RedisMessageSubscriber redisMessageSubscriber,
				RedisTokenSubscriber redisTokenSubscriber,
				RedisEventSubscriber redisEventSubscriber,
				RedisNewConversationEventSubscriber conversationEvent) {
			RedisMessageListenerContainer redListenerContainer= new RedisMessageListenerContainer();
			redListenerContainer.setConnectionFactory(connectionFactory);
			redListenerContainer.addMessageListener(
					redisMessageSubscriber,
					new ChannelTopic("chat:messages")
			);
			
			redListenerContainer.addMessageListener(
					redisTokenSubscriber,
					new ChannelTopic("user:blackListedTokens")
			);
			
			redListenerContainer.addMessageListener(
					redisEventSubscriber,
					new ChannelTopic("chat:typing")
			);
			
			redListenerContainer.addMessageListener(
					conversationEvent,
					new ChannelTopic("chat:conversation")
					);
	
			return redListenerContainer;
		}
		
		@Bean("connectionDB2")
		LettuceConnectionFactory redisConnectionDB2(
				@Value("${spring.data.redis.host}") String host,
				@Value("${spring.data.redis.port}") int port,
				@Value("${spring.data.redis.password}") String password) {
			RedisStandaloneConfiguration configuration= new RedisStandaloneConfiguration();
			configuration.setHostName(host);
			configuration.setPort(port);
			configuration.setPassword(password);
			configuration.setDatabase(2);
			
			return new LettuceConnectionFactory(configuration);
		}
		
		@Bean("simpleRedisTemplate")
		RedisTemplate<String, String> simpleRedisTemplate(
				@Qualifier("connectionDB2")LettuceConnectionFactory connectionFactory){
			RedisTemplate<String, String> template= new RedisTemplate<>();
			template.setConnectionFactory(connectionFactory);
	        template.setKeySerializer(new StringRedisSerializer());
	        template.setValueSerializer(new StringRedisSerializer());
	        template.setHashKeySerializer(new StringRedisSerializer());
	        template.setHashValueSerializer(new StringRedisSerializer());
			
			template.afterPropertiesSet();
			return template;
		}
		
		@Bean
		RedisScript<String> isTypingIndicatorScript(){
			DefaultRedisScript<String> defaultRedisScript= new DefaultRedisScript<>();
			defaultRedisScript.setLocation(new ClassPathResource("typingevent.lua"));
			defaultRedisScript.setResultType(String.class);
			
			defaultRedisScript.afterPropertiesSet();
			return defaultRedisScript;
		}
}

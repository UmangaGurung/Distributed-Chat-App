package com.distributedchat.chatservice.component.redis;

import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import com.distributedchat.chatservice.component.UserGrpcClient;
import com.distributedchat.chatservice.model.dto.RedisUserInfoDTO;
import com.distributedchat.chatservice.model.dto.UserDetailGrpcDTO;

@Component
public class RedisCaching {

	private RedisTemplate<String, Object> redisTemplate;
	private UserGrpcClient client;
	
	private HashOperations<String, String, Object> hashOperations;
	private static final Duration TTL = Duration.ofMinutes(30);
	
	private static final Logger log= LoggerFactory.getLogger(RedisCaching.class);
	
	public RedisCaching(RedisTemplate<String, Object> redisTemplate,
			UserGrpcClient client) {
		// TODO Auto-generated constructor stub
		this.redisTemplate= redisTemplate;
		this.client= client;
		this.hashOperations= redisTemplate.opsForHash();
	}
	
	public List<UserDetailGrpcDTO> cacheListOfUserInfo(List<UUID> usersId){
		List<String> stringUsersId= usersId.stream()
				.map(userId -> userId.toString())
				.collect(Collectors.toList());
		
		RedisUserInfoDTO results= getListOfCacheUserInfo(stringUsersId);
		List<String> missingInfoIds= results.getUserIdList();
		System.out.println(missingInfoIds);
		if (!missingInfoIds.isEmpty()) {
			List<UserDetailGrpcDTO> missingInfos= new ArrayList<>();
			
			if (missingInfoIds.size()==1) {
				UUID userId= UUID.fromString(missingInfoIds.get(0));
				missingInfos.add(client.getUserInfo(userId));
			}else {
				missingInfos.addAll(client.getUserInfoList(missingInfoIds));
			}
			
			for (UserDetailGrpcDTO userInfo: missingInfos) {
				Map<String, Object> userMap= new HashMap<>();
				userMap.put("userId", userInfo.getUserId());
				userMap.put("name", userInfo.getUserName());
				userMap.put("photo", userInfo.getPhotoUrl());
				userMap.put("phone", userInfo.getPhoneNumber());
				
				String key= "user:"+userInfo.getUserId().toString();
				
				hashOperations.putAll(key, userMap);
				redisTemplate.expire(key, TTL);
			}
			
			results.getUserDetailsList().addAll(missingInfos);
		}

		return results.getUserDetailsList();
	}
	
	public UserDetailGrpcDTO cacheUserInfo(UUID userId) {
		UserDetailGrpcDTO result= getCacheUserInfo(userId.toString());
		
		if (result!=null) {
			return result;
		}
		
		log.info("Delegating call to UserService for details of sender: "+userId);
		UserDetailGrpcDTO userInfo= client.getUserInfo(userId);
		
		if (userInfo==null) {
			throw new IllegalArgumentException();
		}
		
		Map<String, Object> userMap= new HashMap<>();
		userMap.put("userId", userId.toString());
		userMap.put("name", userInfo.getUserName());
		userMap.put("photo", userInfo.getPhotoUrl());
		userMap.put("phone", userInfo.getPhoneNumber());
		
		String key= "user:"+userId.toString();
		
		hashOperations.putAll(key, userMap);
		redisTemplate.expire(key,TTL);
		
		return userInfo;
	}
	
	private UserDetailGrpcDTO getCacheUserInfo(String userId){
		String key= "user:"+userId;
		Map<String, Object> cached= hashOperations.entries(key);
		
		System.out.println("=== CACHE CHECK FOR: " + userId + " ===");
		System.out.println("Cache empty? " + cached.isEmpty());
		    
		if (cached==null || cached.isEmpty()) {
			return null;
		}
		
		UserDetailGrpcDTO detailGrpcDTO= new UserDetailGrpcDTO(
				UUID.fromString(cached.get("userId").toString()),
				cached.get("name").toString(),
				cached.get("photo").toString(),
				cached.get("phone").toString()
				);

		log.info("Found Details for user: {} in Cache", userId);
		System.out.println(cached);
		
		return detailGrpcDTO;
	}
	
	private RedisUserInfoDTO getListOfCacheUserInfo(List<String> usersId){
		String key= "user:";
		List<UserDetailGrpcDTO> userDetails= new ArrayList<>();
		List<String> missingUserInfos= new ArrayList<>();
		
		for (String userId: usersId) {
			Map<String, Object> cached= hashOperations.entries(key+userId);

			if (cached.isEmpty()) {
				log.info("Couldnt get info for user: "+userId);
				missingUserInfos.add(userId);
				continue;
			}
			
			log.info("Found info for user: "+userId);
			UserDetailGrpcDTO detailGrpcDTO= new UserDetailGrpcDTO( 
					UUID.fromString(cached.get("userId").toString()),
					cached.get("name").toString(),
					cached.get("photo").toString(),
					cached.get("phone").toString()
					);
			
			userDetails.add(detailGrpcDTO);
		}
		
		return new RedisUserInfoDTO(userDetails, missingUserInfos);
	}
}

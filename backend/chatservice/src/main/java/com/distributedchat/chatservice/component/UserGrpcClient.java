package com.distributedchat.chatservice.component;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Component;

import com.distributedchat.chatservice.model.dto.UserDetailGrpcDTO;

import net.devh.boot.grpc.client.inject.GrpcClient;

@Component
public class UserGrpcClient {
	
	@GrpcClient("userservice")
	private UserServiceGrpc.UserServiceBlockingStub userServiceBlockingStub;
	
	public boolean userExists(UUID userId) {
		UserIdRequest request= UserIdRequest.newBuilder()
				.setUserId(userId.toString())
				.build();
		
		UserExistsResponse response= userServiceBlockingStub.verifyUserExists(request);
		return response.getExists();
	}
	
	public UserDetailGrpcDTO getUserInfo(UUID userId) {
		String uid= userId.toString();
		UserIdRequest request= UserIdRequest.newBuilder()
				.setUserId(uid)
				.build();
		
		UserDetails response= userServiceBlockingStub.getUserDetails(request);
		
		String name= response.getUsername();
		String photo= response.getPhoto();
		String phone= response.getPhone();
		
		UserDetailGrpcDTO userDetails= new UserDetailGrpcDTO(userId, name, photo, phone);
		
		return userDetails;
	}
	
	public List<UserDetailGrpcDTO> getUserInfoList(List<String> userIds){
		UsersIdList request= UsersIdList.newBuilder()
				.addAllUserId(userIds)
				.build();
		
		System.out.println(request);
		
		UsersListWrapper response= userServiceBlockingStub.getUsersDetailList(request);
		
		List<UserInfo> userInfos= response.getUsersList();
		List<UserDetailGrpcDTO> detailsListDTO= new ArrayList<>();
		
		System.out.println(userInfos);
		
		for (UserInfo userInfo: userInfos) {
			detailsListDTO.add(
					new UserDetailGrpcDTO(
							UUID.fromString(userInfo.getUserId()),
							userInfo.getUsername(),
							userInfo.getPhoto(),
							userInfo.getPhone())
					);
		}
		
		return detailsListDTO;
	}
}

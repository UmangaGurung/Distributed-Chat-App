package com.distributedchat.chatservice.component;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Component;

import com.distributedchat.chatservice.component.UserServiceGrpc.UserServiceBlockingStub;
import com.distributedchat.chatservice.model.dto.UserDetailGrpcDTO;

import io.grpc.Metadata;
import io.grpc.stub.MetadataUtils;
import net.devh.boot.grpc.client.inject.GrpcClient;

@Component
public class UserGrpcClient {
	
	@GrpcClient("userservice")
	private UserServiceGrpc.UserServiceBlockingStub userServiceBlockingStub;
	
	private static final Metadata.Key<String> AUTHORIZATION_KEY= 
			Metadata.Key.of("Authorization", Metadata.ASCII_STRING_MARSHALLER);
	
	public boolean userExists(UUID userId, String token) {

		UserServiceBlockingStub stubWithHeader= getStubWithHeaders(token);
		
		UserIdRequest request= UserIdRequest.newBuilder()
				.setUserId(userId.toString())
				.build();
		
		UserExistsResponse response= stubWithHeader.verifyUserExists(request);
		return response.getExists();
	}
	
	public UserDetailGrpcDTO getUserInfo(UUID userId, String token) {
		String uid= userId.toString();
		
		UserServiceBlockingStub stubWithHeaders= getStubWithHeaders(token);
		
		UserIdRequest request= UserIdRequest.newBuilder()
				.setUserId(uid)
				.build();
		
		UserDetails response= stubWithHeaders.getUserDetails(request);
		
		String name= response.getUsername();
		String photo= response.getPhoto();
		String phone= response.getPhone();
		
		UserDetailGrpcDTO userDetails= new UserDetailGrpcDTO(userId, name, photo, phone);
		
		return userDetails;
	}
	
	public List<UserDetailGrpcDTO> getUserInfoList(List<String> userIds, String token){
		
		UserServiceBlockingStub stubWithHeaders= getStubWithHeaders(token);
		
		UsersIdList request= UsersIdList.newBuilder()
				.addAllUserId(userIds)
				.build();
		
		System.out.println(request);
		
		UsersListWrapper response= stubWithHeaders.getUsersDetailList(request);
		
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
	
	private UserServiceBlockingStub getStubWithHeaders(String token) {
		Metadata metadata= new Metadata();
		metadata.put(AUTHORIZATION_KEY, "Bearer "+token);
		
		return userServiceBlockingStub.withInterceptors(
				MetadataUtils.newAttachHeadersInterceptor(metadata)
				);
				
	}
}

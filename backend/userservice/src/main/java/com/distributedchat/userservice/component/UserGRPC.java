package com.distributedchat.userservice.component;

import java.util.UUID;
import java.util.stream.Collectors;
import java.util.ArrayList;
import java.util.List;

import com.distributedchat.userservice.model.dto.GRPCUserDetailsDTO;
import com.distributedchat.userservice.repository.UserDAO;

import io.grpc.stub.StreamObserver;
import net.devh.boot.grpc.server.service.GrpcService;

@GrpcService
public class UserGRPC extends UserServiceGrpc.UserServiceImplBase{
	
	UserDAO userDAO;
	
	public UserGRPC(UserDAO userDAO) {
		// TODO Auto-generated constructor stub
		this.userDAO= userDAO;
	}
	
	@Override
	public void verifyUserExists(UserIdRequest request, 
			StreamObserver<UserExistsResponse> responseObserver) {
		String userIdString= request.getUserId();
		UUID userId= UUID.fromString(userIdString);
		
		boolean exists= userDAO.doesUserExistsByIdGrpc(userId);
		
		UserExistsResponse response= UserExistsResponse.newBuilder()
				.setExists(exists)
				.build();
		
		responseObserver.onNext(response);
		responseObserver.onCompleted();
	}
	
	@Override
	public void getUserDetails(UserIdRequest request, 
			StreamObserver<UserDetails> responseObserver) {
		String userIdString= request.getUserId();
		UUID userId= UUID.fromString(userIdString);
		
		GRPCUserDetailsDTO userInfo= userDAO.getGrpcUserInfo(userId);
		
		if (userInfo.getPhone()==null || userInfo.getPhone().isEmpty()) {
			userInfo.setPhone("9DUMMYTEST12");
		}
		
		UserDetails respone= UserDetails.newBuilder()
				.setUsername(userInfo.getFullname())
				.setPhoto(userInfo.getPhoto())
				.setPhone(userInfo.getPhone())
				.build();
		
		responseObserver.onNext(respone);
		responseObserver.onCompleted();
	}
	
	@Override
	public void getUsersDetailList(UsersIdList request, 
			StreamObserver<UsersListWrapper> responseObserver) {
		List<String> userIds= request.getUserIdList();
		List<UUID> userUUIDS= userIds
				.stream()
				.map(uid->UUID.fromString(uid))
				.collect(Collectors.toList());
		
		List<GRPCUserDetailsDTO> userDetails= userDAO.getGrpcUserInfoList(userUUIDS);
		List<UserInfo> userInfoList= new ArrayList<>();
		
		for (GRPCUserDetailsDTO userDetail: userDetails) {
			UserInfo userInfo= UserInfo.newBuilder()
					.setUserId(userDetail.getUserId().get())
					.setUsername(userDetail.getFullname())
					.setPhone(userDetail.getPhone())
					.setPhoto(userDetail.getPhoto())
					.build();
			
			userInfoList.add(userInfo);
		}
		
		UsersListWrapper response= UsersListWrapper.newBuilder()
				.addAllUsers(userInfoList)
				.build();
		
		responseObserver.onNext(response);
		responseObserver.onCompleted();
	}
}

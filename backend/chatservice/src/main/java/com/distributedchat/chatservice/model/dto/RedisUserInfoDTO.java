package com.distributedchat.chatservice.model.dto;

import java.util.List;

public class RedisUserInfoDTO {
	private List<UserDetailGrpcDTO> userDetailsList;
	private List<String> userIdList;
	
	public RedisUserInfoDTO(List<UserDetailGrpcDTO> userDetailsList, List<String> userIdList) {
		super();
		this.userDetailsList = userDetailsList;
		this.userIdList = userIdList;
	}

	public List<UserDetailGrpcDTO> getUserDetailsList() {
		return userDetailsList;
	}

	public void setUserDetailsList(List<UserDetailGrpcDTO> userDetailsList) {
		this.userDetailsList = userDetailsList;
	}

	public List<String> getUserIdList() {
		return userIdList;
	}

	public void setUserIdList(List<String> userIdList) {
		this.userIdList = userIdList;
	}
}

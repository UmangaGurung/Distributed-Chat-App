package com.distributedchat.chatservice.model.dto;

import java.util.UUID;

public class UserDetailGrpcDTO {
	private UUID userId;
	private String userName;
	private String photoUrl;
	private String phoneNumber;
	
	public UserDetailGrpcDTO() {
		// TODO Auto-generated constructor stub
	}
	
	public UserDetailGrpcDTO(UUID userId, String userName, String photoUrl, String phoneNumber) {
		super();
		this.userId = userId;
		this.userName = userName;
		this.photoUrl = photoUrl;
		this.phoneNumber = phoneNumber;
	}

	public UUID getUserId() {
		return userId;
	}

	public void setUserId(UUID userId) {
		this.userId = userId;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getPhotoUrl() {
		return photoUrl;
	}

	public void setPhotoUrl(String photoUrl) {
		this.photoUrl = photoUrl;
	}

	public String getPhoneNumber() {
		return phoneNumber;
	}

	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}
}

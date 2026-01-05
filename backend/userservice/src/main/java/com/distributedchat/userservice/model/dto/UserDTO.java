package com.distributedchat.userservice.model.dto;

import java.util.UUID;

public class UserDTO {
	
	private UUID userId;
	private String email;
	private String fullname;
	private String phoneNumber;
	private String imageURL;
	private String loginType;
	
	public UserDTO() {
		
	}
	
	public UserDTO(UUID userId, String email, String fullname, String phoneNumber, String imageURL, String loginType) {
		super();
		this.userId = userId;
		this.email = email;
		this.fullname = fullname;
		this.phoneNumber = phoneNumber;
		this.imageURL = imageURL;
		this.loginType = loginType;
	}

	public String getLoginType() {
		return loginType;
	}

	public void setLoginType(String loginType) {
		this.loginType = loginType;
	}

	public UUID getUserId() {
		return userId;
	}

	public void setUserId(UUID userId) {
		this.userId = userId;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getFullname() {
		return fullname;
	}

	public void setFullname(String fullname) {
		this.fullname = fullname;
	}

	public String getPhoneNumber() {
		return phoneNumber;
	}

	public void setPhoneNumber(String phoneNumber) {
		this.phoneNumber = phoneNumber;
	}

	public String getImageURL() {
		return imageURL;
	}

	public void setImageURL(String imageURL) {
		this.imageURL = imageURL;
	}
}

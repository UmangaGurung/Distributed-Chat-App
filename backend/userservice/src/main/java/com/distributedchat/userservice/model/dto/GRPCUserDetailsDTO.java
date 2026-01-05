package com.distributedchat.userservice.model.dto;

import java.util.Optional;

public class GRPCUserDetailsDTO {
	
	private Optional<String> userId;
	private String fullname;
	private String photo;
	private String phone;
	
	public GRPCUserDetailsDTO(Optional<String> userId, String fullname, String photo, String phone) {
		super();
		this.userId = userId;
		this.fullname = fullname;
		this.photo = photo;
		this.phone = phone;
	}

	public Optional<String> getUserId() {
		return userId;
	}
	
	public void setUserId(Optional<String> userId) {
		this.userId = userId;
	}

	public String getFullname() {
		return fullname;
	}

	public void setFullname(String fullname) {
		this.fullname = fullname;
	}

	public String getPhoto() {
		return photo;
	}

	public void setPhoto(String photo) {
		this.photo = photo;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}
}

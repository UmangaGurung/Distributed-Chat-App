package com.distributedchat.userservice.model.dto;

import java.util.UUID;

public class UserListDTO {
	
	private UUID uid;
	private String email;
	private String fullname;
	private String imagePath;
	private String phone;
	
	public UserListDTO() {
		// TODO Auto-generated constructor stub
	}
	
	public UserListDTO(UUID uid, String email, String fullname, String imagePath, String phone) {
		super();
		this.uid = uid;
		this.email = email;
		this.fullname = fullname;
		this.imagePath = imagePath;
		this.phone = phone;
	}

	public UUID getUid() {
		return uid;
	}
	public void setUid(UUID uid) {
		this.uid = uid;
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
	public String getImagePath() {
		return imagePath;
	}
	public void setImagePath(String imagePath) {
		this.imagePath = imagePath;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
}

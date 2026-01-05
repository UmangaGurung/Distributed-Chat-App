package com.distributedchat.userservice.model.dto;

import com.sun.istack.NotNull;

import jakarta.validation.constraints.Email;

public class GoogleLoginDTO {
	
	@NotNull
	@Email
	private String email;
	
	@NotNull
	private String tokenid;
	
	private String photo;
	
	@NotNull
	private String name;

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getTokenid() {
		return tokenid;
	}

	public void setTokenid(String tokenid) {
		this.tokenid = tokenid;
	}

	public String getPhoto() {
		return photo;
	}

	public void setPhoto(String photo) {
		this.photo = photo;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Override
	public String toString() {
		return "GoogleLoginDTO [email=" + email + ", tokenid=" + tokenid + ", photo=" + photo + ", name=" + name + "]";
	}
	
}

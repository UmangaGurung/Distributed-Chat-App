package com.distributedchat.userservice.model.dto;

import com.sun.istack.NotNull;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

public class UserRegistrationDTO {
	
	@NotNull
	@Email
	private String email;
	
	@NotNull
	@Size(min=4, max = 30)
	private String fullname;
	
	@NotNull 
	private String password;
	
	@NotNull
	private String phone;
	
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
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	
}

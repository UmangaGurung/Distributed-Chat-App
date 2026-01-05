package com.distributedchat.userservice.model.dto;

public class AddPhoneNumberDTO {
	
	private String loginType;
	private String phone;
	
	public AddPhoneNumberDTO() {
		// TODO Auto-generated constructor stub
	}

	public AddPhoneNumberDTO(String loginType, String phone) {
		super();
		this.loginType = loginType;
		this.phone = phone;
	}

	public String getLoginType() {
		return loginType;
	}

	public void setLoginType(String loginType) {
		this.loginType = loginType;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}
}

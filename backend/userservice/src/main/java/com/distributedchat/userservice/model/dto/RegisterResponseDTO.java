package com.distributedchat.userservice.model.dto;

public class RegisterResponseDTO {
	
	private UserDTO userDto;
	private RegisterStatus status;
	private String response;
	
	public RegisterResponseDTO(UserDTO userDto, RegisterStatus status, String response) {
		super();
		this.userDto= userDto;
		this.status= status;
		this.response= response;
	}
		
	public UserDTO getUserDto() {
		return userDto;
	}

	public void setUserDto(UserDTO userDto) {
		this.userDto = userDto;
	}


	public RegisterStatus getStatus() {
		return status;
	}

	public void setStatus(RegisterStatus status) {
		this.status = status;
	}

	public String getResponse() {
		return response;
	}

	public void setResponse(String response) {
		this.response = response;
	}
}

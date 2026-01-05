package com.distributedchat.userservice.model.dto;

public class GoogleResponseDTO {
	private RegisterResponseDTO responsedto;
	private String token;
	
	public GoogleResponseDTO(RegisterResponseDTO responsedto, String token) {
		super();
		this.responsedto = responsedto;
		this.token = token;
	}

	public RegisterResponseDTO getResponsedto() {
		return responsedto;
	}

	public void setResponsedto(RegisterResponseDTO responsedto) {
		this.responsedto = responsedto;
	}

	public String getToken() {
		return token;
	}

	public void setToken(String token) {
		this.token = token;
	}
}

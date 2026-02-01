package com.distributedchat.userservice.model.dto;

public enum RegisterStatus {
	ACCOUNT_CREATED_GOOGLE,
	ACCOUNT_CREATED_APP,
	ACCOUNT_EXISTS_APP,
	ACCOUNT_EXISTS_GOOGLE,
	GOOGLE_LOGIN,
	FAILED
}

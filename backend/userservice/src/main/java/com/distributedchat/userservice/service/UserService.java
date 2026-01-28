package com.distributedchat.userservice.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.distributedchat.userservice.model.dto.AddPhoneNumberDTO;
import com.distributedchat.userservice.model.dto.GoogleLoginDTO;
import com.distributedchat.userservice.model.dto.GoogleResponseDTO;
import com.distributedchat.userservice.model.dto.ParticipantListDTO;
import com.distributedchat.userservice.model.dto.RegisterResponseDTO;
import com.distributedchat.userservice.model.dto.UserDTO;
import com.distributedchat.userservice.model.dto.UserListDTO;
import com.distributedchat.userservice.model.dto.UserLoginDTO;
import com.distributedchat.userservice.model.dto.UserRegistrationDTO;

public interface UserService {
	
	public RegisterResponseDTO registerNewUser(UserRegistrationDTO registerdto, MultipartFile file);
	
	public String loginUser(UserLoginDTO logindto);
	
	public GoogleResponseDTO googleLogin(GoogleLoginDTO googledto);
	
	public List<UserListDTO> getUsers(ParticipantListDTO participantListDTO);

	public String addPhoneNumber(String uid, AddPhoneNumberDTO addPhone, String oldToken);

	public void logoutUser(String token);

	public UserDTO findUserByPhone(String uid, String query);
}

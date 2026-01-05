package com.distributedchat.userservice.repository;

import java.util.List;
import java.util.UUID;

import com.distributedchat.userservice.model.dto.GRPCUserDetailsDTO;
import com.distributedchat.userservice.model.dto.RegisterResponseDTO;
import com.distributedchat.userservice.model.dto.UserDTO;

public interface UserDAO {
	
	public RegisterResponseDTO registerNewUser(String email, String fullname, String password, String phone, String imagepath, String logintype);

	public UserDTO loginUser(String email, String password);
	
	public List<UserDTO> getUsers(UUID uid);

	public boolean doesUserExistsByIdGrpc(UUID userId);

	public GRPCUserDetailsDTO getGrpcUserInfo(UUID userId);
	
	public List<GRPCUserDetailsDTO> getGrpcUserInfoList(List<UUID> userIds);

	public UserDTO addUserPhone(UUID userId, String phone);

	public UserDTO findUserByPhone(UUID userId, String query);
}

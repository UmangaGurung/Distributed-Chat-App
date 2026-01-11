package com.distributedchat.userservice.repository;

import java.util.List;
import java.util.Set;
import java.util.UUID;

import com.distributedchat.userservice.model.dto.GRPCUserDetailsDTO;
import com.distributedchat.userservice.model.dto.RegisterResponseDTO;
import com.distributedchat.userservice.model.dto.UserDTO;
import com.distributedchat.userservice.model.dto.UserListDTO;

public interface UserDAO {
	
	public RegisterResponseDTO registerNewUser(String email, String fullname, String password, String phone, String imagepath, String logintype);

	public UserDTO loginUser(String email, String password);
	
	public List<UserListDTO> getUsers(Set<UUID> userIdList);

	public boolean doesUserExistsByIdGrpc(UUID userId);

	public GRPCUserDetailsDTO getGrpcUserInfo(UUID userId);
	
	public List<GRPCUserDetailsDTO> getGrpcUserInfoList(List<UUID> userIds);

	public UserDTO addUserPhone(UUID userId, String phone);

	public UserDTO findUserByPhone(UUID userId, String query);
}

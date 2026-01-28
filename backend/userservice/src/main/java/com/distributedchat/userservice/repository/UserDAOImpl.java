package com.distributedchat.userservice.repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Repository;

import com.distributedchat.userservice.model.entity.User;
import com.distributedchat.userservice.model.dto.GRPCUserDetailsDTO;
import com.distributedchat.userservice.model.dto.RegisterResponseDTO;
import com.distributedchat.userservice.model.dto.RegisterStatus;
import com.distributedchat.userservice.model.dto.UserDTO;
import com.distributedchat.userservice.model.dto.UserListDTO;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;

@Repository
public class UserDAOImpl implements UserDAO{

	EntityManager entitymanager;
	BCryptPasswordEncoder passwordEncoder;
	
	public UserDAOImpl(EntityManager entitymanager, BCryptPasswordEncoder passwordEncoder) {
		// TODO Auto-generated constructor stub
		this.entitymanager= entitymanager;
		this.passwordEncoder= passwordEncoder;
	}

	@Override
	public RegisterResponseDTO registerNewUser(String email, String fullname, String password,
		String phone, String imagepath, String logintype) {
		// TODO Auto-generated method stub		
		TypedQuery<User> query= entitymanager.createQuery(
				"SELECT u FROM User u WHERE u.email=:email", User.class)
				.setParameter("email", email);
		try {
			User user= query.getSingleResult();
			
			UserDTO userDTO= modifiedUserDetails(user);
			
			if (logintype.equals("APPLOGIN")) { 
				if (user.getLogintype().equals("APPLOGIN")) {
					return new RegisterResponseDTO(
							userDTO,
							RegisterStatus.ACCOUNT_EXISTS_APP,
							"Account already registered through APP");
				}else if (user.getLogintype().equals("GOOGLE")) {
					return new RegisterResponseDTO(
							userDTO,
							RegisterStatus.ACCOUNT_EXISTS_GOOGLE,
							"Account already registered through GOOGLE");
				}
			}else if (logintype.equals("GOOGLE")) {
				if (user.getLogintype().equals("APPLOGIN")) {
					return new RegisterResponseDTO(
							userDTO,
							RegisterStatus.ACCOUNT_EXISTS_APP,
							"Email already linked through APP registration");
				}else if (user.getLogintype().equals("GOOGLE")) {
					return new RegisterResponseDTO(
							userDTO,
							RegisterStatus.GOOGLE_LOGIN,
							"Linked email, loggin in...");
				}
			}
		}catch (NoResultException e) {
			User user= new User(email, password, fullname, phone, logintype, imagepath);
			
			entitymanager.persist(user);
			
			UserDTO userDTO= modifiedUserDetails(user);
			
			return new RegisterResponseDTO(
					userDTO,
					RegisterStatus.ACCOUNT_CREATED,
					"Account Created");	
		}
		return new RegisterResponseDTO(null, RegisterStatus.FAILED, "FAILED");	
	}

	@Override
	public UserDTO loginUser(String email, String password) {
		// TODO Auto-generated method stub
		System.out.println(email+", "+password);
		
		TypedQuery<User> query= entitymanager.createQuery(
				"SELECT u FROM User u WHERE u.email=:email", User.class)
				.setParameter("email", email);
		
		User user= query.getSingleResult();
		
		if (passwordEncoder.matches(password, user.getPassword())) {
			UserDTO userDTO= modifiedUserDetails(user);
			
			return userDTO;
		}
		
		return null;
	}

	@Override
	public List<UserListDTO> getUsers(Set<UUID> userIdList) {
		// TODO Auto-generated method stub
		TypedQuery<User> query= entitymanager.createQuery(
				"SELECT u FROM User u WHERE u.userid IN :userIdList", User.class)
				.setParameter("userIdList", userIdList);
		
		List<User> userList= query.getResultList();
		
		List<UserListDTO> userListDTO= new ArrayList<>();
				
		for (User user: userList) {
			String phone;
			if (user.getPhonenumber()==null) {
				phone="N/A";
			}else {
				phone= user.getPhonenumber();
			}
			UserListDTO userDTO= new UserListDTO(
					user.getUserid(), 
					user.getFullname(), 
					user.getProfileimagepath(), 
					phone
					);
			userListDTO.add(userDTO);
		}
		
		return userListDTO;
	}

	@Override
	public boolean doesUserExistsByIdGrpc(UUID userId) {
		// TODO Auto-generated method stub
		User user= entitymanager.find(User.class, userId);
		
		if (user==null) {
			return false;
		}
		return true;
	}

	@Override
	public GRPCUserDetailsDTO getGrpcUserInfo(UUID userId) {
		// TODO Auto-generated method stub
		User user= entitymanager.find(User.class, userId);
		
		GRPCUserDetailsDTO userDetails= new GRPCUserDetailsDTO(
				null, user.getFullname(), user.getProfileimagepath(), user.getPhonenumber());
		
		return userDetails;
	}
	
	@Override
	public List<GRPCUserDetailsDTO> getGrpcUserInfoList(List<UUID> userIds) {
		// TODO Auto-generated method stub
		TypedQuery<User> query= entitymanager.createQuery(
				"SELECT u FROM User u WHERE u.userid IN :ids", User.class)
				.setParameter("ids", userIds);
		
		List<User> users= query.getResultList();
		List<GRPCUserDetailsDTO> userDetails= new ArrayList<>();
		
		for (User user: users) {
			if (user.getPhonenumber()==null){
				user.setPhonenumber("N/A");
			}
			userDetails.add(
					new GRPCUserDetailsDTO(
							Optional.of(user.getUserid().toString()), 
							user.getFullname(), 
							user.getProfileimagepath(),
							user.getPhonenumber())
					);
		}
		return userDetails;
	}

	@Override
	public UserDTO addUserPhone(UUID userId, String phone) {
		// TODO Auto-generated method stub
		User user= entitymanager.find(User.class, userId);
		
		user.setPhonenumber(phone);
		
		entitymanager.persist(user);
		
		return modifiedUserDetails(user);
	}	

	@Override
	public UserDTO findUserByPhone(UUID userId, String query) {
		// TODO Auto-generated method stub
		User user= entitymanager.find(User.class, userId);
		
		if (user!=null) {
			TypedQuery<User> userQuery= entitymanager.createQuery(
					"SELECT u FROM User u WHERE u.phonenumber=:query", User.class)
					.setParameter("query", query);
			
			User result= userQuery.getSingleResult();
			
			if (!result.getPhonenumber().equals(user.getPhonenumber())) {
				return modifiedUserDetails(result);
			}
		}
		return null;
	}
	
	public UserDTO modifiedUserDetails(User user) {
		return new UserDTO(
				user.getUserid(),
				user.getEmail(),
				user.getFullname(),
				user.getPhonenumber(),
				user.getProfileimagepath(),
				user.getLogintype()
				);
	}
}

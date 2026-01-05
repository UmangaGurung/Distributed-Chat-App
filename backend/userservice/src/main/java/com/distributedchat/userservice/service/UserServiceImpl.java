package com.distributedchat.userservice.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.distributedchat.userservice.component.RedisTokenBlackList;
import com.distributedchat.userservice.component.RedisTokenPublisher;
import com.distributedchat.userservice.model.dto.AddPhoneNumberDTO;
import com.distributedchat.userservice.model.dto.GoogleLoginDTO;
import com.distributedchat.userservice.model.dto.GoogleResponseDTO;
import com.distributedchat.userservice.model.dto.RegisterResponseDTO;
import com.distributedchat.userservice.model.dto.RegisterStatus;
import com.distributedchat.userservice.model.dto.UserDTO;
import com.distributedchat.userservice.model.dto.UserLoginDTO;
import com.distributedchat.userservice.model.dto.UserRegistrationDTO;
import com.distributedchat.userservice.repository.UserDAO;
import com.nimbusds.jwt.JWTClaimsSet;

import io.jsonwebtoken.lang.Collections;
import jakarta.transaction.Transactional;

@Service
@Transactional
public class UserServiceImpl implements UserService{

	UserDAO userdao;
	JWTService jwtservice;
	GoogleJWTService googleJWTService;
	BCryptPasswordEncoder passwordEncoder;
	RedisTokenBlackList blackList;
	RedisTokenPublisher publisher;

	public UserServiceImpl(
			UserDAO userdao, 
			BCryptPasswordEncoder passwordEncoder, 
			JWTService jwtservice, 
			GoogleJWTService googleJWTService,
			RedisTokenBlackList blackList,
			RedisTokenPublisher publisher) {
		// TODO Auto-generated constructor stub
		this.userdao= userdao;
		this.passwordEncoder= passwordEncoder;
		this.jwtservice= jwtservice;
		this.googleJWTService= googleJWTService;
		this.blackList= blackList;
		this.publisher= publisher;
	}
	
	@Override
	public RegisterResponseDTO registerNewUser(UserRegistrationDTO registerdto, MultipartFile file) {
		// TODO Auto-generated method stub
			String email= registerdto.getEmail();
			String fullname= registerdto.getFullname();
			String password= registerdto.getPassword();
			String phone= registerdto.getPhone();	
			
			String hashpassword= passwordEncoder.encode(password);
			
			String filename= file.getOriginalFilename().replaceAll("\\\\", "/");
			Path uploadDir= Paths.get("/var/mnt/data/SpringToolSuite/projects/distributedchat/photos");
			
			if (!Files.exists(uploadDir)) {
				try {
					Files.createDirectories(uploadDir);
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			
			Path filepath= uploadDir.resolve(filename);
			try {
				Files.copy(file.getInputStream(), filepath, StandardCopyOption.REPLACE_EXISTING);
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			String imagepath= filepath.toString();
			
			RegisterResponseDTO responseDTO= userdao.registerNewUser(
					email, fullname, hashpassword, phone, imagepath, "APPLOGIN");
			System.out.println(responseDTO.getUserDto());
			System.out.println(responseDTO.getResponse());
			System.out.println(responseDTO.getStatus());
			
			return responseDTO;
	}

	@Override
	public String loginUser(UserLoginDTO logindto) {
		// TODO Auto-generated method stub
		String email= logindto.getEmail();
		String password= logindto.getPassword();
		
		UserDTO userDTO= userdao.loginUser(email, password);
		
		if (userDTO==null) {
			throw new BadCredentialsException("Invalid Credentials");
		}
		
		String token= jwtservice.generateToken(userDTO);
		
		if(token.equals("") || token==null) {
			throw new IllegalStateException("Token failed to generate");
		}
		
		return token;
	}

	@Override
	public GoogleResponseDTO googleLogin(GoogleLoginDTO googledto) {
		// TODO Auto-generated method stub
		String googletoken= googledto.getTokenid();
		
		try {
			JWTClaimsSet claimset= googleJWTService.validateGoogleToken(googletoken);
			
			Map<String, Object> all= claimset.getClaims();
			for (Map.Entry<String, Object> entry : all.entrySet()) {
				System.out.println(entry.getKey()+": "+entry.getValue());
			}
			
			String fullname= googledto.getName();
			String photoUrl= googledto.getPhoto();
			String email= googledto.getEmail();
			
			RegisterResponseDTO register= userdao.registerNewUser(
					email, fullname, null, null, photoUrl, "GOOGLE");
			
			if (register.getStatus()==RegisterStatus.ACCOUNT_EXISTS_APP) {
				return new GoogleResponseDTO(register, null);
			}
			
			String token= jwtservice.generateToken(register.getUserDto());
			System.out.println("token= "+token);
			
			return new GoogleResponseDTO(register, token);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new GoogleResponseDTO(null, "FAILED");
	}

	@Override
	public List<UserDTO> getUsers(String uid) {
		// TODO Auto-generated method stub
		if (uid==null || uid.equals("")) {
			return Collections.emptyList();
		}
		
		UUID userid= UUID.fromString(uid);
		
		return userdao.getUsers(userid);
	}
	
	//token blacklisting is happening before db operation finalizes
	@Override
	public String addPhoneNumber(String uid, AddPhoneNumberDTO addPhone, String oldToken) {
		// TODO Auto-generated method stub
		UUID userId= UUID.fromString(uid);
		String phone= addPhone.getPhone();
		String loginType= addPhone.getLoginType();
		
		if (!loginType.equals("GOOGLE")) {
			throw new SecurityException("Invalid");
		}
		
		UserDTO userDto= userdao.addUserPhone(userId, phone);
		
		String token= jwtservice.generateToken(userDto);
		blackList.blackListToken(oldToken);
		
		System.out.println("New Token: "+ token);
		
		return token;
	}

	@Override
	public void logoutUser(String token) {
		// TODO Auto-generated method stub
		if (token==null || token.isEmpty()) {
			throw new IllegalArgumentException("Value cant be null");
		}
		
		blackList.blackListToken(token);
		publisher.publishBlackListedTokens(token);
	}

	@Override
	public UserDTO findUserByPhone(String uid, String query) {
		// TODO Auto-generated method stub
		
		if (uid==null || uid.equals("") || query.length()!=10) {
			throw new IllegalArgumentException("Empty values");
		}
		
		UUID userId= UUID.fromString(uid);
		
		return userdao.findUserByPhone(userId, query);
	}
}

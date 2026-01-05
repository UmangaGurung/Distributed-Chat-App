package com.distributedchat.userservice.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.distributedchat.userservice.model.dto.AddPhoneNumberDTO;
import com.distributedchat.userservice.model.dto.GoogleLoginDTO;
import com.distributedchat.userservice.model.dto.GoogleResponseDTO;
import com.distributedchat.userservice.model.dto.RegisterResponseDTO;
import com.distributedchat.userservice.model.dto.UserDTO;
import com.distributedchat.userservice.model.dto.UserLoginDTO;
import com.distributedchat.userservice.model.dto.UserRegistrationDTO;
import com.distributedchat.userservice.service.JWTService;
import com.distributedchat.userservice.service.RedisService;
import com.distributedchat.userservice.service.UserService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/users")
public class UserController {
	
	UserService userservice;
	RedisService redisservice;
	JWTService jwtService;
	
	public UserController(UserService userservice, RedisService redisservice, JWTService jwtService) {
		// TODO Auto-generated constructor stub
		this.userservice= userservice;
		this.redisservice= redisservice;
		this.jwtService= jwtService;
	}
	
	@PostMapping("/signup")
	public ResponseEntity<Map<String, String>> signupUser(@ModelAttribute @Valid UserRegistrationDTO registerdto,
			@RequestParam("profilepicture") MultipartFile file){
	
		RegisterResponseDTO data= userservice.registerNewUser(registerdto, file);
		Map<String, String> response= new HashMap<>();
		response.put("message", data.getResponse());
		response.put("status", data.getStatus().toString());
		
		System.out.println(response);
		return ResponseEntity.ok(response);
	}
	
	@PostMapping("/login")
	public ResponseEntity<Map<String,String>> loginUser(@RequestBody @Valid UserLoginDTO logindto){
		
		String token= userservice.loginUser(logindto);
		
		Map<String, String> response= new HashMap<>();
		response.put("token", token);
		
		return ResponseEntity.ok(response);
	}
		
	@PostMapping("/google/auth/token")
	public ResponseEntity<Map<String, String>> googleLogin(
			@RequestBody @Valid GoogleLoginDTO googledto){
		
		System.out.println(googledto);
		
		GoogleResponseDTO data= userservice.googleLogin(googledto);
		
		Map<String, String> respone= new HashMap<>();
		respone.put("token", data.getToken());
		respone.put("status", data.getResponsedto().getStatus().toString());
		respone.put("message", data.getResponsedto().getResponse());
		
		System.out.println(respone);
		return ResponseEntity.ok(respone);
	}
	
	@GetMapping("/allusers")
	public ResponseEntity<Map<String, Object>> getUsers(){
		String uid= SecurityContextHolder.getContext()
				.getAuthentication()
				.getPrincipal()
				.toString();
		
		List<UserDTO> users= userservice.getUsers(uid);
		
		Map<String, Object> response= new HashMap<>();
		response.put("users", users);
		
		return ResponseEntity.status(HttpStatus.OK).body(response);
	}
	
	@PatchMapping("/addphone")
	public ResponseEntity<Map<String, String>> addPhoneNumber(
			@RequestBody AddPhoneNumberDTO addPhone,
			@RequestHeader("Authorization") String authHeader){
		String uid= SecurityContextHolder.getContext()
				.getAuthentication()
				.getPrincipal()
				.toString();
		
		String oldToken= authHeader.substring(7);
		System.out.println("/addphone: "+ oldToken);
		
		String token= userservice.addPhoneNumber(uid, addPhone, oldToken);
		
		Map<String, String> response= new HashMap<>();
		response.put("token", token);
		
		return ResponseEntity.status(HttpStatus.OK).body(response);
	}
	
	@GetMapping("/phone")
	public ResponseEntity<?> findUser(
			@RequestParam(name = "search_query", required = true) String query){
		String uid= SecurityContextHolder.getContext()
				.getAuthentication()
				.getPrincipal()
				.toString();
		
		UserDTO user= userservice.findUserByPhone(uid, query);
		System.out.println("found search result:"+ user.getPhoneNumber());
		System.out.println("found search result:"+ user.getFullname());
		Map<String, Object> response= new HashMap<>();
		response.put("result", user);
		
		return ResponseEntity.status(HttpStatus.OK).body(response);
	}
	
	@PostMapping("/logout")
	public ResponseEntity<?> logoutUser(
			@RequestHeader("Authorization") String authHeader){
		String token= authHeader.substring(7);
		System.out.println("----Logout:---- "+ token);
		
		userservice.logoutUser(token);
		
		return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
	}
}

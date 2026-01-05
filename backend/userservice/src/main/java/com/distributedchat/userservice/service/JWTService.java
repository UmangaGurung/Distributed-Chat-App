package com.distributedchat.userservice.service;

import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.distributedchat.userservice.model.dto.UserDTO;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.security.Keys;

@Service
public class JWTService {
	
	private final String key;
	
	public JWTService(@Value("${jwt.secretkey}") String key) {
		// TODO Auto-generated constructor stub
		this.key= key;
	}
	
	public String generateToken(UserDTO userDto) {
		return Jwts.builder()
				.subject(userDto.getUserId().toString())
				.id(UUID.randomUUID().toString())
				.claim("email", userDto.getEmail())
				.claim("fullname", userDto.getFullname())
				.claim("phone", userDto.getPhoneNumber())
				.claim("imagepath", userDto.getImageURL())
				.claim("loginType", userDto.getLoginType())
				.issuedAt(new Date())
				.expiration(new Date(System.currentTimeMillis() + 3600000)) //3600000 1- hr
				.signWith(secretKey(), Jwts.SIG.HS512)
				.compact();				
	}
	
	public SecretKey secretKey() {
		byte[] keybytes= key.getBytes(StandardCharsets.UTF_8);
		return Keys.hmacShaKeyFor(keybytes);
	}
	
	public Claims extractClaims(String token) {
		return Jwts.parser()
				.verifyWith(secretKey())
				.build()
				.parseSignedClaims(token)
				.getPayload();
	}
	
	public boolean ValidateToken(String token) {
		try{
			Claims claims= extractClaims(token);
		
			if (claims.getIssuedAt().after(new Date())) {
				return false;
			}
		
			if(claims.getExpiration().before(new Date())) {
				return false;
			}
		
			if (claims.getSubject()==null || claims.getSubject().isEmpty()) {
				return false;
			}
		
			return true;
		}catch(ExpiredJwtException e) {
			e.printStackTrace();
			return false;
		}catch (MalformedJwtException e) {
			e.printStackTrace();
			return false;
		}catch (IllegalArgumentException e) {
			e.printStackTrace();
			return false;
		}catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public String getUserId(String token) {
		String uid= extractClaims(token).getSubject();
		if (uid==null || uid.equals("")) {
			return null;
		}
		return uid;
	}
}

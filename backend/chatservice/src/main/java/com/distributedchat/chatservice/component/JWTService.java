package com.distributedchat.chatservice.component;

import java.nio.charset.StandardCharsets;
import java.util.Date;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.security.Keys;

@Component
public class JWTService {
	
	private final String key;
	
	public JWTService(@Value("${jwt.secretkey}") String key) {
		// TODO Auto-generated constructor stub
		this.key= key;
		System.out.println(key);
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
		if (token==null) {
			return false;
		}
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
	
	//reminder to add a method to invalidate token after logout
}

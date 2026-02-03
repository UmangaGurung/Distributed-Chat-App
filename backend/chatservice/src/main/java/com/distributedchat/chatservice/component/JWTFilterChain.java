package com.distributedchat.chatservice.component;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.distributedchat.chatservice.component.redis.RedisTokenBlackList;

import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class JWTFilterChain extends OncePerRequestFilter{
	
	private JWTService jwtService;
	private RedisTokenBlackList blackList;
	
	public JWTFilterChain(JWTService jwtService, RedisTokenBlackList blackList) {
		// TODO Auto-generated constructor stub
		this.jwtService= jwtService;
		this.blackList= blackList;
	}

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		String authHeader= request.getHeader("Authorization");
	
		if (authHeader!=null) {
			String token= authHeader.substring(7);
			Claims claims= jwtService.extractClaims(token);
			String tokenId= claims.getId();
			
			if (blackList.isTokenBlackListed(tokenId)) {
				System.out.println("Token blacklisted");
				response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
				return;
			}
			
			if (!jwtService.ValidateToken(token)) {
				System.out.println("Token Invalidated");
				response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
				return;
			}
			
			String phone;
			if (claims.get("phone")==null) {
				phone = "N/A";
			}else {
				phone= claims.get("phone").toString();
			}

			Map<String, String> details= Map.of(
					"userId", claims.getSubject().toString(),
					"userName", claims.get("fullname").toString(),
					"phone", phone,
					"photo", claims.get("imagepath").toString(),
					"token", token
					);
			
			UsernamePasswordAuthenticationToken authToken= new UsernamePasswordAuthenticationToken(details, null, List.of());
			SecurityContextHolder.getContext().setAuthentication(authToken);
		}
		filterChain.doFilter(request, response);
	}
}

package com.distributedchat.userservice.component;

import java.io.IOException;
import java.util.List;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.distributedchat.userservice.service.JWTService;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class JwtFilterChain extends OncePerRequestFilter{
	
	JWTService jwtService;
	RedisTokenBlackList blackList;
	
	public JwtFilterChain(JWTService jwtService, RedisTokenBlackList blackList) {
		// TODO Auto-generated constructor stub
		this.jwtService= jwtService;
		this.blackList= blackList;
	}
	
	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		String authHeader= request.getHeader("Authorization");
		System.out.println(authHeader);
		
		if (authHeader!=null) {
			String token= authHeader.substring(7);
			System.out.println(token);
			
			if (!jwtService.ValidateToken(token)) {
				response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
				return;
			}
			
			boolean blackListedToken= blackList.isTokenBlackListed(token);
			
			if (blackListedToken) {
				System.out.println("Invalidated token");
				response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
				return;
			}
			
			String uid= jwtService.getUserId(token);
			
			UsernamePasswordAuthenticationToken authToken= new UsernamePasswordAuthenticationToken(uid, null, List.of());
			SecurityContextHolder.getContext().setAuthentication(authToken);
		
		}
		filterChain.doFilter(request, response);
	}

}

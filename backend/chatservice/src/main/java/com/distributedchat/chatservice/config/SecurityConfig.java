package com.distributedchat.chatservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.distributedchat.chatservice.component.JWTFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
	
	private final JWTFilterChain jwtFilterChain;
	
	public SecurityConfig(JWTFilterChain jwtFilterChain) {
		// TODO Auto-generated constructor stub
		this.jwtFilterChain= jwtFilterChain;
	}
	
	@Bean
	SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity) throws Exception{
		return httpSecurity.authorizeHttpRequests(auth -> auth
					.requestMatchers("/ws", "/ws/**").permitAll()
					.anyRequest().authenticated()
				)
				.csrf(crsf -> crsf.disable())
				.sessionManagement(session -> session
						.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
						)
				.addFilterBefore(jwtFilterChain, UsernamePasswordAuthenticationFilter.class)
				.build();		
	}
}

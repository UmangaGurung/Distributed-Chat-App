package com.distributedchat.userservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.distributedchat.userservice.component.JwtFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtFilterChain jwtFilterChain;

    SecurityConfig(JwtFilterChain jwtFilterChain) {
        this.jwtFilterChain = jwtFilterChain;
    }
    
	@Bean
	BCryptPasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}
	
	@Bean
	SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception{
        return http.authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/users/signup",
                        		"/api/users/login","/api/users/google/auth/token").permitAll()
                        .requestMatchers("/photos/**").permitAll()   
                        .anyRequest().authenticated()
        )
        .csrf(csrf -> csrf.disable())
        .sessionManagement(session -> session
        	    .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
        	)
        .addFilterBefore(jwtFilterChain, UsernamePasswordAuthenticationFilter.class)
        .build();
	}
}

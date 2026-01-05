package com.distributedchat.chatservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;

@SpringBootApplication(exclude = SecurityAutoConfiguration.class)
public class ChatserviceApplication {

	public static void main(String[] args) {
		SpringApplication.run(ChatserviceApplication.class, args);
	}

}

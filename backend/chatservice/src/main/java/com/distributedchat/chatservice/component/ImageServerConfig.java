package com.distributedchat.chatservice.component;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class ImageServerConfig implements WebMvcConfigurer{
	
	
	@Override
	public void addResourceHandlers(ResourceHandlerRegistry registry) {
		// TODO Auto-generated method stub
		registry.addResourceHandler("/chat-photos/**")
				.addResourceLocations("file:/var/mnt/data/SpringToolSuite/projects/distributedchat/photos/chat/");
	}

}

package com.distributedchat.chatservice.component;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class MessageEncryption {
	
	private final SecretKeySpec secretKey;
	
	public MessageEncryption(@Value("${message.secretkey}") String secretKey) {
		// TODO Auto-generated constructor stub
		this.secretKey= keySpecObj(secretKey);
	}
	
	public String encryptMessage(String message) {
		try {
			byte[] nonce= new byte[12];
			SecureRandom nonceRandom= new SecureRandom();
			nonceRandom.nextBytes(nonce);
			
			Cipher cipher= Cipher.getInstance("AES/GCM/NoPadding");
			GCMParameterSpec gcmSpec= new GCMParameterSpec(128, nonce);
			cipher.init(Cipher.ENCRYPT_MODE, secretKey, gcmSpec);
			
			byte[] cipherText= cipher.doFinal(message.getBytes(StandardCharsets.UTF_8));
			
			ByteBuffer buffer= ByteBuffer.allocate(nonce.length+cipherText.length);
			buffer.put(nonce);
			buffer.put(cipherText);
			
			return Base64.getEncoder().encodeToString(buffer.array());
		}catch(Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public String decryptMessage(String encryptedMessage) {
		try {
			Cipher cipher= Cipher.getInstance("AES/GCM/NoPadding");
			
			byte[] encryptedBytes= Base64.getDecoder().decode(encryptedMessage);
			byte[] nonce= Arrays.copyOfRange(encryptedBytes, 0, 12);
			byte[] cipherText= Arrays.copyOfRange(encryptedBytes, 12, encryptedBytes.length);
			
			GCMParameterSpec gcmParameterSpec= new GCMParameterSpec(128, nonce);
			cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmParameterSpec);
			
			byte[] plainBytes= cipher.doFinal(cipherText);
			
			return new String(plainBytes, StandardCharsets.UTF_8);
		}catch(Exception e) {
			e.printStackTrace();
			return null;
		}
	}
	
	private SecretKeySpec keySpecObj(String secretKey) {
		return new SecretKeySpec(secretKey.getBytes(StandardCharsets.UTF_8), "AES");
	}
}

package com.distributedchat.userservice.service;

import java.net.URI;
import java.net.URL;
import java.util.Date;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.jwk.source.JWKSourceBuilder;
import com.nimbusds.jose.proc.JWSKeySelector;
import com.nimbusds.jose.proc.JWSVerificationKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import com.nimbusds.jwt.proc.ConfigurableJWTProcessor;
import com.nimbusds.jwt.proc.DefaultJWTProcessor;

@Service
public class GoogleJWTService {
	
	private final ConfigurableJWTProcessor<SecurityContext> jwtprocessor;
	
	private String clientid;
	
	public GoogleJWTService(@Value("${google.custom.url.clientId}") String clientid) throws Exception{
		URI jwkuri= new URI("https://www.googleapis.com/oauth2/v3/certs");
		URL jwkurl= jwkuri.toURL();
		
		JWKSource<SecurityContext> keyssource= JWKSourceBuilder.create(jwkurl).build();
		
		this.jwtprocessor= new DefaultJWTProcessor<>();
		JWSKeySelector<SecurityContext> keyselector= new JWSVerificationKeySelector<>(JWSAlgorithm.RS256, keyssource);
		
		this.jwtprocessor.setJWSKeySelector(keyselector);
		
		this.clientid= clientid;
	}
	
	public JWTClaimsSet validateGoogleToken(String token) throws Exception{
		
		System.out.println(token);
		
		JWTClaimsSet claims= jwtprocessor.process(SignedJWT.parse(token), null);
		
		if (!clientid.equals(claims.getAudience().get(0))) {
			throw new IllegalArgumentException("Invalid audience");
		}
		
		if (!"accounts.google.com".equals(claims.getIssuer()) &&
	            !"https://accounts.google.com".equals(claims.getIssuer())) {
	            throw new IllegalArgumentException("Invalid issuer");
	    }
		
		if (claims.getExpirationTime().before(new Date())) {
			throw new IllegalArgumentException("Expired Token");
		}
		
		return claims;
	}
}

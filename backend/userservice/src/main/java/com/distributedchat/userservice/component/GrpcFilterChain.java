package com.distributedchat.userservice.component;

import com.distributedchat.userservice.service.JWTService;

import io.grpc.Metadata;
import io.grpc.ServerCall;
import io.grpc.ServerCall.Listener;
import io.grpc.ServerCallHandler;
import io.grpc.Status;
import net.devh.boot.grpc.server.interceptor.GrpcGlobalServerInterceptor;
import net.devh.boot.grpc.server.security.interceptors.AuthenticatingServerInterceptor;

@GrpcGlobalServerInterceptor
public class GrpcFilterChain implements AuthenticatingServerInterceptor {

	private JWTService jwtService;
	private RedisTokenBlackList blackList;

	private static final Metadata.Key<String> AUTHORIZATION_KEY = Metadata.Key.of("Authorization",
			Metadata.ASCII_STRING_MARSHALLER);

	public GrpcFilterChain(JWTService jwtService, RedisTokenBlackList blackList) {
		// TODO Auto-generated constructor stub
		this.jwtService = jwtService;
		this.blackList = blackList;
	}

	@Override
	public <ReqT, RespT> Listener<ReqT> interceptCall(ServerCall<ReqT, RespT> call, Metadata headers,
			ServerCallHandler<ReqT, RespT> next) {
		// TODO Auto-generated method stub
		try {
			System.out.println(headers);
			String tokenHeader = headers.get(AUTHORIZATION_KEY);

			if (tokenHeader == null || !tokenHeader.startsWith("Bearer ")) {
				call.close(Status.UNAUTHENTICATED.withDescription("Missing or invalid Authorization header"), headers);
				return new Listener<ReqT>() {
				};
			}

			String token = tokenHeader.substring(7);

			if (token == null || blackList.isTokenBlackListed(token) || !jwtService.ValidateToken(token)) {
				call.close(Status.UNAUTHENTICATED.withDescription("ACCESS DENIED"), headers);
				return new Listener<ReqT>() {
				};
			}
			System.out.println("Valid Token");

			return next.startCall(call, headers);
		} catch (Exception e) {
			call.close(Status.UNAUTHENTICATED.withDescription("Missing or invalid Authorization header"), headers);
			return new Listener<ReqT>() {
			};
		}
	}
}

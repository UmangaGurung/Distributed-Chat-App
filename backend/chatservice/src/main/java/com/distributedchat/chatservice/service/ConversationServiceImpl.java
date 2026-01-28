package com.distributedchat.chatservice.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.distributedchat.chatservice.component.MessageEncryption;
import com.distributedchat.chatservice.component.redis.RedisCaching;
import com.distributedchat.chatservice.component.redis.RedisNewConversationEventPublisher;
import com.distributedchat.chatservice.model.dto.UserDetailGrpcDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConversationDetailsListDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConversationGroupDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConversationResponseDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConversationUpdateDTO;
import com.distributedchat.chatservice.model.dto.Conversation.ConvoMessageDTO;
import com.distributedchat.chatservice.model.dto.Conversation.CreateOrFindDTO;
import com.distributedchat.chatservice.model.dto.Message.LatestMessageDTO;
import com.distributedchat.chatservice.model.dto.Message.MessagePaginationDTO;
import com.distributedchat.chatservice.model.dto.Message.MessageResponseDTO;
import com.distributedchat.chatservice.repository.ConversationDAO;

import jakarta.transaction.Transactional;

@Service
@Transactional
public class ConversationServiceImpl implements ConversationService {

	private ConversationDAO conversationDAO;
	private RedisCaching redisCaching;
	private MessageEncryption messageEncryption;
	private RedisNewConversationEventPublisher conversationEventPublisher;
	
	public ConversationServiceImpl(
			ConversationDAO conversationDAO,
			RedisCaching redisCaching,
			MessageEncryption messageEncryption,
			RedisNewConversationEventPublisher conversationEventPublisher) {
		// TODO Auto-generated constructor stub
		this.conversationDAO= conversationDAO;
		this.redisCaching= redisCaching;
		this.messageEncryption= messageEncryption;
		this.conversationEventPublisher= conversationEventPublisher;
	}
	
	@Override
	public ConversationDetailsListDTO createGroupConversation(
			ConversationGroupDTO conversationdDto, String uid, String userName, String phone, String photo) {
		// TODO Auto-generated method stub
		String convoType= conversationdDto.getType();
		String convoName= conversationdDto.getName();
		
		List<UUID> participants= conversationdDto.getParticipants();

		UUID senderId= UUID.fromString(uid);
		participants.add(senderId);
		
		if (!convoType.equals("GROUP")) {
			throw new IllegalArgumentException("Goup convo type mismatch");
		}

		if (conversationdDto.getParticipants().size()==1 
				&& conversationdDto.getParticipants().contains(senderId)) {
			throw new IllegalArgumentException("Goup convo with same user cant be created");
		}
		ConversationResponseDTO conversation= conversationDAO.createGroupConversation(convoType, convoName, participants, senderId);
		
		conversationEventPublisher.publishNewConversation(
				new ConversationDetailsListDTO(conversation, new UserDetailGrpcDTO(senderId, userName, photo, phone)));
		
		return new ConversationDetailsListDTO(conversation, null);
	}
	
	@Override
	public ConversationDetailsListDTO createOrFindConversation(
			CreateOrFindDTO createOrFindDTO, String uid, String userName, String phone, String photo) {
		// TODO Auto-generated method stub
		UUID userId= UUID.fromString(uid);
		UUID participantId= createOrFindDTO.getParticipantId();
		String type= createOrFindDTO.getType();
		
		if (userId.equals(participantId)) {
			throw new IllegalArgumentException("No Convo here");
		}
		
		Map<ConversationResponseDTO, Boolean> result= conversationDAO.createOrFindConversation(userId, participantId, type);

		UserDetailGrpcDTO userDetails= redisCaching.cacheUserInfo(participantId);
		
		ConversationResponseDTO responseDTO= result.keySet().stream().findFirst().get();
		boolean operationType= result.get(responseDTO);
		
		if (operationType) {
			responseDTO.setConversationName(userName);
			conversationEventPublisher.publishNewConversation(
					new ConversationDetailsListDTO(responseDTO, new UserDetailGrpcDTO(userId, userName, photo, phone)));
		}
		
		String decryptedMessage= messageEncryption.decryptMessage(responseDTO.getLastMessage());
		responseDTO.setConversationName(userDetails.getUserName());
		responseDTO.setLastMessage(decryptedMessage);
		
		ConversationDetailsListDTO conversationDetailsListDTO= 
				new ConversationDetailsListDTO(responseDTO, userDetails);
		
		return conversationDetailsListDTO;
	}

	@Override
	public List<ConversationDetailsListDTO> getConversation(String uid) {
		// TODO Auto-generated method stub
		UUID userId= UUID.fromString(uid);
		
		List<ConversationResponseDTO> allConversations= conversationDAO.getConversation(userId);
		List<ConversationDetailsListDTO> allConvoDetails= new ArrayList<>();
		
		List<UUID> userIds= new ArrayList<>();
		
		for (ConversationResponseDTO responseDTO: allConversations) {
			if (responseDTO.getType().equals("BINARY")) {
				userIds.add(responseDTO.getParticipantID()
						.stream()
						.filter(id -> !id.equals(userId))
						.findFirst()
						.orElseThrow());
			}
		}
		
		List<UserDetailGrpcDTO> userDetails= redisCaching.cacheListOfUserInfo(userIds);
		Map<UUID, UserDetailGrpcDTO> mappedUserDetails= new HashMap<>();
		
		for (UserDetailGrpcDTO userDto: userDetails) {
			mappedUserDetails.put(userDto.getUserId(), userDto);
		}
		
		for (ConversationResponseDTO conversationResponseDTO: allConversations) {
			if (conversationResponseDTO.getLastMessage()!=null) {
			 String decryptedText= messageEncryption.decryptMessage(conversationResponseDTO.getLastMessage());
			 conversationResponseDTO.setLastMessage(decryptedText);
			}
			
			if (conversationResponseDTO.getType().equals("BINARY")) {
				UserDetailGrpcDTO userDetail= mappedUserDetails.get(conversationResponseDTO.getParticipantID()
						.stream()
						.filter(id -> !id.equals(userId))
						.findFirst()
						.orElseThrow());
				
				conversationResponseDTO.setConversationName(userDetail.getUserName());
				
				allConvoDetails.add(
						new ConversationDetailsListDTO(
								conversationResponseDTO, 
								userDetail)
						);
				
			}else if (conversationResponseDTO.getType().equals("GROUP")) {
				allConvoDetails.add(
						new ConversationDetailsListDTO(
								conversationResponseDTO, 
								null)
						);
			}	
		}
		
		Comparator<ConversationDetailsListDTO> comparator= Comparator
				.comparing(c -> c.getConversationResponseDTO().getUpdatedAt());
		
		allConvoDetails.sort(comparator.reversed());
		
		return allConvoDetails;
	}
	
	@Override
	public ConversationResponseDTO editConversationDetails(
			ConversationUpdateDTO conversationUpdateDTO, 
			String convoId, 
			String uid) {
		// TODO Auto-generated method stub
		UUID userId= UUID.fromString(uid);
		UUID conversationId= UUID.fromString(convoId);
		String conversationName= conversationUpdateDTO.getConversationName();
		
		return conversationDAO.editConversationDetails(userId, conversationId, conversationName);
	}

	@Override
	public ConversationResponseDTO addParticipants(
			ConversationUpdateDTO conversationUpdateDTO, 
			String convoId, 
			String uid) {
		// TODO Auto-generated method stub
		UUID userId= UUID.fromString(uid);
		UUID conversationId= UUID.fromString(convoId);
		List<UUID> userIds= conversationUpdateDTO.getUserIds();
		
		userIds.removeIf(id -> id.equals(userId));
		
		if (userIds.isEmpty()) {
			throw new IllegalArgumentException("List is empty");
		}
		
		return conversationDAO.addParticipants(userId, conversationId, userIds);
	}
	
	@Override
	public List<ConvoMessageDTO> getAllConversationMessages(
			String convoIdString, String userIdString, MessagePaginationDTO messagePaginationDTO) {
		// TODO Auto-generated method stub
		UUID convoId= UUID.fromString(convoIdString);
		UUID userId= UUID.fromString(userIdString);
		
		List<MessageResponseDTO> allMessages= conversationDAO.getAllConversationMessages(convoId, userId, messagePaginationDTO);
		
		List<UUID> senderIdList= allMessages.stream()
				.map(m -> m.getSenderId())
				.distinct()
				.collect(Collectors.toList());
		
		List<UserDetailGrpcDTO> userDetailsList= redisCaching.cacheListOfUserInfo(senderIdList);
		Map<UUID, UserDetailGrpcDTO> userDetailMap= new HashMap<>();
		
		for (UserDetailGrpcDTO grpcDTO: userDetailsList) {
			userDetailMap.put(grpcDTO.getUserId(), grpcDTO);
		}

		List<ConvoMessageDTO> allMessageDTOs= new ArrayList<>();
		
		for (MessageResponseDTO m: allMessages) {
			UserDetailGrpcDTO userDetails= userDetailMap.get(m.getSenderId());
			
			String decryptedMessage= messageEncryption.decryptMessage(m.getMessage());
			m.setMessage(decryptedMessage);
			
			ConvoMessageDTO messageDTO= new ConvoMessageDTO();
			messageDTO.setMessageResponse(m);
			messageDTO.setSenderDetails(userDetails);
			
			allMessageDTOs.add(messageDTO);
		}
		return allMessageDTOs;
	}

	@Override
	public List<ConvoMessageDTO> getLatestMessages(String convoId, String userId, LatestMessageDTO latestMessageDTO) {
		// TODO Auto-generated method stub
		UUID conversationId= UUID.fromString(convoId);
		UUID uId= UUID.fromString(userId);
		
		List<MessageResponseDTO> messageList= conversationDAO.getLatestMessages(conversationId, uId, latestMessageDTO);
		
		System.out.println(messageList);
		List<UUID> userIdList= messageList.stream()
				.map(m -> m.getSenderId())
				.distinct()
				.collect(Collectors.toList());
		
		List<UserDetailGrpcDTO> userDetails= redisCaching.cacheListOfUserInfo(userIdList);
		Map<UUID, UserDetailGrpcDTO> userDetailMap= new HashMap<>();
		
		for (UserDetailGrpcDTO userDetail: userDetails) {
			userDetailMap.put(userDetail.getUserId(), userDetail);
		}
		
		List<ConvoMessageDTO> result= new ArrayList<>();
		for (MessageResponseDTO messageResponseDTO: messageList) {
			String decryptedText= messageEncryption.decryptMessage(messageResponseDTO.getMessage());
			messageResponseDTO.setMessage(decryptedText);
			
			UserDetailGrpcDTO userDetail= userDetailMap.get(messageResponseDTO.getSenderId());
			
			result.add(new ConvoMessageDTO(messageResponseDTO, userDetail));
		}
		return result;
	}
}

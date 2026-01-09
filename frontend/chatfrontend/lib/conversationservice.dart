import 'dart:convert';

import 'package:chatfrontend/dto/conversation/conversation&userdetailsdto.dart';
import 'package:chatfrontend/dto/message/messagedetailsdto.dart';
import 'package:chatfrontend/dto/message/messageresponsedto.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';

import 'dto/conversation/conversationresponsedto.dart';
import 'package:http/http.dart' as http;

class ConversationAPIService {
  static const String conversationUrl =
      "http://192.168.1.74:8082/chat/conversations";

  Future<ConversationAndUserDetailsDTO?> createOrFindConversation(
    String? token,
    String userId,
  ) async {
    try {
      final url = Uri.parse(conversationUrl + "/direct-messages");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'participantId': userId, 'type': 'BINARY'}),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print(data['conversationDetails']);
        print(data['userDetails']);

        return ConversationAndUserDetailsDTO(
          conversationResponseDTO: ConversationResponseDTO.fromJson(
            data['conversationResponseDTO'],
          ),
          participantDetailsDTO: ParticipantDetails.fromJson(
            data['detailGrpcDTO'],
          ),
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<List<MessageDetailsDTO>> getConversationMessages(
    String token,
    String conversationId,
  ) async {
    try {
      final url = Uri.parse(
        conversationUrl + "/${conversationId}/messages",
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<MessageDetailsDTO> messageDetailsList = [];
        print(data);

        data.forEach((message) {
          MessageDetailsDTO messageDetailsDTO = MessageDetailsDTO(
            messageResponseDTO: MessageResponseDTO.fromJson(
              message['messageResponse'],
            ),
            userDetailsDTO: ParticipantDetails.fromJson(
              message['senderDetails'],
            ),
          );

          messageDetailsList.add(messageDetailsDTO);
        });

        return messageDetailsList;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<ConversationAndUserDetailsDTO>> getAllConversations(String token) async {
    try {
      final url = Uri.parse(conversationUrl);

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<ConversationAndUserDetailsDTO> conversationDetails = [];

        print(data);

        data.forEach((conversationDetail) {
          final conversationResponseDTO =
              conversationDetail['conversationResponseDTO'];
          final participantDetailsDTO = conversationDetail['detailGrpcDTO'];

          ConversationAndUserDetailsDTO conversationAndUserDetailsDTO =
              ConversationAndUserDetailsDTO(
                conversationResponseDTO: ConversationResponseDTO.fromJson(
                  conversationResponseDTO,
                ),
                participantDetailsDTO: participantDetailsDTO != null
                    ? ParticipantDetails.fromJson(participantDetailsDTO)
                    : null,
              );

          conversationDetails.add(conversationAndUserDetailsDTO);
        });

        return conversationDetails;
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}

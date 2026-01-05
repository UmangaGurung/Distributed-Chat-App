import 'package:chatfrontend/dto/conversation/conversationresponsedto.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';

class ConversationAndUserDetailsDTO{
  final ConversationResponseDTO conversationResponseDTO;
  final ParticipantDetails? participantDetailsDTO;

  ConversationAndUserDetailsDTO({
      required this.conversationResponseDTO,
      this.participantDetailsDTO
  });
}
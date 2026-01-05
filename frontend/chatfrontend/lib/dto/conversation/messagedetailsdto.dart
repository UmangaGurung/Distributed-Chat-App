
import 'package:chatfrontend/dto/conversation/messageresponsedto.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';

class MessageDetailsDTO{
  final MessageResponseDTO messageResponseDTO;
  final ParticipantDetails userDetailsDTO;

  MessageDetailsDTO({
    required this.messageResponseDTO,
    required this.userDetailsDTO
  });
}
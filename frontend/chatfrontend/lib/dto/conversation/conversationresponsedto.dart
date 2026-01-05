import 'package:intl/intl.dart';

class ConversationResponseDTO{

  final String conversationID;
  final String conversationName;
  final String lastMessage;
  final List<String> participantId;
  final String updatedAt;
  final String type;

  ConversationResponseDTO({
    required this.conversationID,
    required this.conversationName,
    required this.lastMessage,
    required this.participantId,
    required this.updatedAt,
    required this.type
  });
  
  factory ConversationResponseDTO.fromJson(Map<String, dynamic> jsonData){
    final date= DateTime.parse(jsonData['updatedAt']);
    final diff= DateTime.now().difference(date).inHours.toInt();

    String time;
    if (diff<=24 && diff>=0){
      time= DateFormat('HH:mm').format(date);
    } else{
      time= DateFormat.Md().format(date);
    }

    return ConversationResponseDTO(
        conversationID: jsonData['conversationID'],
        conversationName: jsonData['conversationName'],
        lastMessage: jsonData['lastMessage'] ?? '',
        participantId: List<String>.from(jsonData['participantID']),
        updatedAt: time,
        type: jsonData['type']
    );
  }
}
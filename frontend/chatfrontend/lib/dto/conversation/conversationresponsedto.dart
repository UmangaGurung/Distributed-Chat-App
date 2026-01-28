import 'package:intl/intl.dart';

class ConversationResponseDTO {
  final String conversationID;
  final String conversationName;
  final String lastMessage;
  final String lastMessageId;
  final List<String> participantId;
  final String updatedAt;
  final String type;
  final String adminId;

  ConversationResponseDTO({
    required this.conversationID,
    required this.conversationName,
    required this.lastMessage,
    required this.lastMessageId,
    required this.participantId,
    required this.updatedAt,
    required this.type,
    required this.adminId,
  });

  factory ConversationResponseDTO.fromJson(Map<String, dynamic> jsonData) {
    final date = DateTime.parse(jsonData['updatedAt']);
    final diff = DateTime.now().difference(date).inHours.toInt();

    String time;
    if (diff <= 24 && diff >= 0) {
      time = DateFormat('HH:mm').format(date);
    } else {
      time = DateFormat.Md().format(date);
    }

    return ConversationResponseDTO(
      conversationID: jsonData['conversationID'],
      conversationName: jsonData['conversationName'],
      lastMessage: jsonData['lastMessage'] ?? '',
      lastMessageId: jsonData['lastMessageId'] ?? '',
      participantId: List<String>.from(jsonData['participantID']),
      updatedAt: time,
      type: jsonData['type'],
      adminId: jsonData['adminId'] ?? '',
    );
  }
}

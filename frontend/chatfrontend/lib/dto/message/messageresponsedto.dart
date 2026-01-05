import 'dart:collection';

import 'package:intl/intl.dart';

class MessageResponseDTO {
  final String conversationId;
  final String messageId;
  final String message;
  final String messageType;
  final String createdAt;
  final String senderId;

  MessageResponseDTO({
    required this.conversationId,
    required this.messageId,
    required this.message,
    required this.messageType,
    required this.createdAt,
    required this.senderId,
  });

  factory MessageResponseDTO.fromJson(Map<String, dynamic> jsonData) {
    print("Inside MessageRespose 1 ${jsonData['createdAt']}");
    final date= DateTime.parse(jsonData['createdAt']);
    print("Inside MessageRespose 2 ${date}");
    String time= DateFormat('HH:mm').format(date);
    print("Inside MessageRespose 3 ${time}");
    return MessageResponseDTO(
      conversationId: jsonData['conversationId'],
      messageId: jsonData['messageId'],
      message: jsonData['message'],
      messageType: jsonData['messageType'],
      // createdAt: DateTime.parse(jsonData['createdAt']),
      createdAt: time,
      senderId: jsonData['senderId'],
    );
  }
}

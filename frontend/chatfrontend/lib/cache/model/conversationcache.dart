import 'package:hive_flutter/hive_flutter.dart';

part 'conversationcache.g.dart';

@HiveType(typeId: 1)
class HiveConversationModel extends HiveObject {

  @HiveField(0)
  final String conversationId;
  
  @HiveField(1)
  final String conversationName;
  
  @HiveField(2)
  final String lastMessage;
  
  @HiveField(3)
  final List<String> participantId;
  
  @HiveField(4)
  final String updatedAt;
  
  @HiveField(5)
  final String type;

  HiveConversationModel({
    required this.conversationId,
    required this.conversationName,
    required this.lastMessage,
    required this.participantId,
    required this.updatedAt,
    required this.type
  });
}
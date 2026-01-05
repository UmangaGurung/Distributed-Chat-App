import 'package:hive_flutter/hive_flutter.dart';

part 'messagecache.g.dart';

@HiveType(typeId: 2)
class HiveMessageModel extends HiveObject {

  @HiveField(0)
  final String conversationId;

  @HiveField(1)
  final String messageId;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final String messageType;

  @HiveField(4)
  final String createdAt;

  @HiveField(5)
  final String senderId;

  HiveMessageModel({
    required this.conversationId,
    required this.messageId,
    required this.message,
    required this.messageType,
    required this.createdAt,
    required this.senderId,
  });
}

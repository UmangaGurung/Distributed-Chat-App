class MessageFrameDTO{

  final String conversationId;
  final String type;
  final String message;

  MessageFrameDTO({
    required this.conversationId,
    required this.type,
    required this.message
  });
}
import 'package:chatfrontend/cache/service/hivemessageservice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dto/message/messagedetailsdto.dart';

class ChatMessageState extends Notifier<Map<String, List<MessageDetailsDTO>>> {
  @override
  Map<String, List<MessageDetailsDTO>> build() {
    // TODO: implement build
    return {};
  }

  // HiveMessageService _hiveMessageService= HiveMessageService();

 void addNewMessages(MessageDetailsDTO message){
    final convoId = message.messageResponseDTO.conversationId;

    final existingMessages = state[convoId] ?? const [];

    state = {
      ...state,
      convoId: [message, ...existingMessages],
    };
  }

  void clearState(String convoId){
    state = {
      ...state,
      convoId: [],
    };
  }
}

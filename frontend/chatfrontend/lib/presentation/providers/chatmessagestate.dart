import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dto/conversation/messagedetailsdto.dart';

class ChatMessageState extends Notifier<Map<String, List<MessageDetailsDTO>>> {
  @override
  Map<String, List<MessageDetailsDTO>> build() {
    // TODO: implement build
    return {};
  }

  void addNewMessages(MessageDetailsDTO message) {
    final convoId = message.messageResponseDTO.conversationId;

    final existingMessages = state[convoId] ?? const [];

    state = {
      ...state,
      convoId: [...existingMessages, message],
    };
  }

  void clearState(String convoId){
    state = {
      ...state,
      convoId: [],
    };
  }
  //add a addbatch method also
}

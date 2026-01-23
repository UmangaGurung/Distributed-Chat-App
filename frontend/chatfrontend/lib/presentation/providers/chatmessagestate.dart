import 'dart:async';

import 'package:chatfrontend/cache/service/hivemessageservice.dart';
import 'package:chatfrontend/dto/message/messageresponsedto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dto/message/messagedetailsdto.dart';

class ChatMessageState extends Notifier<Map<String, List<MessageDetailsDTO>>> {
  late final HiveMessageService _hiveMessageService= HiveMessageService();
  late final StreamController<MessageResponseDTO> _queue= StreamController();

  ChatMessageState() {
    _queue.stream.asyncMap((msg) async {
      final conversationId= msg.conversationId;

      if(await _hiveMessageService.isExpired(conversationId)){
        await _hiveMessageService.setExpirationTime(conversationId);
      }

      await _hiveMessageService.addMessageToHive(msg, conversationId);
    }).listen(null);
  }

  @override
  Map<String, List<MessageDetailsDTO>> build() {
    // TODO: implement build
    return {};
  }

  void addNewMessages(MessageDetailsDTO message) {
    final conversationId = message.messageResponseDTO.conversationId;
    print(conversationId);

    final existingMessages = state[conversationId] ?? const [];

    state = {
      ...state,
      conversationId: [message, ...existingMessages],
    };
    print("State Keys ${state.keys.toList()}");

    _queue.add(message.messageResponseDTO);
  }

  void clearState(String conversationId) {
    state = {...state, conversationId: []};
  }
}

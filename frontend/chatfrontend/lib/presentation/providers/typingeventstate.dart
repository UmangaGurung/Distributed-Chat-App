
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TypingEventState extends Notifier<Map<String, Map<String, String>>>{
  Map<String, Timer> userIdTimers= {};
  static const String separator= '\u2021';

  @override
  Map<String, Map<String, String>> build() {
    // TODO: implement build
    return {};
  }

  void setTypingEvent(List<String> payload){
    String conversationId= payload.first;
    String userId= payload[1];
    String userImage= payload[2];
    String event= payload.last;

    Map<String, String> existingEvents= state[conversationId] ?? const {};

    if (event=="TYPING") {
      state = {
        ...state,
        conversationId: {
          ...existingEvents,
          userId: "$userImage$separator$event"
        }
      };
    }else{
      state= {
        ...state,
        conversationId: {
          ...existingEvents
        }..remove(userId)
      };
    }
  }
}

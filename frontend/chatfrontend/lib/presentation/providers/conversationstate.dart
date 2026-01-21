import 'package:chatfrontend/dto/conversation/conversation&userdetailsdto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationState extends Notifier<Map<String, ConversationAndUserDetailsDTO>>{

  @override
  Map<String, ConversationAndUserDetailsDTO> build() {
    // TODO: implement build
    return {};
  }

  void addNewConversationToState(ConversationAndUserDetailsDTO newConversation){
    final String conversationId= newConversation.conversationResponseDTO.conversationID;

    // if (state.containsKey(conversationId)){
    //   return;
    // }

    state= {
      ...state,
      conversationId: newConversation
    };

    print("---------Added to convoState: ${state.keys}");
  }
}
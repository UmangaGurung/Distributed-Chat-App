
import 'package:chatfrontend/cache/model/conversationcache.dart';
import 'package:chatfrontend/dto/conversation/conversationresponsedto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveConversationService {

  final convoBox= Hive.box<HiveConversationModel>('conversation');

  Future<void> addConversationToHive(
      List<ConversationResponseDTO> conversationResponseList) async{

    Map<String, HiveConversationModel> hiveMap= {};
    for (ConversationResponseDTO conversation in conversationResponseList){

      HiveConversationModel hiveConversationModel= HiveConversationModel(
          conversationId: conversation.conversationID,
          conversationName: conversation.conversationName,
          lastMessage: conversation.lastMessage,
          participantId: conversation.participantId,
          updatedAt: conversation.updatedAt,
          type: conversation.type);

      hiveMap[conversation.conversationID]= hiveConversationModel;
    }

    await convoBox.putAll(hiveMap);
  }
}
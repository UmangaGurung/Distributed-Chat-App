import 'package:chatfrontend/cache/model/messagecache.dart';
import 'package:chatfrontend/dto/message/messageresponsedto.dart';
import 'package:hive/hive.dart';

class HiveMessageService {
  final box = Hive.box<HiveMessageModel>('messages');
  final indexBox = Hive.box('conversationIndex');
  final ttlBox= Hive.box<DateTime>('dataTTL');

  Future<void> addMessagesToHive(
    List<MessageResponseDTO> messageList,
    String conversationId,
  ) async {
    Map<String, HiveMessageModel> hiveMessageMap = {};

    Map<dynamic, dynamic> messageIdMap= indexBox.get(
      conversationId,
      defaultValue: {},
    ) ?? {};

    List<String> messageIdList= (messageIdMap['api'] as List?)?.cast<String>() ?? [];

    for (MessageResponseDTO message in messageList) {
      if (messageIdList.contains(message.messageId)){
        continue;
      }

      HiveMessageModel hiveMessage = HiveMessageModel(
        conversationId: message.conversationId,
        messageId: message.messageId,
        message: message.message,
        messageType: message.messageType,
        createdAt: message.createdAt,
        createdAtFormatted: message.createdAtFormatted,
        senderId: message.senderId,
      );

      hiveMessageMap[message.messageId] = hiveMessage;
      messageIdList.insert(0, message.messageId);
    }

    messageIdMap['api']= messageIdList;
    await box.putAll(hiveMessageMap);
    await indexBox.put(conversationId, messageIdMap);

    print("Messages added to Hive");
  }

  Future<void> addMessageToHive(
      MessageResponseDTO messageResponse,
      String conversationId) async{

    Map<dynamic, dynamic> messageIdMap= indexBox.get(
      conversationId,
      defaultValue: {},
    ) ?? {};

    List<String> messageIdList = (messageIdMap['stomp'] as List?)?.cast<String>() ?? [];

    if (messageIdList.contains(messageResponse.messageId)){
      return;
    }

    HiveMessageModel messageModel= HiveMessageModel(
        conversationId: conversationId,
        messageId: messageResponse.messageId,
        message: messageResponse.message,
        messageType: messageResponse.messageType,
        createdAt: messageResponse.createdAt,
        createdAtFormatted: messageResponse.createdAtFormatted,
        senderId: messageResponse.senderId
    );

    messageIdList.add(messageResponse.messageId);
    messageIdMap['stomp']= messageIdList;

    await box.put(messageResponse.messageId, messageModel);
    await indexBox.put(conversationId, messageIdMap);
  }

  List<MessageResponseDTO> getMessages(String conversationId) {
    final messageIdMap = indexBox.get(conversationId) ?? {};

    final messageIdList= (messageIdMap['api'] as List).cast<String>();

    final messageList = messageIdList!.map((id) => box.get(id)!).toList();

    List<MessageResponseDTO> messageResponseList= [];
    for (HiveMessageModel message in messageList) {
      MessageResponseDTO messageResponseDTO = MessageResponseDTO(
        conversationId: message.conversationId,
        messageId: message.messageId,
        message: message.message,
        messageType: message.messageType,
        createdAt: message.createdAt,
        createdAtFormatted: message.createdAtFormatted,
        senderId: message.senderId,
      );
      messageResponseList.insert(0, messageResponseDTO);
    }

    return messageResponseList;
  }

  Future<void> setExpirationTime(String conversationId) async{
    final key= 'conversation:$conversationId';
    if (ttlBox.containsKey(key)){
      return;
    }
    await ttlBox.put(key, DateTime.now());
  }

  bool doesMessageExist(String conversationId, String keyType){
    final conversationMessages= indexBox.get(conversationId) ?? {};

    if (conversationMessages == null || conversationMessages.isEmpty){
      return false;
    }

    final stompMessages = (conversationMessages['stomp'] as List?)?.cast<String>() ?? [];
    final apiMessages = (conversationMessages['api'] as List?)?.cast<String>() ?? [];

    switch (keyType){
      case 'stomp':
        if (stompMessages.isNotEmpty){
          return true;
        }
        break;
      case 'api':
        if (apiMessages.isNotEmpty){
          return true;
        }
        break;
    }
    return false;
  }

  Future<bool> isExpired(String conversationId) async{
    final key= 'conversation:$conversationId';
    final DateTime now= DateTime.now();

    final messageList= indexBox.get(conversationId);
    final allMessages= [...?messageList?['api'], ...?messageList?['stomp']];

    try{
      DateTime? value= ttlBox.get(key);
      
      if (value==null || now.difference(value) > const Duration(minutes: 15)){
        await box.deleteAll(allMessages);
        await indexBox.delete(conversationId);
        await ttlBox.delete(key);

        return true;
      }
      return false;
    }catch(e){
      print(e);
      await box.deleteAll(allMessages);
      await indexBox.delete(conversationId);
      await ttlBox.delete(key);
      return true;
    }
  }
}

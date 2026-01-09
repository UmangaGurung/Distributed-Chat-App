import 'package:chatfrontend/cache/model/messagecache.dart';
import 'package:chatfrontend/dto/message/messageresponsedto.dart';
import 'package:hive/hive.dart';

class HiveMessageService {
  final box = Hive.box<HiveMessageModel>('messages');
  final indexBox = Hive.box<Map<String, List<String>>>('conversationIndex');
  final ttlBox= Hive.box<DateTime>('dataTTL');

  Future<void> addMessagesToHive(
    List<MessageResponseDTO> messageList,
    String conversationId,
  ) async {
    Map<String, HiveMessageModel> hiveMessageMap = {};

    Map<String, List<String>> messageIdMap= indexBox.get(
      conversationId,
      defaultValue: {},
    ) ?? {};

    List<String> messageIdList= messageIdMap['api'] ?? [];

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

    Map<String, List<String>> messageIdMap= indexBox.get(
      conversationId,
      defaultValue: {},
    ) ?? {};

    List<String> messageIdList= messageIdMap['stomp'] ?? [];

    if (messageIdList.contains(messageResponse.messageId)){
      return;
    }

    HiveMessageModel messageModel= HiveMessageModel(
        conversationId: conversationId,
        messageId: messageResponse.messageId,
        message: messageResponse.message,
        messageType: messageResponse.messageType,
        createdAt: messageResponse.createdAt,
        senderId: messageResponse.senderId
    );

    messageIdList.add(messageResponse.messageId);
    messageIdMap['stomp']= messageIdList;

    await box.put(messageResponse.messageId, messageModel);
    await indexBox.put(conversationId, messageIdMap);
  }

  List<MessageResponseDTO> getMessages(String conversationId, int limitIndex) {
    final messageIdMap = indexBox.get(conversationId) ?? {};
    final messageIdList= messageIdMap['api'];

    final messageList = messageIdList!.map((id) => box.get(id)!).toList();

    List<MessageResponseDTO> messageResponseList= [];
    for (HiveMessageModel message in messageList) {
      MessageResponseDTO messageResponseDTO = MessageResponseDTO(
        conversationId: message.conversationId,
        messageId: message.messageId,
        message: message.message,
        messageType: message.messageType,
        createdAt: message.createdAt,
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

    if (conversationMessages.isEmpty){
      return false;
    }

    final stompMessages= conversationMessages['stomp'] ?? [];
    final apiMessages= conversationMessages['api'] ?? [];

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

  Future<bool> isExpired(String conversationId) async {
    final key= 'conversation:$conversationId';
    print(indexBox.get(conversationId));
    if (!ttlBox.containsKey(key)){
      return true;
    }
    final ttl= ttlBox.get(key);
    print(ttl);
    if (DateTime.now().difference(ttl!) > const Duration(minutes: 15)){
      print("Expired");
      print(indexBox.get(conversationId));
      final messageIdMap = indexBox.get(conversationId);
      print(messageIdMap);
      if (messageIdMap!=null && messageIdMap.isNotEmpty){
        final messageIdLists= [ ...?messageIdMap['api'], ...?messageIdMap['stomp']];
        await box.deleteAll(messageIdLists);
      }
      await indexBox.delete(conversationId);
      await ttlBox.delete(key);

      return true;
    }
    print("Not expired");
    return false;
  }
}

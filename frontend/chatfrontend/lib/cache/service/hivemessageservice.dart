import 'package:chatfrontend/cache/model/messagecache.dart';
import 'package:chatfrontend/dto/message/messageresponsedto.dart';
import 'package:hive/hive.dart';

class HiveMessageService {
  final box = Hive.box<HiveMessageModel>('messages');
  final indexBox = Hive.box<List<String>>('conversationIndex');
  final ttlBox= Hive.box<DateTime>('dataTTL');

  Future<void> addMessagesToHive(
    List<MessageResponseDTO> messageList,
    String conversationId,
  ) async {
    Map<String, HiveMessageModel> hiveMessageMap = {};

    List<String>? messageIdList = indexBox.get(
      conversationId,
      defaultValue: <String>[],
    );

    for (MessageResponseDTO message in messageList) {
      HiveMessageModel hiveMessage = HiveMessageModel(
        conversationId: message.conversationId,
        messageId: message.messageId,
        message: message.message,
        messageType: message.messageType,
        createdAt: message.createdAt,
        senderId: message.senderId,
      );
      hiveMessageMap[message.messageId] = hiveMessage;
      messageIdList!.insert(0, message.messageId);
    }
    await box.putAll(hiveMessageMap);
    await indexBox.put(conversationId, messageIdList!);

    print("Messages added to Hive");
  }

  List<MessageResponseDTO> getMessages(String conversationId, int limitIndex) {
    final messageIdList = indexBox.get(conversationId);

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
    final key= 'conversation:${conversationId}';
    if (ttlBox.containsKey(key)){
      return;
    }
    ttlBox.put(key, DateTime.now());
  }

  Future<bool> isExpired(String conversationId) async {
    final key= 'conversation:${conversationId}';
    if (!ttlBox.containsKey(key)){
      return true;
    }
    final ttl= ttlBox.get(key);
    if (DateTime.now().difference(ttl!) > const Duration(minutes: 10)){
      final messageIdList = indexBox.get(conversationId);

      if (messageIdList!=null && messageIdList.isNotEmpty){
        await box.deleteAll(messageIdList);
      }

      await indexBox.delete(conversationId);
      await ttlBox.delete(key);

      return true;
    }
    return false;
  }
}

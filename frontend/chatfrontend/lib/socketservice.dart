import 'dart:convert';
import 'package:chatfrontend/dto/message/messagedetailsdto.dart';
import 'package:chatfrontend/dto/message/messageresponsedto.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:chatfrontend/presentation/providers/chatmessagestate.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class SocketService {
  late StompClient stompClient;
  final String url = "ws://192.168.1.74:8080/ws/";
  late String userId;

  bool isConnected = false;
  bool isSubscribed = false;
  final Set<String> _seenMessageIds = {};

  final ChatMessageState chatMessageState;

  SocketService(this.chatMessageState);

  void connectToWebSocket(String token, String userId) {
    print("connectToWebSocket called");
    if (isConnected) {
      print("Already connected");
      return;
    }
    this.userId = userId;
    stompClient = StompClient(
      config: StompConfig(
        url: url,
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: onConnect,
        beforeConnect: () async {
          print('Connecting...');
          await Future.delayed(Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) => print('WebSocket error..$error'),
        onStompError: (dynamic error) => print('STOMP error..$error'),
        onDisconnect: (dynamic error) => print('Disconnected'),
      ),
    );
    stompClient.activate();
  }

  void onConnect(StompFrame frame) {
    isConnected = true;
    print("Connected to WebSocket");
    print("Subscribing to topic: /topic/user/$userId");

    stompClient.subscribe(
      destination: '/topic/user/$userId',
      callback: callback,
    );

    final convoId= '4e0d5c2e-d112-476a-9deb-2af06417559b';
    stompClient.subscribe(
        destination: '/topic/event/$convoId',
        callback: callbackTypingEvent
    );

    isSubscribed = true;
  }

  void callback(StompFrame frame) {
    print("Received on topic: ${frame.headers}");

    final body = frame.body!;
    final jsonMsg = jsonDecode(body);
    final messageId = jsonMsg['messageResponse']['messageId'];

    if (_seenMessageIds.contains(messageId)) return;
    _seenMessageIds.add(messageId);

    print(jsonMsg['messageResponse']);
    print(jsonMsg['senderDetails']);

    MessageDetailsDTO messageDetailsDTO= MessageDetailsDTO(
        messageResponseDTO: MessageResponseDTO.fromJson(jsonMsg['messageResponse']),
        userDetailsDTO: ParticipantDetails.fromJson(jsonMsg['senderDetails'])
    );

    chatMessageState.addNewMessages(messageDetailsDTO);
  }

  void sendMessage(String message) {
    final messageData = {
      'conversationId': '47a33f67-8382-4de5-89b7-49ccbf50eedc',
      'message': message,
      'type': 'TEXT',
    };

    stompClient.send(
      destination: '/app/chat.sendMessage',
      body: jsonEncode(messageData),
    );
  }

  void typingEvent(String conversationId, String userId, String event){
    final info= {
      'conversationId': conversationId,
      'event': event
    };

    stompClient.send(
        destination: '/app/chat.typingEvent',
        body: jsonEncode(info)
    );
  }

  void callbackTypingEvent(StompFrame frame){
    print("Received on topic: ${frame.headers}");

    final body= frame.body;

    print(body);
  }

  void disconnectConnection() {
    print("Disconnecting.....");
    if (!isConnected) return;
    stompClient.deactivate();
    isConnected = false;
    isSubscribed = false;
  }
}

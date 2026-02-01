import 'dart:convert';
import 'package:chatfrontend/dto/conversation/conversation&userdetailsdto.dart';
import 'package:chatfrontend/dto/conversation/conversationresponsedto.dart';
import 'package:chatfrontend/dto/message/messagedetailsdto.dart';
import 'package:chatfrontend/dto/message/messageresponsedto.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:chatfrontend/presentation/providers/chatmessagestate.dart';
import 'package:chatfrontend/presentation/providers/conversationstate.dart';
import 'package:chatfrontend/presentation/providers/typingeventstate.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class SocketService {
  late StompClient stompClient;
  final String url = "ws://192.168.1.74:8080/ws/";
  late String userId;

  bool isConnected = false;
  bool isSubscribed = false;
  final Set<String> _seenMessageIds = {};

  final ChatMessageState chatMessageState;
  final TypingEventState typingEventState;
  final ConversationState conversationState;
  dynamic convoIdEvent;

  SocketService(this.chatMessageState, this.typingEventState, this.conversationState);

  static const String separator = '\u2021';

  void connectToWebSocket(String token, String userId) {

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

    stompClient.subscribe(
      destination: '/topic/event/$userId',
      callback: newConversationEvent,
    );

    stompClient.subscribe(
      destination: '/queue/ack/$userId',
      callback: callbackSuccessfullySent,
    );

    isSubscribed = true;
  }

  void newConversationEvent(StompFrame frame) {
    final body = jsonDecode(frame.body!);

    ConversationAndUserDetailsDTO conversationAndUserDetailsDTO =
        ConversationAndUserDetailsDTO(
          conversationResponseDTO: ConversationResponseDTO.fromJson(
            body['conversationResponseDTO'],
          ),
          participantDetailsDTO: body['detailGrpcDTO'] != null
              ? ParticipantDetails.fromJson(body['detailGrpcDTO'])
              : null,
        );

    conversationState.addNewConversationToState(conversationAndUserDetailsDTO);
  }

  void subscribeToEvent(String conversationId) {
    if (!isConnected) {
      return;
    }
    print("Subscribing to event");

    if (convoIdEvent != null) {
      unSubscribeToEvent();
    }

    convoIdEvent = stompClient.subscribe(
      destination: '/topic/event/$conversationId',
      callback: callbackTypingEvent,
    );
  }

  void unSubscribeToEvent() {
    convoIdEvent(unsubscribeHeaders: <String, String>{});
    convoIdEvent = null;
    print("Removed Subscription");
  }

  void callback(StompFrame frame) {
    final body = frame.body!;
    final jsonMsg = jsonDecode(body);
    final messageId = jsonMsg['messageResponse']['messageId'];

    if (_seenMessageIds.contains(messageId)) return;
    _seenMessageIds.add(messageId);

    MessageDetailsDTO messageDetailsDTO = MessageDetailsDTO(
      messageResponseDTO: MessageResponseDTO.fromJson(
        jsonMsg['messageResponse'],
      ),
      userDetailsDTO: ParticipantDetails.fromJson(jsonMsg['senderDetails']),
    );

    chatMessageState.addNewMessages(messageDetailsDTO);
  }

  void sendMessage(String message, String conversationId, String type) {
    final messageData = {
      'conversationId': conversationId,
      'message': message,
      'type': type,
    };

    stompClient.send(
      destination: '/app/chat.sendMessage',
      body: jsonEncode(messageData),
    );
  }

  void typingEvent(String conversationId, String userId, String event) {
    final info = {'conversationId': conversationId, 'event': event};

    stompClient.send(
      destination: '/app/chat.typingEvent',
      body: jsonEncode(info),
    );
  }

  void callbackTypingEvent(StompFrame frame) {
    final body = frame.body;

    List<String> payload = body!.split(separator);

    typingEventState.setTypingEvent(payload);
  }

  void callbackSuccessfullySent(StompFrame frame) {
    print("Message successfully sent");
    final response = jsonDecode(frame.body!);

    ParticipantDetails participantDetails = ParticipantDetails(
      userId: '',
      userName: '',
      photoUrl: '',
      phoneNumber: '',
    );

    MessageDetailsDTO messageDetailsDTO = MessageDetailsDTO(
      messageResponseDTO: MessageResponseDTO.fromJson(response),
      userDetailsDTO: participantDetails,
    );

    chatMessageState.addNewMessages(messageDetailsDTO);
  }

  void disconnectConnection() {
    print("Disconnecting.....");
    if (!isConnected) return;
    stompClient.deactivate();
    isConnected = false;
    isSubscribed = false;
  }
}

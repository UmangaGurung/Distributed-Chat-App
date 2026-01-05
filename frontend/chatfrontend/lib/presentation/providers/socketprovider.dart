import 'package:chatfrontend/dto/message/messagedetailsdto.dart';
import 'package:chatfrontend/presentation/providers/chatmessagestate.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/socketservice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final socketService= Provider<SocketService>((ref){
  final tokenAsync= ref.watch(tokenProvider);

  ChatMessageState chatMessageState= ref.watch(messageProvider.notifier);
  final socket= SocketService(chatMessageState);

  tokenAsync.whenData((token){
    print("TOKEN CHECK AT SOCKET PROVIDER $token");
    if (token!=null && !JwtDecoder.isExpired(token)){
      if (!socket.isConnected) {
        final claims = JwtDecoder.decode(token);
        print("Connecting STOMP for user: ${claims['sub']}");
        socket.connectToWebSocket(token, claims['sub']);
      }
    }else{
      print("Connecting Refused");
      socket.disconnectConnection();
    }
  });

  ref.onDispose((){
    print("SocketService disposed");
    socket.disconnectConnection();
  });

  return socket;
});

final messageProvider=
    NotifierProvider<ChatMessageState, Map<String, List<MessageDetailsDTO>>>((){
    return ChatMessageState();
});
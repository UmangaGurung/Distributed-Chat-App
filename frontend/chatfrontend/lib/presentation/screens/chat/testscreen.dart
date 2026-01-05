import 'dart:async';

import 'package:chatfrontend/presentation/providers/socketprovider.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class TestScreen extends ConsumerStatefulWidget {
  const TestScreen({super.key});

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  Timer? _timer;
  Timer? _typingTimer;
  bool isTyping= false;
  final conversationId= '4e0d5c2e-d112-476a-9deb-2af06417559b';
  late String token;
  late String userId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final auth= ref.read(tokenProvider.notifier);

    token= auth.token;
    final claims= auth.tokenDecode();
    userId= claims['sub'];
  }

  @override
  Widget build(BuildContext context) {
    final socket= ref.read(socketService);

    return Scaffold(
      body: Center(
        child: TextField(
          onChanged: (String? text){
            _timer?.cancel();

            _timer= Timer(Duration(milliseconds: 3000), (){
              isTyping= false;
              _typingTimer?.cancel();
            });

            if (!isTyping){
              isTyping= true;
              socket.typingEvent(conversationId, userId, 'STARTED_TYPING');

              _typingTimer= Timer.periodic(Duration(milliseconds: 2000), (Timer timer){
                socket.typingEvent(conversationId, userId, 'STILL_TYPING');
              });
            }
           },
        ),
      ),
    );
  }
}

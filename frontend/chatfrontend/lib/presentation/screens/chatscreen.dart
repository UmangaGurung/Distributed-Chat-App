import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/chat/testscreen.dart';
import 'package:chatfrontend/presentation/screens/chatmemberscreen.dart';
import 'package:chatfrontend/presentation/screens/conversationscreen.dart';
import 'package:chatfrontend/presentation/screens/searchusers.dart';
import 'package:chatfrontend/presentation/screens/welcome.dart';
import 'package:chatfrontend/socketservice.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/userapiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chatscreentest.dart';
import '../providers/socketprovider.dart';

class Chatscreen extends ConsumerStatefulWidget {
  const Chatscreen({super.key});

  @override
  ConsumerState<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends ConsumerState<Chatscreen> {
  final userAPIService = UserAPIService();
  late TokenService authService;

  @override
  void initState() {
    super.initState();
    authService = ref.read(tokenProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final socket = ref.watch(socketService);

    int counter = 0;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: TextButton(
                  onPressed: () async {
                    final token = authService.token;
                    if (token != '' && authService.isAuthenticated) {
                      await userAPIService.logout(token);
                    }
                    print(" login out...");
                    await authService.clearToken();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Welcome()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text("LOGOUT"),
                ),
              ),
              SizedBox(height: 40),
              Center(
                child: TextButton(
                  onPressed: () async {
                    print(socket.isConnected);
                    print(socket.isSubscribed);
                    final token = authService.token;
                    if (token == '' || !authService.isAuthenticated) {
                      await authService.clearToken();
                      return;
                    }
                    counter++;
                  },
                  child: Text("Send"),
                ),
              ),
              // Center(
              //   child: TextButton(
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => ChatscreenTest(conversation: null,)),
              //       );
              //     },
              //     child: Text("ChatList"),
              //   ),
              // ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TestScreen()),
                    );
                  },
                  child: Text("Type Test"),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchUsers()),
                    );
                  },
                  child: Text("Search Users"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationScreen(),
                    ),
                  );
                },
                child: Text("Conversation List"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatMembers(
                          userIdList: ["e71e45bb-d50c-4c41-953c-ec23e93e51e4",
                            "cb571f2d-03ce-49ca-ab0f-d9a40e0cd584",
                            "91ccdbef-a3f4-4514-a20b-1d097f8b538c",
                            "f0ec8810-1a48-4897-910b-6f932df12a35"],
                          conversationType: "GROUP"),
                    ),
                  );
                },
                child: Text("Chat members"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

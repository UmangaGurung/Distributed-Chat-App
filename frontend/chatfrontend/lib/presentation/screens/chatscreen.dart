import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/conversationscreen.dart';
import 'package:chatfrontend/presentation/screens/searchusers.dart';
import 'package:chatfrontend/presentation/screens/user/userprofile.dart';

import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/userapiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixelarticons/pixelarticons.dart';


import '../providers/socketprovider.dart';
import 'package:chatfrontend/constants.dart' as constColor;

class Chatscreen extends ConsumerStatefulWidget {
  const Chatscreen({super.key});

  @override
  ConsumerState<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends ConsumerState<Chatscreen> {
  int _index = 0;

  final userAPIService = UserAPIService();
  late TokenService authService;

  final List<Widget> widgets= [
    ConversationScreen(),
    SearchUsers(),
    UserProfile()
  ];

  @override
  void initState() {
    super.initState();
    authService = ref.read(tokenProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    final socket = ref.watch(socketService);

    return Scaffold(
      body: widgets.elementAt(_index),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: constColor.blackcolor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Pixel.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Pixel.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Pixel.user), label: "Profile")
        ],
        unselectedIconTheme: IconThemeData(
          color: constColor.magentacolor,
              size: 25
        ),
        selectedIconTheme: IconThemeData(
          color: constColor.magentacolor,
          size: 28
        ),
        showUnselectedLabels: false,
        selectedItemColor: constColor.cyancolor,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
        ),
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index= index;
          });
        }
      ),
    );
  }
}

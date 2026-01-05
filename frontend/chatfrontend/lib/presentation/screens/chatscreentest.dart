import 'package:chatfrontend/dto/conversation/conversation&userdetailsdto.dart';
import 'package:chatfrontend/presentation/providers/chatmessagestate.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as provider;
import '../providers/messageprovider.dart';
import '../providers/socketprovider.dart';
import 'package:chatfrontend/constants.dart' as constColor;

import 'package:pixelarticons/pixelarticons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //debugPaintSizeEnabled = true;
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.pressStart2pTextTheme()),
      home: ChatscreenTest(),
    ),
  );
}

class ChatscreenTest extends ConsumerStatefulWidget {
  // final ConversationAndUserDetailsDTO conversation;
  // const ChatscreenTest({required this.conversation, super.key});
  const ChatscreenTest({super.key});

  @override
  ConsumerState<ChatscreenTest> createState() => _ChatscreenState();
}

class _ChatscreenState extends ConsumerState<ChatscreenTest> {
  late final ChatMessageState chatMessageState;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final convoDetails = widget.conversation.conversationResponseDTO;
    // final participantDetails = widget.conversation.participantDetailsDTO;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: constColor.blackcolor,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Pixel.chevronleft),
          color: constColor.magentacolor,
          iconSize: 25,
        ),
        titleSpacing: 0,
        title: const Text(
          "CONVERSATION NAME",
          style: TextStyle(color: constColor.cyancolor, fontSize: 12),
          textAlign: TextAlign.left,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Pixel.morevertical),
            color: constColor.magentacolor,
            iconSize: 25,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: 30,
                itemBuilder: (context, index) {
                  return ListTile(title: Text("Message ${index}"));
                },
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Pixel.camera)),
                  IconButton(onPressed: () {}, icon: Icon(Pixel.imagegallery)),
                   Container(
                      height: 35,
                      width: 90,
                      padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: constColor.magentacolor
                          )
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none
                          ),
                          keyboardType: TextInputType.multiline,
                        ),
                  ),
                  IconButton(onPressed: () {}, icon: Icon(Pixel.arrowbarright))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

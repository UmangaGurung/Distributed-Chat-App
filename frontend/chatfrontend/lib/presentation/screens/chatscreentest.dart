import 'package:chatfrontend/dto/conversation/conversation&userdetailsdto.dart';
import 'package:chatfrontend/presentation/providers/chatmessagestate.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/messageprovider.dart';
import '../providers/socketprovider.dart';
import 'package:chatfrontend/constants.dart' as constColor;

import 'package:pixelarticons/pixelarticons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // debugPaintSizeEnabled = true;
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(textTheme: GoogleFonts.pressStart2pTextTheme()),
        home: ChatscreenTest(),
      ),
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
      backgroundColor: constColor.blackcolor,
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
          style: TextStyle(color: constColor.cyancolor, fontSize: 14),
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
                  return ListTile(title: Text("Message ${index}", style: TextStyle(color: constColor.magentacolor),));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 6),
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    iconSize: 38,
                    color: constColor.cyancolor,
                    icon: Icon(Pixel.camera),
                  ),
                  SizedBox(width: 6),
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    iconSize: 38,
                    color: constColor.cyancolor,
                    icon: Icon(Pixel.imagegallery),
                  ),
                  SizedBox(width: 6),
                  Expanded(child: TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: constColor.magentacolor
                        )
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: constColor.magentacolor,
                            width: 2
                          )
                      )
                    ),
                  )),
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    iconSize: 38,
                    color: constColor.cyancolor,
                    icon: Icon(Pixel.arrowbarright),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

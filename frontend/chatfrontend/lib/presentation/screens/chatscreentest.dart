import 'dart:math';

import 'package:chatfrontend/cache/model/userdetailscache.dart';
import 'package:chatfrontend/cache/service/hivemessageservice.dart';
import 'package:chatfrontend/cache/service/hiveuserservice.dart';
import 'package:chatfrontend/conversationservice.dart';
import 'package:chatfrontend/dto/conversation/conversation&userdetailsdto.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:chatfrontend/dto/message/messagedetailsdto.dart';
import 'package:chatfrontend/dto/message/messageresponsedto.dart';
import 'package:chatfrontend/presentation/providers/chatmessagestate.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/chat/chatbubble.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../tokenutil.dart';
import '../providers/messageprovider.dart';
import '../providers/socketprovider.dart';

import 'package:pixelarticons/pixelarticons.dart';
import 'package:chatfrontend/constants.dart' as constColor;

class ChatscreenTest extends ConsumerStatefulWidget {
  final ConversationAndUserDetailsDTO conversation;
  const ChatscreenTest({required this.conversation, super.key});

  @override
  ConsumerState<ChatscreenTest> createState() => _ChatscreenState();
}

class _ChatscreenState extends ConsumerState<ChatscreenTest> {
  late final ChatMessageState chatMessageState;
  final ConversationAPIService conversationAPIService= ConversationAPIService();

  final HiveMessageService hiveMessageService= HiveMessageService();
  final HiveUserService hiveUserService= HiveUserService();

  List<MessageDetailsDTO> messageList= [];

  final messageField = TextEditingController();

  late TokenService tokenService;
  late String userId;

  late final response;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokenService = ref.read(tokenProvider.notifier);
    final token= tokenService.tokenDecode();
    userId= token['sub'];
    _getMessages();
  }

  Future<void> _getMessages() async {
    final conversationId= widget.conversation.conversationResponseDTO.conversationID;

    if (!tokenService.isAuthenticated) {
      if (!mounted) {
        return;
      }
      await ifTokenIsInvalid(context, tokenService);
      return;
    }

    final token = tokenService.token;

    List<MessageResponseDTO> cachedMessages= [];
    if (!await hiveMessageService.isExpired(conversationId)){
      print("Loading messages from hive");
      cachedMessages= hiveMessageService.getMessages(
          conversationId,
          0
      );
      final userIdList= widget.conversation.conversationResponseDTO.participantId;
      final cachedUserDetails= hiveUserService.getAllCachedUserDetails(
        userIdList
      );

      response = cachedMessages.map((message) {
        final participantDetails = cachedUserDetails[message.senderId];
        if (participantDetails == null) return null;
        return MessageDetailsDTO(
          messageResponseDTO: message,
          userDetailsDTO: participantDetails,
        );
      }).whereType<MessageDetailsDTO>().toList();
    }

    if (cachedMessages.isEmpty){
      if (await hiveMessageService.isExpired(conversationId)){
        print("Cached has expired as well");
      }
      print("Loading messages from API");
      List<MessageDetailsDTO> apiResponse = await conversationAPIService.getConversationMessages(
          token,
          widget.conversation.conversationResponseDTO.conversationID
      );

      response= apiResponse;

      final messageDetailsList= apiResponse.map((m) => m.messageResponseDTO).toList();
      final userDetailsList= apiResponse.map((u) => u.userDetailsDTO).toList();

      await hiveMessageService.addMessagesToHive(messageDetailsList, conversationId);
      await hiveUserService.addListOfUserDetailsToCache(userDetailsList);
      await hiveMessageService.setExpirationTime(conversationId);
    }

    print(response);
    if (!mounted) {
      return;
    }

    setState(() {
      messageList= response;
      isLoading= false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    messageField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final convoDetails = widget.conversation.conversationResponseDTO;
    final participantDetails = widget.conversation.participantDetailsDTO;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: constColor.blackcolor,
        body: Center(child: CircularProgressIndicator(color: constColor.magentacolor)),
      );
    }

    print("THis is inside the chat + ${messageList}");
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
        title: Text(
          convoDetails.conversationName,
          style: const TextStyle(color: constColor.cyancolor, fontSize: 14),
          textAlign: TextAlign.left,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {

              });
            },
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
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  final message= messageList[index];
                  return MessageBubble(
                    messageResponseDTO: message.messageResponseDTO,
                    senderDetailsDTO: message.userDetailsDTO,
                    userId: userId
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
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
                  Expanded(
                    child: TextField(
                      controller: messageField,
                      maxLength: 500,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: constColor.magentacolor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: constColor.magentacolor,
                            width: 2,
                          ),
                        ),
                        counterText: '',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {

                    },
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

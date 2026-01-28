import 'dart:async';

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
import 'package:chatfrontend/socketservice.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:flutter/material.dart';
import '../../tokenutil.dart';
import '../providers/socketprovider.dart';

import 'package:pixelarticons/pixelarticons.dart';
import 'package:chatfrontend/constants.dart' as constColor;

import 'chatmemberscreen.dart';
import 'editchatscreen.dart';

class ChatscreenTest extends ConsumerStatefulWidget {
  final ConversationAndUserDetailsDTO conversation;
  const ChatscreenTest({required this.conversation, super.key});

  @override
  ConsumerState<ChatscreenTest> createState() => _ChatscreenState();
}

class _ChatscreenState extends ConsumerState<ChatscreenTest> {
  static const String separator = '\u2021';
  final ConversationAPIService conversationAPIService =
      ConversationAPIService();

  final HiveMessageService hiveMessageService = HiveMessageService();
  final HiveUserService hiveUserService = HiveUserService();

  final ScrollController _scrollController = ScrollController();
  final _limit = 20;

  List<MessageDetailsDTO> messageList = [];

  final messageField = TextEditingController();

  late TokenService tokenService;
  late String userId;

  late SocketService socket;

  bool isLoading = true;
  bool firstFetch = true;
  bool apiFetch = false;
  bool updatingHive = false;

  Timer? _timer;
  Timer? _typingTimer;
  bool isTyping = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socket = ref.read(socketService);
    socket.subscribeToEvent(
      widget.conversation.conversationResponseDTO.conversationID,
    );
    tokenService = ref.read(tokenProvider.notifier);
    final token = tokenService.tokenDecode();
    userId = token['sub'];
    _getMessages('', '', _limit);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 30 &&
          !isLoading) {
        _getMessages(
          messageList.last.messageResponseDTO.messageId,
          messageList.last.messageResponseDTO.createdAt,
          _limit,
        );
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    messageField.dispose();
    socket.unSubscribeToEvent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final convoDetails = widget.conversation.conversationResponseDTO;

    final messageProviderState = ref.watch(messageProvider);

    final latestMessageState =
        messageProviderState[convoDetails.conversationID] ?? [];

    final typingEventProvider = ref.watch(eventProvider);
    final latestEvent = typingEventProvider[convoDetails.conversationID] ?? {};
    latestEvent.remove(userId);

    print(latestEvent.keys.toList());

    if (isLoading) {
      return const Scaffold(
        backgroundColor: constColor.blackcolor,
        body: Center(
          child: CircularProgressIndicator(color: constColor.magentacolor),
        ),
      );
    }

    Set<String> messageIds = messageList
        .map((m) => m.messageResponseDTO.messageId)
        .toSet();

    List<MessageDetailsDTO> deduplicatedState = latestMessageState.where((ms) {
      return !messageIds.contains(ms.messageResponseDTO.messageId);
    }).toList();

    List<MessageDetailsDTO> allMessages = [
      ...deduplicatedState,
      ...messageList,
    ];

    return Scaffold(
      backgroundColor: constColor.blackcolor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: constColor.blackcolor,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
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
          PopupMenuButton(
            icon: const Icon(Pixel.morevertical),
            iconSize: 25,
            iconColor: constColor.magentacolor,
            color: constColor.blackcolor,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditChatScreen()),
                  );
                  break;
                case 'members':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatMembers(
                        userIdList: convoDetails.participantId,
                        conversationType: convoDetails.type,
                        conversationAdmin: convoDetails.adminId,
                      ),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text(
                  'Edit Chat',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const PopupMenuItem(
                value: 'members',
                child: Text(
                  'Chat Members',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount:
                    allMessages.length +
                    (apiFetch ? 1 : 0) +
                    (latestEvent.isNotEmpty ? 1 : 0) +
                    (updatingHive ? 1 : 0),
                itemBuilder: (context, index) {

                  if (updatingHive && index == 0) {
                    return const Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (apiFetch && index == allMessages.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (latestEvent.isNotEmpty && index == 0) {
                    List<String> values = latestEvent.values
                        .toList()
                        .map((img) => img.split(separator).first)
                        .toList();
                    print("here $values");
                    List<String> images = values.map((img) {
                      if (!img.startsWith("https")) {
                        return "http://192.168.1.74:8081/photos/${img.split('/').last}";
                      }
                      return img;
                    }).toList();

                    print("Typing $images");

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: constColor.cyancolor),
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Rounded corners
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 8),
                              ...images.map(
                                (image) => Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: ClipOval(
                                    child: Image.network(
                                      image,
                                      fit: BoxFit.cover,
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "Is typing....",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  int messageIndex =
                      index - (latestEvent.isNotEmpty ? 1 : 0) - (updatingHive ? 1 : 0);
                  final message = allMessages[messageIndex];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: MessageBubble(
                      key: ValueKey(message.messageResponseDTO.messageId),
                      messageResponseDTO: message.messageResponseDTO,
                      senderDetailsDTO: message.userDetailsDTO,
                      userId: userId,
                    ),
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
                      onChanged: (value) {
                        _timer?.cancel();

                        _timer = Timer(Duration(milliseconds: 2500), () {
                          socket.typingEvent(
                              convoDetails.conversationID,
                              userId,
                              'NOT_TYPING');
                          _typingTimer?.cancel();
                          isTyping = false;
                        });

                        if (!isTyping) {
                          isTyping = true;
                          socket.typingEvent(
                            convoDetails.conversationID,
                            userId,
                            'TYPING',
                          );
                        }
                      },
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
                    onPressed: () async {
                      if (!tokenService.isAuthenticated) {
                        await ifTokenIsInvalid(context, tokenService);
                        return;
                      }
                      if (messageField.text.isEmpty) {
                        return;
                      }
                      if (!socket.isConnected || !socket.isSubscribed) {
                        //show message sent failed
                      }
                      socket.sendMessage(
                        messageField.text,
                        convoDetails.conversationID,
                        'TEXT',
                      );
                      setState(() {
                        messageField.clear();
                      });
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

  Future<void> _getMessages(
    String messageId,
    String timeStamp,
    int limit,
  ) async {
    if (apiFetch) {
      return;
    }

    setState(() {
      apiFetch = true;
    });

    List<MessageDetailsDTO> response = [];

    final conversationId =
        widget.conversation.conversationResponseDTO.conversationID;

    if (!tokenService.isAuthenticated) {
      if (!mounted) {
        return;
      }
      await ifTokenIsInvalid(context, tokenService);
      return;
    }

    final token = tokenService.token;

    List<MessageResponseDTO> cachedMessages = [];
    if (!await hiveMessageService.isExpired(conversationId) &&
        hiveMessageService.doesMessageExist(conversationId, 'api') &&
        firstFetch == true) {
      print("Loading messages from hive");

      cachedMessages = hiveMessageService.getMessages(conversationId);
      final userIdList =
          widget.conversation.conversationResponseDTO.participantId;
      final cachedUserDetails = hiveUserService.getAllCachedUserDetails(
        userIdList,
      );

      response = cachedMessages
          .map((message) {
            final participantDetails = cachedUserDetails[message.senderId];
            if (participantDetails == null) return null;
            return MessageDetailsDTO(
              messageResponseDTO: message,
              userDetailsDTO: participantDetails,
            );
          })
          .whereType<MessageDetailsDTO>()
          .toList();

      if (cachedMessages.first.messageId !=
          widget.conversation.conversationResponseDTO.lastMessageId) {
        setMessageState(response);
        setState(() {
          updatingHive = true;
        });

        print(updatingHive);
        final List<MessageDetailsDTO> latestMessage= await conversationAPIService.getLatestMessages(
            token, cachedMessages.first.messageId, cachedMessages.first.createdAt, conversationId);

        print(latestMessage);
        setState(() {
          messageList= [...latestMessage, ...messageList];
          updatingHive= false;
        });

        return;
      }
    }

    if (cachedMessages.isEmpty) {
      print("Loading messages from API since cache is empty");
      List<MessageDetailsDTO> apiResponse = await conversationAPIService
          .getConversationMessages(
            token,
            widget.conversation.conversationResponseDTO.conversationID,
            messageId,
            timeStamp,
            limit,
            firstFetch,
          );

      response = apiResponse;

      if (firstFetch) {
        print('Since first fetch');
        final messageDetailsList = apiResponse
            .map((m) => m.messageResponseDTO)
            .toList();
        final userDetailsList = apiResponse
            .map((u) => u.userDetailsDTO)
            .toList();

        await hiveMessageService.addMessagesToHive(
          messageDetailsList,
          conversationId,
        );

        Set<String> userIdSet = apiResponse
            .map((u) => u.userDetailsDTO.userId)
            .toSet();

        await hiveUserService.addListOfUserDetailsToCache(userDetailsList);
        await hiveUserService.setExpirationTimeBulk(userIdSet);
        await hiveMessageService.setExpirationTime(conversationId);
      }
    }

    print(response);
    if (!mounted) {
      return;
    }

    if (!firstFetch) {
      await Future.delayed(Duration(milliseconds: 500));
    }

   setMessageState(response);
  }

  void setMessageState(List<MessageDetailsDTO> response){
    setState(() {
      messageList= [...messageList, ...response];
      isLoading= false;
      if(firstFetch) {
        firstFetch= false;
      }
      apiFetch= false;
    });
  }
}

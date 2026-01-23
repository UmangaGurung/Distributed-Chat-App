import 'package:chatfrontend/conversationservice.dart';
import 'package:chatfrontend/dto/conversation/conversation&userdetailsdto.dart';
import 'package:chatfrontend/dto/message/messagedetailsdto.dart';
import 'package:chatfrontend/presentation/providers/socketprovider.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/chatscreentest.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/tokenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/constants.dart' as constants;

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final ConversationAPIService conversationAPIService =
      ConversationAPIService();
  late TokenService tokenService;
  late String userId;

  List<ConversationAndUserDetailsDTO> conversationList = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokenService = ref.read(tokenProvider.notifier);
    final claims = tokenService.tokenDecode();
    userId = claims['sub'];
    _loadAllConversations();
  }

  Future<void> _loadAllConversations() async {
    if (!tokenService.isAuthenticated) {
      if (!mounted) {
        return;
      }
      await ifTokenIsInvalid(context, tokenService);
      return;
    }

    final token = tokenService.token;
    final response = await conversationAPIService.getAllConversations(token);

    if (!mounted) {
      return;
    }

    setState(() {
      conversationList = response;
      isLoading = false;
    });
  }

  TextStyle latestMessageColor(double i) {
    return TextStyle(
      color: constants.magentacolor.withValues(alpha: i),
      fontSize: 10,
    );
  }

  List<dynamic> _extractConversationDetails(
    ConversationAndUserDetailsDTO conversation,
    List<MessageDetailsDTO> latestMessageState,
  ) {

    List<dynamic> extractedDetails = [];
    if (latestMessageState.isEmpty) {
      extractedDetails.add(conversation.conversationResponseDTO.lastMessage);
      extractedDetails.add('');
      extractedDetails.add(latestMessageColor(0.5));
      extractedDetails.add(conversation.conversationResponseDTO.updatedAt);
    } else if (latestMessageState.isNotEmpty) {
      final String latestMessageSenderId= latestMessageState.first.messageResponseDTO.senderId;
      final messageDTO= latestMessageState.first.messageResponseDTO;

      if (latestMessageSenderId==userId){
        extractedDetails.add(messageDTO.message);
        extractedDetails.add('');
        extractedDetails.add(latestMessageColor(0.5));
        extractedDetails.add(messageDTO.createdAtFormatted);
      }else {
        extractedDetails.add(latestMessageState.length == 1
            ? messageDTO.message
            : 'New Messages');
        extractedDetails.add(latestMessageState.length.toString());
        extractedDetails.add(latestMessageColor(1));
        extractedDetails.add(messageDTO.createdAtFormatted);
      }
    }

    return extractedDetails;
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageProvider);
    final conversationState = ref.watch(conversationProvider);
    final conversationStateList = conversationState.values.toList();


    if (isLoading) {
      return const Scaffold(
        backgroundColor: constants.blackcolor,
        body: Center(
          child: CircularProgressIndicator(color: constants.magentacolor),
        ),
      );
    }

    List<String> convoIdList= conversationState.keys.toList();

    List<ConversationAndUserDetailsDTO> filteredConversationList=
        conversationList.where(
            (c) => !convoIdList.contains(c.conversationResponseDTO.conversationID)
        ).toList();

    return Scaffold(
      backgroundColor: constants.blackcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: constants.blackcolor,
        title: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Text(
            "CONVERSATIONS",
            style: TextStyle(color: constants.cyancolor, fontSize: 20),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 25),
              ...List.generate(
                filteredConversationList.length + conversationStateList.length,
                (index) {
                  late final ConversationAndUserDetailsDTO conversation;
                  late final String conversationId;

                  late final List<MessageDetailsDTO> latestMessageState;

                  String latestMessage;
                  String messageCount;
                  TextStyle messageStyle;
                  String messageDate;

                  if (conversationStateList.isNotEmpty &&
                      index < conversationStateList.length) {
                    conversation = conversationStateList[index];
                    conversationId = conversation.conversationResponseDTO.conversationID;

                    latestMessageState = messageState[conversationId] ?? [];

                    List<dynamic> extractedDetails =
                        _extractConversationDetails(
                          conversation,
                          latestMessageState,
                        );

                    latestMessage = extractedDetails.elementAt(0);
                    messageCount = extractedDetails.elementAt(1);
                    messageStyle = extractedDetails.elementAt(2);
                    messageDate = extractedDetails.elementAt(3);
                  } else {
                    final fromApi = index - conversationState.length;
                    conversation = filteredConversationList[fromApi];
                    conversationId =
                        conversation.conversationResponseDTO.conversationID;

                    latestMessageState = messageState[conversationId] ?? [];

                    List<dynamic> extractedDetails =
                        _extractConversationDetails(
                          conversation,
                          latestMessageState,
                        );

                    latestMessage = extractedDetails.elementAt(0);
                    messageCount = extractedDetails.elementAt(1);
                    messageStyle = extractedDetails.elementAt(2);
                    messageDate = extractedDetails.elementAt(3);
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatscreenTest(conversation: conversation),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      padding: const EdgeInsets.all(12.0),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  conversation.conversationResponseDTO.type ==
                                      "BINARY"
                                  ? Image.network(
                                      conversation
                                          .participantDetailsDTO!
                                          .photoUrl,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      "assets/icon/logo.png",
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    conversation.conversationResponseDTO.type ==
                                            "BINARY"
                                        ? conversation
                                              .participantDetailsDTO!
                                              .userName
                                        : conversation
                                              .conversationResponseDTO
                                              .conversationName,
                                    style: TextStyle(
                                      color: constants.cyancolor,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    latestMessage,
                                    style: messageStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 70,
                            padding: const EdgeInsets.only(left: 15.0),
                            alignment: Alignment.topRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  messageDate,
                                  style: TextStyle(
                                    color: constants.cyancolor.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 8,
                                  ),
                                ),
                                SizedBox(height: 28),
                                if (messageCount.isNotEmpty)
                                  Container(
                                    width: 15,
                                    height: 15,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: constants.magentacolor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      messageCount,
                                      style: TextStyle(
                                        color: constants.cyancolor,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

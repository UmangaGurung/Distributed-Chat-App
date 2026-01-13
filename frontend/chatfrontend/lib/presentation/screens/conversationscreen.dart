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
import 'package:google_fonts/google_fonts.dart';

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
    final claims= tokenService.tokenDecode();
    userId= claims['sub'];
    _loadAllConversations();
  }

  Future<void> _loadAllConversations() async {
    if (!tokenService.isAuthenticated) {
      if (!mounted){
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

  TextStyle latestMessageColor(double i){
    return TextStyle(
      color: constants.magentacolor.withValues(alpha: i), fontSize: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageService= ref.watch(messageProvider);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: constants.blackcolor,
        body: Center(child: CircularProgressIndicator(color: constants.magentacolor)),
      );
    }

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
            style: TextStyle(color: constants.cyancolor),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 25),
              ...List.generate(conversationList.length, (index) {
                final conversation = conversationList[index];
                final convoId= conversation.conversationResponseDTO.conversationID;

                final latestMessageState= messageService[convoId];

                final excludedUserMessages= latestMessageState?.where(
                    (m)=> m.messageResponseDTO.senderId!=userId
                ).toList() ?? [];

                String messageDate;
                String latestMessage;
                String messageCount;
                TextStyle messageStyle;

                if (latestMessageState==null || latestMessageState.isEmpty){
                  latestMessage= conversation.conversationResponseDTO.lastMessage;
                  messageCount= '';
                  messageStyle= latestMessageColor(0.5);
                  messageDate= conversation.conversationResponseDTO.updatedAt;
                } else if (excludedUserMessages.isNotEmpty && excludedUserMessages.length>1){
                  latestMessage= "New Messages";
                  messageCount= excludedUserMessages.length.toString();
                  messageStyle= latestMessageColor(1);
                  messageDate= excludedUserMessages.first.messageResponseDTO.createdAtFormatted;
                } else if (excludedUserMessages.isNotEmpty && excludedUserMessages.length==1){
                  final messageDTO= excludedUserMessages.first;
                  latestMessage= messageDTO.messageResponseDTO.message;
                  messageCount= excludedUserMessages.length.toString();
                  messageStyle= latestMessageColor(1);
                  messageDate= messageDTO.messageResponseDTO.createdAtFormatted;
                } else {
                  latestMessage= latestMessageState.first.messageResponseDTO.message;
                  messageCount= '';
                  messageStyle= latestMessageColor(0.5);
                  messageDate= conversation.conversationResponseDTO.updatedAt;
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
              }),
            ],
          ),
        ),
      ),
    );
  }
}

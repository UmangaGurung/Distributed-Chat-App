import 'package:chatfrontend/cache/service/hiveuserservice.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMembers extends ConsumerStatefulWidget {
  final ParticipantDetails participantDetails;
  final List<String> userIdList;
  final String conversationType;
  const ChatMembers({
    required this.participantDetails,
    required this.userIdList,
    required this.conversationType,
    super.key
  });

  @override
  ConsumerState<ChatMembers> createState() => _ChatMembersState();
}

class _ChatMembersState extends ConsumerState<ChatMembers> {
  final HiveUserService hiveUserService= HiveUserService();
  late final TokenService tokenService;
  
  bool hasLoaded= false;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokenService= ref.read(tokenProvider.notifier);
    getUserDetails();
  }
  
  Future<void> getUserDetails() async{
    switch (widget.conversationType){
      case 'GROUP':
        List<String> expiredIds= await hiveUserService.isExpiredBulkCheck(widget.userIdList);


      case 'BINARY':
    }
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(

    );
  }
}

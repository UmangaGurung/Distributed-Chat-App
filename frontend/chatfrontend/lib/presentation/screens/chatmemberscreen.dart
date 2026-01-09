import 'package:chatfrontend/cache/service/hiveuserservice.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/userapiservice.dart';
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
    super.key,
  });

  @override
  ConsumerState<ChatMembers> createState() => _ChatMembersState();
}

class _ChatMembersState extends ConsumerState<ChatMembers> {
  final HiveUserService hiveUserService = HiveUserService();
  final UserAPIService userAPIService = UserAPIService();

  late final TokenService tokenService;
  List<ParticipantDetails> userDetailsList = [];

  bool hasLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokenService = ref.read(tokenProvider.notifier);

    getUserDetails();
  }

  Future<void> getUserDetails() async {
    if (!tokenService.isAuthenticated) {
      //token invalidation logic
      return;
    }

    final claims = tokenService.tokenDecode();
    ParticipantDetails currentUserDetails = ParticipantDetails(
      userId: claims['sub'],
      userName: claims['userName'],
      photoUrl: claims['photo'],
      phoneNumber: claims['phone'],
    );

    switch (widget.conversationType) {
      case 'GROUP':
        Set<String> expiredUserIds = await hiveUserService.isExpiredBulkCheck(
          widget.userIdList,
        );
        Set<String> notExpiredUserIds = widget.userIdList
            .where((id) => !expiredUserIds.contains(id))
            .toSet();
        List<ParticipantDetails> fetchedUserDetails = [];

        if (expiredUserIds.isNotEmpty) {
          final apiResponse = await userAPIService.getUserDetails(
            expiredUserIds,
          );
          fetchedUserDetails = [...apiResponse];

          await hiveUserService.addListOfUserDetailsToCache(apiResponse);
          //add expiration for them as well
        }

        final cacheResponse = hiveUserService
            .getAllCachedUserDetails(notExpiredUserIds.toList())
            .values
            .toList();
        fetchedUserDetails.addAll(cacheResponse);

        addToState([currentUserDetails, ...fetchedUserDetails]);
        break;

      case 'BINARY':
        final userDetail = widget.participantDetails;
        final Set<String> idList = {userDetail.userId};

        if (await hiveUserService.isExpired(userDetail.userId)) {
          final apiResponse = await userAPIService.getUserDetails(idList);

          addToState([currentUserDetails, ...apiResponse]);

          await hiveUserService.addListOfUserDetailsToCache(apiResponse);
          await hiveUserService.setExpirationTime(userDetail.userId);
          break;
        }

        final cacheResponse = hiveUserService
            .getAllCachedUserDetails(idList.toList())
            .values
            .toList();

        addToState([currentUserDetails, ...cacheResponse]);
        break;
    }
  }

  void addToState(List<ParticipantDetails> participationDetails) {
    if (!mounted) {
      return;
    }

    setState(() {
      userDetailsList = participationDetails;
      hasLoaded= true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

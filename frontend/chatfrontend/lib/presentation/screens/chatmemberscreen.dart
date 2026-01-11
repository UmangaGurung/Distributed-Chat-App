import 'package:chatfrontend/cache/service/hiveuserservice.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/userapiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/constants.dart' as constColor;

class ChatMembers extends ConsumerStatefulWidget {
  final List<String> userIdList;
  final String conversationType;

  const ChatMembers({
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
    print(widget.userIdList);
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    String token= tokenService.token;
    if (!tokenService.isAuthenticated) {
      //token invalidation logic
      return;
    }
    final claims = tokenService.tokenDecode();
    Map<String, dynamic> user = {};
    user['userId'] = claims['sub'];
    user['userName'] = claims['fullname'];
    user['photoUrl'] = claims['imagepath'];
    user['phoneNumber'] = claims['phone'];
    ParticipantDetails currentUserDetails = ParticipantDetails.fromJson(user);

    final List<String> participantIdList = widget.userIdList
        .where((id) => id != user['userId'])
        .toList();

    print("Token Id ${user['userId']}");
    switch (widget.conversationType) {
      case 'GROUP':
        Set<String> expiredUserIds = await hiveUserService.isExpiredBulkCheck(
          participantIdList,
        );
        print("Expired Ids $expiredUserIds");
        Set<String> notExpiredUserIds = participantIdList
            .where((id) => !expiredUserIds.contains(id))
            .toSet();
        print("UNExpired Ids $notExpiredUserIds");
        List<ParticipantDetails> fetchedUserDetails = [];

        if (expiredUserIds.isNotEmpty) {
          print("${expiredUserIds.length} user details have expired");

          final apiResponse = await userAPIService.getUserDetails(
            expiredUserIds,
            token
          );

          fetchedUserDetails = [...apiResponse];

          await hiveUserService.addListOfUserDetailsToCache(apiResponse);
          await hiveUserService.setExpirationTimeBulk(expiredUserIds);
          print("user Details from api $fetchedUserDetails");
        }

        print("fetching ${notExpiredUserIds.length} user details from cache");
        final cacheResponse = hiveUserService
            .getAllCachedUserDetails(notExpiredUserIds.toList())
            .values
            .toList();
        fetchedUserDetails.addAll(cacheResponse);

        print("userDetails from cache $cacheResponse");
        print("all user Details $fetchedUserDetails");

        addToState([currentUserDetails, ...fetchedUserDetails]);
        break;

      case 'BINARY':
        final String participantId = participantIdList.single;

        final Set<String> idList = {participantId};

        if (await hiveUserService.isExpired(participantId)) {
          final apiResponse = await userAPIService.getUserDetails(idList, token);

          addToState([currentUserDetails, ...apiResponse]);

          await hiveUserService.addListOfUserDetailsToCache(apiResponse);
          await hiveUserService.setExpirationTime(participantId);
          break;
        }

        final cacheResponse = hiveUserService.getUserDetails(participantId);

        addToState([currentUserDetails, cacheResponse]);
        break;
    }
  }

  void addToState(List<ParticipantDetails> participationDetails) {
    if (!mounted) {
      return;
    }
    setState(() {
      userDetailsList = participationDetails;
      hasLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasLoaded) {
      return const Scaffold(
        backgroundColor: constColor.blackcolor,
        body: Center(
          child: CircularProgressIndicator(color: constColor.magentacolor),
        ),
      );
    }
    return Scaffold(
      backgroundColor: constColor.blackcolor,
      appBar: AppBar(
        backgroundColor: constColor.blackcolor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "CHAT MEMBERS",
          style: const TextStyle(color: constColor.cyancolor, fontSize: 14),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: userDetailsList.length,
          itemBuilder: (context, index) {
            final user = userDetailsList[index];
            return ListTile(
              leading: Container(
                height: 70,
                width: 60,
                decoration: BoxDecoration(
                  color: constColor.blackcolor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(user.photoUrl, fit: BoxFit.cover,
                    height: 70,
                    width: 60,),
                ),
              ),
              title: Text(
                user.userName,
                style: TextStyle(color: constColor.magentacolor),
              ),
              subtitle: Text(user.phoneNumber),
            );
          },
        ),
      ),
    );
  }
}

import 'package:chatfrontend/cache/service/hiveuserservice.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/initiatechatbutton.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/userapiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/constants.dart' as constColor;
import 'package:pixelarticons/pixel.dart';

class ChatMembers extends ConsumerStatefulWidget {
  final List<String> userIdList;
  final String conversationType;
  final String conversationAdmin;

  const ChatMembers({
    required this.userIdList,
    required this.conversationType,
    required this.conversationAdmin,
    super.key,
  });

  @override
  ConsumerState<ChatMembers> createState() => _ChatMembersState();
}

class _ChatMembersState extends ConsumerState<ChatMembers> {
  final HiveUserService hiveUserService = HiveUserService();
  final UserAPIService userAPIService = UserAPIService();

  late final TokenService tokenService;
  late final String userId;

  List<ParticipantDetails> userDetailsList = [];

  bool hasLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokenService = ref.read(tokenProvider.notifier);
    userId= tokenService.tokenDecode()['sub'];
    print(widget.userIdList);
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    setState(() {
      hasLoaded= false;
    });

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

    switch (widget.conversationType) {
      case 'GROUP':
        Set<String> expiredUserIds = await hiveUserService.isExpiredBulkCheck(
          participantIdList,
        );
        print("Expired Ids $expiredUserIds");
        Set<String> notExpiredUserIds = participantIdList
            .where((id) => !expiredUserIds.contains(id))
            .toSet();
        print("Unexpired Ids $notExpiredUserIds");
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

        if (notExpiredUserIds.isNotEmpty) {
          print("fetching ${notExpiredUserIds.length} user details from cache");
          final cacheResponse = hiveUserService
              .getAllCachedUserDetails(notExpiredUserIds.toList())
              .values
              .toList();
          fetchedUserDetails.addAll(cacheResponse);

          print("userDetails from cache $cacheResponse");
          print("all user Details $fetchedUserDetails");
        }

        addToState([currentUserDetails, ...fetchedUserDetails]);
        break;

      case 'BINARY':
        final String participantId = participantIdList.single;

        final Set<String> idList = {participantId};

        if (await hiveUserService.isExpired(participantId)) {
          print("Yes, expired");
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
    print(participationDetails.toList());
    setState(() {
      userDetailsList = participationDetails;
      hasLoaded = true;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    userDetailsList= [];
    super.dispose();
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
        title: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: const Text(
            "CHAT MEMBERS",
            style: TextStyle(color: constColor.cyancolor, fontSize: 20),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 25,),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
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
                        ),
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
            const SizedBox(height: 25,),
            if (widget.conversationType=='GROUP'
                && widget.conversationAdmin==userId)
            ClipPath(
              clipper: InitiateChatButton(),
              child: GestureDetector(
                onTap: () {

                },
                child: Container(
                  height: MediaQuery.of(context).size.width*0.13,
                  width: MediaQuery.of(context).size.width*0.65,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Color(0xFFFF006E),
                          Color(0xFF8800FF),
                        ]
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Pixel.userplus,
                        color: constColor.cyancolor,
                      ),
                      SizedBox(width: 10,),
                      Text(
                        "ADD PEOPLE",
                        style: TextStyle(
                          color: constColor.cyancolor,
                          fontSize: 14
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25,),
          ],
        ),
      ),
    );
  }
}

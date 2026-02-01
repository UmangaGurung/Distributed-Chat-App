import 'package:chatfrontend/cache/service/hiveuserservice.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:chatfrontend/dto/usersearchresult.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/chat/creategroupcontinue.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/userapiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/constants.dart' as constColor;
import 'package:pixelarticons/pixelarticons.dart';

class CreateGroup extends ConsumerStatefulWidget {
  const CreateGroup({super.key});

  @override
  ConsumerState<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends ConsumerState<CreateGroup> {
  final HiveUserService hiveUserService = HiveUserService();
  final UserAPIService userAPIService = UserAPIService();

  late final TokenService tokenService;
  late final String token;
  late final String userId;

  bool isLoading = true;
  bool apiFetch = false;

  Map<String, bool> selectedUserMap = {};
  Map<String, ParticipantDetails> userMap = {};
  Map<String, ParticipantDetails> constUserMap = {};
  List<String> cachedUserPhone = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokenService = ref.read(tokenProvider.notifier);
    token = tokenService
        .token; // token may become null here so, add a session expired logic here
    userId = tokenService.tokenDecode()['sub'];

    fetchUsersFromHive();
  }

  Future<void> fetchUsersFromHive() async {
    setState(() {
      isLoading = true;
    });

    final List<ParticipantDetails> cachedUsers = hiveUserService
        .getAllCachedUserDetails([])
        .values
        .where((u) => u.userId != userId)
        .toList();

    if (cachedUsers.isEmpty) {
      print("Nothing to show");
      constUserMap = {};
      setState(() {
        isLoading = false;
      });
      return;
    }

    final Map<String, bool> initialUserState = {};
    final Map<String, ParticipantDetails> cachedUserMap = {};
    final List<String> userPhone = [];

    for (ParticipantDetails user in cachedUsers) {
      cachedUserMap[user.userId] = user;
      initialUserState[user.userId] = false;
      userPhone.add(user.phoneNumber);
    }

    constUserMap = {...cachedUserMap};

    setState(() {
      userMap = {...cachedUserMap};
      selectedUserMap = {...initialUserState};
      cachedUserPhone = userPhone;
      isLoading = false;
    });
  }

  void onSearchChanged(String input) async {
    List<String> matchedPhones = cachedUserPhone
        .where((p) => p.startsWith(input))
        .toList();

    Map<String, ParticipantDetails> filtered = Map.fromEntries(
      constUserMap.entries.where(
        (u) => matchedPhones.contains(u.value.phoneNumber),
      ),
    );

    setState(() {
      userMap = filtered;
    });

    if (filtered.isEmpty && input.length == 10) {
      if (filtered.values.any((u) => u.phoneNumber == input)) {
        return;
      }
      setState(() {
        apiFetch = true;
      });

      final response = await userAPIService.searchUsers(
        token,
        input,
      );

      ParticipantDetails participantDetails = ParticipantDetails(
        userId: response!.userId,
        userName: response.fullname,
        photoUrl: response.imageURL,
        phoneNumber: response.phoneNumber,
      );

      Map<String, ParticipantDetails> searchedUser = {
        participantDetails.userId: participantDetails,
      };

      setState(() {
        userMap = {...userMap, ...searchedUser};
        selectedUserMap = {...selectedUserMap}
          ..[participantDetails.userId] = false;
        apiFetch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: constColor.blackcolor,
        body: Center(
          child: CircularProgressIndicator(color: constColor.magentacolor),
        ),
      );
    }

    List<String> selectedUserIdList = selectedUserMap.entries
        .where((s) => s.value)
        .map((s) => s.key)
        .toList();

    return Scaffold(
      backgroundColor: constColor.blackcolor,
      appBar: AppBar(
        backgroundColor: constColor.blackcolor,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Pixel.chevronleft),
          color: constColor.magentacolor,
          iconSize: 30,
        ),
        titleSpacing: 0,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              final List<ParticipantDetails> selectedUsers = constUserMap
                  .entries
                  .where((k) => selectedUserIdList.contains(k.key))
                  .map((k) => k.value)
                  .toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateGroupContinue(userDetails: selectedUsers),
                ),
              );
            },
            child: const Icon(Pixel.userplus),
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 40),
        actionsIconTheme: IconThemeData(
          color: selectedUserMap.values.any((b) => b)
              ? constColor.magentacolor
              : Colors.grey,
          size: 30,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SearchBarTheme(
                data: SearchBarThemeData(
                  hintStyle: WidgetStatePropertyAll(
                    const TextStyle(color: Colors.grey),
                  ),
                ),
                child: SearchBar(
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(Icons.search, color: constColor.cyancolor),
                  ),
                  onChanged: onSearchChanged,
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  side: WidgetStateProperty.all(
                    BorderSide(color: constColor.magentacolor, width: 2.0),
                  ),
                  backgroundColor: WidgetStatePropertyAll(
                    constColor.blackcolor,
                  ),
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(color: constColor.cyancolor),
                  ),
                  hintText: 'Enter phone',
                  hintStyle: WidgetStatePropertyAll(
                    TextStyle(color: Colors.grey[200]),
                  ),
                ),
              ),
            ),

            if (selectedUserIdList.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(top: 15),
                height: 85,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedUserIdList.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 15);
                  },
                  itemBuilder: (context, index) {
                    final String userId = selectedUserIdList.elementAt(index);
                    final ParticipantDetails user = constUserMap[userId]!;
                    return SizedBox(
                      width: 55,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipOval(
                            child: Image.network(
                              user.photoUrl,
                              fit: BoxFit.cover,
                              width: 45,
                              height: 45,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user.userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: constColor.cyancolor,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: userMap.length + (apiFetch ? 1 : 0),
                itemBuilder: (context, index) {
                  if (apiFetch && index == userMap.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (index < userMap.length) {
                    final String userId = userMap.keys.elementAt(index);
                    final ParticipantDetails user = userMap[userId]!;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedUserMap[userId] =
                              !(selectedUserMap[user.userId] ?? false);
                          cachedUserPhone.add(user.phoneNumber);
                          constUserMap[userId] = user;
                        });
                        print("${user.userName} ${selectedUserMap[userId]}");
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: ClipOval(
                            child: Image.network(
                              user.photoUrl,
                              fit: BoxFit.cover,
                              width: 45,
                              height: 45,
                            ),
                          ),
                          title: Text(
                            user.userName,
                            style: TextStyle(
                              color: constColor.cyancolor,
                              fontSize: 12,
                            ),
                          ),
                          trailing: IgnorePointer(
                            child: Checkbox(
                              value: selectedUserMap[user.userId],
                              onChanged: (value) {},
                              activeColor: constColor.magentacolor,
                              shape: const CircleBorder(),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

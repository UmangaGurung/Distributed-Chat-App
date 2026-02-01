import 'dart:async';

import 'package:chatfrontend/conversationservice.dart';
import 'package:chatfrontend/dto/usersearchresult.dart';
import 'package:chatfrontend/presentation/providers/socketprovider.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/initiatechatbutton.dart';
import 'package:chatfrontend/dto/conversation/conversation&userdetailsdto.dart';
import 'package:chatfrontend/tokenutil.dart';
import 'package:chatfrontend/socketservice.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/userapiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:chatfrontend/constants.dart' as constants;
import 'package:marquee/marquee.dart';

import 'chatscreentest.dart';
import 'user/login.dart';


class SearchUsers extends ConsumerStatefulWidget {
  const SearchUsers({super.key});

  @override
  ConsumerState<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends ConsumerState<SearchUsers> {
  final ConversationAPIService conversationService= ConversationAPIService();
  late final TokenService tokenService;

  Timer? _debounce;
  final userService = UserAPIService();

  List<String>? userInfo;
  String? imageUrl;
  String? userId;

  static const List<dynamic> userInfoIcon = [
    Icons.person,
    Icons.email,
    Icons.phone,
  ];

  @override
  void initState() {
    super.initState();
    tokenService= ref.read(tokenProvider.notifier);
    userInfo= List.empty();
  }

  void onSearchChanged(String search) {
    _debounce?.cancel();

    if (search.length != 10) {
      setState(() {
        userInfo = null;
      });
      return;
    }

    _debounce = Timer(Duration(milliseconds: 300), () async {
        if (!tokenService.isAuthenticated){
          if (mounted) {
            await ifTokenIsInvalid(context, tokenService);
          }
          return;
        }

        final token= tokenService.token;

        final UserSearchResult result = await userService.searchUsers(token, search);

        if (!mounted){
          return;
        }

        setState(() {
          userInfo = <String>[
            result.fullname,
            result.email,
            result.phoneNumber,
          ];
          imageUrl = result.imageURL;
          userId= result.userId;
        });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  BorderSide borderColorMagenta() {
    return BorderSide(color: constants.magentacolor, width: 3);
  }

  BorderSide borderColorCyan() {
    return BorderSide(color: constants.cyancolor, width: 3);
  }

  BorderSide emptyBorderColor() {
    return BorderSide(color: constants.blackcolor, width: 0);
  }

  @override
  Widget build(BuildContext context) {
    final contentContainerHeight= MediaQuery.of(context).size.height*0.6;
    final contentContainerWidth= MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      backgroundColor: constants.blackcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: constants.blackcolor,
        title: Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text(
            "Search User",
            style: GoogleFonts.pressStart2p(
              textStyle: TextStyle(color: constants.cyancolor, fontSize: 14),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SearchBar(
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(Icons.search, color: constants.cyancolor),
                  ),
                  onChanged: onSearchChanged,
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  side: WidgetStateProperty.all(
                    BorderSide(color: constants.magentacolor, width: 2.0),
                  ),
                  backgroundColor: WidgetStatePropertyAll(constants.blackcolor),
                  textStyle: WidgetStatePropertyAll(
                    TextStyle(color: constants.cyancolor),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: contentContainerWidth,
                height: contentContainerHeight,
                child: Stack(
                  children: [
                    ...List.generate(4, (index) {
                      return Positioned(
                        top: index == 0 || index == 1 ? 0 : null,
                        right: index == 0 || index == 2 ? 0 : null,
                        left: index == 1 || index == 3 ? 0 : null,
                        bottom: index == 2 || index == 3 ? 0 : null,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: index == 0
                                  ? borderColorMagenta()
                                  : index == 1
                                  ? borderColorCyan()
                                  : emptyBorderColor(),
                              right: index == 0
                                  ? borderColorMagenta()
                                  : index == 2
                                  ? borderColorCyan()
                                  : emptyBorderColor(),
                              left: index == 3
                                  ? borderColorMagenta()
                                  : index == 1
                                  ? borderColorCyan()
                                  : emptyBorderColor(),
                              bottom: index == 2
                                  ? borderColorCyan()
                                  : index == 3
                                  ? borderColorMagenta()
                                  : emptyBorderColor(),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (userInfo != null && userInfo!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.all(contentContainerHeight*0.04),
                        child: Column(
                          children: [
                            SizedBox(height: contentContainerHeight*0.025),
                            ClipOval(
                              child: Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                width: contentContainerWidth*0.4,
                                height: contentContainerHeight*0.275,
                              ),
                            ),
                            SizedBox(height: contentContainerHeight*0.1),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: userInfo!.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          userInfoIcon[index],
                                          color: constants.magentacolor,
                                        ),
                                        SizedBox(width: 10), // spacing
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 3,
                                            ),
                                            child: userInfo![index].length < 18
                                                ? Text(
                                                    userInfo![index],
                                                    style: TextStyle(
                                                      color:
                                                          constants.cyancolor,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 20,
                                                    width: double.infinity,
                                                    child: Marquee(
                                                      text: userInfo![index],
                                                      style: TextStyle(
                                                        color:
                                                            constants.cyancolor,
                                                      ),
                                                      blankSpace: 50,
                                                      velocity: 30,
                                                      pauseAfterRound: Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      SizedBox(height: contentContainerHeight*0.072),
                            ),
                            Spacer(flex: 1,),
                            ClipPath(
                              clipper: InitiateChatButton(),
                              child: GestureDetector(
                                onTap: () async {
                                  if (!tokenService.isAuthenticated){
                                    if (mounted) {
                                      await ifTokenIsInvalid(context, tokenService);
                                    }
                                    return;
                                  }

                                  final token= tokenService.token;
                                  
                                  final conversation= await conversationService.createOrFindConversation(
                                      token, userId!);
                             
                                  if (conversation == null) {
                                    if (!mounted){
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to create/fetch conversation')),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChatscreenTest(conversation: conversation),
                                    ),
                                  );
                                },
                                child: Container(
                                  height:
                                      contentContainerHeight * 0.12,
                                  width:
                                      contentContainerWidth,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[
                                        Color(0xFFFF006E),
                                        Color(0xFF8800FF),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'SEND MESSAGE',
                                      style: TextStyle(
                                        color: constants.cyancolor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

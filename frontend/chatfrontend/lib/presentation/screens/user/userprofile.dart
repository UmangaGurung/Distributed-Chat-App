import 'package:chatfrontend/cache/service/hivemessageservice.dart';
import 'package:chatfrontend/cache/service/hiveuserservice.dart';
import 'package:chatfrontend/presentation/providers/socketprovider.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/userapiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/constants.dart' as constColor;
import 'package:marquee/marquee.dart';
import 'package:pixelarticons/pixelarticons.dart';

import '../initiatechatbutton.dart';
import '../welcome.dart';

void main() {
  debugPaintSizeEnabled = true;
  runApp(ProviderScope(child: MaterialApp(home: UserProfile())));
}

class UserProfile extends ConsumerStatefulWidget {
  const UserProfile({super.key});

  @override
  ConsumerState<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  final UserAPIService userAPIService = UserAPIService();
  late TokenService tokenService;
  late String token;

  final Map<String, IconData> details = {
    "Name": Pixel.user,
    "Email": Pixel.mail,
    "Phone": Pixel.devicephone,
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tokenService = ref.read(tokenProvider.notifier);
    token = tokenService.token;
  }

  String formatImage(String image) {
    if (image.startsWith("https")) {
      return image;
    }
    String img = "http://192.168.1.74:8081/photos/${image.split("/").last}";

    return img;
  }

  @override
  Widget build(BuildContext context) {
    final claims = tokenService.tokenDecode();
    final userName = claims['fullname'];
    final email = claims['email'];
    final phone = claims['phone'];
    final image = formatImage(claims['imagepath']);

    final List<String> userDetail = [userName, email, phone];

    return Scaffold(
      backgroundColor: constColor.blackcolor,
      appBar: AppBar(
        backgroundColor: constColor.blackcolor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text(
            "USER PROFILE",
            style: TextStyle(color: constColor.cyancolor, fontSize: 20),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: constColor.blackcolor, width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                image,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 50),
          Flexible(
            child: ListView.separated(
              itemCount: details.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        details.entries.elementAt(index).value,
                        color: constColor.magentacolor,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.entries.elementAt(index).key,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: constColor.cyancolor
                              ),
                            ),
                            if (userDetail[index].length > 15)
                              SizedBox(
                                height: 20,
                                width: double.infinity,
                                child: Marquee(
                                  text: userDetail[index],
                                  style: const TextStyle(
                                    color: constColor.cyancolor,
                                  ),
                                  startAfter: Duration(seconds: 1),
                                  velocity: 50,
                                  blankSpace: 50,
                                  pauseAfterRound: Duration(seconds: 2),
                                ),
                              )
                            else
                              Text(
                                userDetail[index],
                                style: TextStyle(color: constColor.cyancolor),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 30);
              },
            ),
          ),
          ClipPath(
            clipper: InitiateChatButton(),
            child: GestureDetector(
              onTap: () async {
                final userBox= HiveUserService();
                final messageBox= HiveMessageService();
                if (token != '' || tokenService.isAuthenticated) {
                  await userAPIService.logout(token);
                }

                ref.invalidate(conversationProvider);
                ref.invalidate(messageProvider);
                ref.invalidate(eventProvider);

                await userBox.clearHiveCache();
                await messageBox.clearMessageCache();
                await tokenService.clearToken();
                print("logging out....");
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Welcome()),
                        (Route<dynamic> route) => false,
                  );
                }else{
                  return;
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.width * 0.13,
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFFFF006E), Color(0xFF8800FF)],
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Pixel.logout, color: constColor.cyancolor),
                    SizedBox(width: 10),
                    Text(
                      "LOGOUT",
                      style: TextStyle(
                        color: constColor.cyancolor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

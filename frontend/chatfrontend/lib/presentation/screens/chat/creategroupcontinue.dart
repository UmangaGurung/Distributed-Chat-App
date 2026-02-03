import 'package:chatfrontend/consthost.dart';
import 'package:chatfrontend/conversationservice.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/chatscreentest.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/userapiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/constants.dart' as constColor;
import 'package:pixelarticons/pixel.dart';

class CreateGroupContinue extends ConsumerStatefulWidget {
  final List<ParticipantDetails> userDetails;
  const CreateGroupContinue({required this.userDetails, super.key});

  @override
  ConsumerState<CreateGroupContinue> createState() =>
      _CreateGroupContinueState();
}

class _CreateGroupContinueState extends ConsumerState<CreateGroupContinue> {
  final ConversationAPIService conversationAPIService= ConversationAPIService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupName = TextEditingController();

  late final List<ParticipantDetails> selectedUsers;

  late final TokenService tokenService;
  late final String token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedUsers = widget.userDetails;
    tokenService = ref.read(tokenProvider.notifier);
    token = tokenService.token;
  }

  String formatImage(String image) {
    if (image.startsWith("https")) {
      return image;
    }
    String img = "http://${HostConfig.host}:8081/photos/${image.split("/").last}";

    return img;
  }

  @override
  Widget build(BuildContext context) {
    final claims = tokenService.tokenDecode();
    final userName = claims['fullname'];
    final photo = formatImage(claims['imagepath']);

    List<String> userIdList= selectedUsers.map(
        (u) => u.userId
    ).toList();

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
        title: Text(
          "NEW GROUP",
          style: const TextStyle(color: constColor.cyancolor, fontSize: 14),
          textAlign: TextAlign.left,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _groupName,
                      style: TextStyle(
                        color: constColor.cyancolor,
                        fontSize: 12,
                      ),
                      maxLength: 15,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: "Enter group name",
                        hintStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: constColor.magentacolor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: constColor.magentacolor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: constColor.magentacolor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Text(
                    "ADMIN: (YOU)",
                    style: TextStyle(color: constColor.cyancolor.withValues(alpha: 0.7), fontSize: 10),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.network(
                          photo,
                          fit: BoxFit.cover,
                          width: 45,
                          height: 45,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        userName,
                        style: TextStyle(
                          color: constColor.cyancolor,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Text(
                    "MEMBERS: ${selectedUsers.length}",
                    style: TextStyle(color: constColor.cyancolor.withValues(alpha: 0.7), fontSize: 10, ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: selectedUsers.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) {
                        final user = selectedUsers[index];

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 0),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 35,
              right: 35,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: constColor.magentacolor,
                ),
                child: ClipOval(
                  child: TextButton(
                    onPressed: () async{
                      final conversation= await conversationAPIService
                          .createGroupConversation(token, _groupName.text, userIdList);

                      if (!context.mounted){
                        return;
                      }

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => ChatscreenTest(conversation: conversation)));
                    },
                    child: Icon(
                      Pixel.check,
                      color: constColor.cyancolor,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

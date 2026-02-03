import 'package:chatfrontend/consthost.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/chatscreen.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatfrontend/constants.dart' as constant;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatfrontend/userapiservice.dart';

class AddPhoneNumber extends ConsumerStatefulWidget {
  const AddPhoneNumber({super.key});

  @override
  ConsumerState<AddPhoneNumber> createState() => _AddPhoneNumberState();
}

class _AddPhoneNumberState extends ConsumerState<AddPhoneNumber> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> claims;
  late String token;
  late TokenService authService;

  String imageUrl = "";
  late TextEditingController fullNameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  final phoneController = TextEditingController();

  final userservice = UserAPIService();

  @override
  void initState() {
    super.initState();
    authService = ref.read(tokenProvider.notifier);
    token = authService.token;
    claims = authService.tokenDecode();

    final loginType = claims['loginType'];
    final rawPath = claims['imagepath'] ?? "";

    final fileName = rawPath.split('/').isNotEmpty
        ? rawPath.split('/').last
        : "";

    final url = loginType == "APPLOGIN"
        ? "http://${HostConfig.host}:8081/photos/$fileName"
        : rawPath;

    setState(() {
      imageUrl = url;
      fullNameController.text = claims['fullname'] ?? '';
      emailController.text = claims['email'] ?? '';
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: constant.blackcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 100),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                      ),
                      child: ClipOval(
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              )
                            : Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Full Name",
                      style: TextStyle(color: constant.cyancolor),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      readOnly: true,
                      controller: fullNameController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: constant.cyancolor, fontSize: 12),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constant.magentacolor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constant.magentacolor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constant.magentacolor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Email",
                      style: TextStyle(color: constant.cyancolor),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      readOnly: true,
                      controller: emailController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: constant.cyancolor, fontSize: 12),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constant.magentacolor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constant.magentacolor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constant.magentacolor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Phone",
                      style: TextStyle(color: constant.cyancolor),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: constant.cyancolor, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: "Enter your phone number",
                        hintStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constant.magentacolor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constant.magentacolor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constant.magentacolor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your phone";
                        } else if (value.length != 10) {
                          return "Invalid format";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          bool success;
                          try {
                            success = await userservice.addPhoneNumber(
                              claims['loginType'],
                              phoneController.text,
                              token,
                              authService,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed: $e")),
                            );
                            return;
                          }
                          if (success) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Chatscreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            constant.magentacolor,
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: constant.magentacolor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: constant.cyancolor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

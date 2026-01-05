import 'package:chatfrontend/googleregisterresponse.dart';
import 'package:chatfrontend/loginresult.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/addPhoneNumber.dart';
import 'package:chatfrontend/presentation/screens/register2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatfrontend/constants.dart' as constants;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../registerresponse.dart';
import '../../userapiservice.dart';
import 'chatscreen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formkey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmpassword = TextEditingController();

  bool _obscurePassword = true;

  final emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  final userservice= UserAPIService();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: constants.blackcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 40,),
                  SizedBox(
                    width: 150,
                    height: 90,
                    child: Image.asset('assets/icon/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: constants.blackcolor,
                          child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: constants.cyancolor,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Email",
                      style: TextStyle(color: constants.cyancolor),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: constants.cyancolor,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        hintStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constants.magentacolor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constants.magentacolor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constants.magentacolor),
                        ),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return "Please enter your email";
                        if (!emailRe.hasMatch(v))
                          return "Please enter a valid email";
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      style: TextStyle(color: constants.cyancolor),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      controller: _password,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: constants.cyancolor,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        hintStyle: TextStyle(fontSize: 12),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constants.magentacolor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constants.magentacolor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constants.magentacolor),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a password";
                        }
                        if (value.length < 6) {
                          return "Password is too short";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Confirm",
                      style: TextStyle(color: constants.cyancolor),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      controller: _confirmpassword,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: constants.cyancolor,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: "Confirm your password",
                        hintStyle: TextStyle(fontSize: 12),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constants.magentacolor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constants.magentacolor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: constants.magentacolor),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please re-enter your password";
                        }
                        if (value != _password.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formkey.currentState!.validate()) {
                            return;
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterContinue(
                                  email: _email.text.trim(),
                                  password: _password.text.trim(),
                                ),
                              ),
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            constants.magentacolor,
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: constants.magentacolor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            color: constants.cyancolor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Divider(
                              thickness: 1.5,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'or',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 25),
                            child: Divider(
                              thickness: 1.5,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.center,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final authService= ref.read(tokenProvider.notifier);
                        GoogleRegisterResponse response= await userservice.signInWithGoogle(authService);
                        if (response.status=="GOOGLE_LOGIN"
                            && response.loginResult==LoginResult.SUCCESS) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("SUCCESS")),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Chatscreen()),
                                (Route<dynamic> route) => false,
                          );
                        }else if (response.status=="GOOGLE_LOGIN"
                            && response.loginResult==LoginResult.INCOMPLETE_PROFILE){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("PLEASE COMPLETE YOUR PROFILE")),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => AddPhoneNumber()),
                                (Route<dynamic> route) => false,
                          );
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error. ${response.response}")),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.g_mobiledata,
                        color: constants.cyancolor,
                      ),
                      label: Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 12,
                          color: constants.magentacolor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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

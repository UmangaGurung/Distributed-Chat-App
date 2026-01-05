import 'package:chatfrontend/presentation/screens/login.dart';
import 'package:chatfrontend/registerresponse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatfrontend/constants.dart' as constants;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:chatfrontend/userapiservice.dart';

class RegisterContinue extends StatefulWidget {
  final String email;
  final String password;

  const RegisterContinue({
    required this.email,
    required this.password,
    super.key,
  });

  @override
  State<RegisterContinue> createState() => _RegisterContinueState();
}

class _RegisterContinueState extends State<RegisterContinue> {
  final _formkey = GlobalKey<FormState>();
  final _fullname = TextEditingController();
  final _phonenumber = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
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
      backgroundColor: constants.blackcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 100),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    alignment: Alignment.center,
                    child: Text(
                      "Upload Profile Picture",
                      style: TextStyle(
                        color: constants.cyancolor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Container(
                    margin: EdgeInsets.only(left: 25, right: 25),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Full Name",
                      style: TextStyle(color: constants.cyancolor),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      controller: _fullname,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: constants.cyancolor,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your name",
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
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        } else if (value.length < 4) {
                          return "Invalid format";
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
                      "Phone",
                      style: TextStyle(color: constants.cyancolor),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 22, right: 22),
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      controller: _phonenumber,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: constants.cyancolor,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your phone number",
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
                          if (!_formkey.currentState!.validate()) {
                            return;
                          }
                          if (_profileImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please select a profile image")),
                            );
                            return;
                          }
                          RegisterResponse response;
                          try {
                            response = await UserAPIService.registerUser(
                              widget.email,
                              widget.password,
                              _fullname.text,
                              _phonenumber.text,
                              _profileImage,
                            );
                          }catch(e){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Registration failed: $e")),
                            );
                            return;
                          }
                          if (response.status=="ACCOUNT_CREATED") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Successful. ${response.response}")),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          }else if (response.status=="FAILED"){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error. ${response.response}")),
                            );
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error. ${response.response}")),
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
                          "Sign Up",
                          style: TextStyle(
                            color: constants.cyancolor,
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

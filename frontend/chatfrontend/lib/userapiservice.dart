import 'dart:convert';
import 'dart:io';
import 'package:chatfrontend/dto/usersearchresult.dart';
import 'package:chatfrontend/loginresult.dart';
import 'package:chatfrontend/registerresponse.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:path/path.dart';
import 'package:chatfrontend/googleregisterresponse.dart';

class UserAPIService {
  static const String userurl = "http://192.168.1.74:8081/api/users";

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  Future<GoogleRegisterResponse> signInWithGoogle(TokenService authService) async {
    try {
      await googleSignIn.initialize(
        clientId:
            '313848747985-ahq6apuqkpivg5eeb8o19jfbv8oq77k7.apps.googleusercontent.com',
        serverClientId:
            '313848747985-v0j3covj1p3l8g79v8ineml6d3v93o8o.apps.googleusercontent.com',
      );

      final account = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile', 'openid'],
      );

      if (account == null) {
        print('User cancelled sign-in');
        return GoogleRegisterResponse(
          "User cancelled sign-in",
          "FAILED",
          LoginResult.FAILED,
        );
      }

      final auth = await account.authentication;

      print('Email: ${account.email}');
      print('ID Token: ${auth.idToken}');
      print('photo: ${account.photoUrl}');
      print('name: ${account.displayName}');
      print('id: ${account.id}');

      final url = Uri.parse(userurl + "/google/auth/token");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': account.email,
          'tokenid': auth.idToken,
          'photo': account.photoUrl,
          'name': account.displayName,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(data['message']);
        print(data['status']);

        if (data['token'] != null &&
            data['token'] != "" &&
            data['status'] == "GOOGLE_LOGIN") {
          // final tokenService = Provider.of<TokenService>(
          //   context,
          //   listen: false,
          // );
          await authService.assignToken(token: data['token']);
          //await tokenService.assignToken(token: data['token']);

          Map<String, dynamic> claims = authService.tokenDecode();
          if (claims['phone'] == null) {
            return GoogleRegisterResponse(
              data['message'],
              data['status'],
              LoginResult.INCOMPLETE_PROFILE,
            );
          }
          return GoogleRegisterResponse(
            data['message'],
            data['status'],
            LoginResult.SUCCESS,
          );
        } else {
          return GoogleRegisterResponse(
            data['message'],
            data['status'],
            LoginResult.FAILED,
          );
        }
      }
    } on GoogleSignInException catch (e) {
      print('Sign-in failed: ${e.code} - ${e.description}');
    } catch (e) {
      print(e);
    }
    return GoogleRegisterResponse(
      "Registration call error",
      "FAILED",
      LoginResult.FAILED,
    );
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    print('Signed out');
  }

  static Future<RegisterResponse> registerUser(
    String email,
    String password,
    String fullname,
    String phone,
    File? profileImage,
  ) async {
    if (profileImage == null) {
      print("No profile image selected");
      return RegisterResponse("No profile image selected", "FAILED");
    }

    try {
      final url = Uri.parse(userurl + "/signup");
      final request = http.MultipartRequest('POST', url);

      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['fullname'] = fullname;
      request.fields['phone'] = phone;

      String? mimetype = lookupMimeType(profileImage.path);
      var picfile = await http.MultipartFile.fromPath(
        'profilepicture',
        profileImage.path,
        contentType: mimetype != null
            ? http_parser.MediaType.parse(mimetype)
            : http_parser.MediaType('application', 'octet-stream'),
        filename: basename(profileImage.path),
      );

      request.files.add(picfile);

      final streamedresponse = await request.send();
      final response = await http.Response.fromStream(streamedresponse);

      if (response.statusCode == 200) {
        print(response.body);
        Map<String, dynamic> data = jsonDecode(response.body);
        return RegisterResponse(data['message'], data['status']);
      }
    } catch (e) {
      print("MultipartRequest error: $e");
    }
    return RegisterResponse("MultipartRequest error", "FAILED");
  }

  static Future<bool> userLogin(
    String email,
    String password,
    TokenService authService,
  ) async {
    try {
      final url = Uri.parse(userurl + "/login");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['token'] != null && data['token'] != "") {
          await authService.assignToken(token: data['token']);
          return true;
        }
      } else {
        return false;
      }
      return false;
    } catch (e) {
      print("Login request error: $e");
      return false;
    }
  }

  Future<UserSearchResult> searchUsers(
    String? token,
    String query,
  ) async {
    try {
      final url = Uri.parse(userurl + "/phone?search_query=${query}");

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(data);
        return UserSearchResult.fromJson(data['result']);
      }
      throw Exception('Failed to search users');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to search users');
    }
  }

  Future<bool> addPhoneNumber(
    String loginType,
    String phone,
    String oldToken,
    TokenService authService,
  ) async {
    try {
      final url = Uri.parse(userurl + "/addphone");

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $oldToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"loginType": loginType, "phone": phone}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if ((data['token'] ?? "").isNotEmpty) {
          await authService.assignToken(token: data['token']);
          return true;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print("Request error: $e");
      return false;
    }
  }

  Future<bool> logout(String token) async{
    try{
      final url= Uri.parse(userurl+"/logout");
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode==204){
        print("TOKEN BLACKLISTED SUCCESSFULLY");
        return true;
      }
    }catch(e){
      print(e);
      return false;
    }
    return false;
  }
}

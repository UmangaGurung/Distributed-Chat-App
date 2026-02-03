import 'package:chatfrontend/consthost.dart';

class UserSearchResult{
  final String userId;
  final String email;
  final String fullname;
  final String phoneNumber;
  final String imageURL;
  final String loginType;

  UserSearchResult({
    required this.userId,
    required this.email,
    required this.fullname,
    required this.phoneNumber,
    required this.imageURL,
    required this.loginType,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    String imageURL= json['imageURL'];
    if (!imageURL.startsWith("https")){
      imageURL= "http://${HostConfig.host}:8081/photos/${imageURL.split('/').last}";
    }

    return UserSearchResult(
      userId: json['userId'],
      email: json['email'] ?? 'N/A',
      fullname: json['fullname'],
      phoneNumber: json['phoneNumber'],
      imageURL: imageURL,
      loginType: json['loginType'] ?? 'N/A',
    );
  }
}

import 'package:chatfrontend/consthost.dart';

class ParticipantDetails{

  final String userId;
  final String userName;
  final String photoUrl;
  final String phoneNumber;

  ParticipantDetails({
    required this.userId,
    required this.userName,
    required this.photoUrl,
    required this.phoneNumber,
  });

  factory ParticipantDetails.fromJson(Map<String, dynamic> json) {
    String imageURL = json['photoUrl'];
    if (!imageURL.startsWith("https")) {
      imageURL = "http://${HostConfig.host}:8081/photos/${imageURL
          .split('/')
          .last}";
    }

    return ParticipantDetails(
        userId: json['userId'],
        userName: json['userName'],
        photoUrl: imageURL,
        phoneNumber: json['phoneNumber']
    );
  }
}
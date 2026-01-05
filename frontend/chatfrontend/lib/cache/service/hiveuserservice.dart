import 'package:chatfrontend/cache/model/userdetailscache.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:hive/hive.dart';

class HiveUserService{

  final box = Hive.box<HiveUserModel>('user');
  final ttlBox= Hive.box<DateTime>('dataTTL');

  Future<void> addListOfUserDetailsToCache(List<ParticipantDetails> detailList) async{
    Map<String, HiveUserModel> userMap= {};
    for (ParticipantDetails userDetail in detailList){
      HiveUserModel hiveUserModel= HiveUserModel(
          userId: userDetail.userId,
          userName: userDetail.userName,
          photoUrl: userDetail.photoUrl,
          phoneNumber: userDetail.phoneNumber
      );

      userMap[userDetail.userId]= hiveUserModel;
    }
    await box.putAll(userMap);
  }

  Map<String, ParticipantDetails> getAllCachedUserDetails(List<String> userIdList) {
    final Map<String, ParticipantDetails> userDetailsMap = {};

    for (var id in userIdList) {
      final user = box.get(id);
      if (user == null) continue;

      userDetailsMap[id] = ParticipantDetails(
        userId: user.userId,
        userName: user.userName,
        photoUrl: user.photoUrl,
        phoneNumber: user.phoneNumber,
      );
    }
    return userDetailsMap;
  }
}
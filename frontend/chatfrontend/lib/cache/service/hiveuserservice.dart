import 'package:chatfrontend/cache/model/userdetailscache.dart';
import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:hive/hive.dart';

class HiveUserService {
  final box = Hive.box<HiveUserModel>('user');
  final ttlBox = Hive.box<DateTime>('dataTTL');

  Future<void> addListOfUserDetailsToCache(
    List<ParticipantDetails> detailList,
  ) async {
    Map<String, HiveUserModel> userMap = {};
    for (ParticipantDetails userDetail in detailList) {
      HiveUserModel hiveUserModel = HiveUserModel(
        userId: userDetail.userId,
        userName: userDetail.userName,
        photoUrl: userDetail.photoUrl,
        phoneNumber: userDetail.phoneNumber,
      );

      userMap[userDetail.userId] = hiveUserModel;
    }
    await box.putAll(userMap);
  }

  Map<String, ParticipantDetails> getAllCachedUserDetails(
    List<String> userIdList,
  ) {
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

  Future<void> setExpirationTime(String userId) async {
    final key = 'user:$userId';
    if (ttlBox.containsKey(key)) {
      return;
    }
    await ttlBox.put(key, DateTime.now());
  }

  Future<bool> isExpired(String userId) async {
    final key = 'user:$userId';
    DateTime? value = ttlBox.get(key);

    if (value == null ||
        DateTime.now().difference(value) > const Duration(minutes: 15)) {
      await box.delete(userId);
      await ttlBox.delete(key);
      return true;
    }
    return false;
  }

  Future<Set<String>> isExpiredBulkCheck(List<String> userIdList) async {
    Set<String> expiredIds = {};
    final DateTime now = DateTime.now();

    for (String id in userIdList) {
      final key = 'user:$id';
      final value = ttlBox.get(key);

      if (value == null ||
          now.difference(value) > const Duration(minutes: 15)) {
        await box.delete(id);
        await ttlBox.delete(key);

        expiredIds.add(id);
      }
    }

    return expiredIds;
  }
}

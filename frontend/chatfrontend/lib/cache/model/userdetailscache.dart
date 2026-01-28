import 'package:hive/hive.dart';

part 'userdetailscache.g.dart';

@HiveType(typeId: 0)
class HiveUserModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String userName;

  @HiveField(2)
  final String photoUrl;

  @HiveField(3)
  final String phoneNumber;

  HiveUserModel({
    required this.userId,
    required this.userName,
    required this.photoUrl,
    required this.phoneNumber,
  });
}

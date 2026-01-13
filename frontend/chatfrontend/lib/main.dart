import 'package:chatfrontend/cache/model/conversationcache.dart';
import 'package:chatfrontend/cache/model/messagecache.dart';
import 'package:chatfrontend/cache/model/userdetailscache.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/chatscreen.dart';
import 'package:chatfrontend/presentation/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chatfrontend/constants.dart' as constColor;
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //debugPaintSizeEnabled=true;
  await Hive.initFlutter();
  Hive.registerAdapter(HiveMessageModelAdapter());
  Hive.registerAdapter(HiveUserModelAdapter());
  await Hive.openBox<HiveMessageModel>('messages');
  await Hive.openBox('conversationIndex');
  await Hive.openBox<HiveUserModel>('user');
  await Hive.openBox<DateTime>('dataTTL');
  await inspectHive();
  runApp(ProviderScope(child: ChatApp()));
}

Future<void> inspectHive() async{
  final indexBox = Hive.box('conversationIndex');
  final ttlBox = Hive.box<DateTime>('dataTTL');
  final messageBox = Hive.box<HiveMessageModel>('messages');
  final userBox= Hive.box<HiveUserModel>('user');
  await indexBox.clear();
  await ttlBox.clear();
  await messageBox.clear();
  await userBox.clear();

  print('=== INDEX BOX ===');
  print('Keys: ${indexBox.keys.toList()}');
  for (var key in indexBox.keys) {
    print('$key: ${indexBox.get(key)}');
  }

  print('\n=== TTL BOX ===');
  print('Keys: ${ttlBox.keys.toList()}');
  for (var key in ttlBox.keys) {
    print('$key: ${ttlBox.get(key)}');
  }

  print('\n=== MESSAGE BOX ===');
  print('Keys: ${messageBox.keys.toList()}');
  print('Count: ${messageBox.length}');
}

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(tokenProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.pressStart2pTextTheme()),
      home: tokenState.when(
        data: (token) {
          final auth = ref.read(tokenProvider.notifier);
          if (auth.token == ''){
            print("TOKEN UNASSIGNED");
          }
          return auth.isAuthenticated ? const Chatscreen() : Welcome();
        },
        error: (error, stackTrace) {
          return const Welcome();
        },
        loading: () {
          return const Scaffold(
            backgroundColor: constColor.blackcolor,
            body: Center(child: CircularProgressIndicator(color: constColor.magentacolor,)),
          );
        },
      ),
    );
  }
}

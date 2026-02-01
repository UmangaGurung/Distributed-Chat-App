import 'package:chatfrontend/cache/model/messagecache.dart';
import 'package:chatfrontend/cache/model/userdetailscache.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/presentation/screens/chatscreen.dart';
import 'package:chatfrontend/presentation/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chatfrontend/constants.dart' as constColor;
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  //debugPaintSizeEnabled=true;
  await Hive.initFlutter();
  Hive.registerAdapter(HiveMessageModelAdapter());
  Hive.registerAdapter(HiveUserModelAdapter());
  await Hive.openBox<HiveMessageModel>('messages');
  await Hive.openBox('conversationIndex');
  await Hive.openBox<HiveUserModel>('user');
  await Hive.openBox<DateTime>('dataTTL');
  //await inspectHive();
  runApp(ProviderScope(child: ChatApp()));
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
          final claims= auth.tokenDecode();
          if (auth.token == '' || claims['phone']==null){
            print("TOKEN UNASSIGNED");
            WidgetsBinding.instance.addPostFrameCallback((_){
              auth.clearToken();
            });
          }
          return auth.isAuthenticated || claims['phone']!=null ? const Chatscreen() : Welcome();
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

import 'package:chatfrontend/presentation/providers/socketprovider.dart';
import 'package:chatfrontend/presentation/providers/tokenprovider.dart';
import 'package:chatfrontend/tokenservice.dart';
import 'package:chatfrontend/userapiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../welcome.dart';

class TestThree extends ConsumerStatefulWidget {
  const TestThree({super.key});

  @override
  ConsumerState<TestThree> createState() => _TestThreeState();
}

class _TestThreeState extends ConsumerState<TestThree> {
  final UserAPIService userAPIService = UserAPIService();
  late final TokenService authService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authService = ref.read(tokenProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            final token = authService.token;
            if (token != '' && authService.isAuthenticated) {
              await userAPIService.logout(token);
            }
            print(" login out...");
            ref.invalidate(conversationProvider);
            ref.invalidate(messageProvider);
            ref.invalidate(eventProvider);
            await authService.clearToken();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Welcome()),
              (Route<dynamic> route) => false,
            );
          },
          child: Text("LOGOUT"),
        ),
      ),
    );
  }
}

import 'package:chatfrontend/presentation/screens/user/login.dart';
import 'package:flutter/material.dart';

import 'tokenservice.dart';

Future<void> ifTokenIsInvalid(
    BuildContext context,
    TokenService authService,
    ) async {
  await authService.clearToken();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context){
      return AlertDialog(
        title: Text('Session Expired'),
        content: Text('Your session has timed out. Please log in again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
              );
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
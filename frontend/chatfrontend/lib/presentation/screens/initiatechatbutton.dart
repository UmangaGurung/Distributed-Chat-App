import 'package:flutter/cupertino.dart';

class InitiateChatButton extends CustomClipper<Path>{

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height-(size.height*0.3));
    path.lineTo(size.width-(size.width*0.05), size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height-(size.height*0.7));
    path.lineTo(size.width*0.05, 0);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;

}
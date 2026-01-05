import 'dart:math';

import 'package:chatfrontend/dto/conversation/participantdetails.dart';
import 'package:chatfrontend/dto/message/messagedetailsdto.dart';
import 'package:chatfrontend/dto/message/messageframedto.dart';
import 'package:chatfrontend/dto/message/messageresponsedto.dart';
import 'package:flutter/material.dart';

import 'package:chatfrontend/constants.dart' as constColor;

class MessageBubble extends StatelessWidget {
  final MessageResponseDTO messageResponseDTO;
  final ParticipantDetails senderDetailsDTO;
  final String userId;

  const MessageBubble({
    required this.messageResponseDTO,
    required this.senderDetailsDTO,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final bool isMe= userId==messageResponseDTO.senderId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),  // Spacing
        padding: EdgeInsets.all(8),  // Internal padding
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,  // ← Key fix!
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isMe ? constColor.magentacolor : constColor.cyancolor,
          ),
          borderRadius: BorderRadius.circular(12),  // Rounded corners
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,  // ← Also important!
          children: isMe
            ?[
          Flexible(
            child: Text(
              messageResponseDTO.message,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
            SizedBox(height: 30,),
          ]
          : [
            ClipOval(
              child: Image.network(
                senderDetailsDTO.photoUrl,
                fit: BoxFit.cover,
                height: 30,
                width: 30,
              ),
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                messageResponseDTO.message,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utils/constants/color_constants.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  const ChatBubble(
      {super.key, required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: isCurrentUser
              ? ColorConstants.senderChatColor
              : ColorConstants.receiverChatColor,
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
      child: Text(
        message,
        style: TextStyle(color: isCurrentUser ? Colors.white : (Colors.black)),
      ),
    );
  }
}

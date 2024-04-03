import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  const ChatBubble(
      {super.key, required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    // light vs darkmode for currect bubble colors

    return Container(
      decoration: BoxDecoration(
          color:
              isCurrentUser ? (Colors.green.shade500) : (Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
      child: Text(
        message,
        style: TextStyle(color: isCurrentUser ? Colors.white : (Colors.black)),
      ),
    );
  }
}

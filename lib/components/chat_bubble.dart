import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utils/constants/color_constants.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final bool isFirstInSequence;
  final String? username;
  const ChatBubble.next(
      {super.key, required this.message, required this.isCurrentUser})
      : isFirstInSequence = false,
        username = null;

  const ChatBubble.first(
      {super.key,
      required this.message,
      required this.isCurrentUser,
      required this.username})
      : isFirstInSequence = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isFirstInSequence ? 10 : 0),
      child: Container(
        decoration: BoxDecoration(
            color: isCurrentUser
                ? ColorConstants.senderChatColor
                : ColorConstants.receiverChatColor,
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isFirstInSequence
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username!,
                        style: TextStyle(
                            color:
                                isCurrentUser ? Colors.white : (Colors.black),
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      )
                    ],
                  )
                : const SizedBox(),
            Text(message,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

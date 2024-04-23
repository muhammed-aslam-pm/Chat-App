import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utils/constants/color_constants.dart';

class ChatImageWidget extends StatelessWidget {
  const ChatImageWidget.next({
    super.key,
    required this.isCurrentUser,
    required this.data,
  })  : isFirstInSequence = false,
        username = null;
  const ChatImageWidget.first(
      {super.key,
      required this.isCurrentUser,
      required this.data,
      required this.username})
      : isFirstInSequence = true;

  final bool isCurrentUser;
  final String data;
  final bool isFirstInSequence;
  final String? username;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          right: isCurrentUser ? 8 : 40,
          left: isCurrentUser ? 40 : 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width * .80,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
              decoration: BoxDecoration(
                  color: isCurrentUser
                      ? ColorConstants.senderChatColor
                      : ColorConstants.receiverChatColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isCurrentUser
                          ? ColorConstants.senderChatColor
                          : ColorConstants.receiverChatColor,
                      width: 3)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Visibility(
                      visible: isFirstInSequence,
                      child: Column(
                        children: [
                          Text(username != null ? "    $username    " : "",
                              style: TextStyle(
                                  color: isCurrentUser
                                      ? Colors.white
                                      : (Colors.black),
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(
                            height: 5,
                          )
                        ],
                      )),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    // child: CachedNetworkImage(imageUrl: data)
                    child: Image.network(data),
                    //  FadeInImage.memoryNetwork(
                    //     placeholder: Uint8List(0),
                    //     image: data,
                    //     fit: BoxFit.cover),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

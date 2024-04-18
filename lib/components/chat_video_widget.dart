import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/chat/chat_service.dart';
import 'package:flutter_chat_app/utils/constants/color_constants.dart';

class ChatVideoWidget extends StatelessWidget {
  ChatVideoWidget({
    super.key,
    required this.data,
    required this.isCurrentUser,
  });

  final ChatService chatServices = ChatService();
  final Map<String, dynamic> data;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return FutureBuilder<Uint8List>(
      future: chatServices.getThumbnailData(data['url']),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: width * .85,
                      maxHeight: 300,
                      minWidth: width * .5,
                      minHeight: 150),
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          ),
                        )),
                  ),
                ),
                const Positioned(
                    top: 10,
                    bottom: 10,
                    right: 10,
                    left: 10,
                    child: Icon(
                      Icons.play_arrow,
                      size: 50,
                    ))
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return SizedBox(
            height: 150,
            width: width * .5,
            child: const Center(child: CircularProgressIndicator()));
      },
    );
  }
}

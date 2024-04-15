import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/chat_bubble.dart';
import 'package:flutter_chat_app/components/confirm_dialog.dart';
import 'package:flutter_chat_app/components/custom_textfield.dart';
import 'package:flutter_chat_app/components/video_widget.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/services/chat/chat_service.dart';
import 'package:flutter_chat_app/utils/constants/color_constants.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;
  final String receiverName;
  ChatScreen(
      {super.key,
      required this.receiverEmail,
      required this.receiverID,
      required this.receiverName});
  //text controller
  final TextEditingController messagecontroller = TextEditingController();

  //chat and auth services
  final ChatService chatServices = ChatService();
  final AuthService authServices = AuthService();

  //send messages
  void sendMessage() async {
    //if there is something inside the textfield
    if (messagecontroller.text.isNotEmpty) {
      //send the msg
      await chatServices.sendMessage(receiverID, messagecontroller.text);
      //clear text controller
      messagecontroller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(receiverName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          //display all the msgs
          Expanded(child: buildMessagesList()),
          //user input
          buildUserInput(context)
        ],
      ),
    );
  }

  //build message list
  Widget buildMessagesList() {
    String senderID = authServices.getCurrentUser()!.uid;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: chatServices.getMessages(receiverID, senderID),
        builder: (context, snapshot) {
          //errors
          if (snapshot.hasError) {
            return const Text("Error");
          }

          //loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          //return listview
          return ListView(
            reverse: true,
            children: snapshot.data!.docs
                .map((doc) => buildMessageItem(doc, context))
                .toList(),
          );
        },
      ),
    );
  }

  //build message item
  Widget buildMessageItem(DocumentSnapshot doc, BuildContext context) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data["senderId"] == authServices.getCurrentUser()!.uid;

    //align msg to the right if sender is the current user,otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    String senderID = authServices.getCurrentUser()!.uid;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (data["type"] == 'text')
            InkWell(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmDeletDialog(
                      title: "Confirm Delete",
                      buttontext: "Delete",
                      subTitle: "Are you sure you want to delete this photo ?",
                      onPressed: () async {
                        await Provider.of<ChatService>(context, listen: false)
                            .deleteMessage(receiverID, senderID, doc.id);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                child: ChatBubble(
                    message: data["message"], isCurrentUser: isCurrentUser)),
          if (data['type'] == 'image')
            Padding(
              padding: EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  right: isCurrentUser ? 8 : 40,
                  left: isCurrentUser ? 40 : 8),
              child: InkWell(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmDeletDialog(
                      title: "Confirm Delete",
                      buttontext: "Delete",
                      subTitle: "Are you sure you want to delete this photo ?",
                      onPressed: () async {
                        await Provider.of<ChatService>(context, listen: false)
                            .deleteMessage(receiverID, senderID, doc.id);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: isCurrentUser
                          ? ColorConstants.senderChatColor
                          : ColorConstants.receiverChatColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Image.network(
                    data['url'],
                  ),
                ),
              ),
            ),
          if (data["type"] == 'video')
            InkWell(
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => ConfirmDeletDialog(
                    title: "Confirm Delete",
                    buttontext: "Delete",
                    subTitle: "Are you sure you want to delete this photo ?",
                    onPressed: () async {
                      await Provider.of<ChatService>(context, listen: false)
                          .deleteMessage(receiverID, senderID, doc.id);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViedoPlayScreen(
                        videoUrl: data['url'],
                      ),
                    ));
              },
              child: FutureBuilder<Uint8List>(
                future: chatServices.getThumbnailData(data['url']),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? ColorConstants.senderChatColor
                                    : ColorConstants.receiverChatColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              ),
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

                  return const SizedBox(
                      height: 300,
                      width: 300,
                      child: Center(child: CircularProgressIndicator()));
                },
              ),
            )
        ],
      ),
    );
  }

  //build message input
  Widget buildUserInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                // chatServices.sendImage(receiverID);
                chatServices.pickImages(context: context, receiver: receiverID);
              },
              icon: const Icon(Icons.image_outlined)),
          IconButton(
              onPressed: () {
                // chatServices.sendVideo(receiverID);
                chatServices.pickVideo(context: context, receiver: receiverID);
              },
              icon: const Icon(Icons.video_collection_outlined)),
          //txtfield should take upmost of the space
          Expanded(
            child: CustomTextField(
                hintText: "Type a message",
                obscure: false,
                controller: messagecontroller),
          ),
          //send button
          Container(
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

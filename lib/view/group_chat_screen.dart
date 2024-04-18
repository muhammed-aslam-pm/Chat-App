import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/chat_bubble.dart';
import 'package:flutter_chat_app/components/chat_image_widget.dart';
import 'package:flutter_chat_app/components/chat_video_widget.dart';
import 'package:flutter_chat_app/components/confirm_dialog.dart';
import 'package:flutter_chat_app/components/custom_textfield.dart';
import 'package:flutter_chat_app/view/video_play_screen.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/services/chat/group_chat_service.dart';
import 'package:flutter_chat_app/utils/constants/color_constants.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatelessWidget {
  final DocumentSnapshot group;
  GroupChatScreen({super.key, required this.group});
  //text controller
  final TextEditingController messagecontroller = TextEditingController();

  //chat and auth services
  final GroupChatSerice chatServices = GroupChatSerice();
  final AuthService authServices = AuthService();

  //send messages
  void sendMessage() async {
    //if there is something inside the textfield
    if (messagecontroller.text.isNotEmpty) {
      //send the msg
      await chatServices.sendMessage(group.id, messagecontroller.text);
      //clear text controller
      messagecontroller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(group['groupName']),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: chatServices.getMessages(group.id),
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
          // return ListView(
          //   reverse: true,
          //   children: snapshot.data!.docs
          //       .map((doc) => buildMessageItem(doc, context))
          //       .toList(),
          // );
          return ListView.builder(
            reverse: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final chatMessage = snapshot.data!.docs[index];

              final nextChatMessage = index + 1 < snapshot.data!.docs.length
                  ? snapshot.data!.docs[index + 1]
                  : null;
              final currentMessageId = chatMessage['senderId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['senderId'] : null;
              final nextUserIsSame = nextMessageUserId == currentMessageId;
              bool isCurrentUser =
                  chatMessage['senderId'] == authServices.getCurrentUser()!.uid;
              var alignment =
                  isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
              return Container(
                alignment: alignment,
                child: Column(
                  crossAxisAlignment: isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (chatMessage["type"] == 'text')
                      TextMessageWidget(
                          chatMessage: chatMessage,
                          group: group,
                          nextUserIsSame: nextUserIsSame,
                          isCurrentUser: isCurrentUser),
                    if (chatMessage['type'] == 'image')
                      ImageMessageWidget(
                          isCurrentUser: isCurrentUser,
                          chatMessage: chatMessage,
                          group: group,
                          nextUserIsSame: nextUserIsSame),
                    if (chatMessage["type"] == 'video')
                      VideoMessageWidget(
                          chatMessage: chatMessage,
                          group: group,
                          chatServices: chatServices,
                          isCurrentUser: isCurrentUser,
                          nextUserIsSame: nextUserIsSame)
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildUserInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.lightBlue[100]),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      chatServices.pickImages(
                          context: context, chatId: group.id);
                    },
                    icon: const Icon(Icons.image_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      chatServices.pickVideo(
                          context: context, chatId: group.id);
                    },
                    icon: const Icon(Icons.video_collection_outlined),
                  ),
                  // Expanded text field takes up remaining space
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                            controller: messagecontroller,
                            decoration: const InputDecoration(
                                hintText: "Type a message",
                                border: InputBorder.none))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          // Send button outside the container
          Container(
            decoration: const BoxDecoration(
              color: Colors.lightBlue,
              shape: BoxShape.circle,
            ),
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

/*
  //build message input
  Widget buildUserInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                // chatServices.sendImage(receiverID);
                chatServices.pickImages(context: context, chatId: group.id);
              },
              icon: const Icon(Icons.image_outlined)),
          IconButton(
              onPressed: () {
                // chatServices.sendVideo(receiverID);
                chatServices.pickVideo(context: context, chatId: group.id);
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
  }*/
}

class TextMessageWidget extends StatelessWidget {
  const TextMessageWidget({
    super.key,
    required this.chatMessage,
    required this.group,
    required this.nextUserIsSame,
    required this.isCurrentUser,
  });

  final QueryDocumentSnapshot<Object?> chatMessage;
  final DocumentSnapshot<Object?> group;
  final bool nextUserIsSame;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => ConfirmDeletDialog(
              title: "Confirm Delete",
              buttontext: "Delete",
              subTitle: "Are you sure you want to delete this photo ?",
              onPressed: () async {
                await Provider.of<GroupChatSerice>(context, listen: false)
                    .deleteMessage(chatMessage.id, group.id);
                Navigator.pop(context);
              },
            ),
          );
        },
        child: nextUserIsSame
            ? ChatBubble.next(
                message: chatMessage["message"], isCurrentUser: isCurrentUser)
            : ChatBubble.first(
                message: chatMessage["message"],
                isCurrentUser: isCurrentUser,
                username: chatMessage["senderName"]));
  }
}

class VideoMessageWidget extends StatelessWidget {
  const VideoMessageWidget({
    super.key,
    required this.chatMessage,
    required this.group,
    required this.chatServices,
    required this.isCurrentUser,
    required this.nextUserIsSame,
  });

  final QueryDocumentSnapshot<Object?> chatMessage;
  final DocumentSnapshot<Object?> group;
  final GroupChatSerice chatServices;
  final bool isCurrentUser;
  final bool nextUserIsSame;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => ConfirmDeletDialog(
            title: "Confirm Delete",
            buttontext: "Delete",
            subTitle: "Are you sure you want to delete this photo ?",
            onPressed: () async {
              await Provider.of<GroupChatSerice>(context, listen: false)
                  .deleteMessage(chatMessage.id, group.id);
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
                videoUrl: chatMessage['url'],
              ),
            ));
      },
      child:
          //  nextUserIsSame
          // ? ChatVideoWidget.next(
          //     data: chatMessage['url'], isCurrentUser: isCurrentUser)
          // : ChatVideoWidget.first(
          //     data: chatMessage['url'],
          //     isCurrentUser: isCurrentUser,
          //     username: chatMessage['senderName'])
          FutureBuilder<Uint8List>(
        future: chatServices.getThumbnailData(chatMessage['url']),
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
                    child: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        !nextUserIsSame
                            ? Column(
                                children: [
                                  Text(
                                    chatMessage['senderName'],
                                    style: TextStyle(
                                        color: isCurrentUser
                                            ? Colors.white
                                            : (Colors.black),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  )
                                ],
                              )
                            : const SizedBox(),
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
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
    );
  }
}

class ImageMessageWidget extends StatelessWidget {
  const ImageMessageWidget({
    super.key,
    required this.isCurrentUser,
    required this.chatMessage,
    required this.group,
    required this.nextUserIsSame,
  });

  final bool isCurrentUser;
  final QueryDocumentSnapshot<Object?> chatMessage;
  final DocumentSnapshot<Object?> group;
  final bool nextUserIsSame;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                await Provider.of<GroupChatSerice>(context, listen: false)
                    .deleteMessage(chatMessage.id, group.id);
                Navigator.pop(context);
              },
            ),
          );
        },
        child: nextUserIsSame
            ? ChatImageWidget.next(
                isCurrentUser: isCurrentUser, data: chatMessage['url'])
            : ChatImageWidget.first(
                isCurrentUser: isCurrentUser,
                data: chatMessage['url'],
                username: chatMessage['senderName']),
        // child: Container(
        //   padding: const EdgeInsets.all(10),
        //   decoration: BoxDecoration(
        //       color: isCurrentUser
        //           ? ColorConstants.senderChatColor
        //           : ColorConstants.receiverChatColor,
        //       borderRadius: BorderRadius.circular(15)),
        //   child: Column(
        //     crossAxisAlignment: isCurrentUser
        //         ? CrossAxisAlignment.end
        //         : CrossAxisAlignment.start,
        //     children: [
        //       !nextUserIsSame
        //           ? Column(
        //               children: [
        //                 Text(
        //                   chatMessage['senderName'],
        //                   style: TextStyle(
        //                       color:
        //                           isCurrentUser ? Colors.white : (Colors.black),
        //                       fontWeight: FontWeight.w600),
        //                 ),
        //                 const SizedBox(
        //                   height: 5,
        //                 )
        //               ],
        //             )
        //           : const SizedBox(),
        //       Image.network(
        //         chatMessage['url'],
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/chat_bubble.dart';
import 'package:flutter_chat_app/components/custom_textfield.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/services/chat/chat_service.dart';

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
          buildUserInput()
        ],
      ),
    );
  }

  //build message list
  Widget buildMessagesList() {
    String senderID = authServices.getCurrentUser()!.uid;
    return StreamBuilder(
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
          children:
              snapshot.data!.docs.map((doc) => buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  //build message item
  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data["senderId"] == authServices.getCurrentUser()!.uid;

    //align msg to the right if sender is the current user,otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(message: data["message"], isCurrentUser: isCurrentUser)
          ],
        ));
  }

  //build message input
  Widget buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
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

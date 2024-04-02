import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.receiverEmail, required this.receiverID, required this.name});
  final String receiverEmail;
  final String receiverID;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Chat"),),);
  }
}
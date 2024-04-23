import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/view/chat_screen.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.document,
    required this.context,
  });

  final DocumentSnapshot<Object?> document;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    Map<String, dynamic> userData = document.data()! as Map<String, dynamic>;
    // display all users except current user
    if (userData["email"] != auth.currentUser!.email) {
      return UserTile(
        title: userData["name"],
        onTap: () {
          // tapped on a user => go to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                receiverName: userData["name"],
                receiverID: userData["uid"],
                receiverEmail: userData["email"],
              ),
            ),
          );
        },
        time: '4.30 pm',
        subTitle: 'Last message ...',
      );
    } else {
      return Container();
    }
  }
}

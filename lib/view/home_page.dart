import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/view/chat_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              controller.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, snapshot) {
          // error
          if (snapshot.hasError) {
            return const Center(child: Text("Error"));
          }

          // loading..
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // return list view
          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((userData) => buildUserListItem(userData, context))
                .toList(),
          );
        },
      ),
    );
  }

  Widget buildUserListItem(DocumentSnapshot document, BuildContext context) {
    final _auth = FirebaseAuth.instance;
    Map<String, dynamic> userData = document.data()! as Map<String, dynamic>;
    // display all users except current user
    if (userData["email"] != _auth.currentUser!.email) {
      return UserTile(
        text: userData["name"],
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
      );
    } else {
      return Container();
    }
  }
}
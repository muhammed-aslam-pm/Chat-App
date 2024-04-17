import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/model/group_chat_model.dart';

class GroupChatController with ChangeNotifier {
  Future<void> createGroupChat(
    String groupName,
    List<String> memberIds,
  ) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      // Add current user's ID to the memberIds list
      memberIds.add(currentUserId);

      // Create a Firestore collection reference for group chats
      CollectionReference groupChats =
          FirebaseFirestore.instance.collection('group_chats');

      // Generate a unique ID for the group chat
      String groupId = groupChats.doc().id;

      // Create a GroupChatModel object
      GroupChatModel groupChat = GroupChatModel(
        groupName: groupName,
        members: memberIds,
        groupId: groupId,
      );

      // Convert GroupChatModel to a map
      Map<String, dynamic> groupChatMap = groupChat.toMap();

      // Add the group chat data to Firestore
      await groupChats.doc(groupId).set(groupChatMap);

      // Optionally, you can perform additional actions like sending notifications to members.
    } catch (e) {
      print('Error creating group chat: $e');
      // Handle errors accordingly
    }
  }
}

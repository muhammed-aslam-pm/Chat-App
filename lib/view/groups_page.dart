import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/helpers/helper_functions.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/view/group_chat_screen.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  String name = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              // Print navigation stack before navigating back
              print('Before Navigation Back:');
              print(Navigator.of(context).widget);

              // Navigate back
              Navigator.pop(context);

              // Print navigation stack after navigating back
              WidgetsBinding.instance.addPostFrameCallback((_) {
                print('After Navigation Back:');
                print(Navigator.of(context).widget);
              });
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text("groups"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: CupertinoSearchTextField(
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("group_chats")
                  .where('members',
                      arrayContains: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
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
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    if (name.isEmpty) {
                      return UserTile(
                        title: snapshot.data!.docs[index]['groupName'],
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupChatScreen(
                                    group: snapshot.data!.docs[index]),
                              ));
                        },
                        time: HelperFunctions.formatDate((snapshot.data!
                                .docs[index]['lastMessageTime'] as Timestamp)
                            .toDate()),
                        subTitle:
                            '${snapshot.data!.docs[index]['lastMessageSender']} : ${snapshot.data!.docs[index]['lastMessageType'] == 'text' || snapshot.data!.docs[index]['lastMessageType'] == 'image' ? snapshot.data!.docs[index]['lastMessage'] : snapshot.data!.docs[index]['lastMessageType']}',
                      );
                    }
                    if (snapshot.data!.docs[index]['groupName']
                        .toString()
                        .toLowerCase()
                        .contains(name.toLowerCase())) {
                      return UserTile(
                        title: snapshot.data!.docs[index]['groupName'],
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupChatScreen(
                                    group: snapshot.data!.docs[index]),
                              ));
                        },
                        time: HelperFunctions.formatDate((snapshot.data!
                                .docs[index]['lastMessageTime'] as Timestamp)
                            .toDate()),
                        subTitle:
                            '${snapshot.data!.docs[index]['lastMessageSender']} : ${snapshot.data!.docs[index]['lastMessageType'] == 'text' || snapshot.data!.docs[index]['lastMessageType'] == 'image' ? snapshot.data!.docs[index]['lastMessage'] : snapshot.data!.docs[index]['lastMessageType']}',
                      );
                    }
                    return Container();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

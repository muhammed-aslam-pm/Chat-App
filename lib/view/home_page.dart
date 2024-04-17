import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/view/chat_screen.dart';
import 'package:flutter_chat_app/view/create_group.dart';
import 'package:flutter_chat_app/view/groups_page.dart';
import 'package:flutter_chat_app/view/sample.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTopSlideVisible = false;
  String name = "";

  void _toggleTopSlide() {
    setState(() {
      _isTopSlideVisible = !_isTopSlideVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthService>(context, listen: false);
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          actions: [
            IconButton(
              onPressed: _toggleTopSlide,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                stream:
                    FirebaseFirestore.instance.collection("Users").snapshots(),
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
                        return UserCard(snapshot.data!.docs[index], context);
                      }
                      if (snapshot.data!.docs[index]['name']
                          .toString()
                          .toLowerCase()
                          .contains(name.toLowerCase())) {
                        return UserCard(snapshot.data!.docs[index], context);
                      }
                      return Container();
                    },
                  );
                },
              ),
            ),
          ],
        ),
        drawer: const Drawer(),
      ),
      Visibility(
        visible: _isTopSlideVisible,
        child: GestureDetector(
          onTap: _isTopSlideVisible ? _toggleTopSlide : null,
          child: Container(
            // Make the container cover the whole screen
            color: Colors.transparent, // Make it transparent
            height: double.infinity,
            width: double.infinity,
          ),
        ),
      ),
      AnimatedPositioned(
        top: _isTopSlideVisible ? 0.0 : -MediaQuery.of(context).size.height,
        left: 0.0,
        right: 0.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeIn,
        child: GestureDetector(
          onLongPressUp: _isTopSlideVisible ? _toggleTopSlide : null,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey
                      .withOpacity(0.5), // Shadow color with transparency
                  blurRadius: 5.0, // Adjust blur radius for softness
                  spreadRadius: 0.0, // No spread for a sharper bottom shadow
                  offset: const Offset(0.0, 5.0), // Move shadow down on y-axis
                ),
              ],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(25)),
              color: Colors.white,
            ),
            height: 200.0,
            child: Center(
              child: Row(
                children: [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Text(
                          'Create new Group',
                          style: TextStyle(color: Colors.blue),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.groups_2,
                          size: 20,
                          color: Colors.blue,
                        )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _isTopSlideVisible = false;
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateGroupPage(),
                          ));
                    },
                  ),
                  PopupMenuItem(
                    onTap: () {
                      // setState(() {
                      //   _isTopSlideVisible = false;
                      // });

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => const GroupsPage(),
                      //     ));
                      // Print navigation stack before navigating
                      print('Before Navigation:');
                      print(Navigator.of(context).widget);

                      // Navigate to new screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GroupsPage()),
                      );

                      // Print navigation stack after navigating
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        print('After Navigation:');
                        print(Navigator.of(context).widget);
                      });
                    },
                    child: const Row(
                      children: [
                        Text(
                          'Groups',
                          style: TextStyle(color: Colors.blue),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.groups_2,
                          size: 20,
                          color: Colors.blue,
                        )
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Text(
                          'Log Out',
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.logout,
                          size: 20,
                          color: Colors.red,
                        )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _isTopSlideVisible = false;
                      });
                      controller.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget UserCard(DocumentSnapshot document, BuildContext context) {
    final auth = FirebaseAuth.instance;
    Map<String, dynamic> userData = document.data()! as Map<String, dynamic>;
    // display all users except current user
    if (userData["email"] != auth.currentUser!.email) {
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

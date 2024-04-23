import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/controller/group_controller.dart';
import 'package:provider/provider.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupMemberController = TextEditingController();
  String name = "";
  List<QueryDocumentSnapshot> selectedmembers = [];

  void addMembers(QueryDocumentSnapshot user) {
    // Get the user's ID or any unique identifier
    String userId = user.id;
    // Check if the user is already in the selectedmembers list based on their ID
    bool userAlreadySelected =
        selectedmembers.any((selectedUser) => selectedUser.id == userId);
    if (!userAlreadySelected) {
      selectedmembers.add(user);
      _groupMemberController.clear();
      name = '';
    }

    setState(() {});
  }

  void removeMember(QueryDocumentSnapshot user) {
    String userId = user.id;
    selectedmembers.removeWhere((selectedUser) => selectedUser.id == userId);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(),
                  const Text("Group Chat Name"),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text("Members"),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _groupMemberController,
                    decoration: const InputDecoration(
                      labelText: 'Search Users',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                  Visibility(
                      visible: selectedmembers.isNotEmpty,
                      child: SingleChildScrollView(
                          child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: List.generate(
                              selectedmembers.length,
                              (index) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Stack(children: [
                                        const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: CircleAvatar(
                                            radius: 30,
                                            child: Icon(Icons.person),
                                          ),
                                        ),
                                        Positioned(
                                            top: 0,
                                            right: 0,
                                            child: InkWell(
                                              onTap: () {
                                                removeMember(
                                                    selectedmembers[index]);
                                              },
                                              child: const CircleAvatar(
                                                backgroundColor:
                                                    Colors.redAccent,
                                                radius: 12,
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ))
                                      ]),
                                      Text(selectedmembers[index]['name'])
                                    ],
                                  )),
                        ),
                      ))),
                  Visibility(
                    visible: name.isNotEmpty,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("Users")
                          .snapshots(),
                      builder: (context, snapshot) {
                        // error
                        if (snapshot.hasError) {
                          return const Center(child: Text("Error"));
                        }

                        // loading..
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        // return list view
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: snapshot.data!.docs.length == 1 ? 50 : 200,
                            child: ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                if (name.isEmpty) {
                                  return Container();
                                }
                                if (snapshot.data!.docs[index]['name']
                                    .toString()
                                    .toLowerCase()
                                    .contains(name.toLowerCase())) {
                                  return UserTile(
                                    title: snapshot.data!.docs[index]['name'],
                                    onTap: () {
                                      addMembers(snapshot.data!.docs[index]);
                                    },
                                    time: '',
                                    subTitle: '',
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                      visible: name.isEmpty,
                      child: const SizedBox(
                        height: 40,
                      )),
                  Center(
                      child: InkWell(
                    onTap: () async {
                      List<String> selectedMemberIds =
                          selectedmembers.map((user) => user.id).toList();

                      if (_formKey.currentState!.validate()) {
                        await Provider.of<GroupChatController>(context,
                                listen: false)
                            .createGroupChat(
                                _groupNameController.text, selectedMemberIds);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 60,
                      width: 350,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(30)),
                      child: const Text(
                        "Create",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

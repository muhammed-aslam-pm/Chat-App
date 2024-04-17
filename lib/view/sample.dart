import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sample extends StatefulWidget {
  @override
  _SampleState createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedUsers = [];
  List<String> selected = [];

  // Function to search users
  void searchUsers(String query) {
    // Query the "Users" collection in Firestore
    // You can customize this query based on your requirements
    FirebaseFirestore.instance
        .collection('Users')
        .where('name'.toLowerCase(), isGreaterThanOrEqualTo: query)
        .where('name'.toLowerCase(),
            isLessThanOrEqualTo:
                query + '\uf8ff') // For case-insensitive search
        .get()
        .then((QuerySnapshot querySnapshot) {
      // Clear previous search results
      selectedUsers.clear();
      // Add matching user IDs to the selectedUsers list
      querySnapshot.docs.forEach((doc) {
        selectedUsers.add(doc['name']);
      });
      // Update UI to reflect search results
      setState(() {});
    }).catchError((error) {
      print("Failed to search users: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Call searchUsers function when text changes
                searchUsers(value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search Users',
              ),
            ),
          ),
          Container(
            height: 200,
            width: double.infinity,
            child: GridView.builder(
              itemCount: selected.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context, index) => Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(selected[index]),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedUsers.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(selectedUsers[
                      index]), // Display user name or relevant info
                  onTap: () {
                    setState(() {
                      selected.add(selectedUsers[index]);
                    });

                    // Handle user selection
                    // You can add the selected user to a list or perform any other action
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

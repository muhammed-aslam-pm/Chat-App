import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedMembers = [];

  // Dummy list of members for demonstration
  final List<String> _allMembers = [
    'User 1',
    'User 2',
    'User 3',
    'User 4',
    'User 5',
    'User 6',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _createGroup();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allMembers.length,
              itemBuilder: (context, index) {
                final member = _allMembers[index];
                return ListTile(
                  title: Text(member),
                  trailing: _selectedMembers.contains(member)
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      if (_selectedMembers.contains(member)) {
                        _selectedMembers.remove(member);
                      } else {
                        _selectedMembers.add(member);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _createGroup() {
    // Perform actions to create the group with _groupNameController.text as group name
    // and _selectedMembers as group members
    // For demonstration, just print the group name and members
    print('Group Name: ${_groupNameController.text}');
    print('Group Members: $_selectedMembers');
    // You can add further logic here to actually create the group in your app
  }
}

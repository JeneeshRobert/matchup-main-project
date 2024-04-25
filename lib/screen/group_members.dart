// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}

class UserListScreen extends StatefulWidget {
  final String team;
  UserListScreen({
    super.key,
    required this.team,
  });
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> _users = []; // List of users
  List<User> _searchResults = []; // List of search results
  bool _isLoading = true; // Loading indicator flag

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Fetch users from Firebase
  }

  Future<void> _fetchUsers() async {
    // Fetch users from Firebase
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Convert fetched data to User objects
    List<User> users = snapshot.docs
        .map((doc) => User(
            id: doc.id,
            name: (doc.data() as Map<String, dynamic>)['username'] ??
                'Unknown')) // Cast to Map<String, dynamic>
        .toList();

    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _searchUsers(String searchText) {
    // Filter users based on search text
    List<User> searchResults = _users
        .where((user) =>
            user.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    setState(() {
      _searchResults = searchResults;
    });
  }

  void _showSearchModal(BuildContext context) async {
    String searchText = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  _searchUsers(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  border: InputBorder.none,
                  suffixIcon: Icon(
                    Icons.search,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(_searchResults[index].name),
                  onTap: () {
                    // Do something with the selected user
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Selected User'),
                        content: Text('User ID: ${_searchResults[index].id}\n'
                            'Name: ${_searchResults[index].name}'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Add User'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.flickr(
                  leftDotColor: Color(0xFFEB455F),
                  rightDotColor: Color(0xFF2B3467),
                  size: 30),
            )
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_users[index].name),
                // Do something with the selected user
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Selected User'),
                      content: Text('User ID: ${_users[index].id}\n'
                          'Name: ${_users[index].name}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSearchModal(context), // Show search modal sheet
        child: Icon(Icons.search),
      ),
    );
  }
}

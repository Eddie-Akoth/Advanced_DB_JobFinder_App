import 'package:application_job/src/Widgets/companies_people_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Widgets/bottom_navigation_bar.dart';
import '../constants/colors.dart';

class AllWorkersScreen extends StatefulWidget {
  const AllWorkersScreen({super.key});

  @override
  State<AllWorkersScreen> createState() => _AllWorkersScreenState();
}

class _AllWorkersScreenState extends State<AllWorkersScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';

  // building the search field
  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for Companies/People ...',
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
      style: const TextStyle(color: Colors.black54, fontSize: 16.0),
      onChanged: (query) =>
          updateSearchQuery(query), //update query item as textfield changes
    );
  }

  // method to clear the search field
  void _clearSearchField() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery('');
    });
  }

// updating search query:updating the string
  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      print(searchQuery);
    });
  }

  List<Widget> _buildActions() {
    return <Widget>[
      IconButton(
        onPressed: () {
          _clearSearchField();
        },
        icon: const Icon(
          Icons.clear_rounded,
          color: tPrimaryColor,
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _buildSearchField(),
        actions: _buildActions(),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: tdismissable,
                valueColor: AlwaysStoppedAnimation<Color>(tPrimaryColor),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data?.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  return AllWorkersWidget(
                      userID: snapshot.data?.docs[index]['id'],
                      userName: snapshot.data?.docs[index]['name'],
                      userEmail: snapshot.data?.docs[index]['email'],
                      phoneNumber: snapshot.data?.docs[index]['phoneNumber'],
                      userImgUrl: snapshot.data?.docs[index]['userImage']);
                },
              );
            } else {
              return const Center(
                child: Text('No users found'),
              );
            }
          }
          return const Center(
            child: Text(
              'Something went wrong, try again',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          );
        },
      ),
    );
  }
}

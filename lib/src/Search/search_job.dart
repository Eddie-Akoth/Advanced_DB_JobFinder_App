import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Widgets/job_widget.dart';
import '../constants/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';

  // building the search field
  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: const InputDecoration(
        hintText: 'Search for jobs ...',
        hintStyle: TextStyle(color: Colors.grey),
        // filled: true,
        // fillColor: Colors.black12,
        border: InputBorder.none,
        // fillColor: tdismissable,

        // enabledBorder: UnderlineInputBorder(
        //   borderSide: BorderSide(color: Colors.white),
        // ),
        // focusedBorder: UnderlineInputBorder(
        //   borderSide: BorderSide(color: tPrimaryOnboarding3),
        // ),
        // errorBorder: UnderlineInputBorder(
        //   borderSide: BorderSide(color: Colors.redAccent),
        // ),
      ),
      style: TextStyle(color: Colors.black54, fontSize: 16.0),
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
        icon: const Icon(Icons.clear_rounded),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: tPrimaryColor,
        ),
        title: _buildSearchField(),
        actions: _buildActions(),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      // retrieving data that is matches even partially the search query and has recruitment true
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('jobTitle', isGreaterThanOrEqualTo: searchQuery)
            .where('requirement', isEqualTo: true)
            .snapshots(),
        builder: ((context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: tdismissable,
                valueColor: AlwaysStoppedAnimation<Color>(tPrimaryColor),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            // if the document is not empty
            if (snapshot.data?.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  return JobWidget(
                    jobTitle: snapshot.data?.docs[index]['jobTitle'],
                    jobDescription: snapshot.data?.docs[index]
                        ['jobDescription'],
                    jobId: snapshot.data?.docs[index]['jobId'],
                    uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                    userImage: snapshot.data?.docs[index]['userImage'],
                    name: snapshot.data?.docs[index]['name'],
                    requirement: snapshot.data?.docs[index]['requirement'],
                    email: snapshot.data?.docs[index]['email'],
                    location: snapshot.data?.docs[index]['location'],
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No jobs found'),
              );
            }
          }
          return const Center(
            child: Text(
              'Something went wrong, try again',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          );
        }),
      ),
    );
  }
}

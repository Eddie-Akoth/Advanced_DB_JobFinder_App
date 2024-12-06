import 'package:application_job/src/Search/search_job.dart';
import 'package:application_job/src/Widgets/job_widget.dart';
import 'package:application_job/src/constants/colors.dart';
import 'package:application_job/src/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Persistent/persistent.dart';
import '../Services/global_variables.dart';
import '../Widgets/bottom_navigation_bar.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? jobCategoryFilter;

// job categories for filter
  _showJobCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: const Text(
              'Job Categories',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Persistent.jobCategoryList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          jobCategoryFilter = Persistent.jobCategoryList[index];
                        });
                        Navigator.canPop(context)
                            ? Navigator.pop(context)
                            : null; //remove dialog box after it user has selected
                        print(
                            'jobCategoryList[index], ${Persistent.jobCategoryList[index]}');
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_right_rounded,
                            color: tPrimaryColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Persistent.jobCategoryList[index],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 16,
                    ),
                  )),
              TextButton(
                  onPressed: () {
                    setState(() {
                      jobCategoryFilter = null;
                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                    });
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                  ))
            ],
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    // once user comes to this page, get their name, and image
    Persistent persistentObject = Persistent();
    persistentObject.getAdditionalData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CircleAvatar(
                  backgroundColor: tPrimaryColor,
                  radius: 20,
                  // ignore: prefer_if_null_operators
                  child: Image.network(
                    userImage == null
                        ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'
                        : userImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'Welcome Back 👋🏽',
              style: TextStyle(color: tPrimaryColor),
            ),
          ],
        ),
        // centerTitle: true,
        leading: IconButton(
            onPressed: () {
              _showJobCategoriesDialog(size: size);
            },
            icon: const Icon(
              Icons.filter_list_rounded,
              color: tPrimaryColor,
            )),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (c) => SearchScreen()));
              },
              icon: const Icon(
                Icons.search_rounded,
                color: tPrimaryColor,
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('jobCategory', isEqualTo: jobCategoryFilter)
              .where('requirement', isEqualTo: true)
              .orderBy('createdAt', descending: false)
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
              // once connection state has been established
              // if there are jobs
              if (snapshot.data?.docs.isNotEmpty == true) {
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    // return job widget in widgets folder
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
                        location: snapshot.data?.docs[index]['location']);
                  },
                );
              } else {
                // if there are no jobs
                return const Center(
                  child: Text(
                    "There are no jobs available at the moment",
                    style: TextStyle(
                        color: tPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                );
              }
            }
            return const Center(
              child: Text(
                'Something Went Wrong. Try again',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            );
          }),
    );
  }
}


// onPressed: () {
//             _auth.signOut();
//             Navigator.canPop(context) ? Navigator.pop(context) : null;
//             Navigator.pushReplacement(
//                 context, MaterialPageRoute(builder: (_) => UserState()));
//             Fluttertoast.showToast(
//                 msg: 'Logged out Successfully',
//                 textColor: Colors.white,)
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Services/global_variables.dart';

class Persistent {
  // list for job categories
  static List<String> jobCategoryList = [
    'Architecture and Construction',
    'Education and Training',
    'Development - Programming',
    'Business',
    'IT',
    'Cosmetics',
    'Human Resources',
    'Marketing',
    'Design',
    'Accounting',
    'Other'
  ];
  
  // method to fetch name, location and image of user from the users collection and upload it with the job here
  //method will be called when widget is mounted, thus called within initState
  void getAdditionalData() async {
    // get the user with uid equal to the one who is logged in, since this is the person posting
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    name = userDoc.get('name');
    userImage = userDoc.get('userImage');
    location = userDoc.get('location');
  }
}

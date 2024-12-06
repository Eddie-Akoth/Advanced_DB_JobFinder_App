import 'package:application_job/src/Jobs/jobs_screen.dart';
import 'package:application_job/src/Jobs/upload_job.dart';
import 'package:application_job/src/Search/profile_company.dart';
import 'package:application_job/src/Search/search_companies.dart';
import 'package:application_job/src/constants/colors.dart';
import 'package:application_job/src/user_state.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarForApp extends StatelessWidget {
  // BottomNavigationBar({super.key});
  BottomNavigationBarForApp({super.key, required this.indexNum});

// logout button
  void _logout(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: Row(children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
              )
            ]),
            content: const Text(
              'Do you want to log out?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    // remove the dialog box
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 18),
                  )),
              TextButton(
                  onPressed: () {
                    // signout the user
                    _auth.signOut();
                    // remove the dialog box
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => UserState()));
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Colors.redAccent, fontSize: 18),
                  ))
            ],
          );
        });
  }

  int indexNum = 0;
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: tPrimaryColor,
      backgroundColor: Colors.white, //bg for curved selected
      buttonBackgroundColor: tPrimaryColor, //main bg color
      height: 50,
      index: indexNum,
      items: const [
        Icon(
          Icons.dashboard_rounded,
          size: 22,
          color: Colors.white,
        ),
        Icon(
          Icons.search_rounded,
          size: 22,
          color: Colors.white,
        ),
        Icon(
          Icons.add_box,
          size: 30,
          color: Colors.white,
        ),
        Icon(
          Icons.person,
          size: 22,
          color: Colors.white,
        ),
        Icon(
          Icons.exit_to_app_rounded,
          size: 22,
          color: Colors.white,
        ),
      ],
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      onTap: (index) {
        if (index == 0) {
          // navigate use to jobs screen
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => JobScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => AllWorkersScreen()));
        } else if (index == 2) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => UploadJob()));
        } else if (index == 3) {
          // sending the user to their specific profile, we need their user Ids

          final FirebaseAuth _auth = FirebaseAuth.instance;
          final User? user = _auth.currentUser;
          final String uid = user!.uid;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                        userID: uid,
                      )));
        } else if (index == 4) {
          _logout(context);
        }
      },
    );
  }
}

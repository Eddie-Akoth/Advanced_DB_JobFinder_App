import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Jobs/jobs_screen.dart';
import 'LoginPage/login_screen.dart';

class UserState extends StatelessWidget {
  const UserState({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          print('user not logged in');
          return Login();
        } else if (snapshot.hasData) {
          print('User logged in');
          return JobScreen();
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('An error has occurred. Try Again Later'),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: Text('Something went wrong')),
        );
      },
    );
    ;
  }
}
import 'package:application_job/src/LoginPage/login_screen.dart';
import 'package:application_job/src/constants/colors.dart';
import 'package:application_job/src/user_state.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => MyApp(), // Wrap your app
  //   ),
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            // useInheritedMediaQuery: true,
            // locale: DevicePreview.locale(context),
            // builder: DevicePreview.appBuilder,
            home: Scaffold(
              backgroundColor: tBlackColor,
              body: Center(
                child: Stack(
                  children: [
                    // Positioned(
                    //   top: 200,
                    //   left: 30,
                    //   child:
                    // ),
                    Image(image: AssetImage('assets/images/jobfinder.png')),
                    const SizedBox(
                      height: 20,
                    ),
                    // Positioned(
                    //   child: Text(
                    //     "Land Your Dream Job",
                    //     style: TextStyle(
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 30),
                    //   ),
                    //   top: 450,
                    //   left: 60,
                    // ),
                    // Text(
                    //   "Land Your Dream Job",
                    //   style: TextStyle(
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 30),
                    // ),
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            // useInheritedMediaQuery: true,
            // locale: DevicePreview.locale(context),
            // builder: DevicePreview.appBuilder,
            home: const Scaffold(
              body: Center(
                child: Text(
                  'An error occured',
                  style: TextStyle(
                      color: tPrimaryColor,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          );
        }
        return MaterialApp(
          // useInheritedMediaQuery: true,
          // locale: DevicePreview.locale(context),
          // builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          title: "jobo",
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: tPrimaryColor,
          ),
          home: UserState(),
        );
      },
    );
  }
}


// MaterialApp(
      // useInheritedMediaQuery: true,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(),
//     );
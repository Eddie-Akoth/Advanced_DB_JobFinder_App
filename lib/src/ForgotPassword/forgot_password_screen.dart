import 'package:application_job/src/LoginPage/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Services/global_variables.dart';
import '../constants/colors.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>
    with TickerProviderStateMixin {
  // initialize animation
  late Animation<double> _animation;
  // animation controller
  late AnimationController _animationController;
  final TextEditingController _forgotPasswordTextController =
      TextEditingController(text: '');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Animation
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationstatus) {
            if (animationstatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();
    super.initState();
  }

  // disposing controllers and focusNodes
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _forgotPasswordSubmitForm() async {
    try {
      await _auth.sendPasswordResetEmail(
          email: _forgotPasswordTextController.text);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => Login()));
      Fluttertoast.showToast(
          msg: 'Password Reset link sent to your email',
          textColor: Colors.white,
          backgroundColor: Colors.redAccent);
    } catch (error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          textColor: Colors.white,
          backgroundColor: Colors.greenAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            placeholder: (context, url) => Image.asset(
              'assets/images/wallpaper.jpg',
              fit: BoxFit.fill,
            ),
            imageUrl: forgotUrlImage,
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Email address textfield
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _forgotPasswordTextController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white12,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: tPrimaryOnboarding3)),
                        errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent))),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  MaterialButton(
                    onPressed: () {
                      // create forgot password submit form
                      _forgotPasswordSubmitForm();
                    },
                    color: tPrimaryColor,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: RichText(
                      text: TextSpan(children: [
                        const TextSpan(
                            text: 'Remember password?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )),
                        const TextSpan(text: '    '),
                        TextSpan(
                            // remember, we are pushing from the login, thus canPop==true
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.canPop(context)
                                  ? Navigator.pop(context)
                                  : null,
                            text: 'Login',
                            style: const TextStyle(
                              color: tPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ))
                      ]),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

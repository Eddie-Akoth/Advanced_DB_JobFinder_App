import 'dart:io';

import 'package:application_job/src/Services/global_methods.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../Services/global_variables.dart';
import '../constants/colors.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  // initialize animation
  late Animation<double> _animation;
  // animation controller
  late AnimationController _animationController;

  final _signUpFormKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController =
      TextEditingController(text: "");

  final TextEditingController _emailTextController =
      TextEditingController(text: "");
  final TextEditingController _passwordTextController =
      TextEditingController(text: "");
  final TextEditingController _phoneNumberTextController =
      TextEditingController(text: "");
  final TextEditingController _locationTextController =
      TextEditingController(text: "");

  bool _obscureText = true;
  bool _isLoading = false;
  File? imageFile; //for the image upload
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? imageUrl;

  //an object used by the stateful widget to obtain the keyboard focus
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _positionCPFocusNode = FocusNode();

// disposing controllers and focusNodes
  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailTextController.dispose();
    _phoneNumberTextController.dispose();
    _locationTextController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _positionCPFocusNode.dispose();
    super.dispose();
  }

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

// function to present options when avatar is clicked
  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Please choose an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    // getfrom camera
                    _getFromCamera();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera,
                          color: tPrimaryColor,
                        ),
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(color: tPrimaryColor),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    // getfrom gallery
                    _getFromGallery();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: tPrimaryColor,
                        ),
                      ),
                      Text(
                        'Gallery',
                        style: TextStyle(color: tPrimaryColor),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  // function to allow user to take photo from camera
  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path); //passing the path to the cropper
    Navigator.pop(context); //this removes the dialog box
  }

  // function to allow user to take photo from gallery
  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    _cropImage(pickedFile!.path); //passing the path to the cropper
    Navigator.pop(context); //this removes the dialog box
  }

// function to crop image
  void _cropImage(filePath) async {
    // whenever the user picks an image (either using camera or gallery),
    // we will allow them to crop the image
    // we will pass the image into this function to be cropped
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (croppedImage != null) {
      setState(() {
        // assigning the final image to the file variable we created
        imageFile = File(croppedImage.path);
      });
    }
  }

// function to submit form to firebase
  void _submitFormOnSignUp() async {
    final isValid = _signUpFormKey.currentState!.validate();

    if (isValid) {
      if (imageFile == null) {
        // if no image, show error dialog that we created
        GlobalMethod.showErrorDialog(
            error: 'Please pick an image', context: context);
        return;
      }
      // else if imagefile is not null
      setState(() {
        _isLoading = true;
      });

      try {
        await _auth.createUserWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passwordTextController.text.trim());

        final User? user =
            _auth.currentUser; //assign current user to the user variable
        final _uid = user!.uid; //get their uid
        final ref = FirebaseStorage.instance
            .ref()
            .child('userImages')
            .child(_uid + '.jpg'); //folder to store images for user
        await ref.putFile(imageFile!);
        imageUrl = await ref.getDownloadURL(); //get downlaod url after upload
        // collection of users, set a document with uid and set the document's details with the given values
        FirebaseFirestore.instance.collection('users').doc(_uid).set({
          'id': _uid,
          'name': _fullNameController.text,
          'email': _emailTextController.text,
          'userImage': imageUrl, //the downloadable url we just got
          'phoneNumber': _phoneNumberTextController.text,
          'location': _locationTextController.text,
          'createdAt': Timestamp.now(),
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;//after user signs up, they should be redirected to login page
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(" Account created successfully."),
          backgroundColor: Colors.greenAccent,
        ));
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        // show the error dialog
        GlobalMethod.showErrorDialog(error: error.toString(), context: context);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //size of the screen
    return Scaffold(
      body: Stack(children: [
        CachedNetworkImage(
          imageUrl: signUpUrlImage,
          placeholder: (context, url) => Image.asset(
            'assets/images/wallpaper.jpg',
            fit: BoxFit.fill,
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: FractionalOffset(_animation.value, 0),
        ),
        Container(
          color: Colors.black54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
            child: ListView(
              children: [
                Form(
                  key: _signUpFormKey,
                  child: Column(
                    children: [
                      // FOR THE AVATAR UPLOAD
                      GestureDetector(
                        onTap: () {
                          // create show image dialog
                          _showImageDialog();
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: size.width * 0.24,
                              height: size.width * 0.24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1, color: tPrimaryOnboarding3),
                                borderRadius: BorderRadius.circular(20),
                              ),

                              // creates a rectangular clip
                              child: ClipRRect(
                                //if imageFile exists, show it, if not show camera icon
                                borderRadius: BorderRadius.circular(16),
                                child: imageFile == null
                                    ? const Icon(
                                        Icons.camera_enhance_rounded,
                                        color: tPrimaryOnboarding3,
                                        size: 30,
                                      )
                                    : Image.file(imageFile!, fit: BoxFit.fill),
                              ),
                            )),
                      ),
                      // NAME
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(_emailFocusNode),
                        keyboardType: TextInputType.name,
                        controller: _fullNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required';
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: "Full name/ Company Name",
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: tPrimaryOnboarding3)),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.redAccent))),
                      ),

                      // EMAIL INPUT FIELD
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(_passwordFocusNode),
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailTextController,
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address';
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: tPrimaryOnboarding3)),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.redAccent))),
                      ),

                      // PASSWORD INPUT FIELD
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(_phoneNumberFocusNode),
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passwordTextController,
                        obscureText: !_obscureText,
                        validator: (value) {
                          if (value!.isEmpty || value.length < 7) {
                            return 'please enter a valid password not less than 7 characters';
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                            ),
                            hintText: "Password",
                            hintStyle: const TextStyle(color: Colors.white54),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: tPrimaryOnboarding3)),
                            errorBorder: const UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.redAccent))),
                      ),

                      //PHONE NUMBER
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(_positionCPFocusNode),
                        keyboardType: TextInputType.phone,
                        controller: _phoneNumberTextController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required';
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: "Phone Number",
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: tPrimaryOnboarding3)),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.redAccent))),
                      ),

                      // LOCATION INPUT
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => FocusScope.of(context)
                            .requestFocus(
                                _positionCPFocusNode), //last form field, thus focus remains here
                        keyboardType: TextInputType.text,
                        controller: _locationTextController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required';
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: "Address",
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: tPrimaryOnboarding3)),
                            errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.redAccent))),
                      ),

                      //SIGNUP BUTTON
                      // If loading, show progress indicator, else button
                      const SizedBox(
                        height: 30,
                      ),
                      _isLoading
                          ? Center(
                              child: Container(
                                width: 70,
                                height: 70,
                                child: const CircularProgressIndicator(
                                  backgroundColor: tdismissable,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      tPrimaryColor),
                                ),
                              ),
                            )
                          : MaterialButton(
                              onPressed: () {
                                //submit form on signup
                                _submitFormOnSignUp();
                              },
                              color: tPrimaryColor,
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "SignUp",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                      //  ALREADY HAVE AN ACCOUNT
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: RichText(
                          text: TextSpan(children: [
                            const TextSpan(
                                text: 'Already have an account',
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
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

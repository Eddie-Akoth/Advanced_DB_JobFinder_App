import 'package:application_job/src/Services/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../Persistent/persistent.dart';
import '../Services/global_variables.dart';
import '../Widgets/bottom_navigation_bar.dart';
import '../constants/colors.dart';

class UploadJob extends StatefulWidget {
  const UploadJob({super.key});

  @override
  State<UploadJob> createState() => _UploadJobState();
}

class _UploadJobState extends State<UploadJob> {
  final _formKey = GlobalKey<FormState>();

// controllers
  final TextEditingController _jobCategoryController =
      TextEditingController(text: 'Select Job Category');
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDeadlineController =
      TextEditingController(text: 'Select Deadline Date');
  final TextEditingController _jobDescriptionController =
      TextEditingController();

  bool _isLoading = false;

// Titles
  Widget _textTitles({required String label}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // FormFields
  Widget _textFormFields(
      {required String valueKey,
      required TextEditingController controller,
      required bool enabled,
      required Function fct,
      required int maxLength}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Value is missing';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: TextStyle(color: Colors.black),
          maxLines: valueKey == "JobDescription" ? 5 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            filled: true,
            fillColor: tdismissable,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: tPrimaryOnboarding3)),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ),
    );
  }

// to show job categories
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
                          _jobCategoryController.text =
                              Persistent.jobCategoryList[index];
                        });
                        Navigator.pop(
                            context); //remove dialog box after it user has selected
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

  // date picker
  DateTime? picked;
  Timestamp? deadlineDateTimeStamp;
  void _pickDateDialog() async {
    picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now()
            .subtract(const Duration(days: 0)), //first selectable date
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                  primary: tPrimaryColor,
                  onPrimary: Colors.white,
                  onSurface: tPrimaryColor),
            ),
            child: child!,
          );
        });
    if (picked != null) {
      setState(() {
        _jobDeadlineController.text =
            '${picked!.year} - ${picked!.month} - ${picked!.day}';
        deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(
            picked!.microsecondsSinceEpoch);
      });
    }
  }

// upload task to firebase
  void _uploadJob() async {
    final jobId = const Uuid().v4(); //randomly generate the id
    User? user =
        FirebaseAuth.instance.currentUser; //get current user from firebase
    print(user);
    // print(user!.email);
    final _uid = user!.uid;
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      // if they have not been filled, show error dialog we created
      if (_jobDeadlineController.text == "Select Deadline Date" ||
          _jobCategoryController.text == 'Select Job Category') {
        GlobalMethod.showErrorDialog(
            error: 'Please fill out all the fields', context: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        // upload the data to firebase firestore
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).set({
          'jobId': jobId,
          'uploadedBy': _uid,
          'email': user.email,
          'jobTitle': _jobTitleController.text,
          'jobDescription': _jobDescriptionController.text,
          'deadlineDate': _jobDeadlineController.text,
          'deadlineDateTimeStamp': deadlineDateTimeStamp,
          'jobCategory': _jobCategoryController.text,
          'jobComments': [],
          'requirement': true,
          'createdAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'location': location,
          'applicants': 0
        });

        await Fluttertoast.showToast(
            msg: 'Job Uploaded Successfully',
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.greenAccent);
// restore the input fields to previous form
        _jobTitleController.clear();
        _jobDescriptionController.clear();
        setState(() {
          _jobCategoryController.text = "Select Job Category";
          _jobDeadlineController.text = "Select Deadline Date";
        });
      } catch (error) {
        {
          setState(() {
            _isLoading = false;
          });
          // the error dialog we created
          GlobalMethod.showErrorDialog(
              error: error.toString(), context: context);
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Action Not valid');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _jobDeadlineController.dispose();
    super.dispose();
  }

// // method to fetch name, location and image of user from the users collection and upload it with the job here
//   //method will be called when widget is mounted, thus called within initState
//   void getAdditionalData() async {
//     // get the user with uid equal to the one who is logged in, since this is the person posting
//     final DocumentSnapshot userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .get();

//     setState(() {
//       name = userDoc.get('name');
//       userImage = userDoc.get('userImage');
//       location = userDoc.get('location');
//     });
//   }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   getAdditionalData();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 2),
      appBar: AppBar(
        title: const Text(
          'Upload Job',
          style: TextStyle(color: tPrimaryColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Card(
            elevation: 0,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text(
                        'Please fill all fields',
                        style: TextStyle(
                            color: tPrimaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _textTitles(label: 'Job Category: '),
                          _textFormFields(
                            valueKey: "JobCategory",
                            controller: _jobCategoryController,
                            enabled: false,
                            fct: () {
                              // the onclick event
                              _showJobCategoriesDialog(size: size);
                            },
                            maxLength: 100,
                          ),
                          _textTitles(label: 'Job Title: '),
                          _textFormFields(
                            valueKey: "JobTitle",
                            controller: _jobTitleController,
                            enabled: true,
                            fct: () {
                              // the onclick event
                            },
                            maxLength: 100,
                          ),
                          _textTitles(label: 'Job Description: '),
                          _textFormFields(
                            valueKey: "JobDescription",
                            controller: _jobDescriptionController,
                            enabled: true,
                            fct: () {
                              // the onclick event
                            },
                            maxLength: 100,
                          ),
                          _textTitles(label: 'Application Deadline: '),
                          _textFormFields(
                            valueKey: "Deadline",
                            controller: _jobDeadlineController,
                            enabled: false,
                            fct: () {
                              // the onclick event
                              _pickDateDialog();
                            },
                            maxLength: 100,
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      backgroundColor: tdismissable,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          tPrimaryColor),
                                    )
                                  : MaterialButton(
                                      onPressed: () {
                                        _uploadJob();
                                      },
                                      color: tPrimaryColor,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              "Post Job",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 9,
                                            ),
                                            Icon(
                                              Icons.upload_file_rounded,
                                              color: Colors.white,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

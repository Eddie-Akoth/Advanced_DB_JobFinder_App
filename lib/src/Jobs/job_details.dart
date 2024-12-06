import 'package:application_job/src/Services/global_methods.dart';
import 'package:application_job/src/Widgets/comments_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../Services/global_variables.dart';
import '../Widgets/divider_widget.dart';
import '../constants/colors.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen(
      {super.key,
      required this.uploadedBy,
      required this.jobId,
      required this.authorImgUrl});
// will be passed from context
  final String uploadedBy;
  final String jobId;
  final String authorImgUrl;
  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isCommenting = false;
  bool showComment = false;
  final TextEditingController _commentController = TextEditingController();

  String? authorName;
  String? userImageUrl;
  String? jobCategory;
  String? jobDescription;
  String? jobTitle;
  bool? requirement;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadlineDate;
  String? locationCompany = '';
  String? emailCompany = '';
  int applicants = 0;
  bool isDeadlineAvailable = true;

// get job details for a job with specific ID. This page is accessed onpress from the JobWidget
  void getJobData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();

    if (userDoc == null) {
      return;
    } else {
      setState(() {
        // get name and userimage
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot jobDatabase = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .get();
    if (jobDatabase == null) {
      return;
    } else {
      setState(() {
        jobTitle = jobDatabase.get('jobTitle');
        jobDescription = jobDatabase.get('jobDescription');
        requirement = jobDatabase.get('requirement');
        emailCompany = jobDatabase.get('email');
        locationCompany = jobDatabase.get('location');
        applicants = jobDatabase.get('applicants');
        postedDateTimeStamp = jobDatabase.get('createdAt');
        deadlineDateTimeStamp = jobDatabase.get('deadlineDateTimeStamp');
        deadlineDate = jobDatabase.get('deadlineDate');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year} - ${postDate.month} - ${postDate.day}';
      });

      var date = deadlineDateTimeStamp!.toDate();
      isDeadlineAvailable =
          date.isAfter(DateTime.now()); //checking if deadline has passed
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getJobData();
    super.initState();
  }

// Apply method: send user to their email to upload cv
  applyForJob() {
    // creates the url we need
    final Uri params = Uri(
        scheme: 'mailto',
        path: emailCompany,
        query:
            'subject=Job Application for $jobTitle&body=Hello, Find attached my Resume/CV');
    final url = params.toString();
    launchUrlString(url);
    // need to increment applicants for this job by one
    addNewApplicant();
  }

// methdd to increment applicant value when apply button is clicked
  void addNewApplicant() async {
    var docRef =
        FirebaseFirestore.instance.collection('jobs').doc(widget.jobId);

    docRef.update({
      'applicants': applicants + 1,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: tPrimaryColor,
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(color: tPrimaryColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // JOB TITLE
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          jobTitle == null ? 'No Title Available' : jobTitle!,
                          maxLines: 3,
                          style: const TextStyle(
                              color: tPrimaryColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      // IMAGE
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(width: 1, color: Colors.black26),
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                image: NetworkImage(userImageUrl == null
                                    ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'
                                    : widget.authorImgUrl),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authorName == null
                                      ? 'No name available'
                                      : authorName!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black54),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  locationCompany == null
                                      ? 'No location available'
                                      : locationCompany!,
                                  style: const TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      dividerWidget(),
                      // APPLICANTS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            applicants.toString(),
                            style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          const Text(
                            'Applicants',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.how_to_reg_rounded,
                            color: Colors.grey,
                          )
                        ],
                      ),

                      // RECRUITMENT
                      // if the job has been uploaded by current user, show whether recruitment is on
                      FirebaseAuth.instance.currentUser!.uid !=
                              widget.uploadedBy
                          ?
                          // if not show empty container
                          Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                dividerWidget(),
                                const Text(
                                  'Recruiting:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        User? user = _auth.currentUser;
                                        final _uid = user!.uid;
                                        if (_uid == widget.uploadedBy) {
                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('jobs')
                                                .doc(widget.jobId)
                                                .update({'requirement': true});

                                            await Fluttertoast.showToast(
                                                msg:
                                                    'Recruitment updated Successfully',
                                                toastLength: Toast.LENGTH_LONG,
                                                backgroundColor:
                                                    Colors.greenAccent);
                                          } catch (error) {
                                            GlobalMethod.showErrorDialog(
                                              error:
                                                  'Action cannot be performed: ${error.toString()}',
                                              context: context,
                                            );
                                          }
                                        } else {
                                          GlobalMethod.showErrorDialog(
                                            error:
                                                'You cannot perform this action',
                                            context: context,
                                          );
                                        }
                                        getJobData(); //to update the data being rendered after change
                                      },
                                      child: const Text(
                                        'YES',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: requirement == true ? 1 : 0,
                                      child: const Icon(
                                        Icons.check_box_rounded,
                                        color: tPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 40,
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        User? user = _auth.currentUser;
                                        final _uid = user!.uid;
                                        if (_uid == widget.uploadedBy) {
                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('jobs')
                                                .doc(widget.jobId)
                                                .update({'requirement': false});

                                            await Fluttertoast.showToast(
                                                msg:
                                                    'Recruitment updated Successfully',
                                                toastLength: Toast.LENGTH_LONG,
                                                backgroundColor:
                                                    Colors.greenAccent);
                                          } catch (error) {
                                            GlobalMethod.showErrorDialog(
                                              error:
                                                  'Action cannot be performed: ${error.toString()}',
                                              context: context,
                                            );
                                          }
                                        } else {
                                          GlobalMethod.showErrorDialog(
                                            error:
                                                'You cannot perform this action',
                                            context: context,
                                          );
                                        }
                                        getJobData(); //to update the data being rendered after change
                                      },
                                      child: const Text(
                                        'NO',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Opacity(
                                      opacity: requirement == false ? 1 : 0,
                                      child: const Icon(
                                        Icons.check_box_rounded,
                                        color: tPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      dividerWidget(),
                      // JOB DESCRIPTION
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Job Description:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        jobDescription == null
                            ? 'No Job desciption available'
                            : jobDescription!,
                        textAlign: TextAlign.justify,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      // dividerWidget(),
                      const SizedBox(
                        height: 15,
                      )
                    ],
                  ),
                ),
              ),
            ),

            // ANOTHER CARD
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DEADLINE
                      Center(
                        child: Text(
                          isDeadlineAvailable
                              ? 'Actively Recruiting, Send CV/Resume'
                              : 'Deadline Passed',
                          style: TextStyle(
                              color: isDeadlineAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // APPLY BUTTON
                      Center(
                        child: MaterialButton(
                          onPressed: () {
                            applyForJob();
                          },
                          color: tPrimaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Text(
                              'Apply',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      dividerWidget(),
                      // UPLOADED ON TIMESTAMP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upload on:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            postedDate == null ? '' : postedDate!,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      // DEADLINE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Deadline:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            deadlineDate == null ? '' : deadlineDate!,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),

            // COMMENTS SECTION
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(microseconds: 500),
                        child: _isCommenting
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // COMMENT TEXT FIELD
                                  Flexible(
                                    flex: 3,
                                    child: TextField(
                                      controller: _commentController,
                                      style: const TextStyle(
                                          color: Colors.black54),
                                      maxLength: 200,
                                      keyboardType: TextInputType.text,
                                      maxLines: 15,
                                      decoration: const InputDecoration(
                                          filled: true,
                                          fillColor: tdismissable,
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: tPrimaryOnboarding3)),
                                          errorBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.redAccent))),
                                    ),
                                  ),
                                  // POST/CANCEL BUTTONS
                                  Flexible(
                                      child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        // POST BUTTON
                                        child: MaterialButton(
                                          onPressed: () async {
                                            if (_commentController.text.length <
                                                7) {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'Comment Cannot be less than 7 characters',
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  fontSize: 18);
                                            } else {
                                              final _generatedId =
                                                  const Uuid().v4();
                                              await FirebaseFirestore.instance
                                                  .collection('jobs')
                                                  .doc(widget.jobId)
                                                  .update({
                                                'jobComments':
                                                    FieldValue.arrayUnion([
                                                  {
                                                    'userId': FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    'commentId': _generatedId,
                                                    'name': name,
                                                    'userImageUrl': userImage,
                                                    'commentBody':
                                                        _commentController.text,
                                                    'time': Timestamp.now(),
                                                  }
                                                ])
                                              });
                                              Fluttertoast.showToast(
                                                  msg: 'Comment posted',
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  backgroundColor:
                                                      Colors.greenAccent,
                                                  fontSize: 18);
                                              _commentController.clear();
                                            }
                                            setState(() {
                                              showComment = true;
                                            });
                                          },
                                          color: tPrimaryColor,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Post',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      // CANCEL BUTTON
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _isCommenting = !_isCommenting;
                                            showComment = false;
                                          });
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              )
                            // COMMENT AND DROPDOWN ICONS
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isCommenting = !_isCommenting;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add_comment_rounded,
                                      color: tPrimaryColor,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showComment = !showComment;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.arrow_drop_down_circle_rounded,
                                      color: tPrimaryColor,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      // COMMENT SECTION
                      showComment == false
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.all(
                                8.0,
                              ),
                              child: FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('jobs')
                                      .doc(widget.jobId)
                                      .get(),
                                  builder: ((context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          backgroundColor: tdismissable,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  tPrimaryColor),
                                        ),
                                      );
                                    } else {
                                      if (snapshot.data == null) {
                                        const Center(
                                          child: Text('No comments'),
                                        );
                                      }
                                    }
                                    return ListView.separated(
                                      shrinkWrap: true, //separate by list items
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return CommentWidget(
                                          commentId:
                                              snapshot.data!['jobComments']
                                                  [index]['commentId'],
                                          commenterId:
                                              snapshot.data!['jobComments']
                                                  [index]['userId'],
                                          commenterName:
                                              snapshot.data!['jobComments']
                                                  [index]['name'],
                                          commentBody:
                                              snapshot.data!['jobComments']
                                                  [index]['commentBody'],
                                          commenterImgUrl:
                                              snapshot.data!['jobComments']
                                                  [index]['userImageUrl'],
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return const Divider(
                                          thickness: 1,
                                          color: Colors.black12,
                                        );
                                      },
                                      itemCount:
                                          snapshot.data!['jobComments'].length,
                                    );
                                  })),
                            ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

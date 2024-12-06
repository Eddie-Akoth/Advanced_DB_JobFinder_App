import 'package:application_job/src/Services/global_methods.dart';
import 'package:application_job/src/Widgets/divider_widget.dart';
import 'package:application_job/src/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:fluttericon/font_awesome_icons.dart';

import '../Widgets/bottom_navigation_bar.dart';
import '../constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userID});
  final String userID;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? name;
  String email = '';
  String phoneNumber = '';
  String imageUrl = '';
  String joinedAt = '';
  bool _isLoading = false;
  bool _isSameUser = false;

// function to get user data, called in initState
  void getUserData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          name = userDoc.get('name');
          email = userDoc.get('email');
          phoneNumber = userDoc.get('phoneNumber');
          imageUrl = userDoc.get('userImage');
          Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimeStamp.toDate();
          joinedAt =
              '${joinedDate.year} - ${joinedDate.month} - ${joinedDate.day}';
        });
        User? user = _auth.currentUser;
        final _uid = user!.uid;
        setState(() {
          _isSameUser = _uid == widget.userID;
        });
      }
    } catch (error) {
      GlobalMethod.showErrorDialog(error: error.toString(), context: context);
    } finally {
      _isLoading = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserData();
    super.initState();
  }

  Widget userInfo({required IconData icon, required String content}) {
    return Row(
      children: [
        Icon(
          icon,
          color: tPrimaryColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: const TextStyle(color: Colors.grey),
          ),
        )
      ],
    );
  }

  Widget _contactIcon(
      {required Color color, required Function fct, required IconData icon}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white38,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: () {
            fct();
          },
        ),
      ),
    );
  }

  // method to launch whatsapp
  void _openWhatsAppChat() async {
    var url = 'https://wa.me/$phoneNumber?text=HelloThere';
    launchUrlString(url);
  }

  // method to launch mail message
  void _mailMessage() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Initiating Contact From Jobfinder, Please&body=Hello, please write details here',
    );
    final url = params.toString();
    launchUrlString(url);
  }

  // method to launch call
  void _callPhoneNumber() async {
    var url = 'tel://$phoneNumber';
    launchUrlString(url);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 3),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: tPrimaryColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  backgroundColor: tdismissable,
                  valueColor: AlwaysStoppedAnimation<Color>(tPrimaryColor),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Stack(
                    children: [
                      Card(
                        color: tdismissable,
                        margin: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 100,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  name == null ? 'No Name Available' : name!,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              dividerWidget(),
                              const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  'Account Information:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: userInfo(
                                  icon: Icons.email_rounded,
                                  content: email,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: userInfo(
                                  icon: Icons.phone,
                                  content: phoneNumber,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              dividerWidget(),
                              const SizedBox(
                                height: 25,
                              ),
                              _isSameUser
                                  ? Container()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _contactIcon(
                                          color: Colors.greenAccent,
                                          fct: () {
                                            _openWhatsAppChat();
                                          },
                                          icon: FontAwesome.whatsapp,
                                        ),
                                        _contactIcon(
                                          color: Colors.redAccent,
                                          fct: () {
                                            _mailMessage();
                                          },
                                          icon: Icons.mail_rounded,
                                        ),
                                        _contactIcon(
                                          color: Colors.blueAccent,
                                          fct: () {
                                            _callPhoneNumber();
                                          },
                                          icon: Icons.phone,
                                        ),
                                      ],
                                    ),
                              const SizedBox(
                                height: 15,
                              ),
                             
                              !_isSameUser
                                  ? Container()
                                  : Center(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 30),
                                        child: MaterialButton(
                                          onPressed: () {
                                            _auth.signOut();
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserState(),
                                              ),
                                            );
                                            Fluttertoast.showToast(
                                                msg: 'Logged Out Successfully',
                                                toastLength: Toast.LENGTH_LONG,
                                                backgroundColor:
                                                    Colors.greenAccent);
                                          },
                                          color: tPrimaryColor,
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                                  'Logout',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Icon(
                                                  Icons.logout_rounded,
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
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width * 0.26,
                            height: size.width * 0.26,
                            decoration: BoxDecoration(
                              color: tPrimaryColor,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(width: 5, color: tPrimaryColor),
                              image: DecorationImage(
                                  image: NetworkImage(
                                    // ignore: prefer_if_null_operators
                                    imageUrl == null
                                        ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'
                                        : imageUrl,
                                  ),
                                  fit: BoxFit.fill),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

import 'package:application_job/src/Search/profile_company.dart';
import 'package:application_job/src/Services/global_methods.dart';
import 'package:application_job/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AllWorkersWidget extends StatefulWidget {
  const AllWorkersWidget(
      {super.key,
      required this.userID,
      required this.userName,
      required this.userEmail,
      required this.phoneNumber,
      required this.userImgUrl});
  final String userID;
  final String userName;
  final String userEmail;
  final String phoneNumber;
  final String userImgUrl;
  @override
  State<AllWorkersWidget> createState() => _AllWorkersWidgetState();
}

class _AllWorkersWidgetState extends State<AllWorkersWidget> {
  void _mailTo() async {
    var mailUrl = 'mailto: ${widget.userEmail}';

    if (await canLaunchUrlString(mailUrl)) {
      //if it can launch the urlstring
      launchUrlString(mailUrl);
    } else {
      // ignore: use_build_context_synchronously
      GlobalMethod.showErrorDialog(
          error: "Not able to send email", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userID: widget.userID),
            ),
          );
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          height: 60,
          width: 60,
          padding: const EdgeInsets.only(right: 12),
          decoration:
              const BoxDecoration(border: Border(right: BorderSide(width: 1))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 20,
              // ignore: prefer_if_null_operators
              child: Image.network(
                widget.userImgUrl == null
                    ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'
                    : widget.userImgUrl,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        title: Text(
          widget.userName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text(
              'Visit Profile',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
        trailing: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userID: widget.userID),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_circle_right_rounded,
              size: 35,
              color: tPrimaryColor,
            )),
      ),
    );
  }
}

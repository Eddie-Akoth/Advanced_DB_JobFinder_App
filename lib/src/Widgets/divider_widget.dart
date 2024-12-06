// divider to be used to
import 'package:flutter/material.dart';

Widget dividerWidget() {
  return Column(
    children: const [
      SizedBox(
        height: 10,
      ),
      Divider(
        thickness: 1,
        color: Colors.black12,
      ),
      SizedBox(
        height: 10,
      ),
    ],
  );
}

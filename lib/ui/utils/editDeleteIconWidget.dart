import 'package:flutter/material.dart';

Widget textAndIconWidget(IconData icon, String text, context) {
  return Row(
    children: [
      Icon(icon, size: 19),
      SizedBox(width: 10),
      Text(
        text,
        style: TextStyle(
          fontSize: 17,
          color: Colors.black87,
        ),
      ),
    ],
  );
}

Widget textAndImageIconWidget(String imageIcon, String text, context) {
  return Row(
    children: [
      Image.asset(imageIcon, width: 17),
      SizedBox(width: 10),
      Text(
        text,
        style: TextStyle(
          fontSize: 17,
          color: Colors.black87,
        ),
      ),
    ],
  );
}


Widget textAndImageIconWidgetDemote(String imageIcon, imageColor, String text, context) {
  return Row(
    children: [
      Image.asset(imageIcon, color: Color(imageColor), width: 17),
      SizedBox(width: 10),
      Text(
        text,
        style: TextStyle(
          fontSize: 17,
          color: Colors.black87,
        ),
      ),
    ],
  );
}


Widget textAndImageIconWidgetWithSize(String imageIcon, double size, String text, context) {
  return Row(
    children: [
      Image.asset(imageIcon, width: size),
      SizedBox(width: 10),
      Text(
        text,
        style: TextStyle(
          fontSize: 17,
          color: Colors.black87,
        ),
      ),
    ],
  );
}


Widget messageIconTextWidget(String imageIcon, String text, context) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Image.asset(imageIcon, width: 17),
      ),
      SizedBox(width: 10),
      Text(
        text,
        style: TextStyle(
          fontSize: 17,
          color: Colors.black87,
        ),
      ),
    ],
  );
}
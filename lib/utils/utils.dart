import 'package:flutter/material.dart';
import 'package:usage/uuid/uuid.dart';

export 'firestore_manager.dart';
export 'preference_manager.dart';
export 'search_manager.dart';

class Utils {
  static String getUuid() {
    return Uuid().generateV4();
  }
}

bool isLeapYear(int year) {
  return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
}

bool isSameDay(DateTime d1, DateTime d2) {
  return (d1.year == d2.year && d1.month == d2.month && d1.day == d2.day);
}

Widget getEmptyWidget(String title, String notFoundValue) {
  return Center(
    child: Text(
      notFoundValue,
      overflow: TextOverflow.ellipsis,
      style: sectionHeadingStyle,
    ),
  );
}

TextStyle get sectionHeadingStyle {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontFamily: 'Europa',
    fontSize: 12.5,
    color: Colors.black,
  );
}

TextStyle get sectionTextStyle {
  return TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 11,
    color: Colors.grey,
  );
}

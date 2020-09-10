import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
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

Future<File> createFileOfPdfUrl(String documentUrl, String documentName) async {
  final url = documentUrl;
  final filename = documentName;
  var request = await HttpClient().getUrl(Uri.parse(url));
  var response = await request.close();
  var bytes = await consolidateHttpClientResponseBytes(response);
  String dir = (await getApplicationDocumentsDirectory()).path;
  File file = new File('$dir/$filename');
  await file.writeAsBytes(bytes);
  return file;
}

String getReviewMessage(
    {String userName,
    String requestTitle,
    String reviewMessage,
    bool isForCreator,
    bool isOfferReview = false,
    BuildContext context}) {
  String offerReview = '${S.of(context).offerReview} $requestTitle';
  String body = isForCreator
      ? S.of(context).request_review_body_creator
      : S.of(context).request_review_body_user;
  String review =
      '$userName ${S.of(context).has_given_review} \n\n${isOfferReview ? offerReview : body} $requestTitle \n${S.of(context).review}:\n\n$reviewMessage';
  return review;
}

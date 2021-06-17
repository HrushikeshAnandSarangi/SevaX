import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:usage/uuid/uuid.dart';

import '../flavor_config.dart';

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

bool isMemberAnAdmin(TimebankModel timebank, String userId) =>
    timebank.creatorId == userId ||
    timebank.admins.contains(userId) ||
    timebank.organizers.contains(userId);

bool isAccessAvailable(TimebankModel timebank, String userId) =>
    timebank.creatorId == userId ||
    timebank.admins.contains(userId) ||
    timebank.organizers.contains(userId) ||
    timebank.managedCreatorIds.contains(userId);

bool isDeletable({
  BuildContext context,
  String communityCreatorId,
  String timebankCreatorId,
  String contentCreatorId,
}) =>
    contentCreatorId == SevaCore.of(context).loggedInUser.sevaUserID ||
    communityCreatorId == SevaCore.of(context).loggedInUser.sevaUserID ||
    timebankCreatorId == SevaCore.of(context).loggedInUser.sevaUserID;

bool isOwnerCreator(TimebankModel timebank, String userId) =>
    timebank.creatorId == userId || timebank.organizers.contains(userId);

bool isMemberBlocked(UserModel user, String idToCheck) {
  return user.blockedBy.contains(idToCheck) ||
      user.blockedMembers.contains(idToCheck);
}

UserRole getLoggedInUserRole(TimebankModel model, String userId) {
  if (model.creatorId == userId) {
    if (model.parentTimebankId == FlavorConfig.values.timebankId ||
        model.managedCreatorIds != null &&
            model.managedCreatorIds.contains(userId)) {
      return UserRole.TimebankCreator;
    } else {
      return UserRole.Creator;
    }
  } else if (model.organizers.contains(userId)) {
    return UserRole.Organizer;
  } else if (model.admins.contains(userId)) {
    return UserRole.Admin;
  } else {
    return UserRole.Member;
  }
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

Widget getEmptyWidgetLeftAligned(String title, String notFoundValue) {
  return Text(
    notFoundValue,
    overflow: TextOverflow.ellipsis,
    style: sectionHeadingStyle,
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

void showAdminAccessMessage({BuildContext context}) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext _context) {
      // return object of type Dialog
      return AlertDialog(
        title: Text(S.of(context).alert),
        content: Text(S.of(context).sevax_global_creation_error),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          CustomTextButton(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            color: Theme.of(context).accentColor,
            textColor: FlavorConfig.values.buttonTextColor,
            child: Text(S.of(context).close),
            onPressed: () {
              Navigator.of(_context).pop();
            },
          ),
        ],
      );
    },
  );
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class CommonUtils {
  static Widget TotalCredits({
    BuildContext context,
    RequestModel requestModel,
    TotalCreditseMode requestCreditsMode,
  }) {
    var label;
    var totalCredits =
        requestModel.numberOfApprovals * (requestModel.maxCredits ?? 1);
    requestModel.numberOfHours = totalCredits;

    if ((requestModel.maxCredits ?? 0) > 0 && totalCredits > 0) {
      if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
        label = totalCredits.toString() +
            ' ' +
            S.of(context).timebank_max_seva_credit_message1 +
            requestModel.maxCredits.toString() +
            ' ' +
            S.of(context).timebank_max_seva_credit_message2;
      } else {
        label = totalCredits.toString() +
            ' ' +
            S.of(context).personal_max_seva_credit_message1 +
            requestModel.maxCredits.toString() +
            ' ' +
            S.of(context).personal_max_seva_credit_message2;
      }
    } else {
      label = "";
    }

    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          fontFamily: 'Europa',
          color: Colors.black54,
        ),
      ),
    );
  }
}

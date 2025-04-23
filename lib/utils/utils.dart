import 'package:universal_io/io.dart' as io;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:currency_converter_pro/currency_converter_pro.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/widgets/request_enums.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:uuid/uuid.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';

import '../flavor_config.dart';

export 'firestore_manager.dart';
export 'preference_manager.dart';
export 'search_manager.dart';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class Utils {
  static String getUuid() {
    return Uuid().v4();
  }
}

bool isLeapYear(int year) {
  return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
}

bool isSameDay(DateTime d1, DateTime d2) {
  return (d1.year == d2.year && d1.month == d2.month && d1.day == d2.day);
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
  BuildContext? context,
  String? communityCreatorId,
  String? timebankCreatorId,
  String? contentCreatorId,
}) =>
    contentCreatorId == SevaCore.of(context!).loggedInUser.sevaUserID ||
    communityCreatorId == SevaCore.of(context).loggedInUser.sevaUserID ||
    timebankCreatorId == SevaCore.of(context).loggedInUser.sevaUserID;

bool isOwnerCreator(TimebankModel timebank, String userId) =>
    timebank.creatorId == userId || timebank.organizers.contains(userId);

bool isMemberBlocked(UserModel user, String idToCheck) {
  return user.blockedBy!.contains(idToCheck) ||
      user.blockedMembers!.contains(idToCheck);
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

Future<io.File> createFileOfPdfUrl(
    String documentUrl, String documentName) async {
  final url = documentUrl;
  final filename = documentName;
  var request = await io.HttpClient().getUrl(Uri.parse(url));
  var response = await request.close();
  var bytes = await consolidateHttpClientResponseBytes(response);
  String dir = (await getApplicationDocumentsDirectory()).path;
  io.File file = new io.File('$dir/$filename.pdf');
  return file.writeAsBytes(bytes).then((value) => value);
  // return file;
}

String getReviewMessage(
    {String? userName,
    String? requestTitle,
    String? reviewMessage,
    bool? isForCreator,
    bool? isOfferReview = false,
    BuildContext? context,
    bool? isFromOfferRequest}) {
  String offerReview = '${S.of(context!).offerReview} $requestTitle';
  String body = (isForCreator ?? false)
      ? S.of(context).request_review_body_creator
      : S.of(context).request_review_body_user;
  String review =
      '$userName ${S.of(context).has_given_review} \n\n${(isOfferReview ?? false) ? offerReview : body} $requestTitle \n${S.of(context).review}:\n\n$reviewMessage';
  return review;
}

void showAdminAccessMessage({BuildContext? context}) {
  // flutter defined function
  showDialog(
    context: context!,
    builder: (BuildContext _context) {
      // return object of type Dialog
      return AlertDialog(
        title: Text(S.of(context).alert),
        content: Text(S.of(context).sevax_global_creation_error),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          CustomTextButton(
            shape: StadiumBorder(),
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            color: Theme.of(context).colorScheme.secondary,
            textColor: Colors.white,
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

Future<io.File> urlToFile(String imageUrl) async {
// generate random number.
  var rng = new Random();
// get temporary directory of device.
  io.Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
  String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
  io.File file =
      new io.File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
// call http.get method and pass imageUrl into it to get response.
  http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
  await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
  return file;
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
    required BuildContext context,
    required RequestModel requestModel,
    TotalCreditseMode? requestCreditsMode,
  }) {
    String label = "";
    int totalCredits =
        (requestModel.numberOfApprovals ?? 0) * (requestModel.maxCredits ?? 1);
    requestModel.numberOfHours = totalCredits;

    if ((requestModel.maxCredits ?? 0) > 0 && totalCredits > 0) {
      if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
        label = totalCredits.toString() +
            ' ' +
            S.of(context).timebank_max_seva_credit_message1 +
            (requestModel.maxCredits ?? '').toString() +
            ' ' +
            S.of(context).timebank_max_seva_credit_message2;
      } else {
        label = totalCredits.toString() +
            ' ' +
            S.of(context).personal_max_seva_credit_message1 +
            (requestModel.maxCredits ?? '').toString() +
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

Future<bool> deleteFireBaseImage({required String imageUrl}) async {
  return FirebaseStorage.instance.refFromURL(imageUrl).delete().then((value) {
    return true;
  }).catchError((e) {
    return false;
  });
}

String getStartDateFormat(DateTime date,
    {DateFormat? formatter, DateTime Function(int)? getDateTime}) {
  var suffix = "th";
  var digit = date.day % 10;
  if ((digit > 0 && digit < 4) && (date.day < 11 || date.day > 13)) {
    suffix = ["st", "nd", "rd"][digit - 1];
  }
  if (getDateTime == null)
    return DateFormat("EEEE MMM d'$suffix',  h:mm a").format(date);
  else
    return DateFormat("EEEE MMM d'$suffix',  h:mm a")
        .format(getDateTime(date.millisecondsSinceEpoch));
}

Future<double> currencyConversion({
  required String fromCurrency,
  required String toCurrency,
  required double amount,
}) async {
  // Please ensure you have the correct import for Frankfurter and Currency
  final frankfurter = CurrencyConverterPro();

  // logger.i("from: $fromCurrency || to: $toCurrency  || amount: $amount");
  if (fromCurrency == "") {
    fromCurrency = "USD";
  }
  if (toCurrency == "") {
    toCurrency = "USD";
  }
  if (amount == 0.0) {
    amount = 0.0;
  }
  if (fromCurrency == toCurrency) {
    return amount;
  }
  double convertedCurrency = await frankfurter.convertCurrency(
    fromCurrency: fromCurrency,
    toCurrency: toCurrency,
    amount: amount,
  );
  double convertedCurrencyTwoDecimalPoint =
      ((convertedCurrency * pow(10, 2)).round()) / pow(10, 2);
  return convertedCurrencyTwoDecimalPoint;
}

String createCryptoRandomString([int length = 10]) {
  String randomCode = Uuid().v4().substring(0, length);
  return randomCode;
}

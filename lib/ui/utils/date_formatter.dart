import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/utils/app_config.dart';

String getTimeFormattedString(int timeInMilliseconds) {
  // DateFormat dateFormat = DateFormat('d MMM h:m a ', Locale(AppConfig.prefs.getString('language_code')).toLanguageTag());
  DateFormat dateFormat = DateFormat('d MMM h:m a ');
  String dateOfTransaction = dateFormat.format(
    DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
  );
  return dateOfTransaction;
}

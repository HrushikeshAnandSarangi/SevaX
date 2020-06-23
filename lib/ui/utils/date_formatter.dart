import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';

String getTimeFormattedString(int timeInMilliseconds) {
  DateFormat dateFormat = DateFormat('d MMM h:m a ',
      Locale(AppConfig.prefs.getString('language_code')).toLanguageTag());
  String dateOfTransaction = dateFormat.format(
    DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
  );
  return dateOfTransaction;
}

String formatChatDate(int timestamp, String timezone) {
  return DateFormat(
    'h:mm a',
    Locale(AppConfig.prefs.getString('language_code')).toLanguageTag(),
  ).format(
    getDateTimeAccToUserTimezone(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        timestamp,
      ),
      timezoneAbb: timezone,
    ),
  );
}

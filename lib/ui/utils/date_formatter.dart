import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';

//defaulting to en if sn found as sn is not supported
String getLangTag() {
  String langTag = AppConfig.prefs?.getString('language_code') ?? 'en';
  return langTag == 'sn' ? 'en' : langTag;
}

String getTimeFormattedString(int timeInMilliseconds, String locale) {
  DateFormat dateFormat =
      DateFormat('d MMM h:mm a ', Locale(locale ?? 'en').toLanguageTag());
  String dateOfTransaction = dateFormat.format(
    DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
  );
  return dateOfTransaction;
}

String formatChatDate(int timestamp, String timezone, String locale) {
  return DateFormat(
    'h:mm a, MMM dd,yyyy',
    Locale(locale ?? "en").toLanguageTag(),
  ).format(
    getDateTimeAccToUserTimezone(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        timestamp,
      ),
      timezoneAbb: timezone,
    ),
  );
}

String getTimeZoneFormattedString(
  int timeInMilliseconds,
  String timezoneAbb,
) {
  DateFormat dateFormat = DateFormat(
      'd MMM hh:mm a ', Locale(getLangTag()).toLanguageTag() ?? 'en');
  DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
  DateTime localtime = getDateTimeAccToUserTimezone(
      dateTime: datetime, timezoneAbb: timezoneAbb);
  String from = dateFormat.format(
    localtime,
  );
  return from;
}

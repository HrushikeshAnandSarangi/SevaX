import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/localization/app_timezone.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/timezone.dart';

extension DateTimeTimezone on BuildContext {
  DateTime getDateTime(int milliSeconds) {
    return getDateTimeAccToUserTimezone(
        dateTime: DateTime.fromMillisecondsSinceEpoch(milliSeconds),
        timezoneAbb: SevaCore.of(this)?.loggedInUser?.timezone ??
            Provider.of<AppTimeZone>(this)
                .appTimeZone
                .toString()
                .toUpperCase());
  }
}

DateTime getDateTimeAccToUserTimezone({
  required String timezoneAbb,
  required DateTime dateTime,
}) {
  var temp = TimezoneListData().getTimezoneData(timezoneAbb);
  int offsetFromUtc = temp[0];
  int offsetFromMin = temp[1];
  DateTime timeInUtc = dateTime.toUtc();
  DateTime localtime =
      timeInUtc.add(Duration(hours: offsetFromUtc, minutes: offsetFromMin));
  return localtime;
}

DateTime getUpdatedDateTimeAccToUserTimezone({
  required String timezoneAbb,
  required DateTime dateTime,
}) {
  var temp = TimezoneListData().getTimezoneData(timezoneAbb);
  int offsetFromUtc = temp[0];
  int offsetFromMin = temp[1];
  DateTime timeInUtc = dateTime.toUtc();
  DateTime localtime =
      timeInUtc.add(Duration(hours: offsetFromUtc, minutes: offsetFromMin));
  return localtime;
}

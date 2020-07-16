import 'package:meta/meta.dart';
import 'package:sevaexchange/views/profile/timezone.dart';

DateTime getDateTimeAccToUserTimezone({
  @required String timezoneAbb,
  @required DateTime dateTime,
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
  @required String timezoneAbb,
  @required DateTime dateTime,
}) {
  var temp = TimezoneListData().getTimezoneData(timezoneAbb);
  int offsetFromUtc = temp[0];
  int offsetFromMin = temp[1];
  DateTime timeInUtc = dateTime.toUtc();
  DateTime localtime =
      timeInUtc.add(Duration(hours: offsetFromUtc, minutes: offsetFromMin));
  return localtime;
}

import 'package:meta/meta.dart';
import 'package:sevaexchange/base/base_service.dart';

class TimeZonesService extends BaseService {
  /// Get local Time according to the [timezoneAbb] selected by the user by using [dateTime] passed by the user
  DateTime getDateTimeAccToUserTimezone({
    @required String timezoneAbb,
    @required DateTime dateTime,
  }) {
    log.i(
        'getDateTimeAccToUserTimezone: TimezoneABB: $timezoneAbb DateTime: $dateTime');
    int offsetFromUtc;
    if (timezoneAbb == 'ST')
      offsetFromUtc = -11;
    else if (timezoneAbb == 'HAT')
      offsetFromUtc = -10;
    else if (timezoneAbb == 'AKT')
      offsetFromUtc = -9;
    else if (timezoneAbb == 'PT')
      offsetFromUtc = -8;
    else if (timezoneAbb == 'MT')
      offsetFromUtc = -7;
    else if (timezoneAbb == 'CT')
      offsetFromUtc = -6;
    else if (timezoneAbb == 'ET')
      offsetFromUtc = -5;
    else if (timezoneAbb == 'AST')
      offsetFromUtc = -4;
    else if (timezoneAbb == 'ChT')
      offsetFromUtc = 10;
    else if (timezoneAbb == 'WIT')
      offsetFromUtc = 12;
    else
      offsetFromUtc = -8;

    DateTime timeInUtc = dateTime.toUtc();
    DateTime localtime = timeInUtc.add(Duration(hours: offsetFromUtc));
    return localtime;
  }
}

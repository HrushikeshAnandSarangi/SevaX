export '../search/search_service.dart';
//TODO: export preference service
//export '../preference_service.dart';
export '../firestore_service/firestore_service.dart';

import 'package:sevaexchange/base/base_service.dart';
import 'package:usage/uuid/uuid.dart';

class UtilsService extends BaseService {
  /// generate a Uuid
  String getUuid() {
    log.i('getUuid: ');
    return Uuid().generateV4();
  }

/// check if [year] is leap year
bool isLeapYear(int year) {
  log.i('isLeapYear: Year: $year');
  return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
}
/// check is [d1] and [d2] are same dates
bool isSameDay(DateTime d1, DateTime d2) {
  log.i('isSameDay: Date1: $d1 Date2: $d2 ');
  return (d1.year == d2.year && d1.month == d2.month && d1.day == d2.day);
}
}
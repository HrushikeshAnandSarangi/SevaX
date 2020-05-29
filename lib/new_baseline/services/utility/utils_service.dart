// export '../search/search_service.dart';
// //TODO: export preference service
// //export '../preference_service.dart';
// export '../firestore_service/firestore_service.dart';

// import 'package:sevaexchange/base/base_service.dart';
// import 'package:usage/uuid/uuid.dart';

// class UtilsService extends BaseService {
//   /// generate a Uuid
//   String getUuid() {
//     String uuid = Uuid().generateV4();
//     log.i('getUuid: $uuid');
//     return uuid;
//   }

//   /// check if [year] is leap year
//   bool isLeapYear(int year) {
//     log.i('isLeapYear: Year: $year');
//     bool isLeap = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
//     log.i('isLeapYear: $isLeap');
//     return isLeap;
//   }

//   /// check is [d1] and [d2] are same dates
//   bool isSameDay(DateTime d1, DateTime d2) {
//     log.i('isSameDay: Date1: $d1 Date2: $d2 ');
//     bool isSameDay =
//         (d1.year == d2.year && d1.month == d2.month && d1.day == d2.day);
//     log.i('isSameDay: $isSameDay');
//     return isSameDay;
//   }
// }

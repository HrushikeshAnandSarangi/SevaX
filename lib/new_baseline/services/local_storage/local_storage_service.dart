// import 'dart:async';

// import 'package:sevaexchange/base/base_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:meta/meta.dart';

// class LocalStorageService extends BaseService {
//   static const String _SEVA_USER_ID_KEY = 'sevaUserId';
//   static const String _SEVA_EMAIL_ID_KEY = 'emailId';

//   Future<String> get loggedInEmailId async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     return preferences.getString(_SEVA_EMAIL_ID_KEY);
//   }

//   Future<String> get loggedInUserId async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     return preferences.getString(_SEVA_USER_ID_KEY);
//   }

//   Future<bool> saveLoggedInUser({
//     @required String emailId,
//     @required String userId,
//   }) async {
//     assert(userId != null, 'USER ID cannot be null');
//     assert(emailId != null, 'EMAIL ID cannot be null');

//     SharedPreferences preferences = await SharedPreferences.getInstance();

//     bool a = await preferences.setString(_SEVA_USER_ID_KEY, userId);
//     bool b = await preferences.setString(_SEVA_EMAIL_ID_KEY, emailId);

//     return a && b;
//   }

//   Future<bool> logout() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     return preferences.clear();
//   }
// }

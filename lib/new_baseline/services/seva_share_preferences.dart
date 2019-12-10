import 'package:shared_preferences/shared_preferences.dart';

class SevaSharedPreferences {
  ///
  /// Instantiation of the SharedPreferences library
  ///

  final String _userID = "nothing";

  /// ------------------------------------------------------------
  /// Method that returns the user id
  /// ------------------------------------------------------------
  Future<String> getUserID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userID);
  }

  /// ----------------------------------------------------------
  /// Method that saves the user id
  /// ----------------------------------------------------------
  Future<bool> setUserID(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_userID, value);
  }
}

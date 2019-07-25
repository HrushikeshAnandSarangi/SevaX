import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager {
  static const String _SEVA_USER_ID_KEY = 'sevaUserId';
  static const String _SEVA_EMAIL_ID_KEY = 'emailId';

  static Future<SharedPreferences> get _instance async {
    return await SharedPreferences.getInstance();
  }

  static Future<String> get loggedInUserId async {
    SharedPreferences preferences = await _instance;
    return preferences.getString(_SEVA_USER_ID_KEY);
  }

  static Future<String> get loggedInUserEmail async {
    SharedPreferences preferences = await _instance;
    return preferences.getString(_SEVA_EMAIL_ID_KEY);
  }

  static Future<bool> setLoggedInUser({
    @required String userId,
    @required String emailId,
  }) async {
    assert(userId != null, 'USER ID cannot be null');
    assert(emailId != null, 'EMAIL ID cannot be null');
    SharedPreferences preferences = await _instance;
    bool a = await preferences.setString(_SEVA_USER_ID_KEY, userId);
    bool b = await preferences.setString(_SEVA_EMAIL_ID_KEY, emailId);

    return a && b;
  }

  static Future<bool> logout() async {
    SharedPreferences preferences = await _instance;
    return preferences.clear();
  }
}

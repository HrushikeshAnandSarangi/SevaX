import 'package:sevaexchange/base/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';

class LocalStorageService extends BaseService {
  static const String _SEVA_USER_ID_KEY = 'sevaUserId';
  static const String _SEVA_EMAIL_ID_KEY = 'emailId';

  static LocalStorageService _instance;
  static SharedPreferences _preferences;

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService();
      _instance.log.i('getInstance');
    }
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }

    return _instance;
  }

  String get loggedInEmailId => _preferences.getString(_SEVA_EMAIL_ID_KEY);

  String get loggedInUserId => _preferences.getString(_SEVA_USER_ID_KEY);

  Future<bool> saveLoggedInUser({
    @required String emailId,
    @required String userId,
  }) async {
    assert(userId != null, 'USER ID cannot be null');
    assert(emailId != null, 'EMAIL ID cannot be null');

    bool a = await _preferences.setString(_SEVA_USER_ID_KEY, userId);
    bool b = await _preferences.setString(_SEVA_EMAIL_ID_KEY, emailId);

    return a && b;
  }

  Future<bool> logout() async {
    return _preferences.clear();
  }
}

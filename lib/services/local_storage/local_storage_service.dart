import 'package:sevaexchange/base/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService extends BaseService {
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
}

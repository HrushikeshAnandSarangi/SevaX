import 'package:shared_preferences/shared_preferences.dart';

class UserConfig {
  static const String skip_skill = "skip_skill";
  static const String skip_interest = "skip_interest";
  static const String skip_bio = "skip_bio";

  static SharedPreferences prefs;
}

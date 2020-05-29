import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:sevaexchange/models/billing_plan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String appName = "SevaX";
  static const String skip_skill = "skip_skill";
  static const String skip_interest = "skip_interest";
  static const String skip_bio = "skip_bio";

  static BillingPlanModel billing;
  static SharedPreferences prefs;

  static int maxTransactionLimit;
  static int currentTransactionLimit;

  static RemoteConfig remoteConfig;

  static bool isTransactionAllowed() {
    return maxTransactionLimit != currentTransactionLimit;
  }
}

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:sevaexchange/models/billing_plan_model.dart';
import 'package:sevaexchange/models/upgrade_plan-banner_details_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String appName = "SevaX";
  static const String skip_skill = "skip_skill";
  static const String skip_interest = "skip_interest";
  static const String skip_bio = "skip_bio";
  static Map<String, dynamic> paymentStatusMap = {};
  static Map<String, dynamic> plan_transactions_matrix = {};

  static BillingPlanModel billing;
  static SharedPreferences prefs;

  static int maxTransactionLimit;
  static int currentTransactionLimit;

  static RemoteConfig remoteConfig;

  static bool isTransactionAllowed() {
    return maxTransactionLimit != currentTransactionLimit;
  }

  //App Info
//  static String appName;
  static String appVersion;
  static int buildNumber;
  static String packageName;

  //Platform checks
  static bool isWeb;
  static bool isMobile;

  //plan check data
  static UpgradePlanBannerModel upgradePlanBannerModel;
  static String helpIconContext = "seva_community";
}

class HelpIconContextClass {
  static String DEFAULT = "seva_community";
  static String COMMUNITY_DEFAULT = "seva_community";
  static String GROUP_DEFAULT = "groups";
  static String EVENTS = "events";
  static String REQUESTS = "requests";
  static String TIME_REQUESTS = "time_requests";
  static String MONEY_REQUESTS = "money_requests";
  static String GOODS_REQUESTS = "goods_requests";
  static String OFFERS = "offers";
  static String TIME_OFFERS = "time_offers";
  static String MONEY_OFFERS = "money_offers";
  static String GOODS_OFFERS = "goods_offers";
  static String ONE_TO_MANY_OFFERS = "one_to_many_offers";

  static String helpLinksBaseURL =
      "https://sevax-dev-project-for-sevax--video-urhtxovy.web.app";

  static Map<String, String> helpContextLinks = {
    "seva_community": "$helpLinksBaseURL#seva_community",
    "groups": "$helpLinksBaseURL#groups",
    "events": "$helpLinksBaseURL#events",
    "requests": "$helpLinksBaseURL#requests",
    "time_requests": "$helpLinksBaseURL#time_requests",
    "money_requests": "$helpLinksBaseURL#money_requests",
    "goods_requests": "$helpLinksBaseURL#goods_requests",
    "offers": "$helpLinksBaseURL#offers",
    "time_offers": "$helpLinksBaseURL#time_offers",
    "money_offers": "$helpLinksBaseURL#money_offers",
    "goods_offers": "$helpLinksBaseURL#goods_offers",
    "one_to_many_offers": "$helpLinksBaseURL#one_to_many_offers",
  };
}

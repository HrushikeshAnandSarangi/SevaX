import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:sevaexchange/models/billing_plan_model.dart';
import 'package:sevaexchange/models/enums/help_context_enums.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/upgrade_plan-banner_details_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String appName = "SevaX";
  static const String skip_skill = "skip_skill";
  static const String skip_interest = "skip_interest";
  static const String skip_bio = "skip_bio";
  static Map<String, dynamic> paymentStatusMap = {};
  static Map<String, dynamic> plan_transactions_matrix = {};
  static const supportedRequestTypeForRecurring = [
    RequestType.TIME,
    RequestType.ONE_TO_MANY_REQUEST,
    RequestType.BORROW
  ];

  static BillingPlanModel? billing;
  static SharedPreferences? prefs;
  static List<dynamic> testingEmails = [];

  static int? maxTransactionLimit;
  static int? currentTransactionLimit;

  static FirebaseRemoteConfig? remoteConfig;

  static bool isTransactionAllowed() {
    return maxTransactionLimit != currentTransactionLimit;
  }

  //App Info
//  static String appName;
  static String? appVersion;
  static int? buildNumber;
  static String? packageName;
  static String? loggedInEmail;

  //Platform checks
  static bool? isWeb;
  static bool? isMobile;

  //isTest Community
  static bool isTestCommunity = false;
  static TimebankConfigurations? timebankConfigurations;

  //plan check data
  static UpgradePlanBannerModel? upgradePlanBannerModel;
  static HelpContextMemberType helpIconContextMember =
      HelpContextMemberType.seva_community;

  static HelpContextAdminType helpIconContextAdmin =
      HelpContextAdminType.seva_community;
}

class HelpIconContextClass {
  // static String memberBaseUrl;
  // static String adminBaseUrl;

  // static Map<String, String> helpContextLinks = {
  //   "seva_community": "$helpLinksBaseURL#seva_community",
  //   "groups": "$helpLinksBaseURL#groups",
  //   "events": "$helpLinksBaseURL#events",
  //   "requests": "$helpLinksBaseURL#requests",
  //   "time_requests": "$helpLinksBaseURL#time_requests",
  //   "money_requests": "$helpLinksBaseURL#money_requests",
  //   "goods_requests": "$helpLinksBaseURL#goods_requests",
  //   "offers": "$helpLinksBaseURL#offers",
  //   "time_offers": "$helpLinksBaseURL#time_offers",
  //   "money_offers": "$helpLinksBaseURL#money_offers",
  //   "goods_offers": "$helpLinksBaseURL#goods_offers",
  //   "one_to_many_offers": "$helpLinksBaseURL#one_to_many_offers",
  // };

  static String linkBuilder({bool isAdmin = false}) {
    logger.i("is admin $isAdmin");
    return isAdmin
        ? "${AppConfig.remoteConfig!.getString('help_videos_admin')}#${AppConfig.helpIconContextMember.getValue()}"
        : "${AppConfig.remoteConfig!.getString('help_videos_member')}#${AppConfig.helpIconContextMember.getValue()}";
  }
}

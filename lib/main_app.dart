import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/news_model.dart';
//import 'package:flurry/flurry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.appFlavor = Flavor.APP;
//  await Flurry.initialize(androidKey: "NZN3QTYM42M6ZQXV3GJ8", iosKey: "H9RX59248T458TDZGX3Y", enableLog: true);
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _firebaseMessaging.requestNotificationPermissions(
    IosNotificationSettings(
      alert: true,
      badge: true,
      sound: true,
    ),
  );

  AppConfig.prefs = await SharedPreferences.getInstance();
  AppConfig.remoteConfig = await RemoteConfig.instance;
  AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 0));
  AppConfig.remoteConfig.activateFetched();
  // print(AppConfig.remoteConfig.getString("plans"));
  // AppConfig.billing = BillingPlanModel.fromJson(
  //     json.decode(AppConfig.remoteConfig.getString("plans")));
  // print(
  //     "--->plans ${AppConfig.billing.freePlan.action.adminReviewsCompleted.billable}");

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      return null;
    },
    onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return null;
    },
    onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return null;
    },
  );

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    // statusBarColor: Colors.white,
  ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) {
      Crashlytics.instance.enableInDevMode = true;
      FlutterError.onError = Crashlytics.instance.recordFlutterError;
      runApp(MainApplication());
      // runZoned(() {

      // }, onError: Crashlytics.instance.recordError);
    },
  );
}

class MainApplication extends StatelessWidget {
  final bool skipToHomePage;

  const MainApplication({Key key, this.skipToHomePage = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    NewsModel news;

    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: FlavorConfig.values.theme,
        title: AppConfig.appName,
        // home: RequestStatusView(
        //   requestId: "anitha.beberg@gmail.com*1573268670404",
        // ),
        builder: (context, child) {
          return GestureDetector(
            child: child,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          );
        },
        // home:BillingPlanDetails(),
        home: SplashView(
          skipToHomePage: skipToHomePage,
        ),
      ),
    );
  }
}

class News {}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/ui/utils/connectivity.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/news_model.dart';
import 'package:flurry/flurry.dart';
Future<void> fetchRemoteConfig() async {
  AppConfig.remoteConfig = await RemoteConfig.instance;
  AppConfig.remoteConfig.fetch(expiration: Duration.zero);
  AppConfig.remoteConfig.activateFetched();
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.appFlavor = Flavor.SEVA_DEV;
  await Flurry.initialize(androidKey: "NZN3QTYM42M6ZQXV3GJ8", iosKey: "H9RX59248T458TDZGX3Y", enableLog: true);
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _firebaseMessaging.requestNotificationPermissions(
    IosNotificationSettings(
      alert: true,
      badge: true,
      sound: true,
    ),
  );
  ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  AppConfig.prefs = await SharedPreferences.getInstance();
  await fetchRemoteConfig();
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
      // Crashlytics.instance.enableInDevMode = true;
      // FlutterError.onError = Crashlytics.instance.recordFlutterError;
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
              FocusScope.of(context).unfocus();
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

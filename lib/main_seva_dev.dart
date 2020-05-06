import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sevaexchange/app_localizations.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/ui/utils/connectivity.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/news_model.dart';

Future<void> fetchRemoteConfig() async {
  AppConfig.remoteConfig = await RemoteConfig.instance;
  AppConfig.remoteConfig.fetch(expiration: Duration.zero);
  AppConfig.remoteConfig.activateFetched();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.appFlavor = Flavor.SEVA_DEV;
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
        // List all of the app's supported locales here
        supportedLocales: [
          Locale('en', 'US'),
          Locale('sk', 'SK'),
        ],
        localizationsDelegates: [
          // A class which loads the translations from JSON files
          AppLocalizations.delegate,
          // Built-in localization of basic text for Material widgets
          GlobalMaterialLocalizations.delegate,
          // Built-in localization for text direction LTR/RTL
          GlobalWidgetsLocalizations.delegate,
        ],
        // Returns a locale which will be used by the app
        localeResolutionCallback: (locale, supportedLocales) {
          // Check if the current device locale is supported
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          // If the locale of the device is not supported, use the first one
          // from the list (English, in this case).
          return supportedLocales.first;
        },
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

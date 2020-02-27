import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/views/splash_view.dart';

import 'models/news_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.appFlavor = Flavor.APP;
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _firebaseMessaging.requestNotificationPermissions(
    IosNotificationSettings(
      alert: true,
      badge: true,
      sound: true,
    ),
  );

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

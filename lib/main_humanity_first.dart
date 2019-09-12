import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/views/splash_view.dart';

void main() {
  FlavorConfig.appFlavor = Flavor.HUMANITY_FIRST;

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

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarBrightness: Brightness.dark));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) {
      runApp(MainApplication());
    },
  );
}

class MainApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        theme: FlavorConfig.values.theme,
        home: SplashView(),
      ),
    );
  }
}

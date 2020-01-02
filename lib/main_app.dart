import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/views/invitation/OnboardWithTimebankCode.dart';
import 'package:sevaexchange/views/messages/new_select_member.dart';
import 'package:sevaexchange/views/messages/select_timebank_for_chat.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/views/timebanks/timebank_pinView.dart';
import 'package:sevaexchange/views/workshop/approvedUsers.dart';

import 'models/news_model.dart';
import 'views/messages/list_members_timebank.dart';

void main() {
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
    NewsModel news;

    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        theme: FlavorConfig.values.theme,
        // home: RequestStatusView(
        //   requestId: "anitha.beberg@gmail.com*1573268670404",
        // ),
        home: SplashView(),
      ),
    );
  }
}

class News {}

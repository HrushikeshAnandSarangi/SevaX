import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/applanguage.dart';
import 'package:sevaexchange/ui/utils/connectivity.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'models/news_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
Future<void> fetchRemoteConfig() async {
  AppConfig.remoteConfig = await RemoteConfig.instance;
  AppConfig.remoteConfig.fetch(expiration: Duration.zero);
  AppConfig.remoteConfig.activateFetched();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.appFlavor = Flavor.SEVA_DEV;
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
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
      runApp(MainApplication(appLanguage: appLanguage));
      // runZoned(() {

      // }, onError: Crashlytics.instance.recordError);
    },
  );
}

class MainApplication extends StatelessWidget {
  final bool skipToHomePage;
  final AppLanguage appLanguage;


  const MainApplication({Key key, this.skipToHomePage = false, this.appLanguage})
      : super(key: key);

  @override
  void initState() {}
  @override
  Widget build(BuildContext context) {
    NewsModel news;
    return ChangeNotifierProvider<AppLanguage>(
        builder: (_) => appLanguage,
    child: Consumer<AppLanguage>(builder: (context, model, child) {
      return AuthProvider(
        auth: Auth(),
        child: MaterialApp(
          locale: model.appLocal,
          supportedLocales: [
            Locale('en', 'US'),
            Locale('pt', 'PT'),
            Locale('fr', 'FR'),
            Locale('es', 'ES'),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
    }));
  }
}

class News {}

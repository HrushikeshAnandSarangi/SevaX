import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/localization/delegates/localization_delegate.dart';
import 'package:sevaexchange/ui/utils/connectivity.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  //Initialize app details
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  AppConfig.appVersion = packageInfo.version;
  AppConfig.buildNumber = int.parse(packageInfo.buildNumber);
  AppConfig.packageName = packageInfo.packageName;

  //SharedPreferences
  AppConfig.prefs = await SharedPreferences.getInstance();
  final AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
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
      runApp(
        MainApplication(),
      );
      // runZoned(() {

      // }, onError: Crashlytics.instance.recordError);
    },
  );
}

class MainApplication extends StatelessWidget {
  final AppLanguage appLanguage = AppLanguage()..fetchLocale();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
      create: (_) => appLanguage,
      child: Consumer<AppLanguage>(
        builder: (context, model, child) {
          return AuthProvider(
            auth: Auth(),
            child: MaterialApp(
              locale: model.appLocal,
              supportedLocales: S.delegate.supportedLocales,
              localizationsDelegates: [
                S.delegate,
                SnMaterialLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              theme: FlavorConfig.values.theme,
              title: AppConfig.appName,

              builder: (context, child) {
                return GestureDetector(
                  child: child,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                );
              },
              // home:BillingPlanDetails(),
              home: SplashView(),
            ),
          );
        },
      ),
    );
  }
}

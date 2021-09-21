import 'package:firebase_core/firebase_core.dart';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/localization/app_timezone.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/ui/screens/auth/bloc/user_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/ui/utils/connectivity.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> fetchRemoteConfig() async {
  AppConfig.remoteConfig = await RemoteConfig.instance;
  await AppConfig.remoteConfig.fetch(expiration: Duration.zero);
  await AppConfig.remoteConfig.activateFetched();
}

Future<void> initApp(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlavorConfig.appFlavor = flavor;

  FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
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

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    // statusBarColor: Colors.white,
  ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) {
      // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      runApp(
        Phoenix(
          child: MainApplication(),
        ),
      );
    },
  );
}

class MainApplication extends StatelessWidget {
  final bool skipToHomePage;
  final AppLanguage appLanguage = AppLanguage()..fetchLocale();
  final AppTimeZone appTimeZone = AppTimeZone()..fetchTimezone();

  MainApplication({Key key, this.skipToHomePage = false}) : super(key: key);
  final UserBloc userBloc = UserBloc();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => MembersBloc(),
          dispose: (_, b) => b.dispose(),
        ),
        Provider(
          create: (context) => HomePageBaseBloc(),
          dispose: (_, b) => b.dispose(),
        ),
        Provider(
          create: (context) => userBloc,
          dispose: (_, b) => b.dispose(),
        ),
        Provider(
          create: (context) => HomePageBaseBloc(),
          dispose: (_, b) => b.dispose(),
        ),
        // StreamProvider<UserModel>.value(
        //   initialData: null,
        //   value: userBloc.user,
        // ),
      ],
      child: ChangeNotifierProvider<AppLanguage>(
        create: (_) => appLanguage,
        child: Consumer<AppLanguage>(
          builder: (context, model, child) {
            return ChangeNotifierProvider<AppTimeZone>(
              create: (_) => appTimeZone,
              child: Consumer<AppTimeZone>(
                builder: (context, timezone, child) => AuthProvider(
                  auth: Auth(),
                  child: MaterialApp(
                    locale: model.appLocal,
                    supportedLocales: S.delegate.supportedLocales,
                    localizationsDelegates: [
                      S.delegate,
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
                    home: SplashView(
                      skipToHomePage: skipToHomePage,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

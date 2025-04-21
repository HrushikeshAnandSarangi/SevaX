// lib/app.dart
import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'
    show RemoteConfig;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
import 'package:sevaexchange/widgets/customise_community/theme_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simplified time zone handling for web
class WebSafeTimeZone extends ChangeNotifier {
  String _timezone = 'UTC';
  String get timezone => _timezone;
}

// Simplified locale handling for web
class WebSafeLanguage extends ChangeNotifier {
  Locale _appLocal = const Locale('en');
  Locale get appLocal => _appLocal;
}

Future<void> fetchRemoteConfig() async {
  AppConfig.remoteConfig = await FirebaseRemoteConfig.instance;
  await AppConfig.remoteConfig?.fetchAndActivate();
}

Future<void> initApp(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlavorConfig.appFlavor = flavor;

  // Skip FCM on web
  if (!kIsWeb) {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();

  // Handle package info for web
  if (kIsWeb) {
    AppConfig.appVersion = '1.0.0-web';
    AppConfig.buildNumber = 1;
    AppConfig.packageName = 'com.example.web';
  } else {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    AppConfig.appVersion = packageInfo.version;
    AppConfig.buildNumber = int.parse(packageInfo.buildNumber);
    AppConfig.packageName = packageInfo.packageName;
  }

  // SharedPreferences with error handling
  try {
    AppConfig.prefs = await SharedPreferences.getInstance();
  } catch (e) {
    log('Error initializing SharedPreferences: $e');
  }

  // Platform-specific initialization
  try {
    final AppLanguage appLanguage = AppLanguage();
    await appLanguage.fetchLocale();
    await fetchRemoteConfig();
  } catch (e) {
    log('Initialization error: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
  ));

  // Skip orientation lock on web
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  runApp(
    Phoenix(
      child: MainApplication(),
    ),
  );
}

class MainApplication extends StatelessWidget {
  final bool skipToHomePage;
  final WebSafeLanguage appLanguage = WebSafeLanguage();
  final WebSafeTimeZone appTimeZone = WebSafeTimeZone();

  MainApplication({Key? key, this.skipToHomePage = false}) : super(key: key);
  final UserBloc userBloc = UserBloc();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MembersBloc>(
          create: (context) => MembersBloc(),
          dispose: (_, MembersBloc b) => b.dispose(),
        ),
        Provider(
          create: (context) => HomePageBaseBloc(),
          dispose: (_, HomePageBaseBloc? b) => b?.dispose(),
        ),
        Provider(
          create: (context) => userBloc,
          dispose: (_, UserBloc? b) => b?.dispose(),
        ),
        Provider(
          create: (context) => ThemeBloc(),
          dispose: (_, ThemeBloc? b) => b?.dispose(),
        ),
      ],
      child: ChangeNotifierProvider<WebSafeLanguage>(
        create: (_) => appLanguage,
        child: ChangeNotifierProvider<WebSafeTimeZone>(
          create: (_) => appTimeZone,
          child: AuthProvider(
            auth: Auth(),
            child: MaterialApp(
              locale: const Locale('en'),
              supportedLocales: S.delegate.supportedLocales,
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              theme: FlavorConfig.values.theme!.copyWith(
                primaryColor: ThemeBloc.defaultColor,
                buttonTheme: ButtonThemeData(
                  buttonColor: ThemeBloc.defaultColor,
                ),
              ),
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
      ),
    );
  }
}

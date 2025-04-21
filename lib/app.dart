// lib/app.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
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
import 'package:sevaexchange/utils/connectivity.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/widgets/customise_community/theme_bloc.dart';
import 'package:sevaexchange/utils/connectivity_service.dart';

// Conditional imports for Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'
    hide RemoteConfig;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './firebase_options.dart';

// Enhanced platform detection with web safety
bool get isMobilePlatform {
  if (kIsWeb) return false;

  try {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  } catch (e) {
    log('Platform detection error: $e');
    return false;
  }
}

// Web-safe timezone handling
class PlatformTimeZone extends ChangeNotifier {
  String _timezone = 'UTC';
  String get timezone => _timezone;

  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Web implementation using browser APIs
        _timezone = await _getWebTimezone();
      } else {
        // Mobile implementation
        final appTimeZone = AppTimeZone();
        _timezone = await appTimeZone.fetchTimezone();
      }
      notifyListeners();
    } catch (e) {
      log('Timezone initialization error: $e');
      _timezone = 'UTC'; // Fallback
    }
  }

  Future<String> _getWebTimezone() async {
    try {
      // Using JavaScript interop or default browser timezone
      return DateTime.now().timeZoneName;
    } catch (e) {
      return 'UTC';
    }
  }
}

// Web-safe locale handling
class PlatformLanguage extends ChangeNotifier {
  Locale _appLocale = const Locale('en');
  Locale get appLocale => _appLocale;

  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Web implementation
        _appLocale = await _getWebLocale();
      } else {
        // Mobile implementation
        final appLanguage = AppLanguage();
        await appLanguage.fetchLocale();
        _appLocale = appLanguage.appLocal;
      }
      notifyListeners();
    } catch (e) {
      log('Language initialization error: $e');
      _appLocale = const Locale('en'); // Fallback
    }
  }

  Future<Locale> _getWebLocale() async {
    try {
      // Get browser language
      final languageCode = WidgetsBinding.instance.window.locale.languageCode;
      return Locale(languageCode);
    } catch (e) {
      return const Locale('en');
    }
  }
}

// Web-safe remote config
Future<void> fetchRemoteConfig() async {
  try {
    if (kIsWeb) {
      // Web fallback or API-based config
      AppConfig.remoteConfig = null;
      // Consider using environment variables or API calls for web config
    } else {
      // Mobile implementation
      AppConfig.remoteConfig = FirebaseRemoteConfig.instance;
      await AppConfig.remoteConfig?.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await AppConfig.remoteConfig?.fetchAndActivate();
    }
  } catch (e) {
    log('Remote config error: $e');
    AppConfig.remoteConfig = null;
  }
}

// Web-safe initialization
Future<void> initApp(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only where supported
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
    } else {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    log('Firebase initialization error: $e');
  }

  // Initialize flavor configuration safely
  try {
    FlavorConfig.appFlavor = flavor;
  } catch (e) {
    log('Flavor config error: $e');
  }

  // Initialize FCM only on mobile platforms
  if (!kIsWeb) {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      log('FCM permission error: $e');
    }
  }

  // Initialize connectivity monitoring
  try {
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    await connectionStatus.initialize();
  } catch (e) {
    log('Connectivity initialization error: $e');
  }

  // Handle package info with web-specific values
  try {
    if (kIsWeb) {
      AppConfig.appVersion = '1.0.0-web';
      AppConfig.buildNumber = 1;
      AppConfig.packageName = 'com.example.web';
    } else {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      AppConfig.appVersion = packageInfo.version;
      AppConfig.buildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;
      AppConfig.packageName = packageInfo.packageName;
    }
  } catch (e) {
    log('Package info error: $e');
    AppConfig.appVersion = '1.0.0';
    AppConfig.buildNumber = 1;
    AppConfig.packageName = 'com.example.app';
  }

  // Initialize SharedPreferences with error handling
  try {
    AppConfig.prefs = await SharedPreferences.getInstance();
  } catch (e) {
    log('SharedPreferences error: $e');
  }

  // Platform-specific initialization
  await fetchRemoteConfig();

  // UI configuration
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
  ));

  // Set orientation only for mobile devices
  if (!kIsWeb) {
    try {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
    } catch (e) {
      log('Orientation setting error: $e');
    }
  }

  runApp(
    Phoenix(
      child: MainApplication(),
    ),
  );
}

// Main application widget with web-safe theme handling
class MainApplication extends StatelessWidget {
  final bool skipToHomePage;
  final PlatformLanguage appLanguage = PlatformLanguage();
  final PlatformTimeZone appTimeZone = PlatformTimeZone();
  final UserBloc userBloc = UserBloc();

  MainApplication({Key? key, this.skipToHomePage = false}) : super(key: key);

  ThemeData _getTheme() {
    try {
      return FlavorConfig.values.theme?.copyWith(
            primaryColor: ThemeBloc.defaultColor,
            buttonTheme: ButtonThemeData(
              buttonColor: ThemeBloc.defaultColor,
            ),
          ) ??
          ThemeData.light();
    } catch (e) {
      log('Theme configuration error: $e');
      return ThemeData.light();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        appLanguage.initialize(),
        appTimeZone.initialize(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

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
            ChangeNotifierProvider<PlatformLanguage>.value(value: appLanguage),
            ChangeNotifierProvider<PlatformTimeZone>.value(value: appTimeZone),
          ],
          child: AuthProvider(
            auth: Auth(),
            child: Consumer2<PlatformLanguage, PlatformTimeZone>(
              builder: (context, language, timeZone, child) {
                return MaterialApp(
                  locale: language.appLocale,
                  supportedLocales: S.delegate.supportedLocales,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  debugShowCheckedModeBanner: false,
                  theme: _getTheme(),
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
                );
              },
            ),
          ),
        );
      },
    );
  }
}

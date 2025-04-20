import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/auth/auth.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/splash_view.dart';

import 'auth_provider.dart';

class AuthRouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<AuthRouter> {
  String? sevaUserId;
  final AppLanguage appLanguage = AppLanguage();

  AuthStatus? authStatus;

  UserModel? signedInUser;
  UserModel? fetchedUser;

  @override
  void initState() {
    super.initState();
    authStatus = AuthStatus.notDetermined;
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return getMaterialApp(
          view: SplashView(
            skipToHomePage: false,
          ),
        );
      default:
        return Container();
    }
  }

  Widget getMaterialApp({required Widget view}) {
    return ChangeNotifierProvider<AppLanguage>(
        create: (_) => appLanguage,
        child: Consumer<AppLanguage>(
          builder: (context, model, child) {
            return AuthProvider(
              auth: Auth(),
              child: MaterialApp(
                builder: (context, child) {
                  return GestureDetector(
                    child: child,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
                locale: model.appLocal,
                supportedLocales: S.delegate.supportedLocales,
                localizationsDelegates: [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                title: AppConfig.appName,
                debugShowCheckedModeBanner: false,
                theme: FlavorConfig.values.theme,
                home: view,
              ),
            );
          },
        ));
  }
}

enum AuthStatus {
  notDetermined,
  notSignedIn,
  notCreated,
  skillsNotSetup,
  interestsNotSetup,
  bioNotSetup,
  signedIn,
}

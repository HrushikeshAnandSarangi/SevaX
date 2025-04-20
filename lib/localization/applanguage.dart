import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/app_config.dart';

class AppLanguage extends ChangeNotifier {
  static Locale? _appLocale;

  Locale get appLocal => _appLocale ?? Locale("en");
  Locale fetchLocale() {
    if (AppConfig.prefs!.getString('language_code') == null) {
      _appLocale = Locale('en');
      return _appLocale!;
    }
    _appLocale = Locale(AppConfig.prefs!.getString('language_code')!);
    return _appLocale!;
  }

  void changeLanguage(Locale locale) async {
    if (_appLocale == locale &&
        AppConfig.prefs!.getString('language_code') != null) {
      return;
    }
    _appLocale = locale;
    await AppConfig.prefs!.setString('language_code', locale.languageCode);
    notifyListeners();
  }
}

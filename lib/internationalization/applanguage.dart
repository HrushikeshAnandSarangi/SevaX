import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  static Locale _appLocale;

  Locale get appLocal => _appLocale ?? Locale("en");
  fetchLocale() {
    if (AppConfig.prefs.getString('language_code') == null) {
      _appLocale = Locale('en');
      return _appLocale;
    }
    _appLocale = Locale(AppConfig.prefs.getString('language_code'));
    return _appLocale;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();

    if (_appLocale == type && prefs.getString('language_code') != null) {
      return;
    }

    if (type == Locale("pt")) {
      _appLocale = Locale("pt");
      await prefs.setString('language_code', 'pt');
      await prefs.setString('countryCode', 'PT');
    } else if (type == Locale("es")) {
      _appLocale = Locale("es");
      await prefs.setString('language_code', 'es');
      await prefs.setString('countryCode', 'ES');
    } else if (type == Locale("fr")) {
      _appLocale = Locale("fr");
      await prefs.setString('language_code', 'fr');
      await prefs.setString('countryCode', 'FR');
    }else if (type == Locale("ja")) {
      _appLocale = Locale("ja");
      await prefs.setString('language_code', 'ja');
      await prefs.setString('countryCode', 'JA');
    }else if (type == Locale("zh")) {
      _appLocale = Locale("zh");
      await prefs.setString('language_code', 'zh');
      await prefs.setString('countryCode', 'zh');
    }else if (type == Locale("ko")) {
      _appLocale = Locale("ko");
      await prefs.setString('language_code', 'io');
      await prefs.setString('countryCode', 'KO');
    }else if (type == Locale("ru")) {
      _appLocale = Locale("ru");
      await prefs.setString('language_code', 'ru');
      await prefs.setString('countryCode', 'RU');
    }else if (type == Locale("de")) {
      _appLocale = Locale("de");
      await prefs.setString('language_code', 'de');
      await prefs.setString('countryCode', 'DE');
    } else {
      _appLocale = Locale("en");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
    }
    notifyListeners();
  }
}

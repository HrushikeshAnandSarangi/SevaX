import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlatformLanguage extends ChangeNotifier {
  Locale _appLocale = const Locale('en');

  Locale get appLocale => _appLocale;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final String languageCode = prefs.getString('language_code') ?? 'en';
    _appLocale = Locale(languageCode);
  }

  Future<void> changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    _appLocale = locale;
    notifyListeners();
  }
}



import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/profile/timezone.dart';

class AppTimeZone extends ChangeNotifier {
  static String  _appTimezone;

  String get appTimeZone => _appTimezone ?? 'Pacific Standard Time';

  String fetchTimezone() {
    if (AppConfig.prefs.getString('timezone') == null) {

      String timezoneName = DateTime.now().timeZoneName.toLowerCase();
      var exists = TimezoneListData().timezonelist.firstWhere(
            (element) => element.timezoneName.toLowerCase() == timezoneName.toLowerCase(),
        orElse: () => null,
      );
      if (exists == null) {
        timezoneName = 'PACIFIC TIME'.toLowerCase();
      }
      _appTimezone = timezoneName;
      return _appTimezone;
    }
    _appTimezone = AppConfig.prefs.getString('timezone');
    return _appTimezone;
  }

  void changeTimeZone(String zone) async {
    if (_appTimezone == zone &&
        AppConfig.prefs.getString('timezone') != null) {
      return;
    }

    _appTimezone = zone;
    AppConfig.prefs.setString('timezone', zone);
    notifyListeners();
    logger.e("INSIDE $_appTimezone");
    logger.e("CHANGED $zone");
  }
}